// SPDX-License-Identifier: GPL-3.0-only
// Copyright (C) 2024-2026 Oleksandr Molodchyk

(() => {
  'use strict';

  const GIF_MEDIA_SELECTOR = [
    'div[class*="imageContent"] img[src*=".gif"]',
    'div[class*="imageContent"] video[src*=".mp4"]'
  ].join(', ');
  const HIDDEN_ATTRIBUTE = 'data-discord-gif-blocker-hidden';
  const LOADED_ATTRIBUTE = 'data-discord-gif-blocker-loaded';
  let isScanScheduled = false;

  function hideDiscordGifs() {
    const gifElements = document.querySelectorAll(GIF_MEDIA_SELECTOR);

    gifElements.forEach((element) => {
      const gifContainer = element.closest('div[class*="imageContent"]');
      if (gifContainer) {
        hideElement(gifContainer);
      }
    });
  }

  function hideElement(element) {
    if (element.hasAttribute(HIDDEN_ATTRIBUTE)) {
      return false;
    }

    element.setAttribute(HIDDEN_ATTRIBUTE, 'true');
    element.style.setProperty('display', 'none', 'important');
    console.info('[Discord GIF Blocker] Hidden GIF media.');
    return true;
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

  document.documentElement.setAttribute(LOADED_ATTRIBUTE, 'true');

  hideDiscordGifs();
})();
