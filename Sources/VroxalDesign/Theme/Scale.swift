// Theme/Scale.swift — Vroxal Design
// ─────────────────────────────────────────────────────────────
// SOURCE OF TRUTH: root.json → Scale.*  +  brand.json → Scale.*
//
// TWO-LAYER ARCHITECTURE
// ──────────────────────
// LAYER 1 · Raw Scale   (private)
//   Direct values from root.json Scale.*.
//   The brand.json Scale.* tokens are pure 1:1 pass-throughs
//   with no transformation, so the brand layer adds no value
//   and is intentionally omitted here.
//
// LAYER 2 · Public API  (public)
//   VdSpacing     — Scale.Spacing.*   (padding, gaps)
//   VdRadius      — Scale.Border.Radius.*
//   VdBorderWidth — Scale.Border.Width.*
//   VdIconSize    — Scale.Icon.Size.*
//
// Usage in components:
//   .padding(VdSpacing.md)                          // 16 pt
//   .clipShape(RoundedRectangle(cornerRadius: VdRadius.lg))  // 16 pt
//   .strokeBorder(color, lineWidth: VdBorderWidth.sm)        //  1 pt
//   .font(.system(size: VdIconSize.md))             // 24 pt
// ─────────────────────────────────────────────────────────────

import CoreGraphics

// ═════════════════════════════════════════════════════════════
// MARK: — LAYER 1 · Raw Scale  (private)
// Source: root.json → Scale.*
// ═════════════════════════════════════════════════════════════

private enum _VdScale {
    static let s0:    CGFloat =   0   // Scale.0
    static let s25:   CGFloat =   1   // Scale.25
    static let s50:   CGFloat =   2   // Scale.50
    static let s100:  CGFloat =   4   // Scale.100
    static let s200:  CGFloat =   8   // Scale.200
    static let s300:  CGFloat =  12   // Scale.300
    static let s400:  CGFloat =  16   // Scale.400
    static let s500:  CGFloat =  20   // Scale.500
    static let s600:  CGFloat =  24   // Scale.600
    static let s800:  CGFloat =  32   // Scale.800
    static let s1000: CGFloat =  40   // Scale.1000
    static let s1200: CGFloat =  48   // Scale.1200
    static let s1600: CGFloat =  64   // Scale.1600
    static let s1800: CGFloat =  80   // Scale.1800
    static let s2400: CGFloat =  96   // Scale.2400
    static let s3000: CGFloat = 120   // Scale.3000

    // Negative steps
    static let sNeg50:  CGFloat =  -2   // Scale.Negative50
    static let sNeg100: CGFloat =  -4   // Scale.Negative100
    static let sNeg200: CGFloat =  -8   // Scale.Negative200
    static let sNeg300: CGFloat = -12   // Scale.Negative300
    static let sNeg400: CGFloat = -16   // Scale.Negative400
    static let sNeg600: CGFloat = -24   // Scale.Negative600
}

// ═════════════════════════════════════════════════════════════
// MARK: — LAYER 2 · Public API  ← USE THESE IN COMPONENTS
// ═════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────
// MARK: VdSpacing  (Scale.Spacing.*)
// ─────────────────────────────────────────────────────────────

public enum VdSpacing {

    // ── Numeric tokens — match Figma Scale.Spacing.* exactly ──

    public static let s0:    CGFloat = _VdScale.s0     //   0 pt
    public static let s50:   CGFloat = _VdScale.s50    //   2 pt
    public static let s100:  CGFloat = _VdScale.s100   //   4 pt
    public static let s200:  CGFloat = _VdScale.s200   //   8 pt
    public static let s300:  CGFloat = _VdScale.s300   //  12 pt
    public static let s400:  CGFloat = _VdScale.s400   //  16 pt
    public static let s600:  CGFloat = _VdScale.s600   //  24 pt
    public static let s800:  CGFloat = _VdScale.s800   //  32 pt
    public static let s1000: CGFloat = _VdScale.s1000  //  40 pt
    public static let s1200: CGFloat = _VdScale.s1200  //  48 pt
    public static let s1600: CGFloat = _VdScale.s1600  //  64 pt
    public static let s1800: CGFloat = _VdScale.s1800  //  80 pt
    public static let s2400: CGFloat = _VdScale.s2400  //  96 pt
    public static let s3000: CGFloat = _VdScale.s3000  // 120 pt

    // ── Negative tokens ───────────────────────────────────────

    public static let neg50:  CGFloat = _VdScale.sNeg50   //  -2 pt
    public static let neg100: CGFloat = _VdScale.sNeg100  //  -4 pt
    public static let neg200: CGFloat = _VdScale.sNeg200  //  -8 pt
    public static let neg300: CGFloat = _VdScale.sNeg300  // -12 pt
    public static let neg400: CGFloat = _VdScale.sNeg400  // -16 pt
    public static let neg600: CGFloat = _VdScale.sNeg600  // -24 pt

    // ── Friendly aliases — use these in component code ────────

    public static let none: CGFloat = s0      //   0 pt
    public static let xxs:  CGFloat = s50     //   2 pt
    public static let xs:   CGFloat = s100    //   4 pt
    public static let sm:   CGFloat = s200    //   8 pt
    public static let smMd: CGFloat = s300    //  12 pt
    public static let md:   CGFloat = s400    //  16 pt  ← default padding
    public static let lg:   CGFloat = s600    //  24 pt  ← section/card gap
    public static let xl:   CGFloat = s800    //  32 pt
    public static let xxl:  CGFloat = s1000   //  40 pt
    public static let xxxl: CGFloat = s1200   //  48 pt
    public static let huge: CGFloat = s1600   //  64 pt
}

// ─────────────────────────────────────────────────────────────
// MARK: VdRadius  (Scale.Border.Radius.*)
// ─────────────────────────────────────────────────────────────

public enum VdRadius {
    public static let none: CGFloat = _VdScale.s0     //   0 pt
    public static let xs:   CGFloat = _VdScale.s100   //   4 pt
    public static let sm:   CGFloat = _VdScale.s200   //   8 pt
    public static let md:   CGFloat = _VdScale.s300   //  12 pt
    public static let lg:   CGFloat = _VdScale.s400   //  16 pt
    public static let xl:   CGFloat = _VdScale.s600   //  24 pt
    public static let xxl:  CGFloat = _VdScale.s800   //  32 pt
    public static let xxxl: CGFloat = _VdScale.s1000  //  40 pt
    public static let full: CGFloat = _VdScale.s3000  // 120 pt — pill / circle
}

// ─────────────────────────────────────────────────────────────
// MARK: VdBorderWidth  (Scale.Border.Width.*)
//
// Note: 'none' resolves to Scale.0 (0 pt). 'sm' resolves to
// Scale.25 (1 pt).
// ─────────────────────────────────────────────────────────────

public enum VdBorderWidth {
    public static let none: CGFloat = _VdScale.s0   //  0 pt  (Scale.0)
    public static let sm:   CGFloat = _VdScale.s25   //  1 pt  (Scale.25)
    public static let md:   CGFloat = _VdScale.s50   //  2 pt  — focus ring
    public static let lg:   CGFloat = _VdScale.s100  //  4 pt
    public static let xl:   CGFloat = _VdScale.s200  //  8 pt
}

// ─────────────────────────────────────────────────────────────
// MARK: VdIconSize  (Scale.Icon.Size.*)
// ─────────────────────────────────────────────────────────────

public enum VdIconSize {
    public static let xs: CGFloat = _VdScale.s400   //  16 pt
    public static let sm: CGFloat = _VdScale.s500   //  20 pt
    public static let md: CGFloat = _VdScale.s600   //  24 pt  ← default
    public static let lg: CGFloat = _VdScale.s800   //  32 pt
    public static let xl: CGFloat = _VdScale.s1000  //  40 pt
}
