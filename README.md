# AppContainer

This library allows you to create and manage multiple environments with a single application, just as if you were swapping containers.

This is useful when you want to test multiple accounts in a staging application.

<!-- # Badges -->

[![Github issues](https://img.shields.io/github/issues/p-x9/AppContainer)](https://github.com/p-x9/AppContainer/issues)
[![Github forks](https://img.shields.io/github/forks/p-x9/AppContainer)](https://github.com/p-x9/AppContainer/network/members)
[![Github stars](https://img.shields.io/github/stars/p-x9/AppContainer)](https://github.com/p-x9/AppContainer/stargazers)
[![Github top language](https://img.shields.io/github/languages/top/p-x9/AppContainer)](https://github.com/p-x9/AppContainer/)

> Language Switch: [日本語](https://github.com/p-x9/AppContainer/blob/main/README.ja.md).

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