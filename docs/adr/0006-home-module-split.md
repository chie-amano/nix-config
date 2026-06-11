# 0006 - Split home configuration into llm/dev/personal layers

## Status

Accepted

## Context

The nix-config repository serves two audiences:
1. Chie — needs a full development environment (LLM, Python/R, editor, personal tools like tmux/vim)
2. Colleagues — non-engineers who only need a local LLM environment (Ollama + Open WebUI)

A single `home.nix` file cannot serve both audiences without requiring colleagues to install tools they don't need, or forcing them to manually comment out irrelevant sections.

## Decision

Split home-manager configuration into three composable modules:

- `modules/home-llm.nix` — LLM environment only (Ollama, Colima, Docker CLI). Shareable with colleagues.
- `modules/home-dev.nix` — Development tools (git, Pixi, VS Code, ghq). Shareable, but optional.
- `modules/home-personal.nix` — Chie's personal preferences (tmux, vim, etc.). Not intended for sharing.
- `modules/home.nix` — Chie's full setup, composes all three modules above.

User-specific settings (`home.username`, `home.homeDirectory`) are NOT placed in module files. They are set in `flake.nix` so that modules are fully portable across different users.

## Rationale

- **Single responsibility**: each module has a clear, stated purpose
- **Colleagues only touch one file**: by keeping user settings in `flake.nix`, colleagues edit only `flake.nix` to get started
- **Reusability**: `home-llm.nix` works for any user without modification
- **Extensibility**: adding tools like tmux/vim to `home-personal.nix` does not affect the shareable modules

## Rejected alternatives

- **Single `home.nix` with feature flags**: boolean flags add complexity and are harder to explain to non-engineers
- **Separate repository for colleagues**: splits maintenance effort; upstream changes are harder to sync

## Consequences

- Colleagues clone this repo, edit `flake.nix` (only), and apply the configuration
- `flake.nix` includes a commented-out template for colleagues to uncomment and fill in
- Chie's `home.nix` imports the other three modules; adding personal tools goes into `home-personal.nix`
