/* ============================================================
   Hildings Hantverk — shared behaviour
   Mobile nav + gallery lightbox + generic scroll reveals
   ============================================================ */
(function () {
  "use strict";

  /* ---- mobile navigation ---- */
  const toggle = document.querySelector(".nav-toggle");
  const nav = document.getElementById("site-nav");
  if (toggle && nav) {
    const setNav = (open) => {
      nav.setAttribute("data-open", String(open));
      toggle.setAttribute("aria-expanded", String(open));
      document.body.classList.toggle("nav-open", open);
    };
    toggle.addEventListener("click", () => {
      setNav(nav.getAttribute("data-open") !== "true");
    });
    nav.querySelectorAll("a").forEach((a) =>
      a.addEventListener("click", () => setNav(false))
    );
    document.addEventListener("keydown", (e) => {
      if (e.key === "Escape") setNav(false);
    });
    document.addEventListener("click", (e) => {
      if (
        nav.getAttribute("data-open") === "true" &&
        !nav.contains(e.target) &&
        !toggle.contains(e.target)
      ) {
        setNav(false);
      }
    });
  }

  /* ---- gallery lightbox ---- */
  const lightbox = document.getElementById("lightbox");
  if (lightbox) {
    const imgEl = lightbox.querySelector("img");
    const triggers = document.querySelectorAll("[data-lightbox]");
    const closeBtn = lightbox.querySelector(".lightbox__close");

    function open(src, alt) {
      imgEl.src = src;
      imgEl.alt = alt || "";
      lightbox.classList.add("is-open");
      document.body.style.overflow = "hidden";
    }
    function close() {
      lightbox.classList.remove("is-open");
      document.body.style.overflow = "";
    }
    triggers.forEach((t) =>
      t.addEventListener("click", () => open(t.getAttribute("href") || t.dataset.full || t.querySelector("img")?.src, t.querySelector("img")?.alt))
    );
    triggers.forEach((t) => t.addEventListener("click", (e) => e.preventDefault()));
    closeBtn?.addEventListener("click", close);
    lightbox.addEventListener("click", (e) => { if (e.target === lightbox) close(); });
    document.addEventListener("keydown", (e) => { if (e.key === "Escape") close(); });
  }

  /* ---- generic reveal-on-scroll (inner pages) ---- */
  if (window.gsap && window.ScrollTrigger && document.querySelector(".reveal")) {
    gsap.registerPlugin(ScrollTrigger);
    gsap.utils.toArray(".reveal").forEach((el, i) => {
      gsap.fromTo(el, { opacity: 0, y: 18 }, {
        opacity: 1, y: 0, duration: 0.6, ease: "power2.out", delay: (i % 3) * 0.05,
        scrollTrigger: { trigger: el, start: "top 95%", toggleActions: "play none none reverse" }
      });
    });
  }
})();
