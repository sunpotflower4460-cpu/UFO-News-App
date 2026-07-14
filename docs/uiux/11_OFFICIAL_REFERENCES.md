# Official Apple References and Current Constraints

Checked: 2026-07-14

This file records the primary Apple sources behind the blueprint. Re-check all submission requirements immediately before release because platform rules and asset specifications can change.

## Human Interface Guidelines

- Human Interface Guidelines  
  https://developer.apple.com/design/human-interface-guidelines

- Materials / Liquid Glass  
  https://developer.apple.com/design/human-interface-guidelines/materials  
  Key principle: Liquid Glass forms a distinct functional layer for controls and navigation above content.

- Tab bars  
  https://developer.apple.com/design/human-interface-guidelines/tab-bars

- Accessibility  
  https://developer.apple.com/design/human-interface-guidelines/accessibility

- Motion  
  https://developer.apple.com/design/human-interface-guidelines/motion

- Playing haptics  
  https://developer.apple.com/design/human-interface-guidelines/playing-haptics

- Color  
  https://developer.apple.com/design/human-interface-guidelines/color

- Dark Mode  
  https://developer.apple.com/design/human-interface-guidelines/dark-mode

- Layout  
  https://developer.apple.com/design/human-interface-guidelines/layout

- Maps  
  https://developer.apple.com/design/human-interface-guidelines/maps

- Searching  
  https://developer.apple.com/design/human-interface-guidelines/searching

- Sheets  
  https://developer.apple.com/design/human-interface-guidelines/sheets

- Widgets  
  https://developer.apple.com/design/human-interface-guidelines/widgets

- SF Symbols  
  https://developer.apple.com/design/human-interface-guidelines/sf-symbols

## Liquid Glass and design resources

- Meet Liquid Glass  
  https://developer.apple.com/videos/play/wwdc2025/219/

- Applying Liquid Glass to custom SwiftUI views  
  https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views

- Apple Design Resources / Icon Composer  
  https://developer.apple.com/design/resources/  
  Icon Composer supports layered icon workflows and appearance modes.

## Apple Design Awards 2026

- 2026 winners and finalists  
  https://developer.apple.com/design/awards/

Relevant official observations:

- Moonlitt: praised for broad platform support, onboarding, intuitive interaction, and Liquid Glass integration.
- Tide Guide: praised for clear full-screen data visualization, custom animation, widgets, and time-of-day palette.
- Primary: praised for avoiding sensationalism/clickbait and keeping a minimal UI out of the news’s way.
- Guitar Wiz: praised for VoiceOver, Dynamic Type, Increased Contrast, and Differentiate Without Color.
- Structured: praised for a visually sharp, easy-to-scan, simple layout.

These apps are references for principles, not templates to copy.

## App Store submission and product page

- App Store Connect overview  
  https://developer.apple.com/app-store-connect/  
  Current page states that developers can upload up to 10 screenshots and three app previews for each supported localization.

- Product Page Optimization  
  https://developer.apple.com/app-store/product-page-optimization/

- Creating Your Product Page  
  https://developer.apple.com/app-store/product-page/

- App previews  
  https://developer.apple.com/app-store/app-previews/  
  Current guidance: up to three previews per language; each preview up to 30 seconds and based on on-device footage.

- Screenshot specifications  
  https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/  
  Use the current specification at export/submission time rather than freezing dimensions in product code or design docs.

## Current SDK minimum

Apple Developer News, “Upcoming SDK minimum requirements”:

https://developer.apple.com/news/

As of April 28, 2026, iOS and iPadOS apps uploaded to App Store Connect must be built with the iOS 26 and iPadOS 26 SDK or later. Re-check this requirement at submission time.

## App Review, privacy, and account behavior

- App Review Guidelines  
  https://developer.apple.com/app-store/review/guidelines/

Relevant current requirements include:

- an accessible privacy policy in App Store Connect metadata and inside the app;
- clear data collection, use, retention/deletion, and third-party protection descriptions;
- consent and a way to withdraw it where collection requires consent;
- data minimization and requesting only permissions relevant to core functionality;
- allowing use without login when significant account-based features are absent;
- in-app initiation of account deletion if the app supports account creation.

- Offering account deletion in your app  
  https://developer.apple.com/support/offering-account-deletion-in-your-app/

- App Privacy Details  
  https://developer.apple.com/app-store/app-privacy-details/

## Subscription

- Auto-renewable subscriptions  
  https://developer.apple.com/app-store/subscriptions/

Use StoreKit/current Apple subscription surfaces and do not hard-code localized prices or trial terms.

