import SwiftUI
import UIKit

@MainActor
internal enum VdKeyboardDismissOnTapInstaller {

    private static let recognizerName = "com.vroxaldesign.keyboardDismissTap"
    private static var handlers: [ObjectIdentifier: TapHandler] = [:]

    static func installIfNeeded() {
        let windowScenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }

        for scene in windowScenes {
            for window in scene.windows {
                guard window.gestureRecognizers?.contains(where: { $0.name == recognizerName }) != true else {
                    continue
                }

                let handler = TapHandler()
                handlers[ObjectIdentifier(window)] = handler

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
        @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
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
