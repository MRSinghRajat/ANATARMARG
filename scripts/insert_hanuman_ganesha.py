#!/usr/bin/env python3
"""Insert Hanuman and Ganesha sacred stories."""
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
# ══════════ HANUMAN (5 stories) ══════════
{
 "slug": "hanuman-searches-sita",
 "title": "Hanuman's Leap Across the Ocean",
 "title_hindi": "हनुमान की समुद्र लंघन",
 "deity_slug": "Hanuman",
 "source": "Ramayana",
 "category": "mythology",
 "key_teaching": "When motivated by love and devotion, no obstacle is truly insurmountable.",
 "reflection_prompt": "What seemingly impossible challenge could you overcome with enough devotion?",
 "estimated_minutes": 4,
 "is_featured": True,
 "is_active": True,
 "order_index": 11,
 "pages": [
  p("After Ravana kidnapped Sita, Rama and the Vanara army reached the southern tip of India. Before them lay the vast ocean, and beyond it, Lanka. Finding Sita required someone to leap across a hundred yojanas of churning sea. The Vanaras looked at each other in despair.",
    "रावण द्वारा सीता के अपहरण के बाद, राम और वानर सेना भारत के दक्षिणी छोर पर पहुँची। उनके सामने विशाल समुद्र था और उसके पार लंका। सीता को खोजने के लिए किसी को सौ योजन समुद्र लाँघना था। वानर निराशा से एक-दूसरे को देखने लगे।"),
  p("Jambavan, the wise bear, turned to Hanuman: 'O son of the Wind God, you have forgotten your own power! As a child you leapt toward the sun thinking it was a fruit. You possess the strength to cross this ocean.' Hearing these words, Hanuman remembered his true nature.",
    "जाम्बवान ने हनुमान से कहा: 'हे पवनपुत्र, तुम अपनी शक्ति भूल गए हो! बचपन में तुमने सूर्य को फल समझकर छलाँग लगाई थी। इस सागर को पार करने की शक्ति तुम में है।' ये शब्द सुनकर हनुमान को अपने असली स्वरूप का स्मरण हुआ।"),
  p("Hanuman grew to an enormous size, his body blazing like a mountain of gold. With a mighty roar that shook the earth, he leapt from the mountain peak. The ocean parted beneath him. Demons tried to stop him mid-flight, but nothing could halt the devotee of Rama.",
    "हनुमान विशाल रूप धारण कर गए, उनका शरीर स्वर्ण पर्वत की भाँति चमक रहा था। पृथ्वी को कँपाती गर्जना के साथ उन्होंने पर्वत शिखर से छलाँग लगाई। समुद्र उनके नीचे विभाजित हो गया। राक्षसों ने मार्ग में रोकने का प्रयास किया, पर राम भक्त को कोई नहीं रोक सका।"),
  p("Landing in Lanka, Hanuman searched the entire golden city until he found Sita in the Ashoka garden, praying for Rama. He gave her Rama's ring as proof and hope. This story teaches that when we remember our divine nature and act from love, we can achieve the impossible.",
    "लंका में उतरकर, हनुमान ने पूरी स्वर्ण नगरी खोजी और अशोक वाटिका में राम की प्रार्थना करती सीता को पाया। उन्होंने राम की अँगूठी प्रमाण और आशा के रूप में दी। यह कथा सिखाती है कि जब हम अपने दिव्य स्वरूप को याद करें और प्रेम से कार्य करें, तो असंभव भी संभव होता है।", True),
 ]
},
{
 "slug": "hanuman-burns-lanka",
 "title": "Hanuman Sets Lanka Ablaze",
 "title_hindi": "हनुमान द्वारा लंका दहन",
 "deity_slug": "Hanuman",
 "source": "Ramayana",
 "category": "mythology",
 "key_teaching": "Injustice will always face consequences; courage turns captivity into triumph.",
 "reflection_prompt": "How do you respond when treated unjustly? With fear or with courage?",
 "estimated_minutes": 4,
 "is_featured": False,
 "is_active": True,
 "order_index": 12,
 "pages": [
  p("After finding Sita, Hanuman intentionally let himself be captured by Ravana's son Indrajit. He wanted to see Ravana face to face and deliver Rama's message. Bound in serpent ropes, he was dragged before the demon king's court.",
    "सीता को खोजने के बाद, हनुमान ने जानबूझकर रावण के पुत्र इंद्रजित से बंदी बनना स्वीकार किया। वे रावण से आमने-सामने मिलकर राम का संदेश देना चाहते थे। नाग पाश में बँधकर उन्हें राक्षस राज की सभा में लाया गया।"),
  p("Hanuman fearlessly addressed Ravana: 'O King, return Sita to Lord Rama and seek his forgiveness. His arrows will not spare even your golden Lanka.' Ravana laughed and ordered Hanuman's tail to be set on fire as punishment and humiliation.",
    "हनुमान ने निर्भय होकर रावण से कहा: 'हे राजन, सीता को राम को लौटाओ और क्षमा माँगो। उनके बाण तुम्हारी स्वर्ण लंका को भी नहीं छोड़ेंगे।' रावण हँसा और दंड तथा अपमान स्वरूप हनुमान की पूँछ में आग लगाने का आदेश दिया।"),
  p("But as Ravana's soldiers wrapped cloth soaked in oil around his tail and lit it, Hanuman shrank his body and slipped free of the ropes. Then he grew enormous again and began leaping from rooftop to rooftop, setting fire to all of Lanka with his burning tail. Palaces, gardens, and treasuries turned to ash.",
    "रावण के सैनिकों ने तेल में भीगा कपड़ा उनकी पूँछ पर लपेटकर आग लगाई, पर हनुमान ने शरीर छोटा कर बंधन तोड़ दिए। फिर विशाल रूप धारण कर छत से छत कूदते हुए अपनी जलती पूँछ से पूरी लंका में आग लगा दी। महल, उद्यान और खजाने भस्म हो गए।"),
  p("Having delivered both Rama's message and a demonstration of his power, Hanuman extinguished his tail in the ocean and flew back to Rama. The story teaches that evil may mock righteousness, but the fire of dharma always burns brighter than the fire of arrogance.",
    "राम का संदेश और शक्ति का प्रदर्शन दोनों देकर, हनुमान ने समुद्र में अपनी पूँछ बुझाई और राम के पास उड़ गए। यह कथा सिखाती है कि अधर्म धर्म का उपहास कर सकता है, पर धर्म की अग्नि सदा अहंकार की अग्नि से अधिक प्रज्वलित होती है।", True),
 ]
},
{
 "slug": "hanuman-sanjeevani",
 "title": "Hanuman Brings the Mountain of Life",
 "title_hindi": "हनुमान संजीवनी बूटी लाते हैं",
 "deity_slug": "Hanuman",
 "source": "Ramayana",
 "category": "mythology",
 "key_teaching": "In times of crisis, take bold action rather than hesitating over small details.",
 "reflection_prompt": "When someone you love needs help urgently, do you overthink or act?",
 "estimated_minutes": 3,
 "is_featured": True,
 "is_active": True,
 "order_index": 13,
 "pages": [
  p("During the great battle in Lanka, Lakshmana was struck by Indrajit's Shakti weapon and fell unconscious, near death. The physician Sushena said only the Sanjeevani herb from the Dronagiri mountain in the Himalayas could save him, and it had to arrive before dawn.",
    "लंका के महायुद्ध में, लक्ष्मण इंद्रजित के शक्ति अस्त्र से मूर्छित हो गए, मृत्यु के निकट। वैद्य सुषेण ने कहा कि केवल हिमालय के द्रोणागिरि पर्वत की संजीवनी बूटी ही उन्हें बचा सकती है, और वह सूर्योदय से पहले आनी चाहिए।"),
  p("Hanuman flew northward with the speed of wind itself. When he reached the Himalayas and found Dronagiri mountain glowing with medicinal herbs, he could not identify which specific herb was the Sanjeevani. Rather than waste precious time searching, Hanuman made a bold decision.",
    "हनुमान वायु की गति से उत्तर की ओर उड़े। जब हिमालय पहुँचकर औषधीय जड़ी-बूटियों से चमकते द्रोणागिरि पर्वत पर पहुँचे, तो संजीवनी बूटी पहचान नहीं पाए। बहुमूल्य समय बर्बाद करने के बजाय, हनुमान ने साहसी निर्णय लिया।"),
  p("He uprooted the entire mountain and lifted it on his palm! Flying back through the night sky with a glowing mountain, Hanuman arrived just before dawn. The fragrance of the Sanjeevani reached Lakshmana, who opened his eyes and returned to life. The army erupted in joy.",
    "उन्होंने पूरा पर्वत उखाड़कर अपनी हथेली पर उठा लिया! रात्रि के आकाश में चमकते पर्वत के साथ उड़ते हुए, हनुमान ठीक सूर्योदय से पहले पहुँचे। संजीवनी की सुगंध लक्ष्मण तक पहुँची, उन्होंने आँखें खोलीं और पुनर्जीवित हो गए। सेना में आनंद छा गया।", True),
 ]
},
{
 "slug": "hanuman-opens-heart",
 "title": "Rama Lives in Hanuman's Heart",
 "title_hindi": "हनुमान के हृदय में राम",
 "deity_slug": "Hanuman",
 "source": "Ramayana",
 "category": "moral",
 "key_teaching": "The highest devotion is when the divine lives within every fiber of your being.",
 "reflection_prompt": "What do you carry so deeply in your heart that it defines who you are?",
 "estimated_minutes": 3,
 "is_featured": False,
 "is_active": True,
 "order_index": 14,
 "pages": [
  p("After the war ended and Rama was crowned king of Ayodhya, a grand celebration was held. Gifts of gold, jewels, and precious gems were distributed to all who had fought in the great war. Sita gifted Hanuman a magnificent pearl necklace.",
    "युद्ध समाप्त होने और राम के अयोध्या के राजा बनने के बाद, भव्य उत्सव मनाया गया। युद्ध में लड़ने वालों को सोना, रत्न और बहुमूल्य रत्न वितरित किए गए। सीता ने हनुमान को एक भव्य मोतियों का हार उपहार में दिया।"),
  p("To everyone's surprise, Hanuman began breaking each pearl with his teeth! The courtiers were shocked and offended. 'Why are you destroying such a precious gift?' they demanded. Hanuman replied calmly, 'I am checking if Rama's name is inside these pearls. If Rama is not in them, they are worthless to me.'",
    "सबके आश्चर्य में, हनुमान ने हर मोती को दाँतों से तोड़ना शुरू किया! दरबारियों ने चिढ़कर पूछा, 'इतने मूल्यवान उपहार को क्यों नष्ट कर रहे हो?' हनुमान ने शांति से कहा, 'मैं देख रहा हूँ कि इन मोतियों में राम का नाम है या नहीं। यदि राम नहीं हैं, तो ये मेरे लिए मूल्यहीन हैं।'"),
  p("A courtier mocked: 'Then is Rama's name in your body?' Without hesitation, Hanuman tore open his chest. There, within his heart, glowing with divine light, sat Rama and Sita. Every hair on his body echoed 'Ram, Ram, Ram.' The entire court fell silent in awe.",
    "एक दरबारी ने व्यंग्य किया: 'तो क्या तुम्हारे शरीर में राम हैं?' बिना हिचकिचाहट, हनुमान ने अपनी छाती चीर दी। वहाँ, उनके हृदय में, दिव्य प्रकाश से चमकते राम और सीता विराजमान थे। उनके शरीर का हर रोम 'राम, राम, राम' गूँज रहा था। पूरी सभा विस्मय में मौन हो गई।"),
  p("This story is the pinnacle of bhakti - devotion so complete that the devotee and the divine become one. Hanuman teaches that true wealth is not gold or pearls, but the presence of the divine in every breath.",
    "यह कथा भक्ति की पराकाष्ठा है - इतना पूर्ण समर्पण कि भक्त और भगवान एक हो जाएँ। हनुमान सिखाते हैं कि सच्चा धन सोना या मोती नहीं, बल्कि हर श्वास में भगवान की उपस्थिति है।", True),
 ]
},
{
 "slug": "hanuman-childhood-sun",
 "title": "Baby Hanuman Swallows the Sun",
 "title_hindi": "बाल हनुमान और सूर्य निगलन",
 "deity_slug": "Hanuman",
 "source": "Ramayana",
 "category": "leela",
 "key_teaching": "Innocence combined with divine power must be guided by wisdom and humility.",
 "reflection_prompt": "How do you use your strengths responsibly without becoming reckless?",
 "estimated_minutes": 3,
 "is_featured": False,
 "is_active": True,
 "order_index": 15,
 "pages": [
  p("As a baby, Hanuman was extraordinarily powerful. One morning, seeing the rising sun, he mistook it for a ripe, glowing fruit. Hungry and curious, baby Hanuman leapt into the sky toward the sun, flying faster than the wind his father Vayu commanded.",
    "शिशु हनुमान असाधारण रूप से शक्तिशाली थे। एक सुबह, उगते सूर्य को देखकर उन्होंने इसे पका चमकता फल समझा। भूखे और जिज्ञासु हनुमान ने सूर्य की ओर आकाश में छलाँग लगाई, अपने पिता वायु की हवा से भी तेज।"),
  p("As Hanuman approached the sun, Indra, the king of gods, saw a small figure about to swallow the sun itself! Alarmed that the world would be plunged into darkness, Indra hurled his thunderbolt Vajra at the baby. The bolt struck Hanuman's jaw, and he fell to earth unconscious.",
    "जैसे हनुमान सूर्य के निकट पहुँचे, देवराज इंद्र ने देखा कि एक छोटा प्राणी सूर्य को निगलने वाला है! अंधकार के भय से इंद्र ने अपना वज्र शिशु पर फेंका। वज्र हनुमान की ठुड्डी पर लगा और वे मूर्छित होकर पृथ्वी पर गिर पड़े।"),
  p("Vayu, the wind god, was furious at his son's injury. He withdrew all air from the universe. Living beings began to suffocate. The gods panicked and rushed to revive Hanuman. Each god blessed him with a unique power - Brahma gave immortality, Surya offered knowledge, Indra made him resistant to the Vajra.",
    "पवन देव वायु अपने पुत्र के घायल होने पर क्रोधित हुए और सारी वायु ब्रह्मांड से वापस खींच ली। प्राणी दम घुटने लगे। देवताओं ने घबराकर हनुमान को पुनर्जीवित किया। प्रत्येक देवता ने अनोखा वरदान दिया - ब्रह्मा ने अमरत्व, सूर्य ने ज्ञान, इंद्र ने वज्र से अभेद्यता।"),
  p("But the gods also decided that Hanuman would forget his powers until the right moment. This is why Jambavan had to remind him before the ocean leap. The story teaches that great power must be paired with the right purpose and right time.",
    "पर देवताओं ने यह भी निश्चय किया कि हनुमान उचित समय तक अपनी शक्तियाँ भूले रहेंगे। इसीलिए समुद्र लंघन से पहले जाम्बवान को उन्हें याद दिलाना पड़ा। कथा सिखाती है कि महान शक्ति को सही उद्देश्य और सही समय से जोड़ना आवश्यक है।", True),
 ]
},
# ══════════ GANESHA (4 stories, 1 already exists) ══════════
{
 "slug": "ganesha-writing-mahabharata",
 "title": "Ganesha Writes the Mahabharata",
 "title_hindi": "गणेश द्वारा महाभारत लेखन",
 "deity_slug": "ganesha",
 "source": "Mahabharata",
 "category": "mythology",
 "key_teaching": "Wisdom means understanding before acting; never write what you don't comprehend.",
 "reflection_prompt": "Do you take time to truly understand things before committing to them?",
 "estimated_minutes": 3,
 "is_featured": True,
 "is_active": True,
 "order_index": 16,
 "pages": [
  p("When the sage Vyasa wished to compose the great epic Mahabharata, he needed a scribe who could match the speed of his thought. Brahma suggested Lord Ganesha, the wisest of all beings. Vyasa approached Ganesha with his request.",
    "जब ऋषि व्यास ने महान महाकाव्य महाभारत की रचना करनी चाही, उन्हें ऐसे लिपिकार की आवश्यकता थी जो उनके विचार की गति से लिख सके। ब्रह्मा ने सबसे बुद्धिमान भगवान गणेश को सुझाया।"),
  p("Ganesha agreed, but with one condition: 'My pen will not stop even for a moment. You must dictate without pause.' Vyasa smiled and made his own condition: 'You must understand every verse before writing it.' Ganesha agreed, recognizing the cleverness of this demand.",
    "गणेश ने सहमति दी, पर एक शर्त रखी: 'मेरी लेखनी एक क्षण भी नहीं रुकेगी। आपको बिना रुके बोलना होगा।' व्यास मुस्कुराए और अपनी शर्त रखी: 'लिखने से पहले हर श्लोक को समझना होगा।' गणेश ने इस चतुराई को पहचानकर सहमति दी।"),
  p("So the great composition began. Whenever Vyasa needed time to think, he would compose an especially complex verse. Ganesha would pause to understand its meaning, giving Vyasa time to compose the next section. His pen broke mid-writing and he broke off his own tusk to continue without stopping.",
    "महान रचना आरंभ हुई। जब व्यास को सोचने का समय चाहिए, वे जटिल श्लोक बोलते। गणेश उसका अर्थ समझने में रुकते, जिससे व्यास को आगे सोचने का समय मिलता। लेखनी टूट गई तो गणेश ने बिना रुके अपना दाँत तोड़कर लिखना जारी रखा।"),
  p("This is why Ganesha is often depicted holding his broken tusk as a pen. The story teaches that true knowledge requires understanding, not mere recording. And that sacrifice of the self for a higher purpose is the mark of divinity.",
    "इसीलिए गणेश को अक्सर टूटे दाँत को लेखनी के रूप में पकड़े दिखाया जाता है। कथा सिखाती है कि सच्चा ज्ञान समझने में है, केवल लिखने में नहीं। और किसी उच्च उद्देश्य के लिए स्वयं का त्याग दिव्यता की पहचान है।", True),
 ]
},
{
 "slug": "ganesha-moon-curse",
 "title": "Ganesha and the Moon's Laughter",
 "title_hindi": "गणेश और चंद्रमा का उपहास",
 "deity_slug": "ganesha",
 "source": "Shiva Purana",
 "category": "moral",
 "key_teaching": "Never mock others for their appearance; pride in beauty leads to downfall.",
 "reflection_prompt": "Have you ever judged someone by their appearance? What did you learn?",
 "estimated_minutes": 3,
 "is_featured": False,
 "is_active": True,
 "order_index": 17,
 "pages": [
  p("One evening, Ganesha was returning home after a grand feast where he had eaten an enormous quantity of modaks (sweet dumplings). His belly was so full that he rode his tiny mouse vehicle carefully. But the mouse stumbled on a snake, and Ganesha tumbled off, his belly splitting open, scattering modaks everywhere.",
    "एक शाम, गणेश भव्य भोज से लौट रहे थे जहाँ उन्होंने ढेर सारे मोदक खाए थे। उनका पेट इतना भरा था कि वे सावधानी से अपने छोटे मूषक वाहन पर सवार थे। पर मूषक एक साँप पर ठोकर खा गया और गणेश गिर पड़े, पेट फट गया और मोदक बिखर गए।"),
  p("Ganesha quickly gathered the modaks, stuffed them back, and tied the snake around his belly as a belt. Seeing this comical scene, Chandra (the Moon) burst into uncontrollable laughter, mocking Ganesha's round form and the ridiculous spectacle.",
    "गणेश ने जल्दी से मोदक इकट्ठे किए, वापस रखे, और साँप को पेट के चारों ओर पेटी की तरह बाँध लिया। यह हास्यास्पद दृश्य देखकर चंद्रमा जोर से हँसने लगा, गणेश के गोल रूप और इस विचित्र दृश्य का मजाक उड़ाते हुए।"),
  p("Ganesha, angered by the mockery, cursed the Moon: 'You are so proud of your beauty that you mock others. From today, whoever looks at you on Ganesh Chaturthi will be falsely accused of something they didn't do.' The Moon begged forgiveness and Ganesha softened the curse.",
    "उपहास से क्रोधित गणेश ने चंद्रमा को श्राप दिया: 'तुम अपने सौंदर्य पर इतने गर्वित हो कि दूसरों का मजाक उड़ाते हो। आज से जो गणेश चतुर्थी पर तुम्हें देखेगा, उस पर झूठा आरोप लगेगा।' चंद्रमा ने क्षमा माँगी और गणेश ने श्राप कम किया।"),
  p("This is why people avoid looking at the moon on Ganesh Chaturthi even today. The story teaches that beauty without humility becomes a curse. Mocking someone's appearance reveals the ugliness within the mocker, not the one being mocked.",
    "इसीलिए आज भी लोग गणेश चतुर्थी पर चंद्रमा को देखने से बचते हैं। कथा सिखाती है कि विनम्रता के बिना सौंदर्य अभिशाप बन जाता है। किसी के रूप का मजाक उड़ाना मजाक उड़ाने वाले की कुरूपता दर्शाता है।", True),
 ]
},
{
 "slug": "ganesha-kubera-feast",
 "title": "The Feast That Humbled Kubera",
 "title_hindi": "कुबेर का अहंकार और गणेश",
 "deity_slug": "ganesha",
 "source": "Shiva Purana",
 "category": "moral",
 "key_teaching": "Wealth means nothing if used to show off; true abundance is sharing with humility.",
 "reflection_prompt": "Do you use your blessings to serve or to show off?",
 "estimated_minutes": 3,
 "is_featured": False,
 "is_active": True,
 "order_index": 18,
 "pages": [
  p("Kubera, the god of wealth, was immensely proud of his riches. To show off his opulence, he invited Lord Shiva and Parvati to a grand feast at his palace. Shiva, seeing through Kubera's pride, sent young Ganesha instead.",
    "धन के देवता कुबेर को अपनी संपत्ति पर अत्यंत गर्व था। अपनी समृद्धि का प्रदर्शन करने के लिए उन्होंने शिव और पार्वती को भव्य भोज का निमंत्रण दिया। शिव ने कुबेर के अहंकार को समझकर बालक गणेश को भेज दिया।"),
  p("Kubera was delighted - how much could one small child eat? But Ganesha began eating. And eating. Plate after plate disappeared. Then entire tables of food vanished. The kitchens ran dry. The storerooms emptied. Ganesha's hunger only grew with every bite.",
    "कुबेर प्रसन्न हुए - एक छोटा बच्चा कितना खा सकता है? पर गणेश ने खाना शुरू किया। थाली पर थाली गायब होती गई। फिर भोजन की पूरी मेजें। रसोई खाली हो गई। भंडार समाप्त हो गए। हर कौर के साथ गणेश की भूख और बढ़ती गई।"),
  p("'More! I am still hungry!' Ganesha cried, and began eating the furniture, the decorations, the walls of the palace itself. Terrified, Kubera ran to Mount Kailash and begged Shiva for help. Shiva gave him a handful of humble puffed rice and said, 'Give this to Ganesha with love, not pride.'",
    "'और! मुझे अभी भी भूख है!' गणेश ने चिल्लाकर फर्नीचर, सजावट, महल की दीवारें खानी शुरू कीं। भयभीत कुबेर कैलाश दौड़ा और शिव से सहायता माँगी। शिव ने मुट्ठी भर लावा दिया और कहा, 'यह गणेश को प्रेम से दो, गर्व से नहीं।'"),
  p("Kubera offered the simple puffed rice with genuine humility. Ganesha ate it and was instantly satisfied. The simplest food given with love filled what mountains of wealth could not. This story teaches that offerings made with ego can never satisfy, but even a morsel offered with love can satisfy the divine.",
    "कुबेर ने सच्ची विनम्रता से साधारण लावा अर्पित किया। गणेश ने खाया और तुरंत तृप्त हो गए। प्रेम से दिया सबसे सादा भोजन वह भर गया जो धन के पहाड़ नहीं भर सके। कथा सिखाती है कि अहंकार से दिया कभी तृप्त नहीं करता, पर प्रेम का एक कौर भगवान को संतुष्ट कर सकता है।", True),
 ]
},
{
 "slug": "ganesha-race-around-world",
 "title": "Ganesha's Race Around the World",
 "title_hindi": "गणेश की विश्व परिक्रमा",
 "deity_slug": "ganesha",
 "source": "Shiva Purana",
 "category": "moral",
 "key_teaching": "Wisdom triumphs over physical strength; devotion to parents is the highest pilgrimage.",
 "reflection_prompt": "When do you use wisdom instead of brute force to solve problems?",
 "estimated_minutes": 3,
 "is_featured": True,
 "is_active": True,
 "order_index": 19,
 "pages": [
  p("One day Narada Muni brought a divine mango to Shiva and Parvati. Both Ganesha and Kartikeya wanted it. To settle the dispute, Shiva declared a challenge: whoever circles the world three times first wins the mango.",
    "एक दिन नारद मुनि शिव और पार्वती के लिए एक दिव्य आम लाए। गणेश और कार्तिकेय दोनों इसे चाहते थे। विवाद सुलझाने के लिए शिव ने चुनौती दी: जो तीन बार पृथ्वी की परिक्रमा पहले करेगा, आम उसका।"),
  p("Kartikeya immediately mounted his peacock and flew around the earth at blazing speed. Ganesha, with his large belly and tiny mouse, knew he could never match his brother's speed. But he was the god of wisdom. He thought for a moment, then smiled.",
    "कार्तिकेय तुरंत अपने मयूर पर सवार होकर तीव्र गति से पृथ्वी की परिक्रमा करने उड़ गए। गणेश जानते थे कि अपने बड़े पेट और छोटे मूषक से वे भाई की गति से कभी मिल नहीं सकते। पर वे बुद्धि के देवता थे। एक क्षण सोचा, फिर मुस्कुराए।"),
  p("Ganesha walked slowly around his parents Shiva and Parvati - once, twice, three times. Then he bowed and said, 'My parents ARE my world. To circle them is to circle the entire universe.' Shiva was deeply moved by this wisdom and devotion.",
    "गणेश ने धीरे-धीरे अपने माता-पिता शिव और पार्वती की परिक्रमा की - एक बार, दो बार, तीन बार। फिर प्रणाम कर कहा, 'मेरे माता-पिता ही मेरा संसार हैं। उनकी परिक्रमा पूरे ब्रह्मांड की परिक्रमा है।' शिव इस बुद्धि और भक्ति से अत्यंत प्रसन्न हुए।"),
  p("Ganesha won the mango. When Kartikeya returned exhausted, he understood: physical effort cannot compete with wisdom and genuine love. This story teaches that the greatest pilgrimage is honoring your parents, and wisdom always finds a shorter path than brute force.",
    "गणेश ने आम जीत लिया। जब थके कार्तिकेय लौटे, उन्होंने समझा: शारीरिक बल बुद्धि और सच्चे प्रेम से नहीं जीत सकता। कथा सिखाती है कि सबसे बड़ी तीर्थयात्रा माता-पिता का सम्मान है, और बुद्धि सदा बल से छोटा मार्ग खोज लेती है।", True),
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

# Final count
r = requests.get(f"{URL}/rest/v1/sacred_stories?select=slug,title,deity_slug&order=order_index.asc", headers=H_READ)
data = r.json()
print(f"Total stories: {len(data)}")
for i, s in enumerate(data):
    print(f"  {i+1}. [{s['deity_slug']}] {s['title']}")
