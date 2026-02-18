#!/usr/bin/env python3
"""Insert additional sacred stories - batch 3."""
import requests

URL = "https://qyikatemonzykqamtvod.supabase.co"
KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5aWthdGVtb256eWtxYW10dm9kIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk2NTQzMDIsImV4cCI6MjA4NTIzMDMwMn0.YlulvY1iIlK-pBNkFdmKMwnfn0avMfQO35KW-Z7plAA"
H_READ = {"apikey": KEY, "Authorization": f"Bearer {KEY}"}
H_WRITE = {"apikey": KEY, "Authorization": f"Bearer {KEY}", "Content-Type": "application/json", "Prefer": "return=minimal"}

def p(en, hi, final=False):
    d = {"text_english": en, "text_hindi": hi}
    if final:
        d["is_final"] = True
    return d

r = requests.get(f"{URL}/rest/v1/sacred_stories?select=slug", headers=H_READ)
existing = {s["slug"] for s in r.json()}
print(f"Existing: {len(existing)} stories")

STORIES = [
# ══════ MORE SHIVA ══════
{
 "slug": "shiva-parvati-marriage",
 "title": "The Marriage of Shiva and Parvati",
 "title_hindi": "शिव-पार्वती विवाह",
 "deity_slug": "shiva",
 "source": "Shiva Purana",
 "category": "mythology",
 "key_teaching": "True love requires patience, devotion, and surrender of ego from both sides.",
 "reflection_prompt": "What have you been willing to transform about yourself for love?",
 "estimated_minutes": 4,
 "is_featured": True,
 "is_active": True,
 "order_index": 20,
 "pages": [
  p("After Sati immolated herself, Shiva withdrew from the world into deep meditation on Mount Kailash. Without Shiva's participation, the universe lost its balance. The demon Tarakasura terrorized the gods, protected by a boon that only Shiva's son could destroy him.",
    "सती के आत्मदाह के बाद, शिव संसार से विमुख होकर कैलाश पर गहन ध्यान में चले गए। शिव की सहभागिता के बिना ब्रह्मांड का संतुलन बिगड़ गया। राक्षस तारकासुर ने देवताओं पर अत्याचार किया, एक वरदान से सुरक्षित कि केवल शिव का पुत्र ही उसे मार सकता है।"),
  p("Sati was reborn as Parvati, daughter of the Himalaya mountain king. From childhood, she loved Shiva with an intensity that surprised even the gods. She went to Kailash to serve the meditating Shiva, offering flowers and prayers in silence, year after year.",
    "सती ने पार्वती के रूप में पुनर्जन्म लिया, हिमालय पर्वत राजा की पुत्री। बचपन से ही उन्हें शिव से इतना गहन प्रेम था जो देवताओं को भी आश्चर्यचकित करता था। वे ध्यानमग्न शिव की सेवा करने कैलाश गईं, मौन रहकर वर्ष दर वर्ष पुष्प और प्रार्थनाएँ अर्पित करती रहीं।"),
  p("When devotion alone did not break Shiva's meditation, Parvati undertook the fiercest tapasya. She stood in freezing rivers, sat amidst five fires in summer, and meditated without food or water. Her penance shook the heavens. Finally, Shiva opened his eyes and saw Parvati's unwavering love.",
    "जब केवल भक्ति से शिव का ध्यान नहीं टूटा, पार्वती ने कठोरतम तपस्या की। बर्फीली नदियों में खड़ी रहीं, गर्मी में पंचाग्नि के बीच बैठीं, बिना अन्न-जल ध्यान किया। उनकी तपस्या से स्वर्ग काँप उठा। अंततः शिव ने आँखें खोलीं और पार्वती का अटल प्रेम देखा।"),
  p("Their wedding was the grandest event in creation. Every god, sage, river, and mountain attended. The cosmic dance of Shiva and the nurturing grace of Parvati united once more. This story teaches that love which transforms the self is the love that transforms the universe.",
    "उनका विवाह सृष्टि का सबसे भव्य आयोजन था। प्रत्येक देवता, ऋषि, नदी और पर्वत उपस्थित था। शिव का ब्रह्मांडीय नृत्य और पार्वती की पोषक कृपा पुनः एक हुए। कथा सिखाती है कि जो प्रेम स्वयं को रूपांतरित करे, वही ब्रह्मांड को रूपांतरित करता है।", True),
 ]
},
{
 "slug": "shiva-nataraja-dance",
 "title": "The Cosmic Dance of Nataraja",
 "title_hindi": "नटराज का ब्रह्मांडीय नृत्य",
 "deity_slug": "shiva",
 "source": "Shiva Purana",
 "category": "moral",
 "key_teaching": "Creation and destruction are part of the same divine dance; embrace change fearlessly.",
 "reflection_prompt": "Can you find peace knowing that endings are necessary for new beginnings?",
 "estimated_minutes": 3,
 "is_featured": False,
 "is_active": True,
 "order_index": 21,
 "pages": [
  p("In the forest of Taragam, ten thousand arrogant sages believed they had mastered the universe through rituals alone. They thought they had no need for God. Shiva came to teach them humility, appearing as a wandering beggar accompanied by Vishnu disguised as the enchanting Mohini.",
    "तारागम वन में दस हजार अहंकारी ऋषि मानते थे कि उन्होंने केवल कर्मकांड से ब्रह्मांड पर अधिकार कर लिया है। उन्हें ईश्वर की कोई आवश्यकता नहीं थी। शिव उन्हें विनम्रता सिखाने आए, एक भटकते भिक्षुक के रूप में, साथ में विष्णु मोहिनी के रूप में।"),
  p("Furious at the disruption, the sages used their ritual powers to attack Shiva. They conjured a ferocious tiger, a deadly serpent, and a demonic dwarf called Apasmara (representing ignorance). Shiva calmly skinned the tiger to wear as a garment, coiled the serpent around his neck, and placed his foot upon Apasmara.",
    "व्यवधान से क्रुद्ध ऋषियों ने शिव पर आक्रमण किया। उन्होंने भयंकर बाघ, घातक सर्प, और अपस्मार नामक राक्षसी बौना (अज्ञान का प्रतीक) उत्पन्न किया। शिव ने शांति से बाघ की खाल वस्त्र बनाई, सर्प गले में लपेटा, और अपस्मार पर पैर रख दिया।"),
  p("Then Shiva began to dance the Tandava — the cosmic dance of creation and destruction. His drumbeat created new worlds, his fire dissolved old ones. His raised foot promised liberation, his crushing foot destroyed ignorance. Every movement contained the rhythm of the entire universe.",
    "फिर शिव ने तांडव आरंभ किया — सृष्टि और संहार का ब्रह्मांडीय नृत्य। उनके डमरू की ध्वनि ने नए लोक रचे, उनकी अग्नि ने पुराने लोक विलीन किए। उनका उठा पैर मोक्ष का वचन था, दबा पैर अज्ञान का नाश। हर गति में पूरे ब्रह्मांड की लय समाहित थी।"),
  p("The sages fell to their knees, realizing that all their knowledge was nothing before the divine dance. Nataraja teaches that the universe is an eternal dance — creation, preservation, destruction, concealment, and grace. To live is to dance with change, not resist it.",
    "ऋषि घुटनों पर गिर पड़े, समझ गए कि उनका सारा ज्ञान दिव्य नृत्य के समक्ष कुछ नहीं। नटराज सिखाते हैं कि ब्रह्मांड एक शाश्वत नृत्य है — सृष्टि, पालन, संहार, तिरोभाव और अनुग्रह। जीना परिवर्तन के साथ नृत्य करना है, उसका प्रतिरोध नहीं।", True),
 ]
},
# ══════ MORE KRISHNA ══════
{
 "slug": "krishna-rasa-leela",
 "title": "The Rasa Leela — Divine Dance of Love",
 "title_hindi": "रास लीला — प्रेम का दिव्य नृत्य",
 "deity_slug": "Krishna",
 "source": "Bhagavata Purana",
 "category": "leela",
 "key_teaching": "Divine love is infinite — God gives himself completely to each devotee personally.",
 "reflection_prompt": "Do you feel the divine presence is available only to some, or to all equally?",
 "estimated_minutes": 4,
 "is_featured": True,
 "is_active": True,
 "order_index": 22,
 "pages": [
  p("On a full moon night in autumn, Krishna stood at the edge of the Yamuna forest and played his enchanting flute. The melody carried through Vrindavan like a divine summons. Every Gopi, hearing the music, felt an irresistible pull in her heart and left everything to run toward the forest.",
    "शरद पूर्णिमा की रात्रि, कृष्ण यमुना वन के किनारे खड़े होकर अपनी मोहक बाँसुरी बजाई। वह स्वर वृंदावन में दिव्य आह्वान बनकर बहा। हर गोपी ने, वह संगीत सुनकर, हृदय में अनिवार्य खिंचाव अनुभव किया और सब कुछ छोड़कर वन की ओर दौड़ पड़ीं।"),
  p("Krishna danced with every single Gopi simultaneously — multiplying himself so that each Gopi believed Krishna was dancing with her alone. Each one felt his undivided attention, his complete love, his personal presence. No one was left out, no one received less.",
    "कृष्ण ने प्रत्येक गोपी के साथ एक साथ नृत्य किया — स्वयं को अनेक रूपों में विस्तारित किया ताकि हर गोपी को लगे कि कृष्ण केवल उसी के साथ नृत्य कर रहे हैं। हर एक को उनका अविभाजित ध्यान, पूर्ण प्रेम, व्यक्तिगत उपस्थिति प्राप्त हुई। कोई वंचित नहीं रहा।"),
  p("The moon stopped moving to watch. The rivers paused their flow. Even the trees blossomed out of season. The Rasa dance continued through the night as the boundary between the mortal and divine dissolved completely.",
    "चंद्रमा देखने के लिए रुक गया। नदियों ने अपनी धारा थाम ली। वृक्षों पर बेमौसम फूल खिल उठे। रास नृत्य पूरी रात चलता रहा जैसे नश्वर और दिव्य के बीच की सीमा पूर्णतः विलीन हो गई।"),
  p("The Rasa Leela is not a mere story — it is the deepest metaphor in Hinduism. It reveals that God's love is not limited. He is fully present for each devotee. You never need to compete for divine attention. The flute call is always playing; you just need to listen and follow.",
    "रास लीला केवल कथा नहीं — यह हिंदू धर्म का सबसे गहन रूपक है। यह प्रकट करता है कि ईश्वर का प्रेम सीमित नहीं है। वे प्रत्येक भक्त के लिए पूर्ण रूप से उपस्थित हैं। दिव्य ध्यान के लिए प्रतिस्पर्धा की आवश्यकता नहीं। बाँसुरी सदा बज रही है; बस सुनना और अनुसरण करना है।", True),
 ]
},
{
 "slug": "krishna-putana-salvation",
 "title": "The Salvation of Putana",
 "title_hindi": "पूतना का उद्धार",
 "deity_slug": "Krishna",
 "source": "Bhagavata Purana",
 "category": "leela",
 "key_teaching": "The divine transforms even hostile intentions into grace when you come close to God.",
 "reflection_prompt": "Can you find goodness even in those who wish you harm?",
 "estimated_minutes": 3,
 "is_featured": False,
 "is_active": True,
 "order_index": 23,
 "pages": [
  p("When Kamsa learned that his destined slayer had been born in Gokul, he sent the demoness Putana to kill all newborns. Putana disguised herself as a beautiful woman and entered the village, offering to nurse the babies. She had coated her breast with deadly poison.",
    "जब कंस को पता चला कि उसका वधकर्ता गोकुल में जन्मा है, उसने राक्षसी पूतना को सभी नवजातों को मारने भेजा। पूतना ने सुंदर स्त्री का रूप धारण कर गाँव में प्रवेश किया, शिशुओं को दूध पिलाने का प्रस्ताव देते हुए। उसने अपने स्तन पर घातक विष लगाया था।"),
  p("When Putana picked up baby Krishna and began to nurse him, Krishna knew her true nature. He suckled with divine force, drawing out not just the poison but her very life force. Putana tried to escape but collapsed, revealing her massive demonic form stretching across the fields.",
    "जब पूतना ने शिशु कृष्ण को उठाकर दूध पिलाना शुरू किया, कृष्ण ने उसके असली स्वरूप को जान लिया। उन्होंने दिव्य बल से न केवल विष बल्कि उसकी प्राण शक्ति भी खींच ली। पूतना ने भागने का प्रयास किया पर गिर पड़ी, उसका विशाल राक्षसी रूप खेतों में फैल गया।"),
  p("But here is the miracle: because Putana had offered her breast to Krishna — even with murderous intent — Krishna granted her the status of a mother. Her soul was liberated and she attained a divine realm. Even her body gave off the fragrance of sandalwood when cremated.",
    "पर चमत्कार यह हुआ: क्योंकि पूतना ने कृष्ण को अपना स्तन अर्पित किया — भले ही हत्या के इरादे से — कृष्ण ने उसे माता का दर्जा दिया। उसकी आत्मा मुक्त हुई और उसने दिव्य लोक प्राप्त किया। दाह संस्कार में उसके शरीर से चंदन की सुगंध आई।"),
  p("This story teaches the most radical form of grace: if even an enemy who approaches Krishna with poison receives liberation, imagine what awaits those who approach with genuine love. The divine sees the act of coming close, not the motive behind it.",
    "यह कथा कृपा का सबसे क्रांतिकारी रूप सिखाती है: यदि विष लेकर कृष्ण के पास आने वाली शत्रु को भी मुक्ति मिलती है, तो सोचिए सच्चे प्रेम से आने वालों को क्या मिलेगा। भगवान निकट आने का कृत्य देखते हैं, उसके पीछे का उद्देश्य नहीं।", True),
 ]
},
# ══════ MORE HANUMAN ══════
{
 "slug": "hanuman-rama-bridge",
 "title": "Hanuman Builds the Bridge to Lanka",
 "title_hindi": "हनुमान और राम सेतु",
 "deity_slug": "Hanuman",
 "source": "Ramayana",
 "category": "mythology",
 "key_teaching": "Devotion transforms even stones into stepping stones; love makes the impossible possible.",
 "reflection_prompt": "How does your faith help you bridge seemingly impossible gaps in life?",
 "estimated_minutes": 3,
 "is_featured": False,
 "is_active": True,
 "order_index": 24,
 "pages": [
  p("After Hanuman returned from Lanka with news of Sita, Rama's army needed to cross the ocean. The Vanaras began building a bridge. Each monkey carried boulders and threw them into the sea, but they kept sinking. The task seemed hopeless.",
    "लंका से सीता का समाचार लेकर हनुमान के लौटने के बाद, राम की सेना को समुद्र पार करना था। वानरों ने पुल बनाना शुरू किया। हर वानर शिलाएँ उठाकर समुद्र में फेंकता, पर वे डूबती रहीं। कार्य असंभव लग रहा था।"),
  p("Then Nala and Neela, two Vanara engineers blessed by Vishwakarma, devised a plan. They wrote 'Ram' on each stone before placing it in the water. To everyone's astonishment, the stones with Rama's name written on them floated! Even massive boulders became buoyant with the power of the divine name.",
    "फिर नल और नील, विश्वकर्मा से वरदान प्राप्त दो वानर शिल्पकारों ने योजना बनाई। उन्होंने प्रत्येक पत्थर पर 'राम' लिखकर जल में रखा। सबके आश्चर्य में, राम का नाम लिखे पत्थर तैरने लगे! विशाल शिलाएँ भी दिव्य नाम की शक्ति से तैर गईं।"),
  p("A small squirrel watched the monkeys carry huge boulders and felt helpless. She began rolling in the sand and shaking the grains off her body into the gaps between stones. Some monkeys laughed, but Rama noticed and gently stroked the squirrel's back with three fingers, leaving three lines of blessing forever on her fur.",
    "एक छोटी गिलहरी ने वानरों को विशाल शिलाएँ उठाते देखा और असहाय अनुभव किया। उसने रेत में लोटकर अपने शरीर से रेत के कण पत्थरों की दरारों में भरने शुरू किए। कुछ वानर हँसे, पर राम ने देखा और प्रेम से गिलहरी की पीठ पर तीन उँगलियों से सहलाया, उसके फर पर सदा के लिए तीन धारियाँ छोड़ दीं।"),
  p("This story teaches two profound lessons: the name of the divine has power to make even stones float, and no act of devotion is too small. The squirrel's tiny grains mattered as much as the monkeys' boulders. God values the love behind the offering, not its size.",
    "यह कथा दो गहन शिक्षाएँ देती है: भगवान के नाम में पत्थर तैराने की शक्ति है, और भक्ति का कोई कार्य छोटा नहीं। गिलहरी के छोटे कण भी वानरों की शिलाओं जितने महत्वपूर्ण थे। भगवान अर्पण के पीछे के प्रेम को देखते हैं, उसके आकार को नहीं।", True),
 ]
},
{
 "slug": "hanuman-meets-rama",
 "title": "When Hanuman First Met Rama",
 "title_hindi": "हनुमान और राम की प्रथम भेंट",
 "deity_slug": "Hanuman",
 "source": "Ramayana",
 "category": "mythology",
 "key_teaching": "The meeting of a true guru and a sincere seeker transforms both their destinies forever.",
 "reflection_prompt": "Has a single encounter ever changed the entire course of your life?",
 "estimated_minutes": 3,
 "is_featured": False,
 "is_active": True,
 "order_index": 25,
 "pages": [
  p("When Rama and Lakshmana wandered through the forests searching for Sita, they reached the Rishyamukha mountain where the exiled Vanara king Sugriva was hiding. Sugriva, fearing they were enemies, sent his minister Hanuman to investigate.",
    "जब राम और लक्ष्मण सीता की खोज में वनों में भटक रहे थे, वे ऋष्यमूक पर्वत पर पहुँचे जहाँ निर्वासित वानरराज सुग्रीव छिपे थे। सुग्रीव ने, शत्रु समझकर, अपने मंत्री हनुमान को जाँच के लिए भेजा।"),
  p("Hanuman disguised himself as a Brahmin scholar and approached the two princes. The moment he saw Rama's face, something ancient stirred in his soul. He forgot his disguise, his mission, everything. Tears flowed from his eyes as if meeting someone he had known across lifetimes.",
    "हनुमान ने ब्राह्मण विद्वान का वेश धारण कर दोनों राजकुमारों के पास पहुँचे। जिस क्षण उन्होंने राम का मुख देखा, उनकी आत्मा में कुछ सनातन जाग उठा। वे अपना वेश, अपना कार्य, सब भूल गए। उनकी आँखों से अश्रु बहने लगे जैसे जन्मों-जन्मों के किसी परिचित से मिल रहे हों।"),
  p("Rama too recognized the extraordinary being before him. When Hanuman revealed his true form and fell at Rama's feet, Rama lifted him up and embraced him. In that embrace, the greatest friendship in all of Hindu scripture was born — master and devotee, God and soul, inseparable forever.",
    "राम ने भी सामने के असाधारण प्राणी को पहचान लिया। जब हनुमान ने अपना असली रूप प्रकट कर राम के चरणों में गिरे, राम ने उन्हें उठाकर गले लगाया। उस आलिंगन में हिंदू शास्त्रों की सबसे महान मित्रता का जन्म हुआ — स्वामी और भक्त, ईश्वर और आत्मा, सदा के लिए अविभाज्य।"),
  p("Hanuman's meeting with Rama shows that divine connections are not accidental. The soul recognizes its source. When the devotee is ready, the divine appears — not as a stranger, but as the one you have always been seeking without knowing it.",
    "हनुमान की राम से भेंट दर्शाती है कि दिव्य संबंध आकस्मिक नहीं होते। आत्मा अपने स्रोत को पहचान लेती है। जब भक्त तैयार होता है, भगवान प्रकट होते हैं — अजनबी नहीं, बल्कि वही जिन्हें आप बिना जाने सदा खोज रहे थे।", True),
 ]
},
# ══════ MORE GANESHA ══════
{
 "slug": "ganesha-modak-story",
 "title": "Why Ganesha Loves Modaks",
 "title_hindi": "गणेश को मोदक क्यों प्रिय हैं",
 "deity_slug": "ganesha",
 "source": "Ganesh Purana",
 "category": "mythology",
 "key_teaching": "Sweetness in life comes from a blend of ingredients — no single thing makes us whole.",
 "reflection_prompt": "What combination of qualities makes your life feel complete and satisfying?",
 "estimated_minutes": 3,
 "is_featured": False,
 "is_active": True,
 "order_index": 26,
 "pages": [
  p("Once, Sage Atreya prepared a unique food to offer the gods — a sweet dumpling called the Modak, made by wrapping coconut, jaggery, and wisdom into a rice flour shell. When he offered it to the gods, each deity tasted it but none could eat more than one.",
    "एक बार ऋषि आत्रेय ने देवताओं को अर्पित करने के लिए एक अद्वितीय भोजन बनाया — मोदक नामक मिठाई, नारियल, गुड़ और ज्ञान को चावल के आटे में लपेटकर। जब उन्होंने देवताओं को अर्पित किया, हर देवता ने चखा पर एक से अधिक कोई नहीं खा सका।"),
  p("When Ganesha tasted the first Modak, his eyes lit up with pure bliss. He ate one, then another, then twenty-one. Each Modak tasted different to him — one tasted of his mother's love, another of cosmic knowledge, another of pure joy. He could not stop.",
    "जब गणेश ने पहला मोदक चखा, उनकी आँखें शुद्ध आनंद से चमक उठीं। उन्होंने एक खाया, फिर एक और, फिर इक्कीस। हर मोदक का स्वाद उन्हें अलग लगा — एक में माँ का प्रेम, दूसरे में ब्रह्मांडीय ज्ञान, तीसरे में शुद्ध आनंद। वे रुक नहीं पाए।"),
  p("The other gods asked, 'Why can only Ganesha taste such depth in a simple sweet?' Brahma smiled: 'Because Ganesha sees the universe in everything. A modak is not just flour and sugar to him — it is creation wrapped in sweetness.' Since that day, Modaks became Ganesha's favorite offering.",
    "अन्य देवताओं ने पूछा, 'एक साधारण मिठाई में इतनी गहराई केवल गणेश ही क्यों चख सकते हैं?' ब्रह्मा मुस्कुराए: 'क्योंकि गणेश हर चीज में ब्रह्मांड देखते हैं। मोदक उनके लिए आटा और शक्कर नहीं — मिठास में लिपटी सृष्टि है।' उस दिन से मोदक गणेश का प्रिय नैवेद्य बन गया।"),
  p("This is why 21 modaks are traditionally offered to Ganesha. The story teaches that the same world appears ordinary or extraordinary based on our perception. Ganesha sees divinity in the simplest things — and that is the true mark of wisdom.",
    "इसीलिए परंपरा में गणेश को 21 मोदक अर्पित किए जाते हैं। कथा सिखाती है कि एक ही संसार हमारी दृष्टि के अनुसार साधारण या असाधारण दिखाई देता है। गणेश सबसे सामान्य वस्तुओं में दिव्यता देखते हैं — और यही सच्ची बुद्धि की पहचान है।", True),
 ]
},
{
 "slug": "ganesha-devotee-stories",
 "title": "Ganesha and the Devoted Farmer",
 "title_hindi": "गणेश और समर्पित किसान",
 "deity_slug": "ganesha",
 "source": "Ganesh Purana",
 "category": "moral",
 "key_teaching": "Honest effort with devotion always bears fruit, even when the world says otherwise.",
 "reflection_prompt": "Do you trust that sincere effort will be rewarded, even when results are delayed?",
 "estimated_minutes": 3,
 "is_featured": False,
 "is_active": True,
 "order_index": 27,
 "pages": [
  p("In a small village lived a humble farmer named Madhav who worshipped Ganesha every morning before tending his fields. Despite his devotion, his crops failed year after year. Droughts, floods, and pests seemed to target only his land. His neighbors mocked him.",
    "एक छोटे गाँव में माधव नामक एक विनम्र किसान रहता था जो प्रतिदिन सुबह खेतों में जाने से पहले गणेश की पूजा करता था। उसकी भक्ति के बावजूद, उसकी फसलें वर्ष दर वर्ष नष्ट होती रहीं। सूखा, बाढ़ और कीड़े केवल उसकी भूमि को निशाना बनाते। पड़ोसी उसका मजाक उड़ाते।"),
  p("'Where is your Ganesha now?' they laughed. But Madhav continued his prayers with unwavering faith. One monsoon, when a devastating flood destroyed every field in the region, Madhav noticed something miraculous — a single mound in his field stood above the water, untouched.",
    "'अब कहाँ है तुम्हारा गणेश?' वे हँसते। पर माधव ने अटल विश्वास से अपनी प्रार्थना जारी रखी। एक बरसात, जब विनाशकारी बाढ़ ने क्षेत्र के हर खेत को नष्ट कर दिया, माधव ने कुछ चमत्कारी देखा — उसके खेत में एक टीला बाढ़ के जल से ऊपर, अछूता खड़ा था।"),
  p("When the waters receded, Madhav dug into the mound and found an ancient Ganesha idol made of pure gold, along with seeds of a grain that had never been seen before. Those seeds grew into the richest crop the village had ever known — enough to feed the entire region for years.",
    "जब जल उतरा, माधव ने टीले की खुदाई की और शुद्ध सोने की प्राचीन गणेश मूर्ति पाई, साथ ही ऐसे अनाज के बीज जो पहले कभी नहीं देखे गए थे। उन बीजों से गाँव की सबसे समृद्ध फसल उगी — इतनी कि पूरे क्षेत्र को वर्षों तक खिला सकती थी।"),
  p("Madhav shared everything with the same neighbors who had mocked him. Ganesha had been testing his devotion, preparing the soil of his character before granting the harvest of his destiny. True devotion is not transactional — it is trust that the divine plan is always greater than our own.",
    "माधव ने सब कुछ उन्हीं पड़ोसियों से बाँटा जिन्होंने उसका मजाक उड़ाया था। गणेश उसकी भक्ति की परीक्षा ले रहे थे, उसके भाग्य की फसल देने से पहले उसके चरित्र की मिट्टी तैयार कर रहे थे। सच्ची भक्ति लेन-देन नहीं — यह विश्वास है कि दिव्य योजना सदा हमारी अपनी से बड़ी होती है।", True),
 ]
},
]

inserted = 0
for story in STORIES:
    if story["slug"] in existing:
        print(f"SKIP: {story['slug']}")
        continue
    r = requests.post(f"{URL}/rest/v1/sacred_stories", headers=H_WRITE, json=story)
    if r.status_code in (200, 201):
        print(f"OK: {story['title']}")
        inserted += 1
    else:
        print(f"FAIL: {story['title']} -> {r.status_code} {r.text[:200]}")

print(f"\nInserted {inserted} new stories")

# Final summary
r = requests.get(f"{URL}/rest/v1/sacred_stories?select=slug,deity_slug&slug=not.like.test*&order=order_index.asc", headers=H_READ)
data = r.json()
counts = {}
for s in data:
    d = s["deity_slug"]
    counts[d] = counts.get(d, 0) + 1
print(f"Total real stories: {len(data)}")
for deity, count in counts.items():
    print(f"  {deity}: {count}")
