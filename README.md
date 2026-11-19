# hatilu.com

The website of Hatilú Studio: the studio home, one folder per app, and each
app's privacy, support and roadmap pages.

Plain HTML and one stylesheet. There is no build step and no dependency:
GitHub Pages serves the `main` branch as it is, so a push to `main` is a deploy.

## Layout

```
index.html                 studio home
press/                     studio press page
assets/site.css            the one stylesheet, shared by every page
assets/og/                 link preview images (1200 x 630)
tepuy/                     everything about Tepuy
  index.html               the app's page
  theme.css                the app's colours, nothing else
  img/                     icon and web-sized screenshots
  press/                   press kit, with full-size files in press/files/
  privacy/<locale>/        legal pages, in the app's languages
  support/<locale>/
  roadmap/<locale>/
privacy/ support/ roadmap/ forwarding pages, see "Old addresses" below
scripts/                   screenshot resizing and the preview image sources
sitemap.xml, robots.txt
```

Every link between pages is relative, so the site works at
`javierjosefernandes.github.io/tepuy-pages/` and at `hatilu.com/` alike.
Canonical URLs, the sitemap and the link preview tags are absolute and point at
`https://hatilu.com`.

## Working on it

```sh
python3 -m http.server 8000      # then open http://localhost:8000
```

Larger changes go through a pull request, so the diff of what the public sees
gets read first. Copy fixes can go straight to `main`.

The header and footer are repeated in every page. A change to either is a
search and replace across the files, not an edit in one place.

## Adding an app

Tepuy's folder is the template. Copy it, then replace:

1. **Folder**: `cp -R tepuy <app>`, and delete `privacy`, `support`, `roadmap`
   and `press/files` until the app has its own.
2. **`theme.css`**: the accent, taken from the app's icon, for light and dark,
   and the three `--band-*` colours of the dark band at the top. Check the light
   accent against the page background for a contrast of at least 4.5 to 1.
3. **`img/`**: `icon-64.png`, `icon-180.png`, `icon-512.png` from the 1024 px
   icon (`sips -Z 64 AppIcon.png --out img/icon-64.png`), and the screenshots,
   with `scripts/make-screenshots.sh`.
4. **`index.html`**, top to bottom:
   - `<title>`, the description, the canonical URL and the `og:` tags
   - `apple-itunes-app` and both App Store links: the app's ID and a `ct=` name
   - both JSON-LD blocks. The questions in the `FAQPage` block must match the
     visible questions word for word
   - the headline, the paragraph under it and the hero screenshot
   - the line under the band, if the name has a story
   - the feature blocks: three to five, each a screenshot, a label, a heading
     and two or three sentences
   - the story, in the first person
   - the four link cards
   - the questions, written as people would type them into a search engine
   - the footer, including any trademark or affiliation line the app needs
5. **Legal pages**: `privacy/en/`, `support/en/` and `roadmap/en/` at least,
   plus `privacy/index.html` and its siblings, which forward to `en/`.
6. **`press/index.html`** and the files it offers.
7. **Link preview image**: copy `scripts/og/tepuy.html`, change it, and save a
   1200 x 630 screenshot to `assets/og/<app>.png`.
8. **Studio home**: a card in the Apps section of `/index.html`, a support link
   in its Contact section, a line in `/press/index.html`.
9. **`sitemap.xml`**: one line per new page.

An app with no shipped version gets no page.

### Screenshots

```sh
scripts/make-screenshots.sh tepuy ../tepuy-marketing/screenshots/raw en
```

It reads the raw, bezel-free captures the store screenshot pipeline writes and
produces `tepuy/img/<slug>.webp` at 660 px wide, and `watch-<slug>.webp` for
Apple Watch. The device frames are drawn in CSS (`.device` and `.device.watch`),
so the images carry no bezel. Run it again after each release's capture.

### Link preview images

`scripts/og/*.html` are 1200 x 630 pages. Open one in a browser, set the window
to that size with the developer tools, and save a screenshot over the PNG in
`assets/og/`.

## Old addresses

The legal pages used to live at `/privacy/`, `/support/` and `/roadmap/` on
`javierjosefernandes.github.io/tepuy-pages/`. Those addresses are compiled into
released versions of Tepuy and are in its App Store listing, so the forwarding
pages in the top-level `privacy/`, `support/` and `roadmap/` folders have to
stay for as long as an old version of the app is in use.

For the same reason, **do not rename this repository** without a plan for those
addresses. GitHub forwards everything about a renamed repository except its
Pages site: `…github.io/tepuy-pages/…` would stop answering. With the custom
domain attached and the name unchanged, GitHub Pages is expected to send those
addresses on to `hatilu.com`, where the forwarding pages take over. Check that
with a real request after attaching the domain.

## Going live on hatilu.com

Nothing in the pages needs to change for the domain. The steps, in order:

1. **Buy `hatilu.com`** at Cloudflare Registrar.
2. **DNS at Cloudflare**, every record set to "DNS only" (grey cloud), so GitHub
   can issue the certificate:
   - `A` records for `@` to `185.199.108.153`, `185.199.109.153`,
     `185.199.110.153` and `185.199.111.153`
   - `CNAME` for `www` to `javierjosefernandes.github.io`
3. **GitHub**: verify the domain under the account's Pages settings, then set
   `hatilu.com` as the custom domain in this repository's Pages settings and
   turn on "Enforce HTTPS". GitHub commits a `CNAME` file to `main`.
4. **Email Routing at Cloudflare**: forward `hello@hatilu.com` and
   `press@hatilu.com` to a real inbox. Both are printed on the site and bounce
   until this is done.
5. **Cloudflare Web Analytics**: add the site, copy its token, then:

   ```sh
   TOKEN=paste-the-token-here
   grep -rl '<!-- analytics -->' --include='*.html' . | xargs sed -i '' \
     "s|<!-- analytics -->|<script defer src=\"https://static.cloudflareinsights.com/beacon.min.js\" data-cf-beacon='{\"token\": \"$TOKEN\"}'></script>|"
   ```

   It sets no cookie and collects no personal data. New pages get the same line
   in their `<head>`.
6. **Campaign links**: the App Store links carry a campaign name (`ct=`), but
   App Store Connect only counts them with the account's provider token. Copy it
   from the campaign link generator in App Store Connect, then:

   ```sh
   PT=paste-the-provider-token-here
   grep -rl 'apps.apple.com/app/id' --include='*.html' . | xargs sed -i '' \
     "s|\(apps\.apple\.com/app/id[0-9]*\)?ct=\([a-z0-9-]*\)|\1?pt=$PT\&amp;ct=\2\&amp;mt=8|g"
   ```

7. **Search engines**: add `hatilu.com` to Google Search Console as a domain
   property (a `TXT` record at Cloudflare), submit `https://hatilu.com/sitemap.xml`,
   and import the site into Bing Webmaster Tools.
8. **Tepuy**: once the domain answers, set the marketing URL to
   `https://hatilu.com/tepuy/` and the privacy and support URLs to their new
   addresses in App Store Connect, and update the privacy and roadmap URLs in
   the app's config for its next release.
