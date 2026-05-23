# Changelog

All notable changes to this project will be documented in this file.

## [1.1.0] - Work in progress

### Added

- Added GPL-3.0-only SPDX and copyright headers to the content script.
- Added localized extension metadata for English, Ukrainian, German, Spanish, and French.
- Added Chrome Web Store listing descriptions for English, Ukrainian, German, Spanish, and French.
- Added reproducible generated icons and Chrome Web Store promotional images.
- Added Chrome Web Store justification and privacy policy documentation.
- Added Chrome Web Store listing index.
- Added `LICENSE.txt`.

### Changed

- Updated `manifest.json` to use Chrome extension internationalization keys.
- Improved `content.js` by isolating its scope, coalescing mutation handling, and making GIF hiding idempotent.
- Expanded README into a complete GitHub project page.

### Removed

- Removed the unused background service worker from the extension manifest.

## [1.0.0] - Initial release

### Added

- Added the initial Chrome extension for hiding Discord GIFs.
