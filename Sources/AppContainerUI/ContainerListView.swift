//
//  ContainerListView.swift
//  
//
//  Created by p-x9 on 2022/10/15.
//  
//

import SwiftUI
import AppContainer

extension Container: Identifiable {
    public var id: UUID {
        UUID(uuidString: uuid)!
    }
}

@available(iOS 14, *)
public struct ContainerListView: View {
    let appContainer: AppContainer
    let title: String
    
    @State var containers: [Container]
    
    public init(appContainer: AppContainer, title: String) {
        self.appContainer = appContainer
        self.title = title
        self._containers = .init(initialValue: appContainer.containers)
    }
    
    public var body: some View {
        NavigationView {
            List {
                ForEach(containers) { container in
                    NavigationLink {
                        ContainerInfoView(appContainer: appContainer,
                                          container: container)
                    } label: {
                        ContainerRowView(container: container)
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
}

#if DEBUG
@available(iOS 16, *)
struct ContainerListView_Preview: PreviewProvider {
    static var previews: some View {
        let containers: [Container] = [
            .init(name: "Default",
                  uuid: UUID().uuidString,
                  description: "This container is default.\nこんにちは"),
            .init(name: "Debug1", uuid: UUID().uuidString,
                 description: "This container is Debug1. \nHello\nHello"),
            .init(name: "Debug2", uuid: UUID().uuidString),
            .init(name: "Debug3", uuid: UUID().uuidString),
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
