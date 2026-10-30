# System diagram: vision spec (draft)

Started 2026-10-30. Brainstorming notes for the next version of the system diagram
(`static/web/system_diagram.drawio.xml` → `system_diagram.png`). The diagram will be used as
a tool to develop the vision, so the new version stays unpublished on its own branch until
things take shape over the coming months.

## Framing

Kalpataru Grove supports a larger goal: **the internet as a digital Sanskrit library**. The
library itself is the set of e-text collections out there; the grove's job is mostly to make
that library knowable (what exists, where, how much, of which works) and, in a smaller way,
to add to it.

Sources for the vision: the ISCLS 2027 paper ("Sāgarasaṅgama: Fathoming the Sanskrit E-Text
Oceans", `Dropbox/Docs/Projects/Workshops_Conferences/2027.01 ISCLS 9/paper/`) and the blog
post https://tylerneill.info/blog/sagarasangama.

## Tiers of importance

The current diagram gives every project equal weight. The next one should make the ranking
visible.

1. **Core: clarifying what exists** (highest impact)
   - **Sāgarasaṅgama** and its **Atlases**: finding aids for the very large collections,
     with combined counts, growth, and federated title search.
   - **SETI**: the register of e-texts in smaller scholarly collections, linked to Pandit
     work IDs.
   - **PANDiT** (external): the authority records for works.
   - **Pāṇḍitya**: the visual window onto works with their e-texts overlaid. (Open question:
     core, or a consumer of the core?)
2. **Production: my corner, adding new material**
   - **HANSEL**: new e-texts. Note that HANSEL is itself one more collection in the library,
     feeding SETI like any other.
   - **Skrutable**: OCR, transliteration, metrical analysis.
   - **editing (manual + AI)**, **source PDFs**.
   - **Pramāṇa NLP** text collection: now mainly something that will feed HANSEL.
3. **Inspiration / periphery**
   - **Vātāyana**: still the inspiration for NLP applications, but not central to the vision.
   - **Firewatch**: ops tooling (mainly useful for debugging the server drag Vātāyana
     caused). Candidate to shrink to a small "ops" note or drop.

## Data flows to show

Existing today:
- Large collections → Atlases (scraped or bulk metadata, sizes, dates) → Sāgarasaṅgama
  (reads only each Atlas's published `tree.json` + `changelog.json`).
- Smaller collections, HANSEL, Pramāṇa NLP → SETI (metadata); PANDiT → SETI (work IDs).
- SETI + PANDiT → Pāṇḍitya.
- Source PDFs → Skrutable / editing → HANSEL.

Planned (paper §3):
- Atlas enumerations → new rows in SETI.
- SETI's smaller collections → one combined pseudo-Atlas → Sāgarasaṅgama.
- Edition and quality annotations in SETI → deduplication → **D1**, the dated inventory of
  all extant e-texts (one per deduplication policy).
- Further out: SETI → Pandit → New Catalogus Catalogorum → **D2**, all premodern works that
  could have an e-text. Probably shown as a destination, not as system.

## Layout ideas

- **Organize around the library, not around the apps.** One option is left to right:
  the collections (external, the library itself) → finding layer (Atlases, SETI,
  Sāgarasaṅgama, Pāṇḍitya) → what it yields (D1, later D2). The production corner sits
  off to one side and feeds new material back into the collections pool (via HANSEL).
- **Split the collections.** Name the five large "oceans" (Sanskrit Wikisource,
  E-bharatisampat, Sanskrit Documents, Jain eLibrary, GRETIL) separately from the smaller
  scholarly collections SETI covers. The paper's core claim is that they differ in kind.
  GRETIL appears in both, which is worth showing as the dedup case.
- **Size and placement show importance.** The core tier gets the centre and the largest
  nodes; Vātāyana and Firewatch shrink to the edges.
- **Visual conventions:**
  - solid = exists, a distinct colour or style = planned, dashed = external (keep the
    current meaning of dashed);
  - one colour per tier;
  - same-kind nodes the same size;
  - orthogonal connectors;
  - merge the repeated "metadata" / "text" labels.
- **Screenshot strip:** keep it only for the core tier, or drop it. Screenshots go stale, and
  they are most of the source file's 1.7 MB.
- **Status markers:** Atlases are at different stages (as of Oct 2026: Wikisource, Sanskrit
  Documents, E-bharatisampat published; Jain eLibrary, GRETIL in development). A small
  badge per Atlas, or a single "×5" stack with a note.

## Open questions

- Is Pāṇḍitya core (the place the inventory becomes visible) or a consumer?
- Show the planned flows at all on the public version, or only on the working branch?
- One "Atlases ×5" node or five named ones?
- Where does Pramāṇa NLP go once it feeds HANSEL: its own node in the production corner,
  or folded into HANSEL's inputs?
- Firewatch: keep, shrink, or drop?
- Does D2 / the NCC belong on a *system* diagram, or in a separate "roadmap" figure?

## Interim change (2026-10-30, branch `add-sagarasangama`)

A lightweight addition only, to merge with the homepage update: a "Sāgarasaṅgama web
interface" node in the empty bottom right, with one line from "Other text collections"
("metadata (via Atlases)") and a two-way line to SETI ("metadata (planned)"). No screenshot,
no restyling. Everything above is for a later branch.
