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
    private let leadingIcon: String?
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
        HStack(alignment: .center, spacing: VdSpacing.xs) {

            if let icon = leadingIcon {
                VdIcon(icon, size: VdIconSize.md, color: .vdContentNeutralOnBase)
                    .padding(VdSpacing.sm)
            }

            // ── Message ───────────────────────────────────────
            Text(message)
                .vdFont(.bodyMedium)
                .foregroundStyle(Color.vdContentNeutralOnBase)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(minHeight: 24)
                .padding(VdSpacing.sm)

            if let label = action {
                Button(action: { onAction?() }) {
                    Text(label)
                        .vdFont(.labelMedium)
                        .foregroundStyle(Color.vdContentPrimaryBaseInverted)
                }
                .buttonStyle(.plain)
                .padding(0)
                .padding(VdSpacing.sm)
            }

            if closable {
                Button(action: { onClose?() }) {
                    VdIcon("vd:xmark", size: VdIconSize.xs, color: .vdContentNeutralOnBase)
                }
                .buttonStyle(.plain)
                .padding(0)
                .padding(VdSpacing.sm)
            }
        }
        .padding(VdSpacing.sm)
        .background(Color.vdBackgroundNeutralTertiary)
        .clipShape(RoundedRectangle(cornerRadius: VdRadius.md, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: VdRadius.md, style: .continuous))
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — VdSnackbarModifier
// ─────────────────────────────────────────────────────────────

@MainActor
public struct VdSnackbarModifier: ViewModifier {

    @Binding private var isPresented: Bool
    private let message: String
    private let action: String?
    private let onAction: (() -> Void)?
    private let leadingIcon: String?
    private let closable: Bool
    private let duration: TimeInterval
    @State private var dismissId: UInt = 0
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
                guard isPresented else { return }
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
            dismiss()
        }
    }

    @MainActor
    private func dismiss() {
        isPresented = false
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

// ─────────────────────────────────────────────────────────────
// MARK: — VdSnackbarPresenter
// ─────────────────────────────────────────────────────────────

@MainActor
private enum VdSnackbarPresenter {
    private static let teardownDelay: TimeInterval = 0.65
    private static var entries: [UUID: VdSnackbarPresentationEntry] = [:]

    static func present(id: UUID, configuration: VdSnackbarPresentationConfiguration) {
        guard let scene = activeWindowScene() else { return }
        let bottomInset = resolvedBottomInset(for: scene)

        // ── Reuse existing entry ───────────────────────────────
        if let entry = entries[id] {
            entry.window.windowScene = scene
            entry.window.isHidden = false
            entry.model.configuration = configuration
            entry.bottomConstraint.constant = -bottomInset
            (entry.window as? VdPassThroughWindow)?.isShowingSnackbar = true
            entry.model.isVisible = true
            return
        }

        // ── Create new entry ───────────────────────────────────
        let model = VdSnackbarOverlayModel(configuration: configuration)
        let window = VdPassThroughWindow(windowScene: scene)
        window.backgroundColor = .clear
        window.windowLevel = .alert + 1

        // VdSnackbarRootView fills the window but only claims touches that land
        // on an actual subview — it returns nil for background touches, so the
        // main window always stays fully interactive behind the snackbar.
        let rootVC = UIViewController()
        let rootView = VdSnackbarRootView()
        rootView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        rootVC.view = rootView

        // The hosting controller is sized by its SwiftUI content (snackbar pill
        // height) and pinned to the bottom via UIKit constraints. Since it never
        // covers the full screen, super.hitTest in VdPassThroughWindow naturally
        // returns nil for anything above the snackbar — no frame-tracking needed.
        let hostingController = UIHostingController(
            rootView: VdSnackbarOverlayView(model: model)
        )
        hostingController.view.backgroundColor = .clear

        rootVC.addChild(hostingController)
        rootView.addSubview(hostingController.view)
        hostingController.didMove(toParent: rootVC)

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        let bottomConstraint = hostingController.view.bottomAnchor.constraint(
            equalTo: rootView.bottomAnchor,
            constant: -bottomInset
        )
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: VdSpacing.lg),
            hostingController.view.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -VdSpacing.lg),
            bottomConstraint,
        ])

        window.windowScene = scene
        window.rootViewController = rootVC
        window.isHidden = false
        window.isShowingSnackbar = true

        entries[id] = VdSnackbarPresentationEntry(
            window: window,
            model: model,
            bottomConstraint: bottomConstraint
        )
    }

    static func dismiss(id: UUID) {
        guard let entry = entries[id] else { return }

        // Stop intercepting touches immediately so the screen is
        // responsive during the exit animation.
        (entry.window as? VdPassThroughWindow)?.isShowingSnackbar = false
        entry.model.isVisible = false

        DispatchQueue.main.asyncAfter(deadline: .now() + teardownDelay) {
            guard let currentEntry = entries[id],
                  !currentEntry.model.isVisible else { return }
            currentEntry.window.isHidden = true
            currentEntry.window.rootViewController = nil
            entries.removeValue(forKey: id)
        }
    }

    // ── Helpers ───────────────────────────────────────────────

    private static func activeWindowScene() -> UIWindowScene? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })
        ?? UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first
    }

    private static func resolvedBottomInset(for scene: UIWindowScene) -> CGFloat {
        guard let hostWindow = presentationHostWindow(for: scene) else {
            return VdSpacing.xl
        }
        let safeAreaBottom = hostWindow.safeAreaInsets.bottom
        let reservedBottom = max(safeAreaBottom, reservedBottomHeight(in: hostWindow))
        return reservedBottom + VdSpacing.md
    }

    private static func presentationHostWindow(for scene: UIWindowScene) -> UIWindow? {
        let visibleWindows = scene.windows.filter {
            !$0.isHidden && $0.windowLevel == .normal
        }
        return visibleWindows.first(where: \.isKeyWindow) ?? visibleWindows.first
    }

    private static func reservedBottomHeight(in window: UIWindow) -> CGFloat {
        var maxHeight: CGFloat = 0
        for view in window.allSubviews
        where (view is UITabBar || view is UIToolbar)
            && !view.isHidden
            && view.alpha > 0.01
            && view.bounds.height > 0.5
        {
            let frameInWindow = view.convert(view.bounds, to: window)
            guard frameInWindow.maxY > window.bounds.maxY - 1 else { continue }
            let overlap = max(0, window.bounds.maxY - frameInWindow.minY)
            maxHeight = max(maxHeight, overlap)
        }
        return maxHeight
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — Overlay Model & View
// ─────────────────────────────────────────────────────────────

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
    let bottomConstraint: NSLayoutConstraint
}

private struct VdSnackbarOverlayView: View {
    @ObservedObject var model: VdSnackbarOverlayModel
    @State private var isShowing = false
    @State private var dragOffset: CGFloat = 0

    private let swipeDismissThreshold: CGFloat = 60

    var body: some View {
        // ZStack with no background — sizes itself to the snackbar pill only.
        // The hosting view's UIKit constraints (leading/trailing/bottom) position
        // the pill at the bottom of the screen. No full-screen Color.clear means
        // UIKit's hitTest naturally returns nil for everything outside this view.
        ZStack {
            if isShowing {
                VdSnackbar(
                    message: model.configuration.message,
                    action: model.configuration.action,
                    onAction: model.configuration.onAction,
                    leadingIcon: model.configuration.leadingIcon,
                    closable: model.configuration.closable,
                    onClose: model.configuration.onClose
                )
                .offset(y: max(0, dragOffset))
                .gesture(
                    DragGesture(minimumDistance: 10)
                        .onChanged { value in
                            if value.translation.height > 0 {
                                dragOffset = value.translation.height
                            }
                        }
                        .onEnded { value in
                            if value.translation.height > swipeDismissThreshold {
                                model.configuration.onClose?()
                            } else {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    dragOffset = 0
                                }
                            }
                        }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isShowing)
        .onAppear {
            isShowing = true
        }
        .onChangeCompat(of: model.isVisible) { newValue in
            if !newValue { dragOffset = 0 }
            isShowing = newValue
        }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — VdPassThroughWindow
// ─────────────────────────────────────────────────────────────

private final class VdPassThroughWindow: UIWindow {
    var isShowingSnackbar = false

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // When no snackbar is on screen, never intercept any touch.
        guard isShowingSnackbar else { return nil }
        // Delegate entirely to the view hierarchy. Because the hosting view is
        // sized to just the snackbar pill (not full-screen), super.hitTest
        // returns nil for any touch that falls outside the pill — no frame
        // tracking or coordinate comparison required.
        return super.hitTest(point, with: event)
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — VdSnackbarRootView
// ─────────────────────────────────────────────────────────────

/// Transparent full-screen root view for the overlay window.
/// Passes through any touch that doesn't land on a real subview (i.e., the
/// snackbar pill), keeping the main app fully interactive everywhere else.
private final class VdSnackbarRootView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hit = super.hitTest(point, with: event)
        // If the only thing hit was this transparent root view itself
        // (meaning no snackbar content exists at this point), return nil
        // so the touch falls through to the window below.
        return hit === self ? nil : hit
    }
}

private extension UIView {
    var allSubviews: [UIView] {
        subviews + subviews.flatMap(\.allSubviews)
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
                    message: "Snackbar Content",
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
            .vdFont(.labelSmall)
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
                action: { showBasic = true }
            )
            .frame(maxWidth: .infinity)

            VdButton(
                "Show snackbar with action",
                action: { showAction = true }
            )
            .frame(maxWidth: .infinity)

            VdButton(
                "Show snackbar with icon",
                style: .subtle,
                action: { showWithIcon = true }
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
