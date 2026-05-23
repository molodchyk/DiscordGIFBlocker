# Chrome Web Store Justifications

## Beschreibung des alleinigen Zwecks

This extension blocks GIFs on discord.com. It could be argued that GIFs do not provide any important information and thus can be safely ignored or blocked, and this extension does exactly that.

## Begründung für Hostberechtigung

The extension runs `content.js` on Discord pages so it can find GIF media elements in Discord chat and hide their containing media element. The content script uses DOM queries such as `document.querySelectorAll` to find GIF-related media. Without access to `discord.com`, the extension cannot perform its only purpose.

## URL der Datenschutzerklärung

https://github.com/molodchyk/DiscordGIFBlocker/blob/main/PRIVACY.md
