# AppContainer

まるでコンテナを載せ替えるかのように、一つのアプリで複数の環境を作成・管理することのできるライブラリです。

<!-- # Badges -->

[![Github issues](https://img.shields.io/github/issues/p-x9/AppContainer)](https://github.com/p-x9/AppContainer/issues)
[![Github forks](https://img.shields.io/github/forks/p-x9/AppContainer)](https://github.com/p-x9/AppContainer/network/members)
[![Github stars](https://img.shields.io/github/stars/p-x9/AppContainer)](https://github.com/p-x9/AppContainer/stargazers)
[![Github top language](https://img.shields.io/github/languages/top/p-x9/AppContainer)](https://github.com/p-x9/AppContainer/)


## デモ
|  Default  |  Debug1  |
| ---- | ---- |
|  ![Default](https://user-images.githubusercontent.com/50244599/195981131-c0a3938c-2ea9-48cc-a0f5-eafd7b6ea283.PNG)  |  ![Debug1](https://user-images.githubusercontent.com/50244599/195981134-bbd94cac-6cd2-4ea9-acbc-f20d3832fef6.PNG)  |

|  コンテナ選択  |  コンテナリスト  |  コンテナ情報  |
| ---- | ---- | ---- |
|  ![Select](https://user-images.githubusercontent.com/50244599/195981135-240d3201-66e1-4845-b437-b8e28474a946.PNG)  |  ![List](https://user-images.githubusercontent.com/50244599/195981140-6ae77d07-6a7a-495a-812b-6bf2c4b81ce1.PNG)  |  ![Info](https://user-images.githubusercontent.com/50244599/195981142-21ac932a-d82e-41ce-a30d-deebd5773fdb.PNG)  |

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

### HTTPCookieStorage
HTTPCookieStorageもキャッシングされており、非同期でファイル(Library/Cookies)への書き込みが行われています。
予期せぬタイミングで書き込みが行われてしまうと、コンテナ内でデータの不整合が起こってしまいます。
特に同一ドメイン宛のCookieを複数コンテナで扱っている場合には、セッションが引き継げなくなってしまう問題が起きます。
そのため、コンテナの切り替え時に、保存とキャッシュの解放を行なっています。

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

### 通知(Notification)
コンテナ切り替え時に通知を受け取ることができます。  
厳密に、切り替え前および切り替え後に行いたい処理を追加する場合は、後述するdelegateを使用してください。

- containerWillChangeNotification
コンテナ切り替え前
- containerDidChangeNotification
コンテナ切り替え後
### 委譲(Delegate)
Delegateを使用して、コンテナの切り替え時に、任意の処理を追加することができます。
以下の順で処置が行われます。

``` swift
// `activate`メソッドが呼び出される

// ↓↓↓↓↓↓↓↓↓↓


func appContainer(_ appContainer: AppContainer, willChangeTo toContainer: Container, from fromContainer: Container?) // Delegate(コンテナ切り替え前)

// ↓↓↓↓↓↓↓↓↓↓

// コンテナの切り替え処理(ライブラリ)

// ↓↓↓↓↓↓↓↓↓↓

func appContainer(_ appContainer: AppContainer, didChangeTo toContainer: Container, from fromContainer: Container?) // Delegate(コンテナ切り替え後)
```

このライブラリでは複数のdelegateを設定できるようになっています。 
以下のように追加します。
```swift
AppContainer.standard.delegates.add(self) // selfがAppContainerDelegateに準拠している場合
```
弱参照で保持されており、オブジェクトが解放された場合は自動で解除されます。  
もし、delegateの設定を解除したい場合は以下のように書きます。
```swift
AppContainer.standard.delegates.remove(self) // selfがAppContainerDelegateに準拠している場合
```

### AppContainerUI
AppContainerを扱うためのUIを提供しています。  
SwiftUIおよびUIKitに対応しています。
#### SwiftUI
```swift
import AppContainerUI

// コンテナのリストを表示
ContainerListView(appContainer: .standard, title: String = "Containers")

// コンテナ情報を表示
ContainerInfoView(appContainer: .standard, container: container)
```
#### UIKit
```swift
import AppContainerUI

// コンテナのリストを表示
ContainerListViewController(appContainer: .standard, title: String = "Containers")

// コンテナ情報を表示
ContainerInfoViewController(appContainer: .standard, container: container)
```