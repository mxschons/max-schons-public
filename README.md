# max-schons-public

Things Max Schons thinks are worth sharing — FAQs, lists, recommendations, templates. The repo is the source of truth; a lightweight Jekyll site renders the same content in a browsable form.

**Live site:** _(TBD — custom domain pending: max.me / max.blog)_

## Browse by life area

- [`global/`](global/) — cross-domain and identity-level content
- [`life-admin/`](life-admin/) — operational life infrastructure (services, logistics)
- [`social/`](social/) — people and relationships
- [`travel/`](travel/) — places
- [`self-care/`](self-care/) — practices and routines
- [`professional/`](professional/) — work, career, projects

### How to decide which folder something goes in

When content overlaps, use reader intent:

- **travel** — info about *places*
- **social** — info about *people/relationships*
- **self-care** — *practices/routines*
- **life-admin** — operational *life infrastructure*
- **professional** — *work/career*
- **global** — *cross-domain / identity-level*

## Subscribe

- **RSS/Atom:** https://github.com/mxschons/max-schons-public/commits/main/CHANGELOG.md.atom
- **Email:** _follow.it link pending._

## Private values

Some content (e.g. specific banks, insurers, service providers) is abstracted as `${VARNAME}` tokens. The real values live in a local `.env` file (gitignored) matching [`.env.example`](.env.example). Public visitors see the tokens as-is; local AI workflows can resolve them by reading `.env`.

## License

CC0 1.0 — public domain. See [LICENSE](LICENSE). Use anything here without asking.
