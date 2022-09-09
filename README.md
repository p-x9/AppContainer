# AppContainer

Library that makes it easy to create multiple environments within a single app.
You can switch environments without deleting the application.

This is useful when you want to test multiple accounts in a staging application.


## Document
### Create New Container
 ```swift
 let container = try AppContainer.shared.createNewContainer(name: "Debug1")
 ```

### Get Container List
```swift
let containers: [Container] = AppContainer.shared.containers
```

### Get Active Container
```swift
let activeContainer: Container? = AppContainer.shared.activeContainer
```

### Activate Contrainer
restart app required.
```swift
try AppContainer.shared.activate(container: container)
```
```swift
try AppContainer.shared.activateContainer(uuid: uuid)
```
### Delete Container
```swift
try AppContainer.shared.delete(container: container)
```
```swift
try AppContainer.shared.deleteContainer(uuid: uuid)
```

### Clean Container
```swift
try AppContainer.shared.clean(container: container)
```
```swift
try AppContainer.shared.cleanContainer(uuid: uuid)
```

### Reset
```swift
try AppContainer.shared.reset()
```