#!/usr/bin/env python3
"""Insert missing stories one at a time with detailed output."""
import requests
import json

URL = "https://qyikatemonzykqamtvod.supabase.co"
KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5aWthdGVtb256eWtxYW10dm9kIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk2NTQzMDIsImV4cCI6MjA4NTIzMDMwMn0.YlulvY1iIlK-pBNkFdmKMwnfn0avMfQO35KW-Z7plAA"
H_READ = {"apikey": KEY, "Authorization": f"Bearer {KEY}"}
H_WRITE = {"apikey": KEY, "Authorization": f"Bearer {KEY}", "Content-Type": "application/json", "Prefer": "return=minimal"}

def p(en, hi, final=False):
    d = {"text_english": en, "text_hindi": hi}
    if final:
        d["is_final"] = True
    return d

# Get existing slugs
r = requests.get(f"{URL}/rest/v1/sacred_stories?select=slug", headers=H_READ)
existing = {s["slug"] for s in r.json()}
print(f"Existing slugs: {existing}")

# Stories that might be missing
missing_stories = [
{
 "slug": "shiva-ardhanarishvara",
 "title": "Ardhanarishvara - The Divine Union",
 "title_hindi": "अर्धनारीश्वर - दिव्य मिलन",
 "deity_slug": "shiva",
 "source": "Shiva Purana",
 "category": "moral",
 "key_teaching": "The divine encompasses both masculine and feminine; wholeness comes from balance.",
 "reflection_prompt": "How do you balance different aspects of your own nature?",
 "estimated_minutes": 3,
 "is_featured": False,
 "is_active": True,
 "order_index": 3,
 "pages": [
  p("Once, the great sage Bhringi was so devoted to Lord Shiva that he refused to worship anyone else - not even Goddess Parvati. When he would circumambulate Shiva, he would transform into a bee to fly between them, honoring only Shiva.",
    "एक बार महान ऋषि भृंगी भगवान शिव के इतने परम भक्त थे कि उन्होंने किसी और की पूजा करने से इंकार कर दिया।"),
  p("Parvati, who is Shakti herself - the very energy that sustains the universe - was displeased. She reminded Bhringi that without Shakti, even Shiva is Shava (a lifeless body).",
    "पार्वती, जो स्वयं शक्ति हैं, अप्रसन्न हुईं। उन्होंने भृंगी को याद दिलाया कि शक्ति के बिना शिव भी शव हैं।"),
  p("To teach this eternal truth, Shiva merged Parvati into his own being, becoming Ardhanarishvara - half man, half woman. The right side remained Shiva; the left became Parvati.",
    "इस शाश्वत सत्य को सिखाने के लिए, शिव ने पार्वती को अपने अस्तित्व में मिला लिया और अर्धनारीश्वर बने।"),
  p("Bhringi understood and bowed to both. Ardhanarishvara teaches that consciousness and energy are inseparable. True devotion honors the whole.",
    "भृंगी ने समझा और दोनों को प्रणाम किया। अर्धनारीश्वर सिखाते हैं कि चेतना और शक्ति अविभाज्य हैं।", True),
 ]
},
{
 "slug": "shiva-nandi-devotion",
 "title": "Nandi - The Perfect Devotee",
 "title_hindi": "नंदी - परम भक्त की कथा",
 "deity_slug": "shiva",
 "source": "Shiva Purana",
 "category": "mythology",
 "key_teaching": "Pure, selfless devotion transforms the devotee into divinity itself.",
 "reflection_prompt": "What does true devotion mean to you in daily life?",
 "estimated_minutes": 3,
 "is_featured": False,
 "is_active": True,
 "order_index": 5,
 "pages": [
  p("Nandi was born as the son of Sage Shilada. The boy was extraordinary - radiant, wise, and filled with innate love for Lord Shiva. But he was told his life would be short.",
    "नंदी का जन्म ऋषि शिलाद के पुत्र के रूप में हुआ। बालक असाधारण था परंतु ऋषियों ने बताया कि उसका जीवन अल्प होगा।"),
  p("Rather than despair, young Nandi devoted every breath to worshipping Shiva. His meditation was so pure that forests grew still and animals rested at his feet.",
    "निराश होने के बजाय, बालक नंदी ने अपनी हर श्वास शिव की आराधना को समर्पित कर दी।"),
  p("Shiva, deeply moved, appeared before him. He blessed Nandi with immortality, gave him the form of a divine bull, and declared him chief of all Ganas.",
    "शिव ने प्रसन्न होकर नंदी को अमरत्व दिया, दिव्य वृषभ का रूप प्रदान किया, और गणों का प्रमुख घोषित किया।"),
  p("This is why in every Shiva temple, Nandi sits facing the sanctum - eternally devoted, eternally listening. When devotion is pure, death itself bows.",
    "इसीलिए प्रत्येक शिव मंदिर में नंदी गर्भगृह की ओर मुख करके विराजमान हैं। जब भक्ति शुद्ध होती है, मृत्यु भी नतमस्तक हो जाती है।", True),
 ]
},
{
 "slug": "krishna-sudama-friendship",
 "title": "Krishna and Sudama - Eternal Friendship",
 "title_hindi": "कृष्ण-सुदामा की मित्रता",
 "deity_slug": "Krishna",
 "source": "Bhagavata Purana",
 "category": "mythology",
 "key_teaching": "True friendship sees no difference between rich and poor; love is the only currency.",
 "reflection_prompt": "Do you value people for who they are, or for what they have?",
 "estimated_minutes": 4,
 "is_featured": True,
 "is_active": True,
 "order_index": 8,
 "pages": [
  p("Sudama was a poor Brahmin who had been Krishna's childhood friend. Years later, Krishna had become King of Dwaraka while Sudama lived in dire poverty.",
    "सुदामा एक निर्धन ब्राह्मण थे जो कृष्ण के बचपन के मित्र रहे थे। कृष्ण द्वारका के राजा बन चुके थे जबकि सुदामा गरीबी में थे।"),
  p("Ashamed but desperate, Sudama set out with nothing but a small bundle of flattened rice (poha). When he reached Dwaraka's golden gates, he trembled.",
    "लज्जित पर विवश, सुदामा केवल पोहा लेकर चल पड़े। द्वारका के स्वर्ण द्वारों पर पहुँचकर वे काँपने लगे।"),
  p("But Krishna ran barefoot to embrace him! He washed Sudama's dusty feet, seated him on his throne, and ate the humble poha with such love that each grain became priceless.",
    "पर कृष्ण ने नंगे पैर दौड़कर उन्हें गले लगाया! उनके पैर धोए, सिंहासन पर बैठाया, और पोहा इतने प्रेम से खाया कि प्रत्येक दाना अमूल्य हो गया।"),
  p("Sudama left without asking for anything. But when he reached home, his hut had transformed into a palace. Krishna had given everything without being asked. Divine love needs no words.",
    "सुदामा बिना कुछ माँगे लौटे। पर घर पहुँचने पर झोपड़ी महल में बदल चुकी थी। कृष्ण ने बिना माँगे सब दे दिया। दिव्य प्रेम को शब्दों की आवश्यकता नहीं।", True),
 ]
},
{
 "slug": "krishna-draupadi-vastraharan",
 "title": "Krishna Protects Draupadi's Honor",
 "title_hindi": "द्रौपदी की रक्षा",
 "deity_slug": "Krishna",
 "source": "Mahabharata",
 "category": "mythology",
 "key_teaching": "When you surrender completely to the divine with faith, help arrives in infinite measure.",
 "reflection_prompt": "In your darkest moment, can you let go and trust a higher power?",
 "estimated_minutes": 4,
 "is_featured": True,
 "is_active": True,
 "order_index": 9,
 "pages": [
  p("In the fateful game of dice, Yudhishthira lost everything. Duryodhana ordered Dushasana to drag Draupadi into court and disrobe her before the assembly.",
    "चौसर के खेल में, युधिष्ठिर ने सब कुछ खो दिया। दुर्योधन ने दुःशासन को द्रौपदी का वस्त्र हरण करने का आदेश दिया।"),
  p("Draupadi looked at her five husbands, at Bhishma, Drona - none moved. In absolute despair, she raised both hands and cried out to Krishna with complete surrender.",
    "द्रौपदी ने पतियों, भीष्म, द्रोण की ओर देखा - कोई नहीं हिला। परम निराशा में उन्होंने पूर्ण समर्पण से कृष्ण को पुकारा।"),
  p("'O Krishna! You are my only refuge!' As Dushasana pulled, the cloth kept extending endlessly. He pulled until exhausted, but Draupadi remained clothed. Krishna answered with infinite grace.",
    "'हे कृष्ण! आप ही मेरा शरण हैं!' दुःशासन खींचता रहा, वस्त्र अनंत बढ़ता गया। कृष्ण ने अनंत कृपा से उत्तर दिया।"),
  p("Draupadi's story teaches: surrender to the divine is not weakness but the greatest strength. Krishna is bound by devotion, and whoever calls with genuine faith will never be abandoned.",
    "द्रौपदी की कथा सिखाती है: ईश्वर के प्रति समर्पण दुर्बलता नहीं, सबसे बड़ी शक्ति है। कृष्ण भक्ति से बँधे हैं।", True),
 ]
},
{
 "slug": "krishna-arjuna-vishwaroop",
 "title": "The Cosmic Vision on the Battlefield",
 "title_hindi": "विश्वरूप दर्शन",
 "deity_slug": "Krishna",
 "source": "Bhagavad Gita",
 "category": "moral",
 "key_teaching": "The divine encompasses all of creation - birth, death, time, and beyond.",
 "reflection_prompt": "Can you see the sacred in everyday moments, not just in temples?",
 "estimated_minutes": 4,
 "is_featured": True,
 "is_active": True,
 "order_index": 10,
 "pages": [
  p("On Kurukshetra, Arjuna stood paralyzed. His family stood on opposite sides. Dropping his bow Gandiva, he told Krishna, 'I cannot fight. I would rather die.'",
    "कुरुक्षेत्र में अर्जुन परिजनों को सामने देख पंगु थे। गांडीव गिराकर बोले, 'मैं युद्ध नहीं कर सकता।'"),
  p("Krishna revealed the deepest truths of existence. But Arjuna asked, 'Show me your true form.' Krishna granted him divine vision.",
    "कृष्ण ने अस्तित्व के गहन सत्य प्रकट किए। अर्जुन ने कहा, 'अपना सच्चा रूप दिखाओ।' कृष्ण ने दिव्य दृष्टि दी।"),
  p("Krishna's body expanded to fill the universe. Countless faces, infinite arms, blazing suns. All creation - past, present, future - existed within Krishna simultaneously. Time itself burned as consuming fire.",
    "कृष्ण का शरीर ब्रह्मांड में फैल गया। अगणित मुख, अनंत भुजाएँ। भूत, वर्तमान, भविष्य सब कृष्ण में विद्यमान। काल स्वयं अग्नि बनकर दिखा।"),
  p("Trembling, Arjuna folded his hands: 'You are everything.' Krishna smiled: 'Now do your duty, and surrender the results to me.' The divine is not distant - it IS everything.",
    "काँपते अर्जुन ने हाथ जोड़े: 'आप सब कुछ हैं।' कृष्ण मुस्कुराए: 'कर्तव्य करो, फल मुझे समर्पित करो।' ईश्वर दूर नहीं, वह सब कुछ है।", True),
 ]
},
]

# Insert missing stories
inserted = 0
for story in missing_stories:
    if story["slug"] in existing:
        print(f"SKIP: {story['slug']} already exists")
        continue
    r = requests.post(f"{URL}/rest/v1/sacred_stories", headers=H_WRITE, json=story)
    if r.status_code in (200, 201):
        print(f"OK: {story['title']}")
        inserted += 1
    else:
        print(f"FAIL: {story['title']} -> {r.status_code} {r.text[:150]}")

print(f"\nInserted {inserted} stories")

# Final count
r = requests.get(f"{URL}/rest/v1/sacred_stories?select=slug&order=order_index.asc", headers=H_READ)
print(f"Total stories now: {len(r.json())}")
