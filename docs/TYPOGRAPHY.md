# Typography house rules (AM-51)

Four roles. Do not add a fifth font for a job one of these already covers.

| Role | Font | Use for |
|---|---|---|
| **UI chrome** | Inter | Buttons, labels, nav, system text, errors, form fields |
| **Sacred display** | Cormorant Garamond | Deity names, journey titles, temple/ceremonial headings |
| **Long-form reading** | Crimson Pro | Scripture, stories, chapters, verse body |
| **Devanagari** | Noto Serif Devanagari with reading; Noto Sans Devanagari with UI labels | Hindi / Sanskrit UI vs long-form |

**Not a new role:** Cinzel may remain where it already is until a dedicated pass; do not introduce it on new screens. Prefer Cormorant Garamond for new ceremonial headings.

**Retire incrementally (do not big-bang):**

- Poppins → Inter (start with Ashram gamification strings). Sequence **after AM-14** (Quests/Gamification removal deletes a large share of Poppins call sites).
- Libre Baskerville → Crimson Pro (2 files).
- Outfit, Tenor Sans, Plus Jakarta Sans — audit whether they do a job the four roles cannot; retire if not (also shrinks the AM-32/AM-39 font bundle).

New screens: `GoogleFonts.inter`, `GoogleFonts.cormorantGaramond`, or `GoogleFonts.crimsonPro` only (plus the Noto Devanagari pair for Hindi).
