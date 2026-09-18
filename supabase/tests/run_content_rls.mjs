#!/usr/bin/env node
// Uses actual PostgreSQL (PGlite WASM), with no network or persistent database.
// npm install --prefix /tmp/antarmarg-backend-tools @electric-sql/pglite
// PGLITE_MODULE=/tmp/antarmarg-backend-tools/node_modules/@electric-sql/pglite/dist/index.js node supabase/tests/run_content_rls.mjs
import { readFile } from 'node:fs/promises';
import { dirname, resolve, isAbsolute } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
const moduleName = process.env.PGLITE_MODULE || '@electric-sql/pglite';
const { PGlite } = await import(isAbsolute(moduleName) ? pathToFileURL(moduleName).href : moduleName);
async function expand(file) {
  const lines = (await readFile(file, 'utf8')).split('\n');
  const result = [];
  for (const line of lines) {
    if (line.startsWith('\\ir ')) result.push(await expand(resolve(dirname(file), line.slice(4).trim())));
    else if (line.startsWith('\\set ') || line.startsWith('\\echo ')) continue;
    else if (line.startsWith('\\')) throw new Error(`Unsupported psql directive: ${line}`);
    else result.push(line);
  }
  return result.join('\n');
}
const db = new PGlite();
try {
  await db.exec(await expand(fileURLToPath(new URL('./l07_content_rls.sql', import.meta.url))));
  console.log('PASS: PostgreSQL L07 content RLS fixture, including migration reapplication');
} catch (error) {
  console.error(`FAIL: ${error.message}`);
  process.exitCode = 1;
} finally {
  await db.close();
}
