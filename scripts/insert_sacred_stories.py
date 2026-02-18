#!/usr/bin/env python3
"""Insert 20 sacred stories into Supabase sacred_stories table."""
import json, sys, requests

URL = "https://qyikatemonzykqamtvod.supabase.co"
KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5aWthdGVtb256eWtxYW10dm9kIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk2NTQzMDIsImV4cCI6MjA4NTIzMDMwMn0.YlulvY1iIlK-pBNkFdmKMwnfn0avMfQO35KW-Z7plAA"
H = {"apikey": KEY, "Authorization": f"Bearer {KEY}", "Content-Type": "application/json", "Prefer": "return=minimal"}

def p(en, hi, final=False):
    """Create a page dict."""
    d = {"text_english": en, "text_hindi": hi}
    if final:
        d["is_final"] = True
    return d

STORIES = [
# ══════════ SHIVA (5 stories) ══════════
{
 "slug": "shiva-halahala-poison",
 "title": "Shiva Drinks the Cosmic Poison",
 "title_hindi": "शिव का हलाहल विष पान",
 "deity_slug": "shiva",
 "source": "Bhagavata Purana",
 "category": "mythology",
 "key_teaching": "True strength lies in self-sacrifice for the welfare of all beings.",
 "reflection_prompt": "When have you sacrificed your comfort for someone else's wellbeing?",
 "estimated_minutes": 4,
 "is_featured": True,
 "order_index": 1,
 "pages": [
  p("When the Devas and Asuras churned the great Ocean of Milk to obtain the nectar of immortality, a terrible poison called Halahala emerged first. The poison was so potent that its fumes alone began to scorch the three worlds. Trees withered, rivers boiled, and all creatures cried out in agony.",
    "जब देवताओं और असुरों ने अमृत प्राप्ति के लिए क्षीरसागर का मंथन किया, तो सबसे पहले हलाहल नामक भयंकर विष निकला। यह विष इतना प्रबल था कि इसके धुएं मात्र से तीनों लोक जलने लगे। वृक्ष सूख गए, नदियाँ उबलने लगीं, और सभी प्राणी पीड़ा से चिल्लाने लगे।"),
  p("Neither Devas nor Asuras dared to touch the poison. In their desperation, they turned to Lord Shiva, the great ascetic who dwells on Mount Kailash. Shiva, moved by compassion for all creation, agreed without hesitation to consume the deadly Halahala.",
    "न देवता और न ही असुर इस विष को छूने का साहस कर पा रहे थे। अपनी विवशता में, उन्होंने कैलाश पर्वत पर निवास करने वाले महान तपस्वी भगवान शिव से प्रार्थना की। शिव ने समस्त सृष्टि के प्रति करुणा से प्रेरित होकर, बिना किसी हिचकिचाहट के हलाहल विष को पीने का निश्चय किया।"),
  p("As Shiva raised the poison to his lips, Goddess Parvati rushed forward and pressed her hand against his throat, stopping the poison from descending further. The Halahala remained in Shiva's throat, turning it a deep blue. From that day, Shiva became known as Neelkanth — the Blue-Throated One.",
    "जैसे ही शिव ने विष को अपने होठों तक उठाया, देवी पार्वती दौड़कर आईं और उनके गले पर अपना हाथ रख दिया, जिससे विष नीचे नहीं उतर सका। हलाहल शिव के कंठ में ही रह गया, जिससे उनका गला गहरा नीला हो गया। उस दिन से शिव 'नीलकंठ' के नाम से जाने गए।"),
  p("The universe was saved by Shiva's supreme act of self-sacrifice. He bore the unbearable pain so that all beings could live. This story teaches us that true divinity lies not in power, but in the willingness to endure suffering for the sake of others. Shiva's blue throat stands as an eternal reminder of love's triumph over destruction.",
    "शिव के परम त्याग से सम्पूर्ण सृष्टि बच गई। उन्होंने असहनीय पीड़ा सही ताकि सभी प्राणी जीवित रह सकें। यह कथा हमें सिखाती है कि सच्ची दिव्यता शक्ति में नहीं, बल्कि दूसरों के लिए कष्ट सहने की इच्छा में है। शिव का नीला कंठ प्रेम की विनाश पर विजय का शाश्वत प्रतीक है।", True),
 ]
},
{
 "slug": "shiva-ganga-descent",
 "title": "The Descent of River Ganga",
 "title_hindi": "गंगा अवतरण की कथा",
 "deity_slug": "shiva",
 "source": "Ramayana",
 "category": "mythology",
 "key_teaching": "Patience and devotion can move even the mightiest forces of nature.",
 "reflection_prompt": "What long-term goal requires your unwavering patience and dedication?",
 "estimated_minutes": 4,
 "order_index": 2,
 "pages": [
  p("King Sagara's sixty thousand sons were reduced to ashes by the wrath of Sage Kapila. Their souls could only find liberation if the sacred River Ganga, which flowed in the heavens, descended to Earth and washed over their remains. For generations, Sagara's descendants tried and failed.",
    "राजा सगर के साठ हजार पुत्र ऋषि कपिल के क्रोध से भस्म हो गए। उनकी आत्माओं को मुक्ति तभी मिल सकती थी जब स्वर्ग में बहने वाली पवित्र गंगा नदी पृथ्वी पर अवतरित होकर उनकी अस्थियों को स्पर्श करे। पीढ़ियों तक सगर के वंशज प्रयास करते रहे पर असफल रहे।"),
  p("Finally, Prince Bhagiratha undertook the severest of penances. He stood on one foot for a thousand years, meditating upon Lord Brahma. Pleased by his devotion, Brahma agreed to release Ganga, but warned that her force would shatter the Earth. Only Shiva could bear her mighty descent.",
    "अंततः राजकुमार भगीरथ ने कठोरतम तपस्या की। उन्होंने एक पैर पर खड़े होकर हजार वर्षों तक ब्रह्मा जी की आराधना की। उनकी भक्ति से प्रसन्न होकर ब्रह्मा ने गंगा को मुक्त करने की सहमति दी, परंतु चेतावनी दी कि उसका वेग पृथ्वी को तोड़ देगा। केवल शिव ही उसके प्रचंड अवतरण को सह सकते थे।"),
  p("Bhagiratha then prayed to Lord Shiva, who graciously agreed. When Ganga descended with full force from heaven, Shiva calmly caught her in his matted locks. The mighty river, humbled by Shiva's power, flowed gently through his hair and descended peacefully to Earth, following Bhagiratha's chariot to the sea.",
    "भगीरथ ने फिर भगवान शिव की प्रार्थना की, जिन्होंने कृपापूर्वक स्वीकार किया। जब गंगा पूरे वेग से स्वर्ग से उतरीं, शिव ने शांतिपूर्वक उन्हें अपनी जटाओं में धारण कर लिया। शिव की शक्ति के आगे विनम्र होकर, गंगा उनके केशों से होती हुई शांतिपूर्वक पृथ्वी पर अवतरित हुईं और भगीरथ के रथ का अनुसरण करती हुई सागर तक पहुँचीं।"),
  p("As Ganga's waters touched the ashes of Sagara's sons, their souls ascended to heaven. Bhagiratha's unwavering devotion across lifetimes had finally borne fruit. This story teaches us that with patience, perseverance, and surrender to the divine, even the impossible becomes possible.",
    "जैसे ही गंगा का जल सगर के पुत्रों की भस्म को छुआ, उनकी आत्माएँ स्वर्ग को गईं। जन्मों-जन्मों की भगीरथ की अटल भक्ति अंततः फलीभूत हुई। यह कथा सिखाती है कि धैर्य, दृढ़ता और ईश्वर के प्रति समर्पण से असंभव भी संभव हो जाता है।", True),
 ]
},
{
 "slug": "shiva-ardhanarishvara",
 "title": "Ardhanarishvara — The Divine Union",
 "title_hindi": "अर्धनारीश्वर — दिव्य मिलन",
 "deity_slug": "shiva",
 "source": "Shiva Purana",
 "category": "moral",
 "key_teaching": "The divine encompasses both masculine and feminine; wholeness comes from balance.",
 "reflection_prompt": "How do you balance different aspects of your own nature?",
 "estimated_minutes": 3,
 "order_index": 3,
 "pages": [
  p("Once, the great sage Bhringi was so devoted to Lord Shiva that he refused to worship anyone else — not even Goddess Parvati. When he would circumambulate Shiva, he would transform into a bee to fly between them, honoring only Shiva.",
    "एक बार महान ऋषि भृंगी भगवान शिव के इतने परम भक्त थे कि उन्होंने किसी और की पूजा करने से इंकार कर दिया — यहाँ तक कि देवी पार्वती की भी नहीं। जब वे शिव की परिक्रमा करते, तो वे भँवरे का रूप धारण कर दोनों के बीच से उड़ जाते, केवल शिव को ही प्रणाम करते।"),
  p("Parvati, who is Shakti herself — the very energy that sustains the universe — was displeased. She reminded Bhringi that without Shakti, even Shiva is 'Shava' (a lifeless body). Without feminine energy, creation itself would cease to exist.",
    "पार्वती, जो स्वयं शक्ति हैं — वह ऊर्जा जो ब्रह्मांड को धारण करती है — अप्रसन्न हुईं। उन्होंने भृंगी को याद दिलाया कि शक्ति के बिना शिव भी 'शव' हैं। स्त्री शक्ति के बिना सृष्टि का अस्तित्व ही समाप्त हो जाएगा।"),
  p("To teach this eternal truth, Shiva merged Parvati into his own being, becoming Ardhanarishvara — half man, half woman. The right side remained Shiva with his matted locks and trident; the left became Parvati with her graceful form and ornaments. This divine form revealed that masculine and feminine are not separate but two aspects of one reality.",
    "इस शाश्वत सत्य को सिखाने के लिए, शिव ने पार्वती को अपने अस्तित्व में मिला लिया और अर्धनारीश्वर बने — आधे पुरुष, आधी स्त्री। दाहिना भाग शिव का रहा उनकी जटाओं और त्रिशूल के साथ; बायाँ भाग पार्वती का बना उनके सुंदर रूप और आभूषणों के साथ। इस दिव्य रूप ने प्रकट किया कि पुरुष और स्त्री अलग नहीं बल्कि एक ही सत्य के दो पहलू हैं।"),
  p("Bhringi understood and bowed to both. Ardhanarishvara teaches that the universe exists in balance — consciousness (Shiva) and energy (Shakti) are inseparable. Neither is superior. True devotion honors the whole, not just the part.",
    "भृंगी ने समझा और दोनों को प्रणाम किया। अर्धनारीश्वर सिखाते हैं कि ब्रह्मांड संतुलन में है — चेतना (शिव) और ऊर्जा (शक्ति) अविभाज्य हैं। कोई भी श्रेष्ठ नहीं। सच्ची भक्ति समग्र को सम्मानित करती है, केवल अंश को नहीं।", True),
 ]
},
{
 "slug": "shiva-destroys-tripura",
 "title": "Shiva Destroys the Three Cities",
 "title_hindi": "शिव द्वारा त्रिपुर संहार",
 "deity_slug": "shiva",
 "source": "Matsya Purana",
 "category": "mythology",
 "key_teaching": "Pride and arrogance, even with great power, lead to downfall.",
 "reflection_prompt": "Has success ever made you overconfident? What brought you back to humility?",
 "estimated_minutes": 4,
 "order_index": 4,
 "pages": [
  p("Three Asura brothers — Tarakaksha, Vidyunmali, and Kamalaksha — performed intense penance and received a boon from Brahma. They were granted three magnificent flying cities made of gold, silver, and iron. These cities, called Tripura, could only be destroyed when all three aligned in a single line, and only by a single arrow.",
    "तीन असुर भाई — तारकाक्ष, विद्युन्माली और कमलाक्ष — ने कठोर तपस्या की और ब्रह्मा से वरदान प्राप्त किया। उन्हें सोने, चाँदी और लोहे से बनी तीन भव्य उड़ने वाली नगरियाँ प्रदान की गईं। त्रिपुर कहलाने वाली ये नगरियाँ तभी नष्ट हो सकती थीं जब तीनों एक सीध में आएँ, और केवल एक ही बाण से।"),
  p("Drunk with power, the Asuras terrorized the three worlds. They conquered heaven and earth, humiliated the Devas, and declared themselves supreme. The alignment of their cities happened only once in thousands of years, making them feel invincible.",
    "शक्ति के मद में चूर असुरों ने तीनों लोकों पर अत्याचार किया। उन्होंने स्वर्ग और पृथ्वी पर विजय प्राप्त की, देवताओं को अपमानित किया, और स्वयं को सर्वोच्च घोषित किया। उनकी नगरियों का एक सीध में आना हजारों वर्षों में एक बार होता था, जिससे वे अजेय अनुभव कर रहे थे।"),
  p("The Devas approached Lord Shiva. When the rare celestial alignment occurred, Shiva mounted a chariot made from the Earth itself. With Brahma as his charioteer and Vishnu as his arrow, Shiva drew his great bow, the Pinaka. With a single smile, he released one blazing arrow that pierced all three cities, reducing them to ash.",
    "देवताओं ने भगवान शिव से सहायता माँगी। जब वह दुर्लभ खगोलीय संरेखण घटित हुआ, शिव ने पृथ्वी से बने रथ पर आरूढ़ हुए। ब्रह्मा उनके सारथी बने और विष्णु उनके बाण। शिव ने अपना महान धनुष पिनाक उठाया। एक मुस्कान के साथ, उन्होंने एक प्रज्वलित बाण छोड़ा जिसने तीनों नगरियों को भेदकर भस्म कर दिया।"),
  p("The fall of Tripura demonstrated that no amount of power can protect those consumed by ego. Shiva, as Tripurantaka, showed that divine justice is patient but inevitable. The story reminds us that humility preserves what pride destroys.",
    "त्रिपुर के पतन ने प्रमाणित किया कि अहंकार से ग्रस्त लोगों की कोई भी शक्ति रक्षा नहीं कर सकती। शिव ने त्रिपुरांतक के रूप में दिखाया कि दिव्य न्याय धैर्यवान किंतु अवश्यंभावी है। यह कथा हमें याद दिलाती है कि विनम्रता वह सुरक्षित रखती है जो अहंकार नष्ट करता है।", True),
 ]
},
{
 "slug": "shiva-nandi-devotion",
 "title": "Nandi — The Perfect Devotee",
 "title_hindi": "नंदी — परम भक्त की कथा",
 "deity_slug": "shiva",
 "source": "Shiva Purana",
 "category": "mythology",
 "key_teaching": "Pure, selfless devotion transforms the devotee into divinity itself.",
 "reflection_prompt": "What does true devotion mean to you in daily life?",
 "estimated_minutes": 3,
 "order_index": 5,
 "pages": [
  p("Nandi was born as the son of Sage Shilada, who had prayed for a child blessed by Shiva himself. The boy was extraordinary — radiant, wise, and filled with an innate love for Lord Shiva from the moment of his birth. But he was also told by the sages that his life would be short.",
    "नंदी का जन्म ऋषि शिलाद के पुत्र के रूप में हुआ, जिन्होंने स्वयं शिव से आशीर्वाद प्राप्त संतान के लिए प्रार्थना की थी। बालक असाधारण था — तेजस्वी, बुद्धिमान, और जन्म से ही शिव के प्रति स्वाभाविक प्रेम से परिपूर्ण। परंतु ऋषियों ने बताया कि उसका जीवन अल्प होगा।"),
  p("Rather than despair, young Nandi devoted every breath to worshipping Shiva. His meditation was so pure and intense that the very forests around him grew still. Animals rested at his feet. Even time seemed to pause in his presence.",
    "निराश होने के बजाय, बालक नंदी ने अपनी हर श्वास शिव की आराधना को समर्पित कर दी। उनका ध्यान इतना शुद्ध और गहन था कि उनके आसपास के वन भी स्थिर हो जाते। पशु उनके चरणों में विश्राम करते। यहाँ तक कि समय भी उनकी उपस्थिति में रुक जाता प्रतीत होता था।"),
  p("Shiva, deeply moved by Nandi's devotion, appeared before him. He blessed Nandi with immortality, gave him the form of a magnificent divine bull, and declared him the chief of all his attendants (Ganas). Nandi would forever sit at the entrance of Shiva's abode, the first to hear Shiva's wisdom and the eternal guardian of his temple.",
    "नंदी की भक्ति से अत्यंत प्रसन्न होकर शिव उनके समक्ष प्रकट हुए। उन्होंने नंदी को अमरत्व का वरदान दिया, उन्हें एक भव्य दिव्य वृषभ का रूप प्रदान किया, और उन्हें अपने समस्त गणों का प्रमुख घोषित किया। नंदी सदा शिव के धाम के प्रवेश द्वार पर विराजमान रहेंगे, शिव के ज्ञान को सर्वप्रथम सुनने वाले और उनके मंदिर के शाश्वत रक्षक।"),
  p("This is why in every Shiva temple, Nandi sits facing the sanctum — eternally devoted, eternally listening. Nandi teaches that when devotion is pure, death itself bows. Love freely given to the divine returns as immortality.",
    "इसीलिए प्रत्येक शिव मंदिर में नंदी गर्भगृह की ओर मुख करके विराजमान हैं — शाश्वत भक्त, शाश्वत श्रोता। नंदी सिखाते हैं कि जब भक्ति शुद्ध होती है, तो मृत्यु भी नतमस्तक हो जाती है। भगवान को निःस्वार्थ दिया गया प्रेम अमरत्व बनकर लौटता है।", True),
 ]
},
# ══════════ KRISHNA (5 stories) ══════════
{
 "slug": "krishna-butter-thief",
 "title": "The Divine Butter Thief",
 "title_hindi": "माखन चोर की लीला",
 "deity_slug": "Krishna",
 "source": "Bhagavata Purana",
 "category": "leela",
 "key_teaching": "God's playfulness reminds us that spirituality can be joyful, not just solemn.",
 "reflection_prompt": "Where can you bring more joy and playfulness into your spiritual practice?",
 "estimated_minutes": 3,
 "order_index": 6,
 "pages": [
  p("In the village of Vrindavan, young Krishna was adored by all the Gopis (cowherd women), but he was also their greatest mischief. Every morning, the Gopis would churn fresh butter and store it in high-hanging pots. Yet somehow, the butter would always vanish.",
    "वृंदावन गाँव में, बाल कृष्ण सभी गोपियों के लाडले थे, पर वे उनकी सबसे बड़ी शरारत भी थे। प्रतिदिन सुबह गोपियाँ ताजा मक्खन मथतीं और ऊँचे लटके मटकों में रखतीं। फिर भी, मक्खन सदा गायब हो जाता।"),
  p("Krishna would gather his friends, build human pyramids to reach the pots, and feast on the butter with gleeful abandon. When caught, he would look at Mother Yashoda with his wide innocent eyes and say, 'I didn't steal it, Maiya! The monkeys did!' His face smeared with butter would tell a different tale.",
    "कृष्ण अपने मित्रों को इकट्ठा करते, मटकों तक पहुँचने के लिए मानव पिरामिड बनाते, और आनंदपूर्वक मक्खन का भोग लगाते। पकड़े जाने पर, वे माता यशोदा की ओर अपनी बड़ी-बड़ी मासूम आँखों से देखते और कहते, 'मैंने नहीं चुराया, मैया! बंदरों ने किया!' मक्खन से सने उनके मुख की कहानी कुछ और कहती।"),
  p("One day, the Gopis complained to Yashoda. She tried to tie Krishna to a mortar as punishment. But no matter how much rope she brought, it was always two fingers too short! Finally, Krishna, seeing his mother exhausted and sweating, let himself be bound — not by rope, but by her love.",
    "एक दिन गोपियों ने यशोदा से शिकायत की। उन्होंने कृष्ण को दंड स्वरूप ओखली से बाँधने का प्रयास किया। पर कितनी भी रस्सी लाएँ, वह सदा दो अंगुल छोटी पड़ती! अंततः कृष्ण ने, अपनी माता को थका और पसीने से भीगा देखकर, स्वयं को बँधने दिया — रस्सी से नहीं, बल्कि उनके प्रेम से।"),
  p("The Butter Thief leelas reveal the deepest truth: the Supreme Lord who cannot be bound by yoga or knowledge, willingly becomes captive to pure love. Krishna steals butter — but truly, he steals the hearts of his devotees.",
    "माखन चोर की लीलाएँ सबसे गहन सत्य प्रकट करती हैं: वह परम भगवान जो योग या ज्ञान से बाँधे नहीं जा सकते, स्वेच्छा से शुद्ध प्रेम के बंधन में बँध जाते हैं। कृष्ण मक्खन चुराते हैं — पर वास्तव में वे अपने भक्तों के हृदय चुराते हैं।", True),
 ]
},
{
 "slug": "krishna-kalia-naag",
 "title": "Krishna Subdues the Serpent Kaliya",
 "title_hindi": "कालिया नाग दमन",
 "deity_slug": "Krishna",
 "source": "Bhagavata Purana",
 "category": "leela",
 "key_teaching": "Evil that poisons a community must be confronted with courage, not avoided.",
 "reflection_prompt": "What toxic influence in your life needs to be bravely confronted?",
 "estimated_minutes": 4,
 "order_index": 7,
 "pages": [
  p("A terrifying multi-headed serpent named Kaliya made his home in the Yamuna River near Vrindavan. His venom was so deadly that the water turned black and boiled. The fish died, the birds that flew over the river fell from the sky, and the trees along the banks withered to ash.",
    "कालिया नामक एक भयंकर बहुमुखी सर्प ने वृंदावन के निकट यमुना नदी में अपना निवास बना लिया। उसका विष इतना घातक था कि जल काला और उबलने लगा। मछलियाँ मर गईं, नदी के ऊपर उड़ने वाले पक्षी आकाश से गिर पड़ते, और किनारों के वृक्ष सूखकर राख हो गए।"),
  p("The people of Vrindavan lived in constant fear. One day, young Krishna's ball rolled into the poisoned waters. Without hesitation, Krishna leaped into the river. His friends screamed in terror and ran to alert the village. The entire community rushed to the riverbank, weeping.",
    "वृंदावन के लोग निरंतर भय में जीते थे। एक दिन बाल कृष्ण की गेंद विषैले जल में गिर गई। बिना किसी हिचकिचाहट के, कृष्ण नदी में कूद पड़े। उनके मित्र भय से चिल्लाते हुए गाँव को सचेत करने दौड़े। पूरा गाँव रोता हुआ नदी के किनारे दौड़ आया।"),
  p("Deep underwater, Kaliya attacked Krishna with all his might, wrapping his coils around the divine child. But Krishna expanded his body, breaking free. Then, to everyone's astonishment, Krishna climbed atop Kaliya's many hoods and began to dance! His feet struck each hood in rhythm, and the serpent's poison drained away with every step.",
    "जल की गहराई में, कालिया ने अपनी पूरी शक्ति से कृष्ण पर आक्रमण किया, अपने कुंडलों में दिव्य बालक को लपेट लिया। पर कृष्ण ने अपना शरीर विस्तारित किया और मुक्त हो गए। फिर, सबके आश्चर्य में, कृष्ण कालिया के अनेक फनों पर चढ़ गए और नृत्य करने लगे! उनके पैर प्रत्येक फन पर ताल में प्रहार करते, और हर कदम के साथ सर्प का विष निकलता गया।"),
  p("Defeated and humbled, Kaliya begged for mercy. Krishna, ever compassionate, did not kill him but commanded him to leave the Yamuna and return to the ocean. The river became pure again, and Vrindavan rejoiced. Krishna showed that true strength lies not in destruction but in restoring harmony.",
    "पराजित और विनम्र कालिया ने क्षमा माँगी। कृष्ण ने, सदा करुणामय, उसे मारा नहीं बल्कि यमुना छोड़कर सागर में लौटने का आदेश दिया। नदी पुनः शुद्ध हो गई और वृंदावन में उत्सव मना। कृष्ण ने दिखाया कि सच्ची शक्ति विनाश में नहीं, बल्कि सामंजस्य की पुनर्स्थापना में है।", True),
 ]
},
{
 "slug": "krishna-sudama-friendship",
 "title": "Krishna and Sudama — Eternal Friendship",
 "title_hindi": "कृष्ण-सुदामा की मित्रता",
 "deity_slug": "Krishna",
 "source": "Bhagavata Purana",
 "category": "mythology",
 "key_teaching": "True friendship sees no difference between rich and poor; love is the only currency.",
 "reflection_prompt": "Do you value people for who they are, or for what they have?",
 "estimated_minutes": 4,
 "order_index": 8,
 "pages": [
  p("Sudama was a poor Brahmin who had been Krishna's childhood friend at Guru Sandipani's ashrama. Years later, while Krishna had become the King of Dwaraka, Sudama lived in dire poverty. His children went hungry, and his wife urged him to seek help from his old friend.",
    "सुदामा एक निर्धन ब्राह्मण थे जो गुरु सांदीपनी के आश्रम में कृष्ण के बचपन के मित्र रहे थे। वर्षों बाद, जबकि कृष्ण द्वारका के राजा बन चुके थे, सुदामा अत्यंत गरीबी में जीवन व्यतीत कर रहे थे। उनके बच्चे भूखे रहते, और उनकी पत्नी ने उन्हें पुराने मित्र से सहायता माँगने का आग्रह किया।"),
  p("Ashamed but desperate, Sudama set out with nothing but a small bundle of flattened rice (poha) — the only gift he could afford. When he reached the golden gates of Dwaraka, he trembled. How could a king remember a poor nobody like him?",
    "लज्जित पर विवश, सुदामा केवल एक छोटी पोटली चिवड़ा (पोहा) लेकर चल पड़े — केवल यही उपहार वे दे सकते थे। जब वे द्वारका के स्वर्ण द्वारों पर पहुँचे, वे काँपने लगे। एक राजा उनके जैसे निर्धन व्यक्ति को कैसे याद करेगा?"),
  p("But Krishna, seeing Sudama from afar, ran barefoot to embrace him! He washed Sudama's dusty feet with his own hands, seated him on his own throne, and wept with joy. When Krishna saw the humble poha, he ate it with such love that each grain became worth more than all the gold in Dwaraka.",
    "पर कृष्ण ने सुदामा को दूर से देखते ही, नंगे पैर दौड़कर उन्हें गले लगाया! उन्होंने अपने हाथों से सुदामा के धूल भरे पैर धोए, उन्हें अपने सिंहासन पर बैठाया, और आनंद से रो पड़े। जब कृष्ण ने साधारण पोहा देखा, उन्होंने इतने प्रेम से खाया कि प्रत्येक दाना द्वारका के सारे सोने से अधिक मूल्यवान हो गया।"),
  p("Sudama left Dwaraka without asking for anything — too overwhelmed by love. But when he reached home, his hut had transformed into a palace, his family dressed in fine clothes, his children well-fed. Krishna had given everything without being asked. This story teaches that divine love needs no words — it simply knows and gives.",
    "सुदामा बिना कुछ माँगे द्वारका से लौटे — प्रेम से अभिभूत। पर जब वे घर पहुँचे, उनकी झोपड़ी महल में बदल चुकी थी, परिवार सुंदर वस्त्रों में, बच्चे तृप्त। कृष्ण ने बिना माँगे ही सब कुछ दे दिया। यह कथा सिखाती है कि दिव्य प्रेम को शब्दों की आवश्यकता नहीं — वह बस जानता है और देता है।", True),
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
 "order_index": 9,
 "pages": [
  p("In the fateful game of dice, Yudhishthira lost everything — his kingdom, his brothers, himself, and finally, Draupadi. The wicked Duryodhana ordered Dushasana to drag the queen of the Pandavas into the court and disrobe her before the entire assembly.",
    "उस भाग्यपूर्ण चौसर के खेल में, युधिष्ठिर ने सब कुछ खो दिया — अपना राज्य, भाई, स्वयं को, और अंततः द्रौपदी को। दुष्ट दुर्योधन ने दुःशासन को आदेश दिया कि पांडवों की रानी को भरी सभा में खींचकर लाए और उनका वस्त्र हरण करे।"),
  p("Draupadi looked desperately at her five husbands, at Bhishma, Drona, and all the elders. None moved. Shame, helplessness, and political bonds held them all frozen. In that moment of absolute despair, Draupadi raised both hands and cried out to Krishna with complete surrender.",
    "द्रौपदी ने निराशा से अपने पाँच पतियों, भीष्म, द्रोण और सभी बड़ों की ओर देखा। कोई नहीं हिला। लज्जा, विवशता और राजनीतिक बंधनों ने सबको जड़ कर दिया। उस परम निराशा के क्षण में, द्रौपदी ने दोनों हाथ उठाकर पूर्ण समर्पण से कृष्ण को पुकारा।"),
  p("'O Krishna! O Govinda! You are my only refuge!' she cried, releasing her grip on her own sari. In that act of total surrender, the miracle happened. As Dushasana pulled, the cloth kept extending endlessly. Yard after yard appeared from nowhere. He pulled until his arms grew tired, but Draupadi remained clothed. Krishna had answered her call with infinite grace.",
    "'हे कृष्ण! हे गोविंद! आप ही मेरा एकमात्र शरण हैं!' उन्होंने पुकारा, और अपनी साड़ी की पकड़ छोड़ दी। उस पूर्ण समर्पण में चमत्कार हुआ। दुःशासन खींचता रहा, वस्त्र अनंत रूप से बढ़ता गया। गज पर गज प्रकट होता रहा। वह तब तक खींचता रहा जब तक उसकी भुजाएँ थक नहीं गईं, पर द्रौपदी वस्त्रहीन नहीं हुईं। कृष्ण ने उनकी पुकार का अनंत कृपा से उत्तर दिया।"),
  p("Draupadi's story echoes through the ages: when the world fails you, when all human support crumbles, surrender to the divine is not weakness — it is the greatest strength. Krishna teaches that he is bound by the thread of devotion, and whoever calls upon him with genuine faith will never be abandoned.",
    "द्रौपदी की कथा युगों-युगों तक गूँजती है: जब संसार आपको छोड़ दे, जब सारा मानवीय सहारा टूट जाए, तो ईश्वर के प्रति समर्पण दुर्बलता नहीं — सबसे बड़ी शक्ति है। कृष्ण सिखाते हैं कि वे भक्ति के धागे से बँधे हैं, और जो कोई सच्ची आस्था से उन्हें पुकारेगा, उसे कभी त्यागा नहीं जाएगा।", True),
 ]
},
{
 "slug": "krishna-arjuna-vishwaroop",
 "title": "The Cosmic Vision on the Battlefield",
 "title_hindi": "विश्वरूप दर्शन",
 "deity_slug": "Krishna",
 "source": "Bhagavad Gita",
 "category": "moral",
 "key_teaching": "The divine encompasses all of creation — birth, death, time, and beyond.",
 "reflection_prompt": "Can you see the sacred in everyday moments, not just in temples?",
 "estimated_minutes": 4,
 "order_index": 10,
 "pages": [
  p("On the battlefield of Kurukshetra, Arjuna stood paralyzed between two armies. His own family, teachers, and friends stood on opposite sides. Dropping his bow Gandiva, he told Krishna, his charioteer, 'I cannot fight. I would rather die than kill my own kin.'",
    "कुरुक्षेत्र के रणभूमि में, अर्जुन दो सेनाओं के बीच पंगु खड़े थे। उनके अपने परिजन, गुरु और मित्र विपक्ष में खड़े थे। अपना धनुष गांडीव गिराकर उन्होंने अपने सारथी कृष्ण से कहा, 'मैं युद्ध नहीं कर सकता। अपनों को मारने से मृत्यु श्रेयस्कर है।'"),
  p("Krishna spoke for hours, revealing the deepest truths of existence — about duty, the eternal soul, action without attachment, and devotion. But Arjuna asked, 'Show me your true form, O Krishna. Let me see what you really are.' Krishna granted him divine vision.",
    "कृष्ण ने घंटों तक अस्तित्व के गहनतम सत्य प्रकट किए — कर्तव्य, शाश्वत आत्मा, निष्काम कर्म और भक्ति के बारे में। पर अर्जुन ने कहा, 'मुझे अपना सच्चा रूप दिखाओ, हे कृष्ण। मुझे देखने दो कि तुम वास्तव में क्या हो।' कृष्ण ने उन्हें दिव्य दृष्टि प्रदान की।"),
  p("What Arjuna saw shook him to his core. Krishna's body expanded to fill the entire universe. Countless faces, infinite arms, blazing suns and moons within him. All of creation — past, present, and future — existed within Krishna simultaneously. Stars were born and died. Armies marched into his mouths. Time itself was visible as a consuming fire.",
    "अर्जुन ने जो देखा, उससे वे काँप उठे। कृष्ण का शरीर विस्तारित होकर पूरे ब्रह्मांड में फैल गया। अगणित मुख, अनंत भुजाएँ, प्रज्वलित सूर्य और चंद्रमा उनमें। समस्त सृष्टि — भूत, वर्तमान और भविष्य — एक साथ कृष्ण में विद्यमान थी। तारे जन्मते और मरते। सेनाएँ उनके मुखों में प्रवेश करतीं। काल स्वयं एक भस्म करने वाली अग्नि के रूप में दिखाई दिया।"),
  p("Trembling with awe and terror, Arjuna folded his hands: 'You are everything — the beginning, the middle, and the end of all beings.' Krishna returned to his gentle form and smiled: 'Now do your duty, Arjuna, and surrender the results to me.' The Vishwaroop teaches that the divine is not distant — it IS everything. Our duty is simply to act with devotion.",
    "भय और विस्मय से काँपते हुए अर्जुन ने हाथ जोड़े: 'आप सब कुछ हैं — सभी प्राणियों का आदि, मध्य और अंत।' कृष्ण अपने सौम्य रूप में लौटे और मुस्कुराए: 'अब अपना कर्तव्य करो अर्जुन, और फल मुझे समर्पित करो।' विश्वरूप सिखाता है कि ईश्वर दूर नहीं — वह सब कुछ है। हमारा कर्तव्य केवल भक्ति से कर्म करना है।", True),
 ]
},
]

# I'll add Hanuman and Ganesha stories in the next batch
# For now, let's insert the Shiva + Krishna stories (10 total)

def main():
    # First check existing slugs to avoid duplicates
    r = requests.get(f"{URL}/rest/v1/sacred_stories?select=slug", headers={"apikey": KEY, "Authorization": f"Bearer {KEY}"})
    existing = {s["slug"] for s in r.json()}
    print(f"Existing stories: {existing}")

    to_insert = [s for s in STORIES if s["slug"] not in existing]
    print(f"New stories to insert: {len(to_insert)}")

    if not to_insert:
        print("Nothing to insert!")
        return

    for s in to_insert:
        s["is_active"] = True

    # Insert one at a time
    for i, story in enumerate(to_insert):
        r = requests.post(f"{URL}/rest/v1/sacred_stories", headers=H, json=story)
        if r.status_code in (200, 201):
            print(f"  {i+1}. Inserted: {story['title']}")
        else:
            print(f"  {i+1}. FAILED ({story['title']}): {r.status_code} - {r.text[:200]}")

    # Verify
    r = requests.get(f"{URL}/rest/v1/sacred_stories?select=title,deity_slug,category&order=order_index.asc",
                     headers={"apikey": KEY, "Authorization": f"Bearer {KEY}"})
    print(f"\nTotal stories now: {len(r.json())}")
    for s in r.json():
        print(f"  {s['title']} | {s['deity_slug']} | {s['category']}")

if __name__ == "__main__":
    main()
