# 概要
YAMAHA RTX1000の備忘録メモ\
マニュアル\
http://www.rtpro.yamaha.co.jp/RT/manual/Rev.9.00.01/Users.pdf

Luaスクリプトを動かせる機種のほうが良かったかも、、、、なるほど\
https://network.yamaha.com/setting/router_firewall/monitor/lua_script/manual
## 接続関係
### シリアル接続
MacOSの場合、USBにシリアルポート変換機器をつなぐとUSB機器としてそのまま使用できる

```sh
screen /dev/tty.usbxxxx
# xxxxの文字列は環境による
```

最初真っ黒画面の場合、`enter`
後は案内に従う

screenの終了は ctrl + a -> k -> y


## コマンド関係
- `?`でヘルプがでる
- コマンドの途中でも出る
- タブ保管が結構効く
- 設定周りをいじるのは基本admin -> save
- 一部設定は再起動するまで有効に鳴らない

### よく使うコマンド一覧
トップレベルコマンドは補完が聞きにくいのでメモ

- show
- administrator
- save [num] [comment]
  - セーブポイントをいくつか作れる。デフォルト０番。
- no xxx
  - 設定の取り消し。上書きしてくれないものもあるので注意
- restart
  - 再起動


### 初回やっておくこと
IPをクライアント側に払い出せるところまで行けば、以降はLANを差すだけでGUI設定できる。\
初期化状態でも、macアドレスをipv6に変換するして直接アクスすればできる、、、らしい。\
(ref: ブロードバンドルーター最小構成 http://www.rtpro.yamaha.co.jp/RT/docs/example/broadband/pppoe-private.html )

- 初期化
  - `cold start`
- adminのパスワード設定
  - `administrator password`
- ログインパスワード設定
  - `login password`
- 無操作タイムアウト時間変更（デフォルト300s）
  - `login timer <sec>`
- コンソールの設定
  - 文字コードを英語に（デフォルトだと日本語エラー表示で、文字化けする場合）
    - `console character ascii`
  - プロンプト設定（複数台ある場合、識別するために）
    - `console prompt {つけたい名前}`
- 時刻設定
  - `date YYYY/MM/dd`
  - `time hh:mm:ss`
  - `timezone jst`
- LANポートのIPv4設定
  - 以下のような感じで、必要に応じて
  - 固定（ローカルネット構築など）
    - `ip lan1 address 192.168.1.1/24`
  - DHCPから取得してくる（WAN側）
    - `ip lan3 address dhcp`
    - ついでにデフォルトゲートウェイの設定も入れておく
    - `ip route default gateway dhcp lan3`
- DHCPサーバ設定
  - `dhcp service server`
  - `dhcp scope 1 192.168.1.2-192.168.1.10/24`
- DNSサーバ設定
  - `dns server dhcp lan3`
- NAT設定
  - WAN-LANの転送設定をいれる、デフォルトはipcp（PPP接続のとき）になっている
  - `nat descriptor type 1 masquerade`
  - `ip lan3 nat descriptor 1`
  - `nat descriptor address outer 1 primary`
- ntp設定(RTXからネットが見える様になった段階のどこかで)
  - `ntpdate jp.pool.ntp.org`

出来上がるconfig

```
administrator password *
timezone +09:00
console character ascii
console prompt 1st
login timer 3600
ip route default gateway dhcp lan3
ip lan1 address 192.168.1.1/24
ip lan3 address dhcp
ip lan3 nat descriptor 1
nat descriptor type 1 masquerade
nat descriptor address outer 1 primary
dhcp service server
dhcp server rfc2131 compliant except remain-silent
dhcp scope 1 192.168.1.2-192.168.1.10/24
dns server dhcp lan3
```

構成

```
+------------------+
|                  |
|    Internet      |
+-------+----------+
        | .xxx
        |
        | xxx.xxx.xxx.0/24
        |
   lan3 | .dhcp
+-------+----------+
|  Yamaha RTX1000  |
|       1st        |
+-------+----------+
   lan1 | .1
        |
        | 192.168.1.0/24
        |
        | .dhcp
+-------+----------+
|    client PC     |
|                  |
+------------------+

```
