//
//  ContainerInfoView.swift
//  
//
//  Created by p-x9 on 2022/10/15.
//  
//

import SwiftUI
import AppContainer
import EditValueView

@available(iOS 14, *)
public struct ContainerInfoView: View {

    let appContainer: AppContainer?
    var isEditable: Bool {
        appContainer != nil
    }

    @State private var container: Container

    // swiftlint:disable:next type_contents_order
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
        .navigationTitle(container.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
    }

    var informationSection: some View {
        Section(header: Text("Informations")) {
            WritableKeyValueRowView(key: "Name", value: container.name, isEditable: isEditable) {
                EditValueView(container, key: "name", keyPath: \.name)
                    .onUpdate {_, value in
                        save(keyPath: \.name, value: value)
                    }
            }

            KeyValueRowView(key: "UUID", value: container.uuid)
            KeyValueRowView(key: "isDefault", value: container.isDefault)

            WritableKeyValueRowView(key: "Description", value: container.description, isEditable: isEditable) {
                EditValueView(container, key: "description", keyPath: \.description)
                    .onUpdate {_, value in
                        save(keyPath: \.description, value: value)
                    }
            }

            KeyValueRowView(key: "Created At", value: container.createdAt)

            WritableKeyValueRowView(key: "Last Activated Date", value: container.lastActivatedDate, isEditable: isEditable) {
                EditValueView(container, key: "lastActivatedDate", keyPath: \.lastActivatedDate)
                    .onUpdate { _, value in
                        save(keyPath: \.lastActivatedDate, value: value)
                    }
            }

            WritableKeyValueRowView(key: "Activated Count", value: container.activatedCount, isEditable: isEditable) {
                EditValueView(container, key: "activatedCount", keyPath: \.activatedCount)
                    .onUpdate {_, value in
                        save(keyPath: \.activatedCount, value: value)
                    }
            }
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
        let container: Container = .init(name: "Default",
                                         uuid: UUID().uuidString,
                                         description: "This container is default.\nこんにちは")
        NavigationView {
            ContainerInfoView(appContainer: nil, container: container)
        }
    }
}
#endif
