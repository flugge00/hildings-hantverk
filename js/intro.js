/* ============================================================
   Hildings Hantverk — the candlelight intro
   Match strike → carry flame → light the candle → reveal the page
   ============================================================ */
(function () {
  "use strict";

  const prefersReduced = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  const svgNS = "http://www.w3.org/2000/svg";

  // ---- element refs ----
  const body        = document.body;
  const root        = document.documentElement;
  const match       = document.getElementById("match");
  const matchFlame  = document.getElementById("matchFlame");
  const matchChar   = document.getElementById("matchChar");
  const matchHead   = document.getElementById("matchHead");
  const candle      = document.getElementById("candle");
  const candleFlame = document.getElementById("candleFlame");
  const wickGlow    = document.getElementById("wickGlow");
  const lightHalo   = document.getElementById("lightHalo");
  const striker     = document.getElementById("striker");
  const sparksGroup = document.getElementById("sparks");
  const embersBox   = document.getElementById("embers");
  const heroWords   = document.querySelectorAll("#heroTitle .word");
  const heroLogo    = document.getElementById("heroLogo");
  const heroEyebrow = document.querySelector("#heroTitle .eyebrow");
  const heroSub     = document.querySelector("#heroTitle .subtitle");
  const scrollCue   = document.getElementById("scrollCue");
  const strikeHint  = document.getElementById("strikeHint");
  const introUi     = document.getElementById("introUi");
  const matchHit    = document.getElementById("matchHit");
  const skipBtn     = document.getElementById("skipIntro");

  // ---- shared light state driven onto CSS custom properties ----
  // amt/glow = the base level (set by ignition + scroll); flick = the live
  // flame flicker multiplied on top; x/y = where the pool of light sits.
  const light = { x: 50, y: 66, glow: 32, amt: 0.16, flick: 1 };
  function applyLight() {
    root.style.setProperty("--glow-x", light.x + "%");
    root.style.setProperty("--glow-y", light.y + "%");
    root.style.setProperty("--glow-size", (light.glow * (0.97 + 0.03 * light.flick)).toFixed(2) + "vmax");
    root.style.setProperty("--light", (light.amt * light.flick).toFixed(3));
  }
  applyLight();

  // screen-space centre of an element, as viewport percentages
  function pointAt(el) {
    const r = el.getBoundingClientRect();
    return {
      x: (r.left + r.width / 2) / window.innerWidth * 100,
      y: (r.top + r.height / 2) / window.innerHeight * 100
    };
  }

  // set transform origins so flames grow / pivot from their base
  gsap.set(["#candleFlame", "#matchFlame"], { transformOrigin: "50% 100%" });
  gsap.set(".flame-anim", { transformOrigin: "50% 100%" });
  gsap.set(match, { transformOrigin: "50% 4%" });

  // the candle + holder stay fully opaque; a dark veil over them reads as
  // "asleep in the dark" and lifts once the wick catches — no see-through
  gsap.set("#nightVeil", { opacity: 0.82 });

  const matchFlameAnim  = matchFlame.querySelector(".flame-anim");
  const candleFlameAnim = candleFlame.querySelector(".flame-anim");

  let started = false;
  let igniteTl = null;

  /* ---------------------------------------------------------
     Spark burst at the strike point
  --------------------------------------------------------- */
  function burstSparks(x, y, n) {
    for (let i = 0; i < n; i++) {
      const s = document.createElementNS(svgNS, "circle");
      s.setAttribute("cx", x);
      s.setAttribute("cy", y);
      s.setAttribute("r", gsap.utils.random(0.7, 2.2));
      s.setAttribute("fill", Math.random() > 0.5 ? "#ffd27a" : "#ff8a1e");
      sparksGroup.appendChild(s);
      const ang = gsap.utils.random(200, 340) * Math.PI / 180; // up & out
      const dist = gsap.utils.random(28, 96);
      gsap.to(s, {
        attr: {
          cx: x + Math.cos(ang) * dist,
          cy: y + Math.sin(ang) * dist + gsap.utils.random(24, 70) // gravity
        },
        opacity: 0,
        duration: gsap.utils.random(0.5, 1.15),
        ease: "power2.out",
        onComplete: () => s.remove()
      });
    }
  }

  /* ---------------------------------------------------------
     A small pool of warm light that follows the lit match,
     gliding toward it so the movement always stays soft.
  --------------------------------------------------------- */
  let matchGlowOn = false;
  function startMatchGlow() {
    if (matchGlowOn) return;
    matchGlowOn = true;
    const tick = () => {
      if (!matchGlowOn) { gsap.ticker.remove(tick); return; }
      const p = pointAt(matchHead);
      light.x += (p.x - light.x) * 0.16;
      light.y += (p.y - light.y) * 0.16;
      applyLight();
    };
    gsap.ticker.add(tick);
  }
  function stopMatchGlow() { matchGlowOn = false; }

  /* ---------------------------------------------------------
     Organic flame dance — layered, non-harmonic sine waves so
     the motion never quite repeats (that is what sells "alive").
     Origin is the wick, so the tip sways while the base holds.
  --------------------------------------------------------- */
  const flameTickers = {};
  function startFlameMotion(key, group) {
    if (prefersReduced || flameTickers[key]) return;
    gsap.set(group, { transformOrigin: "50% 100%" });
    const t0 = performance.now() - Math.random() * 4000;
    const tick = () => {
      const t = (performance.now() - t0) / 1000;
      const sway    = 3.4 * Math.sin(t * 2.3) + 1.9 * Math.sin(t * 3.9 + 1.2) + 0.9 * Math.sin(t * 7.3);
      const stretch = 1 + 0.055 * Math.sin(t * 3.3 + 0.4) + 0.03 * Math.sin(t * 6.7 + 1.1);
      const widen   = 1 - 0.03 * Math.sin(t * 2.9 + 0.7) - 0.018 * Math.sin(t * 5.1);
      const drift   = 0.7 * Math.sin(t * 2.6 + 0.3);
      gsap.set(group, { skewX: sway, rotation: sway * 0.2, scaleY: stretch, scaleX: widen, x: drift });
    };
    flameTickers[key] = tick;
    gsap.ticker.add(tick);
  }
  function stopFlameMotion(key) {
    if (flameTickers[key]) { gsap.ticker.remove(flameTickers[key]); delete flameTickers[key]; }
  }

  /* ---------------------------------------------------------
     The candle's pool of light, once lit: a slow, warm breath
     that never dies down completely (stays ~70%-100%).
  --------------------------------------------------------- */
  let breathOn = false;
  function startLightBreath() {
    if (breathOn || prefersReduced) return;
    breathOn = true;
    const t0 = performance.now();
    gsap.ticker.add(() => {
      const t = (performance.now() - t0) / 1000;
      let n = 0.60 * Math.sin(t * 1.1)
            + 0.24 * Math.sin(t * 2.3 + 1.0)
            + 0.16 * Math.sin(t * 4.7 + 0.6);
      n = (n + 1) / 2;                  // -> 0..1
      light.flick = 0.70 + 0.30 * n;    // gentle, always shining
      applyLight();
    });
    // the halo disc breathes slowly in sympathy
    gsap.to(lightHalo, {
      opacity: 0.64, scale: 1.07, duration: 2.6,
      ease: "sine.inOut", repeat: -1, yoyo: true,
      transformOrigin: "50% 50%"
    });
  }

  /* ---------------------------------------------------------
     Drifting embers once the candle is alive
  --------------------------------------------------------- */
  function spawnEmber() {
    if (prefersReduced) return;
    const e = document.createElement("span");
    e.className = "ember";
    const startX = 46 + Math.random() * 8;      // near the candle, %
    e.style.left = startX + "%";
    e.style.bottom = "24vh";
    embersBox.appendChild(e);
    gsap.to(e, {
      y: -gsap.utils.random(180, 420),
      x: gsap.utils.random(-60, 60),
      opacity: 0,
      duration: gsap.utils.random(3.5, 6.5),
      ease: "power1.out",
      onStart: () => gsap.set(e, { opacity: gsap.utils.random(0.4, 0.9) }),
      onComplete: () => e.remove()
    });
  }
  function startEmbers() {
    if (prefersReduced) return;
    (function loop() {
      spawnEmber();
      gsap.delayedCall(gsap.utils.random(0.5, 1.4), loop);
    })();
  }

  /* ---------------------------------------------------------
     Reveal the page for scrolling + wire scroll animations
  --------------------------------------------------------- */
  let scrollReady = false;
  function unlockScroll() {
    if (scrollReady) return;
    scrollReady = true;
    body.classList.remove("intro-locked");
    gsap.set(introUi, { pointerEvents: "none" });
    gsap.to(introUi, { opacity: 0, duration: 0.6, onComplete: () => { introUi.style.display = "none"; } });

    if (!window.ScrollTrigger) return;
    gsap.registerPlugin(ScrollTrigger);

    // fade the hero title + cue away as the story rises (quick, so it's
    // fully gone well before the first panel starts revealing)
    gsap.to(["#heroTitle", "#scrollCue"], {
      opacity: 0,
      ease: "none",
      scrollTrigger: {
        trigger: "#story",
        start: "top top",
        end: () => "+=" + Math.round(window.innerHeight * 0.35),
        scrub: true
      }
    });

    // gently dim the fixed candle so text stays readable deeper down
    gsap.to(light, {
      amt: 0.72,
      glow: 88,
      ease: "none",
      onUpdate: applyLight,
      scrollTrigger: { trigger: "#story", start: "top top", end: "60% top", scrub: true }
    });

    // the candle is fixed in place on screen, so once the CTA (with its
    // own logo) scrolls up to meet it, fade the candle scene away first —
    // otherwise the two always end up overlapping near the page bottom
    gsap.to(".scene", {
      opacity: 0,
      ease: "none",
      scrollTrigger: { trigger: ".story__cta", start: "top 85%", end: "top 30%", scrub: true }
    });

    // reveal each story panel as it enters (early enough that it doesn't
    // leave large dark gaps while scrolling on small screens)
    gsap.utils.toArray(".fx-up").forEach((el) => {
      gsap.to(el, {
        opacity: 1,
        y: 0,
        duration: 0.9,
        ease: "power2.out",
        scrollTrigger: { trigger: el, start: "top 88%", toggleActions: "play none none reverse" }
      });
    });
  }

  /* ---------------------------------------------------------
     Master ignition timeline
  --------------------------------------------------------- */
  function ignite() {
    if (started) return;
    started = true;
    gsap.killTweensOf(strikeHint);
    gsap.to(strikeHint, { opacity: 0, duration: 0.3 });
    matchHit.style.pointerEvents = "none";

    const tl = gsap.timeline({
      defaults: { ease: "power2.inOut" },
      onComplete: () => { startLightBreath(); startEmbers(); unlockScroll(); }
    });
    igniteTl = tl;

    // 0 — reveal the striker + let the pool of light drop toward the match
    tl.to(striker, { opacity: 0.75, duration: 0.25 }, 0);
    tl.to(light, { glow: 22, amt: 0.32, duration: 0.5, ease: "sine.out", onUpdate: applyLight }, 0);
    tl.add(() => startMatchGlow(), 0.02);        // the light now tracks the match

    // 1 — the strike: drag the head across the striker with sparks
    tl.to(match, { x: 110, rotation: -6, duration: 0.14, ease: "power1.in" }, 0.05)
      .to(match, { x: 64, rotation: -14, duration: 0.24, ease: "power2.out",
        onStart: () => burstSparks(110, 396, 10),
        onUpdate: () => { if (Math.random() > 0.72) burstSparks(gsap.getProperty(match, "x") - 6, 396, 3); }
      }, 0.19);

    // char the head
    tl.to(matchChar, { opacity: 1, duration: 0.2 }, 0.34)
      .to(matchHead, { fill: "#5a1a0f", duration: 0.3 }, 0.34);

    // 2 — the match flame catches and begins to dance; its little pool warms
    tl.fromTo(matchFlame, { scale: 0 }, { scale: 1, duration: 0.45, ease: "back.out(2)",
        onStart: () => { burstSparks(64, 392, 14); startFlameMotion("match", matchFlameAnim); } }, 0.36);
    tl.to(light, { glow: 27, amt: 0.5, duration: 0.6, ease: "sine.out", onUpdate: applyLight }, 0.5);

    // 3 — lift & carry the flame up to the wick (arc via a middle keyframe).
    // The two legs share eases (in -> out) so velocity carries through the
    // middle keypoint instead of stalling there.
    tl.to(match, { x: 150, y: 320, rotation: -22, duration: 0.5, ease: "sine.in" }, 0.9)
      .to(match, { x: 199, y: 240, rotation: -30, duration: 0.55, ease: "sine.out" }, 1.4)
      .to(matchFlame, { rotation: 28, duration: 1.0, ease: "sine.inOut" }, 0.9); // keep the flame upright-ish

    // 4 — the candle catches: the light lets go of the match and settles on the wick
    tl.add(() => stopMatchGlow(), 1.86);
    tl.to(wickGlow, { opacity: 1, duration: 0.3 }, 1.85)
      .to("#nightVeil", { opacity: 0, duration: 0.9, ease: "power2.out" }, 1.85)
      .fromTo(candleFlame, { scale: 0 }, { scale: 1, duration: 0.6, ease: "back.out(1.6)",
        onStart: () => startFlameMotion("candle", candleFlameAnim) }, 1.9)
      .fromTo(lightHalo, { opacity: 0, scale: 0.4, transformOrigin: "50% 50%" },
              { opacity: 0.8, scale: 1, duration: 0.9, ease: "power2.out" }, 1.9);

    // the great reveal — light floods out from the candle and warms the page
    tl.to(light, { x: 50, y: 62, glow: 100, amt: 1, duration: 1.5, ease: "power2.out", onUpdate: applyLight }, 1.9);

    // brand emerges from the dark
    tl.to(heroLogo, { opacity: 1, duration: 1.1, ease: "power2.out",
        onStart: () => gsap.set(heroLogo, { y: 18 }) }, 1.95)
      .to(heroLogo, { y: 0, duration: 1.1, ease: "power3.out" }, 1.95)
      .to(heroEyebrow, { opacity: 1, duration: 0.9 }, 2.1)
      .to(heroWords, { opacity: 1, y: 0, duration: 1.1, stagger: 0.14, ease: "power3.out",
        onStart: () => gsap.set(heroWords, { y: 24 }) }, 2.15)
      .to(heroSub, { opacity: 1, duration: 1, ease: "power2.out" }, 2.6)
      .to(scrollCue, { opacity: 1, duration: 0.8 }, 3.0);

    // 5 — withdraw the spent match with a little puff; the striker strip
    // fades out in step with the match leaving the frame
    tl.to(matchFlame, { scale: 0, duration: 0.35, ease: "power2.in",
        onComplete: () => stopFlameMotion("match") }, 2.35)
      .to(match, { y: 470, opacity: 0, rotation: -46, duration: 0.9, ease: "power2.in" }, 2.5)
      .to(striker, { opacity: 0, duration: 0.9, ease: "power2.in" }, 2.5);
  }

  /* ---------------------------------------------------------
     Jump straight to the fully-lit state (skip / reduced motion)
  --------------------------------------------------------- */
  function goToLit() {
    started = true;
    stopMatchGlow();
    stopFlameMotion("match");
    gsap.set(match, { opacity: 0 });
    gsap.set(matchFlame, { scale: 0 });
    gsap.set("#nightVeil", { opacity: 0 });
    gsap.set(candleFlame, { scale: 1 });
    gsap.set(wickGlow, { opacity: 1 });
    gsap.set(lightHalo, { opacity: 0.8, scale: 1, transformOrigin: "50% 50%" });
    gsap.set(striker, { opacity: 0 });
    gsap.set([heroEyebrow, heroSub, scrollCue], { opacity: 1 });
    gsap.set(heroLogo, { opacity: 1, y: 0 });
    gsap.set(heroWords, { opacity: 1, y: 0 });
    gsap.set(strikeHint, { opacity: 0 });
    Object.assign(light, { x: 50, y: 62, glow: 100, amt: 1, flick: 1 });
    applyLight();
    startFlameMotion("candle", candleFlameAnim);
    startLightBreath();
    startEmbers();
    unlockScroll();
  }

  /* ---------------------------------------------------------
     Boot
  --------------------------------------------------------- */
  function boot() {
    if (prefersReduced) { goToLit(); return; }

    // invite the strike
    gsap.to(strikeHint, { opacity: 1, duration: 1, delay: 0.9 });

    matchHit.addEventListener("click", ignite, { once: true });
    matchHit.addEventListener("touchstart", ignite, { once: true, passive: true });
    skipBtn.addEventListener("click", () => {
      if (igniteTl) igniteTl.kill();
      gsap.killTweensOf([match, matchFlame, candleFlame, lightHalo, light]);
      goToLit();
    });

    // if the visitor hesitates, light it for them
    gsap.delayedCall(5, () => { if (!started) ignite(); });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot);
  } else {
    boot();
  }
})();
