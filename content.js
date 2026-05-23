// SPDX-License-Identifier: GPL-3.0-only
// Copyright (C) 2024-2026 Oleksandr Molodchyk

(() => {
  'use strict';

  const GIF_MEDIA_SELECTOR = [
    'div[class*="imageContent"] img[src*=".gif"]',
    'div[class*="imageContent"] video[src*=".mp4"]'
  ].join(', ');
  const HIDDEN_ATTRIBUTE = 'data-discord-gif-blocker-hidden';
  const DEBUG_ATTRIBUTE = 'data-discord-gif-blocker-debug';
  const DEBUG_STORAGE_KEY = 'discordGifBlockerDebug';
  let isScanScheduled = false;

  function hideDiscordGifs() {
    document.querySelectorAll(GIF_MEDIA_SELECTOR).forEach((element) => {
      const gifContainer = element.closest('div[class*="imageContent"]');
      if (gifContainer) {
        hideElement(gifContainer);
      }
    });
  }

  function hideElement(element) {
    if (element.hasAttribute(HIDDEN_ATTRIBUTE)) {
      return;
    }

    element.setAttribute(HIDDEN_ATTRIBUTE, 'true');
    element.style.setProperty('display', 'none', 'important');
    logBlockedGif();
  }

  function logBlockedGif() {
    if (!isDebugEnabled()) {
      return;
    }

    console.info('[Discord GIF Blocker] Hidden GIF media.');
  }

  function isDebugEnabled() {
    if (document.documentElement.getAttribute(DEBUG_ATTRIBUTE) === 'true') {
      return true;
    }

    return globalThis.localStorage?.getItem(DEBUG_STORAGE_KEY) === 'true';
  }

  function scheduleGifScan() {
    if (isScanScheduled) {
      return;
    }

    isScanScheduled = true;
    requestAnimationFrame(() => {
      isScanScheduled = false;
      hideDiscordGifs();
    });
  }

  const observer = new MutationObserver(scheduleGifScan);

  observer.observe(document.body || document.documentElement, {
    childList: true,
    subtree: true
  });

  hideDiscordGifs();
})();
