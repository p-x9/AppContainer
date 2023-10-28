# ``AppContainer``

🧳 Create and manage multiple environments within a single app.

@Metadata {
    @DocumentationExtension(mergeBehavior: append)
    @Available(iOS, introduced: "14.0")
}

## Overview

It is a library that allows you to create and manage multiple environments with a single application, just as if you were replacing containers.
You can switch environments without deleting the application.

### Concept

Normally there is one environment (Directory, UserDefaults, Cookies, Cache, ...) for one app.
This means that to prepare multiple environments, multiple installations of the same application are required.
For apps with login capabilities, you may need to sign in and sign out repeatedly each time to use multiple accounts.

So we wondered if it would be possible to create multiple environments within the same application and switch between them easily.
We created this library called AppContainer.

![Concept Image](concept.png)

### Usage

#### AppGroup

    ```swift
    extension AppContainer {
        static let group = .init(groupIdentifier: "YOUR APP GROUP IDENTIFIER")
    }
    ```

#### Methods

- Create New Container
    ```swift
    let container = try AppContainer.standard.createNewContainer(name: "Debug1")
    ```

- Get Container List
    ```swift
    let containers: [Container] = AppContainer.standard.containers
    ```

- Get Active Container
    ```swift
    let activeContainer: Container? = AppContainer.standard.activeContainer
    ```

- Activate Contrainer
    It is recommended to restart the application after calling this method.
    ```swift
    try AppContainer.standard.activate(container: container)
    ```
    ```swift
    try AppContainer.standard.activateContainer(uuid: uuid)
    ```

- Delete Container
    If the container you are deleting is in use, activate the Default container before deleting it.
    ```swift
    try AppContainer.standard.delete(container: container)
    ```
    ```swift
    try AppContainer.standard.deleteContainer(uuid: uuid)
    ```

- Clean Container
    ```swift
    try AppContainer.standard.clean(container: container)
    ```
    ```swift
    try AppContainer.standard.cleanContainer(uuid: uuid)
    ```

- Reset Container
    Revert to the state before this library was used.
    Specifically, the DEFAULT container will be enabled and all other AppContainer-related files will be removed.
    ```swift
    try AppContainer.standard.reset()
    ```

#### Notification

You can receive notifications when switching containers.
If you want to add additional processing to be done strictly before and after the switch, use delegate as described below.

- containerWillChangeNotification:
    Before container switching
- containerDidChangeNotification:
    After container change

#### Delegate

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

#### Set files not to be moved when switching containers

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

## Topics

### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->

- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->
