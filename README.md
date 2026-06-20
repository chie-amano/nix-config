# nix-config

macOS development environment for Chie's MacBook Pro, managed with Nix + nix-darwin + home-manager.

## Two layers: system (sudo) vs. user (no sudo)

The configuration is split into two independent layers so that everyday app
changes never require `sudo`:

| Layer | Tool | Command | When |
|-------|------|---------|------|
| **System** | nix-darwin | `sudo darwin-rebuild switch --flake .#Chies-MacBook-Pro` | Rare — only Nix daemon / system settings (`darwin.nix`) |
| **User** | home-manager (standalone) | `home-manager switch --flake .#Chie` | Often — every app / dotfile change, **no sudo** |

Almost everything Chie edits day-to-day (ghostty, tmux, git, nixvim, lazygit,
LLM tools, …) lives in the **user** layer, so the normal workflow is just
`home-manager switch` with no `sudo`.

## What this sets up

| Module | Contents | Audience |
|--------|----------|----------|
| `home-llm.nix` | Ollama, Colima, Docker CLI, launchd auto-start | Everyone |
| `home-dev.nix` | git, Pixi, VS Code, ghq, zsh | Developers |
| `home-personal.nix` | Personal tools (tmux, vim, …) | Chie only |
| `home.nix` | Full setup — imports all three above | Chie only |

The specific applications to be installed are described in each module file.

If you want to install the minimum necessary configuration to run Local LLM,
modify the section for Chie in `flake.nix` to refer to the commented-out section.
(This is explained in Step 3.)

---

## Setup — Chie's full environment

### Prerequisites

- Apple Silicon Mac with macOS installed
- Internet connection

---

### Step 1 — Install Nix

Nix is an open-source package manager that automatically installs and configures
applications specified in Nix files.
We will install it using [the official Nix installer](https://github.com/NixOS/nix-installer).

Open Terminal (`Applications > Utilities > Terminal`) and run:

```bash
curl -sSfL https://artifacts.nixos.org/nix-installer | sh -s -- install --enable-flakes
```

Close and reopen the terminal when the installer finishes.

Verify:

```bash
nix --version
```

---

### Step 2 — Clone this repository

The following command copies the files from this GitHub repository to your local machine.

```bash
nix run nixpkgs#ghq get github.com/chie-amano/nix-config
cd ~/ghq/github.com/chie-amano/nix-config
```

---

### Step 3 — Verify your hostname and username

Check the hostname (computer name) and username of your MacBook Pro.
The Nix package manager will need this information when installing applications.

```bash
scutil --get LocalHostName   # must match the key in flake.nix
whoami                       # must match home.username in home.nix
```

If they differ, update `flake.nix` and `modules/home.nix` accordingly.

---

### Step 4 — Apply the configuration

The configuration has two layers. Apply the **system** layer once (needs
`sudo`), then the **user** layer (no `sudo`).

**4a — System layer (nix-darwin) — first time only:**

```bash
# Replace #Chies-MacBook-Pro to your LocalHostName before running the command.
sudo nix run nix-darwin -- switch --flake .#Chies-MacBook-Pro
```

This sets up Nix's system-level settings. You will only need to repeat this
when `modules/darwin.nix` changes (rare).

**4b — User layer (home-manager) — first time:**

```bash
nix run home-manager/release-26.05 -- switch --flake .#Chie
```

After this first run, the `home-manager` command is on your PATH, so every
later change is applied **without sudo**:

```bash
home-manager switch --flake .#Chie
```

> Updating package versions: run `nix flake update` first (updates `flake.lock`
> as your own user), then `home-manager switch --flake .#Chie`.

---

### Step 5 — Download LLM models

Ollama starts automatically. Pull one or both of these recommended models for translation and grammar correction:
Refer the tip section to choose how to find best LLM model on your PC.

```bash
# High quality, multilingual (~15 GB — takes a while)
ollama pull gemma3:27b

# Lighter and faster (~8 GB)
ollama pull qwen2.5:14b
```

---

### Step 6 — Start Open WebUI

Colima starts automatically at login. The first boot downloads a VM image — wait for it:

```bash
colima status   # wait until status shows "Running"
```

Then start Open WebUI (run once; Docker restarts it automatically after that):

```bash
docker run -d \
  -p 3000:8080 \
  -e OLLAMA_BASE_URL=http://host.docker.internal:11434 \
  -v open-webui:/app/backend/data \
  --name open-webui \
  --restart always \
  ghcr.io/open-webui/open-webui:main
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

---

## Setup — Colleagues (LLM environment only)

This gives you Ollama + Open WebUI without touching your existing git or other tools.

### Prerequisites

- Apple Silicon Mac
- git (from Xcode Command Line Tools — run `xcode-select --install` if needed)

### Step 1 — Install Nix

```bash
curl -sSfL https://artifacts.nixos.org/nix-installer | sh -s -- install --enable-flakes
```

Reopen the terminal when done.

### Step 2 — Clone this repository

```bash
git clone https://github.com/chie-amano/nix-config.git ~/ghq/github.com/chie-amano/nix-config
cd ~/ghq/github.com/chie-amano/nix-config
```

### Step 3 — Add your configuration to flake.nix

Find the commented-out `homeConfigurations` template near the bottom of
`flake.nix` and uncomment it. Replace one value:

| Placeholder | How to find your value |
|-------------|----------------------|
| `yourname` | `whoami` |

### Step 4 — Apply (no sudo)

```bash
nix run home-manager/release-26.05 -- switch --flake .#yourname
```

Later updates just need `home-manager switch --flake .#yourname`.

### Step 5 — Download a model and start Open WebUI

Same as steps 5–6 above.

---

## Updating the configuration

Everyday app / dotfile changes (the user layer) — **no sudo**:

```bash
cd ~/ghq/github.com/chie-amano/nix-config
# (optional) bump package versions: nix flake update
home-manager switch --flake .#Chie
```

System-level changes (only when `modules/darwin.nix` changes) — needs sudo:

```bash
sudo darwin-rebuild switch --flake .#Chies-MacBook-Pro
```

---

## Using Pixi for Python / R projects

See the [Pixi documentation](https://pixi.sh/latest/) for full details.

```bash
pixi init my-project
cd my-project

# Add packages
pixi add python pandas matplotlib jupyterlab

# Enter the environment
pixi shell

# Start JupyterLab
jupyter lab
```

---

## Repository layout

```
.
├── flake.nix               # entry point: darwinConfigurations (system)
│                           # + homeConfigurations (user); colleague template
├── modules/
│   ├── darwin.nix          # minimal nix-darwin system settings (sudo layer)
│   ├── home-llm.nix        # LLM environment (shareable)
│   ├── home-dev.nix        # development tools (shareable)
│   ├── home-personal.nix   # personal tools — Chie only
│   └── home.nix            # Chie's full home-manager setup (imports all three)
├── docs/
│   └── adr/                # architecture decision records
└── README.md
```

---

## Troubleshooting

### Open WebUI is not loading

```bash
docker ps -a --filter name=open-webui
docker logs open-webui
```

### Restart Open WebUI manually

```bash
docker restart open-webui
```

### Colima is not running

```bash
cat /tmp/colima.log
colima start
colima status
```

### Ollama is not responding

```bash
cat /tmp/ollama.log
launchctl unload ~/Library/LaunchAgents/org.nix-community.home.ollama.plist
launchctl load  ~/Library/LaunchAgents/org.nix-community.home.ollama.plist
```

---

## Uninstalling

### Step 1 — Remove nix-darwin

```bash
nix --extra-experimental-features "nix-command flakes" run nix-darwin#darwin-uninstaller
```

### Step 2 — Remove Nix

```bash
/nix/nix-installer uninstall
```

Reopen the terminal and your Mac is back to its pre-Nix state.

## Tips

### How to choose appropreate model for your machine

A tool [whichllm](https://github.com/Andyyyy64/whichllm) support to choose the best local LLM model
on your specific hardware setups.

To use,

```bash
nix run nixpkgs#uv uvx whichllm@latest
```

