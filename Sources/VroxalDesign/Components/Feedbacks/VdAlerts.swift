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
                icon: "vd:info-circle-filled"
            )
        case .neutral:
            return VdAlertTokens(
                background: .vdBackgroundNeutralSecondary,
                border: .vdBorderNeutralSecondary,
                contentColor: .vdContentNeutralOnSecondary,
                icon: "vd:info-circle-filled"
            )
        case .success:
            return VdAlertTokens(
                background: .vdBackgroundSuccessSecondary,
                border: .vdBorderSuccessSecondary,
                contentColor: .vdContentSuccessOnSecondary,
                icon: "vd:check-circle-filled"
            )
        case .error:
            return VdAlertTokens(
                background: .vdBackgroundErrorSecondary,
                border: .vdBorderErrorSecondary,
                contentColor: .vdContentErrorOnSecondary,
                icon: "vd:danger-circle-filled"
            )
        case .warning:
            return VdAlertTokens(
                background: .vdBackgroundWarningSecondary,
                border: .vdBorderWarningSecondary,
                contentColor: .vdContentWarningOnSecondary,
                icon: "vd:danger-triangle-filled"
            )
        case .info:
            return VdAlertTokens(
                background: .vdBackgroundInfoSecondary,
                border: .vdBorderInfoSecondary,
                contentColor: .vdContentInfoOnSecondary,
                icon: "vd:info-circle-filled"
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
                        .vdFont(.titleMedium)
                        .foregroundStyle(t.contentColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Text(description)
                    .vdFont(.labelMedium)
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
