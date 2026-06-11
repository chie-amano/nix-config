# nix-config

Chieの MacBook Pro 開発環境設定です。
Nix + nix-darwin + home-manager を使って、Python/R 開発環境とローカル LLM 環境を構築します。

## この設定でできること

- **Python / R 開発環境**：[Pixi](https://pixi.sh) でプロジェクトごとに再現性のある環境を作成
- **ローカル LLM**：[Ollama](https://ollama.com) でローカルで大規模言語モデルを実行
- **LLM Web UI**：[Open WebUI](https://docs.openwebui.com) でブラウザから ChatGPT 風に LLM を使用（翻訳・文法修正など）
- **VS Code**：コードエディタ

## セットアップ手順

### 前提条件

- macOS がインストールされた Apple Silicon Mac
- インターネット接続

---

### ステップ 1：Nix のインストール

ターミナル（`アプリケーション > ユーティリティ > ターミナル`）を開き、以下のコマンドを実行します。

```bash
curl -sSfL https://artifacts.nixos.org/nix-installer | sh -s -- install --enable-flakes
```

インストール完了後、**ターミナルを一度閉じて再度開いてください**。

動作確認：

```bash
nix --version
```

---

### ステップ 2：設定ファイルのカスタマイズ

#### Mac のユーザー名を確認する

```bash
whoami
```

表示されたユーザー名が `Chie` でない場合は、`modules/home.nix` の以下の 2 箇所を変更してください：

```nix
home.username = "Chie";        # ← whoami の結果に変更
home.homeDirectory = "/Users/Chie";  # ← /Users/あなたのユーザー名 に変更
```

#### Mac のホスト名を確認する

```bash
scutil --get LocalHostName
```

`flake.nix` の `"chie-macbook"` の部分を、表示されたホスト名に変更してください：

```nix
darwinConfigurations."Chies-MacBook-Pro" = ...
# ↑ ここを scutil --get LocalHostName の結果に変更
```

#### Git のメールアドレスを設定する

`modules/home.nix` の以下の行を変更してください：

```nix
userEmail = "achse603@gmail.com"; # ← 実際のメールアドレスに変更
```

---

### ステップ 3：このリポジトリを取得する

```bash
nix run nixpkgs#ghq get github.com/chie-amano/nix-config
cd ~/ghq/github.com/chie-amano/nix-config
```

---

### ステップ 4：設定を適用する

初回のみ、nix-darwin のインストーラーを使います：

```bash
sudo nix run nix-darwin -- switch --flake .#Chies-MacBook-Pro
```

> `Chies-MacBook-Pro` の部分は、ステップ 2 で確認したホスト名に合わせてください。

2 回目以降（設定を更新したとき）：

```bash
sudo darwin-rebuild switch --flake .#Chies-MacBook-Pro
```

---

### ステップ 5：LLM モデルをダウンロードする

Ollama は自動起動するよう設定されています。以下のコマンドでモデルをダウンロードします。

**日本語の翻訳・文法修正におすすめのモデル（どちらか 1 つでも OK）：**

```bash
# 高品質・多言語対応（約 15 GB、ダウンロードに時間がかかります）
ollama pull gemma3:27b

# 軽量・高速（約 8 GB）
ollama pull qwen2.5:14b
```

---

### ステップ 6：Open WebUI を起動する

Colima（Docker の実行環境）は Nix によって自動起動するよう設定されています。
**初回のみ** VM イメージのダウンロードに数分かかります。以下のコマンドで起動を待ちます：

```bash
# Colima が起動するまで待つ（Starting... → Running と表示されたら OK）
colima status
```

起動を確認したら Open WebUI を起動します：

```bash
docker run -d \
  -p 3000:8080 \
  -e OLLAMA_BASE_URL=http://host.docker.internal:11434 \
  -v open-webui:/app/backend/data \
  --name open-webui \
  --restart always \
  ghcr.io/open-webui/open-webui:main
```

Mac 再起動後は Colima と Open WebUI が自動的に立ち上がります。

ブラウザで [http://localhost:3000](http://localhost:3000) を開くと、ChatGPT 風の画面が表示されます。
モデルを選択して翻訳・文法修正などに使えます。

---

## 設定の更新方法

このリポジトリの設定を変更したあとは：

```bash
cd ~/ghq/github.com/chie-amano/nix-config
nix flake update   # flake.lock を自分のユーザーで更新（rootにならないように）
sudo darwin-rebuild switch --flake .#Chies-MacBook-Pro
```

nixpkgs のバージョンは固定されているので、`nix flake update` を頻繁に実行する必要はありません。実行すると nixpkgs・nix-darwin・home-manager がすべて最新に更新されます。

---

## Python / R プロジェクトの使い方

各プロジェクトのフォルダで Pixi を使います。詳細は [Pixi 公式ドキュメント](https://pixi.sh/latest/) を参照してください。

```bash
# 新しいプロジェクトを始める
pixi init my-project
cd my-project

# パッケージを追加する（例：Python データ分析）
pixi add python pandas matplotlib jupyterlab

# 環境を起動する
pixi shell

# JupyterLab を起動する
jupyter lab
```

---

## ファイル構成

```
.
├── flake.nix          # Nix Flake のエントリポイント
├── modules/
│   ├── darwin.nix     # nix-darwin の最小設定
│   └── home.nix       # home-manager でインストールするツール
├── docs/
│   └── adr/           # 設計上の意思決定記録
└── README.md
```

---

## トラブルシューティング

### Open WebUI が開かない

```bash
# Open WebUI コンテナの状態を確認する
docker ps -a --filter name=open-webui

# ログを確認する
docker logs open-webui
```

### Open WebUI を手動で再起動する

```bash
docker restart open-webui
```

### Colima が起動していない

```bash
# ログを確認する
cat /tmp/colima.log

# 手動で起動する
colima start

# 状態を確認する
colima status
```

### Ollama が応答しない

```bash
# ログを確認する
cat /tmp/ollama.log

# Ollama を手動で再起動する
launchctl unload ~/Library/LaunchAgents/org.nixos.ollama.plist
launchctl load ~/Library/LaunchAgents/org.nixos.ollama.plist
```

---

## Nix のアンインストール方法

この環境をすべて削除したい場合は以下を実行します。

### ステップ 1：nix-darwin を削除する

```bash
nix --extra-experimental-features "nix-command flakes" run nix-darwin#darwin-uninstaller
```

### ステップ 2：Nix 本体を削除する

```bash
/nix/nix-installer uninstall
```

ターミナルを再起動すると、Mac が Nix をインストール前の状態に戻ります。
