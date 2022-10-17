//
//  EditValueView.swift
//  
//
//  Created by p-x9 on 2022/10/16.
//  
//

import SwiftUI
import AppContainer

@available(iOS 14, *)
struct EditValueView<Value>: View {
    var appContainer: AppContainer?
    let container: Container
    let key: String
    let keyPath: PartialKeyPath<Container> //WritableKeyPath<Container, Value>
    private var isWrappedOptional = false
    
    @State private var value: Value
    @Environment(\.presentationMode) private var presentationMode
    
    init(container: Container, key: String, keyPath: WritableKeyPath<Container, Value>) {
        self.container = container
        self.key = key
        self.keyPath = keyPath
        
        self._value = .init(initialValue: container[keyPath: keyPath])
    }
    
    init(container: Container, key: String, keyPath: WritableKeyPath<Container, Optional<Value>>) where Value: DefaultRepresentable {
        self.container = container
        self.key = key
        self.keyPath = keyPath
        self.isWrappedOptional = true
        
        self._value = .init(initialValue: container[keyPath: keyPath] ?? Value.default)
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    let string: String = "Key: \(key)"
                    Text(string)
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.gray)
                    Spacer()
                }
                HStack {
                    let string: String = "Type: \(Value.self)"
                    Text(string)
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.gray)
                        .padding([.bottom])
                    Spacer()
                }
                editor
                    .padding(.vertical)
                Spacer()
            }
            .padding()
            .navigationTitle(key)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .destructiveAction) {
                    Button("Save") {
                        save()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var editor: some View {
        switch $value {
        case let v as Binding<String>:
            TextEditor(text: v)
                .border(.black, width: 0.5)
        case let v as Binding<Date>:
            VStack {
                Text(v.wrappedValue.description)
                    .frame(maxWidth: .infinity)
                    .border(.black, width: 0.5)
                DatePicker("Date", selection: v)
                    .datePickerStyle(.graphical)
            }
        default: // FIXME: Support more value types
            Text("this type is currently not supported.")
        }
    }
    
    func set(appContainer: AppContainer?) -> Self {
        var new = self
        new.appContainer = appContainer
        return new
    }
    
    func save() {
        if isWrappedOptional {
            guard let keyPath = keyPath as? WritableKeyPath<Container, Optional<Value>> else {
                return
            }
            try? appContainer?.updateInfo(of: container, keyValue: .init(keyPath, value))
        } else {
            guard let keyPath = keyPath as? WritableKeyPath<Container, Value> else {
                return
            }
            try? appContainer?.updateInfo(of: container, keyValue: .init(keyPath, value))
        }
       
    }
}

#if DEBUG
@available(iOS 14, *)
struct EditValueView_Preview: PreviewProvider {
    static var previews: some View {
        let container: Container =  .init(name: "Default",
                                          uuid: UUID().uuidString,
                                          description: "This container is default.\nこんにちは")
        Group {
            EditValueView(container: container,
                          key: "name", keyPath: \.name)
            EditValueView(container: container,
                          key: "lastActivatedDate", keyPath: \.lastActivatedDate)
        }
    }
}
#endif
