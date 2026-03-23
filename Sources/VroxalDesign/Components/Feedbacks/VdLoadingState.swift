// Components/Feedback/VdLoadingState.swift — Vroxal Design
// ─────────────────────────────────────────────────────────────
// Figma source: node 539-11365
//
// Two loading patterns in one file:
//
// ── 1. VdLoadingState ────────────────────────────────────────
// Centered spinner with optional title and description.
// Used for full-screen loading, section loading, or async waits.
//
//   Spinner   40×40pt  color=ContentPrimaryBase  (animated arc)
//   Title     Title/Large  ContentDefaultBase     optional
//   Body      Body/Medium  ContentDefaultSecondary optional
//   Gap       24pt between spinner and text block
//   Text gap  4pt between title and description
//
// Variants:
//   .inline   — renders as-is, embed anywhere in a layout
//   .overlay  — full screen dimmed overlay (BackgroundDefaultOverlay)
//               centered content, blocks interaction
//
// ── 2. VdSkeleton / .vdSkeleton() modifier ───────────────────
// Shimmer placeholder that mimics the shape of loading content.
// Apply to any view to replace it with an animated shimmer.
//
// USAGE — VdLoadingState
//   // Inline, spinner only
//   VdLoadingState()
//
//   // Inline with text
//   VdLoadingState(title: "Loading your data",
//                  description: "This won't take long")
//
//   // Full-screen overlay
//   VdLoadingState(style: .overlay)
//
//   // Overlay with text, shown conditionally
//   MyView()
//       .overlay {
//           if isLoading {
//               VdLoadingState(style: .overlay,
//                              title: "Saving changes...")
//           }
//       }
//
// USAGE — VdSkeleton
//   // Basic skeleton block
//   Rectangle()
//       .vdSkeleton()
//       .frame(height: 20)
//
//   // Skeleton card
//   VStack(alignment: .leading, spacing: 8) {
//       Rectangle().vdSkeleton().frame(height: 16).frame(maxWidth: .infinity)
//       Rectangle().vdSkeleton().frame(height: 16).frame(maxWidth: 200)
//       Rectangle().vdSkeleton().frame(height: 120).frame(maxWidth: .infinity)
//   }
//   .vdSkeletonEnabled(isLoading)   // toggle on/off
// ─────────────────────────────────────────────────────────────

import SwiftUI

// ─────────────────────────────────────────────────────────────
// MARK: — VdLoadingStyle
// ─────────────────────────────────────────────────────────────

public enum VdLoadingStyle {
    case inline     // renders in place within layout
    case overlay    // full-screen dimmed overlay
}

// ─────────────────────────────────────────────────────────────
// MARK: — VdLoadingState
// ─────────────────────────────────────────────────────────────

public struct VdLoadingState: View {

    private let style:       VdLoadingStyle
    private let title:       String?
    private let description: String?

    public init(
        style:       VdLoadingStyle = .inline,
        title:       String?        = nil,
        description: String?        = nil
    ) {
        self.style       = style
        self.title       = title
        self.description = description
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Body
    // ─────────────────────────────────────────────────────────

    public var body: some View {
        switch style {
        case .inline:
            content
        case .overlay:
            ZStack {
                // Dimmed backdrop
                Color.vdBackgroundDefaultTertiary
                    .ignoresSafeArea()
                    .allowsHitTesting(true)     // blocks all taps beneath

                content
                    .padding(VdSpacing.xl)
                    .background(
                        RoundedRectangle(cornerRadius: VdRadius.lg)
                            .fill(Color.vdBackgroundDefaultSecondary)
                    )
                    .padding(VdSpacing.xl)
            }
        }
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Core content — spinner + optional text
    // ─────────────────────────────────────────────────────────

    private var content: some View {
        VStack(spacing: VdSpacing.xl) {         // 24pt gap (scale/spacing/600)

            // ── Spinner ───────────────────────────────────────
            VdSpinner(size: 40, color: .vdContentPrimaryBase)

            // ── Text block (only if title or description given) ──
            if title != nil || description != nil {
                VStack(spacing: VdSpacing.xs) { // 4pt gap (scale/spacing/100)
                    if let t = title {
                        Text(t)
                            .vdFont(VdFont.titleLarge)
                            .foregroundStyle(Color.vdContentDefaultBase)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                    if let d = description {
                        Text(d)
                            .vdFont(VdFont.bodyMedium)
                            .foregroundStyle(Color.vdContentDefaultSecondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: 480)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — VdSpinner
// A standalone reusable spinning arc.
// Also used internally by VdButton and VdIconButton.
// ─────────────────────────────────────────────────────────────

public struct VdSpinner: View {

    private let size:  CGFloat
    private let color: Color

    @State private var isAnimating = false

    public init(size: CGFloat = 24, color: Color = .vdContentPrimaryBase) {
        self.size  = size
        self.color = color
    }

    public var body: some View {
        Circle()
            .trim(from: 0, to: 0.75)
            .stroke(color, style: StrokeStyle(lineWidth: size * 0.1, lineCap: .round))
            .frame(width: size, height: size)
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            .animation(
                .linear(duration: 0.9).repeatForever(autoreverses: false),
                value: isAnimating
            )
            .onAppear { isAnimating = true }
            .onDisappear { isAnimating = false }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — VdSkeletonModifier
// Shimmer animation for placeholder content.
// ─────────────────────────────────────────────────────────────

private struct VdSkeletonModifier: ViewModifier {

    let isEnabled:     Bool
    let cornerRadius:  CGFloat

    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        if isEnabled {
            content
                .hidden()
                .overlay(
                    GeometryReader { geo in
                        shimmer(width: geo.size.width)
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    }
                )
        } else {
            content
        }
    }

    @ViewBuilder
    private func shimmer(width: CGFloat) -> some View {
        let secondary = Color.vdBackgroundNeutralSecondary
        let highlight = Color.vdBackgroundNeutralTertiary.opacity(0.6)
        let leadingStop = 0.3 + phase * 0.4
        let centerStop = 0.5 + phase * 0.4
        let trailingStop = 0.7 + phase * 0.4
        let stops: [Gradient.Stop] = [
            .init(color: secondary, location: 0),
            .init(color: secondary, location: leadingStop),
            .init(color: highlight, location: centerStop),
            .init(color: secondary, location: trailingStop),
            .init(color: secondary, location: 1),
        ]
        let gradient = LinearGradient(
            stops: stops,
            startPoint: .leading,
            endPoint: .trailing
        )

        Rectangle()
            .fill(gradient)
            .onAppear {
                withAnimation(
                    .linear(duration: 1.4).repeatForever(autoreverses: false)
                ) {
                    phase = 1
                }
            }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — View extensions
// ─────────────────────────────────────────────────────────────

public extension View {

    /// Replaces this view with an animated shimmer placeholder.
    /// - Parameters:
    ///   - isEnabled: When true the shimmer is shown, when false the original view is shown.
    ///   - cornerRadius: Corner radius of the shimmer shape. Defaults to `VdRadius.xs` (4pt).
    func vdSkeleton(
        _ isEnabled:    Bool    = true,
        cornerRadius:   CGFloat = VdRadius.md
    ) -> some View {
        modifier(VdSkeletonModifier(isEnabled: isEnabled, cornerRadius: cornerRadius))
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — Preview
// ─────────────────────────────────────────────────────────────

#Preview("VdLoadingState — All Variants") {
    ScrollView {
        VStack(alignment: .leading, spacing: VdSpacing.xl) {

            previewSection("Spinner only") {
                VdLoadingState()
                    .frame(maxWidth: .infinity)
                    .padding(VdSpacing.lg)
                    .background(Color.vdBackgroundDefaultSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: VdRadius.lg))
            }

            previewSection("Spinner + title") {
                VdLoadingState(title: "Loading your data")
                    .frame(maxWidth: .infinity)
                    .padding(VdSpacing.lg)
                    .background(Color.vdBackgroundDefaultSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: VdRadius.lg))
            }

            previewSection("Spinner + title + description") {
                VdLoadingState(
                    title: "Title goes here",
                    description: "Nothing more exciting happening here in terms of content, but just filling up the space to make it look representative.")
                .frame(maxWidth: .infinity)
                .padding(VdSpacing.lg)
                .background(Color.vdBackgroundDefaultSecondary)
                .clipShape(RoundedRectangle(cornerRadius: VdRadius.lg))
            }

            previewSection("Overlay (tap to toggle)") {
                OverlayDemo()
            }

            previewSection("Skeleton — text lines") {
                VStack(alignment: .leading, spacing: VdSpacing.sm) {
                    RoundedRectangle(cornerRadius: VdRadius.xs)
                        .vdSkeleton()
                        .frame(maxWidth: .infinity)
                        .frame(height: 16)
                    RoundedRectangle(cornerRadius: VdRadius.xs)
                        .vdSkeleton()
                        .frame(maxWidth: 260)
                        .frame(height: 16)
                    RoundedRectangle(cornerRadius: VdRadius.xs)
                        .vdSkeleton()
                        .frame(maxWidth: 200)
                        .frame(height: 16)
                }
                .padding(VdSpacing.md)
                .background(Color.vdBackgroundDefaultSecondary)
                .clipShape(RoundedRectangle(cornerRadius: VdRadius.lg))
            }

            previewSection("Skeleton — card") {
                SkeletonCardDemo()
            }

            previewSection("Skeleton — toggle") {
                SkeletonToggleDemo()
            }
        }
        .padding(VdSpacing.lg)
    }
    .background(Color.vdBackgroundDefaultBase)
}

// ─────────────────────────────────────────────────────────────
// MARK: Preview helpers
// ─────────────────────────────────────────────────────────────

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

private struct OverlayDemo: View {
    @State private var isLoading = false

    var body: some View {
        ZStack {
            VStack(spacing: VdSpacing.md) {
                Text("Tap the button to show the overlay loading state.")
                    .vdFont(VdFont.bodyMedium)
                    .foregroundStyle(Color.vdContentDefaultSecondary)
                    .multilineTextAlignment(.center)
                VdButton("Show overlay", action: {
                    isLoading = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        isLoading = false
                    }
                })
            }
            .frame(maxWidth: .infinity)
            .padding(VdSpacing.lg)
            .background(Color.vdBackgroundDefaultSecondary)
            .clipShape(RoundedRectangle(cornerRadius: VdRadius.lg))

            if isLoading {
                VdLoadingState(style: .overlay, title: "Saving changes...")
                    .clipShape(RoundedRectangle(cornerRadius: VdRadius.lg))
            }
        }
    }
}

private struct SkeletonCardDemo: View {
    var body: some View {
        HStack(spacing: VdSpacing.md) {
            // Avatar
            Circle()
                .vdSkeleton()
                .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: VdSpacing.xs) {
                RoundedRectangle(cornerRadius: VdRadius.xs)
                    .vdSkeleton()
                    .frame(width: 140, height: 14)
                RoundedRectangle(cornerRadius: VdRadius.xs)
                    .vdSkeleton()
                    .frame(width: 100, height: 12)
            }

            Spacer()

            RoundedRectangle(cornerRadius: VdRadius.xs)
                .vdSkeleton()
                .frame(width: 60, height: 28)
        }
        .padding(VdSpacing.md)
        .background(Color.vdBackgroundDefaultSecondary)
        .clipShape(RoundedRectangle(cornerRadius: VdRadius.lg))
    }
}

private struct SkeletonToggleDemo: View {
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: VdSpacing.md) {
            Toggle("Show skeleton", isOn: $isLoading)
                .tint(Color.vdBackgroundPrimaryBase)

            HStack(spacing: VdSpacing.md) {
                Circle()
                    .fill(Color.vdBackgroundPrimarySecondary)
                    .vdSkeleton(isLoading)
                    .frame(width: 48, height: 48)

                VStack(alignment: .leading, spacing: VdSpacing.xs) {
                    Text("Ada Lovelace")
                        .vdFont(VdFont.labelMedium)
                        .foregroundStyle(Color.vdContentDefaultBase)
                        .vdSkeleton(isLoading)
                    Text("ada@example.com")
                        .vdFont(VdFont.bodySmall)
                        .foregroundStyle(Color.vdContentDefaultSecondary)
                        .vdSkeleton(isLoading)
                }

                Spacer()
            }
            .padding(VdSpacing.md)
            .background(Color.vdBackgroundDefaultSecondary)
            .clipShape(RoundedRectangle(cornerRadius: VdRadius.lg))
        }
    }
}
