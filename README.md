# max-schons-public

Things Max Schons thinks are worth sharing — FAQs, recommendations, lists, templates, checklists. The repo is the source of truth; a lightweight Jekyll site renders the same content in a browsable form.

**Live site:** _(TBD — custom domain pending: max.me / max.blog)_

## Structure

### Top level: one folder per **life area**

- [`global/`](global/) — cross-domain and identity-level content
- [`life-admin/`](life-admin/) — operational life infrastructure (services, logistics)
- [`social/`](social/) — people and relationships
- [`travel/`](travel/) — places
- [`self-care/`](self-care/) — health, body, wellbeing
- [`professional/`](professional/) — work, career, projects

**When content overlaps two areas**, use reader intent as the tiebreaker:

- **travel** — info about *places*
- **social** — info about *people / relationships*
- **self-care** — *practices / routines* for body and mind
- **life-admin** — operational *life infrastructure*
- **professional** — *work / career*
- **global** — *cross-domain* or *identity-level*

### Within each life area: consistent shape

Each life area may contain any of:

- **`faq/`** — one markdown file per question. Example: [`life-admin/faq/how-i-organize-my-contacts.md`](life-admin/faq/how-i-organize-my-contacts.md).
- **`checklists/`** — process runbooks (things to do, in order). Example: [`life-admin/checklists/arriving-in-a-new-country.md`](life-admin/checklists/arriving-in-a-new-country.md).
- **`templates/`** — blank templates to copy into your own doc. Example: [`professional/templates/one-on-one-check-in.md`](professional/templates/one-on-one-check-in.md).
- **`preferences.md`** — how I like operational things done in that area.
- **`*.tsv`** — tabular data (services I use, belongings, budget tiers).
- **`images/`** — images referenced by content in that area.
- Other topic-specific `.md` files for longer write-ups (e.g. [`travel/singapore-recommendations.md`](travel/singapore-recommendations.md)).

### Aggregated pages (built automatically from sources)

On the live site:

- `/faq/` — every FAQ entry across all areas, grouped by area
- `/<area>/faq/` — every FAQ entry for one area
- `/<area>/<tsv-name>/` — each TSV file rendered as an HTML table

These are generated at build time from the source files; they don't exist in the repo.

## Subscribe

- **RSS / Atom:** https://github.com/mxschons/max-schons-public/commits/main/CHANGELOG.md.atom — every commit that touches [`CHANGELOG.md`](CHANGELOG.md) becomes a feed entry.
- **Email:** _(follow.it link pending)_

## Private values

Some content (e.g. specific banks, insurers, service providers) is abstracted as `${VARNAME}` tokens. The real values live in a local `.env` file (gitignored) matching [`.env.example`](.env.example). Public visitors see the tokens as-is; local AI workflows can resolve them by reading `.env`.

A lint script ([`script/lint_tokens.rb`](script/lint_tokens.rb)) runs in CI and fails the build if a token appears in content without a matching declaration in `.env.example`.

## License

CC0 1.0 — public domain. See [LICENSE](LICENSE). Use anything here without asking.
