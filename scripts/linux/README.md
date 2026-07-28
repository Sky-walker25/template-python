# Linux — one-time setup

This prepares your machine to use the **Python dev-container template** with
**Podman**. On Linux, Podman runs natively — there is no virtual machine to
install or manage. You run this **once** per machine.

> Already comfortable with the terminal? Jump to [Run it](#1-run-the-script).
> Curious what it changes first? See [What it does](#what-it-does).

---

## 1. Run the script

Download it and run it:

```bash
curl -fsSL https://raw.githubusercontent.com/Sky-walker25/template-python/main/scripts/linux/bootstrap.sh -o bootstrap.sh
bash bootstrap.sh
```

Or, manualy download it and run:

```bash
bash ./Downloads/bootstrap.sh
```

The script asks before changing anything. Two options if you prefer:

| Option    | Effect                                             |
| --------- | -------------------------------------------------- |
| `--check` | Only reports what is installed — changes nothing.  |
| `--yes`   | Non-interactive: accepts defaults, asks nothing.   |

Good habit: run `bash bootstrap.sh --check` first to see the starting state.

---

## What it does

It is **idempotent** — running it again only fixes what is missing, and it
**never overwrites an existing SSH key**.

- **Podman** — installs it with your package manager (`apt`, `dnf`, `pacman`
  or `zypper`) if it is missing, then checks that rootless mode works.
- **Copier** — installs it (via [`uv`](https://docs.astral.sh/uv/), which
  brings its own Python), so you can generate projects from the template.
- **git** — installs it if missing, sets your name/email, and picks a friendly
  default editor (VS Code if available).
- **SSH** — generates an `ed25519` key if you have none, loads it into the
  agent, and makes it persistent in `~/.ssh/config`.

That's all. No VM, no background service, no reboot.

---

## 2. Add your SSH key to your Git forge

At the end, the script prints your **public** key. Copy it into your forge:

- **GitHub** → Settings → *SSH and GPG keys* → New SSH key
- **GitLab / Gitea** → Preferences → *SSH Keys*

This lets `git` push/pull from inside the container.

---

## 3. Open the template in VS Code

1. Install [**VSCode**](https://code.visualstudio.com/download) and then the [**Dev Containers**](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension.
2. Go to **Settings** -> **Extensions** -> **Dev Containers**

   ```
   Dev > Containers: Docker Path

   docker
   ```
3. Change it to podman

   ```
   Dev > Containers: Docker Path

   podman
   ```

## 4. Create your project

```bash
copier copy --trust git@github.com:Sky-walker25/template-python.git my-project
```

Open the new folder in VS Code and choose **Reopen in Container**. Done.
