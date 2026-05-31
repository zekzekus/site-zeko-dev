# site-zeko-dev

Source of [zeko.dev](https://zeko.dev). Built with [Zola](https://www.getzola.org/), deployed on Cloudflare Pages.

## Local development

This repo ships a Nix flake. The only dependency you need on your machine is Nix.

```sh
nix develop                # drops you in a shell with zola 0.22.1
zola serve                 # live preview on http://127.0.0.1:1111
zola build                 # produce ./public
zola check                 # validate internal links + content
```

If you use [direnv](https://direnv.net/), create `.envrc`:

```sh
echo 'use flake' > .envrc && direnv allow
```

Then zola is on your PATH automatically when you `cd` here.

To build with pure Nix (no dev shell):

```sh
nix build              # output in ./result
```

## Writing a new post

```sh
$EDITOR content/posts/my-new-post.md
```

Minimal frontmatter:

```toml
+++
title = "My new post"
date = 2026-06-01

[taxonomies]
tags = ["foo"]
categories = ["personal"]
+++

Markdown body here.
```

Drafts: add `draft = true` to keep it out of production builds.
Run `zola serve --drafts` to preview drafts locally.

## Project layout

```
.
├── flake.nix              # Nix dev shell + build (pinned Zola)
├── config.toml            # Zola site config
├── content/
│   ├── _index.md          # homepage intro
│   ├── about.md           # /about/
│   └── posts/
│       ├── _index.md      # /posts/ section index
│       └── *.md           # individual posts → /posts/<slug>/
├── templates/             # Tera templates (base, index, section, page, taxonomy_*)
├── static/                # copied verbatim to site root
│   ├── style.css
│   └── _redirects         # Cloudflare Pages redirect rules
└── public/                # build output (git-ignored)
```

## Deploying to Cloudflare Pages

The site is plain static HTML so any static host works. Below is the
recommended Cloudflare Pages setup.

### 1. Create the Pages project

1. Log in at <https://dash.cloudflare.com> → **Workers & Pages** → **Create** → **Pages** → **Connect to Git**.
2. Authorize Cloudflare to read this GitHub repo.
3. **Production branch:** `master` (or whatever your default is).
4. **Framework preset:** select **Zola**. The build command and output
   directory will be filled in automatically:
   - Build command: `zola build`
   - Build output: `public`
5. Under **Environment variables (advanced)** add:
   - `ZOLA_VERSION` = `0.22.1`  *(pins to what we develop against; Pages
     v3 build image preinstalls this so the build is instant)*
6. **Save and Deploy.** First build takes ~30s. You get a
   `<project>.pages.dev` URL.

### 2. (Optional) Make preview deployments work with correct URLs

Branch / PR previews live on `https://<branch>.<project>.pages.dev`. By
default, `base_url` from `config.toml` is hardcoded into asset URLs.
Replace the build command with:

```sh
if [ "$CF_PAGES_BRANCH" = "master" ]; then zola build; else zola build --base-url $CF_PAGES_URL; fi
```

### 3. Point zeko.dev at Cloudflare Pages

1. In the Pages project → **Custom domains** → **Set up a custom domain** → enter `zeko.dev`.
2. Cloudflare gives you either DNS records to add, or — if `zeko.dev`
   already uses Cloudflare nameservers — sets them up for you with one
   click. Add `www.zeko.dev` too if you want it to redirect.
3. SSL provisions automatically (a few minutes).
4. Once DNS resolves, deactivate the old GitHub Pages site:
   - In the [`zekzekus/zekzekus.github.com`](https://github.com/zekzekus/zekzekus.github.com)
     repo → Settings → Pages → set source to "None", or archive the
     repo. (Don't delete it — preserves history of the old site.)

### 4. URL compatibility with the old Hugo site

All Hugo URLs are preserved 1:1 — no broken links, no redirects needed
for content:

| Old (Hugo)                                | New (Zola)                                |
|-------------------------------------------|-------------------------------------------|
| `/`                                       | `/`                                       |
| `/about/`                                 | `/about/`                                 |
| `/posts/`                                 | `/posts/`                                 |
| `/posts/fp-001/`                          | `/posts/fp-001/`                          |
| `/posts/kosmasaydim-yazamazdim/`          | (same)                                    |
| `/posts/kostugum-halde-yapamadim/`        | (same)                                    |

For the RSS feeds, Hugo emitted `/posts/index.xml`; Zola emits
`/posts/atom.xml`. [`static/_redirects`](static/_redirects) sends the old
paths to the new ones with HTTP 301, so existing subscribers keep
working.
