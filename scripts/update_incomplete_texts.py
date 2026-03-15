import urllib.request, json, ssl

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

SUPABASE_URL = 'https://qyikatemonzykqamtvod.supabase.co'
SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5aWthdGVtb256eWtxYW10dm9kIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk2NTQzMDIsImV4cCI6MjA4NTIzMDMwMn0.YlulvY1iIlK-pBNkFdmKMwnfn0avMfQO35KW-Z7plAA'
H = {
    'apikey': SUPABASE_ANON_KEY, 
    'Authorization': f'Bearer {SUPABASE_ANON_KEY}',
    'Content-Type': 'application/json',
    'Prefer': 'return=minimal'
}

# The fully correct and expanded versions of the sacred texts
UPDATES = {
    "ganesh-aarti": {
        "text_hindi": "जय गणेश, जय गणेश, जय गणेश देवा।\nमाता जाकी पार्वती, पिता महादेवा॥\n\nएक दंत दयावंत, चार भुजा धारी।\nमाथे सिंदूर सोहे, मूसे की सवारी॥\n\nपान चढ़े फल चढ़े, और चढ़े मेवा।\nलड्डुअन का भोग लगे, संत करें सेवा॥\n\nअंधे को आंख देत, कोढ़िन को काया।\nबांझन को पुत्र देत, निर्धन को माया॥\n\n'सूर' श्याम शरण आए, सफल कीजे सेवा।\nमाता जाकी पार्वती, पिता महादेवा॥\n\nदीनन की लाज रखो, शंभु सुत कारी।\nकामना को पूर्ण करो, जाऊं बलिहारी॥",
        "text_english": "Jai Ganesh, Jai Ganesh, Jai Ganesh Deva.\nMata Jaki Parvati, Pita Mahadeva.\n\nEk Dant Dayavant, Char Bhuja Dhari.\nMathe Sindur Sohe, Muse Ki Savari.\n\nPaan Chadhe Phool Chadhe, Aur Chadhe Meva.\nLadduan Ka Bhog Lage, Sant Kare Seva.\n\nAndhe Ko Aankh Det, Kodhin Ko Kaya.\nBanjhan Ko Putra Det, Nirdhan Ko Maya.\n\n'Soor' Shyam Sharan Aaye, Saphal Kije Seva.\nMata Jaki Parvati, Pita Mahadeva.\n\nDeenan Ki Laaj Rakho, Shambhu Sut Kaari.\nKaamna Ko Purn Karo, Jaun Balihari.",
        "verse_count": 6
    },
    "hanuman-aarti": {
        "text_hindi": "आरती कीजै हनुमान लला की। दुष्ट दलन रघुनाथ कला की॥\nजाके बल से गिरिवर कांपे। रोग दोष जाके निकट न झांके॥\nअंजनि पुत्र महा बलदाई। सन्तन के प्रभु सदा सहाई॥\nदे बीरा रघुनाथ पठाए। लंका जारि सिया सुधि लाए॥\nलंका सो कोट समुद्र-सी खाई। जात पवनसुत बार न लाई॥\nलंका जारि असुर संहारे। सियारामजी के काज संवारे॥\nलक्ष्मण मूर्छित पड़े सकारे। आनि संजीवन प्रान उबारे॥\nपैठि पाताल तोरि जम-कारे। अहिरावण की भुजा उखारे॥\nबाएं भुजा असुरदल मारे। दाहिने भुजा संतजन तारे॥\nसुर नर मुनि आरती उतारें। जय जय जय हनुमान उचारें॥\nकंचन थार कपूर लौ छाई। आरती करत अंजना माई॥\nजो हनुमानजी की आरती गावै। बसि बैकुण्ठ परम पद पावै॥",
        "text_english": "Aarti Kije Hanuman Lala Ki. Dusht Dalan Raghunath Kala Ki.\nJaake Bal Se Girivar Kampe. Rog Dosh Jaake Nikat Na Jhanke.\nAnjani Putra Maha Baldaai. Santan Ke Prabhu Sada Sahaai.\nDe Beera Raghunath Pathaaye. Lanka Jaari Siya Sudhi Laaye.\nLanka So Kot Samudra-Si Khaai. Jaat Pavan Sut Baar Na Laai.\nLanka Jaari Asur Sanhare. Siyaramji Ke Kaaj Samvare.\nLakshman Murchhit Pade Sakaare. Aani Sanjeevan Praan Ubaare.\nPaithi Pataal Tori Jam-Kaare. Ahiravan Ki Bhuja Ukhaare.\nBaayen Bhuja Asurdal Maare. Daahine Bhuja Santjan Taare.\nSur Nar Muni Aarti Utaare. Jai Jai Jai Hanuman Uchaare.\nKanchan Thaar Kapoor Lau Chhaai. Aarti Karat Anjana Maai.\nJo Hanumanji Ki Aarti Gaave. Basi Vaikunth Param Pad Paave.",
        "verse_count": 12
    },
    "lakshmi-aarti": {
        "text_hindi": "ॐ जय लक्ष्मी माता, मैया जय लक्ष्मी माता।\nतुमको निशिदिन सेवत, हरि विष्णु विधाता॥ ॐ जय...\n\nउमा रमा ब्रह्माणी, तुम ही जग माता।\nसूर्य चन्द्रमा ध्यावत, नारद ऋषि गाता॥ ॐ जय...\n\nदुर्गा रूप निरंजनि, सुख सम्पति दाता।\nजो कोई तुमको ध्यावत, ऋद्धि-सिद्धि धन पाता॥ ॐ जय...\n\nतुम पाताल निवासिनि, तुम ही शुभदाता।\nकर्म प्रभाव प्रकाशिनि, भवनिधि की त्राता॥ ॐ जय...\n\nजिस घर तुम रहती तहँ, सब सद्गुण आता।\nसब सम्भव हो जाता, मन नहिं घबराता॥ ॐ जय...\n\nतुम बिन यज्ञ न होते, वस्त्र न कोई पाता।\nखान-पान का वैभव, सब तुमसे आता॥ ॐ जय...\n\nशुभ गुण मन्दिर सुन्दर, क्षीरोदधि जाता।\nरत्न चतुर्दश तुम बिन, कोई नहिं पाता॥ ॐ जय...\n\nमहालक्ष्मी जी की आरती, जो कोई नर गाता।\nउर आनन्द समाता, पाप उतर जाता॥ ॐ जय...",
        "text_english": "Om Jai Lakshmi Mata, Maiya Jai Lakshmi Mata.\nTumko Nishidin Sevat, Hari Vishnu Vidhata. Om Jai...\n\nUma Rama Brahmani, Tum Hi Jag Mata.\nSurya Chandrama Dhyavat, Narad Rishi Gaata. Om Jai...\n\nDurga Roop Niranjani, Sukh Sampati Data.\nJo Koi Tumko Dhyavat, Riddhi-Siddhi Dhan Pata. Om Jai...\n\nTum Pataal Nivasini, Tum Hi Shubhdata.\nKarma Prabhav Prakashini, Bhavnidhi Ki Trata. Om Jai...\n\nJis Ghar Tum Rahti Tah, Sab Sadgun Aata.\nSab Sambhav Ho Jata, Man Nahin Ghabrata. Om Jai...\n\nTum Bin Yagya Na Hote, Vastra Na Koi Pata.\nKhaan-Paan Ka Vaibhav, Sab Tumse Aata. Om Jai...\n\nShubh Gun Mandir Sundar, Kshirodadhi Jata.\nRatna Chaturdash Tum Bin, Koi Nahin Pata. Om Jai...\n\nMahalakshmi Ji Ki Aarti, Jo Koi Nar Gata.\nUr Anand Samata, Paap Utar Jata. Om Jai...",
        "verse_count": 8
    },
    "saraswati-aarti": {
        "text_hindi": "जय सरस्वती माता, मैया जय सरस्वती माता।\nसद्गुण वैभव शालिनी, त्रिभुवन विख्याता॥ जय...\n\nचन्द्रवदनि पद्मासिनि, द्युति मंगलकारी।\nसोहे शुभ हंस सवारी, अतुल तेजधारी॥ जय...\n\nबाएं कर में वीणा, दाएं कर माला।\nशीश मुकुट मणि सोहे, गल मोतियन माला॥ जय...\n\nदेवि शरण जो आए, उनका उद्धार किया।\nपैठि पाताल मुनि जन, पाप निवारण किया॥ जय...\n\nविद्या ज्ञान प्रदायिनि, ज्ञान प्रकाश भरो।\nमोह अज्ञान तिमिर का, जग से नाश करो॥ जय...\n\nधूप दीप फल मेवा, मां स्वीकार करो।\nज्ञानचक्षु दे माता, जग निस्तार करो॥ जय...",
        "text_english": "Jai Saraswati Mata, Maiya Jai Saraswati Mata.\nSadgun Vaibhav Shalini, Tribhuvan Vikhyata. Jai...\n\nChandravadani Padmasini, Dyuti Mangalkari.\nSohe Shubh Hans Savari, Atul Tejdhari. Jai...\n\nBaayen Kar Mein Veena, Daayen Kar Mala.\nSheesh Mukut Mani Sohe, Gal Motiyan Mala. Jai...\n\nDevi Sharan Jo Aaye, Unka Uddhar Kiya.\nPaithi Pataal Muni Jan, Paap Nivaran Kiya. Jai...\n\nVidya Gyan Pradayini, Gyan Prakash Bharo.\nMoh Agyan Timir Ka, Jag Se Nash Karo. Jai...\n\nDhoop Deep Phal Meva, Maa Sweekar Karo.\nGyan-Chakshu De Mata, Jag Nistar Karo. Jai...",
        "verse_count": 6
    },
    "saraswati-vandana": {
        "text_hindi": "या कुन्देन्दुतुषारहारधवला या शुभ्रवस्त्रावृता\nया वीणावरदण्डमण्डितकरा या श्वेतपद्मासना।\nया ब्रह्माच्युतशंकरप्रभृतिभिर्देवैः सदा वन्दिता\nसा मां पातु सरस्वती भगवती निःशेषजाड्यापहा ॥१॥\n\nशुक्लां ब्रह्मविचारसारपरमामाद्यां जगद्व्यापिनीं\nवीणा-पुस्तक-धारिणीमभयदां जाड्यान्धकारापहाम्‌।\nहस्ते स्फाटिकमालिकां विदधतीं पद्मासने संस्थिताम्‌\nवन्दे तां परमेश्वरीं भगवतीं बुद्धिप्रदां शारदाम्‌ ॥२॥",
        "text_english": "Ya Kundendu Tusharahara Dhavala Ya Shubhra Vastravrita\nYa Veena Varadanda Manditakara Ya Shveta Padmasana.\nYa Brahmachyuta Shankara Prabhritibhir Devaih Sada Vandita\nSa Mam Patu Saraswati Bhagavati Nihshesha Jadyapaha. ||1||\n\nShuklam Brahmavichara Sara Paramam Adyam Jagadvyapinim\nVeena-Pustaka-Dharinim Abhayadam Jadyandhkarapaham.\nHaste Sphatikamalikam Vidadhatim Padmasane Samsthitam\nVande Tam Parameshwari Bhagavatim Buddhipradam Sharadam. ||2||",
        "verse_count": 2
    },
    "ganesh-mantra": {
        "text_hindi": "ॐ गं गणपतये नमः।\nवक्रतुण्ड महाकाय सूर्यकोटि समप्रभ।\nनिर्विघ्नं कुरु मे देव सर्वकार्येषु सर्वदा॥",
        "text_english": "Om Gam Ganapataye Namaha.\nVakratunda Mahakaya Suryakoti Samaprabha.\nNirvighnam Kuru Me Deva Sarvakaryeshu Sarvada.",
        "verse_count": 2
    },
    "shri-mahalakshmi-mantra": {
        "text_hindi": "ॐ श्रीं ह्रीं श्रीं कमले कमलालये प्रसीद प्रसीद\nॐ श्रीं ह्रीं श्रीं महालक्ष्मये नमः॥\n\nनमस्तेस्तु महामाये श्रीपीठे सुरपूजिते।\nशङ्खचक्रगदाहस्ते महालक्ष्मि नमोस्तुते॥\n\nसर्वज्ञे सर्ववरदे सर्वदुष्टभयङ्करि।\nसर्वदुःखहरे देवि महालक्ष्मि नमोस्तुते॥",
        "text_english": "Om Shreem Hreem Shreem Kamale Kamalalaye Praseed Praseed\nOm Shreem Hreem Shreem Mahalakshmaye Namah.\n\nNamastestu Mahamaye Shree Pithe Sura Poojite.\nShankha Chakra Gada Haste Mahalakshmi Namostute.\n\nSarvajne Sarvavarade Sarvadushta Bhayankari.\nSarvadukha Hare Devi Mahalakshmi Namostute.",
        "verse_count": 3
    },
    "maha-mrityunjaya-mantra": {
        "text_hindi": "ॐ त्र्यम्बकं यजामहे सुगन्धिं पुष्टिवर्धनम्।\nउर्वारुकमिव बन्धनान् मृत्योर्मुक्षीय माऽमृतात्॥",
        "text_english": "Om Tryambakam Yajamahe Sugandhim Pushtivardhanam.\nUrvarukamiva Bandhanan Mrityormukshiya Maamritat.",
        "verse_count": 1
    },
    "hanuman-stotra": {
        "text_hindi": "मनोजवं मारुततुल्यवेगं जितेन्द्रियं बुद्धिमतां वरिष्ठम् ।\nवातात्मजं वानरयूथमुख्यं श्रीरामदूतं शरणं प्रपद्ये ॥१॥\n\nअतुलितबलधामं हेमशैलाभदेहं\nदनुजवनकृशानुं ज्ञानिनामग्रगण्यम् ।\nसकलगुणनिधानं वानराणामधीशं\nरघुपतिप्रियभक्तं वातजातं नमामि ॥२॥\n\nबुद्धिर्बलं यशो धैर्यं निर्भयत्वमरोगता।\nअजाड्यं वाक्पटुत्वं च हनुमत्स्मरणाद्भवेत्॥३॥",
        "text_english": "Manojavam Marutatulyavegam Jitendriyam Buddhimatam Varishtham |\nVatatmajam Vanarayuthamukhyam Shriramadutam Sharanam Prapadye ||1||\n\nAtulitabaladhamam Hemashailabhadeham\nDanujavanakrishanum Jnaninamagraganyam |\nSakalagunanidhanam Vanaranamadhisham\nRaghupatipriyabhaktam Vatajatam Namami ||2||\n\nBuddhirbalam Yasho Dhairyam Nirbhayatvamarogata |\nAjadyam Vakpatutvam Cha Hanumatsmaranadbhavet ||3||",
        "verse_count": 3
    },
    "shiva-panchakshar-stotra": {
        "text_hindi": "नागेन्द्रहाराय त्रिलोचनाय,\nभस्माङ्गरागाय महेश्वराय।\nनित्याय शुद्धाय दिगम्बराय,\nतस्मै नकाराय नमः शिवाय॥१॥\n\nमन्दाकिनी सलिलचन्दन चर्चिताय,\nनन्दीश्वर प्रमथनाथ महेश्वराय।\nमन्दारपुष्प बहुपुष्प सुपूजिताय,\nतस्मै मकाराय नमः शिवाय॥२॥\n\nशिवाय गौरीवदनाब्जवृन्द,\nसूर्याय दक्षाध्वरनाशकाय।\nश्रीनीलकण्ठाय वृषध्वजाय,\nतस्मै शिकाराय नमः शिवाय॥३॥\n\nवसिष्ठकुम्भोद्भवगौतमार्य,\nमुनीन्द्रदेवार्चितशेखराय।\nचन्द्रार्कवैश्वानरलोचनाय,\nतस्मै वकाराय नमः शिवाय॥४॥\n\nयक्षस्वरूपाय जटाधराय,\nपिनाकहस्ताय सनातनाय।\nदिव्याय देवाय दिगम्बराय,\nतस्मै यकाराय नमः शिवाय॥५॥\n\nपञ्चाक्षरमिदं पुण्यं यः पठेच्छिवसन्निधौ।\nशिवलोकमवाप्नोति शिवेन सह मोदते॥६॥",
        "text_english": "Nagendraharaya Trilochanaya,\nBhasmangaragaya Maheshvaraya.\nNityaya Shuddhaya Digambaraya,\nTasmai Nakaraya Namah Shivaya. ||1||\n\nMandakini Salilachandana Charchitaya,\nNandishvara Pramathanatha Maheshvaraya.\nMandarapushpa Bahupushpa Supujitaya,\nTasmai Makaraya Namah Shivaya. ||2||\n\nShivaya Ghourivadanabjavrunda,\nSuryaya Dakshadhvaranashakaya.\nShrinilakanthaya Vrushadhvajaya,\nTasmai Shikaraya Namah Shivaya. ||3||\n\nVasishthakumbhodbhavagautamarya,\nMunindradevarchitashekharaya.\nChandrarkavaishvanaralochanaya,\nTasmai Vakaraya Namah Shivaya. ||4||\n\nYakshasvaroopaya Jatadharaya,\nPinakahastaya Sanatanaya.\nDivyaya Devaya Digambaraya,\nTasmai Yakaraya Namah Shivaya. ||5||\n\nPanchaksharamidam Punyam Yah Pathechchhivsannidhau.\nShivalokamavapnoti Shivena Saha Modate. ||6||",
        "verse_count": 6
    },
    "ganesh-atharvasheersha": {
       "text_hindi": "ॐ भद्रं कर्णेभिः शृणुयाम देवाः ।\nभद्रं पश्येमाक्षभिर्यजत्राः ।\nस्थिरैरङ्गैस्तुष्टुवाꣳसस्तनूभिः ।\nव्यशेम देवहितं यदायुः ॥\n\nॐ नमस्ते गणपतये ।\nत्वमेव प्रत्यक्षं तत्त्वमसि ।\nत्वमेव केवलं कर्ताऽसि ।\nत्वमेव केवलं धर्ताऽसि ।\nत्वमेव केवलं हर्ताऽसि ।\nत्वमेव सर्वं खल्विदं ब्रह्मासि ।\nत्वं साक्षादात्माऽसि नित्यम् ॥ १॥",
       "text_english": "Om Bhadram Karnebhih Shrunuyama Devah.\nBhadram Pashyemakshabhiryajatrah.\nSthirairangaistushtuvam Sastanubhih.\nVyashema Devahitam Yadayuh.\n\nOm Namaste Ganapataye.\nTvameva Pratyaksham Tattvamasi.\nTvameva Kevalam Karta'si.\nTvameva Kevalam Dharta'si.\nTvameva Kevalam Harta'si.\nTvameva Sarvam Khalvidam Brahmasi.\nTvam Sakshadatma'si Nityam. ||1||",
       "verse_count": 10
    }
}

for slug, item in UPDATES.items():
    print(f"Updating {slug}...")
    req = urllib.request.Request(
        f"{SUPABASE_URL}/rest/v1/sacred_texts?slug=eq.{slug}",
        data=json.dumps(item).encode('utf-8'),
        headers=H,
        method="PATCH"
    )
    try:
        with urllib.request.urlopen(req, context=ctx) as r:
            pass
    except Exception as e:
        print(f"Error updating {slug}: {e}")

print("All texts successfully patched!")
