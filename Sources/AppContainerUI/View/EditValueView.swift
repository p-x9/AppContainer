//
//  EditValueView.swift
//  
//
//  Created by p-x9 on 2022/10/16.
//  
//

import SwiftUI

@available(iOS 14, *)
struct EditValueView<Root, Value>: View {
    let target: Root
    let key: String
    let keyPath: PartialKeyPath<Root> //WritableKeyPath<Root, Value>
    private var _onUpdate: ((Root, Value) -> Void)?
    private var isWrappedOptional = false
    
    @State private var value: Value
    @Environment(\.presentationMode) private var presentationMode
    
    @_disfavoredOverload
    init(_ target: Root, key: String, keyPath: WritableKeyPath<Root, Value>) {
        self.target = target
        self.key = key
        self.keyPath = keyPath
        
        self._value = .init(initialValue: target[keyPath: keyPath])
    }
    
    init(_ target: Root, key: String, keyPath: WritableKeyPath<Root, Optional<Value>>) where Value: DefaultRepresentable {
        self.target = target
        self.key = key
        self.keyPath = keyPath
        self.isWrappedOptional = true
        
        self._value = .init(initialValue: target[keyPath: keyPath] ?? Value.defaultValue)
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
    
    func onUpdate(_ onUpdate: ((Root, Value) -> Void)?) -> Self {
        var new = self
        new._onUpdate = onUpdate
        return new
    }
    
    private func save() {
        _onUpdate?(target, value)
    }
}

#if DEBUG
import AppContainer

@available(iOS 14, *)
struct EditValueView_Preview: PreviewProvider {
    static var previews: some View {
        let target: Container =  .init(name: "Default",
                                          uuid: UUID().uuidString,
                                          description: "This container is default.\nこんにちは")
        Group {
            EditValueView(target,
                          key: "name", keyPath: \Container.name)
            EditValueView(target,
                          key: "lastActivatedDate", keyPath: \Container.lastActivatedDate)
        }
    }
}
#endif
