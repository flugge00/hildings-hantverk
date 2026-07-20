# Hildings Hantverk — Handgjorda ljus

Animated website for **Hildings Hantverk**, a small candle workshop. Built as a
static site with vanilla HTML/CSS/JS and [GSAP](https://gsap.com/) (loaded from a
CDN). There is **no build step** — the files in this folder are the site.

## Structure

```
hildings-hantverk/
├── index.html          # Animated intro + landing page
├── katalog.html        # Product catalog
├── bilder.html         # Gallery
├── kontakt.html        # Contact / about
├── css/                # styles.css (shared) + intro.css (intro scene)
├── js/                 # data.js, intro.js, main.js
├── images/             # products, gallery/, contact/
└── Logos/
    ├── Logga_HildingsHantverk_200x200mm.svg
    └── variations/
        ├── gallery.html   # Logo variations preview page
        └── generate.ps1
```

## How to run

Because the site uses relative paths and loads assets, open it through a **local
web server** (opening `index.html` directly via `file://` can break font/asset
loading and CDN behavior).

Pick any one of the following from inside the `hildings-hantverk/` folder:

### Python (built in on most systems)

```powershell
python -m http.server 5533
```

Then open <http://localhost:5533/index.html>.

### Node.js

```powershell
npx serve -l 5533
```

### VS Code

Install the **Live Server** extension, right-click `index.html`, and choose
**"Open with Live Server"**.

## Logo variations gallery

The logo variations preview lives at:

```
Logos/variations/gallery.html
```

With a local server running (see above) open:

- <http://localhost:5533/Logos/variations/gallery.html>

Or navigate manually: from the site root go to **Logos → variations →
gallery.html**. Once deployed, the same relative path works:
`https://<your-site>/Logos/variations/gallery.html`.

## Deploy

The site is fully static, so it can be hosted on any static host.

### GitHub (push the code)

```powershell
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/<user>/<repo>.git
git push -u origin main
```

> **GitHub Pages:** enable it under **Settings → Pages → Build and deployment**,
> source **"Deploy from a branch"**, branch `main`, folder `/ (root)`.

### GitLab Pages (hosting)

This repo includes a [`.gitlab-ci.yml`](.gitlab-ci.yml) that publishes the site
with GitLab Pages. To host on GitLab:

1. Create a project on GitLab and push the code (same commands as above, using
   your GitLab remote URL).
2. GitLab runs the `pages` job automatically on the default branch. It copies the
   static files into a `public/` directory that GitLab Pages serves.
3. Find the live URL under **Deploy → Pages** (typically
   `https://<user>.gitlab.io/<repo>/`).

The logo gallery is then available at
`https://<user>.gitlab.io/<repo>/Logos/variations/gallery.html`.
