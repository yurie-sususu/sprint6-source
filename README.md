# デプロイが問題なくできるかテスト

# おみくじAPI (Omikuji API)

Go言語で実装されたおみくじAPIサーバーです。ELB/AutoScalingハンズオン用のサンプルアプリケーションとして設計されています。

## 技術スタック

- Go 1.21+
- 標準ライブラリのみ使用（外部依存なし）

## API仕様

| エンドポイント | メソッド | 説明 |
|---------------|---------|------|
| `/omikuji` | GET | おみくじを引く |
| `/hostname` | GET | インスタンスのホスト名（ID）を取得 |
| `/health` | GET | ヘルスチェック |
| `/stress` | GET | CPU負荷テスト（Auto Scaling検証用） |

## エンドポイント詳細

### GET `/omikuji` - おみくじを引く

ランダムにおみくじの結果を返します。

**レスポンス例:**
```json
{
  "result": "大吉",
  "message": "すべてがうまくいく最高の運勢です！"
}
```

**おみくじの種類:**
- 大吉: すべてがうまくいく最高の運勢です！
- 中吉: 良いことが起こりそうな予感です。
- 小吉: 小さな幸せが訪れるでしょう。
- 吉: 穏やかな一日になりそうです。
- 末吉: 努力が実を結ぶ兆しがあります。
- 凶: 慎重に行動することをお勧めします。
- 大凶: 今日は控えめに過ごしましょう。

### GET `/hostname` - ホスト名取得

負荷分散の確認用エンドポイントです。EC2インスタンスIDを返します。

**レスポンス例:**
```json
{
  "hostname": "i-0123456789abcdef0"
}
```

### GET `/health` - ヘルスチェック

ALBのターゲットグループで使用するヘルスチェック用エンドポイントです。

**レスポンス例:**
```json
{
  "status": "healthy"
}
```

### GET `/stress` - CPU負荷テスト

Auto Scalingの動作確認用エンドポイントです。60秒間CPU負荷をかけます。

**レスポンス例:**
```json
{
  "message": "CPU stress test started for 60 seconds"
}
```

## 環境変数

| 変数名 | 必須 | 説明 |
|--------|-----|------|
| INSTANCE_ID | × | EC2インスタンスID（userdataで自動設定） |

## ローカル開発

### 前提条件

- Go 1.21以上

### セットアップ

1. 依存関係をインストール（標準ライブラリのみなので不要）

```bash
go mod tidy
```

2. 起動

```bash
go run main.go
```

サーバーが `http://localhost:80` で起動します（root権限が必要）。

開発時は別ポートで起動することも可能です：

```go
// main.go の最後の行を変更
log.Fatal(http.ListenAndServe(":8080", nil))
```

### ビルド

```bash
go build -o omikuji-api main.go
./omikuji-api
```

## APIの使用例

### おみくじを引く

```bash
curl http://localhost/omikuji
```

### ホスト名確認（負荷分散テスト）

```bash
# 10回連続でリクエストを送信し、異なるインスタンスに振り分けられることを確認
for i in {1..10}; do curl http://localhost/hostname; echo; done
```

### ヘルスチェック

```bash
curl http://localhost/health
```

### CPU負荷テスト（Auto Scaling検証）

```bash
curl http://localhost/stress
```

## EC2へのデプロイ

EC2インスタンスのユーザーデータで `userdata/api_userdata.sh` を実行することで、自動的にセットアップされます。

### 必要なパッケージ

- golang
- git
- stress-ng（負荷テスト用）

### systemdサービス

アプリケーションは `omikuji-api.service` として systemd で管理されます。

```bash
# サービスの状態確認
sudo systemctl status omikuji-api

# サービスの再起動
sudo systemctl restart omikuji-api

# ログの確認
sudo journalctl -u omikuji-api -f
```
