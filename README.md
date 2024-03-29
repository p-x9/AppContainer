# AppContainer

This library allows you to create and manage multiple environments with a single application, just as if you were swapping containers.

This is useful when you want to test multiple accounts in a staging application.

<!-- # Badges -->

[![Github issues](https://img.shields.io/github/issues/p-x9/AppContainer)](https://github.com/p-x9/AppContainer/issues)
[![Github forks](https://img.shields.io/github/forks/p-x9/AppContainer)](https://github.com/p-x9/AppContainer/network/members)
[![Github stars](https://img.shields.io/github/stars/p-x9/AppContainer)](https://github.com/p-x9/AppContainer/stargazers)
[![Github top language](https://img.shields.io/github/languages/top/p-x9/AppContainer)](https://github.com/p-x9/AppContainer/)

> Language Switch: [日本語](https://github.com/p-x9/AppContainer/blob/main/README.ja.md).

## Concept
Normally there is one environment (Directory, UserDefaults, Cookies, Cache, ...) for one app.
To have multiple environments for debugging or to handle multiple accounts, multiple identical apps must be installed. (with different bundle IDs).
In debugging, there may be cases where accounts are repeatedly checked by logging in and logging out.
</br>
Therefore, we thought it would be possible to create multiple environments within the same app and switch between them easily.
This is why we created this library called `AppContainer`.

## Demo
|  Default  |  Debug1  |
| ---- | ---- |
|  ![Default](https://user-images.githubusercontent.com/50244599/195981131-c0a3938c-2ea9-48cc-a0f5-eafd7b6ea283.PNG)  |  ![Debug1](https://user-images.githubusercontent.com/50244599/195981134-bbd94cac-6cd2-4ea9-acbc-f20d3832fef6.PNG)  |

|  Selet Container  |  Container List  |  Container Info  |
| ---- | ---- | ---- |
|  ![Select](https://user-images.githubusercontent.com/50244599/195981135-240d3201-66e1-4845-b437-b8e28474a946.PNG)  |  ![List](https://user-images.githubusercontent.com/50244599/195981140-6ae77d07-6a7a-495a-812b-6bf2c4b81ce1.PNG)  |  ![Info](https://user-images.githubusercontent.com/50244599/195981142-21ac932a-d82e-41ce-a30d-deebd5773fdb.PNG)  |

## Document
### AppGroup
```swift
extension AppContainer {
    static let group = .init(groupIdentifier: "YOUR APP GROUP IDENTIFIER")
}
```
### Methods
#### Create New Container
 ```swift
 let container = try AppContainer.standard.createNewContainer(name: "Debug1")
 ```

#### Get Container List
The original container is named `DEFAULT` and has a UUID of `00000000-0000-0000-0000-0000-0000-00000000000000000000`.
You can check it with the property `isDefault`.
```swift
let containers: [Container] = AppContainer.standard.containers
```

#### Get Active Container
```swift
let activeContainer: Container? = AppContainer.standard.activeContainer
```

#### Activate Contrainer
It is recommended to restart the application after calling this method.
```swift
try AppContainer.standard.activate(container: container)
```
```swift
try AppContainer.standard.activateContainer(uuid: uuid)
```
#### Delete Container
If the container you are deleting is in use, activate the Default container before deleting it.
```swift
try AppContainer.standard.delete(container: container)
```
```swift
try AppContainer.standard.deleteContainer(uuid: uuid)
```

#### Clean Container
```swift
try AppContainer.standard.clean(container: container)
```
```swift
try AppContainer.standard.cleanContainer(uuid: uuid)
```

#### Reset
Revert to the state before this library was used.
Specifically, the DEFAULT container will be enabled and all other AppContainer-related files will be removed.
```swift
try AppContainer.standard.reset()
```

### Notification
You can receive notifications when switching containers.
If you want to add additional processing to be done strictly before and after the switch, use delegate as described below.

- containerWillChangeNotification
Before container switching
- containerDidChangeNotification
After container change

### Delegate
Delegate can be used to add optional processing when switching containers.
The actions are performed in the following order.

``` swift
// the `activate` method is called

// ↓↓↓↓↓↓↓↓↓↓


func appContainer(_ appContainer: AppContainer, willChangeTo toContainer: Container, from fromContainer: Container?) // Delegate(before container switch)

// ↓↓↓↓↓↓↓↓↓↓

// Container switching process (library)

// ↓↓↓↓↓↓↓↓↓↓

func appContainer(_ appContainer: AppContainer, didChangeTo toContainer: Container, from fromContainer: Container?) // Delegate (after container switch)
```

This library allows multiple delegates to be set.
Add the following.

```swift
AppContainer.standard.delegates.add(self) // if self is AppContainerDelegate compliant
```
It is held in a weak reference and will be automatically released when the object is freed.
If you want to unset the delegate, write the following.
```swift
AppContainer.standard.delegates.remove(self) // if self conforms to AppContainerDelegate
```

### Set files not to be moved when switching containers
When switching containers, almost all files except for some system files are saved and restored to the container directory.
You can set files to be excluded from these moves.

For example, the following is an example of a case where you want to use UserDefault commonly in all containers.
This file will not be saved or restored when switching containers.
```swift
appcontainer.customExcludeFiles = [
    "Library/Preferences/<Bundle Identifier>.plist"
]
```

All file paths that end with the contents of customExcludeFiles will be excluded from the move.
For example, the following configuration will exclude the file named `XXX.yy` under all directories.

```swift
appcontainer.customExcludeFiles = [
    "XXX.yy"
]
```

### AppContainerUI
Provides UI for using AppContainer.
SwiftUI and UIKit are supported.
#### SwiftUI
```swift
import AppContainerUI

// show Container List
ContainerListView(appContainer: .standard, title: String = "Containers")

// container info view
ContainerInfoView(appContainer: .standard, container: container)
```
#### UIKit
```swift
import AppContainerUI

// show Container List
ContainerListViewController(appContainer: .standard, title: String = "Containers")

// container info view
ContainerInfoViewController(appContainer: .standard, container: container)
```

## Licenses

[MIT License](./LICENSE)
