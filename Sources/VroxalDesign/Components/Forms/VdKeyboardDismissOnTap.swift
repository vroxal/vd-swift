import SwiftUI
import UIKit

@MainActor
internal enum VdKeyboardDismissOnTapInstaller {

    private static let recognizerName = "com.vroxaldesign.keyboardDismissTap"

    // Holds a weak window reference so entries for destroyed windows are
    // pruned automatically on the next installIfNeeded() call — no scene
    // lifecycle observers required.
    private final class Entry {
        weak var window: UIWindow?
        let handler: TapHandler
        init(window: UIWindow, handler: TapHandler) {
            self.window = window
            self.handler = handler
        }
    }

    private static var entries: [ObjectIdentifier: Entry] = [:]

    static func installIfNeeded() {
        // Prune stale entries for windows that have been deallocated.
        entries = entries.filter { $0.value.window != nil }

        let windowScenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }

        for scene in windowScenes {
            for window in scene.windows {
                guard window.gestureRecognizers?.contains(where: { $0.name == recognizerName }) != true else {
                    continue
                }

                let handler = TapHandler()
                entries[ObjectIdentifier(window)] = Entry(window: window, handler: handler)

                let recognizer = UITapGestureRecognizer(target: handler, action: #selector(TapHandler.handleTap(_:)))
                recognizer.name = recognizerName
                recognizer.cancelsTouchesInView = false
                recognizer.delaysTouchesBegan = false
                recognizer.delaysTouchesEnded = false
                window.addGestureRecognizer(recognizer)
            }
        }
    }

    private final class TapHandler: NSObject {
        @MainActor @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
            recognizer.view?.endEditing(true)
        }
    }
}

internal struct VdInstallKeyboardDismissOnTapModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                VdKeyboardDismissOnTapInstaller.installIfNeeded()
            }
    }
}

internal extension View {
    func vdInstallKeyboardDismissOnTap() -> some View {
        modifier(VdInstallKeyboardDismissOnTapModifier())
    }
}
