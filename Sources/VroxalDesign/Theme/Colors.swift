// Theme/Colors.swift — Vroxal Design
// ─────────────────────────────────────────────────────────────
// SOURCE OF TRUTH: root.json → brand.json → light.json / dark.json
//
// THREE-LAYER ARCHITECTURE
// ────────────────────────
// LAYER 1 · Root Palette   _vdBlueGlow500, _vdGrey300 …
//   Raw hex from root.json. Private (underscore prefix).
//   Never reference these in components.
//
// LAYER 2 · Brand Colours  _vdPrimary500, _vdSuccess100 …
//   Aliases of root values from brand.json.
//   Private. If the brand ever swaps BlueGlow → another hue,
//   only this layer changes and every semantic token follows.
//
// LAYER 3 · Semantic Tokens  Color.vdContentDefaultBase, Color.vdBackgroundPrimaryBase …
//   Dynamic Color(light:dark:) resolved from light.json & dark.json.
//   PUBLIC. These are the ONLY tokens components should use.
//   Format: vd<Type><Semantic><Variant>
//
// Figma file: https://figma.com/design/8oIATZ6DcoE8mPi62kw97V
// ─────────────────────────────────────────────────────────────

import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// ─────────────────────────────────────────────────────────────
// MARK: — Helpers
// ─────────────────────────────────────────────────────────────

extension Color {

    /// Initialise from a hex string. Supports 6-char (#RRGGBB) and
    /// 8-char (#RRGGBBAA) formats.
    init(vdHex hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let hasAlpha = hex.count == 8
        let r = Double((int >> (hasAlpha ? 24 : 16)) & 0xFF) / 255
        let g = Double((int >> (hasAlpha ? 16 :  8)) & 0xFF) / 255
        let b = Double((int >> (hasAlpha ?  8 :  0)) & 0xFF) / 255
        let a = hasAlpha ? Double(int & 0xFF) / 255 : 1.0
        self.init(red: r, green: g, blue: b, opacity: a)
    }

    /// Dynamic light/dark colour — adapts automatically to the
    /// current colour scheme on both iOS and macOS.
    init(light: Color, dark: Color) {
        #if canImport(UIKit)
        self.init(UIColor { tc in
            tc.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
        #else
        self.init(NSColor(name: nil) { appearance in
            switch appearance.name {
            case .darkAqua,
                 .vibrantDark,
                 .accessibilityHighContrastDarkAqua,
                 .accessibilityHighContrastVibrantDark:
                return NSColor(dark)
            default:
                return NSColor(light)
            }
        })
        #endif
    }
}

// ═════════════════════════════════════════════════════════════
// MARK: — LAYER 1 · Root Palette
// Source: root.json  →  Color.*
// Private — do not use directly in components.
// ═════════════════════════════════════════════════════════════

extension Color {

    // ── BlueGlow (root.json: Color.BlueGlow.*) ────────────────
    static let _vdBlueGlow50  = Color(vdHex: "#dedbfd")
    static let _vdBlueGlow100 = Color(vdHex: "#cec9fc")
    static let _vdBlueGlow200 = Color(vdHex: "#bdb7fb")
    static let _vdBlueGlow300 = Color(vdHex: "#9c92f8")
    static let _vdBlueGlow400 = Color(vdHex: "#7b6ef6")
    static let _vdBlueGlow500 = Color(vdHex: "#5a4af4")
    static let _vdBlueGlow600 = Color(vdHex: "#483bc3")
    static let _vdBlueGlow700 = Color(vdHex: "#362c92")
    static let _vdBlueGlow800 = Color(vdHex: "#1f1a55")
    static let _vdBlueGlow900 = Color(vdHex: "#120f31")

    // ── Ocean (root.json: Color.Ocean.*) ──────────────────────
    static let _vdOcean50  = Color(vdHex: "#e6eff2")
    static let _vdOcean100 = Color(vdHex: "#ccdfe4")
    static let _vdOcean200 = Color(vdHex: "#99bec9")
    static let _vdOcean300 = Color(vdHex: "#669eae")
    static let _vdOcean400 = Color(vdHex: "#337d93")
    static let _vdOcean500 = Color(vdHex: "#005d78")
    static let _vdOcean600 = Color(vdHex: "#004a60")
    static let _vdOcean700 = Color(vdHex: "#003848")
    static let _vdOcean800 = Color(vdHex: "#002530")
    static let _vdOcean900 = Color(vdHex: "#001318")

    // ── Green (root.json: Color.Green.*) ──────────────────────
    static let _vdGreen50  = Color(vdHex: "#e7f3ee")
    static let _vdGreen100 = Color(vdHex: "#cfe7dd")
    static let _vdGreen200 = Color(vdHex: "#9fcfbb")
    static let _vdGreen300 = Color(vdHex: "#6eb799")
    static let _vdGreen400 = Color(vdHex: "#3e9f77")
    static let _vdGreen500 = Color(vdHex: "#0e8755")
    static let _vdGreen600 = Color(vdHex: "#0b6c44")
    static let _vdGreen700 = Color(vdHex: "#085133")
    static let _vdGreen800 = Color(vdHex: "#063622")
    static let _vdGreen900 = Color(vdHex: "#031b11")

    // ── Red (root.json: Color.Red.*) ──────────────────────────
    static let _vdRed50  = Color(vdHex: "#fbe9ea")
    static let _vdRed100 = Color(vdHex: "#f8d2d4")
    static let _vdRed200 = Color(vdHex: "#f0a5a9")
    static let _vdRed300 = Color(vdHex: "#e9787e")
    static let _vdRed400 = Color(vdHex: "#e14b53")
    static let _vdRed500 = Color(vdHex: "#da1e28")
    static let _vdRed600 = Color(vdHex: "#ae1820")
    static let _vdRed700 = Color(vdHex: "#831218")
    static let _vdRed800 = Color(vdHex: "#570c10")
    static let _vdRed900 = Color(vdHex: "#2c0608")

    // ── Orange (root.json: Color.Orange.*) ────────────────────
    static let _vdOrange50  = Color(vdHex: "#fcf0e6")
    static let _vdOrange100 = Color(vdHex: "#f8e0cc")
    static let _vdOrange200 = Color(vdHex: "#f1c299")
    static let _vdOrange300 = Color(vdHex: "#eaa366")
    static let _vdOrange400 = Color(vdHex: "#e38533")
    static let _vdOrange500 = Color(vdHex: "#dc6600")
    static let _vdOrange600 = Color(vdHex: "#b05200")
    static let _vdOrange700 = Color(vdHex: "#843d00")
    static let _vdOrange800 = Color(vdHex: "#582900")
    static let _vdOrange900 = Color(vdHex: "#2c1400")

    // ── Blue (root.json: Color.Blue.*) ────────────────────────
    static let _vdBlue50  = Color(vdHex: "#eaf1fb")
    static let _vdBlue100 = Color(vdHex: "#d6e3f6")
    static let _vdBlue200 = Color(vdHex: "#adc7ee")
    static let _vdBlue300 = Color(vdHex: "#83aae5")
    static let _vdBlue400 = Color(vdHex: "#5a8edd")
    static let _vdBlue500 = Color(vdHex: "#3172d4")
    static let _vdBlue600 = Color(vdHex: "#275baa")
    static let _vdBlue700 = Color(vdHex: "#1d447f")
    static let _vdBlue800 = Color(vdHex: "#142e55")
    static let _vdBlue900 = Color(vdHex: "#0a172a")

    // ── Grey (root.json: Color.Grey.*) ────────────────────────
    static let _vdGrey50  = Color(vdHex: "#f6f5ff")
    static let _vdGrey100 = Color(vdHex: "#e7e6f5")
    static let _vdGrey200 = Color(vdHex: "#d7d5e5")
    static let _vdGrey300 = Color(vdHex: "#A7A4BD")
    static let _vdGrey400 = Color(vdHex: "#797791")
    static let _vdGrey500 = Color(vdHex: "#5a5870")
    static let _vdGrey600 = Color(vdHex: "#48465c")
    static let _vdGrey700 = Color(vdHex: "#323045")
    static let _vdGrey800 = Color(vdHex: "#19172b")
    static let _vdGrey900 = Color(vdHex: "#04021a")

    // ── Opaque Black (root.json: Color.Opaque.Black.*) ────────
    static let _vdOpaqueBlack100  = Color.black.opacity(0.1)
    static let _vdOpaqueBlack200  = Color.black.opacity(0.2)
    static let _vdOpaqueBlack300  = Color.black.opacity(0.3)
    static let _vdOpaqueBlack400  = Color.black.opacity(0.4)
    static let _vdOpaqueBlack500  = Color.black.opacity(0.5)
    static let _vdOpaqueBlack600  = Color.black.opacity(0.6)
    static let _vdOpaqueBlack700  = Color.black.opacity(0.7)
    static let _vdOpaqueBlack800  = Color.black.opacity(0.8)
    static let _vdOpaqueBlack900  = Color.black.opacity(0.9)
    static let _vdOpaqueBlack1000 = Color(vdHex: "#000000")

    // ── Opaque White (root.json: Color.Opaque.White.*) ────────
    static let _vdOpaqueWhite100  = Color.white.opacity(0.1)
    static let _vdOpaqueWhite200  = Color.white.opacity(0.2)
    static let _vdOpaqueWhite300  = Color.white.opacity(0.3)
    static let _vdOpaqueWhite400  = Color.white.opacity(0.4)
    static let _vdOpaqueWhite500  = Color.white.opacity(0.5)
    static let _vdOpaqueWhite600  = Color.white.opacity(0.6)
    static let _vdOpaqueWhite700  = Color.white.opacity(0.7)
    static let _vdOpaqueWhite800  = Color.white.opacity(0.8)
    static let _vdOpaqueWhite900  = Color.white.opacity(0.9)
    static let _vdOpaqueWhite1000 = Color(vdHex: "#ffffff")

    // ── Overlay (root.json: Color.Opaque.Neutral.Overlay) ─────
    // rgba(4, 2, 26, 0.4)
    static let _vdNeutralOverlay = Color(red: 4/255, green: 2/255, blue: 26/255, opacity: 0.4)
}

// ═════════════════════════════════════════════════════════════
// MARK: — LAYER 2 · Brand Colours
// Source: brand.json  →  Color.*
// Maps brand names → root palette shades.
// Private — do not use directly in components.
// ═════════════════════════════════════════════════════════════

extension Color {

    // ── Primary → BlueGlow (brand.json: Color.Primary.*) ──────
    static let _vdPrimary50  = _vdBlueGlow50
    static let _vdPrimary100 = _vdBlueGlow100
    static let _vdPrimary200 = _vdBlueGlow200
    static let _vdPrimary300 = _vdBlueGlow300
    static let _vdPrimary400 = _vdBlueGlow400
    static let _vdPrimary500 = _vdBlueGlow500   
    static let _vdPrimary600 = _vdBlueGlow600
    static let _vdPrimary700 = _vdBlueGlow700
    static let _vdPrimary800 = _vdBlueGlow800
    static let _vdPrimary900 = _vdBlueGlow900

    // ── Success → Green (brand.json: Color.Success.*) ─────────
    static let _vdSuccess50  = _vdGreen50
    static let _vdSuccess100 = _vdGreen100
    static let _vdSuccess200 = _vdGreen200
    static let _vdSuccess300 = _vdGreen300
    static let _vdSuccess400 = _vdGreen400
    static let _vdSuccess500 = _vdGreen500     
    static let _vdSuccess600 = _vdGreen600
    static let _vdSuccess700 = _vdGreen700
    static let _vdSuccess800 = _vdGreen800
    static let _vdSuccess900 = _vdGreen900

    // ── Error → Red (brand.json: Color.Error.*) ───────────────
    static let _vdError50  = _vdRed50
    static let _vdError100 = _vdRed100
    static let _vdError200 = _vdRed200
    static let _vdError300 = _vdRed300
    static let _vdError400 = _vdRed400
    static let _vdError500 = _vdRed500
    static let _vdError600 = _vdRed600
    static let _vdError700 = _vdRed700
    static let _vdError800 = _vdRed800
    static let _vdError900 = _vdRed900

    // ── Warning → Orange (brand.json: Color.Warning.*) ────────
    static let _vdWarning50  = _vdOrange50
    static let _vdWarning100 = _vdOrange100
    static let _vdWarning200 = _vdOrange200
    static let _vdWarning300 = _vdOrange300
    static let _vdWarning400 = _vdOrange400
    static let _vdWarning500 = _vdOrange500     
    static let _vdWarning600 = _vdOrange600
    static let _vdWarning700 = _vdOrange700
    static let _vdWarning800 = _vdOrange800
    static let _vdWarning900 = _vdOrange900

    // ── Info → Blue (brand.json: Color.Info.*) ────────────────
    static let _vdInfo50  = _vdBlue50
    static let _vdInfo100 = _vdBlue100
    static let _vdInfo200 = _vdBlue200
    static let _vdInfo300 = _vdBlue300
    static let _vdInfo400 = _vdBlue400
    static let _vdInfo500 = _vdBlue500         
    static let _vdInfo600 = _vdBlue600
    static let _vdInfo700 = _vdBlue700
    static let _vdInfo800 = _vdBlue800
    static let _vdInfo900 = _vdBlue900

    // ── Neutral → Grey (brand.json: Color.Neutral.*) ──────────
    static let _vdNeutral50  = _vdGrey50
    static let _vdNeutral100 = _vdGrey100
    static let _vdNeutral200 = _vdGrey200
    static let _vdNeutral300 = _vdGrey300
    static let _vdNeutral400 = _vdGrey400
    static let _vdNeutral500 = _vdGrey500
    static let _vdNeutral600 = _vdGrey600
    static let _vdNeutral700 = _vdGrey700
    static let _vdNeutral800 = _vdGrey800
    static let _vdNeutral900 = _vdGrey900

    // ── White / Black / Overlay ───────────────────────────────
    static let _vdWhite1000  = _vdOpaqueWhite1000   
    static let _vdBlack1000  = _vdOpaqueBlack1000  
    static let _vdOverlayRaw = _vdNeutralOverlay     
}

// ═════════════════════════════════════════════════════════════
// MARK: — LAYER 3 · Semantic Tokens  ← USE THESE IN COMPONENTS
//
// Every token is Color(light:dark:) resolved from:
//   light.json  (Color.Content|Background|Border.*)
//   dark.json   (same keys, different shade references)
//
// Token path shown as comment on every property.
// Format: vd<Type><Semantic><Variant>
// ═════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────
// MARK: Content tokens  (Text + Icon unified)
// ─────────────────────────────────────────────────────────────

public extension Color {

    // ── Content · Default ─────────────────────────────────────

    /// Content/Default/Base  · light: Neutral.900 · dark: Neutral.50
    static let vdContentDefaultBase = Color(
        light: _vdNeutral900,   
        dark:  _vdNeutral50    
    )

    /// Content/Default/Secondary  · light: Neutral.600 · dark: Neutral.300
    static let vdContentDefaultSecondary = Color(
        light: _vdNeutral600,  
        dark:  _vdNeutral300   
    )

    /// Content/Default/Tertiary  · light: Neutral.500 · dark: Neutral.400
    static let vdContentDefaultTertiary = Color(
        light: _vdNeutral500,  
        dark:  _vdNeutral400   
    )

    /// Content/Default/Disabled  · light: Neutral.400 · dark: Neutral.500
    static let vdContentDefaultDisabled = Color(
        light: _vdNeutral400,   
        dark:  _vdNeutral500    
    )

    /// Content/Default/AlwaysLight — never inverts
    static let vdContentDefaultAlwaysLight = _vdNeutral50    

    /// Content/Default/AlwaysDark — never inverts
    static let vdContentDefaultAlwaysDark  = _vdNeutral900  

    // ── Content · Primary ─────────────────────────────────────

    /// Content/Primary/Base  · light: Primary.500 · dark: Primary.400
    static let vdContentPrimaryBase = Color(
        light: _vdPrimary500,   
        dark:  _vdPrimary400    
    )

    /// Content/Primary/BaseInverted  · light: Primary.400 · dark: Primary.500
    static let vdContentPrimaryBaseInverted = Color(
        light: _vdPrimary400,
        dark:  _vdPrimary500
    )

    /// Content/Primary/Secondary  · light: Primary.600 · dark: Primary.300
    static let vdContentPrimarySecondary = Color(
        light: _vdPrimary600,   
        dark:  _vdPrimary300   
    )

    /// Content/Primary/Tertiary  · light: Primary.700 · dark: Primary.200
    static let vdContentPrimaryTertiary = Color(
        light: _vdPrimary700,   
        dark:  _vdPrimary200    
    )

    /// Content/Primary/OnBase  · light: Primary.50 · dark: Primary.900
    static let vdContentPrimaryOnBase = Color(
        light: _vdPrimary50,    
        dark:  _vdPrimary900    
    )

    /// Content/Primary/OnSecondary  · light: Primary.700 · dark: Primary.200
    static let vdContentPrimaryOnSecondary = Color(
        light: _vdPrimary700,   
        dark:  _vdPrimary200   
    )

    /// Content/Primary/OnTertiary  · light: Primary.200 · dark: Primary.700
    static let vdContentPrimaryOnTertiary = Color(
        light: _vdPrimary200,  
        dark:  _vdPrimary700    
    )

    // ── Content · Success ─────────────────────────────────────

    /// Content/Success/Base  · light: Success.500 · dark: Success.400
    static let vdContentSuccessBase = Color(
        light: _vdSuccess500,   
        dark:  _vdSuccess400   
    )

    /// Content/Success/Secondary  · light: Success.600 · dark: Success.300
    static let vdContentSuccessSecondary = Color(
        light: _vdSuccess600,   
        dark:  _vdSuccess300    
    )

    /// Content/Success/Tertiary  · light: Success.700 · dark: Success.100
    static let vdContentSuccessTertiary = Color(
        light: _vdSuccess700, 
        dark:  _vdSuccess100   
    )

    /// Content/Success/OnBase  · light: Success.50 · dark: Success.900
    static let vdContentSuccessOnBase = Color(
        light: _vdSuccess50,   
        dark:  _vdSuccess900   
    )

    /// Content/Success/OnSecondary  · light: Success.700 · dark: Success.200
    static let vdContentSuccessOnSecondary = Color(
        light: _vdSuccess700,   
        dark:  _vdSuccess200   
    )

    /// Content/Success/OnTertiary  · light: Success.200 · dark: Success.700
    static let vdContentSuccessOnTertiary = Color(
        light: _vdSuccess200,  
        dark:  _vdSuccess700    
    )

    // ── Content · Error ───────────────────────────────────────

    /// Content/Error/Base  · light: Error.500 · dark: Error.400
    static let vdContentErrorBase = Color(
        light: _vdError500,    
        dark:  _vdError400     
    )

    /// Content/Error/Secondary  · light: Error.600 · dark: Error.300
    static let vdContentErrorSecondary = Color(
        light: _vdError600,     
        dark:  _vdError300      
    )

    /// Content/Error/Tertiary  · light: Error.700 · dark: Error.100
    static let vdContentErrorTertiary = Color(
        light: _vdError700,     
        dark:  _vdError100     
    )

    /// Content/Error/OnBase  · light: Error.50 · dark: Error.900
    static let vdContentErrorOnBase = Color(
        light: _vdError50,     
        dark:  _vdError900    
    )

    /// Content/Error/OnSecondary  · light: Error.700 · dark: Error.200
    static let vdContentErrorOnSecondary = Color(
        light: _vdError700,    
        dark:  _vdError200    
    )

    /// Content/Error/OnTertiary  · light: Error.200 · dark: Error.700
    static let vdContentErrorOnTertiary = Color(
        light: _vdError200,     
        dark:  _vdError700     
    )

    // ── Content · Warning ─────────────────────────────────────

    /// Content/Warning/Base  · light: Warning.500 · dark: Warning.400
    static let vdContentWarningBase = Color(
        light: _vdWarning500,   
        dark:  _vdWarning400    
    )

    /// Content/Warning/Secondary  · light: Warning.600 · dark: Warning.300
    static let vdContentWarningSecondary = Color(
        light: _vdWarning600,   
        dark:  _vdWarning300   
    )

    /// Content/Warning/Tertiary  · light: Warning.700 · dark: Warning.100
    static let vdContentWarningTertiary = Color(
        light: _vdWarning700,  
        dark:  _vdWarning100    
    )

    /// Content/Warning/OnBase  · light: Warning.50 · dark: Warning.900
    static let vdContentWarningOnBase = Color(
        light: _vdWarning50,   
        dark:  _vdWarning900   
    )

    /// Content/Warning/OnSecondary  · light: Warning.700 · dark: Warning.200
    static let vdContentWarningOnSecondary = Color(
        light: _vdWarning700,   
        dark:  _vdWarning200   
    )

    /// Content/Warning/OnTertiary  · light: Warning.200 · dark: Warning.700
    static let vdContentWarningOnTertiary = Color(
        light: _vdWarning200,   
        dark:  _vdWarning700   
    )

    // ── Content · Info ────────────────────────────────────────

    /// Content/Info/Base  · light: Info.500 · dark: Info.400
    static let vdContentInfoBase = Color(
        light: _vdInfo500,     
        dark:  _vdInfo400       
    )

    /// Content/Info/Secondary  · light: Info.600 · dark: Info.300
    static let vdContentInfoSecondary = Color(
        light: _vdInfo600,      
        dark:  _vdInfo300       
    )

    /// Content/Info/Tertiary  · light: Info.700 · dark: Info.100
    static let vdContentInfoTertiary = Color(
        light: _vdInfo700,     
        dark:  _vdInfo100      
    )

    /// Content/Info/OnBase  · light: Info.50 · dark: Info.900
    static let vdContentInfoOnBase = Color(
        light: _vdInfo50,      
        dark:  _vdInfo900       
    )

    /// Content/Info/OnSecondary  · light: Info.700 · dark: Info.200
    static let vdContentInfoOnSecondary = Color(
        light: _vdInfo700,      
        dark:  _vdInfo200      
    )

    /// Content/Info/OnTertiary  · light: Info.200 · dark: Info.700
    static let vdContentInfoOnTertiary = Color(
        light: _vdInfo200,     
        dark:  _vdInfo700      
    )

    // ── Content · Neutral ─────────────────────────────────────

    /// Content/Neutral/Base  · light: Neutral.600 · dark: Neutral.400
    static let vdContentNeutralBase = Color(
        light: _vdNeutral600,   
        dark:  _vdNeutral400    
    )

    /// Content/Neutral/Secondary  · light: Neutral.700 · dark: Neutral.300
    static let vdContentNeutralSecondary = Color(
        light: _vdNeutral700,   
        dark:  _vdNeutral300    
    )

    /// Content/Neutral/Tertiary  · light: Neutral.800 · dark: Neutral.100
    static let vdContentNeutralTertiary = Color(
        light: _vdNeutral800,  
        dark:  _vdNeutral100   
    )

    /// Content/Neutral/OnBase  · light: Neutral.50 · dark: Neutral.900
    static let vdContentNeutralOnBase = Color(
        light: _vdNeutral50,    
        dark:  _vdNeutral900   
    )

    /// Content/Neutral/OnSecondary  · light: Neutral.700 · dark: Neutral.100
    static let vdContentNeutralOnSecondary = Color(
        light: _vdNeutral700,   
        dark:  _vdNeutral100    
    )

    /// Content/Neutral/OnTertiary  · light: Neutral.100 · dark: Neutral.700
    static let vdContentNeutralOnTertiary = Color(
        light: _vdNeutral100,   
        dark:  _vdNeutral700    
    )
}

// ─────────────────────────────────────────────────────────────
// MARK: Background tokens
// ─────────────────────────────────────────────────────────────

public extension Color {

    // ── Background · Default ──────────────────────────────────

    /// Background/Default/Base — page/screen background
    /// light: Neutral.100 · dark: Neutral.900
    static let vdBackgroundDefaultBase = Color(
        light: _vdNeutral100,
        dark:  _vdNeutral900
    )

    /// Background/Default/Secondary — card / surface
    /// light: White.1000 · dark: Neutral.800
    static let vdBackgroundDefaultSecondary = Color(
        light: _vdWhite1000,
        dark:  _vdNeutral800
    )

    /// Background/Default/Tertiary — raised secondary surface
    /// light: Neutral.200 · dark: Neutral.700
    static let vdBackgroundDefaultTertiary = Color(
        light: _vdNeutral200,
        dark:  _vdNeutral700
    )

    /// Background/Default/Disabled
    /// light: Neutral.200 · dark: Neutral.700
    static let vdBackgroundDefaultDisabled = Color(
        light: _vdNeutral200,
        dark:  _vdNeutral700
    )

    /// Background/Default/AlwaysLight — stays light in both modes
    static let vdBackgroundDefaultAlwaysLight = _vdWhite1000

    /// Background/Default/AlwaysDark — stays dark in both modes
    static let vdBackgroundDefaultAlwaysDark  = _vdNeutral900

    // ── Background · Primary ──────────────────────────────────

    /// Background/Primary/Base — filled brand button/badge
    /// light: Primary.500 · dark: Primary.400
    static let vdBackgroundPrimaryBase = Color(
        light: _vdPrimary500,
        dark:  _vdPrimary400
    )

    /// Background/Primary/BaseHover
    /// light: Primary.600 · dark: Primary.300
    static let vdBackgroundPrimaryBaseHover = Color(
        light: _vdPrimary600,
        dark:  _vdPrimary300
    )

    /// Background/Primary/Secondary — subtle brand tint
    /// light: Primary.100 · dark: Primary.800
    static let vdBackgroundPrimarySecondary = Color(
        light: _vdPrimary100,
        dark:  _vdPrimary800
    )

    /// Background/Primary/SecondaryHover
    /// light: Primary.200 · dark: Primary.700
    static let vdBackgroundPrimarySecondaryHover = Color(
        light: _vdPrimary200,
        dark:  _vdPrimary700
    )

    /// Background/Primary/Tertiary — dark/inverse brand fill
    /// light: Primary.800 · dark: Primary.100
    static let vdBackgroundPrimaryTertiary = Color(
        light: _vdPrimary800,
        dark:  _vdPrimary100
    )

    /// Background/Primary/TertiaryHover
    /// light: Primary.700 · dark: Primary.200
    static let vdBackgroundPrimaryTertiaryHover = Color(
        light: _vdPrimary700,
        dark:  _vdPrimary200
    )

    // ── Background · Success ──────────────────────────────────

    /// Background/Success/Base  · light: Success.500 · dark: Success.400
    static let vdBackgroundSuccessBase = Color(
        light: _vdSuccess500,
        dark:  _vdSuccess400
    )

    /// Background/Success/BaseHover  · light: Success.600 · dark: Success.300
    static let vdBackgroundSuccessBaseHover = Color(
        light: _vdSuccess600,
        dark:  _vdSuccess300
    )

    /// Background/Success/Secondary  · light: Success.100 · dark: Success.800
    static let vdBackgroundSuccessSecondary = Color(
        light: _vdSuccess100,
        dark:  _vdSuccess800
    )

    /// Background/Success/SecondaryHover  · light: Success.200 · dark: Success.700
    static let vdBackgroundSuccessSecondaryHover = Color(
        light: _vdSuccess200,
        dark:  _vdSuccess700
    )

    /// Background/Success/Tertiary  · light: Success.800 · dark: Success.100
    static let vdBackgroundSuccessTertiary = Color(
        light: _vdSuccess800,
        dark:  _vdSuccess100
    )

    /// Background/Success/TertiaryHover  · light: Success.700 · dark: Success.200
    static let vdBackgroundSuccessTertiaryHover = Color(
        light: _vdSuccess700,
        dark:  _vdSuccess200
    )

    // ── Background · Error ────────────────────────────────────

    /// Background/Error/Base  · light: Error.500 · dark: Error.400
    static let vdBackgroundErrorBase = Color(
        light: _vdError500,
        dark:  _vdError400
    )

    /// Background/Error/BaseHover  · light: Error.600 · dark: Error.300
    static let vdBackgroundErrorBaseHover = Color(
        light: _vdError600,
        dark:  _vdError300
    )

    /// Background/Error/Secondary  · light: Error.100 · dark: Error.800
    static let vdBackgroundErrorSecondary = Color(
        light: _vdError100,
        dark:  _vdError800
    )

    /// Background/Error/SecondaryHover  · light: Error.200 · dark: Error.700
    static let vdBackgroundErrorSecondaryHover = Color(
        light: _vdError200,
        dark:  _vdError700
    )

    /// Background/Error/Tertiary  · light: Error.800 · dark: Error.100
    static let vdBackgroundErrorTertiary = Color(
        light: _vdError800,
        dark:  _vdError100
    )

    /// Background/Error/TertiaryHover  · light: Error.700 · dark: Error.200
    static let vdBackgroundErrorTertiaryHover = Color(
        light: _vdError700,
        dark:  _vdError200
    )

    // ── Background · Warning ──────────────────────────────────

    /// Background/Warning/Base  · light: Warning.500 · dark: Warning.400
    static let vdBackgroundWarningBase = Color(
        light: _vdWarning500,
        dark:  _vdWarning400
    )

    /// Background/Warning/BaseHover  · light: Warning.600 · dark: Warning.300
    static let vdBackgroundWarningBaseHover = Color(
        light: _vdWarning600,
        dark:  _vdWarning300
    )

    /// Background/Warning/Secondary  · light: Warning.100 · dark: Warning.800
    static let vdBackgroundWarningSecondary = Color(
        light: _vdWarning100,
        dark:  _vdWarning800
    )

    /// Background/Warning/SecondaryHover  · light: Warning.200 · dark: Warning.700
    static let vdBackgroundWarningSecondaryHover = Color(
        light: _vdWarning200,
        dark:  _vdWarning700
    )

    /// Background/Warning/Tertiary  · light: Warning.800 · dark: Warning.100
    static let vdBackgroundWarningTertiary = Color(
        light: _vdWarning800,
        dark:  _vdWarning100
    )

    /// Background/Warning/TertiaryHover  · light: Warning.700 · dark: Warning.200
    static let vdBackgroundWarningTertiaryHover = Color(
        light: _vdWarning700,
        dark:  _vdWarning200
    )

    // ── Background · Info ─────────────────────────────────────

    /// Background/Info/Base  · light: Info.500 · dark: Info.400
    static let vdBackgroundInfoBase = Color(
        light: _vdInfo500,
        dark:  _vdInfo400
    )

    /// Background/Info/BaseHover  · light: Info.600 · dark: Info.300
    static let vdBackgroundInfoBaseHover = Color(
        light: _vdInfo600,
        dark:  _vdInfo300
    )

    /// Background/Info/Secondary  · light: Info.100 · dark: Info.800
    static let vdBackgroundInfoSecondary = Color(
        light: _vdInfo100,
        dark:  _vdInfo800
    )

    /// Background/Info/SecondaryHover  · light: Info.200 · dark: Info.700
    static let vdBackgroundInfoSecondaryHover = Color(
        light: _vdInfo200,
        dark:  _vdInfo700
    )

    /// Background/Info/Tertiary  · light: Info.800 · dark: Info.100
    static let vdBackgroundInfoTertiary = Color(
        light: _vdInfo800,
        dark:  _vdInfo100
    )

    /// Background/Info/TertiaryHover  · light: Info.700 · dark: Info.200
    static let vdBackgroundInfoTertiaryHover = Color(
        light: _vdInfo700,
        dark:  _vdInfo200
    )

    // ── Background · Neutral ──────────────────────────────────

    /// Background/Neutral/Base  · light: Neutral.500 · dark: Neutral.400
    static let vdBackgroundNeutralBase = Color(
        light: _vdNeutral500,
        dark:  _vdNeutral400
    )

    /// Background/Neutral/BaseHover  · light: Neutral.600 · dark: Neutral.300
    static let vdBackgroundNeutralBaseHover = Color(
        light: _vdNeutral600,
        dark:  _vdNeutral300
    )

    /// Background/Neutral/Secondary  · light: Neutral.200 · dark: Neutral.800
    static let vdBackgroundNeutralSecondary = Color(
        light: _vdNeutral200,
        dark:  _vdNeutral800
    )

    /// Background/Neutral/SecondaryHover  · light: Neutral.300 · dark: Neutral.700
    static let vdBackgroundNeutralSecondaryHover = Color(
        light: _vdNeutral300,
        dark:  _vdNeutral700
    )

    /// Background/Neutral/Tertiary  · light: Neutral.800 · dark: Neutral.200
    static let vdBackgroundNeutralTertiary = Color(
        light: _vdNeutral800,
        dark:  _vdNeutral200
    )

    /// Background/Neutral/TertiaryHover  · light: Neutral.700 · dark: Neutral.300
    static let vdBackgroundNeutralTertiaryHover = Color(
        light: _vdNeutral700,
        dark:  _vdNeutral300
    )

    // ── Background · Overlay ──────────────────────────────────

    /// Background/Overlay/Base — same in both modes
    /// rgba(4, 2, 26, 0.4)
    static let vdBackgroundOverlayBase = _vdOverlayRaw
}

// ─────────────────────────────────────────────────────────────
// MARK: Border tokens
// ─────────────────────────────────────────────────────────────

public extension Color {

    // ── Border · Default ──────────────────────────────────────

    /// Border/Default/Base  · light: Neutral.500 · dark: Neutral.500
    static let vdBorderDefaultBase = Color(
        light: _vdNeutral500,
        dark:  _vdNeutral500
    )

    /// Border/Default/Secondary  · light: Neutral.400 · dark: Neutral.600
    static let vdBorderDefaultSecondary = Color(
        light: _vdNeutral400,
        dark:  _vdNeutral600
    )

    /// Border/Default/Tertiary  · light: Neutral.300 · dark: Neutral.700
    static let vdBorderDefaultTertiary = Color(
        light: _vdNeutral300,
        dark:  _vdNeutral700
    )

    /// Border/Default/Disabled  · light: Neutral.300 · dark: Neutral.700
    static let vdBorderDefaultDisabled = Color(
        light: _vdNeutral300,
        dark:  _vdNeutral700
    )

    // ── Border · Primary ──────────────────────────────────────

    /// Border/Primary/Base  · light: Primary.500 · dark: Primary.400
    static let vdBorderPrimaryBase = Color(
        light: _vdPrimary500,
        dark:  _vdPrimary400
    )

    /// Border/Primary/Secondary  · light: Primary.700 · dark: Primary.300
    static let vdBorderPrimarySecondary = Color(
        light: _vdPrimary700,
        dark:  _vdPrimary300
    )

    /// Border/Primary/Tertiary  · light: Primary.300 · dark: Primary.700
    static let vdBorderPrimaryTertiary = Color(
        light: _vdPrimary300,
        dark:  _vdPrimary700
    )

    // ── Border · Success ──────────────────────────────────────

    /// Border/Success/Base  · light: Success.500 · dark: Success.400
    static let vdBorderSuccessBase = Color(
        light: _vdSuccess500,
        dark:  _vdSuccess400
    )

    /// Border/Success/Secondary  · light: Success.700 · dark: Success.300
    static let vdBorderSuccessSecondary = Color(
        light: _vdSuccess700,
        dark:  _vdSuccess300
    )

    /// Border/Success/Tertiary  · light: Success.300 · dark: Success.700
    static let vdBorderSuccessTertiary = Color(
        light: _vdSuccess300,
        dark:  _vdSuccess700
    )

    // ── Border · Error ────────────────────────────────────────

    /// Border/Error/Base  · light: Error.500 · dark: Error.400
    static let vdBorderErrorBase = Color(
        light: _vdError500,
        dark:  _vdError400
    )

    /// Border/Error/Secondary  · light: Error.700 · dark: Error.300
    static let vdBorderErrorSecondary = Color(
        light: _vdError700,
        dark:  _vdError300
    )

    /// Border/Error/Tertiary  · light: Error.300 · dark: Error.700
    static let vdBorderErrorTertiary = Color(
        light: _vdError300,
        dark:  _vdError700
    )

    // ── Border · Warning ──────────────────────────────────────

    /// Border/Warning/Base  · light: Warning.500 · dark: Warning.400
    static let vdBorderWarningBase = Color(
        light: _vdWarning500,
        dark:  _vdWarning400
    )

    /// Border/Warning/Secondary  · light: Warning.700 · dark: Warning.300
    static let vdBorderWarningSecondary = Color(
        light: _vdWarning700,
        dark:  _vdWarning300
    )

    /// Border/Warning/Tertiary  · light: Warning.300 · dark: Warning.700
    static let vdBorderWarningTertiary = Color(
        light: _vdWarning300,
        dark:  _vdWarning700
    )

    // ── Border · Info ─────────────────────────────────────────

    /// Border/Info/Base  · light: Info.500 · dark: Info.400
    static let vdBorderInfoBase = Color(
        light: _vdInfo500,
        dark:  _vdInfo400
    )

    /// Border/Info/Secondary  · light: Info.700 · dark: Info.300
    static let vdBorderInfoSecondary = Color(
        light: _vdInfo700,
        dark:  _vdInfo300
    )

    /// Border/Info/Tertiary  · light: Info.300 · dark: Info.700
    static let vdBorderInfoTertiary = Color(
        light: _vdInfo300,
        dark:  _vdInfo700
    )

    // ── Border · Neutral ──────────────────────────────────────

    /// Border/Neutral/Base  · light: Neutral.500 · dark: Neutral.400
    static let vdBorderNeutralBase = Color(
        light: _vdNeutral500,
        dark:  _vdNeutral400
    )

    /// Border/Neutral/Secondary  · light: Neutral.700 · dark: Neutral.300
    static let vdBorderNeutralSecondary = Color(
        light: _vdNeutral700,
        dark:  _vdNeutral300
    )

    /// Border/Neutral/Tertiary  · light: Neutral.400 · dark: Neutral.700
    static let vdBorderNeutralTertiary = Color(
        light: _vdNeutral400,
        dark:  _vdNeutral700
    )
}
