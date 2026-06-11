# 0004 - ローカルLLMランタイムとしてOllamaを採用する

## ステータス

承認済み

## コンテキスト

Chieさんは翻訳・スペルチェック・文法修正のためにローカルLLMを使いたい。
MacBook Pro（Apple Silicon M系、32GBメモリ）上で動作する必要がある。
Nixで管理できることが望ましい。

## 決定

ローカルLLMランタイムとしてOllamaを採用し、Nixパッケージとして管理する。

## 根拠

- **Nixパッケージが存在する**：`nixpkgs`にOllamaパッケージがあり、home-managerで宣言的に管理できる
- **Apple Silicon対応**：Metal（AppleのGPU API）を自動的に使用するため、32GBメモリを最大限に活用できる
- **Open WebUIとの連携**：OllamaはOpen WebUIのバックエンドとして標準サポートされている
- **モデル管理のシンプルさ**：`ollama pull <model名>`の一コマンドでモデルを追加できる

## 却下した選択肢

- **LM Studio**：GUIが充実しているが、Nixパッケージが存在せずCaskでの管理になる。再現性を保てない
- **llamafile**：単一バイナリでシンプルだが、複数モデルの管理やUIとの連携が弱い
- **llama.cpp**：低レベルで設定が複雑。非エンジニア向けではない

## 結果

- `home.nix`に`services.ollama.enable = true`を記述するだけで管理できる
- モデルのダウンロードは手動で行い、READMEに推奨モデル（gemma3:27b、qwen2.5:14bなど）を記載する
