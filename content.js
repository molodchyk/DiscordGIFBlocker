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
  const LOADED_ATTRIBUTE = 'data-discord-gif-blocker-loaded';
  const DEBUG_STORAGE_KEY = 'discordGifBlockerDebug';
  const SCAN_EVENT = 'discordGifBlockerScan';
  let isScanScheduled = false;

  function hideDiscordGifs() {
    let hiddenCount = 0;
    const gifElements = document.querySelectorAll(GIF_MEDIA_SELECTOR);

    gifElements.forEach((element) => {
      const gifContainer = element.closest('div[class*="imageContent"]');
      if (gifContainer && hideElement(gifContainer)) {
        hiddenCount += 1;
      }
    });

    logDebug(`Scan complete. Found ${gifElements.length} GIF media element(s), hidden ${hiddenCount}.`);
  }

  function hideElement(element) {
    if (element.hasAttribute(HIDDEN_ATTRIBUTE)) {
      return false;
    }

    element.setAttribute(HIDDEN_ATTRIBUTE, 'true');
    element.style.setProperty('display', 'none', 'important');
    logDebug('Hidden GIF media.');
    return true;
  }

  function logDebug(message) {
    if (!isDebugEnabled()) {
      return;
    }

    console.info(`[Discord GIF Blocker] ${message}`);
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

  document.documentElement.setAttribute(LOADED_ATTRIBUTE, 'true');
  document.addEventListener(SCAN_EVENT, hideDiscordGifs);

  hideDiscordGifs();
})();
