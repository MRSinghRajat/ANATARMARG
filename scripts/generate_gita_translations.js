#!/usr/bin/env node
/**
 * Generates verse_translations SQL from gita_data.json
 * Run: node scripts/generate_gita_translations.js
 * Output: SUPABASE_GITA_TRANSLATIONS.sql
 */

const fs = require("fs");
const path = require("path");

// Load data - use the JSON file or inline data
let data;
try {
  const jsonPath = path.join(__dirname, "gita_data_full.json");
  data = JSON.parse(fs.readFileSync(jsonPath, "utf8"));
} catch (e) {
  console.error("Create gita_data_full.json with the full verse data");
  process.exit(1);
}

function esc(s) {
  if (!s || typeof s !== "string") return "";
  return s.replace(/'/g, "''").replace(/\\/g, "\\\\");
}

let sql = `-- Bhagavad Gita Verse Translations - Chapters 1 & 2
-- Run after SUPABASE_GITA_DATA.sql
-- Generated from gita_data_full.json

`;

for (const d of data) {
  const vid = `bg_${d.chapter}_${d.verse}`;
  const hindi = esc(d.hindi);
  const english = esc(d.english);

  sql += `INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
('${vid}', 'hi', 'Hindi', '${hindi}', FALSE, 'Swami Tejomayananda'),
('${vid}', 'en', 'English', '${english}', TRUE, 'Swami Sivananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

`;
}

fs.writeFileSync(
  path.join(__dirname, "..", "SUPABASE_GITA_TRANSLATIONS.sql"),
  sql,
);
console.log(
  `Generated SUPABASE_GITA_TRANSLATIONS.sql with ${data.length} verses`,
);
