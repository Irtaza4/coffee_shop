# Cuppio Coffee

A Flutter recreation of [Coffee Shop Mobile App UI/UX Design by Ali Mortuja for Dashbloom](https://dribbble.com/shots/27605633-Coffee-Shop-Mobile-App-UI-UX-Design).

## Run

```sh
flutter pub get
flutter run
```

Targets the existing Android and iOS projects. Layouts adapt to smaller phones and constrain the app to a comfortable width on larger displays.

## Experience

- Iced-coffee onboarding with subtle animated motion.
- Swipeable home carousel, category filters, search, and a staggered Explore catalog.
- Favorites, rating sort, product details, four cup sizes, and quantity selection.
- Hero transitions, animated cup scaling, favorite feedback, press feedback, and haptics.
- Floating navigation with a transparent surround: tabs stay in their original slots while the curved dip and blue highlight move to the selection. Tap a tab or drag across the dock and release to select.
- Slide-to-proceed controls throughout the app. Drag the dark handle to the right edge and release; incomplete or cancelled drags reset. Keyboard and screen-reader activation remain available.
- Cart with size-aware line items, quantity controls, accurate totals, and empty states.
- Editable delivery address, payment method selection, demo order confirmation, and a session profile.

## MVVM structure

- `lib/domain/models/`: immutable coffee and cart models, size definitions.
- `lib/data/repositories/`: catalog repository contract and local implementation.
- `lib/presentation/viewmodels/`: observable shop and product state, filtering, pricing, cart operations, and demo order logic.
- `lib/presentation/views/`: screens that observe view models via `ListenableBuilder`.
- `lib/presentation/widgets/`: shared product rendering, cards, controls, and route transitions.
- `lib/core/theme/`: shared typography and colors.

View models own business state; views own only transient presentation state such as animation and page controllers. The repository is injected into `ShopViewModel` at the app composition root. No additional runtime packages are required.

## Validation

```sh
flutter analyze
flutter test
```

Tests cover cart merging by size, removal, totals, demo order clearing, search/category filtering, favorites, size pricing, an end-to-end widget checkout journey, compact phone layouts, slide completion/cancellation, disabled sliders, and drag-based tab switching.

To regenerate screen previews:

```sh
flutter test test/preview_capture_test.dart
```

Screenshots are saved under `build/previews/`.

## Scope and assets

This is a local UI demo. Data is kept in memory and resets when the app restarts. There is no authentication, real payment processing, order submission, or delivery integration. Checkout clearly labels the demo behavior.

The layout, palette and visual direction follow the linked design. The coffee artwork is AI-recreated from the reference, not original production assets, and the font is Manrope; this is not a pixel-identical export. The profile uses initials instead of the reference portrait. Product descriptions, prices, delivery fee, and catalog contents are sample data. The raised highlight and curved dip follow the selected tab without reordering the tabs.

Manrope is bundled locally under the SIL Open Font License; see `assets/fonts/OFL.txt`. Image assets are bundled locally and require no network connection.
