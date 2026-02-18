-- ═══════════════════════════════════════════════════════════
-- RUN THIS IN SUPABASE SQL EDITOR
-- This will:
--   1. Fix RLS policies for sacred_texts
--   2. Update Hanuman Chalisa with transliterated English
--   3. Update Shiv Tandav with transliterated English
--   4. Insert 11 new sacred texts for all deities
-- ═══════════════════════════════════════════════════════════

-- STEP 1: Fix RLS
ALTER TABLE sacred_texts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view active sacred texts" ON sacred_texts;
CREATE POLICY "Anyone can view active sacred texts"
  ON sacred_texts FOR SELECT USING (is_active = true);

DROP POLICY IF EXISTS "Allow anon insert sacred_texts" ON sacred_texts;
CREATE POLICY "Allow anon insert sacred_texts"
  ON sacred_texts FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Allow anon update sacred_texts" ON sacred_texts;
CREATE POLICY "Allow anon update sacred_texts"
  ON sacred_texts FOR UPDATE USING (true);

-- ═══════════════════════════════════════════════════════════
-- STEP 2: Update Hanuman Chalisa - transliterated English
-- (Hindi words in English/Roman script)
-- ═══════════════════════════════════════════════════════════

UPDATE sacred_texts
SET text_english = '|| Doha ||
Shri Guru Charan Saroj Raj, Nij Manu Mukuru Sudhaari.
Baranau Raghubar Bimal Jasu, Jo Daayaku Phal Chaari.
Buddhiheen Tanu Jaanike, Sumirau Pavan Kumaar.
Bal Buddhi Vidya Dehu Mohi, Harahu Kalesh Vikaar.

|| Chaupai ||
Jai Hanuman Gyaan Gun Saagar,
Jai Kapis Tihun Lok Ujaagar.
Ramdoot Atulit Bal Dhaamaa,
Anjani Putra Pavan Sut Naamaa.

Mahaabir Bikram Bajrangi,
Kumati Nivaar Sumati Ke Sangi.
Kanchan Baran Biraaj Subesa,
Kaanan Kundal Kunchit Kesa.

Haath Bajra Aur Dhvaja Biraaje,
Kaandhe Moonj Janeu Saaje.
Shankar Suvan Kesari Nandan,
Tej Prataap Mahaa Jag Vandan.

Vidyaavaan Guni Ati Chaatur,
Raam Kaaj Karibe Ko Aatur.
Prabhu Charitra Sunibe Ko Rasiyaa,
Raam Lakhan Seetaa Man Basiyaa.

Sukshma Roop Dhari Siyahi Dikhaavaa,
Bikat Roop Dhari Lanka Jaraavaa.
Bheem Roop Dhari Asur Sanhaare,
Raamchandra Ke Kaaj Sanvaare.

Laay Sajeevan Lakhan Jiyaaye,
Shri Raghubir Harashi Ur Laaye.
Raghupati Keenhi Bahut Badaai,
Tum Mam Priya Bharatahi Sam Bhaai.

Sahas Badan Tumharo Jas Gaavein,
As Kahi Shripati Kanth Lagaavein.
Sanakaadik Brahmaadi Muneesaa,
Naarad Shaarad Sahit Aheesaa.

Jam Kuber Digpaal Jahaan Te,
Kabi Kobid Kahi Sake Kahaan Te.
Tum Upkaar Sugreevanhi Keenhaa,
Raam Milaay Raajpad Deenhaa.

Tumharo Mantra Vibheeshan Maanaa,
Lankeshwar Bhaye Sab Jag Jaanaa.
Yug Sahasra Yojan Par Bhaanu,
Leelyo Taahi Madhur Phal Jaanu.

Prabhu Mudrikaa Meli Mukh Maaheen,
Jaladhi Laanghi Gaye Achraj Naaheen.
Durgam Kaaj Jagat Ke Jete,
Sugam Anugrah Tumhre Tete.

Raam Duaare Tum Rakhvaare,
Hot Na Aagya Binu Paisaare.
Sab Sukh Lahai Tumhaari Sharanaa,
Tum Rakshak Kaahu Ko Dar Naa.

Aapan Tej Samhaaro Aapei,
Teenon Lok Haank Te Kaanpei.
Bhoot Pishaach Nikat Nahin Aavei,
Mahaabir Jab Naam Sunaavei.

Naasai Rog Harai Sab Peera,
Japat Nirantar Hanumat Beera.
Sankat Te Hanumaan Chudaavei,
Man Kram Bachan Dhyaan Jo Laavei.

Sab Par Raam Tapasvi Raajaa,
Tin Ke Kaaj Sakal Tum Saajaa.
Aur Manorath Jo Koi Laavei,
Soi Amit Jeevan Phal Paavei.

Chaaron Jug Partaap Tumhaaraa,
Hai Parasiddh Jagat Ujiyaaraa.
Saadhu Sant Ke Tum Rakhvaare,
Asur Nikandan Raam Dulaare.

Ashta Siddhi Nau Nidhi Ke Daataa,
As Bar Deen Jaanaki Maataa.
Raam Rasaayan Tumhare Paasaa,
Sadaa Raho Raghupati Ke Daasaa.

Tumhare Bhajan Raam Ko Paavei,
Janam Janam Ke Dukh Bisraavei.
Antkaal Raghubar Pur Jaai,
Jahaan Janam Hari Bhakt Kahaai.

Aur Devataa Chitt Na Dharai,
Hanumat Sei Sarb Sukh Karai.
Sankat Katei Mitei Sab Peera,
Jo Sumirai Hanumat Balbeeraa.

Jai Jai Jai Hanumaan Gosaaeen,
Kripaa Karahu Gurudev Ki Naaee.

|| Doha ||
Jo Sat Baar Paath Kar Koi,
Chhutehi Bandhi Mahaa Sukh Hoi.
Jo Yah Padhe Hanumaan Chaleesaa,
Hoy Siddhi Saakhi Gaureesaa.
Tulsidaas Sadaa Hari Cheraa,
Keeje Naath Hriday Mah Deraa.'
WHERE slug = 'hanuman-chalisa';

-- ═══════════════════════════════════════════════════════════
-- STEP 3: Update Shiv Tandav - transliterated English
-- ═══════════════════════════════════════════════════════════

UPDATE sacred_texts
SET text_english = 'Jatataveegalajjalapravaahapaavitasthale
Galeavalambya Lambitaam Bhujangaatungamaalikaam
Damad Damad Damaddama Ninaaadavaddamaravayam
Chakaar Chaandataandavam Tanotu Nah Shivah Shivam.

Jatakataahasambhramaa Bhramanilimpanirjharee
Vilolaveechivallari Viraajamaanamoordhani
Dhagaddhagaddhagajjvalal Lalaat Pattapaavakey
Kishoreachandrashekhare Ratih Pratikshanam Mama.

Dharaadharendranandineevil Aasabandhubandhura
Sphuradigantasantati Pramodamaanaamaanase
Krupaakataaksha Dhoranee Niruddhadurdharaapadi
Kvachidigambare Manovinodametuvastuni.

Jataa Bhujan Gapingala Sphuratphanamaaniprabhaa
Kadambakunkumadravapraliptadigvadhoomukhe
Madaandhasindhurasphurattvaguttareeyamedure
Mano Vinodamadbhutam Bibhartu Bhootabhartari.

Sahasra Lochanprabhritya Sheshapunyalekshitar
Prasoondhoolidhoranee Vidhoosar Anghripeethbhooh
Bhujangaraaja Maalayaa Nibaddhajaatajootaka
Shriyai Chiraya Jaayataam Chakora Bandhu Shekhara.

Lalaat Chatvarajvala Dhananjayasphulingabhaa
Nipeetapanchasaayakam Nammannilimpanaayakam
Sudhaamayookha Lekhayaa Viraajamaan Shekharam
Mahaakapaalineeshwara Mahaadyagnyah Paalayantu.

Karaal Bhaal Pattikaa Dhagaddhagaddhagajjvala
Ddhananjayaahuteekruta Prachanda Panchasaayake
Dharaadharendranandineekuchaagrachitrapatraka
Prakalpanaik Shilpinee Trilochane Ratirmama.

Naveen Megh Mandalee Niruddhadurdharasphurad
Kuhoonishteedeetpaha Prithama Baalakuntalaah
Kalanidhaan Bandhurah Shriyam Jagaddhurnadharah
Tritoolashool Shailshikhaanaadhavaa Dishhatu Naah.

Praphulla Neelpalamkadamba Kameshaavalambha
Kanth Pravedaananya Kinnikinikinikkila
Dharaadharoddaroodyad Vidhunmaadhirnmadaa
Hrishi Mohan Manohara Padpaadanjo Ratirme.

Imam Hi Nityam Evamuktauttamottamastavam
Patan Smaran Bruvannaro Vishuddhimeti Santatam
Hare Guruah Sarvasya Devasya Sarvadaa Hridaa
Bhajeh Akhandameeshwaram Trijagadaashritam Param.'
WHERE slug = 'shiv-tandav-stotram';

-- ═══════════════════════════════════════════════════════════
-- STEP 4: Insert new sacred texts (skip if already exists)
-- ═══════════════════════════════════════════════════════════

-- Shiva Aarti
INSERT INTO sacred_texts (slug, title, title_hindi, type, deity_slug, text_hindi, text_english, benefits, when_to_recite, verse_count, category, difficulty, is_featured, is_active, order_index)
SELECT 'shiva-aarti', 'Shiva Aarti', 'शिव आरती', 'aarti', 'shiva',
'ॐ जय शिव ओंकारा, स्वामी जय शिव ओंकारा।
ब्रह्मा, विष्णु, सदाशिव, अर्धांगी धारा॥
ॐ जय शिव ओंकारा॥

एकानन चतुरानन पंचानन राजे।
हंसासन गरुड़ासन वृषवाहन साजे॥
ॐ जय शिव ओंकारा॥

दो भुज चार चतुर्भुज दस भुज अति सोहे।
तीनों रूप निरखता त्रिभुवन जन मोहे॥
ॐ जय शिव ओंकारा॥

अक्षमाला वनमाला मुण्डमाला धारी।
त्रिपुरारी कंसारी कर माला धारी॥
ॐ जय शिव ओंकारा॥

श्वेताम्बर पीताम्बर बाघम्बर अंगे।
सनकादिक गरुणादिक भूतादिक संगे॥
ॐ जय शिव ओंकारा॥

कर के मध्य कमण्डलु चक्र त्रिशूलधारी।
सुखकारी दुःखहारी जगपालन कारी॥
ॐ जय शिव ओंकारा॥

ब्रह्मा विष्णु सदाशिव जानत अविवेका।
प्रणवाक्षर में शोभित ये तीनों एका॥
ॐ जय शिव ओंकारा॥

त्रिगुण स्वामी की आरती जो कोई नर गावे।
कहत शिवानन्द स्वामी मनवांछित फल पावे॥
ॐ जय शिव ओंकारा॥',
'Om Jai Shiv Onkaara, Swaami Jai Shiv Onkaara.
Brahmaa, Vishnu, Sadaashiv, Ardhaangi Dhaaraa.
Om Jai Shiv Onkaara.

Ekaanan Chaturaanan Panchaanan Raaje.
Hansaasan Garudaasan Vrishavaahan Saaje.
Om Jai Shiv Onkaara.

Do Bhuj Chaar Chaturbhuj Das Bhuj Ati Sohe.
Teenon Roop Nirakhata Tribhuvan Jan Mohe.
Om Jai Shiv Onkaara.

Akshmaala Vanmaala Mundmaala Dhaari.
Tripuraari Kansaari Kar Maala Dhaari.
Om Jai Shiv Onkaara.

Shvetaambar Peetaambar Baaghaambar Ange.
Sanakaadik Garunaadik Bhootaadik Sange.
Om Jai Shiv Onkaara.

Kar Ke Madhya Kamandalu Chakra Trishool Dhaari.
Sukhkaari Duhkhahaari Jagpaalan Kaari.
Om Jai Shiv Onkaara.

Brahmaa Vishnu Sadaashiv Jaanat Aviveka.
Pranavaakshar Mein Shobhit Ye Teenon Ekaa.
Om Jai Shiv Onkaara.

Trigun Swaami Ki Aarti Jo Koi Nar Gaave.
Kahat Shivaanand Swaami Manvaanchhit Phal Paave.
Om Jai Shiv Onkaara.',
'Brings peace, removes negativity, and invokes Lord Shiva''s blessings for spiritual growth.',
'During Shiva puja, especially on Mondays, Maha Shivaratri, and Pradosh Kaal.',
8, 'daily_prayer', 'beginner', true, true, 3
WHERE NOT EXISTS (SELECT 1 FROM sacred_texts WHERE slug = 'shiva-aarti');

-- Maha Mrityunjaya Mantra
INSERT INTO sacred_texts (slug, title, title_hindi, type, deity_slug, text_hindi, text_english, benefits, when_to_recite, verse_count, category, difficulty, is_featured, is_active, order_index)
SELECT 'maha-mrityunjaya-mantra', 'Maha Mrityunjaya Mantra', 'महा मृत्युंजय मंत्र', 'mantra', 'shiva',
'ॐ त्र्यम्बकं यजामहे सुगन्धिं पुष्टिवर्धनम्।
उर्वारुकमिव बन्धनान् मृत्योर्मुक्षीय मामृतात्॥',
'Om Tryambakam Yajaamahe Sugandhim Pushtivarddhanam.
Urvaarukamiva Bandhanaan Mrityormuksheeya Maamritaat.',
'The most powerful mantra for healing, longevity, and overcoming the fear of death.',
'During illness, danger, or daily as protection. Especially on Mondays and Maha Shivaratri.',
1, 'daily_prayer', 'beginner', true, true, 4
WHERE NOT EXISTS (SELECT 1 FROM sacred_texts WHERE slug = 'maha-mrityunjaya-mantra');

-- Krishna Aarti
INSERT INTO sacred_texts (slug, title, title_hindi, type, deity_slug, text_hindi, text_english, benefits, when_to_recite, verse_count, category, difficulty, is_featured, is_active, order_index)
SELECT 'krishna-aarti', 'Krishna Aarti', 'कृष्ण आरती', 'aarti', 'Krishna',
'ॐ जय जगदीश हरे, स्वामी जय जगदीश हरे।
भक्त जनों के संकट, दास जनों के संकट,
क्षण में दूर करे॥
ॐ जय जगदीश हरे॥

जो ध्यावे फल पावे, दुःख बिनसे मन का।
स्वामी दुःख बिनसे मन का।
सुख सम्पत्ति घर आवे, कष्ट मिटे तन का॥
ॐ जय जगदीश हरे॥

मात पिता तुम मेरे, शरण गहूं किसकी।
स्वामी शरण गहूं किसकी।
तुम बिन और न दूजा, आस करूं जिसकी॥
ॐ जय जगदीश हरे॥

तुम पूरन परमात्मा, तुम अंतर्यामी।
स्वामी तुम अंतर्यामी।
पारब्रह्म परमेश्वर, तुम सबके स्वामी॥
ॐ जय जगदीश हरे॥',
'Om Jai Jagdeesh Hare, Swaami Jai Jagdeesh Hare.
Bhakt Janon Ke Sankat, Daas Janon Ke Sankat,
Kshan Mein Door Kare.
Om Jai Jagdeesh Hare.

Jo Dhyaave Phal Paave, Dukh Binse Man Ka.
Swaami Dukh Binse Man Ka.
Sukh Sampatti Ghar Aave, Kasht Mite Tan Ka.
Om Jai Jagdeesh Hare.

Maat Pita Tum Mere, Sharan Gahun Kiski.
Swaami Sharan Gahun Kiski.
Tum Bin Aur Na Dooja, Aas Karun Jiski.
Om Jai Jagdeesh Hare.

Tum Pooran Paramaatma, Tum Antaryaami.
Swaami Tum Antaryaami.
Paarbrahm Parmeshwar, Tum Sabke Swaami.
Om Jai Jagdeesh Hare.',
'Invokes Lord Krishna''s blessings, removes sorrows, and brings prosperity and peace.',
'During daily evening aarti, Janmashtami, Ekadashi, and any Krishna puja.',
7, 'daily_prayer', 'beginner', true, true, 5
WHERE NOT EXISTS (SELECT 1 FROM sacred_texts WHERE slug = 'krishna-aarti');

-- Hare Krishna Maha Mantra
INSERT INTO sacred_texts (slug, title, title_hindi, type, deity_slug, text_hindi, text_english, benefits, when_to_recite, verse_count, category, difficulty, is_featured, is_active, order_index)
SELECT 'hare-krishna-maha-mantra', 'Hare Krishna Maha Mantra', 'हरे कृष्ण महा मंत्र', 'mantra', 'Krishna',
'हरे कृष्ण हरे कृष्ण कृष्ण कृष्ण हरे हरे।
हरे राम हरे राम राम राम हरे हरे॥',
'Hare Krishna Hare Krishna, Krishna Krishna Hare Hare.
Hare Raam Hare Raam, Raam Raam Hare Hare.',
'The supreme mantra for Kali Yuga. Purifies the mind, awakens divine love, and grants liberation.',
'Anytime, anywhere. Chant 108 times on a mala daily for best results.',
1, 'daily_prayer', 'beginner', true, true, 6
WHERE NOT EXISTS (SELECT 1 FROM sacred_texts WHERE slug = 'hare-krishna-maha-mantra');

-- Ganesh Aarti
INSERT INTO sacred_texts (slug, title, title_hindi, type, deity_slug, text_hindi, text_english, benefits, when_to_recite, verse_count, category, difficulty, is_featured, is_active, order_index)
SELECT 'ganesh-aarti', 'Ganesh Aarti', 'गणेश आरती', 'aarti', 'ganesha',
'जय गणेश जय गणेश जय गणेश देवा।
माता जाकी पार्वती पिता महादेवा॥

एक दन्त दयावन्त चार भुजा धारी।
माथे पर तिलक सोहे मूसे की सवारी॥
जय गणेश जय गणेश जय गणेश देवा॥

पान चढ़े फूल चढ़े और चढ़े मेवा।
लड्डुअन का भोग लगे सन्त करें सेवा॥
जय गणेश जय गणेश जय गणेश देवा॥

अंधन को आंख देत कोढ़िन को काया।
बांझन को पुत्र देत निर्धन को माया॥
जय गणेश जय गणेश जय गणेश देवा॥

दीनन की लाज रखो शम्भू सुत वारी।
कामना को पूर्ण करो जाउं बलिहारी॥
जय गणेश जय गणेश जय गणेश देवा॥',
'Jai Ganesh Jai Ganesh Jai Ganesh Deva.
Maata Jaaki Paarvati Pitaa Mahaadeva.

Ek Dant Dayaavant Chaar Bhuja Dhaari.
Maathe Par Tilak Sohe Moose Ki Savaari.
Jai Ganesh Jai Ganesh Jai Ganesh Deva.

Paan Chadhe Phool Chadhe Aur Chadhe Mevaa.
Ladduan Ka Bhog Lage Sant Karein Seva.
Jai Ganesh Jai Ganesh Jai Ganesh Deva.

Andhan Ko Aankh Det Kodhin Ko Kaayaa.
Baanjhan Ko Putra Det Nirdhan Ko Maayaa.
Jai Ganesh Jai Ganesh Jai Ganesh Deva.

Deenan Ki Laaj Rakho Shambhu Sut Vaari.
Kaamnaa Ko Poorn Karo Jaun Balihaari.
Jai Ganesh Jai Ganesh Jai Ganesh Deva.',
'Removes obstacles, brings wisdom and good fortune. Essential before beginning any new venture.',
'Before any puja, on Wednesdays, Ganesh Chaturthi, and Sankashti Chaturthi.',
6, 'daily_prayer', 'beginner', true, true, 7
WHERE NOT EXISTS (SELECT 1 FROM sacred_texts WHERE slug = 'ganesh-aarti');

-- Ganesh Beej Mantra
INSERT INTO sacred_texts (slug, title, title_hindi, type, deity_slug, text_hindi, text_english, benefits, when_to_recite, verse_count, category, difficulty, is_featured, is_active, order_index)
SELECT 'ganesh-mantra', 'Ganesh Beej Mantra', 'गणेश बीज मंत्र', 'mantra', 'ganesha',
'ॐ गं गणपतये नमः॥

वक्रतुण्ड महाकाय सूर्यकोटि समप्रभ।
निर्विघ्नं कुरु मे देव सर्वकार्येषु सर्वदा॥',
'Om Gam Ganapataye Namah.

Vakratunda Mahaakaaya Suryakoti Samaprabha.
Nirvighnam Kuru Me Deva Sarvakaaryeshu Sarvadaa.',
'Invokes Ganesha''s energy to remove obstacles and ensure success in all endeavors.',
'Before starting anything new — exams, business, travel. Chant 108 times.',
2, 'daily_prayer', 'beginner', true, true, 8
WHERE NOT EXISTS (SELECT 1 FROM sacred_texts WHERE slug = 'ganesh-mantra');

-- Hanuman Aarti
INSERT INTO sacred_texts (slug, title, title_hindi, type, deity_slug, text_hindi, text_english, benefits, when_to_recite, verse_count, category, difficulty, is_featured, is_active, order_index)
SELECT 'hanuman-aarti', 'Hanuman Aarti', 'हनुमान आरती', 'aarti', 'Hanuman',
'आरती कीजै हनुमान लला की।
दुष्ट दलन रघुनाथ कला की॥

जाके बल से गिरिवर कांपे।
रोग दोष जाके निकट न झांके॥

अंजनी पुत्र महा बलदाई।
संतन के प्रभु सदा सहाई॥

दे बीड़ा रघुनाथ पठाए।
लंका जारि सिया सुधि लाए॥

लंका सो कोट समुद्र सी खाई।
जात पवनसुत बार न लाई॥

लंका जारि असुर संहारे।
सीताराम जी के काज संवारे॥

सुर नर मुनि जन आरती उतारे।
जय जय जय हनुमान उचारे॥',
'Aarti Keejai Hanumaan Lalaa Ki.
Dusht Dalan Raghunaath Kalaa Ki.

Jaake Bal Se Girivar Kaanpe.
Rog Dosh Jaake Nikat Na Jhaanke.

Anjani Putra Mahaa Baldaaee.
Santan Ke Prabhu Sadaa Sahaaee.

De Beedaa Raghunaath Pathaaye.
Lankaa Jaari Siyaa Sudhi Laaye.

Lankaa So Kot Samudr Si Khaaee.
Jaat Pavansut Baar Na Laaee.

Lankaa Jaari Asur Sanhaare.
Seetaaraam Ji Ke Kaaj Sanvaare.

Sur Nar Muni Jan Aarti Utaare.
Jai Jai Jai Hanumaan Uchaare.',
'Brings courage, removes fear, and invites Hanuman''s protection.',
'During Hanuman puja, on Tuesdays and Saturdays.',
10, 'daily_prayer', 'beginner', true, true, 9
WHERE NOT EXISTS (SELECT 1 FROM sacred_texts WHERE slug = 'hanuman-aarti');

-- Bajrang Baan
INSERT INTO sacred_texts (slug, title, title_hindi, type, deity_slug, text_hindi, text_english, benefits, when_to_recite, verse_count, category, difficulty, is_featured, is_active, order_index)
SELECT 'bajrang-baan', 'Bajrang Baan', 'बजरंग बाण', 'stotra', 'Hanuman',
'निश्चय प्रेम प्रतीति ते, विनय करें सनमान।
तेहि के कारज सकल शुभ, सिद्ध करें हनुमान॥

जय हनुमन्त सन्त हितकारी। सुन लीजे प्रभु अरज हमारी॥
जन के काज विलम्ब न कीजे। आतुर दौरि महा सुख दीजे॥

जैसे कूदि सिन्धु माहीं। सुरसा बदन पैठि गई नाहीं॥
आगे जाय लंकिनी रोका। मारेहु लात गई सुर लोका॥',
'Nishchay Prem Prateeti Te, Vinay Karein Sanmaan.
Tehi Ke Kaaraj Sakal Shubh, Siddh Karein Hanumaan.

Jai Hanumant Sant Hitkaari. Sun Leeje Prabhu Araj Hamaari.
Jan Ke Kaaj Vilamb Na Keeje. Aatur Dauri Mahaa Sukh Deeje.

Jaise Koodi Sindhu Maaheen. Surasaa Badan Paithi Gaee Naaheen.
Aage Jaay Lankinee Rokaa. Maarehu Laat Gaee Sur Lokaa.',
'Extremely powerful for protection. Removes black magic, evil spirits, and severe obstacles.',
'During extreme danger, on Tuesdays and Saturdays.',
20, 'daily_prayer', 'intermediate', true, true, 10
WHERE NOT EXISTS (SELECT 1 FROM sacred_texts WHERE slug = 'bajrang-baan');

-- Shiva Panchakshar Stotra
INSERT INTO sacred_texts (slug, title, title_hindi, type, deity_slug, text_hindi, text_english, benefits, when_to_recite, verse_count, category, difficulty, is_featured, is_active, order_index)
SELECT 'shiva-panchakshar-stotra', 'Shiva Panchakshar Stotra', 'शिव पंचाक्षर स्तोत्र', 'stotra', 'shiva',
'ॐ नमः शिवाय शुभं शुभं करोतु।

नागेन्द्रहाराय त्रिलोचनाय भस्मांगरागाय महेश्वराय।
नित्याय शुद्धाय दिगम्बराय तस्मै न काराय नमः शिवाय॥

मन्दाकिनी सलिल चन्दन चर्चिताय नन्दीश्वर प्रमथनाथ महेश्वराय।
मन्दारपुष्प बहुपुष्प सुपूजिताय तस्मै म काराय नमः शिवाय॥

शिवाय गौरी वदनाब्ज बृन्द सूर्याय दक्षाध्वर नाशकाय।
श्री नीलकण्ठाय वृषध्वजाय तस्मै शि काराय नमः शिवाय॥

वसिष्ठ कुम्भोद्भव गौतमार्य मुनीन्द्र देवार्चित शेखराय।
चन्द्रार्क वैश्वानर लोचनाय तस्मै वा काराय नमः शिवाय॥

यज्ञ स्वरूपाय जटाधराय पिनाक हस्ताय सनातनाय।
दिव्याय देवाय दिगम्बराय तस्मै य काराय नमः शिवाय॥',
'Om Namah Shivaaya Shubham Shubham Karotu.

Naagendrahaaraaya Trilochanaaya Bhasmaangaraagaaya Maheshwaraaya.
Nityaaya Shuddhaaya Digambaraaya Tasmai Na Kaaraaya Namah Shivaaya.

Mandaakinee Salil Chandan Charchitaaya Nandeeshwar Pramathanath Maheshwaraaya.
Mandaarapushp Bahupushp Supoojitaaya Tasmai Ma Kaaraaya Namah Shivaaya.

Shivaaya Gauri Vadanaabj Vrinda Sooryaaya Dakshaadhvar Naashakaaya.
Shri Neelakanthaaya Vrishadwajaaya Tasmai Shi Kaaraaya Namah Shivaaya.

Vasishth Kumbhodbhav Gautamaary Muneendra Devaarchit Shekharaaya.
Chandraarka Vaishwaanara Lochanaaya Tasmai Vaa Kaaraaya Namah Shivaaya.

Yagya Swaroopaya Jataadhaaraaya Pinaak Hastaaya Sanaatanaaya.
Divyaaya Devaaya Digambaraaya Tasmai Ya Kaaraaya Namah Shivaaya.',
'Explains each syllable of Om Namah Shivaya. Grants spiritual knowledge and Shiva''s grace.',
'On Mondays, during Pradosh Vrat, and Maha Shivaratri.',
6, 'daily_prayer', 'intermediate', true, true, 11
WHERE NOT EXISTS (SELECT 1 FROM sacred_texts WHERE slug = 'shiva-panchakshar-stotra');

-- Vishnu Sahasranama (Key Verses)
INSERT INTO sacred_texts (slug, title, title_hindi, type, deity_slug, text_hindi, text_english, benefits, when_to_recite, verse_count, category, difficulty, is_featured, is_active, order_index)
SELECT 'vishnu-sahasranama-key', 'Vishnu Sahasranama (Key Verses)', 'विष्णु सहस्रनाम (मुख्य श्लोक)', 'sahasranama', 'Krishna',
'ॐ विश्वं विष्णुर्वषट्कारो भूतभव्यभवत्प्रभुः।
भूतकृद्भूतभृद्भावो भूतात्मा भूतभावनः॥

पूतात्मा परमात्मा च मुक्तानां परमा गतिः।
अव्ययः पुरुषः साक्षी क्षेत्रज्ञोऽक्षर एव च॥

सर्वदर्शी विमुक्तात्मा सर्वज्ञो ज्ञानमुत्तमम्।
सुव्रतः सुमुखः सूक्ष्मः सुघोषः सुखदः सुहृत्॥',
'Om Vishwam Vishnur Vashatkaro Bhootabhavyabhavatprabhuh.
Bhootakrid Bhootabhrid Bhaavo Bhootaatmaa Bhootabhaavnah.

Pootaatmaa Paramaatmaa Cha Muktaanaam Paramaa Gatih.
Avyayah Purushah Saakshee Kshetragyoakshara Eva Cha.

Sarvadarshee Vimuktaatmaa Sarvagyo Gyaanmuttamam.
Suvratah Sumukhah Sookshmah Sughosah Sukhadah Suhrit.',
'Chanting the thousand names of Vishnu grants protection, prosperity, and liberation.',
'On Ekadashi, Thursdays, and during Vishnu puja.',
107, 'daily_prayer', 'advanced', false, true, 12
WHERE NOT EXISTS (SELECT 1 FROM sacred_texts WHERE slug = 'vishnu-sahasranama-key');

-- Ganesh Atharvasheersha
INSERT INTO sacred_texts (slug, title, title_hindi, type, deity_slug, text_hindi, text_english, benefits, when_to_recite, verse_count, category, difficulty, is_featured, is_active, order_index)
SELECT 'ganesh-atharvasheersha', 'Ganesh Atharvasheersha', 'गणेश अथर्वशीर्ष', 'stotra', 'ganesha',
'ॐ नमस्ते गणपतये।
त्वमेव प्रत्यक्षं तत्त्वमसि। त्वमेव केवलं कर्ताऽसि।
त्वमेव केवलं धर्ताऽसि। त्वमेव केवलं हर्ताऽसि।
त्वमेव सर्वं खल्विदं ब्रह्मासि।
त्वं साक्षादात्माऽसि नित्यम्॥

ऋतं वच्मि। सत्यं वच्मि।

अव त्वं माम्। अव वक्तारम्।
अव श्रोतारम्। अव दातारम्।
अव धातारम्। अवानूचानमव शिष्यम्।

ॐ शान्तिः शान्तिः शान्तिः॥',
'Om Namaste Ganapataye.
Tvameva Pratyaksham Tattvamasi. Tvameva Kevalam Kartaasi.
Tvameva Kevalam Dhartaasi. Tvameva Kevalam Hartaasi.
Tvameva Sarvam Khalvidam Brahmaasi.
Tvam Saakshaadaatmaasi Nityam.

Ritam Vachmi. Satyam Vachmi.

Ava Tvam Maam. Ava Vaktaaram.
Ava Shrotaaram. Ava Daataaram.
Ava Dhaataaram. Avaanoochaanmava Shishyam.

Om Shaantih Shaantih Shaantih.',
'An Upanishadic hymn declaring Ganesha as supreme reality. Grants deep spiritual wisdom.',
'On Ganesh Chaturthi, Sankashti, and before any spiritual study.',
10, 'daily_prayer', 'intermediate', false, true, 13
WHERE NOT EXISTS (SELECT 1 FROM sacred_texts WHERE slug = 'ganesh-atharvasheersha');
