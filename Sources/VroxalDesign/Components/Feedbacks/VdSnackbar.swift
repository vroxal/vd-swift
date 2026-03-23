// Components/Feedback/VdSnackbar.swift — Vroxal Design

import SwiftUI

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
                VStack {
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .padding(2)
                        .foregroundStyle(Color.vdContentNeutralOnBase)
                        .frame(width: VdIconSize.md, height: VdIconSize.md)
                    //                        .background()

                }
                .padding(VdSpacing.sm)

            }

            // ── Message ───────────────────────────────────────
            Text(message)
                .vdFont(VdFont.bodyMedium)
                .foregroundStyle(Color.vdContentNeutralOnBase)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(VdSpacing.sm)

            if let label = action {
                Button(action: { onAction?() }) {
                    Text(label)
                        .vdFont(VdFont.bodyMedium)
                        .foregroundStyle(Color.vdContentPrimaryBase)
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
            }
        }
        .padding(VdSpacing.sm)
        .background(Color.vdBackgroundNeutralTertiary)
        .clipShape(RoundedRectangle(cornerRadius: VdRadius.md))
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — VdSnackbarModifier
// Presents the snackbar as an overlay pinned to the bottom
// of the screen, with enter/exit slide + fade animation.
// Auto-dismisses after `duration` seconds unless closable.
// ─────────────────────────────────────────────────────────────

public struct VdSnackbarModifier: ViewModifier {

    @Binding private var isPresented: Bool
    private let message: String
    private let action: String?
    private let onAction: (() -> Void)?
    private let leadingIcon: String?
    private let closable: Bool
    private let duration: TimeInterval  // 0 = no auto-dismiss
    @State private var dismissId: UInt = 0  // incremented on each show to invalidate stale timers

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
            .overlay(alignment: .bottom) {
                if isPresented {
                    VdSnackbar(
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
                    .padding(.horizontal, VdSpacing.lg)  // 24pt side margins
                    .padding(.bottom, VdSpacing.xl)  // 32pt from bottom edge
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onAppear {
                        guard duration > 0 else { return }
                        dismissId &+= 1
                        let currentId = dismissId
                        DispatchQueue.main.asyncAfter(
                            deadline: .now() + duration
                        ) {
                            // Only dismiss if this is still the same presentation
                            guard currentId == dismissId else { return }
                            dismiss()
                        }
                    }
                }
            }
            .animation(
                .spring(response: 0.35, dampingFraction: 0.8),
                value: isPresented
            )
    }

    private func dismiss() {
        withAnimation { isPresented = false }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — View extension
// ─────────────────────────────────────────────────────────────

extension View {

    /// Presents a snackbar anchored to the bottom of this view.
    ///
    ///     .vdSnackbar(isPresented: $show, message: "Saved!",
    ///                 action: "Undo", onAction: { undoSave() })
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
                        "Snackbar Content that can goes multiline across two lines",
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
