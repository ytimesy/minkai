# みんなの開発村

誰でも開発テーマを投稿し、設計の論点を整理しながら参加者を集めるRailsアプリです。
機械、ロボット、政策、Webサイト、料理など、領域を限定しない開発支援サイトとして作っています。

## 機能

- 開発テーマの投稿
- 課題、対象者、成功条件、参加募集内容の整理
- プロジェクトごとの参加メモ投稿
- `ops.com` / `www.ops.com` のproductionホスト許可

## 開発

```sh
bundle install
bin/rails db:setup
bin/rails server
```

テスト:

```sh
bin/rails test
```
