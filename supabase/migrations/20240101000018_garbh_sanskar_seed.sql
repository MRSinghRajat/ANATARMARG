-- ============================================================
-- GARBH SANSKAR SEED DATA
-- Comprehensive content: mantras, meditations, yoga, diet tips,
-- affirmations, and lullabies for all 40 weeks + postnatal
-- ============================================================

-- ============================================================
-- SECTION 1: MANTRAS (Prenatal - All Trimesters)
-- ============================================================

INSERT INTO garbh_sanskar_content (phase, content_type, trimester, week_start, week_end, title, title_hindi, title_sanskrit, subtitle, description, body_text, transliteration, translation, duration_seconds, deity_associated, benefits, tags, coins_reward, is_premium, order_index) VALUES

-- Garbh Gayatri Mantra (All trimesters)
('prenatal', 'mantra', NULL, 1, 40,
 'Garbh Gayatri Mantra', 'गर्भ गायत्री मंत्र', 'गर्भ गायत्री',
 'The sacred mantra for the unborn child',
 'The Garbh Gayatri is a special form of the Gayatri Mantra dedicated to the protection and nourishment of the unborn child. Recite it 108 times daily, ideally in the morning after bathing.',
 'ॐ भूर्भुवः स्वः\nतत्सवितुर्वरेण्यं\nभर्गो देवस्य धीमहि\nधियो यो नः प्रचोदयात्',
 'Om Bhur Bhuvah Svah\nTat Savitur Varenyam\nBhargo Devasya Dhimahi\nDhiyo Yo Nah Prachodayat',
 'We meditate on the divine light of the Sun (Savitri). May that divine light illuminate our intellect.',
 180, 'surya',
 ARRAY['Stimulates baby''s brain development', 'Reduces maternal anxiety', 'Promotes positive energy in the womb'],
 ARRAY['gayatri', 'mantra', 'daily', 'all_trimesters'],
 10, false, 1),

-- Om Namah Shivaya (All trimesters)
('prenatal', 'mantra', NULL, 1, 40,
 'Om Namah Shivaya', 'ॐ नमः शिवाय', 'ॐ नमः शिवाय',
 'The Panchakshara — five-syllable mantra of Lord Shiva',
 'One of the most powerful mantras in Hinduism. The five syllables Na-Ma-Shi-Va-Ya represent the five elements (earth, water, fire, air, ether) and purify all five. Reciting this mantra during pregnancy fills the womb with divine vibrations.',
 'ॐ नमः शिवाय\nॐ नमः शिवाय\nॐ नमः शिवाय',
 'Om Namah Shivaya',
 'I bow to Shiva — the inner Self, the divine consciousness within all beings.',
 300, 'shiva',
 ARRAY['Deep calming effect on mother and baby', 'Purifies the environment', 'Strengthens the mother''s resolve'],
 ARRAY['shiva', 'panchakshara', 'mantra', 'calming'],
 10, false, 2),

-- Vishnu Sahasranama (2nd and 3rd trimester)
('prenatal', 'mantra', NULL, 14, 40,
 'Vishnu Sahasranama (Selected Verses)', 'विष्णु सहस्रनाम', 'विष्णु सहस्रनाम',
 '108 names of Lord Vishnu for the baby''s protection',
 'The Vishnu Sahasranama contains 1000 names of Lord Vishnu. Listening to or reciting selected verses during pregnancy is believed to invoke divine protection for the child and instil noble qualities.',
 'ॐ विश्वं विष्णुर्वषट्कारो भूतभव्यभवत्प्रभुः ।\nभूतकृद्भूतभृद्भावो भूतात्मा भूतभावनः ॥\nपूतात्मा परमात्मा च मुक्तानां परमागतिः ।\nअव्ययः पुरुषः साक्षी क्षेत्रज्ञोऽक्षर एव च ॥',
 'Om Vishvam Vishnur Vashatkaro Bhuta-Bhavya-Bhavat-Prabhuh\nBhuta-Krid Bhuta-Bhrid Bhavo Bhutatma Bhuta-Bhavanah',
 'Vishnu is the universe itself, the Lord of past, present, and future. He is the creator, sustainer, and essence of all beings.',
 600, 'vishnu',
 ARRAY['Invokes divine protection', 'Promotes noble qualities in child', 'Calms the mother''s mind'],
 ARRAY['vishnu', 'sahasranama', 'protection', 'second_trimester'],
 15, false, 3),

-- Lalita Sahasranama (3rd trimester)
('prenatal', 'mantra', 3, 28, 40,
 'Lalita Sahasranama (Selected Verses)', 'ललिता सहस्रनाम', 'ललिता सहस्रनाम',
 'The 1000 names of the Divine Mother',
 'The Lalita Sahasranama from the Brahmanda Purana praises the Divine Mother in her form as Lalita Tripura Sundari. Reciting this during the third trimester invokes the Mother''s grace for a safe and smooth delivery.',
 'ॐ श्री माता श्री महाराज्ञी श्रीमत्सिंहासनेश्वरी ।\nचिदग्निकुण्डसम्भूता देवकार्यसमुद्यता ॥\nउद्यद्भानुसहस्राभा चतुर्बाहुसमन्विता ।\nरागस्वरूपापाशाढ्या क्रोधाकाराङ्कुशोज्ज्वला ॥',
 'Om Shri Mata Shri Maharajni Shrimat Simhasaneshvari\nChidagni-Kunda-Sambhuta Devakaryasamudyata',
 'O Divine Mother, the supreme queen seated on the throne of consciousness, born from the fire of pure awareness, ever ready to fulfil the divine purpose.',
 900, 'devi',
 ARRAY['Invokes Divine Mother''s grace for safe delivery', 'Reduces fear of childbirth', 'Fills the womb with divine feminine energy'],
 ARRAY['devi', 'lalita', 'third_trimester', 'safe_delivery'],
 15, true, 4),

-- Ganesha Mantra (1st trimester)
('prenatal', 'mantra', 1, 1, 13,
 'Ganesha Mantra for New Beginnings', 'गणेश मंत्र', 'गणपति मंत्र',
 'Remove obstacles from the path of your pregnancy',
 'Lord Ganesha is the remover of obstacles and the lord of new beginnings. Reciting his mantra at the start of pregnancy removes obstacles and ensures a smooth journey.',
 'ॐ गं गणपतये नमः\nवक्रतुण्ड महाकाय सूर्यकोटि समप्रभ ।\nनिर्विघ्नं कुरु मे देव सर्वकार्येषु सर्वदा ॥',
 'Om Gam Ganapataye Namah\nVakratunda Mahakaya Suryakoti Samaprabha\nNirvighnam Kuru Me Deva Sarvakaryeshu Sarvada',
 'O Ganesha with the curved trunk and mighty form, radiant as a million suns — please remove all obstacles from my path, always and in all endeavours.',
 240, 'ganesha',
 ARRAY['Removes obstacles in pregnancy', 'Brings auspiciousness', 'Calms first-trimester anxiety'],
 ARRAY['ganesha', 'first_trimester', 'obstacles', 'new_beginning'],
 10, false, 5),

-- Santana Gopala Mantra
('prenatal', 'mantra', NULL, 1, 40,
 'Santana Gopala Mantra', 'संतान गोपाल मंत्र', 'संतान गोपाल',
 'Krishna''s mantra for a healthy, blessed child',
 'The Santana Gopala mantra is specifically prescribed in the Puranas for couples who desire a child and for the protection of the unborn. It invokes Lord Krishna in his form as the protector of children.',
 'ॐ श्रीं ह्रीं क्लीं ग्लौं देवकीसुत गोविन्द वासुदेव जगत्पते\nदेहि मे तनयं कृष्ण त्वामहं शरणं गतः',
 'Om Shrim Hrim Klim Glaum Devaki-Suta Govinda Vasudeva Jagatpate\nDehi Me Tanayam Krishna Tvam Aham Sharanam Gatah',
 'O Krishna, son of Devaki, Lord of the universe — I surrender to you. Please bless me with a noble child.',
 300, 'krishna',
 ARRAY['Specifically for child''s wellbeing', 'Invokes Krishna''s protection', 'Strengthens mother-child bond'],
 ARRAY['krishna', 'santana_gopala', 'child_protection', 'all_trimesters'],
 10, false, 6),

-- Maha Mrityunjaya Mantra
('prenatal', 'mantra', NULL, 1, 40,
 'Maha Mrityunjaya Mantra', 'महामृत्युंजय मंत्र', 'महामृत्युंजय',
 'The great mantra of healing and protection',
 'The Maha Mrityunjaya Mantra from the Rig Veda is one of the most powerful healing mantras. During pregnancy, it invokes Lord Shiva''s healing energy to protect both mother and child.',
 'ॐ त्र्यम्बकं यजामहे सुगन्धिं पुष्टिवर्धनम् ।\nउर्वारुकमिव बन्धनान् मृत्योर्मुक्षीय माऽमृतात् ॥',
 'Om Tryambakam Yajamahe Sugandhim Pushtivardhanam\nUrvarukamiva Bandhanan Mrityor Mukshiya Ma Amritat',
 'We worship the three-eyed Lord Shiva who is fragrant and who nourishes all beings. May He liberate us from the bondage of death, just as a cucumber is severed from its vine, and grant us immortality.',
 420, 'shiva',
 ARRAY['Powerful healing and protection', 'Reduces complications', 'Invokes divine health for mother and child'],
 ARRAY['shiva', 'healing', 'protection', 'all_trimesters'],
 10, false, 7);

-- ============================================================
-- SECTION 2: MEDITATIONS (Prenatal)
-- ============================================================

INSERT INTO garbh_sanskar_content (phase, content_type, trimester, week_start, week_end, title, title_hindi, subtitle, description, body_text, duration_seconds, benefits, tags, coins_reward, is_premium, order_index) VALUES

-- 1st Trimester Meditation
('prenatal', 'meditation', 1, 1, 13,
 'Golden Light Meditation', 'स्वर्णिम प्रकाश ध्यान',
 'Surround your baby with divine golden light',
 'A gentle guided meditation for the first trimester. Visualise a warm golden light surrounding your womb, nurturing and protecting your growing baby. This meditation is best done lying down in a comfortable position.',
 'Find a comfortable position, either lying on your back or sitting supported. Close your eyes and take three deep breaths.\n\nImagine a warm, golden light above your head — the light of the divine sun. With each breath, this light flows down through the crown of your head, through your heart, and into your womb.\n\nSee your baby surrounded by this golden light — safe, warm, and loved. The light is nourishing every cell of your baby''s growing body.\n\nWhisper to your baby: "You are loved. You are safe. You are welcome."\n\nStay in this space for as long as you wish. When you are ready, gently bring your awareness back to the room.',
 900, 
 ARRAY['Reduces first-trimester anxiety', 'Strengthens mother-baby bond', 'Promotes relaxation'],
 ARRAY['meditation', 'first_trimester', 'visualisation', 'bonding'],
 10, false, 10),

-- 2nd Trimester Meditation
('prenatal', 'meditation', 2, 14, 27,
 'Connecting with Your Baby', 'शिशु से जुड़ाव',
 'Feel your baby''s presence and communicate through love',
 'In the second trimester, your baby can hear your voice. This meditation guides you to speak to your baby''s soul and establish a deep spiritual connection.',
 'Sit comfortably with your hands resting on your belly. Close your eyes.\n\nTake a few deep breaths and feel the weight of your hands on your belly. Beneath your hands, your baby is growing, moving, and listening.\n\nBegin to breathe slowly and deeply. With each exhale, imagine sending a wave of love from your heart, through your hands, into your womb.\n\nNow, speak to your baby — silently or aloud. Tell them about your family, your hopes for them, the world they are coming into. Tell them about the deities who watch over them.\n\nRecite the Gayatri Mantra three times, feeling each syllable vibrate through your body and into your baby.\n\nEnd by saying: "I am your mother. I love you. I am ready for you."',
 1200,
 ARRAY['Deepens mother-baby bond', 'Stimulates baby''s auditory development', 'Reduces stress hormones'],
 ARRAY['meditation', 'second_trimester', 'bonding', 'communication'],
 10, false, 11),

-- 3rd Trimester Meditation
('prenatal', 'meditation', 3, 28, 40,
 'Preparing for Birth — Surrender Meditation', 'प्रसव की तैयारी',
 'Release fear and surrender to the divine process of birth',
 'As your due date approaches, this meditation helps you release fear and trust in the divine process of birth. The body knows what to do — your role is to surrender.',
 'Lie down in a comfortable position with pillows supporting your back and legs. Close your eyes.\n\nTake a deep breath in, and as you exhale, consciously release any tension in your body. Do this three times.\n\nImagine yourself in a sacred space — perhaps a temple, a forest, or by a river. You are surrounded by the Divine Mother in all her forms: Durga for strength, Lakshmi for abundance, Saraswati for wisdom.\n\nFeel their presence around you. They have guided countless mothers through this journey. You are not alone.\n\nRepeat to yourself: "My body is wise. My baby is ready. I surrender to the divine plan."\n\nBreath by breath, release any remaining fear. Trust that you are held, guided, and protected.',
 1500,
 ARRAY['Reduces fear of childbirth', 'Prepares the mind for labour', 'Invokes divine support'],
 ARRAY['meditation', 'third_trimester', 'birth_preparation', 'surrender'],
 15, false, 12),

-- Postnatal Meditation
('postnatal', 'meditation', NULL, NULL, NULL,
 'Mother''s Healing Meditation', 'माँ का उपचार ध्यान',
 'Restore your energy and connect with your newborn',
 'After birth, your body and mind need deep rest and healing. This gentle meditation helps you restore your energy, process the birth experience, and deepen your bond with your newborn.',
 'Find a quiet moment when your baby is sleeping. Lie down or sit comfortably.\n\nClose your eyes and take three slow, deep breaths. With each exhale, release any tension, pain, or worry.\n\nBring your awareness to your heart. Feel it beating — the same heart that nourished your baby for nine months.\n\nImagine a warm, healing light filling your body from the inside. It soothes any soreness, restores your energy, and fills you with a deep sense of peace.\n\nThink of your baby. Feel the love that flows between you — a love that existed before birth and will continue beyond this life.\n\nRepeat: "I am a good mother. I am enough. I am healing."',
 900,
 ARRAY['Supports postnatal recovery', 'Reduces postnatal anxiety', 'Strengthens mother-baby bond'],
 ARRAY['meditation', 'postnatal', 'healing', 'recovery'],
 10, false, 13);

-- ============================================================
-- SECTION 3: PRANAYAMA & YOGA (Prenatal)
-- ============================================================

INSERT INTO garbh_sanskar_content (phase, content_type, trimester, week_start, week_end, title, title_hindi, subtitle, description, body_text, duration_seconds, benefits, tags, coins_reward, is_premium, order_index) VALUES

('prenatal', 'pranayama', 1, 1, 40,
 'Nadi Shodhana — Alternate Nostril Breathing', 'नाड़ी शोधन प्राणायाम',
 'Balance your energy channels for a calm pregnancy',
 'Nadi Shodhana (alternate nostril breathing) is one of the safest and most beneficial pranayamas during pregnancy. It balances the left and right hemispheres of the brain, reduces anxiety, and improves oxygen supply to the baby.',
 'Sit comfortably in a chair or on the floor with your spine straight.\n\n1. Place your right hand in Vishnu Mudra: fold your index and middle fingers toward your palm, leaving your thumb, ring finger, and little finger extended.\n\n2. Close your right nostril with your right thumb. Inhale slowly through your left nostril for a count of 4.\n\n3. Close both nostrils. Hold gently for a count of 2. (Do not hold breath for long during pregnancy.)\n\n4. Release your right nostril and exhale slowly for a count of 6.\n\n5. Inhale through your right nostril for a count of 4.\n\n6. Close both nostrils. Hold gently for a count of 2.\n\n7. Release your left nostril and exhale for a count of 6.\n\nThis completes one cycle. Repeat 5-10 cycles. Practice daily in the morning.',
 600,
 ARRAY['Reduces anxiety and stress', 'Improves oxygen supply to baby', 'Balances hormones', 'Improves sleep quality'],
 ARRAY['pranayama', 'breathing', 'all_trimesters', 'anxiety_relief'],
 10, false, 20),

('prenatal', 'pranayama', 1, 1, 27,
 'Ujjayi — Ocean Breath', 'उज्जायी प्राणायाम',
 'The breath of victory — calm and energise',
 'Ujjayi pranayama creates a gentle, ocean-like sound in the throat. It is warming, calming, and deeply oxygenating. Safe for the first and second trimesters.',
 'Sit comfortably. Slightly constrict the back of your throat (as if you are about to fog a mirror, but with your mouth closed).\n\nInhale slowly through your nose for a count of 4, making a gentle "hhhh" sound in your throat.\n\nExhale slowly through your nose for a count of 6, making the same gentle sound.\n\nThe breath should sound like gentle ocean waves — soft and rhythmic.\n\nPractice 5-10 minutes daily. This breath is also excellent during labour contractions.',
 480,
 ARRAY['Calms the nervous system', 'Increases oxygen intake', 'Excellent for labour pain management'],
 ARRAY['pranayama', 'ujjayi', 'first_trimester', 'second_trimester', 'labour_prep'],
 10, false, 21),

('prenatal', 'yoga', 2, 14, 27,
 'Cat-Cow Stretch (Marjariasana)', 'मार्जरी आसन',
 'Gentle spinal movement to relieve back pain',
 'The Cat-Cow pose is one of the safest and most beneficial yoga poses during pregnancy. It gently stretches the spine, relieves back pain, and helps position the baby optimally.',
 'Come onto your hands and knees (tabletop position). Wrists under shoulders, knees under hips.\n\nCOW POSE (Inhale): Drop your belly toward the floor, lift your chest and tailbone toward the ceiling. Look slightly upward. Feel the gentle stretch along your spine.\n\nCAT POSE (Exhale): Round your spine toward the ceiling like a cat stretching. Tuck your chin to your chest and your tailbone under.\n\nMove slowly and gently between these two positions, synchronising with your breath.\n\nRepeat 10-15 times. Practice daily to relieve back pain and encourage optimal baby positioning.',
 480,
 ARRAY['Relieves back pain', 'Improves spinal flexibility', 'Helps baby into optimal position', 'Reduces hip tension'],
 ARRAY['yoga', 'second_trimester', 'back_pain', 'gentle'],
 10, false, 25),

('prenatal', 'yoga', 3, 28, 40,
 'Butterfly Pose (Baddha Konasana)', 'बद्ध कोणासन',
 'Open the hips and prepare for birth',
 'The Butterfly Pose gently opens the hips and inner thighs, which is essential preparation for childbirth. It also improves circulation to the pelvic region.',
 'Sit on the floor with your spine straight. Bring the soles of your feet together, letting your knees fall out to the sides.\n\nHold your feet or ankles with your hands. Sit tall and breathe deeply.\n\nGently flap your knees up and down like butterfly wings — 10-15 times.\n\nThen hold the pose still and breathe deeply for 1-2 minutes. Feel the gentle opening in your hips.\n\nDo NOT force your knees down. Work within your comfortable range.\n\nPractice daily in the third trimester to prepare the hips for birth.',
 360,
 ARRAY['Opens hips for birth preparation', 'Improves pelvic circulation', 'Reduces inner thigh tension', 'Prepares for labour'],
 ARRAY['yoga', 'third_trimester', 'hip_opening', 'birth_prep'],
 10, false, 26);

-- ============================================================
-- SECTION 4: AFFIRMATIONS (All trimesters)
-- ============================================================

INSERT INTO garbh_sanskar_content (phase, content_type, trimester, week_start, week_end, title, title_hindi, subtitle, description, body_text, duration_seconds, benefits, tags, coins_reward, is_premium, order_index) VALUES

('prenatal', 'affirmation', 1, 1, 13,
 'First Trimester Affirmations', 'पहली तिमाही की सकारात्मक पुष्टि',
 'Daily affirmations for a positive first trimester',
 'The first trimester can bring uncertainty and anxiety. These affirmations help you anchor in positivity and trust. Recite them each morning after waking.',
 'I am grateful for this precious life growing within me.\nMy body is wise and knows exactly what to do.\nI trust the divine plan for my pregnancy.\nMy baby is healthy, strong, and surrounded by love.\nI release all fear and embrace this sacred journey.\nI am supported by the divine and by all those who love me.\nEach day, my baby and I grow stronger together.\nI am a vessel of divine love.',
 300,
 ARRAY['Reduces first-trimester anxiety', 'Builds positive mindset', 'Strengthens faith'],
 ARRAY['affirmation', 'first_trimester', 'positivity', 'daily'],
 5, false, 30),

('prenatal', 'affirmation', 2, 14, 27,
 'Second Trimester Affirmations', 'दूसरी तिमाही की सकारात्मक पुष्टि',
 'Celebrate your growing body and deepening bond',
 'The second trimester is often called the "golden trimester." Your baby is growing rapidly and you can begin to feel movement. These affirmations celebrate this beautiful phase.',
 'I love and accept my changing body.\nMy baby can hear my voice and feels my love.\nI am growing a miracle.\nMy body is strong and capable.\nI nourish my baby with every loving thought.\nI welcome the movements of my baby with joy.\nI am connected to all the mothers who have come before me.\nThe Divine Mother walks with me on this path.',
 300,
 ARRAY['Promotes body positivity', 'Deepens mother-baby bond', 'Reduces second-trimester discomfort'],
 ARRAY['affirmation', 'second_trimester', 'body_positivity', 'daily'],
 5, false, 31),

('prenatal', 'affirmation', 3, 28, 40,
 'Third Trimester Affirmations', 'तीसरी तिमाही की सकारात्मक पुष्टि',
 'Prepare your mind and spirit for the birth',
 'As you approach your due date, these affirmations help you release fear and prepare for the transformative experience of birth.',
 'I trust my body''s ability to birth my baby.\nI am strong, capable, and ready.\nI surrender to the divine wisdom of my body.\nMy baby knows the perfect time to be born.\nI breathe through every wave with grace and strength.\nI am surrounded by love and divine protection.\nI welcome my baby with open arms and an open heart.\nI am becoming the mother I am meant to be.',
 300,
 ARRAY['Reduces fear of childbirth', 'Builds confidence', 'Prepares for labour'],
 ARRAY['affirmation', 'third_trimester', 'birth_prep', 'daily'],
 5, false, 32),

('postnatal', 'affirmation', NULL, NULL, NULL,
 'New Mother Affirmations', 'नई माँ की सकारात्मक पुष्टि',
 'You are enough. You are doing beautifully.',
 'The early days of motherhood can be overwhelming. These affirmations remind you of your strength, your love, and your innate wisdom as a mother.',
 'I am a good mother.\nI am learning and growing every day.\nMy love for my baby is perfect, even when I feel imperfect.\nI give myself permission to rest and heal.\nI ask for help when I need it — that is strength, not weakness.\nMy baby chose me. I am exactly the right mother for them.\nI trust my instincts.\nI am not alone on this journey.',
 300,
 ARRAY['Reduces postnatal anxiety', 'Builds maternal confidence', 'Prevents postnatal depression'],
 ARRAY['affirmation', 'postnatal', 'new_mother', 'daily'],
 5, false, 33);

-- ============================================================
-- SECTION 5: DIET TIPS (Trimester-specific)
-- ============================================================

INSERT INTO garbh_sanskar_content (phase, content_type, trimester, week_start, week_end, title, title_hindi, subtitle, description, body_text, benefits, tags, coins_reward, is_premium, order_index) VALUES

('prenatal', 'diet_tip', 1, 1, 13,
 'First Trimester Ayurvedic Diet', 'पहली तिमाही का आयुर्वेदिक आहार',
 'Nourish yourself and your baby with ancient wisdom',
 'Ayurveda has specific dietary guidelines for each trimester of pregnancy. In the first trimester, the focus is on easily digestible, cooling, and nourishing foods.',
 'WHAT TO EAT:\n• Fresh fruits: pomegranate, dates, figs, mangoes (in season)\n• Dairy: warm milk with saffron and cardamom, ghee, yogurt\n• Grains: rice, wheat, barley\n• Vegetables: leafy greens, sweet potato, carrots\n• Spices: cumin, coriander, fennel, ginger (small amounts)\n• Nuts: soaked almonds, walnuts\n• Legumes: moong dal (easiest to digest)\n\nWHAT TO AVOID:\n• Spicy, fried, and processed foods\n• Excess salt\n• Raw papaya and pineapple\n• Alcohol and caffeine\n• Very cold foods and drinks\n\nAYURVEDIC TIP:\nDrink warm water with a pinch of saffron (kesar) and a few drops of ghee each morning. This is said to promote the baby''s complexion and intelligence.',
 ARRAY['Reduces morning sickness', 'Provides essential nutrients', 'Supports baby''s development'],
 ARRAY['diet', 'ayurveda', 'first_trimester', 'nutrition'],
 5, false, 40),

('prenatal', 'diet_tip', 2, 14, 27,
 'Second Trimester Ayurvedic Diet', 'दूसरी तिमाही का आयुर्वेदिक आहार',
 'Build strength as your baby grows rapidly',
 'In the second trimester, your baby is growing rapidly and your nutritional needs increase. Focus on protein, calcium, and iron-rich foods.',
 'WHAT TO EAT:\n• Protein: paneer, dal, nuts, seeds, milk\n• Iron-rich: spinach, fenugreek (methi), jaggery (gud), sesame seeds\n• Calcium: milk, yogurt, sesame seeds, ragi (finger millet)\n• Healthy fats: ghee, coconut, avocado\n• Fruits: banana, chikoo, guava\n\nSPECIAL PREPARATIONS:\n• Sattu (roasted gram flour) with milk and jaggery — excellent for energy\n• Ragi porridge with milk and dates\n• Methi paratha with ghee\n• Til (sesame) ladoo — rich in calcium\n\nAYURVEDIC TIP:\nAdd a teaspoon of Shatavari powder to warm milk daily. Shatavari is the premier Ayurvedic herb for pregnancy, supporting the reproductive system and increasing breast milk production.',
 ARRAY['Supports rapid foetal growth', 'Prevents anaemia', 'Builds strong bones for baby'],
 ARRAY['diet', 'ayurveda', 'second_trimester', 'nutrition', 'iron', 'calcium'],
 5, false, 41),

('postnatal', 'diet_tip', NULL, NULL, NULL,
 'Postnatal Ayurvedic Diet (Sutika Paricharya)', 'प्रसव के बाद का आयुर्वेदिक आहार',
 'Heal, restore, and nourish your body after birth',
 'Ayurveda prescribes a specific postnatal diet called Sutika Paricharya for the 40-day recovery period after birth. This diet focuses on restoring the mother''s strength, promoting healing, and increasing breast milk.',
 'FIRST WEEK:\n• Warm, easily digestible foods only\n• Ajwain (carom seed) water — drink throughout the day\n• Panjiri (wheat flour roasted in ghee with dry fruits) — 1-2 tablespoons daily\n• Warm milk with turmeric and black pepper\n• Light dal and rice\n\nWEEKS 2-6:\n• Ghee is essential — add to all foods. It lubricates the joints, aids digestion, and promotes healing\n• Dry fruits: dates, figs, almonds, walnuts (soaked overnight)\n• Methi (fenugreek) ladoo — promotes milk production\n• Ajwain paratha with ghee\n• Doodh panjiri\n• Warm soups and stews\n\nFOR BREAST MILK:\n• Shatavari powder in warm milk\n• Fennel seeds (saunf) tea\n• Fenugreek seeds (methi)\n• Jeera (cumin) water\n\nAVOID:\n• Cold foods and drinks\n• Raw salads\n• Spicy foods\n• Processed foods',
 ARRAY['Accelerates postnatal healing', 'Increases breast milk production', 'Restores energy and strength', 'Prevents postnatal depression'],
 ARRAY['diet', 'ayurveda', 'postnatal', 'sutika_paricharya', 'breastfeeding'],
 5, false, 42);

-- ============================================================
-- SECTION 6: LULLABIES
-- ============================================================

INSERT INTO lullabies (title, title_hindi, language, deity_associated, lyrics, transliteration, translation, audio_storage_path, duration_seconds, age_range_months_min, age_range_months_max, mood, order_index) VALUES

('Nind Aaja Re', 'नींद आ जा रे', 'hi', NULL,
 'नींद आ जा रे, नींद आ जा रे\nमेरे लाल को नींद आ जा रे\nचंदा मामा आएंगे\nतारे साथ लाएंगे\nसोजा मेरे राजा, नींद आ जा रे',
 'Nind Aa Ja Re, Nind Aa Ja Re\nMere Lal Ko Nind Aa Ja Re\nChanda Mama Aayenge\nTare Saath Laayenge\nSoja Mere Raja, Nind Aa Ja Re',
 'Come, sleep, come sleep\nBring sleep to my precious one\nUncle Moon will come\nBringing stars along\nSleep, my little king, come sleep',
 'lullabies/nind-aaja-re.mp3', 180, 0, 24, 'bedtime', 1),

('Krishna Lori', 'कृष्ण लोरी', 'hi', 'krishna',
 'सो जा रे सो जा, मेरे कान्हा सो जा\nयशोदा की आँखों का तारा सो जा\nगोकुल के नंदन, वृंदावन के बंधन\nमाखन चोर मेरा, सो जा सो जा',
 'So Ja Re So Ja, Mere Kanha So Ja\nYashoda Ki Aankhon Ka Tara So Ja\nGokul Ke Nandan, Vrindavan Ke Bandhan\nMakhan Chor Mera, So Ja So Ja',
 'Sleep, sleep, my little Krishna\nStar of Yashoda''s eyes, sleep\nDelight of Gokul, beloved of Vrindavan\nMy butter thief, sleep, sleep',
 'lullabies/krishna-lori.mp3', 240, 0, 36, 'devotional', 2),

('Chanda Mama', 'चंदा मामा', 'hi', NULL,
 'चंदा मामा दूर के, पुए पकाए बूर के\nआप खाएं थाली में, मुन्ने को दें प्याली में\nप्याली गई टूट, मुन्ना गया रूठ\nलाएंगे नई प्याली, मुन्ना खाएगा खाली',
 'Chanda Mama Dur Ke, Pue Pakaye Bur Ke\nAap Khayen Thali Mein, Munne Ko Den Pyali Mein\nPyali Gayi Toot, Munna Gaya Rooth\nLayenge Nayi Pyali, Munna Khayega Khali',
 'Uncle Moon from far away, cooking sweet puris\nYou eat from a plate, give little one a bowl\nThe bowl broke, little one sulked\nWe''ll bring a new bowl, little one will eat happily',
 'lullabies/chanda-mama.mp3', 200, 0, 48, 'playful', 3),

('Ram Lalla Lori', 'राम लल्ला लोरी', 'hi', 'rama',
 'सो जा राम लल्ला, सो जा\nकौशल्या माँ की आँखों का तारा सो जा\nसीता की राम, अयोध्या के धाम\nसो जा मेरे राजा, सो जा सो जा',
 'So Ja Ram Lalla, So Ja\nKaushalya Maa Ki Aankhon Ka Tara So Ja\nSita Ki Ram, Ayodhya Ke Dham\nSo Ja Mere Raja, So Ja So Ja',
 'Sleep, little Ram, sleep\nStar of Mother Kaushalya''s eyes, sleep\nRam of Sita, the abode of Ayodhya\nSleep, my king, sleep, sleep',
 'lullabies/ram-lalla-lori.mp3', 220, 0, 36, 'devotional', 4),

('Om Jai Jagdish Lori', 'ॐ जय जगदीश लोरी', 'hi', 'vishnu',
 'ॐ जय जगदीश हरे, स्वामी जय जगदीश हरे\nभक्त जनों के संकट, क्षण में दूर करे\nजो ध्यावे फल पावे, दुख बिनसे मन का\nसुख सम्पत्ति घर आवे, कष्ट मिटे तन का',
 'Om Jai Jagdish Hare, Swami Jai Jagdish Hare\nBhakta Janon Ke Sankat, Kshan Mein Dur Kare\nJo Dhyave Phal Pave, Dukh Binse Man Ka\nSukh Sampatti Ghar Aave, Kasht Mite Tan Ka',
 'Victory to Lord Vishnu, the Lord of the universe\nHe removes the troubles of devotees in an instant\nWhoever meditates on Him receives blessings\nHappiness and prosperity come home, bodily suffering ends',
 'lullabies/om-jai-jagdish-lori.mp3', 300, 0, 60, 'devotional', 5),

('Hanuman Lori', 'हनुमान लोरी', 'hi', 'hanuman',
 'सो जा बजरंगी, सो जा\nराम के दूत, पवन पुत्र, सो जा\nलंका जलाई, सीता को लाई\nसो जा मेरे वीर, सो जा सो जा',
 'So Ja Bajrangi, So Ja\nRam Ke Doot, Pavan Putra, So Ja\nLanka Jalai, Sita Ko Lai\nSo Ja Mere Veer, So Ja So Ja',
 'Sleep, mighty Hanuman, sleep\nMessenger of Ram, son of the wind, sleep\nYou burned Lanka, you brought Sita back\nSleep, my brave one, sleep, sleep',
 'lullabies/hanuman-lori.mp3', 210, 0, 48, 'devotional', 6);

-- ============================================================
-- SECTION 7: POSTNATAL RITUALS
-- ============================================================

INSERT INTO garbh_sanskar_content (phase, content_type, week_start, week_end, title, title_hindi, subtitle, description, body_text, duration_seconds, benefits, tags, coins_reward, is_premium, order_index) VALUES

('postnatal', 'ritual', NULL, NULL,
 'Abhyanga — Postnatal Oil Massage', 'प्रसव के बाद अभ्यंग',
 'The ancient Ayurvedic practice of oil massage for mother and baby',
 'Abhyanga (oil massage) is one of the most important postnatal practices in Ayurveda. For the mother, it restores strength, lubricates the joints, and promotes healing. For the baby, it strengthens the nervous system, improves sleep, and promotes healthy growth.',
 'FOR THE MOTHER:\nMassage the entire body with warm sesame oil (in winter) or coconut oil (in summer) for 15-20 minutes before bathing. Focus on the abdomen, lower back, and hips. This can be done by a family member or trained postnatal massage therapist.\n\nFOR THE BABY:\nWarm a small amount of oil in your palms. Massage the baby gently from the feet upward, then the hands upward, then the back. Use gentle, circular motions on the abdomen (clockwise). Massage the scalp gently.\n\nBEST OILS FOR BABY:\n• Coconut oil (cooling, anti-fungal)\n• Sesame oil (warming, strengthening)\n• Almond oil (nourishing for skin)\n• Mustard oil (traditional, warming — use in winter)\n\nTIMING: Daily, ideally in the morning before bath. Continue for at least 40 days postpartum.',
 600,
 ARRAY['Accelerates postnatal healing', 'Improves baby''s sleep', 'Strengthens baby''s nervous system', 'Promotes bonding'],
 ARRAY['ritual', 'postnatal', 'abhyanga', 'massage', 'ayurveda'],
 10, false, 50),

('newborn', 'ritual', NULL, NULL,
 'Baby''s First Bath — Prathama Snan', 'शिशु का पहला स्नान',
 'A sacred and gentle ritual for the newborn''s first bath',
 'The baby''s first bath at home is a special occasion. In Hindu tradition, the bath water is infused with sacred herbs and a short prayer is said to invoke divine protection.',
 'PREPARATION:\n• Warm water (test with your elbow — it should feel comfortably warm, not hot)\n• Add a pinch of turmeric and a few drops of pure sesame oil to the water\n• Optional: add a few drops of rose water or a small amount of neem leaves (boiled and strained)\n\nTHE RITUAL:\n1. Light a small diya near the bathing area.\n2. Recite this prayer before beginning: "Om Apavitrah Pavitro Va Sarvavastham Gato Api Va, Yah Smaret Pundarikaksham Sa Bahyabhyantarah Shuchih" (Whether pure or impure, in all circumstances, whoever remembers the lotus-eyed Lord becomes pure inside and out.)\n3. Gently lower the baby into the water, supporting the head at all times.\n4. Wash gently with a soft cloth. Do not use soap on the face.\n5. After the bath, wrap the baby in a warm, soft cloth immediately.\n6. Apply a tiny dot of kajal behind the ear (to ward off the evil eye).\n7. Dress the baby in clean, soft clothes.',
 480,
 ARRAY['Sacred beginning for the baby', 'Skin protection with turmeric', 'Establishes daily routine'],
 ARRAY['ritual', 'newborn', 'bath', 'first_bath'],
 10, false, 51);
