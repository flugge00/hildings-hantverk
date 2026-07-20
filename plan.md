# Plan: Animated Website for "Hildings Hantverk"

## Decisions (from user)
- Stack: Vanilla HTML/CSS/JS + GSAP (free core + ScrollTrigger). No build step.
- Fire: hand-built SVG flames animated with GSAP (flicker via scale/rotate/skew yoyo + SVG turbulence filter). No Lottie/WebGL.
- Structure: Animated intro landing (index) → multi-page (Katalog, Bilder, Kontakt).
- Assets: reuse images from current GitHub Pages site + placeholders.
- Host: GitHub Pages. Content in Swedish.

## Existing site content (source of truth)
Base URL: https://flugge00.github.io/hildings-hantverk-hemsida/
Nav: Katalog (/), Bilder (/gallery/), Kontakt (/contact/)
Founders: Molly Hilding Södergren, Towe Södergren Hilding
Email: hildingshantverk@gmail.com  Tel: +46 70 123 45 67  © 2026

Products (images/*Product.jpg):
- Hög Femma vit 325kr (5hogProduct)
- Fyra grön 250kr (4gronProduct)
- Låg Femma vit 325kr (5lagProduct)
- Sexa grön 500kr (6gronProduct)
- Sockertoppar 150kr (sockertopparProduct)
- Hög Fyra SickSack 300kr (sicksack4hogProduct)
- Låg Fyra SickSack 300kr (sicksack4Product)
- Hög Femma SickSack 450kr (sicksack5Product)
- Snöbollar 60kr (snobollarProduct)
- Spiror 120kr (spirorProduct)

Gallery (images/gallery/*): ekenasBigMolly, ekenasApples, ekenasCollection,
ekenasCollectionSmall, vadstenaCollectionMolly, rodFemma, vadstenaFonster
Contact: images/contact/kontaktBild1.jpg

## Project structure
/
  index.html      animated intro + inspirational scroll
  katalog.html    product catalog
  bilder.html     gallery + lightbox
  kontakt.html    founders/about
  css/styles.css  shared design system (nav, footer, palette, fonts)
  css/intro.css   intro-scene specific
  js/intro.js     GSAP match->candle->scene timeline + ScrollTrigger
  js/main.js      nav toggle, gallery lightbox, shared
  assets/svg/     match.svg, candle.svg, flame (inline in HTML)
  assets/images/  products, gallery/, contact/ (copied from old repo)
  GSAP via CDN (SRI) with reduced-motion fallback

## Design system
- Palette: near-black candlelit bg (#14100c), warm amber/gold (#f5b041/#e67e22),
  flame gradient (white->gold->orange->deep red), cream text (#f3e9d8).
- Fonts: serif headings (Cormorant Garamond), sans body (Inter/Nunito Sans).
- Radial candlelight glow overlay, subtle grain.

## Phases
Phase 1 Scaffold + design system: files, palette, fonts, shared nav/footer.
Phase 2 Intro centerpiece (index): dark scene; SVG match strikes (travel + spark
  particles), flame ignites at tip, GSAP timeline transfers flame to candle wick,
  candle flame grows, radial glow mask expands revealing scene. Continuous flicker
  loop (yoyo scale/rotate/skew + feTurbulence). Skip-intro button.
Phase 3 Inspirational scroll on index: ScrollTrigger pins candle, sections of
  image+text fade/parallax in as if lit by candlelight; CTA into site.
Phase 4 Inner pages: Katalog (product grid cards name/price), Bilder (gallery grid
  + lightbox via main.js), Kontakt (founders + about + contact info). Shared nav/footer.
Phase 5 Polish: copy images from old repo + placeholders, responsive (mobile flame
  scaling + hamburger nav), prefers-reduced-motion (skip to lit state), alt text,
  keyboard nav, perf (60fps), GitHub Pages deploy.

## Verification
- Serve locally (VS Code Live Server or `python -m http.server`) + preview in
  Simple Browser; iterate on flame smoothness.
- Check: match->candle->scene sequence smooth ~60fps; flicker looks organic;
  scroll reveals work; lightbox works; responsive at 375/768/1440px;
  prefers-reduced-motion shows lit scene without heavy animation; keyboard/alt.
- Validate relative paths work under GitHub Pages subpath.

## Excluded
No e-commerce/checkout, no CMS/backend, no framework/build step.
