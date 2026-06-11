# 0002 - nix-darwinのスコープを最小限にする

## ステータス

承認済み

## コンテキスト

nix-darwinはmacOSのシステム設定（Dock、キーボード、スクリーンセーバーなど）やHomebrew管理も含めて幅広く管理できる。
Chieさんは非エンジニアで、macOSの設定は自分の好みで手動管理している。

## 決定

nix-darwinの役割をNix自体のブートストラップと基本設定（`nix.settings`、`system.stateVersion`など）に限定する。
開発ツールとdotfilesの管理はすべてhome-managerに委ねる。

## 根拠

- **非エンジニアユーザーへの配慮**：macOSのシステム設定をNixで管理すると、Chieさんが手動で変更した設定がNix適用時に上書きされるリスクがある
- **複雑さの排除**：nix-darwinの全機能を使うと設定量が増え、README手順も複雑になる
- **同僚への展開**：設定がシンプルであるほど、同僚が同じ設定を適用しやすい
- **責務の明確化**：「システム設定 = 手動」「開発ツール = home-manager」と役割が明確

## 却下した選択肢

- **nix-darwinでmacOS設定もフル管理**：理論的には一貫性が高いが、非エンジニアユーザーには混乱の元になる
- **nix-darwinでHomebrew管理**：Homebrewを採用しない決定（ADR-0001）と矛盾する

## 結果

- `darwin.nix`はNixの設定と`system.stateVersion`のみの薄いファイルになる
- macOSの見た目や動作はChieさんが自由にカスタマイズできる
