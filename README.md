# nix-config

macOS development environment for Chie's MacBook Pro, managed with Nix + nix-darwin + home-manager.

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

First time only:

```bash
# Replace #Chies-MacBook-Pro to your LocalHostName before run the following command.
sudo nix run nix-darwin -- switch --flake .#Chies-MacBook-Pro
```

Subsequent updates:

```bash
# Replace #Chies-MacBook-Pro to your LocalHostName before run the following command.
nix flake update
sudo darwin-rebuild switch --flake .#Chies-MacBook-Pro
```

> `nix flake update` updates `flake.lock` as your own user (not root) before running `darwin-rebuild` as root. This keeps `flake.lock` owned by you.

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

Find the commented-out template near the bottom of `flake.nix` and uncomment it.
Replace two values:

| Placeholder | How to find your value |
|-------------|----------------------|
| `your-macbook` | `scutil --get LocalHostName` |
| `yourname` | `whoami` |

### Step 4 — Apply

```bash
sudo nix run nix-darwin -- switch --flake .#your-macbook
```

### Step 5 — Download a model and start Open WebUI

Same as steps 5–6 above.

---

## Updating the configuration

```bash
cd ~/ghq/github.com/chie-amano/nix-config
nix flake update
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
├── flake.nix               # entry point; also contains colleague template
├── modules/
│   ├── darwin.nix          # minimal nix-darwin system settings
│   ├── home-llm.nix        # LLM environment (shareable)
│   ├── home-dev.nix        # development tools (shareable)
│   ├── home-personal.nix   # personal tools — Chie only
│   └── home.nix            # Chie's full setup (imports all three)
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

