//
//  ContainerInfoView.swift
//  
//
//  Created by p-x9 on 2022/10/15.
//  
//

import SwiftUI
import AppContainer

extension Container: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}

@available(iOS 14, *)
fileprivate enum Presentation: View, Hashable, Identifiable {
    struct EditItem<Value>: Hashable where Value: Hashable {
        static func == (lhs: Presentation.EditItem<Value>, rhs: Presentation.EditItem<Value>) -> Bool {
            lhs.container == rhs.container &&
            lhs.keyName == rhs.keyName &&
            lhs.keyPath == rhs.keyPath
        }
        
        let container: Container
        let keyName: String
        let keyPath: WritableKeyPath<Container, Value>
        var onUpdate: ((Value) -> Void)?
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(container)
            hasher.combine(keyName)
            hasher.combine(keyPath)
        }
    }
    
    case text(EditItem<String>)
    case date(EditItem<Date>)
    case optionalText(EditItem<String?>)
    case optionalDate(EditItem<Date?>)
    
    var id: Self { self }
    
    @ViewBuilder
    var body: some View {
        switch self {
        case let .text(e):
            EditValueView(e.container, key: e.keyName, keyPath: e.keyPath)
                .onUpdate { _, value in
                    e.onUpdate?(value)
                }
        case let .date(e):
            EditValueView(e.container, key: e.keyName, keyPath: e.keyPath)
                .onUpdate { _, value in
                    e.onUpdate?(value)
                }
        case let .optionalText(e):
            EditValueView(e.container, key: e.keyName, keyPath: e.keyPath)
                .onUpdate { _, value in
                    e.onUpdate?(value)
                }
        case let .optionalDate(e):
            EditValueView(e.container, key: e.keyName, keyPath: e.keyPath)
                .onUpdate { _, value in
                    e.onUpdate?(value)
                }
        }
    }
}

@available(iOS 14, *)
public struct ContainerInfoView: View {
    
    let appContainer: AppContainer?
    var isEditable: Bool {
        appContainer != nil
    }
    
    @State private var container: Container
    
    @State private var presentation: Presentation?
    
    public init(appContainer: AppContainer?, container: Container) {
        self.appContainer = appContainer
        self._container = .init(initialValue: container)
    }
    
    public var body: some View {
        List {
            informationSection
            if let activeContainer = appContainer?.activeContainer {
                Section {
                    KeyValueRowView(key: "isActive",
                                    value: activeContainer.uuid == container.uuid)
                }
            }
        }
        .when(isEditable) {
            $0.sheet(item: $presentation) { $0 }
        }
        .navigationTitle(container.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var informationSection: some View {
        Section(header: Text("Informations")) {
            KeyValueRowView(key: "Name", value: container.name) {
                let editItem = Presentation.EditItem(container: container, keyName: "name", keyPath: \.name) {
                    save(keyPath: \.name, value: $0)
                }
                self.presentation = .optionalText(editItem)
            }
            KeyValueRowView(key: "UUID", value: container.uuid)
            KeyValueRowView(key: "isDefault", value: container.isDefault)
            
            KeyValueRowView(key: "Description", value: container.description) {
                let editItem = Presentation.EditItem(container: container, keyName: "description", keyPath: \.description) {
                    save(keyPath: \.description, value: $0)
                }
                self.presentation = .optionalText(editItem)
            }
            
            KeyValueRowView(key: "Created At", value: container.createdAt)
            
            KeyValueRowView(key: "Last Activated Date", value: container.lastActivatedDate) {
                let editItem = Presentation.EditItem(container: container, keyName: "lastActivatedDate", keyPath: \.lastActivatedDate) {
                    save(keyPath: \.lastActivatedDate, value: $0)
                }
                self.presentation = .optionalDate(editItem)
            }
            
            KeyValueRowView(key: "Activated Count", value: container.activatedCount)
        }
    }
    
    func save<Value>(keyPath: WritableKeyPath<Container, Value>, value: Value) {
        try? appContainer?.updateInfo(of: container,
                                 keyValue: .init(keyPath, value))
        onUpdate()
    }
    
    func onUpdate() {
        guard let appContainer = appContainer,
              let container = appContainer.containers.first(where: { container in
                  self.container.uuid == container.uuid
              }) else {
            return
        }
        self.container = container
    }
}

#if DEBUG
@available(iOS 14, *)
struct ContainerInfoView_Preview: PreviewProvider {
    static var previews: some View {
        let container: Container =  .init(name: "Default",
                                          uuid: UUID().uuidString,
                                          description: "This container is default.\nこんにちは")
        NavigationView {
            ContainerInfoView(appContainer: nil, container: container)
        }
    }
}
#endif
