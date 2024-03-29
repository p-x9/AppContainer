//
//  ContainerListView.swift
//  
//
//  Created by p-x9 on 2022/10/15.
//  
//
//  swiftlint:disable:next type_contents_order

import SwiftUI
import AppContainer

/// View to display list of existing containers
@available(iOS 14, *)
public struct ContainerListView: View {
    let appContainer: AppContainer
    let title: String

    @State var containers: [Container]
    
    /// Default initializer
    /// - Parameters:
    ///   - appContainer: instance of ``AppContainer``.
    ///   - title: navigation title
    public init(appContainer: AppContainer, title: String = "Containers") {
        self.appContainer = appContainer
        self.title = title
        self._containers = .init(initialValue: appContainer.containers)
    }

    public var body: some View {
        List {
            ForEach(containers) { container in
                NavigationLink {
                    ContainerInfoView(appContainer: appContainer,
                                      container: container)
                } label: {
                    let activeContainer = appContainer.activeContainer
                    let isActive = activeContainer?.uuid == container.uuid
                    ContainerRowView(container: container, isActive: isActive)
                }
            }
        }
        .onAppear {
            containers = appContainer.containers
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension Container: Identifiable {
    public var id: UUID {
        // swiftlint:disable:next force_unwrapping
        UUID(uuidString: uuid)!
    }
}

#if DEBUG
@available(iOS 14, *)
struct ContainerListView_Preview: PreviewProvider {
    static var previews: some View {
        let containers: [Container] = [
            .init(name: "Default",
                  uuid: UUID().uuidString,
                  description: "This container is default.\nこんにちは"),
            .init(name: "Debug1", uuid: UUID().uuidString,
                  description: "This container is Debug1. \nHello\nHello"),
            .init(name: "Debug2", uuid: UUID().uuidString),
            .init(name: "Debug3", uuid: UUID().uuidString)
        ]

        NavigationView {
            List {
                ForEach(containers) { container in
                    NavigationLink {
                        ContainerInfoView(appContainer: nil, container: container)
                    } label: {
                        ContainerRowView(container: container)
                    }
                }
            }
            .navigationTitle("Containers")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
#endif
