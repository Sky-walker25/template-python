# macOS — one-time setup

This prepares your Mac to use the **Python dev-container template**. You run it
once. You will set up a container engine (**Docker Desktop** below — or
**Podman** as an alternative at the very end), then a few developer tools via
the bootstrap script.

---

## 1. Install Docker Desktop

Docker Desktop is the container engine. It manages its own lightweight virtual
machine — there is nothing else to size, start or keep running.

1. Download [**Docker Desktop for Mac**](https://www.docker.com/products/docker-desktop/)
   (choose **Apple Silicon** or **Intel** to match your Mac).

2. Open **Docker Desktop** and wait until the whale icon in the menu bar reads
   *"Docker Desktop is running"*.

> Prefer Podman? Skip this step and follow
> [Using Podman instead](#using-podman-instead) at the end — the rest is identical.

---

## 2. Run the bootstrap script

Download it and run it:

```bash
curl -fsSL https://raw.githubusercontent.com/Sky-walker25/template-python/main/scripts/macos/bootstrap.sh -o bootstrap.sh
bash bootstrap.sh
```

Or, manualy download it and run:

```bash
bash ./Downloads/bootstrap.sh
```

| Option    | Effect                                            |
| --------- | ------------------------------------------------- |
| `--check` | Only reports what is installed — changes nothing. |
| `--yes`   | Non-interactive: accepts defaults, asks nothing.  |

It is **idempotent** and **never overwrites an existing SSH key**. It:

- installs **Copier** (via [`uv`](https://docs.astral.sh/uv/), which brings its
  own Python) so you can generate projects,
- installs the **Xcode Command Line Tools** (which provide `git`) if missing,
- sets your **git** name/email and a friendly default editor,
- generates an **SSH key** and loads it into the agent via the **Keychain**, so
  it is available again after every reboot.

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

```bash
copier copy --trust git@github.com:Sky-walker25/template-python.git my-project
```

Open the new folder in VS Code and choose **Reopen in Container**. Done.

---

## Using Podman instead

Podman is a daemonless, rootless, fully open-source alternative to Docker. If
you go this way, replace **step 1** with the following — everything else
(steps 2 to 5) is unchanged.

1. Install [**Podman Desktop**](https://podman-desktop.io), it creates and
   starts the Podman virtual machine for you. Or install podman cli and start the VM
   yourself:

   ```bash
   podman machine init
   podman machine start
   ```

2. Point VS Code at Podman — **Settings** → **Extensions** → **Dev Containers**:

   ```
   Dev > Containers: Docker Path

   podman
   ```
   or if this does not work try
   ```
   Dev > Containers: Docker Path

   /opt/podman/bin/podman
   ```
