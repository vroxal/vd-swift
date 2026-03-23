// Theme/Typography.swift — Vroxal Design System

import SwiftUI
import UIKit

// ═════════════════════════════════════════════════════════════
// MARK: — VdTextStyle
// Mirrors a single Figma text style token exactly.
// ═════════════════════════════════════════════════════════════

public struct VdTextStyle {
    public let font:       Font
    public let uiFont:     UIFont
    public let size:       CGFloat
    public let lineHeight: CGFloat
    public let tracking:   CGFloat
    public var lineSpacingValue: CGFloat {
        max(lineHeight - uiFont.lineHeight, 0)
    }
    public var leadingPadding: CGFloat {
        lineSpacingValue / 2
    }
}

// ═════════════════════════════════════════════════════════════
// MARK: — VdFont
// Static properties matching every Figma type token.
// Source: node 31-169 variable definitions.
// ═════════════════════════════════════════════════════════════

public enum VdFont {

    private static let registrationLock = NSLock()
    private static var hasRegisteredFonts = false

    // ── Font registration ─────────────────────────────────────
    /// Registers Poppins from Bundle.module so .custom() resolves.
    /// Safe to call multiple times.
    public static func register() {
        registrationLock.lock()
        defer { registrationLock.unlock() }

        guard !hasRegisteredFonts else { return }

        let fontFiles = [
            "Poppins-Regular",
            "Poppins-Medium",
            "Poppins-SemiBold",
            "Poppins-Italic"
        ]
        for name in fontFiles {
            guard
                let url  = fontURL(for: name),
                let data = try? Data(contentsOf: url),
                let prov = CGDataProvider(data: data as CFData),
                let cgFont = CGFont(prov)
            else { continue }
            CTFontManagerRegisterGraphicsFont(cgFont, nil)
        }
        hasRegisteredFonts = true
    }

    private static func fontURL(for name: String) -> URL? {
        Bundle.module.url(forResource: name, withExtension: "ttf")
            ?? Bundle.module.url(forResource: name, withExtension: "ttf", subdirectory: "Fonts")
    }

    // ── Internal font builder ─────────────────────────────────

    private static func style(
        name:       String = "Poppins",
        size:       CGFloat,
        weight:     Font.Weight,
        lineHeight: CGFloat,
        tracking:   CGFloat
    ) -> VdTextStyle {
        register()

        // Map Font.Weight to UIFont.Weight for UIFont resolution
        let uiWeight: UIFont.Weight = {
            switch weight {
            case .semibold:   return .semibold
            case .medium:     return .medium
            case .bold:       return .bold
            case .heavy:      return .heavy
            case .black:      return .black
            case .light:      return .light
            case .thin:       return .thin
            case .ultraLight: return .ultraLight
            default:          return .regular
            }
        }()

        // Resolve UIFont: prefer the registered Poppins; fall back to
        // a system font with the same size so metrics are never nil.
        let uiFont: UIFont = UIFont(name: name + "-" + uiWeightSuffix(uiWeight), size: size)
            ?? UIFont.systemFont(ofSize: size, weight: uiWeight)

        return VdTextStyle(
            font:       .custom(name, size: size).weight(weight),
            uiFont:     uiFont,
            size:       size,
            lineHeight: lineHeight,
            tracking:   tracking
        )
    }

    /// Maps UIFont.Weight to the Poppins filename weight suffix.
    private static func uiWeightSuffix(_ weight: UIFont.Weight) -> String {
        switch weight {
        case .semibold:   return "SemiBold"
        case .medium:     return "Medium"
        case .bold:       return "Bold"
        case .light:      return "Light"
        case .thin:       return "Thin"
        case .ultraLight: return "ExtraLight"
        default:          return "Regular"
        }
    }

    // ═══════════════════════════════════════════════════════
    // MARK: Display  — SemiBold, negative tracking
    // ═══════════════════════════════════════════════════════

    /// Display/Large  · 60 / 72 / -1.5
    public static let displayLarge = style(
        size: 60, weight: .semibold, lineHeight: 72, tracking: -1.5
    )

    /// Display/Medium  · 48 / 56 / -1.0
    public static let displayMedium = style(
        size: 48, weight: .semibold, lineHeight: 56, tracking: -1.0
    )

    /// Display/Small  · 40 / 48 / -0.5
    public static let displaySmall = style(
        size: 40, weight: .semibold, lineHeight: 48, tracking: -0.5
    )

    // ═══════════════════════════════════════════════════════
    // MARK: Headline  — SemiBold, tracking -0.3
    // ═══════════════════════════════════════════════════════

    /// Headline/Large  · 34 / 40 / -0.3
    public static let headlineLarge = style(
        size: 34, weight: .semibold, lineHeight: 40, tracking: -0.3
    )

    /// Headline/Medium  · 28 / 36 / -0.3
    public static let headlineMedium = style(
        size: 28, weight: .semibold, lineHeight: 36, tracking: -0.3
    )

    /// Headline/Small  · 24 / 32 / -0.3
    public static let headlineSmall = style(
        size: 24, weight: .semibold, lineHeight: 32, tracking: -0.3
    )

    // ═══════════════════════════════════════════════════════
    // MARK: Title  — SemiBold, tracking 0
    // ═══════════════════════════════════════════════════════

    /// Title/Large  · 20 / 28 / 0
    public static let titleLarge = style(
        size: 20, weight: .semibold, lineHeight: 28, tracking: 0
    )

    /// Title/Medium  · 16 / 24 / 0
    public static let titleMedium = style(
        size: 16, weight: .semibold, lineHeight: 24, tracking: 0
    )

    /// Title/Small  · 14 / 20 / 0
    public static let titleSmall = style(
        size: 14, weight: .semibold, lineHeight: 20, tracking: 0
    )

    // ═══════════════════════════════════════════════════════
    // MARK: Label  — Medium (500), tracking +0.2
    // ═══════════════════════════════════════════════════════

    /// Label/Large  · 16 / 24 / +0.2
    public static let labelLarge = style(
        size: 16, weight: .medium, lineHeight: 24, tracking: 0.2
    )

    /// Label/Medium  · 14 / 24 / +0.2
    public static let labelMedium = style(
        size: 14, weight: .medium, lineHeight: 24, tracking: 0.2
    )

    /// Label/Small  · 12 / 16 / +0.2
    public static let labelSmall = style(
        size: 12, weight: .medium, lineHeight: 16, tracking: 0.2
    )

    /// Label/ExtraSmall  · 10 / 16 / +0.2
    public static let labelExtraSmall = style(
        size: 10, weight: .medium, lineHeight: 16, tracking: 0.2
    )

    // ═══════════════════════════════════════════════════════
    // MARK: Body  — Regular (400), tracking 0
    // ═══════════════════════════════════════════════════════

    /// Body/ExtraLarge  · 24 / 36 / 0
    public static let bodyExtraLarge = style(
        size: 24, weight: .regular, lineHeight: 36, tracking: 0
    )

    /// Body/Large  · 16 / 24 / 0
    public static let bodyLarge = style(
        size: 16, weight: .regular, lineHeight: 24, tracking: 0
    )

    /// Body/Medium  · 14 / 24 / 0
    public static let bodyMedium = style(
        size: 14, weight: .regular, lineHeight: 24, tracking: 0
    )

    /// Body/MediumItalic  · 14 / 24 / 0
    public static let bodyMediumItalic: VdTextStyle = {
        register()
        return VdTextStyle(
            font:       .custom("Poppins-Italic", size: 14),
            uiFont:     UIFont(name: "Poppins-Italic", size: 14)
                            ?? UIFont.italicSystemFont(ofSize: 14),
            size:       14,
            lineHeight: 24,
            tracking:   0
        )
    }()

    /// Body/Small  · 12 / 16 / 0
    public static let bodySmall = style(
        size: 12, weight: .regular, lineHeight: 16, tracking: 0
    )

    /// Body/ExtraSmall  · 10 / 16 / 0
    public static let bodyExtraSmall = style(
        size: 10, weight: .regular, lineHeight: 16, tracking: 0
    )
}

// ═════════════════════════════════════════════════════════════
// MARK: — VdTracking
// Raw letter-spacing constants for use with .tracking() when
// you apply a font manually (e.g. on non-Text views).
// ═════════════════════════════════════════════════════════════

public enum VdTracking {
    /// Display Large/Medium/Small and Headline — negative
    public static let displayLarge:  CGFloat = -1.5
    public static let displayMedium: CGFloat = -1.0
    public static let displaySmall:  CGFloat = -0.5
    public static let headline:      CGFloat = -0.3
    /// Title and Body — zero
    public static let `default`:     CGFloat =  0.0
    /// Label — slight positive
    public static let label:         CGFloat =  0.2
}

// ═════════════════════════════════════════════════════════════
// MARK: — VdTextStyle token aliases
//
// Mirrors every VdFont token as a static property on VdTextStyle
// so Swift's type inference resolves the dot-shorthand:
//
//   .vdFont(.bodySmall)   ← instead of .vdFont(VdFont.bodySmall)
//
// ═════════════════════════════════════════════════════════════

public extension VdTextStyle {
    static var displayLarge:    VdTextStyle { VdFont.displayLarge    }
    static var displayMedium:   VdTextStyle { VdFont.displayMedium   }
    static var displaySmall:    VdTextStyle { VdFont.displaySmall    }

    static var headlineLarge:   VdTextStyle { VdFont.headlineLarge   }
    static var headlineMedium:  VdTextStyle { VdFont.headlineMedium  }
    static var headlineSmall:   VdTextStyle { VdFont.headlineSmall   }

    static var titleLarge:      VdTextStyle { VdFont.titleLarge      }
    static var titleMedium:     VdTextStyle { VdFont.titleMedium     }
    static var titleSmall:      VdTextStyle { VdFont.titleSmall      }

    static var labelLarge:      VdTextStyle { VdFont.labelLarge      }
    static var labelMedium:     VdTextStyle { VdFont.labelMedium     }
    static var labelSmall:      VdTextStyle { VdFont.labelSmall      }
    static var labelExtraSmall: VdTextStyle { VdFont.labelExtraSmall }

    static var bodyExtraLarge:  VdTextStyle { VdFont.bodyExtraLarge  }
    static var bodyLarge:       VdTextStyle { VdFont.bodyLarge       }
    static var bodyMedium:      VdTextStyle { VdFont.bodyMedium      }
    static var bodyMediumItalic: VdTextStyle { VdFont.bodyMediumItalic }
    static var bodySmall:       VdTextStyle { VdFont.bodySmall       }
    static var bodyExtraSmall:  VdTextStyle { VdFont.bodyExtraSmall  }
}

// ═════════════════════════════════════════════════════════════
// MARK: — View.vdFont() modifier
// ═════════════════════════════════════════════════════════════

public extension View {
    func vdFont(_ style: VdTextStyle) -> some View {
        VdFont.register()
        return self
            .font(style.font)
            .tracking(style.tracking)
            .lineSpacing(style.lineSpacingValue)
            .padding(.vertical, style.leadingPadding)
    }
}
