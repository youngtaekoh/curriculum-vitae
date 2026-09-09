import fs from 'node:fs';
import path from 'node:path';

const root = path.resolve(path.dirname(new URL(import.meta.url).pathname), '..');
const dataPath = path.join(root, 'data', 'cv.json');
const outputDir = path.join(root, 'output');
const outPath = path.join(outputDir, 'resume.json');

function stripOuter(value) {
  let v = value.trim();
  if ((v.startsWith('{') && v.endsWith('}')) || (v.startsWith('"') && v.endsWith('"'))) {
    v = v.slice(1, -1);
  }
  return v.replace(/\s+/g, ' ').trim();
}

function splitTopLevel(input, separator = ',') {
  const out = [];
  let depth = 0;
  let inQuote = false;
  let escaped = false;
  let start = 0;
  for (let i = 0; i < input.length; i++) {
    const ch = input[i];
    if (escaped) { escaped = false; continue; }
    if (ch === '\\') { escaped = true; continue; }
    if (ch === '"' && depth === 0) inQuote = !inQuote;
    if (!inQuote) {
      if (ch === '{') depth++;
      else if (ch === '}') depth--;
      else if (ch === separator && depth === 0) {
        out.push(input.slice(start, i));
        start = i + 1;
      }
    }
  }
  out.push(input.slice(start));
  return out;
}

function parseBibTeX(text) {
  const entries = [];
  let i = 0;
  while (i < text.length) {
    const at = text.indexOf('@', i);
    if (at < 0) break;
    const typeMatch = text.slice(at + 1).match(/^([A-Za-z]+)\s*\{/);
    if (!typeMatch) { i = at + 1; continue; }
    const type = typeMatch[1].toLowerCase();
    const open = at + 1 + typeMatch[0].lastIndexOf('{');
    let depth = 1, inQuote = false, escaped = false, j = open + 1;
    for (; j < text.length && depth > 0; j++) {
      const ch = text[j];
      if (escaped) { escaped = false; continue; }
      if (ch === '\\') { escaped = true; continue; }
      if (ch === '"') inQuote = !inQuote;
      if (!inQuote) {
        if (ch === '{') depth++;
        else if (ch === '}') depth--;
      }
    }
    const body = text.slice(open + 1, j - 1).trim();
    const parts = splitTopLevel(body);
    const key = (parts.shift() || '').trim();
    const fields = {};
    for (const part of parts) {
      const eq = part.indexOf('=');
      if (eq < 0) continue;
      const name = part.slice(0, eq).trim().toLowerCase();
      const raw = part.slice(eq + 1).trim();
      // Preserve simple BibTeX concatenations as readable text.
      const value = raw.split('#').map(stripOuter).join(' ').replace(/~+/g, ' ').trim();
      fields[name] = value;
    }
    entries.push({ type, key, ...fields });
    i = j;
  }
  return entries;
}

function cleanLatex(s = '') {
  return s
    .replace(/\\&/g, '&')
    .replace(/\\%/g, '%')
    .replace(/\\_/g, '_')
    .replace(/\\textit\{([^{}]*)\}/g, '$1')
    .replace(/\\textbf\{([^{}]*)\}/g, '$1')
    .replace(/[{}]/g, '')
    .replace(/~/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

function toJsonResumePublication(e) {
  const container = e.journal || e.booktitle || e.publisher || e.organization || '';
  const authors = cleanLatex(e.author || '');
  const title = cleanLatex(e.title || e.key);
  const year = cleanLatex(e.year || '');
  const doi = cleanLatex(e.doi || '');
  const url = cleanLatex(e.url || (doi ? `https://doi.org/${doi}` : ''));
  const details = [
    container && cleanLatex(container),
    e.volume && `vol. ${cleanLatex(e.volume)}`,
    e.number && `no. ${cleanLatex(e.number)}`,
    e.pages && `pp. ${cleanLatex(e.pages)}`,
  ].filter(Boolean).join(', ');

  return {
    name: title,
    publisher: details,
    releaseDate: year,
    url,
    summary: authors,
    'x-key': e.key,
    'x-type': e.type,
    'x-authors': authors,
    'x-doi': doi || undefined,
  };
}

function byNewest(a, b) {
  const ay = Number.parseInt(a.releaseDate || '0', 10) || 0;
  const by = Number.parseInt(b.releaseDate || '0', 10) || 0;
  return by - ay || a.name.localeCompare(b.name);
}

function flattenHighlights(highlights = []) {
  return highlights.flatMap((highlight) => {
    if (typeof highlight === 'string') return highlight;

    const heading = [highlight.label, highlight.text].filter(Boolean).join(': ');
    return [heading, ...(highlight.children || [])].filter(Boolean);
  });
}

const base = JSON.parse(fs.readFileSync(dataPath, 'utf8'));
const academic = base['x-academic'] || {};
const bib = academic.bibliography || {};

const publicationsBib = path.resolve(root, bib.publications || 'data/publications.bib');
const patentsBib = path.resolve(root, bib.patents || 'data/patents.bib');

const publications = parseBibTeX(fs.readFileSync(publicationsBib, 'utf8'))
  .map(toJsonResumePublication)
  .sort(byNewest);

const patents = parseBibTeX(fs.readFileSync(patentsBib, 'utf8'))
  .map(toJsonResumePublication)
  .sort(byNewest);

const resume = structuredClone(base);
resume.publications = publications;
resume.work = (resume.work || []).map((job) => ({
  ...job,
  highlights: flattenHighlights(job.highlights),
}));
resume['x-academic'] = {
  ...academic,
  patents,
};

fs.mkdirSync(outputDir, { recursive: true });
fs.writeFileSync(outPath, JSON.stringify(resume, null, 2) + '\n');
console.log(`Wrote ${path.relative(root, outPath)} (${publications.length} publications, ${patents.length} patents)`);
