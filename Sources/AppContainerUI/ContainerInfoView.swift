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
    struct EditItem: Hashable {
        static func == (lhs: Presentation.EditItem, rhs: Presentation.EditItem) -> Bool {
            lhs.appContainer === rhs.appContainer &&
            lhs.container == rhs.container
        }
        
        let appContainer: AppContainer?
        let container: Container
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(container)
        }
    }
    
    case text(EditItem, String, WritableKeyPath<Container, String>)
    case date(EditItem, String, WritableKeyPath<Container, Date>)
    case optionalText(EditItem, String, WritableKeyPath<Container, String?>)
    case optionalDate(EditItem, String, WritableKeyPath<Container, Date?>)
    
    var id: Self { self }
    
    @ViewBuilder
    var body: some View {
        switch self {
        case let .text(c, s, v):
            EditValueView(container: c.container, key: s, keyPath: v)
                .set(appContainer: c.appContainer)
        case let .date(c, s, v):
            EditValueView(container: c.container, key: s, keyPath: v)
                .set(appContainer: c.appContainer)
        case let .optionalText(c, s, v):
            EditValueView(container: c.container, key: s, keyPath: v)
                .set(appContainer: c.appContainer)
        case let .optionalDate(c, s, v):
            EditValueView(container: c.container, key: s, keyPath: v)
                .set(appContainer: c.appContainer)
        }
    }
}

@available(iOS 14, *)
public struct ContainerInfoView: View {
    
    let appContainer: AppContainer?
    @State private var container: Container
    
    @State private var presentation: Presentation?
    
    public init(appContainer: AppContainer?, container: Container) {
        self.appContainer = appContainer
        self._container = .init(initialValue: container)
    }
    
    public var body: some View {
        List {
            informationSection
        }
        .sheet(item: $presentation, onDismiss: {
            onUpdate()
        }, content: {
            $0
        })
        .navigationTitle(container.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var informationSection: some View {
        Section(header: Text("Informations")) {
            KeyValueRowView(key: "Name", value: container.name) {
                self.presentation = .optionalText(
                    .init(appContainer: appContainer, container: container),
                    "name", \.name)
            }
            KeyValueRowView(key: "UUID", value: container.uuid)
            KeyValueRowView(key: "isDefault", value: container.isDefault)
            
            KeyValueRowView(key: "Description", value: container.description) {
                self.presentation = .optionalText(
                    .init(appContainer: appContainer, container: container),
                    "description", \.description)
            }
            
            KeyValueRowView(key: "Created At", value: container.createdAt)
            
            KeyValueRowView(key: "Last Activated Date", value: container.lastActivatedDate) {
                self.presentation = .optionalDate(
                    .init(appContainer: appContainer, container: container),
                    "lastActivatedDate", \.lastActivatedDate)
            }
            
            KeyValueRowView(key: "Activated Count", value: container.activatedCount)
        }
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
