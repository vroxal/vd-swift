# Icons

This folder is optional for raw/source icon files.

Runtime icons should be added inside:

- `Sources/VroxalDesign/Resources/Assets.xcassets`

Each icon should be an image set, for example:

- `ic_home.imageset`
- `ic_profile.imageset`

Usage from the package (SwiftUI):

```swift
Image("ic_home", bundle: .module)
```
