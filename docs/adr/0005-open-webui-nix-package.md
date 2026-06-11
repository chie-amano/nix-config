# 0005 - Open WebUIをDockerで動かす

## ステータス

差し替え済み（当初はNixパッケージでの管理を予定していたが変更）

## コンテキスト

Chieさんが日常的にローカルLLMを使うためのUIが必要。
Open WebUIはChatGPTライクなWebUIで、Ollamaとの連携が標準サポートされている。
公式の推奨実行方法はDockerだが、当初はNixパッケージでの管理を試みた。

## 決定

Open WebUIをDockerで動かす。OllamaはNixで管理し、Open WebUIはDockerコンテナとして起動する。

## 経緯

当初はNixパッケージ（`pkgs.open-webui`）でlaunchdサービスとして管理する方針だったが、
nixpkgs 26.05/unstable ともに macOS でのビルドが失敗することが判明：
- `python3.13-dlinfo` が macOS に存在しない `libdl.dylib` を要求してテスト失敗
- `open-webui-frontend` のnpmビルドが macOS の Nix サンドボックスで `kqueue.c` assertion error で失敗

これらは nixpkgs の open-webui パッケージが主に Linux 向けにテスト・メンテナンスされているための問題。

## 根拠

- **公式推奨方法**：DockerはOpen WebUIの公式推奨実行方法
- **確実に動く**：nixpkgsでのビルド問題を完全に回避できる
- **自動起動**：`--restart always` オプションでDocker Desktop起動時に自動起動
- **データ永続化**：Dockerボリュームでチャット履歴等を保持できる

## 却下した選択肢

- **Nixパッケージ**：macOSでビルドが失敗する（上記経緯参照）
- **Enchanted（App Store）**：Open WebUIより機能が限定的

## 結果

- ColimaとDocker CLIをNixで管理（`home.packages`に追加）
- ColimaをlaunchdサービスとしてNixで自動起動（Docker Desktopは不要）
- `docker run` コマンドでOpen WebUIを起動（READMEに記載）
- OllamaはNixのlaunchdサービスとして動き、Dockerコンテナからは `OLLAMA_BASE_URL=http://host.docker.internal:11434` で接続
- ブラウザで `http://localhost:3000` を開くだけでLLMを使える
