# JSON-first academic CV

`data/cv.json` is the source of truth for profile, education, work, awards, talks, activities, skills and languages. Research publications and patents remain in BibTeX because BibTeX is a better source format for scholarly records.

## Structure

```text
.
├─ data/
│  ├─ cv.json
│  ├─ publications.bib
│  └─ patents.bib
├─ typst/
│  └─ modernpro-adapter.typ
├─ scripts/
│  └─ build-resume.mjs
├─ output/             # generated
│  ├─ resume.json
│  ├─ cv.html
│  └─ cv.pdf
├─ cv.typ
└─ package.json
```

## PDF with Typst

The adapter reads `data/cv.json` and maps it to `modernpro-cv:2.1.0`.

```bash
npm run build:pdf
```

or directly:

```bash
typst compile cv.typ output/cv.pdf
```

### Photo

The example keeps the existing photo path (`img/photo.jpg`) but disables it by default so the project compiles without the image. After placing the photo at that path, change:

```json
"x-typst": {
  "showPhoto": true
}
```

### Korean fallback font

Font fallback is presentation-specific, so keep it in `cv.typ`, not in the JSON data. For example, place this before `#show: cv.with(...)`:

```typst
#set text(font: ("Libertinus Serif", "Noto Serif CJK KR"))
```

## JSON Resume / HTML

`output/resume.json` is generated from `data/cv.json` plus the two BibTeX files:

```bash
npm run build:data
```

Install the renderer/theme once:

```bash
npm install
```

Then generate HTML:

```bash
npm run build:html
```

This uses the `academic-cv-lite` theme. Change the theme in `package.json` as desired.

`resume.json` follows the standard JSON Resume fields where possible. Academic-only information is kept under `x-academic`, including patents, invited talks, mentoring/evaluation activities and other publications. Stock JSON Resume themes may ignore these custom fields; a custom academic theme can render them without changing the source data.

## Data design

Standard JSON Resume fields used directly:

- `basics`
- `education`
- `work`
- `awards`
- `skills`
- `languages`
- generated `publications`

Academic extensions:

- `x-academic.otherPublications`
- `x-academic.invitedTalks`
- `x-academic.activities`
- generated `x-academic.patents`

Typst-only presentation options live under `x-typst`, keeping visual settings out of the semantic CV data.

## Bib Sorting

`biber --tool --configfile=sort.conf publications.bib`
