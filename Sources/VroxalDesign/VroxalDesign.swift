// VroxalDesign.swift
// Public entry point — import VroxalDesign gives access to all Vd* types.
import SwiftUI

// ─────────────────────────────────────────────────────────────
// MARK: — onChange compatibility helper
// Bridges iOS 16's deprecated two-param onChange with iOS 17's new API.
// ─────────────────────────────────────────────────────────────

extension View {
    /// Availability-safe `onChange` that works on iOS 16 and 17+.
    @ViewBuilder
    func onChangeCompat<V: Equatable>(of value: V, perform action: @escaping (V) -> Void) -> some View {
        if #available(iOS 17, *) {
            self.onChange(of: value) { _, newValue in action(newValue) }
        } else {
            self.onChange(of: value, perform: action)
        }
    }
}
