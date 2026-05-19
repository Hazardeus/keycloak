/* agflow-confident — typewriter one-shot per session, prefers-reduced-motion aware.
   Spec: docs/superpowers/specs/2026-05-19-keycloak-theme-agflow-confident-design.md §6.5–6.6
*/
(function () {
  'use strict';

  const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  function cyrb53(str, seed = 0) {
    let h1 = 0xdeadbeef ^ seed, h2 = 0x41c6ce57 ^ seed;
    for (let i = 0, ch; i < str.length; i++) {
      ch = str.charCodeAt(i);
      h1 = Math.imul(h1 ^ ch, 2654435761);
      h2 = Math.imul(h2 ^ ch, 1597334677);
    }
    h1 = Math.imul(h1 ^ (h1 >>> 16), 2246822507) ^ Math.imul(h2 ^ (h2 >>> 13), 3266489909);
    h2 = Math.imul(h2 ^ (h2 >>> 16), 2246822507) ^ Math.imul(h1 ^ (h1 >>> 13), 3266489909);
    return (4294967296 * (2097151 & h2) + (h1 >>> 0)).toString(36);
  }

  function buildSeenKey(voiceEl) {
    const screen = voiceEl.getAttribute('data-screen') || 'unknown';
    if (screen === 'error' || screen === 'login-page-expired') {
      const msgEl = document.querySelector('[data-message-type]');
      const seed = msgEl ? msgEl.textContent.trim() : '';
      return 'agflow_confident.seen.' + screen + '.' + cyrb53(seed);
    }
    return 'agflow_confident.seen.' + screen;
  }

  function revealStatic(voiceEl) {
    voiceEl.querySelectorAll('.kc-line.is-pending').forEach((line) => {
      line.textContent = line.getAttribute('data-text') || '';
      line.classList.remove('is-pending');
    });
    const lines = voiceEl.querySelectorAll('.kc-line:not(.kc-line-aside)');
    if (lines.length > 0) lines[lines.length - 1].classList.add('is-done');
  }

  function typewrite(voiceEl, onDone) {
    const lines = Array.from(voiceEl.querySelectorAll('.kc-line.is-pending'));
    let idx = 0;

    function typeOne() {
      if (idx >= lines.length) { onDone(); return; }
      const line = lines[idx];
      const text = line.getAttribute('data-text') || '';
      line.style.opacity = '1';
      line.classList.remove('is-pending');
      let i = 0;
      const tick = () => {
        line.textContent = text.slice(0, ++i);
        if (i < text.length) {
          setTimeout(tick, 30);
        } else {
          idx++;
          if (idx === lines.length) line.classList.add('is-done');
          setTimeout(typeOne, 400);
        }
      };
      tick();
    }

    typeOne();
  }

  function init() {
    const voiceEl = document.querySelector('.kc-voice[data-screen]');
    if (!voiceEl) return;

    const seenKey = buildSeenKey(voiceEl);
    let alreadySeen = false;
    try { alreadySeen = sessionStorage.getItem(seenKey) === '1'; } catch (_) {}

    if (reducedMotion || alreadySeen) {
      revealStatic(voiceEl);
      return;
    }

    typewrite(voiceEl, () => {
      try { sessionStorage.setItem(seenKey, '1'); } catch (_) {}
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
