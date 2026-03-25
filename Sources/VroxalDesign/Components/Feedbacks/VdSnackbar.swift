// Components/Feedback/VdSnackbar.swift — Vroxal Design

import SwiftUI
import UIKit

// ─────────────────────────────────────────────────────────────
// MARK: — VdSnackbar
// ─────────────────────────────────────────────────────────────

public struct VdSnackbar: View {

    private let message: String
    private let action: String?
    private let onAction: (() -> Void)?
    private let leadingIcon: String?  // SF Symbol name
    private let closable: Bool
    private let onClose: (() -> Void)?

    public init(
        message: String,
        action: String? = nil,
        onAction: (() -> Void)? = nil,
        leadingIcon: String? = nil,
        closable: Bool = false,
        onClose: (() -> Void)? = nil
    ) {
        self.message = message
        self.action = action
        self.onAction = onAction
        self.leadingIcon = leadingIcon
        self.closable = closable
        self.onClose = onClose
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Body
    // ─────────────────────────────────────────────────────────

    public var body: some View {
        HStack(alignment: .top, spacing: 0) {

            if let icon = leadingIcon {
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .padding(2)
                        .foregroundStyle(Color.vdContentNeutralOnBase)
                        .frame(width: VdIconSize.md, height: VdIconSize.md)
                        .padding(VdSpacing.sm)
            }

            // ── Message ───────────────────────────────────────
            Text(message)
                .vdFont(VdFont.bodyMedium)
                .foregroundStyle(Color.vdContentNeutralOnBase)
                .frame(maxWidth: .infinity, minHeight: 24, alignment: .leading)
                .padding(VdSpacing.sm)


            if let label = action {
                Button(action: { onAction?() }) {
                    Text(label)
                        .vdFont(VdFont.labelMedium)
                        .foregroundStyle(Color.vdContentPrimaryBaseInverted)
                        .frame(minHeight: 24)
                }
                .buttonStyle(.plain)
                .padding(VdSpacing.sm)

            }

            if closable {
                Button(action: { onClose?() }) {
                    Image(systemName: "xmark")
                        .resizable()
                        .scaledToFit()
                        .padding(VdSpacing.xs)
                        .foregroundStyle(Color.vdContentNeutralOnBase).frame(
                            width: VdIconSize.md,
                            height: VdIconSize.md
                        )
                }
                .padding(VdSpacing.sm)
                .buttonStyle(.plain)
//                .background()

            }
        }
        .padding(VdSpacing.sm)
        .background(Color.vdBackgroundNeutralTertiary)
        .clipShape(RoundedRectangle(cornerRadius: VdRadius.md))
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — VdSnackbarModifier
// Presents the snackbar in an app-level overlay window pinned
// to the bottom of the active scene, independent of the
// triggering view's bounds. Auto-dismisses after `duration`
// seconds unless closable.
// ─────────────────────────────────────────────────────────────

@MainActor
public struct VdSnackbarModifier: ViewModifier {

    @Binding private var isPresented: Bool
    private let message: String
    private let action: String?
    private let onAction: (() -> Void)?
    private let leadingIcon: String?
    private let closable: Bool
    private let duration: TimeInterval  // 0 = no auto-dismiss
    @State private var dismissId: UInt = 0  // incremented on each show to invalidate stale timers
    @State private var presentationID = UUID()

    public init(
        isPresented: Binding<Bool>,
        message: String,
        action: String? = nil,
        onAction: (() -> Void)? = nil,
        leadingIcon: String? = nil,
        closable: Bool = false,
        duration: TimeInterval = 4.0
    ) {
        self._isPresented = isPresented
        self.message = message
        self.action = action
        self.onAction = onAction
        self.leadingIcon = leadingIcon
        self.closable = closable
        self.duration = duration
    }

    public func body(content: Content) -> some View {
        content
            .onAppear {
                syncPresentation()
            }
            .onChangeCompat(of: isPresented) { _ in
                syncPresentation()
            }
            .onChangeCompat(of: presentationSignature) { _ in
                guard isPresented else { return }
                syncPresentation()
            }
            .onDisappear {
                dismissId &+= 1
                VdSnackbarPresenter.dismiss(id: presentationID)
            }
            .animation(
                .spring(response: 0.35, dampingFraction: 0.8),
                value: isPresented
            )
    }

    private var presentationSignature: VdSnackbarPresentationSignature {
        VdSnackbarPresentationSignature(
            message: message,
            action: action,
            leadingIcon: leadingIcon,
            closable: closable,
            duration: duration
        )
    }

    @MainActor
    private func syncPresentation() {
        dismissId &+= 1

        guard isPresented else {
            VdSnackbarPresenter.dismiss(id: presentationID)
            return
        }

        VdSnackbarPresenter.present(
            id: presentationID,
            configuration: VdSnackbarPresentationConfiguration(
                message: message,
                action: action,
                onAction: {
                    onAction?()
                    dismiss()
                },
                leadingIcon: leadingIcon,
                closable: closable,
                onClose: dismiss
            )
        )

        guard duration > 0 else { return }

        let currentId = dismissId
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            guard currentId == dismissId else { return }
            Task { @MainActor in
                dismiss()
            }
        }
    }

    @MainActor
    private func dismiss() {
        withAnimation {
            isPresented = false
        }
        VdSnackbarPresenter.dismiss(id: presentationID)
    }
}

private struct VdSnackbarPresentationSignature: Equatable {
    let message: String
    let action: String?
    let leadingIcon: String?
    let closable: Bool
    let duration: TimeInterval
}

private struct VdSnackbarPresentationConfiguration {
    let message: String
    let action: String?
    let onAction: (() -> Void)?
    let leadingIcon: String?
    let closable: Bool
    let onClose: (() -> Void)?
}

@MainActor
private enum VdSnackbarPresenter {
    private static let transition = Animation.spring(
        response: 0.35,
        dampingFraction: 0.8
    )
    private static let teardownDelay: TimeInterval = 0.4
    private static var entries: [UUID: VdSnackbarPresentationEntry] = [:]

    static func present(
        id: UUID,
        configuration: VdSnackbarPresentationConfiguration
    ) {
        guard let scene = activeWindowScene() else { return }

        if let entry = entries[id] {
            entry.window.windowScene = scene
            entry.window.isHidden = false
            entry.model.configuration = configuration
            withAnimation(transition) {
                entry.model.isVisible = true
            }
            return
        }

        let model = VdSnackbarOverlayModel(configuration: configuration)
        let window = makeWindow(for: scene)
        let hostingController = UIHostingController(
            rootView: VdSnackbarOverlayView(model: model)
        )
        hostingController.view.backgroundColor = .clear

        window.windowScene = scene
        window.rootViewController = hostingController
        window.isHidden = false

        entries[id] = VdSnackbarPresentationEntry(window: window, model: model)

        DispatchQueue.main.async {
            guard let entry = entries[id] else { return }
            withAnimation(transition) {
                entry.model.isVisible = true
            }
        }
    }

    static func dismiss(id: UUID) {
        guard let entry = entries[id] else { return }

        withAnimation(transition) {
            entry.model.isVisible = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + teardownDelay) {
            Task { @MainActor in
                guard let currentEntry = entries[id], currentEntry.model.isVisible == false else { return }
                currentEntry.window.isHidden = true
                currentEntry.window.rootViewController = nil
                entries.removeValue(forKey: id)
            }
        }
    }

    private static func activeWindowScene() -> UIWindowScene? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })
        ?? UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
    }

    private static func makeWindow(for scene: UIWindowScene) -> UIWindow {
        let window = VdPassThroughWindow(windowScene: scene)
        window.backgroundColor = .clear
        window.windowLevel = .alert + 1
        return window
    }
}

private final class VdPassThroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        return hitView === rootViewController?.view ? nil : hitView
    }
}

@MainActor
private final class VdSnackbarOverlayModel: ObservableObject {
    @Published var configuration: VdSnackbarPresentationConfiguration
    @Published var isVisible = false

    init(configuration: VdSnackbarPresentationConfiguration) {
        self.configuration = configuration
    }
}

private struct VdSnackbarPresentationEntry {
    let window: UIWindow
    let model: VdSnackbarOverlayModel
}

private struct VdSnackbarOverlayView: View {
    @ObservedObject var model: VdSnackbarOverlayModel

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.clear

            if model.isVisible {
                VdSnackbar(
                    message: model.configuration.message,
                    action: model.configuration.action,
                    onAction: model.configuration.onAction,
                    leadingIcon: model.configuration.leadingIcon,
                    closable: model.configuration.closable,
                    onClose: model.configuration.onClose
                )
                .padding(.horizontal, VdSpacing.lg)
                .padding(.bottom, VdSpacing.xl)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .background(Color.clear)
        .ignoresSafeArea()
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — View extension
// ─────────────────────────────────────────────────────────────

extension View {

    /// Presents a snackbar at the app level, anchored to the bottom
    /// of the active scene rather than the triggering view's bounds.
    ///
    ///     .vdSnackbar(isPresented: $show, message: "Saved!",
    ///                 action: "Undo", onAction: { undoSave() })
    @MainActor
    public func vdSnackbar(
        isPresented: Binding<Bool>,
        message: String,
        action: String? = nil,
        onAction: (() -> Void)? = nil,
        leadingIcon: String? = nil,
        closable: Bool = false,
        duration: TimeInterval = 4.0
    ) -> some View {
        modifier(
            VdSnackbarModifier(
                isPresented: isPresented,
                message: message,
                action: action,
                onAction: onAction,
                leadingIcon: leadingIcon,
                closable: closable,
                duration: duration
            )
        )
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — Preview
// ─────────────────────────────────────────────────────────────

#Preview("VdSnackbar — All Variants") {
    ScrollView {
        VStack(alignment: .leading, spacing: VdSpacing.xl) {

            previewSection("Message only") {
                VdSnackbar(message: "Changes saved successfully")
            }

            previewSection("With leading icon") {
                VdSnackbar(
                    message: "Item moved to archive",
                    leadingIcon: "archivebox"
                )
            }

            previewSection("With action") {
                VdSnackbar(
                    message: "Message deleted",
                    action: "Undo",
                    onAction: {}
                )
            }

            previewSection("Closable") {
                VdSnackbar(
                    message: "Your session will expire in 5 minutes",
                    closable: true,
                    onClose: {}
                )
            }

            previewSection("Full — icon + action + close") {
                VdSnackbar(
                    message:
                        "Snackbar Content",
                    action: "Action",
                    onAction: {},
                    leadingIcon: "square.grid.2x2",
                    closable: true,
                    onClose: {}
                )
            }

            previewSection("Interactive") {
                SnackbarInteractiveDemo()
            }
        }
        .padding(VdSpacing.lg)
    }
    .background(Color.vdBackgroundDefaultBase)
}

private func previewSection<Content: View>(
    _ title: String,
    @ViewBuilder content: () -> Content
) -> some View {
    VStack(alignment: .leading, spacing: VdSpacing.sm) {
        Text(title)
            .vdFont(VdFont.labelSmall)
            .foregroundStyle(Color.vdContentDefaultTertiary)
        content()
    }
}

private struct SnackbarInteractiveDemo: View {
    @State private var showBasic = false
    @State private var showAction = false
    @State private var showWithIcon = false

    var body: some View {
        VStack(spacing: VdSpacing.sm) {
            VdButton(
                "Show basic snackbar",
                style: .outlined,
                action: {
                    showBasic = true
                }
            )
            .frame(maxWidth: .infinity)

            VdButton(
                "Show snackbar with action",
                action: {
                    showAction = true
                }
            )
            .frame(maxWidth: .infinity)

            VdButton(
                "Show snackbar with icon",
                style: .subtle,
                action: {
                    showWithIcon = true
                }
            )
            .frame(maxWidth: .infinity)
        }
        .padding(VdSpacing.md)
        .background(Color.vdBackgroundDefaultSecondary)
        .clipShape(RoundedRectangle(cornerRadius: VdRadius.lg))
        .vdSnackbar(
            isPresented: $showBasic,
            message: "Changes saved",
            closable: true
        )
        .vdSnackbar(
            isPresented: $showAction,
            message: "Message deleted",
            action: "Undo",
            onAction: { showAction = false },
            closable: true
        )
        .vdSnackbar(
           isPresented: $showWithIcon,
           message: "File uploaded successfully",
           leadingIcon: "checkmark.circle",
           closable: true
       )
       
    }
}
