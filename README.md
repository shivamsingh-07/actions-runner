# 🏃 GitHub Actions Self-Hosted Runner

Spin up a **self-hosted GitHub Actions runner** inside a Vagrant VM — one script to provision, register, and run.

---

## ✨ What is this?

This project gives you a **repeatable, disposable** environment to run [GitHub Actions](https://docs.github.com/en/actions) workloads on your own machine. A single Ubuntu VM is provisioned with:

- 📦 **Latest GitHub Actions runner** (Linux x64/arm64)
- 🐳 **Docker** (for containerized jobs)
- 🔧 **Build tools** (Python 3, build-essential, curl, jq)

The runner is installed as a **systemd service** and starts on boot. Perfect for local CI, experiments, or air-gapped setups.

---

## 📋 Prerequisites

| Requirement                                                       | Notes                                                        |
| ----------------------------------------------------------------- | ------------------------------------------------------------ |
| [Vagrant](https://www.vagrantup.com/)                             | 2.x                                                          |
| [VirtualBox](https://www.vagrantup.com/docs/providers/virtualbox) | Or another Vagrant provider (adjust `Vagrantfile` if needed) |
| Bash                                                              | For the setup script (Linux/macOS/WSL)                       |

---

## 🚀 Quick setup

From the project root, run:

```bash
./setup-runner.sh
```

The script will:

1. **Start the VM** and run `provision.sh` (packages, Docker, runner download).
2. **Ask you for**:
    - **Repository URL** — e.g. `https://github.com/your-org/your-repo`
    - **Registration token** — from _Repo/Org → Settings → Actions → Runners → New self-hosted runner_
    - **Runner name** (optional) — or press Enter to use the hostname
3. **Register** the runner with GitHub and **install + start** it as a service.

When it finishes, check **Settings ⇒ Actions ⇒ Runners** in your repo — your new runner should appear. ✅

---

## 🛑 Decommission

To unregister the runner from GitHub (VM must be up):

```bash
./remove-runner.sh
```

You’ll be prompted for the **removal token** (GitHub ⇒ Settings ⇒ Actions ⇒ Runners ⇒ select runner ⇒ Remove ⇒ copy token). The script stops the service, unregisters the runner, then runs `vagrant destroy -f` to remove the VM.

---

## 📁 Project layout

| File               | Purpose                                                                                         |
| ------------------ | ----------------------------------------------------------------------------------------------- |
| `Vagrantfile`      | VM definition (Ubuntu 24.04, 2 CPU, 2 GB RAM, VirtualBox)                                       |
| `provision.sh`     | Runs inside the VM: updates packages, installs Docker, downloads the latest runner (idempotent) |
| `setup-runner.sh`  | Interactive setup: `vagrant up` + register runner + install service                             |
| `remove-runner.sh` | Decommission: prompts for removal token, unregisters runner, then destroys the VM               |

Runner install path inside the VM: **`/home/vagrant/actions-runner`**.

---

## 🔧 Useful commands

| Command           | Description                                                              |
| ----------------- | ------------------------------------------------------------------------ |
| `vagrant up`      | Create and provision the VM                                              |
| `vagrant ssh`     | Open a shell in the VM                                                   |
| `vagrant halt`    | Stop the VM                                                              |
| `vagrant destroy` | Delete the VM (runner registration is lost; re-run setup to re-register) |

Inside the VM you can use:

- `./svc.sh status` — runner service status
- `sudo ./svc.sh stop` / `sudo ./svc.sh start` — stop/start the runner

---

## 💡 Tips

- **Token expiry** — Registration tokens from GitHub expire quickly (~1 hour). If config fails, generate a new token and run the config step again.
- **Re-provisioning** — `vagrant provision` re-runs `provision.sh`; the script skips re-downloading the runner if it’s already present.

---

Enjoy your self-hosted runner. 🎉
