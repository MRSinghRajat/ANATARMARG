# MVP content review packet

Prepared 2026-09-15. Draft only: no content imported, published, or approved. The UI discovery allowlist expresses product scope; it is not evidence of editorial approval. Existing active and paused journeys retain their full catalog metadata.

## Proposed free starter: daily-practice-7

Audience: adults starting a personal daily Hindu spiritual practice, Hindi or English. Seven days, one optional five-minute activity each day, no payment, required equipment, breath retention or promised health outcome. Users may shorten or skip any activity. These are original app instructions, not scripture quotations or translations. A Hindi editor and a knowledgeable Hindu-practice reviewer must approve both versions before import.

| Day | English draft | Hindi draft |
| --- | --- | --- |
| 1 | **Make a little space.** Choose a comfortable place to sit. Keep your eyes open or closed, as you prefer. Take a moment to notice your surroundings. Ask yourself: what would I like to bring to today's practice? Stay for up to five minutes. | **अपने लिए थोड़ा समय निकालें।** बैठने के लिए आरामदायक जगह चुनें। अपनी सुविधा के अनुसार आँखें खुली रखें या बंद करें। कुछ पल अपने आसपास ध्यान दें। स्वयं से पूछें: आज के अभ्यास में मैं किस भाव के साथ आना चाहता हूँ? अपनी सुविधा के अनुसार पाँच मिनट तक बैठें। |
| 2 | **Remember gratitude.** Think of one person, experience or everyday kindness for which you are grateful. If prayer is part of your tradition, you may offer a short prayer in your own words. Spend a few quiet moments with that memory. | **कृतज्ञता याद करें।** किसी व्यक्ति, अनुभव या छोटी-सी सहायता को याद करें जिसके लिए आप आभारी हैं। यदि प्रार्थना आपकी परंपरा का हिस्सा है, तो अपने शब्दों में छोटी-सी प्रार्थना कर सकते हैं। उस स्मृति के साथ कुछ शांत पल बिताएँ। |
| 3 | **Read with attention.** Choose a short passage from a sacred text you know, or a reading available to you in the library. Read at your own pace. Which word or idea would you like to think about today? There is no quiz or required answer. | **ध्यान से पढ़ें।** किसी परिचित पवित्र ग्रंथ का छोटा अंश चुनें, या ग्रंथालय में उपलब्ध पाठ पढ़ें। अपनी गति से पढ़ें। आज किस शब्द या विचार पर मनन करना चाहेंगे? कोई परीक्षा या अनिवार्य उत्तर नहीं है। |
| 4 | **Pause before an action.** Choose one ordinary task today. Before starting, pause briefly and decide how you would like to approach it: with care, patience or honesty. Afterward, notice what you experienced without judging yourself. | **काम शुरू करने से पहले ठहरें।** आज का कोई साधारण काम चुनें। शुरू करने से पहले कुछ पल ठहरें और तय करें कि उसे किस भाव से करना चाहेंगे: सावधानी, धैर्य या ईमानदारी से। काम के बाद, स्वयं को परखे बिना अपने अनुभव पर ध्यान दें। |
| 5 | **Practice kindness.** Choose one small act of kindness that fits your circumstances. You might listen attentively, share a helpful word or offer practical help. Keep it within your time and resources. Reflect on the experience for a moment. | **दयालुता का अभ्यास करें।** अपनी परिस्थिति के अनुसार दयालुता का एक छोटा काम चुनें। आप ध्यान से सुन सकते हैं, कोई सहायक बात कह सकते हैं या व्यावहारिक मदद दे सकते हैं। अपने समय और साधनों की सीमा का ध्यान रखें। अनुभव पर कुछ पल मनन करें। |
| 6 | **Return to your practice.** Repeat the activity from this week that felt most approachable. A brief practice is enough. If you missed a day, you can simply begin again today. | **अपने अभ्यास पर लौटें।** इस सप्ताह का वह अभ्यास दोहराएँ जो आपको सबसे सहज लगा। थोड़ा समय भी पर्याप्त है। यदि कोई दिन छूट गया हो, तो आज फिर से शुरू कर सकते हैं। |
| 7 | **Choose your next week.** Look back at the week. What did you enjoy? What was difficult to fit into your day? Choose one practice and a convenient time to return to it next week. You can continue these activities without buying a program. | **अगला सप्ताह चुनें।** बीते सप्ताह पर विचार करें। क्या अच्छा लगा? दिनचर्या में किस अभ्यास के लिए समय निकालना कठिन था? अगले सप्ताह के लिए एक अभ्यास और सुविधाजनक समय चुनें। इन अभ्यासों को जारी रखने के लिए कोई कार्यक्रम खरीदना आवश्यक नहीं है। |

Before import: replace Day 3's optional library choice with a verified free text route if the importer requires a destination. Set seven-day duration, once-per-day completion, guest behavior and recurrence through the existing journey framework. Do not insert an empty journey card merely to fill the launch catalog. Test all seven days and both languages after import.

## Paid program readiness and concrete review flags

| Candidate | Source in repository | Required review evidence |
| --- | --- | --- |
| Hanuman Chalisa 40 days | `supabase/migrations/20240101000038_new_journeys_schema_and_seed.sql`; `20240101000039_hanuman_journey_granthalaya_link.sql` | Authoritative scripture edition, rights for each translation/transliteration/audio/image, full 40-day route coverage, reviewed pronunciation, cadence and respectful accessible alternatives |
| Workday reflection 21 days (`work-stress-21`) | `supabase/migrations/20240101000038_new_journeys_schema_and_seed.sql` | Remove unsupported physiological promises; human review of breath instructions; Hindi coverage, complete 21-day routes and appropriate naming |
| Other specialist/Gayatri/child programs | Existing seed migrations | Deferred from new discovery. Preserve current users' records and continuation; separate qualified review before promoting again |

Concrete unapproved copy in the workday seed includes “Reduces cortisol ... within 3 minutes,” “balancing left/right hemispheres,” “rewires the stress response over 21 days,” and a day-21 statement that neural pathways become the default. Proposed editing direction: describe the observable activity (a short pause or reflection) without asserting physiological or guaranteed outcomes. Changing historical seed text alone will not correct the live content: prepare a narrowly scoped content update after reviewing the actual exported rows.

For every published asset record: stable content ID, live-table source, original source/edition, copyright/license or author permission, English reviewer/date, Hindi reviewer/date, transliteration reviewer/date where applicable, audio/image rights, broken-link check, and final approval. No approvals or rights are inferred from public availability or this draft.

## Remaining UI/accessibility release checks

Locally addressed: placeholder Listen navigation, unsupported audio upsell, focused new journey discovery, actual About destination, scrollable bilingual reader settings, labelled reader toolbar controls, bounded persisted font sizes.

Still required: physical VoiceOver traversal of reading and card layouts; maximum iOS Dynamic Type throughout all main screens; actual text/background contrast across themes; reviewed pronunciation content (the settings controls do not create it); working owner-supplied support contact and public legal hosting; seven-day starter import; editorial approval of launch programs.
