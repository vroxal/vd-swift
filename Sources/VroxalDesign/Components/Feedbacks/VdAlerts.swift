// Components/Alerts/VdAlert.swift — Vroxal Design System

import SwiftUI

//─────────────────────────────────────────────────────────────
// MARK: — VdAlertColor
// ─────────────────────────────────────────────────────────────

public enum VdAlertColor {
    case primary
    case neutral
    case success
    case error
    case warning
    case info
}

// ─────────────────────────────────────────────────────────────
// MARK: — Token resolution
// ─────────────────────────────────────────────────────────────

private struct VdAlertTokens {
    let background: Color
    let border: Color
    let contentColor: Color
    let icon: String
}

extension VdAlertColor {
    fileprivate var tokens: VdAlertTokens {
        switch self {
        case .primary:
            return VdAlertTokens(
                background: .vdBackgroundPrimarySecondary,
                border: .vdBorderPrimarySecondary,
                contentColor: .vdContentPrimaryOnSecondary,
                icon: "vd:info-circle-filled",
            )
        case .neutral:
            return VdAlertTokens(
                background: .vdBackgroundNeutralSecondary,
                border: .vdBorderNeutralSecondary,
                contentColor: .vdContentNeutralOnSecondary,
                icon: "vd:info-circle-filled",
            )
        case .success:
            return VdAlertTokens(
                background: .vdBackgroundSuccessSecondary,
                border: .vdBorderSuccessSecondary,
                contentColor: .vdContentSuccessOnSecondary,
                icon: "vd:check-circle-filled",
            )
        case .error:
            return VdAlertTokens(
                background: .vdBackgroundErrorSecondary,
                border: .vdBorderErrorSecondary,
                contentColor: .vdContentErrorOnSecondary,
                icon: "vd:danger-circle-filled",
            )
        case .warning:
            return VdAlertTokens(
                background: .vdBackgroundWarningSecondary,
                border: .vdBorderWarningSecondary,
                contentColor: .vdContentWarningOnSecondary,
                icon: "vd:danger-triangle-filled",
            )
        case .info:
            return VdAlertTokens(
                background: .vdBackgroundInfoSecondary,
                border: .vdBorderInfoSecondary,
                contentColor: .vdContentInfoOnSecondary,
                icon: "vd:info-circle-filled",
            )
        }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — VdAlert
// ─────────────────────────────────────────────────────────────

public struct VdAlert: View {

    private let color: VdAlertColor
    private let icon: String?  // nil = use color default
    private let title: String?
    private let description: String
    private let action: String?
    private let actionInline: Bool
    private let closable: Bool
    private let onAction: (() -> Void)?
    private let onClose: (() -> Void)?

    public init(
        color: VdAlertColor = .primary,
        icon: String? = nil,
        title: String? = nil,
        description: String,
        action: String? = nil,
        actionInline: Bool = false,
        closable: Bool = false,
        onAction: (() -> Void)? = nil,
        onClose: (() -> Void)? = nil
    ) {
        self.color = color
        self.icon = icon
        self.title = title
        self.description = description
        self.action = action
        self.actionInline = actionInline
        self.closable = closable
        self.onAction = onAction
        self.onClose = onClose
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Body
    // ─────────────────────────────────────────────────────────

    public var body: some View {
        let t = color.tokens

        HStack(alignment: .top, spacing: VdSpacing.sm) {
            VdIcon(icon ?? t.icon, size: VdIconSize.md, color: t.contentColor)
            VStack(alignment: .leading, spacing: 0) {
                if let title {
                    Text(title)
                        .vdFont(VdFont.titleMedium)
                        .foregroundStyle(t.contentColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Text(description)
                    .vdFont(VdFont.labelMedium)
                    .foregroundStyle(Color.vdContentDefaultBase)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let label = action, !actionInline {
                    actionButton(label: label)
                        .padding(.top, VdSpacing.sm)
                }

            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if actionInline {
                if let label = action {
                    actionButton(label: label)
                }

            }
            if closable {
                closeButton
                    .padding(.top, -VdSpacing.xs)
                    .padding(.trailing, -VdSpacing.xs)
            }

        }
        .padding(VdSpacing.md)
        .background(t.background)
        .clipShape(
            RoundedRectangle(cornerRadius: VdRadius.md, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: VdRadius.md, style: .continuous)
                .strokeBorder(t.border, lineWidth: VdBorderWidth.sm)
        }
    }
    // ─────────────────────────────────────────────────────────
    // MARK: Subviews
    // ─────────────────────────────────────────────────────────

    // Action — Figma: Label/Medium, always vdContentPrimaryOnSecondary
    private func actionButton(label: String) -> some View {
        Button(action: { onAction?() }) {
            Text(label)
                .vdFont(.labelMedium)
                .foregroundStyle(Color.vdContentPrimaryOnSecondary)
                .lineLimit(1)
        }
        .buttonStyle(.plain)
    }

    private var closeButton: some View {
        VdIconButton(
            icon: "vd:xmark",
            color: .neutral,
            style: .transparent,
            size: .small,
            action: { onClose?() }
        )
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — Preview
// ─────────────────────────────────────────────────────────────

#Preview("VdAlert — All Variants") {
    ScrollView {
        VStack(alignment: .leading, spacing: VdSpacing.xl) {

            // ── Standard (action below, closable) ─────────────
            previewSection("Standard · Action Below · Closable") {
                VdAlert(
                    color: .primary,
                    icon: "vd:user-circle-filled",
                    description:
                        "Nothing more exciting happening here in terms of content, but just filling up the space to make it look more representative.",
                    action: "Alert Action",
                    actionInline: true,
                    closable: true,
                    onAction: {},
                    onClose: {}
                )

                VdAlert(
                    color: .neutral,
                    title: "Title for the alert goes here",
                    description:
                        "Nothing more exciting happening here in terms of content, but just filling up the space.",
                    action: "Alert Action",
                    closable: true,
                    onAction: {},
                    onClose: {}
                )

                VdAlert(
                    color: .success,
                    title: "Payment complete",
                    description:
                        "Your order #4821 has been confirmed and is being processed.",
                    action: "View order",
                    closable: true,
                    onAction: {},
                    onClose: {}
                )

                VdAlert(
                    color: .error,
                    title: "Upload failed",
                    description:
                        "File size exceeds the 10MB limit. Please compress and try again.",
                    action: "Try again",
                    closable: true,
                    onAction: {},
                    onClose: {}
                )

                VdAlert(
                    color: .warning,
                    title: "Session expiring soon",
                    description:
                        "Your session will expire in 5 minutes. Save your work to avoid losing changes.",
                    action: "Extend session",
                    closable: true,
                    onAction: {},
                    onClose: {}
                )

                VdAlert(
                    color: .info,
                    title: "New update available",
                    description:
                        "Version 2.1 includes performance improvements and bug fixes.",
                    action: "Install now",
                    closable: true,
                    onAction: {},
                    onClose: {}
                )
            }

            // ── Custom icon override ──────────────────────────
            previewSection("Custom Icon Override") {
                VdAlert(
                    color: .primary,
                    icon: "person.crop.circle.fill",
                    title: "Profile updated",
                    description:
                        "Your account information has been saved successfully.",
                    action: "View profile",
                    closable: true,
                    onAction: {},
                    onClose: {}
                )

                VdAlert(
                    color: .error,
                    icon: "externaldrive.badge.xmark",
                    title: "Storage full",
                    description:
                        "You have run out of storage space. Delete files to continue.",
                    action: "Manage storage",
                    closable: true,
                    onAction: {},
                    onClose: {}
                )

                VdAlert(
                    color: .warning,
                    icon: "vd:wi-fi-router",
                    title: "Weak connection",
                    description:
                        "Your internet connection is unstable. Some features may not work.",
                    closable: true,
                    onClose: {}
                )

                VdAlert(
                    color: .success,
                    icon: "vd:cart-filled",
                    title: "Order shipped",
                    description:
                        "Your package is on its way and will arrive in 2–3 business days.",
                    action: "Track order",
                    actionInline: true,
                    closable: true,
                    onAction: {},
                    onClose: {}
                )
            }

            // ── Inline action ─────────────────────────────────
            previewSection("Action Inline · Closable") {
                VdAlert(
                    color: .primary,
                    title: "Title for the alert goes here",
                    description:
                        "Nothing more exciting happening here in terms of content.",
                    action: "Alert Action",
                    actionInline: true,
                    closable: true,
                    onAction: {},
                    onClose: {}
                )

                VdAlert(
                    color: .success,
                    title: "Backup complete",
                    description:
                        "All files have been backed up to cloud storage.",
                    action: "View files",
                    actionInline: true,
                    closable: true,
                    onAction: {},
                    onClose: {}
                )

                VdAlert(
                    color: .error,
                    title: "Card declined",
                    description:
                        "Please check your payment details and try again.",
                    action: "Update card",
                    actionInline: true,
                    closable: true,
                    onAction: {},
                    onClose: {}
                )

                VdAlert(
                    color: .warning,
                    title: "Low storage",
                    description: "You are running low on storage space.",
                    action: "Manage",
                    actionInline: true,
                    closable: true,
                    onAction: {},
                    onClose: {}
                )

                VdAlert(
                    color: .info,
                    title: "Tips & tricks",
                    description:
                        "Did you know you can swipe left to archive items?",
                    action: "Learn more",
                    actionInline: true,
                    closable: true,
                    onAction: {},
                    onClose: {}
                )
            }

            // ── No action, no close ───────────────────────────
            previewSection("Minimal — No Action, No Close") {
                VdAlert(
                    color: .success,
                    title: "Profile saved",
                    description: "Your changes have been saved successfully."
                )

                VdAlert(
                    color: .error,
                    title: "Connection lost",
                    description:
                        "Unable to reach the server. Check your internet connection."
                )

                VdAlert(
                    color: .info,
                    title: "Read-only mode",
                    description:
                        "This document is shared with view-only access."
                )
            }

            // ── Interactive demo ──────────────────────────────
            previewSection("Interactive") {
                InteractiveDemo()
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

private struct InteractiveDemo: View {
    @State private var showSuccess = true
    @State private var showError = true
    @State private var showInfo = true

    var body: some View {
        VStack(spacing: VdSpacing.sm) {
            if showSuccess {
                VdAlert(
                    color: .success,
                    title: "Email verified",
                    description: "Your email address has been confirmed.",
                    closable: true,
                    onClose: { withAnimation { showSuccess = false } }
                )
            }
            if showError {
                VdAlert(
                    color: .error,
                    title: "Failed to save",
                    description:
                        "An unexpected error occurred. Please try again.",
                    action: "Retry",
                    closable: true,
                    onAction: {},
                    onClose: { withAnimation { showError = false } }
                )
            }
            if showInfo {
                VdAlert(
                    color: .info,
                    icon: "calendar.badge.clock",
                    title: "Scheduled maintenance",
                    description:
                        "The service will be unavailable on Sunday 2–4am.",
                    action: "Remind me",
                    actionInline: true,
                    closable: true,
                    onAction: {},
                    onClose: { withAnimation { showInfo = false } }
                )
            }
            if !showSuccess && !showError && !showInfo {
                Button("Reset") {
                    withAnimation {
                        showSuccess = true
                        showError = true
                        showInfo = true
                    }
                }
            }
        }
        .padding(VdSpacing.md)
        .background(Color.vdBackgroundDefaultSecondary)
        .clipShape(RoundedRectangle(cornerRadius: VdRadius.lg))
    }
}
