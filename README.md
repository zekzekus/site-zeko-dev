# site-zeko-dev

Source of [zeko.dev](https://zeko.dev). Built with [Zola](https://www.getzola.org/),
deployed on Cloudflare Workers (Static Assets).

## Local dev

Requires Nix. Everything else is pinned by the flake.

```sh
nix develop          # shell with zola + babashka
bb tasks             # list available tasks
bb serve             # http://127.0.0.1:1111, live reload (drafts on)
bb check             # validate internal links
bb build             # produce ./public
```

## Writing

```sh
$EDITOR content/posts/my-post.md
```

```toml
+++
title = "My post"
date = 2026-06-01

[taxonomies]
tags = ["foo"]
categories = ["personal"]
+++

Markdown body.
```

Add `draft = true` to keep it out of production; `zola serve --drafts` to preview.

## Deploy

```sh
bb deploy "commit message"   # check, build, add+commit if dirty, push
```

`git push` triggers Cloudflare Workers to rebuild via [build.sh](build.sh)
(installs pinned Zola, runs `zola build --minify`) and deploy `./public` to the
Worker configured in [wrangler.jsonc](wrangler.jsonc). Custom domain `zeko.dev`
is attached in the Cloudflare dashboard.

PR branches get automatic preview URLs at `<branch>.site-zeko-dev.<account>.workers.dev`.

## Layout

```
.
├── flake.nix          # nix dev shell + reproducible build
├── bb.edn             # babashka tasks (serve / check / build / deploy)
├── wrangler.jsonc     # Cloudflare Worker config (static assets)
├── build.sh           # CI build (pinned Zola → zola build)
├── config.toml        # Zola site config
├── content/
│   ├── _index.md      # /
│   ├── about.md       # /about/
│   └── posts/*.md     # /posts/<slug>/
├── templates/         # Tera templates
└── static/            # copied verbatim to site root
    ├── style.css
    └── _redirects     # 301s for legacy Hugo RSS paths
```
