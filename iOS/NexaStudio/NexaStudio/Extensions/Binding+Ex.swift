
import SwiftUI
import Foundation

extension Binding where Value == Bool {

    init<T: Sendable>(_ value: Binding<T?>) {
        self.init {
            value.wrappedValue != nil
        } set: { newValue in
            if newValue == false {
                value.wrappedValue = nil
            }
        }
    }
}
