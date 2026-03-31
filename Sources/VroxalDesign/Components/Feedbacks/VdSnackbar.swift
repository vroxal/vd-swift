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
            }

            // ── Message ───────────────────────────────────────
            Text(message)
                .vdFont(VdFont.bodyMedium)
                .foregroundStyle(Color.vdContentNeutralOnBase)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let label = action {
                Button(action: { onAction?() }) {
                    Text(label)
                        .vdFont(VdFont.labelMedium)
                        .foregroundStyle(Color.vdContentPrimaryBaseInverted)
                }
                .buttonStyle(.plain)
            }

            if closable {
                Button(action: { onClose?() }) {
                    VdIcon("vd:xmark", size: VdIconSize.xs, color: .vdContentNeutralOnBase)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, VdSpacing.smMd)
        .padding(.vertical, VdSpacing.sm)
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
            dismiss()
        }
    }

    @MainActor
    private func dismiss() {
        // Setting isPresented = false triggers onChangeCompat → syncPresentation()
        // which calls VdSnackbarPresenter.dismiss. No need to call it directly here.
        withAnimation {
            isPresented = false
        }
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
        let bottomInset = resolvedBottomInset(for: scene)

        if let entry = entries[id] {
            entry.window.windowScene = scene
            entry.window.isHidden = false
            entry.model.configuration = configuration
            entry.model.bottomInset = bottomInset
            withAnimation(transition) {
                entry.model.isVisible = true
            }
            return
        }

        let model = VdSnackbarOverlayModel(configuration: configuration)
        model.bottomInset = bottomInset
        let window = makeWindow(for: scene)
        model.onSnackbarFrameChange = { [weak window] frame in
            (window as? VdPassThroughWindow)?.blockedFrame = frame
        }
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
            guard let currentEntry = entries[id],
                  currentEntry.model.isVisible == false else { return }
            (currentEntry.window as? VdPassThroughWindow)?.blockedFrame = .null
            currentEntry.window.isHidden = true
            currentEntry.window.rootViewController = nil
            entries.removeValue(forKey: id)
        }
    }

    private static func activeWindowScene() -> UIWindowScene? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })
        ?? UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first
    }

    private static func makeWindow(for scene: UIWindowScene) -> UIWindow {
        let window = VdPassThroughWindow(windowScene: scene)
        window.backgroundColor = .clear
        window.windowLevel = .alert + 1
        return window
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
    @Published var bottomInset: CGFloat = VdSpacing.xl
    var onSnackbarFrameChange: ((CGRect) -> Void)?

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
                .padding(.bottom, model.bottomInset)
                // ✅ onTapGesture before contentShape so the full
                //    padded bounding box consumes taps, not just
                //    the VdSnackbar pill itself.
                .onTapGesture { }
                .contentShape(Rectangle())
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .preference(
                                key: VdSnackbarFramePreferenceKey.self,
                                value: proxy.frame(in: .named(VdSnackbarOverlayCoordinateSpace.name))
                            )
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .background(Color.clear)
        .ignoresSafeArea()
        .coordinateSpace(name: VdSnackbarOverlayCoordinateSpace.name)
        .onPreferenceChange(VdSnackbarFramePreferenceKey.self) { frame in
            model.onSnackbarFrameChange?(frame)
        }
        .onChangeCompat(of: model.isVisible) { isVisible in
            guard !isVisible else { return }
            model.onSnackbarFrameChange?(.null)
        }
    }
}

private struct VdSnackbarFramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .null

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

private enum VdSnackbarOverlayCoordinateSpace {
    static let name = "VdSnackbarOverlayCoordinateSpace"
}

// ─────────────────────────────────────────────────────────────
// MARK: — VdPassThroughWindow
// ─────────────────────────────────────────────────────────────

private final class VdPassThroughWindow: UIWindow {
    var blockedFrame: CGRect = .null

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // If no snackbar is shown, pass all touches through.
        guard !blockedFrame.isNull else { return nil }

        let expandedBlockedFrame = blockedFrame.insetBy(dx: -2, dy: -2)

        // ✅ Touches OUTSIDE the snackbar frame pass through to
        //    whatever is beneath the overlay window.
        guard expandedBlockedFrame.contains(point) else { return nil }

        // ✅ Touches INSIDE the snackbar frame are handled by the
        //    snackbar (buttons, close, tap-consume gesture).
        return super.hitTest(point, with: event) ?? rootViewController?.view
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
