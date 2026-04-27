// Components/Feedback/VdSnackbar.swift — Vroxal Design

import SwiftUI

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
