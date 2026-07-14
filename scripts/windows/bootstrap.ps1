#Requires -Version 5.1
<#
.SYNOPSIS
  Host bootstrap for the Python template (Windows).

.DESCRIPTION
  Verifies (and installs when missing) the tools you need to generate and work
  on projects from the template: Copier, git, a git identity, and an SSH key.
  Idempotent: re-running only fixes what is missing, and it never overwrites an
  existing SSH key.

.PARAMETER Yes
  Non-interactive: take defaults, no prompts.
.PARAMETER Check
  Report only (doctor); change nothing.

.EXAMPLE
  .\bootstrap.ps1
.EXAMPLE
  .\bootstrap.ps1 -Yes
.EXAMPLE
  .\bootstrap.ps1 -Check
#>
[CmdletBinding()]
param(
  [switch]$Yes,
  [switch]$Check
)
# This script drives native tools (winget, git, ssh) that legitimately write to
# stderr and return non-zero for expected states. 'Stop' would turn any such
# stderr into a terminating NativeCommandError, so we stay on 'Continue' and
# check $LASTEXITCODE / guard with try-catch explicitly.
$ErrorActionPreference = 'Continue'

$TemplateUrl = 'git@gitlab.accenta.ai:accenta/recherche/template-python.git'
$SshKey      = Join-Path $HOME '.ssh\id_ed25519'
$Interactive = -not $Yes

# ---- pretty output --------------------------------------------------------
function Say  ($m) { Write-Host $m }
function Info ($m) { Write-Host "-> $m" -ForegroundColor Cyan }
function Ok   ($m) { Write-Host "OK $m" -ForegroundColor Green }
function Warn ($m) { Write-Host " ! $m" -ForegroundColor Yellow }
function Err  ($m) { Write-Host " x $m" -ForegroundColor Red }
function Hr        { Write-Host ('-' * 54) -ForegroundColor DarkGray }
function Have ($c) { [bool](Get-Command $c -ErrorAction SilentlyContinue) }

function Ask ($q, [string]$def = 'y') {
  if (-not $Interactive) { return ($def -eq 'y') }
  $hint = if ($def -eq 'y') { '[Y/n]' } else { '[y/N]' }
  $a = Read-Host "$q $hint"
  if ([string]::IsNullOrWhiteSpace($a)) { $a = $def }
  return ($a -match '^[yY]')
}

# ---- doctor ---------------------------------------------------------------
function Doctor {
  Hr; Say "Doctor - current state"; Hr
  if (Have git)    { Ok "git: present" } else { Warn "git: not found (will install)" }
  if (Have copier) { Ok "Copier: present" } else { Warn "Copier: missing (will install)" }
  if (Test-Path $SshKey) { Ok "SSH key: $SshKey" } else { Warn "SSH key: none (will generate)" }
  $svc = Get-Service ssh-agent -ErrorAction SilentlyContinue
  if ($null -eq $svc) { Warn "ssh-agent service: not present (install the OpenSSH Client feature)" }
  elseif ($svc.Status -eq 'Running') { Ok "ssh-agent service: running" }
  else { Warn "ssh-agent service: $($svc.Status)/$($svc.StartType) (needs admin to enable)" }
  Hr
}

# ---- actions --------------------------------------------------------------
function Ensure-Git {
  if (Have git) { Ok "git present"; return }
  # The Git for Windows wizard is confusing for novices; winget installs it
  # silently with sane defaults (one UAC prompt, no wizard).
  if (Have winget) {
    Info "git not found - installing Git for Windows via winget (silent, no wizard)..."
    winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements
    $gitCmd = Join-Path $env:ProgramFiles 'Git\cmd'
    if (Test-Path $gitCmd) { $env:Path = "$gitCmd;$env:Path" }   # winget updates the system PATH, not this process
  } else {
    Warn "winget not available. Install Git from https://gitforwindows.org (the defaults are fine)."
  }
  if (Have git) { Ok "git installed" }
  else { Err "git still not found. Install it, then re-run this script."; exit 1 }
}

function Ensure-Copier {
  if (Have copier) { Ok "Copier already installed"; return }
  if (-not (Have uv) -and -not (Have pipx)) {
    # No Python yet: bootstrap uv (self-contained, no admin, brings its own
    # Python) so Copier can be installed without any prior Python setup.
    Info "No uv or pipx found - installing uv to bootstrap Copier..."
    try { irm https://astral.sh/uv/install.ps1 | iex } catch { Warn "uv installer failed: $_" }
    $env:Path = "$env:USERPROFILE\.local\bin;$env:USERPROFILE\.cargo\bin;$env:Path"
  }
  if (Have uv) {
    uv tool install copier --with copier-template-extensions
    uv tool update-shell 2>$null   # put uv's tool bin on PATH for new shells
    Ok "Copier installed"
  } elseif (Have pipx) {
    pipx install copier; pipx inject copier copier-template-extensions
    Ok "Copier installed"
  } else {
    Warn "Could not bootstrap Copier - install uv or pipx, then re-run."
  }
}

function Ensure-GitIdentity {
  # Friendly default editor: a bare `git commit` opens this. Git for Windows
  # defaults to Vim, which traps novices - prefer VS Code if its CLI is present,
  # else Notepad. Never override an editor the user already chose.
  if (-not (git config --global core.editor 2>$null)) {
    if (Have code) { git config --global core.editor "code --wait"; Ok "git editor: VS Code" }
    else           { git config --global core.editor notepad;       Ok "git editor: Notepad" }
  }
  $name  = (git config --global user.name)  2>$null
  $email = (git config --global user.email) 2>$null
  if ($name -and $email) { Ok "git identity: $name <$email>"; return }
  if (-not $Interactive) { Warn "git user.name / user.email not set"; return }
  if (-not $name)  { $name  = Read-Host "git user.name";  git config --global user.name  $name }
  if (-not $email) { $email = Read-Host "git user.email"; git config --global user.email $email }
  Ok "git identity set"
}

function Ensure-Ssh {
  $sshDir = Split-Path $SshKey
  if (-not (Test-Path $sshDir)) { New-Item -ItemType Directory -Path $sshDir | Out-Null }

  if (-not (Test-Path $SshKey)) {
    $comment = (git config --global user.email) 2>$null
    if (-not $comment) { $comment = "$env:USERNAME@$env:COMPUTERNAME" }
    Info "Generating an SSH key (ed25519)..."
    if ($Interactive) {
      ssh-keygen -t ed25519 -f $SshKey -C $comment
    } else {
      # Empty passphrase for unattended runs. PowerShell 5.1 drops a bare ''
      # argument, so pass '""' there; 6+ passes '' through correctly.
      $empty = if ($PSVersionTable.PSVersion.Major -ge 6) { '' } else { '""' }
      ssh-keygen -t ed25519 -f $SshKey -C $comment -N $empty
    }
    Ok "SSH key created"
  } else {
    Ok "SSH key present - leaving it untouched"
  }

  # The Windows ssh-agent service is disabled by default; enabling it needs admin.
  $svc = Get-Service ssh-agent -ErrorAction SilentlyContinue
  $enableCmd = 'Set-Service ssh-agent -StartupType Automatic; Start-Service ssh-agent'
  if ($null -eq $svc) {
    Warn "OpenSSH ssh-agent service missing; install the 'OpenSSH Client' optional feature."
  } elseif ($svc.Status -ne 'Running') {
    if ($Interactive -and (Ask "Enable the ssh-agent service now? (opens an admin prompt)" 'y')) {
      try {
        Start-Process powershell -Verb RunAs -Wait -ArgumentList '-NoProfile', '-Command', $enableCmd
        Ok "ssh-agent service enabled"
      } catch { Warn "Elevation cancelled. In an admin PowerShell run:  $enableCmd" }
    } else {
      Warn "ssh-agent is not running. In an admin PowerShell run:  $enableCmd"
    }
  } else {
    Ok "ssh-agent service running"
  }

  ssh-add $SshKey 2>$null
  if ($LASTEXITCODE -eq 0) { Ok "Key added to agent" } else { Warn "Could not add key (is ssh-agent running?)" }

  $cfg = Join-Path $sshDir 'config'
  $marker = '# template-python bootstrap'
  if ((Test-Path $cfg) -and (Select-String -Path $cfg -SimpleMatch $marker -Quiet)) {
    Ok "~/.ssh/config already configured"
  } else {
    $block = "`n$marker`nHost *`n  AddKeysToAgent yes`n  IdentityFile $SshKey`n"
    Add-Content -Path $cfg -Value $block
    Ok "Persistence added to ~/.ssh/config"
  }
}

# ---- summary --------------------------------------------------------------
function Summary {
  Hr; Say "Done - next steps"; Hr
  if (Test-Path "$SshKey.pub") {
    Say "Add this SSH public key to your Git forge(s):"
    Say (Get-Content "$SshKey.pub")
    Say ""
  }
  Say "Then create a project:"
  Say "  copier copy --trust $TemplateUrl my-project"
  Hr
}

# ---- main -----------------------------------------------------------------
Say "Python template - host bootstrap (Windows)"
Doctor
if ($Check) { exit 0 }
Ensure-Git
Ensure-Copier
Ensure-GitIdentity
Ensure-Ssh
Summary
