# Chrome Web Store Justifications

## Single Purpose

Discord GIF Blocker has one purpose: it hides GIF media on `discord.com` so Discord chat is less distracting.

## Single Purpose Description

This extension blocks GIFs on discord.com. It could be argued that GIFs do not provide any important information and thus can be safely ignored or blocked, and this extension does exactly that.

## Host Permission Justification

The extension uses this content script declaration:

```json
"content_scripts": [
  {
    "matches": ["*://discord.com/*"],
    "js": ["content.js"]
  }
]
```

This runs `content.js` on Discord pages so the extension can find GIF media elements in Discord chat and hide their containing message media element. The content script uses DOM queries such as `document.querySelectorAll` to find GIF-related media. Without access to `discord.com`, the extension cannot perform its only purpose.

## Remote Code

No. This extension does not use remote code.

All JavaScript is packaged inside the extension. It does not load external scripts, WebAssembly, remote modules, or code strings evaluated with `eval()`.

## Data Use Disclosure

The extension does not collect user data.

For the Chrome Web Store privacy form, no data categories are collected:

- Personally identifiable information: not collected
- Health information: not collected
- Financial and payment information: not collected
- Authentication information: not collected
- Personal communications: not collected
- Location: not collected
- Web history: not collected
- User activity: not collected
- Website content: not collected

The extension only changes the visible Discord web page in the user's browser by hiding GIF media elements. It does not read, store, transmit, sell, or share user data.
