"""
Re-update Hanuman Chalisa English (fix from test overwrite) and insert all new texts.
"""
import requests, json, sys
sys.stdout.reconfigure(encoding='utf-8')

URL = "https://qyikatemonzykqamtvod.supabase.co"
KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5aWthdGVtb256eWtxYW10dm9kIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk2NTQzMDIsImV4cCI6MjA4NTIzMDMwMn0.YlulvY1iIlK-pBNkFdmKMwnfn0avMfQO35KW-Z7plAA"
H = {"apikey": KEY, "Authorization": f"Bearer {KEY}", "Content-Type": "application/json", "Prefer": "return=minimal"}
H_READ = {"apikey": KEY, "Authorization": f"Bearer {KEY}"}

log = []

# ═══════════════════════════════════════════════════════════
# FIX 1: Re-update Hanuman Chalisa text_english
# ═══════════════════════════════════════════════════════════

hanuman_chalisa_english = """|| Doha ||
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
Keeje Naath Hriday Mah Deraa.
"""

r = requests.patch(
    f"{URL}/rest/v1/sacred_texts?slug=eq.hanuman-chalisa",
    headers=H,
    json={"text_english": hanuman_chalisa_english.strip()}
)
log.append(f"Updated Hanuman Chalisa English: {r.status_code}")

# ═══════════════════════════════════════════════════════════
# FIX 2: Update Shiv Tandav Stotram text_english
# ═══════════════════════════════════════════════════════════

shiv_tandav_english = """Jatataveegalajjalapravaahapaavitasthale
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
Bhajeh Akhandameeshwaram Trijagadaashritam Param.
"""

r = requests.patch(
    f"{URL}/rest/v1/sacred_texts?slug=eq.shiv-tandav-stotram",
    headers=H,
    json={"text_english": shiv_tandav_english.strip()}
)
log.append(f"Updated Shiv Tandav English: {r.status_code}")

# ═══════════════════════════════════════════════════════════
# STEP 3: Insert new sacred texts
# ═══════════════════════════════════════════════════════════

NEW_TEXTS = [
{
    "slug": "shiva-aarti",
    "title": "Shiva Aarti",
    "title_hindi": "शिव आरती",
    "type": "aarti",
    "deity_slug": "shiva",
    "text_hindi": "ॐ जय शिव ओंकारा, स्वामी जय शिव ओंकारा।\nब्रह्मा, विष्णु, सदाशिव, अर्धांगी धारा॥\nॐ जय शिव ओंकारा॥\n\nएकानन चतुरानन पंचानन राजे।\nहंसासन गरुड़ासन वृषवाहन साजे॥\nॐ जय शिव ओंकारा॥\n\nदो भुज चार चतुर्भुज दस भुज अति सोहे।\nतीनों रूप निरखता त्रिभुवन जन मोहे॥\nॐ जय शिव ओंकारा॥\n\nअक्षमाला वनमाला मुण्डमाला धारी।\nत्रिपुरारी कंसारी कर माला धारी॥\nॐ जय शिव ओंकारा॥\n\nश्वेताम्बर पीताम्बर बाघम्बर अंगे।\nसनकादिक गरुणादिक भूतादिक संगे॥\nॐ जय शिव ओंकारा॥\n\nकर के मध्य कमण्डलु चक्र त्रिशूलधारी।\nसुखकारी दुःखहारी जगपालन कारी॥\nॐ जय शिव ओंकारा॥\n\nब्रह्मा विष्णु सदाशिव जानत अविवेका।\nप्रणवाक्षर में शोभित ये तीनों एका॥\nॐ जय शिव ओंकारा॥\n\nत्रिगुण स्वामी की आरती जो कोई नर गावे।\nकहत शिवानन्द स्वामी मनवांछित फल पावे॥\nॐ जय शिव ओंकारा॥",
    "text_english": "Om Jai Shiv Onkaara, Swaami Jai Shiv Onkaara.\nBrahmaa, Vishnu, Sadaashiv, Ardhaangi Dhaaraa.\nOm Jai Shiv Onkaara.\n\nEkaanan Chaturaanan Panchaanan Raaje.\nHansaasan Garudaasan Vrishavaahan Saaje.\nOm Jai Shiv Onkaara.\n\nDo Bhuj Chaar Chaturbhuj Das Bhuj Ati Sohe.\nTeenon Roop Nirakhata Tribhuvan Jan Mohe.\nOm Jai Shiv Onkaara.\n\nAkshmaala Vanmaala Mundmaala Dhaari.\nTripuraari Kansaari Kar Maala Dhaari.\nOm Jai Shiv Onkaara.\n\nShvetaambar Peetaambar Baaghaambar Ange.\nSanakaadik Garunaadik Bhootaadik Sange.\nOm Jai Shiv Onkaara.\n\nKar Ke Madhya Kamandalu Chakra Trishool Dhaari.\nSukhkaari Duhkhahaari Jagpaalan Kaari.\nOm Jai Shiv Onkaara.\n\nBrahmaa Vishnu Sadaashiv Jaanat Aviveka.\nPranavaakshar Mein Shobhit Ye Teenon Ekaa.\nOm Jai Shiv Onkaara.\n\nTrigun Swaami Ki Aarti Jo Koi Nar Gaave.\nKahat Shivaanand Swaami Manvaanchhit Phal Paave.\nOm Jai Shiv Onkaara.",
    "benefits": "Brings peace, removes negativity, and invokes Lord Shiva's blessings for spiritual growth.",
    "when_to_recite": "During Shiva puja, especially on Mondays, Maha Shivaratri, and Pradosh Kaal.",
    "verse_count": 8,
    "category": "daily_prayer",
    "difficulty": "beginner",
    "is_featured": True,
    "is_active": True,
    "order_index": 3,
},
{
    "slug": "maha-mrityunjaya-mantra",
    "title": "Maha Mrityunjaya Mantra",
    "title_hindi": "महा मृत्युंजय मंत्र",
    "type": "mantra",
    "deity_slug": "shiva",
    "text_hindi": "ॐ त्र्यम्बकं यजामहे सुगन्धिं पुष्टिवर्धनम्।\nउर्वारुकमिव बन्धनान् मृत्योर्मुक्षीय मामृतात्॥",
    "text_english": "Om Tryambakam Yajaamahe Sugandhim Pushtivarddhanam.\nUrvaarukamiva Bandhanaan Mrityormuksheeya Maamritaat.",
    "benefits": "The most powerful mantra for healing, longevity, and overcoming the fear of death.",
    "when_to_recite": "During illness, danger, or daily as protection. Especially on Mondays and Maha Shivaratri.",
    "verse_count": 1,
    "category": "daily_prayer",
    "difficulty": "beginner",
    "is_featured": True,
    "is_active": True,
    "order_index": 4,
},
{
    "slug": "krishna-aarti",
    "title": "Krishna Aarti",
    "title_hindi": "कृष्ण आरती",
    "type": "aarti",
    "deity_slug": "Krishna",
    "text_hindi": "ॐ जय जगदीश हरे, स्वामी जय जगदीश हरे।\nभक्त जनों के संकट, दास जनों के संकट,\nक्षण में दूर करे॥\nॐ जय जगदीश हरे॥\n\nजो ध्यावे फल पावे, दुःख बिनसे मन का।\nस्वामी दुःख बिनसे मन का।\nसुख सम्पत्ति घर आवे, सुख सम्पत्ति घर आवे,\nकष्ट मिटे तन का॥\nॐ जय जगदीश हरे॥\n\nमात पिता तुम मेरे, शरण गहूं किसकी।\nस्वामी शरण गहूं किसकी।\nतुम बिन और न दूजा, तुम बिन और न दूजा,\nआस करूं जिसकी॥\nॐ जय जगदीश हरे॥\n\nतुम पूरन परमात्मा, तुम अंतर्यामी।\nस्वामी तुम अंतर्यामी।\nपारब्रह्म परमेश्वर, पारब्रह्म परमेश्वर,\nतुम सबके स्वामी॥\nॐ जय जगदीश हरे॥",
    "text_english": "Om Jai Jagdeesh Hare, Swaami Jai Jagdeesh Hare.\nBhakt Janon Ke Sankat, Daas Janon Ke Sankat,\nKshan Mein Door Kare.\nOm Jai Jagdeesh Hare.\n\nJo Dhyaave Phal Paave, Dukh Binse Man Ka.\nSwaami Dukh Binse Man Ka.\nSukh Sampatti Ghar Aave, Sukh Sampatti Ghar Aave,\nKasht Mite Tan Ka.\nOm Jai Jagdeesh Hare.\n\nMaat Pita Tum Mere, Sharan Gahun Kiski.\nSwaami Sharan Gahun Kiski.\nTum Bin Aur Na Dooja, Tum Bin Aur Na Dooja,\nAas Karun Jiski.\nOm Jai Jagdeesh Hare.\n\nTum Pooran Paramaatma, Tum Antaryaami.\nSwaami Tum Antaryaami.\nPaarbrahm Parmeshwar, Paarbrahm Parmeshwar,\nTum Sabke Swaami.\nOm Jai Jagdeesh Hare.",
    "benefits": "Invokes Lord Krishna's blessings, removes sorrows, and brings prosperity and peace.",
    "when_to_recite": "During daily evening aarti, Janmashtami, Ekadashi, and any Krishna puja.",
    "verse_count": 7,
    "category": "daily_prayer",
    "difficulty": "beginner",
    "is_featured": True,
    "is_active": True,
    "order_index": 5,
},
{
    "slug": "hare-krishna-maha-mantra",
    "title": "Hare Krishna Maha Mantra",
    "title_hindi": "हरे कृष्ण महा मंत्र",
    "type": "mantra",
    "deity_slug": "Krishna",
    "text_hindi": "हरे कृष्ण हरे कृष्ण कृष्ण कृष्ण हरे हरे।\nहरे राम हरे राम राम राम हरे हरे॥",
    "text_english": "Hare Krishna Hare Krishna, Krishna Krishna Hare Hare.\nHare Raam Hare Raam, Raam Raam Hare Hare.",
    "benefits": "The supreme mantra for Kali Yuga. Purifies the mind, awakens divine love, and grants liberation.",
    "when_to_recite": "Anytime, anywhere. Chant 108 times on a mala daily for best results.",
    "verse_count": 1,
    "category": "daily_prayer",
    "difficulty": "beginner",
    "is_featured": True,
    "is_active": True,
    "order_index": 6,
},
{
    "slug": "ganesh-aarti",
    "title": "Ganesh Aarti",
    "title_hindi": "गणेश आरती",
    "type": "aarti",
    "deity_slug": "ganesha",
    "text_hindi": "जय गणेश जय गणेश जय गणेश देवा।\nमाता जाकी पार्वती पिता महादेवा॥\n\nएक दन्त दयावन्त चार भुजा धारी।\nमाथे पर तिलक सोहे मूसे की सवारी॥\nजय गणेश जय गणेश जय गणेश देवा॥\n\nपान चढ़े फूल चढ़े और चढ़े मेवा।\nलड्डुअन का भोग लगे सन्त करें सेवा॥\nजय गणेश जय गणेश जय गणेश देवा॥\n\nअंधन को आंख देत कोढ़िन को काया।\nबांझन को पुत्र देत निर्धन को माया॥\nजय गणेश जय गणेश जय गणेश देवा॥\n\nदीनन की लाज रखो शम्भू सुत वारी।\nकामना को पूर्ण करो जाउं बलिहारी॥\nजय गणेश जय गणेश जय गणेश देवा॥",
    "text_english": "Jai Ganesh Jai Ganesh Jai Ganesh Deva.\nMaata Jaaki Paarvati Pitaa Mahaadeva.\n\nEk Dant Dayaavant Chaar Bhuja Dhaari.\nMaathe Par Tilak Sohe Moose Ki Savaari.\nJai Ganesh Jai Ganesh Jai Ganesh Deva.\n\nPaan Chadhe Phool Chadhe Aur Chadhe Mevaa.\nLadduan Ka Bhog Lage Sant Karein Seva.\nJai Ganesh Jai Ganesh Jai Ganesh Deva.\n\nAndhan Ko Aankh Det Kodhin Ko Kaayaa.\nBaanjhan Ko Putra Det Nirdhan Ko Maayaa.\nJai Ganesh Jai Ganesh Jai Ganesh Deva.\n\nDeenan Ki Laaj Rakho Shambhu Sut Vaari.\nKaamnaa Ko Poorn Karo Jaun Balihaari.\nJai Ganesh Jai Ganesh Jai Ganesh Deva.",
    "benefits": "Removes obstacles, brings wisdom and good fortune. Essential before beginning any new venture.",
    "when_to_recite": "Before any puja, on Wednesdays, Ganesh Chaturthi, and Sankashti Chaturthi.",
    "verse_count": 6,
    "category": "daily_prayer",
    "difficulty": "beginner",
    "is_featured": True,
    "is_active": True,
    "order_index": 7,
},
{
    "slug": "ganesh-mantra",
    "title": "Ganesh Beej Mantra",
    "title_hindi": "गणेश बीज मंत्र",
    "type": "mantra",
    "deity_slug": "ganesha",
    "text_hindi": "ॐ गं गणपतये नमः॥\n\nवक्रतुण्ड महाकाय सूर्यकोटि समप्रभ।\nनिर्विघ्नं कुरु मे देव सर्वकार्येषु सर्वदा॥",
    "text_english": "Om Gam Ganapataye Namah.\n\nVakratunda Mahaakaaya Suryakoti Samaprabha.\nNirvighnam Kuru Me Deva Sarvakaaryeshu Sarvadaa.",
    "benefits": "Invokes Ganesha's energy to remove obstacles and ensure success in all endeavors.",
    "when_to_recite": "Before starting anything new — exams, business, travel. Chant 108 times.",
    "verse_count": 2,
    "category": "daily_prayer",
    "difficulty": "beginner",
    "is_featured": True,
    "is_active": True,
    "order_index": 8,
},
{
    "slug": "hanuman-aarti",
    "title": "Hanuman Aarti",
    "title_hindi": "हनुमान आरती",
    "type": "aarti",
    "deity_slug": "Hanuman",
    "text_hindi": "आरती कीजै हनुमान लला की।\nदुष्ट दलन रघुनाथ कला की॥\n\nजाके बल से गिरिवर कांपे।\nरोग दोष जाके निकट न झांके॥\n\nअंजनी पुत्र महा बलदाई।\nसंतन के प्रभु सदा सहाई॥\n\nदे बीड़ा रघुनाथ पठाए।\nलंका जारि सिया सुधि लाए॥\n\nलंका सो कोट समुद्र सी खाई।\nजात पवनसुत बार न लाई॥\n\nलंका जारि असुर संहारे।\nसीताराम जी के काज संवारे॥\n\nसुर नर मुनि जन आरती उतारे।\nजय जय जय हनुमान उचारे॥",
    "text_english": "Aarti Keejai Hanumaan Lalaa Ki.\nDusht Dalan Raghunaath Kalaa Ki.\n\nJaake Bal Se Girivar Kaanpe.\nRog Dosh Jaake Nikat Na Jhaanke.\n\nAnjani Putra Mahaa Baldaaee.\nSantan Ke Prabhu Sadaa Sahaaee.\n\nDe Beedaa Raghunaath Pathaaye.\nLankaa Jaari Siyaa Sudhi Laaye.\n\nLankaa So Kot Samudr Si Khaaee.\nJaat Pavansut Baar Na Laaee.\n\nLankaa Jaari Asur Sanhaare.\nSeetaaraam Ji Ke Kaaj Sanvaare.\n\nSur Nar Muni Jan Aarti Utaare.\nJai Jai Jai Hanumaan Uchaare.",
    "benefits": "Brings courage, removes fear, and invites Hanuman's protection. Cures diseases and wards off evil.",
    "when_to_recite": "During Hanuman puja, on Tuesdays and Saturdays.",
    "verse_count": 10,
    "category": "daily_prayer",
    "difficulty": "beginner",
    "is_featured": True,
    "is_active": True,
    "order_index": 9,
},
{
    "slug": "bajrang-baan",
    "title": "Bajrang Baan",
    "title_hindi": "बजरंग बाण",
    "type": "stotra",
    "deity_slug": "Hanuman",
    "text_hindi": "निश्चय प्रेम प्रतीति ते, विनय करें सनमान।\nतेहि के कारज सकल शुभ, सिद्ध करें हनुमान॥\n\nजय हनुमन्त सन्त हितकारी। सुन लीजे प्रभु अरज हमारी॥\nजन के काज विलम्ब न कीजे। आतुर दौरि महा सुख दीजे॥\n\nजैसे कूदि सिन्धु माहीं। सुरसा बदन पैठि गई नाहीं॥\nआगे जाय लंकिनी रोका। मारेहु लात गई सुर लोका॥",
    "text_english": "Nishchay Prem Prateeti Te, Vinay Karein Sanmaan.\nTehi Ke Kaaraj Sakal Shubh, Siddh Karein Hanumaan.\n\nJai Hanumant Sant Hitkaari. Sun Leeje Prabhu Araj Hamaari.\nJan Ke Kaaj Vilamb Na Keeje. Aatur Dauri Mahaa Sukh Deeje.\n\nJaise Koodi Sindhu Maaheen. Surasaa Badan Paithi Gaee Naaheen.\nAage Jaay Lankinee Rokaa. Maarehu Laat Gaee Sur Lokaa.",
    "benefits": "Extremely powerful for protection. Removes black magic, evil spirits, and severe obstacles.",
    "when_to_recite": "During extreme danger, on Tuesdays and Saturdays. Recite with full devotion.",
    "verse_count": 20,
    "category": "daily_prayer",
    "difficulty": "intermediate",
    "is_featured": True,
    "is_active": True,
    "order_index": 10,
},
{
    "slug": "shiva-panchakshar-stotra",
    "title": "Shiva Panchakshar Stotra",
    "title_hindi": "शिव पंचाक्षर स्तोत्र",
    "type": "stotra",
    "deity_slug": "shiva",
    "text_hindi": "ॐ नमः शिवाय शुभं शुभं करोतु।\n\nनागेन्द्रहाराय त्रिलोचनाय भस्मांगरागाय महेश्वराय।\nनित्याय शुद्धाय दिगम्बराय तस्मै 'न' काराय नमः शिवाय॥\n\nमन्दाकिनी सलिल चन्दन चर्चिताय नन्दीश्वर प्रमथनाथ महेश्वराय।\nमन्दारपुष्प बहुपुष्प सुपूजिताय तस्मै 'म' काराय नमः शिवाय॥\n\nशिवाय गौरी वदनाब्ज बृन्द सूर्याय दक्षाध्वर नाशकाय।\nश्री नीलकण्ठाय वृषध्वजाय तस्मै 'शि' काराय नमः शिवाय॥\n\nवसिष्ठ कुम्भोद्भव गौतमार्य मुनीन्द्र देवार्चित शेखराय।\nचन्द्रार्क वैश्वानर लोचनाय तस्मै 'वा' काराय नमः शिवाय॥\n\nयज्ञ स्वरूपाय जटाधराय पिनाक हस्ताय सनातनाय।\nदिव्याय देवाय दिगम्बराय तस्मै 'य' काराय नमः शिवाय॥",
    "text_english": "Om Namah Shivaaya Shubham Shubham Karotu.\n\nNaagendrahaaraaya Trilochanaaya Bhasmaangaraagaaya Maheshwaraaya.\nNityaaya Shuddhaaya Digambaraaya Tasmai 'Na' Kaaraaya Namah Shivaaya.\n\nMandaakinee Salil Chandan Charchitaaya Nandeeshwar Pramathanath Maheshwaraaya.\nMandaarapushp Bahupushp Supoojitaaya Tasmai 'Ma' Kaaraaya Namah Shivaaya.\n\nShivaaya Gauri Vadanaabj Vrinda Sooryaaya Dakshaadhvar Naashakaaya.\nShri Neelakanthaaya Vrishadwajaaya Tasmai 'Shi' Kaaraaya Namah Shivaaya.\n\nVasishth Kumbhodbhav Gautamaary Muneendra Devaarchit Shekharaaya.\nChandraarka Vaishwaanara Lochanaaya Tasmai 'Vaa' Kaaraaya Namah Shivaaya.\n\nYagya Swaroopaya Jataadhaaraaya Pinaak Hastaaya Sanaatanaaya.\nDivyaaya Devaaya Digambaraaya Tasmai 'Ya' Kaaraaya Namah Shivaaya.",
    "benefits": "Explains each syllable of Om Namah Shivaya. Grants spiritual knowledge and Shiva's grace.",
    "when_to_recite": "On Mondays, during Pradosh Vrat, and Maha Shivaratri.",
    "verse_count": 6,
    "category": "daily_prayer",
    "difficulty": "intermediate",
    "is_featured": True,
    "is_active": True,
    "order_index": 11,
},
{
    "slug": "vishnu-sahasranama-key",
    "title": "Vishnu Sahasranama (Key Verses)",
    "title_hindi": "विष्णु सहस्रनाम (मुख्य श्लोक)",
    "type": "sahasranama",
    "deity_slug": "Krishna",
    "text_hindi": "ॐ विश्वं विष्णुर्वषट्कारो भूतभव्यभवत्प्रभुः।\nभूतकृद्भूतभृद्भावो भूतात्मा भूतभावनः॥\n\nपूतात्मा परमात्मा च मुक्तानां परमा गतिः।\nअव्ययः पुरुषः साक्षी क्षेत्रज्ञोऽक्षर एव च॥\n\nसर्वदर्शी विमुक्तात्मा सर्वज्ञो ज्ञानमुत्तमम्।\nसुव्रतः सुमुखः सूक्ष्मः सुघोषः सुखदः सुहृत्॥",
    "text_english": "Om Vishwam Vishnur Vashatkaro Bhootabhavyabhavatprabhuh.\nBhootakrid Bhootabhrid Bhaavo Bhootaatmaa Bhootabhaavnah.\n\nPootaatmaa Paramaatmaa Cha Muktaanaam Paramaa Gatih.\nAvyayah Purushah Saakshee Kshetragyoakshara Eva Cha.\n\nSarvadarshee Vimuktaatmaa Sarvagyo Gyaanmuttamam.\nSuvratah Sumukhah Sookshmah Sughosah Sukhadah Suhrit.",
    "benefits": "Chanting the thousand names of Vishnu grants protection, prosperity, and liberation.",
    "when_to_recite": "On Ekadashi, Thursdays, and during Vishnu puja. Ideal for daily morning recitation.",
    "verse_count": 107,
    "category": "daily_prayer",
    "difficulty": "advanced",
    "is_featured": False,
    "is_active": True,
    "order_index": 12,
},
{
    "slug": "ganesh-atharvasheersha",
    "title": "Ganesh Atharvasheersha",
    "title_hindi": "गणेश अथर्वशीर्ष",
    "type": "stotra",
    "deity_slug": "ganesha",
    "text_hindi": "ॐ नमस्ते गणपतये।\nत्वमेव प्रत्यक्षं तत्त्वमसि। त्वमेव केवलं कर्ताऽसि।\nत्वमेव केवलं धर्ताऽसि। त्वमेव केवलं हर्ताऽसि।\nत्वमेव सर्वं खल्विदं ब्रह्मासि।\nत्वं साक्षादात्माऽसि नित्यम्॥\n\nऋतं वच्मि। सत्यं वच्मि।\n\nअव त्वं माम्। अव वक्तारम्।\nअव श्रोतारम्। अव दातारम्।\nअव धातारम्। अवानूचानमव शिष्यम्।\n\nॐ शान्तिः शान्तिः शान्तिः॥",
    "text_english": "Om Namaste Ganapataye.\nTvameva Pratyaksham Tattvamasi. Tvameva Kevalam Kartaasi.\nTvameva Kevalam Dhartaasi. Tvameva Kevalam Hartaasi.\nTvameva Sarvam Khalvidam Brahmaasi.\nTvam Saakshaadaatmaasi Nityam.\n\nRitam Vachmi. Satyam Vachmi.\n\nAva Tvam Maam. Ava Vaktaaram.\nAva Shrotaaram. Ava Daataaram.\nAva Dhaataaram. Avaanoochaanmava Shishyam.\n\nOm Shaantih Shaantih Shaantih.",
    "benefits": "An Upanishadic hymn declaring Ganesha as supreme reality. Grants deep spiritual wisdom.",
    "when_to_recite": "On Ganesh Chaturthi, Sankashti, and before any spiritual study.",
    "verse_count": 10,
    "category": "daily_prayer",
    "difficulty": "intermediate",
    "is_featured": False,
    "is_active": True,
    "order_index": 13,
},
]

# Get existing slugs
r = requests.get(f"{URL}/rest/v1/sacred_texts?select=slug", headers=H_READ)
existing = {t["slug"] for t in r.json()}
log.append(f"Existing slugs: {existing}")

for t in NEW_TEXTS:
    if t["slug"] in existing:
        log.append(f"  SKIP: {t['title']} (already exists)")
        continue
    r = requests.post(f"{URL}/rest/v1/sacred_texts", headers=H, json=t)
    if r.status_code in (200, 201):
        log.append(f"  OK: {t['title']}")
    else:
        log.append(f"  FAIL ({r.status_code}): {t['title']} - {r.text[:200]}")

# Final verify
r = requests.get(f"{URL}/rest/v1/sacred_texts?select=slug,title,deity_slug,type,is_featured&order=order_index.asc", headers=H_READ)
final = r.json()
log.append(f"\nFinal count: {len(final)}")
for t in final:
    log.append(f"  [{t['deity_slug']}] {t['title']} ({t['type']}) featured={t['is_featured']}")

# Write log
with open("scripts/insert_result.txt", "w", encoding="utf-8") as f:
    f.write("\n".join(log))
print("Done - check scripts/insert_result.txt")
