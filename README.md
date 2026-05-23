# Discord GIF Blocker

[![Version](https://img.shields.io/badge/version-1.1.0-2ea44f)](CHANGELOG.md)
[![License: GPL v3](https://img.shields.io/badge/license-GPL--3.0-blue)](LICENSE.txt)
[![No analytics](https://img.shields.io/badge/privacy-no%20analytics-brightgreen)](#privacy)

A tiny Chrome extension that hides GIF media on `discord.com`.

![Discord GIF Blocker promotional image](assets/store/cws-marquee-promo-1400x560.png)

## Why

Have you ever seen a single GIF on Discord that was worth your time? Discord GIF Blocker removes GIF media from chat so Discord is calmer and less distracting.

The extension has one job, runs only on Discord, and does not collect data.

## Install

For local development or manual install:

1. Download or clone this repository.
2. Open `chrome://extensions`.
3. Enable **Developer mode**.
4. Click **Load unpacked**.
5. Select this extension folder.

## Features

- Hides GIF media that users send in Discord chat.
- Runs only on `discord.com`.
- Uses Chrome's built-in localization system.
- Does not collect data or send analytics.
- Does not use remote code.

## How It Works

The content script watches Discord's web UI and hides GIF-related media containers when Discord renders them.

It does not:

- read or store your messages
- modify your Discord account
- send data anywhere
- block Discord's backend directly

It only changes the visible web UI in your browser.

## Project Structure

- `manifest.json` - Chrome extension manifest
- `content.js` - content script that hides GIF media on Discord
- `_locales/` - localized extension name and description strings
- `assets/icons/` - generated extension icons
- `assets/store/` - generated Chrome Web Store promotional images
- `store-listing/` - Chrome Web Store description copy split by locale
- `STORE_LISTING.md` - Chrome Web Store listing index
- `STORE_JUSTIFICATIONS.md` - single-purpose, host-permission, remote-code, and data-use justifications
- `PRIVACY.md` - privacy policy
- `tools/generate-assets.ps1` - reproducible icon and promotional image generator
- `LICENSE.txt` - GPL license text

## Development

After making changes, reload the extension from `chrome://extensions` and refresh Discord.

Regenerate icons and Chrome Web Store promotional images:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\generate-assets.ps1
```

## Localization

The extension supports 50 locales through Chrome's `_locales` directory.

Chrome Web Store listing copy is maintained separately in `store-listing/`, with [STORE_LISTING.md](STORE_LISTING.md) as the index.

## Store Review

Chrome Web Store permission and privacy justifications are documented in [STORE_JUSTIFICATIONS.md](STORE_JUSTIFICATIONS.md).

## Privacy

Discord GIF Blocker does not collect, store, or transmit any data. It has no analytics, no tracking, no remote server, and no remote code.

See [PRIVACY.md](PRIVACY.md) for the full privacy policy.

## Support

If this extension saves you time and you want to support its development:

[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-support-FFDD00?logo=buymeacoffee&logoColor=000)](https://buymeacoffee.com/molodchyk)
[![Patreon](https://img.shields.io/badge/Patreon-support-F96854?logo=patreon&logoColor=fff)](https://www.patreon.com/OMolodchyk)

## License

This project is licensed under the GNU General Public License v3.0. See [LICENSE.txt](LICENSE.txt) for details.
