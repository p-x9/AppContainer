# AppContainer

まるでコンテナを載せ替えるかのように、一つのアプリで複数の環境を作成・管理することのできるライブラリです。

<!-- # Badges -->

[![Github issues](https://img.shields.io/github/issues/p-x9/AppContainer)](https://github.com/p-x9/AppContainer/issues)
[![Github forks](https://img.shields.io/github/forks/p-x9/AppContainer)](https://github.com/p-x9/AppContainer/network/members)
[![Github stars](https://img.shields.io/github/stars/p-x9/AppContainer)](https://github.com/p-x9/AppContainer/stargazers)
[![Github top language](https://img.shields.io/github/languages/top/p-x9/AppContainer)](https://github.com/p-x9/AppContainer/)

> Language Switch: [日本語](https://github.com/p-x9/AppContainer/blob/main/README.ja.md).

## 原理
### ディレクトリ
アプリが書き込み可能な領域は、ホームディレクトリ配下にあります。
UserDefaultsもCoreDataもCookieも、アプリが生成するデータは全てここに保存されています。
このディレクトリをコンテナごとに載せ替えることで複数の環境を作成しています。
コンテナは、Library配下に特別なディレクトリを用意してそこに退避させるように実装しています。
```
// UserDefaults
Library/Preferences/XXXXX.plist

// CoreData
Library/Application Support/YOU_APP_NAME

// Cookie
Library/Cookies
```

### UserDefaults/CFPreferences
`UserDefaults`やその上位実装である`CFPreferences`はsetされたデータを、別プロセスである`cfprefsd`というものによってキャッシングをおこなっています。
これらはsetされたデータをplistファイルに保存し永続化をおこなっていますが、上記のキャッシングにより、plist内のデータと`UserDefaults`/`CFPreferences`から取得できるデータは常に等しくなるわけではありません。（非同期で読み書きが行われる。）
これはアプリの再起動を行っても同期されるとは限りません。
よってコンテナの有効化処理を行う処理で、同期を行う処理をおこなっています。 

## ドキュメント
### AppGroup
```swift
extension AppContainer {
    static let group = .init(groupIdentifier: "YOUR APP GROUP IDENTIFIER")
}
```
### メソッド
#### コンテナの作成
 ```swift
 let container = try AppContainer.standard.createNewContainer(name: "Debug1")
 ```

#### コンテナのリスト
元のコンテナは`DEFAULT`という名前で、UUIDは`00000000-0000-0000-0000-000000000000`となっています。
`isDefault`というプロパティで確認できます。
```swift
let containers: [Container] = AppContainer.standard.containers
```

#### 現在使用されているコンテナ
```swift
let activeContainer: Container? = AppContainer.standard.activeContainer
```

#### コンテナの有効化
このメソッドを呼んだ後は、アプリを再起動することをお勧めします。
```swift
try AppContainer.standard.activate(container: container)
```
```swift
try AppContainer.standard.activateContainer(uuid: uuid)
```

#### コンテナの削除
もし削除しようとしているコンテナが使用中の場合、Defaultコンテナを有効化してから削除します。
```swift
try AppContainer.standard.delete(container: container)
```
```swift
try AppContainer.standard.deleteContainer(uuid: uuid)
```

#### コンテナの中身を初期化
```swift
try AppContainer.standard.clean(container: container)
```
```swift
try AppContainer.standard.cleanContainer(uuid: uuid)
```

#### リセット
このライブラリを使用する前の状態に戻します。
具体的には、DEFAULTコンテナを有効にして、その他のAppContainer関連のファイルは全て削除されます。
```swift
try AppContainer.standard.reset()
```