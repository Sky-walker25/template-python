# Windows — one-time setup

This prepares your PC to use the **Python dev-container template**. You run it
once. You will set up a container engine (**Docker Desktop** below — or
**Podman** as an alternative at the very end), then a few developer tools via
the bootstrap script.

---

## 1. Install Docker Desktop

Docker Desktop is the container engine. On Windows it runs on WSL 2, which it
sets up for you — you may need to reboot once during the first install.

1. Download [**Docker Desktop for Windows**](https://www.docker.com/products/docker-desktop/)
   and install it (keep the default *"Use WSL 2"* option).

2. Open **Docker Desktop** and wait until it reads *"Docker Desktop is running"*.

> Prefer Podman? Skip this step and follow
> [Using Podman instead](#using-podman-instead) at the end — the rest is identical.

---

## 2. Run the bootstrap script

Open **PowerShell**, download the script and run it:

```powershell
irm https://gitlab.accenta.ai/accenta/recherche/template-python/-/raw/orbit/scripts/windows/bootstrap.ps1 -OutFile bootstrap.ps1
powershell -ExecutionPolicy Bypass -File .\bootstrap.ps1
```

Or, manually download it and run:

```powershell
powershell -ExecutionPolicy Bypass -File .\Downloads\bootstrap.ps1
```

| Option   | Effect                                            |
| -------- | ------------------------------------------------- |
| `-Check` | Only reports what is installed — changes nothing. |
| `-Yes`   | Non-interactive: accepts defaults, asks nothing.  |

It is **idempotent** and **never overwrites an existing SSH key**. It:

- installs **git** (Git for Windows, via `winget`, silent — no wizard) if missing,
- installs **Copier** (via [`uv`](https://docs.astral.sh/uv/), which brings its
  own Python) so you can generate projects,
- sets your **git** name/email and a friendly default editor,
- generates an **SSH key** and enables the **ssh-agent** service (this opens one
  admin prompt) so the key loads again on every reboot.

---

## 3. Add your SSH key to your Git forge

At the end, the script prints your **public** key. Copy it into your forge:

- **GitHub** → Settings → *SSH and GPG keys* → New SSH key
- **GitLab / Gitea** → Preferences → *SSH Keys*

---

## 4. Open the template in VS Code

1. Install [**VS Code**](https://code.visualstudio.com/download) and then the
   [**Dev Containers**](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
   extension.

2. With Docker Desktop, **no extra setting is needed** — VS Code uses `docker`
   by default.

---

## 5. Create your project

```powershell
copier copy --trust git@gitlab.accenta.ai:accenta/recherche/template-python.git my-project
```

Open the new folder in VS Code and choose **Reopen in Container**. Done.

---

## Using Podman instead

Podman is a daemonless, rootless, fully open-source alternative to Docker. If
you go this way, replace **step 1** with the following — everything else
(steps 2 to 5) is unchanged.

1. Install [**Podman Desktop**](https://podman-desktop.io) — it installs Podman,
   sets up WSL 2, and creates + starts the Podman machine for you. Or install the
   CLI and start the machine yourself:

   ```powershell
   podman machine init
   podman machine start
   ```

2. Point VS Code at Podman — **Settings** → **Extensions** → **Dev Containers**:

   ```
   Dev > Containers: Docker Path

   podman
   ```
   or if this does not work try the full path
   ```
   Dev > Containers: Docker Path

   C:\Users\<you>\AppData\Local\Programs\Podman\podman.exe
   ```
