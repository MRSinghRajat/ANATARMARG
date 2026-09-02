-- Bhagavad Gita Verse Translations - All 18 Chapters
-- Run after SUPABASE_GITA_DATA.sql
-- Generated from gita_full_cleaned.json

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_1', 'hi', 'Hindi', 'धृतराष्ट्र ने कहा -- हे संजय ! धर्मभूमि कुरुक्षेत्र में एकत्र हुए युद्ध के इच्छुक (युयुत्सव:) मेरे और पाण्डु के पुत्रों ने क्या किया?', FALSE, 'Swami Tejomayananda'),
  ('bg_1_1', 'en', 'English', 'The King Dhritarashtra asked: "O Sanjaya! What happened on the sacred battlefield of Kurukshetra, when my people gathered against the Pandavas?"', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_2', 'hi', 'Hindi', 'संजय ने कहा -- पाण्डव-सैन्य की व्यूह रचना देखकर राजा दुर्योधन ने आचार्य द्रोण के पास जाकर ये वचन कहे।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_2', 'en', 'English', 'Sanjaya replied: "The Prince Duryodhana, when he saw the army of the Pandavas paraded, approached his preceptor Guru Drona and spoke as follows:', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_3', 'hi', 'Hindi', 'हे आचार्य ! आपके बुद्धिमान शिष्य द्रुपदपुत्र (धृष्टद्द्युम्न) द्वारा व्यूहाकार खड़ी की गयी पाण्डु पुत्रों की इस महती सेना को देखिये।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_3', 'en', 'English', 'Revered Father! Behold this mighty host of the Pandavas, paraded by the son of King Drupada, thy wise disciple.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_4', 'hi', 'Hindi', 'इस सेना में महान् धनुर्धारी शूर योद्धा है ,  जो युद्ध में भीम और अर्जुन के समान हैं , जैसे --  युयुधान, विराट तथा महारथी राजा द्रुपद।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_4', 'en', 'English', 'In it are heroes and great bowmen; the equals in battle of Arjuna and Bheema, Yuyudhana, Virata and Drupada, great soldiers all;', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_5', 'hi', 'Hindi', 'धृष्टकेतु, चेकितान, बलवान काशिराज,  पुरुजित्, कुन्तिभोज और मनुष्यों में श्रेष्ठ शैब्य।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_5', 'en', 'English', 'Dhrishtaketu, Chekitan, the valiant King of Benares, Purujit, Kuntibhoja, Shaibya - a master over many;', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_6', 'hi', 'Hindi', 'पराक्रमी युधामन्यु,  बलवान् उत्तमौजा,  सुभद्रापुत्र (अभिमन्यु) और द्रोपदी के पुत्र -- ये सब महारथी हैं।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_6', 'en', 'English', 'Yudhamanyu, Uttamouja, Soubhadra and the sons of Droupadi, famous men.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_7', 'hi', 'Hindi', 'हे द्विजोत्तम ! हमारे पक्ष में भी जो विशिष्ट योद्धागण हैं , उनको आप जान लीजिये; आपकी जानकारी के लिये अपनी सेना के नायकों के नाम मैं आपको बताता हूँ।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_7', 'en', 'English', 'Further, take note of all those captains who have ranged themselves on our side, O best of Spiritual Guides! The leaders of my army. I will name them for you.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_8', 'hi', 'Hindi', 'एक तो स्वयं आप, भीष्म, कर्ण, और युद्ध विजयी कृपाचार्य तथा अश्वत्थामा, विकर्ण और सोमदत्त का पुत्र है।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_8', 'en', 'English', 'You come first; then Bheeshma, Karna, Kripa, great soldiers; Ashwaththama, Vikarna and the son of Somadhatta;', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_9', 'hi', 'Hindi', 'मेरे लिए प्राण त्याग करने के लिए तैयार, अनेक प्रकार के शस्त्रास्त्रों से सुसज्जित तथा युद्ध में कुशल और भी अनेक शूर वीर हैं।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_9', 'en', 'English', 'And many others, all ready to die for my sake; all armed, all skilled in war.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_10', 'hi', 'Hindi', 'भीष्म के द्वारा हमारी रक्षित सेना अपर्याप्त है; किन्तु भीम द्वारा रक्षित उनकी सेना पर्याप्त है अथवा, भीष्म के द्वारा रक्षित हमारी सेना अपरिमित है किन्तु भीम के द्वारा रक्षित उनकी सेना परिमित ही है।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_10', 'en', 'English', 'Yet our army seems the weaker, though commanded by Bheeshma; their army seems the stronger, though commanded by Bheema.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_11', 'hi', 'Hindi', 'विभिन्न मोर्चों पर अपने-अपने स्थान पर स्थित रहते हुए आप सब लोग भीष्म पितामह की ही सब ओर से रक्षा करें।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_11', 'en', 'English', 'Therefore in the rank and file, let stand firm in their posts, according to battalions; and all you generals about Bheeshma.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_12', 'hi', 'Hindi', 'उस समय कौरवों में वृद्ध, प्रतापी पितामह भीष्म ने उस (दुर्योधन) के हृदय में हर्ष उत्पन्न करते हुये उच्च स्वर में गरज कर शंखध्वनि की।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_12', 'en', 'English', 'Then to enliven his spirits, the brave Grandfather Bheeshma, eldest of the Kuru-clan, blew his conch, till it sounded like a lion''s roar.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_13', 'hi', 'Hindi', 'तत्पश्चात् शंख, नगारे, ढोल व शृंगी आदि वाद्य एक साथ ही बज उठे, जिनका बड़ा भयंकर शब्द हुआ।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_13', 'en', 'English', 'And immediately all the conches and drums, the trumpets and horns, blared forth in tumultuous uproar.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_14', 'hi', 'Hindi', 'इसके उपरान्त श्वेत अश्वों से युक्त भव्य रथ में बैठे हुये माधव (श्रीकृष्ण) और पाण्डुपुत्र अर्जुन ने भी अपने दिव्य शंख बजाये।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_14', 'en', 'English', 'Then seated in their spacious war chariot, yoked with white horses, Lord Shri Krishna and Arjuna sounded their divine shells.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_15', 'hi', 'Hindi', 'भगवान् हृषीकेश ने पांचजन्य, धनंजय (अर्जुन) ने देवदत्त तथा भयंकर कर्म करने वाले भीम ने पौण्डू नामक महाशंख बजाया।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_15', 'en', 'English', 'Lord Shri Krishna blew his Panchajanya and Arjuna his Devadatta, brave Bheema his renowned shell, Poundra.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_16', 'hi', 'Hindi', 'कुन्तीपुत्र राजा युधिष्ठिर ने अनन्त विजय नामक शंख और नकुल व सहदेव ने क्रमश:  सुघोष और मणिपुष्पक नामक शंख बजाये।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_16', 'en', 'English', 'The King Dharmaraja, the son of Kunti, blew the Anantavijaya, Nakalu and Sahadeo, the Sugosh and Manipushpaka, respectively.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_17', 'hi', 'Hindi', 'श्रेष्ठ धनुषवाले काशिराज, महारथी शिखण्डी, धृष्टद्युम्न,  राजा विराट और अजेय सात्यकि।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_17', 'en', 'English', 'And the Maharaja of Benares, the great archer, Shikhandi, the great soldier, Dhrishtayumna, Virata and Satyaki, the invincible,', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_18', 'hi', 'Hindi', 'हे राजन् ! राजा द्रुपद,  द्रौपदी के पुत्र और महाबाहु सौभद्र (अभिमन्यु) इन सब ने अलग-अलग शंख बजाये।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_18', 'en', 'English', 'And O King! Drupada, the sons of Droupadi and Soubhadra, the great soldier, blew their conches.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_19', 'hi', 'Hindi', 'वह भयंकर घोष आकाश और पृथ्वी पर गूँजने लगा और उसने धृतराष्ट्र के पुत्रों के हृदय विदीर्ण कर दिये।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_19', 'en', 'English', 'The tumult rent the hearts of the sons of Dhritarashtra, and violently shook heaven and earth with its echo.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_20', 'hi', 'Hindi', 'हे महीपते ! इस प्रकार जब युद्ध प्रारम्भ होने वाला ही था कि कपिध्वज अर्जुन ने धृतराष्ट्र के पुत्रों को स्थित देखकर धनुष उठाकर भगवान् हृषीकेश से ये शब्द कहे।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_20', 'en', 'English', 'Then beholding the sons of Dhritarashtra, drawn up on the battle- field, ready to fight, Arjuna, whose flag bore the Hanuman,', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_21', 'hi', 'Hindi', 'अर्जुन ने कहा -- हे! अच्युत मेरे रथ को दोनों सेनाओं के मध्य खड़ा कीजिये।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_21', 'en', 'English', 'Raising his bow, spoke this to the Lord Shri Krishna: O Infallible! Lord of the earth! Please draw up my chariot betwixt the two armies,', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_22', 'hi', 'Hindi', 'जिससे मैं युद्ध की इच्छा से खड़े इन लोगों का निरीक्षण कर सकूँ कि इस युद्ध में मुझे किनके साथ युद्ध करना है।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_22', 'en', 'English', 'So that I may observe those who must fight on my side, those who must fight against me;', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_23', 'hi', 'Hindi', 'दुर्बुद्धि धार्तराष्ट्र (दुर्योधन) का युद्ध में प्रिय चाहने वाले जो ये राजा लोग यहाँ एकत्र हुए हैं, उन युद्ध करने वालों को मैं देखूँगा।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_23', 'en', 'English', 'And gaze over this array of soldiers, eager to please the sinful sons of Dhritarashtra."', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_24', 'hi', 'Hindi', 'संजय ने कहा -- हे भारत (धृतराष्ट्र) ! अर्जुन के इस प्रकार कहने पर भगवान् हृषीकेश ने दोनों सेनाओं के मध्य उत्तम रथ को खड़ा करके।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_24', 'en', 'English', 'Sanjaya said: "Having listened to the request of Arjuna, Lord Shri Krishna drew up His bright chariot exactly in the midst between the two armies,', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_25', 'hi', 'Hindi', 'भीष्म, द्रोण तथा पृथ्वी के समस्त शासकों के समक्ष उन्होंने कहा, "हे पार्थ यहाँ एकत्र हुये कौरवों को देखो"।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_25', 'en', 'English', 'Whither Bheeshma and Drona had led all the rulers of the earth, and spoke thus: O Arjuna! Behold these members of the family of Kuru assembled.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_26', 'hi', 'Hindi', 'वहाँ अर्जुन ने उन दोनों सेनाओं में खड़े पिता के भाइयों,  पितामहों,  आचार्यों,  मामों, भाइयों, पुत्रों,  पौत्रों,  मित्रों,  श्वसुरों और सुहृदों को भी देखा।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_26', 'en', 'English', 'There Arjuna noticed fathers, grandfathers, uncles, cousins, sons, grandsons, teachers, friends;', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_27', 'hi', 'Hindi', 'इस प्रकार उन सब बन्धु-बान्धवों को खड़े देखकर कुन्ती पुत्र अर्जुन का मन करुणा से भर गया और विषादयुक्त होकर उसने यह कहा।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_27', 'en', 'English', 'Fathers-in-law and benefactors, arrayed on both sides. Arjuna then gazed at all those kinsmen before him.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_28', 'hi', 'Hindi', '।।1.28 1.29।।अर्जुन ने कहा -- हे कृष्ण ! युद्ध की इच्छा रखकर उपस्थित हुए इन स्वजनों को देखकर मेरे अंग शिथिल हुये जाते हैं, मुख भी सूख रहा है और मेरे शरीर में कम्प तथा रोमांच हो रहा है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_28', 'en', 'English', 'And his heart melted with pity and sadly he spoke: O my Lord! When I see all these, my own people, thirsting for battle,', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_29', 'hi', 'Hindi', '।।1.28 1.29।।अर्जुन ने कहा -- हे कृष्ण !  युद्ध की इच्छा रखकर उपस्थित हुए इन स्वजनों को देखकर मेरे अंग शिथिल हुये जाते हैं,  मुख भी सूख रहा है और मेरे शरीर में कम्प तथा रोमांच हो रहा है।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_29', 'en', 'English', 'My limbs fail me and my throat is parched, my body trembles and my hair stands on end.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_30', 'hi', 'Hindi', 'मेरे हाथ से गाण्डीव (धनुष) गिर रहा है और त्वचा जल रही है। मेरा मन भ्रमित सा हो रहा है,  और मैं खड़े रहने में असमर्थ हूँ।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_30', 'en', 'English', 'The bow Gandeeva slips from my hand, and my skin burns. I cannot keep quiet, for my mind is in tumult.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_31', 'hi', 'Hindi', 'हे केशव ! मैं शकुनों को भी विपरीत ही देख रहा हूँ और युद्ध में (आहवे) अपने स्वजनों को मारकर कोई कल्याण भी नहीं देखता हूँ।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_31', 'en', 'English', 'The omens are adverse; what good can come from the slaughter of my people on this battlefield?', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_32', 'hi', 'Hindi', 'हे कृष्ण ! मैं न विजय चाहता हूँ, न राज्य और न सुखों को ही चाहता हूँ। हे गोविन्द ! हमें राज्य से अथवा भोगों से और जीने से भी क्या प्रयोजन है?।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_32', 'en', 'English', 'Ah my Lord! I crave not for victory, nor for the kingdom, nor for any pleasure. What were a kingdom or happiness or life to me,', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_33', 'hi', 'Hindi', 'हमें जिनके लिये राज्य,  भोग और सुखादि की इच्छा है,  वे ही लोग धन और जीवन की आशा को त्यागकर युद्ध में खड़े हैं।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_33', 'en', 'English', 'When those for whose sake I desire these things stand here about to sacrifice their property and their lives:', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_34', 'hi', 'Hindi', 'वे लोग गुरुजन,  ताऊ,  चाचा,  पुत्र,  पितामह,   श्वसुर,  पोते,  श्यालक तथा अन्य सम्बन्धी हैं।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_34', 'en', 'English', 'Teachers, fathers and grandfathers, sons and grandsons, uncles, father-in-law, brothers-in-law and other relatives.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_35', 'hi', 'Hindi', 'हे मधुसूदन !  इनके मुझे मारने पर अथवा त्रैलोक्य के राज्य के लिये भी मैं इनको मारना नहीं चाहता,  फिर पृथ्वी के लिए कहना ही क्या है।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_35', 'en', 'English', 'I would not kill them, even for three worlds; why then for this poor earth? It matters not if I myself am killed.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_36', 'hi', 'Hindi', 'हे जनार्दन ! धृतराष्ट्र के पुत्रों की हत्या करके हमें क्या प्रसन्नता होगी?  इन आततायियों को मारकर तो हमें केवल पाप ही लगेगा।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_36', 'en', 'English', 'My Lord! What happiness can come from the death of these sons of Dhritarashtra? We shall sin if we kill these desperate men.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_37', 'hi', 'Hindi', 'हे माधव  !  इसलिये अपने बान्धव धृतराष्ट्र के पुत्रों को मारना हमारे लिए योग्य नहीं है,  क्योंकि स्वजनों को मारकर हम कैसे सुखी होंगे।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_37', 'en', 'English', 'We are worthy of a nobler feat than to slaughter our relatives - the sons of Dhritarashtra; for, my Lord, how can we be happy of we kill our kinsmen?', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_38', 'hi', 'Hindi', 'यद्यपि लोभ से भ्रष्टचित्त हुये ये लोग कुलनाशकृत दोष और मित्र द्रोह में पाप नहीं देखते हैं।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_38', 'en', 'English', 'Although these men, blinded by greed, see no guilt in destroying their kin, or fighting against their friends,', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_39', 'hi', 'Hindi', 'परन्तु,  हेे जनार्दन !  कुलक्षय से होने वाले दोष को जानने वाले हम लोगों को इस पाप से विरत होने के लिए क्यों नहीं सोचना चाहिये।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_39', 'en', 'English', 'Should not we, whose eyes are open, who consider it to be wrong to annihilate our house, turn away from so great a crime?', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_40', 'hi', 'Hindi', 'कुल के नष्ट होने से सनातन धर्म नष्ट हो जाते हैं। धर्म नष्ट होने पर सम्पूर्ण कुल को अधर्म (पाप) दबा लेता है।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_40', 'en', 'English', 'The destruction of our kindred means the destruction of the traditions of our ancient lineage, and when these are lost, irreligion will overrun our homes.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_41', 'hi', 'Hindi', 'हे कृष्ण ! पाप के अधिक बढ़ जाने से कुल की स्त्रियां दूषित हो जाती हैं,  और हे वार्ष्णेय ! स्त्रियों के दूषित होने पर वर्णसंकर उत्पन्न होता है।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_41', 'en', 'English', 'When irreligion spreads, the women of the house begin to stray; when they lose their purity, adulteration of the stock follows.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_42', 'hi', 'Hindi', 'वह वर्णसंकर कुलघातियों को और कुल को नरक में ले जाने का कारण बनता है। पिण्ड और जलदान की क्रिया से वंचित इनके पितर भी नरक में गिर जाते हैं।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_42', 'en', 'English', 'Promiscuity ruins both the family and those who defile it; while the souls of our ancestors droop, through lack of the funeral cakes and ablutions.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_43', 'hi', 'Hindi', 'इन वर्णसंकर कारक दोषों से कुलघाती दोषों से सनातन कुलधर्म और जातिधर्म नष्ट हो जाते हैं।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_43', 'en', 'English', 'By the destruction of our lineage and the pollution of blood, ancient class traditions and family purity alike perish.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_44', 'hi', 'Hindi', 'हे जनार्दन !  हमने सुना है कि जिनके यहां कुल धर्म नष्ट हो जाता है,  उन मनुष्यों का अनियत काल तक नरक में वास होता है।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_44', 'en', 'English', 'The wise say, my Lord, that they are forever lost, whose ancient traditions are lost.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_45', 'hi', 'Hindi', 'अहो  !  शोक है कि हम लोग बड़ा भारी पाप करने का निश्चय कर बैठे हैं,  जो कि इस राज्यसुख के लोभ से अपने कुटुम्ब का नाश करने के लिये तैयार हो गये हैं।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_45', 'en', 'English', 'Alas, it is strange that we should be willing to kill our own countrymen and commit a great sin, in order to enjoy the pleasures of a kingdom.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_46', 'hi', 'Hindi', 'यदि मुझ शस्त्ररहित और प्रतिकार न करने वाले को ये शस्त्रधारी कौरव रण में मारें,  तो भी वह मेरे लिये कल्याणकारक होगा।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_46', 'en', 'English', 'If, on the contrary, the sons of Dhritarashtra, with weapons in their hand, should slay me, unarmed and unresisting, surely that would be better for my welfare!"', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_1_47', 'hi', 'Hindi', 'संजय ने कहा  --  रणभूमि (संख्ये) में शोक से उद्विग्न मनवाला अर्जुन इस प्रकार कहकर बाणसहित धनुष को त्याग कर रथ के पिछले भाग में बैठ गया।', FALSE, 'Swami Tejomayananda'),
  ('bg_1_47', 'en', 'English', 'Sanjaya said: "Having spoken thus, in the midst of the armies, Arjuna sank on the seat of the chariot, casting away his bow and arrow; heartbroken with grief."', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_1', 'hi', 'Hindi', 'संजय ने कहा -- इस प्रकार करुणा और विषाद से अभिभूत,  अश्रुपूरित नेत्रों वाले आकुल अर्जुन से मधुसूदन ने यह वाक्य कहा।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_1', 'en', 'English', 'Sanjaya then told how the Lord Shri Krishna, seeing Arjuna overwhelmed with compassion, his eyes dimmed with flowing tears and full of despondency, consoled him:', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_2', 'hi', 'Hindi', 'श्री भगवान् ने कहा -- हे अर्जुन ! तुमको इस विषम स्थल में यह मोह कहाँ से उत्पन्न हुआ?  यह आर्य आचरण के विपरीत न तो स्वर्ग प्राप्ति का साधन ही है और न कीर्ति कराने वाला ही है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_2', 'en', 'English', '"The Lord said: My beloved friend! Why yield, just on the eve of battle, to this weakness which does no credit to those who call themselves Aryans, and only brings them infamy and bars against them the gates of heaven?', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_3', 'hi', 'Hindi', 'हे पार्थ क्लीव (कायर) मत बनो। यह तुम्हारे लिये अशोभनीय है, हे ! परंतप हृदय की क्षुद्र दुर्बलता को त्यागकर खड़े हो जाओ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_3', 'en', 'English', 'O Arjuna! Why give way to unmanliness? O thou who art the terror of thine enemies! Shake off such shameful effeminacy, make ready to act!', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_4', 'hi', 'Hindi', 'अर्जुन ने कहा -- हे मधुसूदन ! मैं रणभूमि में किस प्रकार भीष्म और द्रोण के साथ बाणों से युद्ध करूँगा। हे अरिसूदन, वे दोनों ही पूजनीय हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_4', 'en', 'English', 'Arjuna argued: My Lord! How can I, when the battle rages, send an arrow through Bheeshma and Drona, who should receive my reverence?', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_5', 'hi', 'Hindi', 'इन महानुभाव गुरुजनों को मारने से इस लोक में भिक्षा का अन्न भी ग्रहण करना अधिक कल्याण कारक है, क्योंकि गुरुजनों को मारकर मैं इस लोक में रक्तरंजित अर्थ और काम रूप भोगों को ही भोगूँगा।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_5', 'en', 'English', 'Rather would I content myself with a beggar''s crust that kill these teachers of mine, these precious noble souls! To slay these masters who are my benefactors would be to stain the sweetness of life''s pleasures with their blood.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_6', 'hi', 'Hindi', 'हम नहीं जानते कि हमें क्या करना उचित है। हम यह भी नहीं जानते कि हम जीतेंगे, या वे हमको जीतेंगे, जिनको मारकर हम जीवित नहीं रहना चाहते वे ही धृतराष्ट्र के पुत्र हमारे सामने युद्ध के लिए खड़े हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_6', 'en', 'English', 'Nor can I say whether it were better that they conquer me or for me to conquer them, since would no longer care to live if I killed these sons of Dhritarashtra, now preparing for fight.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_7', 'hi', 'Hindi', 'करुणा के कलुष से अभिभूत और कर्तव्यपथ पर संभ्रमित हुआ मैं आपसे पूछता हूँ, कि मेरे लिये जो श्रेयष्कर हो, उसे आप निश्चय करके कहिये, क्योंकि मैं आपका शिष्य हूँ; शरण में आये मुझको आप उपदेश दीजिये।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_7', 'en', 'English', 'My heart is oppressed with pity; and my mind confused as to what my duty is. Therefore, my Lord, tell me what is best for my spiritual welfare, for I am Thy disciple. Please direct me, I pray.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_8', 'hi', 'Hindi', 'पृथ्वी पर निष्कण्टक समृद्ध राज्य को और देवताओं के स्वामित्व को प्राप्त होकर भी मैं उस उपाय को नहीं देखता हूँ, जो मेरी इन्द्रियों को सुखाने वाले इस शोक को दूर कर सके।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_8', 'en', 'English', 'For should I attain the monarchy of the visible world, or over the invisible world, it would not drive away the anguish which is now paralysing my senses."', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_9', 'hi', 'Hindi', 'संजय ने कहा -- इस प्रकार गुडाकेश परंतप अर्जुन भगवान् हृषीकेश से यह कहकर कि हे गोविन्द "मैं युद्ध नहीं करूँगा" चुप हो गया।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_9', 'en', 'English', 'Sanjaya continued: "Arjuna, the conqueror of all enemies, then told the Lord of All-Hearts that he would no fight, and became silent, O King!', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_10', 'hi', 'Hindi', 'हे भारत (धृतराष्ट्र) ! दोनों सेनाओं के बीच में उस शोकमग्न अर्जुन को भगवान् हृषीकेश ने हँसते हुए से यह वचन कहे।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_10', 'en', 'English', 'Thereupon the Lord, with a gracious smile, addressed him who was so much depressed in the midst of the two armies.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_11', 'hi', 'Hindi', 'श्री भगवान् ने कहा -- (अशोच्यान्) जिनके लिये शोक करना उचित नहीं है, उनके लिये तुम शोक करते हो और ज्ञानियों के से वचनों को कहते हो, परन्तु ज्ञानी पुरुष मृत (गतासून्) और जीवित (अगतासून्) दोनों के लिये शोक नहीं करते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_11', 'en', 'English', 'Lord Shri Krishna said: Why grieve for those for whom no grief is due, and yet profess wisdom? The wise grieve neither for the dead nor the living.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_12', 'hi', 'Hindi', 'वास्तव में न तो ऐसा ही है कि मैं किसी काल में नहीं था अथवा तुम नहीं थे अथवा ये राजालोग नहीं थे और न ऐसा ही है कि इससे आगे हम सब नहीं रहेंगे।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_12', 'en', 'English', 'There was never a time when I was not, nor thou, nor these princes were not; there will never be a time when we shall cease to be.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_13', 'hi', 'Hindi', 'जैसे इस देह में देही जीवात्मा की कुमार, युवा और वृद्धावस्था होती है, वैसे ही उसको अन्य शरीर की प्राप्ति होती है;  धीर पुरुष इसमें मोहित नहीं होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_13', 'en', 'English', 'As the soul experiences in this body infancy, youth and old age, so finally it passes into another. The wise have no delusion about this.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_14', 'hi', 'Hindi', 'हे कुन्तीपुत्र ! शीत और उष्ण और सुख दुख को देने वाले इन्द्रिय और विषयों के संयोग का प्रारम्भ और अन्त होता है;  वे अनित्य हैं,  इसलिए,  हे भारत ! उनको तुम सहन करो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_14', 'en', 'English', 'Those external relations which bring cold and heat, pain and happiness, they come and go; they are not permanent. Endure them bravely, O Prince!', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_15', 'hi', 'Hindi', 'हे पुरुषश्रेष्ठ ! दुख और सुख में समान भाव से रहने वाले जिस धीर पुरुष को ये व्यथित नहीं कर सकते हैं वह अमृतत्व (मोक्ष) का अधिकारी होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_15', 'en', 'English', 'The hero whose soul is unmoved by circumstance, who accepts pleasure and pain with equanimity, only he is fit for immortality.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_16', 'hi', 'Hindi', 'असत् वस्तु का तो अस्तित्व नहीं है और सत् का कभी अभाव नहीं है। इस प्रकार इन दोनों का ही तत्त्व,  तत्त्वदर्शी ज्ञानी पुरुषों के द्वारा देखा गया है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_16', 'en', 'English', 'That which is not, shall never be; that which is, shall never cease to be. To the wise, these truths are self-evident.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_17', 'hi', 'Hindi', 'उस वस्तु को तुम अविनाशी जानों,  जिससे यह सम्पूर्ण जगत् व्याप्त है। इस अव्यय का नाश करने में कोई भी समर्थ नहीं है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_17', 'en', 'English', 'The Spirit, which pervades all that we see, is imperishable. Nothing can destroy the Spirit.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_18', 'hi', 'Hindi', 'इस नाशरहित अप्रमेय नित्य देही आत्मा के ये सब शरीर नाशवान् कहे गये हैं। इसलिये हे भारत ! तुम युद्ध करो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_18', 'en', 'English', 'The material bodies which this Eternal, Indestructible, Immeasurable Spirit inhabits are all finite. Therefore fight, O Valiant Man!', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_19', 'hi', 'Hindi', 'जो इस आत्मा को मारने वाला समझता है और जो इसको मरा समझता है वे दोनों ही नहीं जानते हैं,  क्योंकि यह आत्मा न मरता है और न मारा जाता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_19', 'en', 'English', 'He who thinks that the Spirit kills, and he who thinks of It as killed, are both ignorant. The Spirit kills not, nor is It killed.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_20', 'hi', 'Hindi', 'यह आत्मा किसी काल में भी न जन्मता है और न मरता है और न यह एक बार होकर फिर अभावरूप होने वाला है। यह आत्मा अजन्मा, नित्य, शाश्वत और पुरातन है,  शरीर के नाश होने पर भी इसका नाश नहीं होता।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_20', 'en', 'English', 'It was not born; It will never die, nor once having been, can It cease to be. Unborn, Eternal, Ever-enduring, yet Most Ancient, the Spirit dies not when the body is dead.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_21', 'hi', 'Hindi', 'हे पार्थ ! जो पुरुष इस आत्मा को अविनाशी,  नित्य और अव्ययस्वरूप जानता है,  वह कैसे किसको मरवायेगा और कैसे किसको मारेगा?', FALSE, 'Swami Tejomayananda'),
  ('bg_2_21', 'en', 'English', 'He who knows the Spirit as Indestructible, Immortal, Unborn, Always-the-Same, how should he kill or cause to be killed?', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_22', 'hi', 'Hindi', 'जैसे मनुष्य जीर्ण वस्त्रों को त्यागकर दूसरे नये वस्त्रों को धारण करता है, वैसे ही देही जीवात्मा पुराने शरीरों को त्याग कर दूसरे नए शरीरों को प्राप्त होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_22', 'en', 'English', 'As a man discards his threadbare robes and puts on new, so the Spirit throws off Its worn-out bodies and takes fresh ones.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_23', 'hi', 'Hindi', 'इस आत्मा को शस्त्र काट नहीं सकते और न अग्नि इसे जला सकती है ; जल इसे गीला नहीं कर सकता और वायु इसे सुखा नहीं सकती।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_23', 'en', 'English', 'Weapons cleave It not, fire burns It not, water drenches It not, and wind dries It not.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_24', 'hi', 'Hindi', 'क्योंकि यह आत्मा अच्छेद्य (काटी नहीं जा सकती),  अदाह्य (जलाई नहीं जा सकती),  अक्लेद्य (गीली नहीं हो सकती ) और अशोष्य (सुखाई नहीं जा सकती) है;  यह नित्य,  सर्वगत,  स्थाणु (स्थिर),  अचल और सनातन है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_24', 'en', 'English', 'It is impenetrable; It can be neither drowned nor scorched nor dried. It is Eternal, All-pervading, Unchanging, Immovable and Most Ancient.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_25', 'hi', 'Hindi', 'यह आत्मा अव्यक्त,  अचिन्त्य और अविकारी कहा जाता है;  इसलिए इसको इस प्रकार जानकर तुमको शोक करना उचित नहीं है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_25', 'en', 'English', 'It is named the Unmanifest, the Unthinkable, the immutable. Wherefore, knowing the Spirit as such, thou hast no cause to grieve.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_26', 'hi', 'Hindi', 'और यदि तुम आत्मा को नित्य जन्मने और नित्य मरने वाला मानो तो भी,  हे महाबाहो !  इस प्रकार शोक करना तुम्हारे लिए उचित नहीं है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_26', 'en', 'English', 'Even if thou thinkest of It as constantly being born, constantly dying, even then, O Mighty Man, thou still hast no cause to grieve.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_27', 'hi', 'Hindi', 'जन्मने वाले की मृत्यु निश्चित है और मरने वाले का जन्म निश्चित है;  इसलिए जो अटल है अपरिहार्य - है उसके विषय में तुमको शोक नहीं करना चाहिये।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_27', 'en', 'English', 'For death is as sure for that which is born, as birth is for that which is dead. Therefore grieve not for what is inevitable.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_28', 'hi', 'Hindi', 'हे भारत ! समस्त प्राणी जन्म से पूर्व और मृत्यु के बाद अव्यक्त अवस्था में रहते हैं और बीच में व्यक्त होते हैं। फिर उसमें चिन्ता या शोक की क्या बात है ?', FALSE, 'Swami Tejomayananda'),
  ('bg_2_28', 'en', 'English', 'The end and the beginning of beings are unknown. We see only the intervening formations. Then what cause is there for grief?', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_29', 'hi', 'Hindi', 'कोई इसे आश्चर्य के समान देखता है;  कोई इसके विषय में आश्चर्य के समान कहता है;  और कोई अन्य पुरुष इसे आश्चर्य के समान सुनता है;  और फिर कोई सुनकर भी नहीं जानता।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_29', 'en', 'English', 'One hears of the Spirit with surprise, another thinks It marvellous, the third listens without comprehending. Thus, though many are told about It, scarcely is there one who knows It.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_30', 'hi', 'Hindi', 'हे भारत ! यह देही आत्मा सबके शरीर में सदा ही अवध्य है, इसलिए समस्त प्राणियों के लिए तुम्हें शोक करना उचित नहीं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_30', 'en', 'English', 'Be not anxious about these armies. The Spirit in man is imperishable.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_31', 'hi', 'Hindi', 'और स्वधर्म को भी देखकर तुमको विचलित होना उचित नहीं है,  क्योंकि धर्मयुक्त युद्ध से बढ़कर दूसरा कोई कल्याणकारक कर्त्तव्य क्षत्रिय के लिये नहीं है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_31', 'en', 'English', 'Thou must look at thy duty. Nothing can be more welcome to a soldier than a righteous war. Therefore to waver in this resolve is unworthy, O Arjuna!', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_32', 'hi', 'Hindi', 'और हे पार्थ ! अपने आप प्राप्त हुए और स्वर्ग के लिए खुले हुए द्वाररूप इस प्रकार के युद्ध को भाग्यवान क्षत्रिय लोग ही पाते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_32', 'en', 'English', 'Blessed are the soldiers who find their opportunity. This opportunity has opened for thee the gates of heaven.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_33', 'hi', 'Hindi', 'और यदि तुम इस धर्मयुद्ध को स्वीकार नहीं करोगे,  तो स्वधर्म और कीर्ति को खोकर पाप को प्राप्त करोगे।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_33', 'en', 'English', 'Refuse to fight in this righteous cause, and thou wilt be a traitor, lost to fame, incurring only sin.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_34', 'hi', 'Hindi', 'और सब लोग तुम्हारी बहुत काल तक रहने वाली अपकीर्ति को भी कहते रहेंगे;  और सम्मानित पुरुष के लिए अपकीर्ति मरण से भी अधिक होती है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_34', 'en', 'English', 'Men will talk forever of thy disgrace; and to the noble, dishonour is worse than death.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_35', 'hi', 'Hindi', 'और जिनके लिए तुम बहुत माननीय हो उनके लिए अब तुम तुच्छता को प्राप्त होओगे,  वे महारथी लोग तुम्हें भय के कारण युद्ध से निवृत्त हुआ मानेंगे।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_35', 'en', 'English', 'Great generals will think that thou hast fled from the battlefield through cowardice; though once honoured thou wilt seem despicable.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_36', 'hi', 'Hindi', 'तुम्हारे शत्रु तुम्हारे सार्मथ्य की निन्दा करते हुए बहुत से अकथनीय वचनों को कहेंगे,  फिर उससे अधिक दु:ख क्या होगा ?', FALSE, 'Swami Tejomayananda'),
  ('bg_2_36', 'en', 'English', 'Thine enemies will spread scandal and mock at thy courage. Can anything be more humiliating?', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_37', 'hi', 'Hindi', 'युद्ध में मरकर तुम स्वर्ग प्राप्त करोगे या जीतकर पृथ्वी को भोगोगे;  इसलिय, हे कौन्तेय ! युद्ध का निश्चय कर तुम खड़े हो जाओ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_37', 'en', 'English', 'If killed, thou shalt attain Heaven; if victorious, enjoy the kingdom of earth. Therefore arise, O Son of Kunti, and fight!', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_38', 'hi', 'Hindi', 'सुख-दु:ख,  लाभ-हानि और जय-पराजय को समान करके युद्ध के लिये तैयार हो जाओ;  इस प्रकार तुमको पाप नहीं होगा।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_38', 'en', 'English', 'Look upon pleasure and pain, victory and defeat, with an equal eye. Make ready for the combat, and thou shalt commit no sin.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_39', 'hi', 'Hindi', 'हे पार्थ ! तुम्हें सांख्य विषयक ज्ञान कहा गया और अब इस (कर्म) योग से सम्बन्धित ज्ञान को सुनो जिस ज्ञान से युक्त होकर तुम कर्मबन्ध का नाश कर सकोगे।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_39', 'en', 'English', 'I have told thee the philosophy of Knowledge. Now listen and I will explain the philosophy of Action, by means of which, O Arjuna, thou shalt break through the bondage of all action.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_40', 'hi', 'Hindi', 'इसमें क्रमनाश और प्रत्यवाय दोष नहीं है। इस धर्म (योग) का अल्प अभ्यास भी महान् भय से रक्षण करता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_40', 'en', 'English', 'On this Path, endeavour is never wasted, nor can it ever be repressed. Even a very little of its practice protects one from great danger.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_41', 'hi', 'Hindi', 'हे कुरुनन्दन ! इस (विषय) में निश्चयात्मक बुद्धि एक ही है, अज्ञानी पुरुषों की बुद्धियां (संकल्प) बहुत भेदों वाली और अनन्त होती हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_41', 'en', 'English', 'By its means, the straying intellect becomes steadied in the contemplation of one object only; whereas the minds of the irresolute stray into bypaths innumerable.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_42', 'hi', 'Hindi', 'हे पार्थ  अविवेकी पुरुष वेदवाद में रमते हुये जो यह पुष्पिता (दिखावटी शोभा की) वाणी बोलते हैं? इससे (स्वर्ग से) बढ़कर और कुछ नहीं है।।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_42', 'en', 'English', 'Only the ignorant speak in figurative language. It is they who extol the letter of the scriptures, saying, There is nothing deeper than this.''', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_43', 'hi', 'Hindi', 'कामनाओं से युक्त? स्वर्ग को ही श्रेष्ठ मानने वाले लोग भोग और ऐश्वर्य को प्राप्त कराने वाली अनेक क्रियाओं को बताते हैं जो (वास्तव में) जन्मरूप कर्मफल को देने वाली होती हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_43', 'en', 'English', 'Consulting only their own desires, they construct their own heaven, devising arduous and complex rites to secure their own pleasure and their own power; and the only result is rebirth.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_44', 'hi', 'Hindi', 'उससे जिनका चित्त हर लिया गया है ऐसे भोग और एश्र्वर्य‌ मॆ आसक्ति रखने वाले पुरुषों के अन्तकरण मे निश्चयात्मक् बुद्धि नही हॊती अर्थात वे ध्यान का अभ्यास करने योग्य‌ नही होते।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_44', 'en', 'English', 'While their minds are absorbed with ideas of power and personal enjoyment, they cannot concentrate their discrimination on one point.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_45', 'hi', 'Hindi', 'हे अर्जुन  वेदों का विषय तीन गुणों से सम्बन्धित (संसार से) है  तुम त्रिगुणातीत? निर्द्वन्द्व? नित्य सत्त्व (शुद्धता) में स्थित? योगक्षेम से रहित और आत्मवान् बनो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_45', 'en', 'English', 'The Vedic Scriptures tell of the three constituents of life - the Qualities. Rise above all of them, O Arjuna, above all the pairs of opposing sensations; be steady in truth, free from worldly anxieties and centered in the Self.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_46', 'hi', 'Hindi', 'सब ओर से परिपूर्ण जलराशि के होने पर मनुष्य का छोटे जलाशय में जितना प्रयोजन रहता है? आत्मज्ञानी ब्राह्मण का सभी वेदों में उतना ही प्रयोजन रहता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_46', 'en', 'English', 'As a man can drink water from any side of a full tank, so the skilled theologian can wrest from any scripture that which will serve his purpose.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_47', 'hi', 'Hindi', 'कर्म करने मात्र में तुम्हारा अधिकार है? फल में कभी नहीं। तुम कर्मफल के हेतु वाले मत होना और अकर्म में भी तुम्हारी आसक्ति न हो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_47', 'en', 'English', 'But thou hast only the right to work, but none to the fruit thereof. Let not then the fruit of thy action be thy motive; nor yet be thou enamored of inaction.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_48', 'hi', 'Hindi', 'हे धनंजय  आसक्ति को त्याग कर तथा सिद्धि और असिद्धि में समभाव होकर योग में स्थित हुये तुम कर्म करो। यह समभाव ही योग कहलाता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_48', 'en', 'English', 'Perform all thy actions with mind concentrated on the Divine, renouncing attachment and looking upon success and failure with an equal eye. Spirituality implies equanimity.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_49', 'hi', 'Hindi', 'इस बुद्धियोग की तुलना में(सकाम) कर्म अत्यन्त निकृष्ट हैं? इसलिये हे धनंजय  तुम बद्धि की शरण लो फल की इच्छा करनेवाले कृपण (दीन) हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_49', 'en', 'English', 'Physical action is far inferior to an intellect concentrated on the Divine. Have recourse then to Pure Intelligence. It is only the petty-minded who work for reward.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_50', 'hi', 'Hindi', 'समत्वबुद्धि युक्त पुरुष यहां (इस जीवन में) पुण्य और पाप इन दोनों कर्मों को त्याग देता है? इसलिये तुम योग से युक्त हो जाओ। कर्मों में कुशलता योग है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_50', 'en', 'English', 'When a man attains to Pure Reason, he renounces in this world the results of good and evil alike. Cling thou to Right Action. Spirituality is the real art of living.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_51', 'hi', 'Hindi', 'बुद्धियोग युक्त मनीषी लोग कर्मजन्य फलों को त्यागकर जन्मरूप बन्धन से मुक्त हुये अनामय अर्थात् निर्दोष पद को प्राप्त होते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_51', 'en', 'English', 'The sages guided by Pure Intellect renounce the fruit of action; and, freed from the chains of rebirth, they reach the highest bliss.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_52', 'hi', 'Hindi', 'जब तुम्हारी बुद्धि मोहरूप दलदल (कलिल) को तर जायेगी तब तुम उन सब वस्तुओं से निर्वेद (वैराग्य) को प्राप्त हो जाओगे? जो सुनने योग्य और सुनी हुई हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_52', 'en', 'English', 'When thy reason has crossed the entanglements of illusion, then shalt thou become indifferent both to the philosophies thou hast heard and to those thou mayest yet hear.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_53', 'hi', 'Hindi', 'जब अनेक प्रकार के विषयों को सुनने से विचलित हुई तुम्हारी बुद्धि आत्मस्वरूप में अचल और स्थिर हो जायेगी तब तुम (परमार्थ) योग को प्राप्त करोगे।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_53', 'en', 'English', 'When the intellect, bewildered by the multiplicity of holy scripts, stands unperturbed in blissful contemplation of the Infinite, then hast thou attained Spirituality.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_54', 'hi', 'Hindi', 'अर्जुन ने कहा -- हे केशव  समाधि में स्थित स्थिर बुद्धि वाले पुरुष का क्या लक्षण है स्थिर बुद्धि पुरुष कैसे बोलता है कैसे बैठता है  कैसे चलता है', FALSE, 'Swami Tejomayananda'),
  ('bg_2_54', 'en', 'English', 'Arjuna asked: My Lord! How can we recognise the saint who has attained Pure Intellect, who has reached this state of Bliss, and whose mind is steady? how does he talk, how does he live, and how does he act?', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_55', 'hi', 'Hindi', 'श्री भगवान् ने कहा -- हे पार्थ? जिस समय पुरुष मन में स्थित सब कामनाओं को त्याग देता है और आत्मा से ही आत्मा में सन्तुष्ट रहता है? उस समय वह स्थितप्रज्ञ कहलाता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_55', 'en', 'English', 'Lord Shri Krishna replied: When a man has given up the desires of his heart and is satisfied with the Self alone, be sure that he has reached the highest state.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_56', 'hi', 'Hindi', 'दुख में जिसका मन उद्विग्न नहीं होता सुख में जिसकी स्पृहा निवृत्त हो गयी है? जिसके मन से राग? भय और क्रोध नष्ट हो गये हैं? वह मुनि स्थितप्रज्ञ कहलाता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_56', 'en', 'English', 'The sage, whose mind is unruffled in suffering, whose desire is not roused by enjoyment, who is without attachment, anger or fear - take him to be one who stands at that lofty level.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_57', 'hi', 'Hindi', 'जो सर्वत्र अति स्नेह से रहित हुआ उन शुभ तथा अशुभ वस्तुओं को प्राप्त कर न प्रसन्न होता है और न द्वेष करता है? उसकी प्रज्ञा प्रतिष्ठित (स्थिर) है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_57', 'en', 'English', 'He who wherever he goes is attached to no person and to no place by ties of flesh; who accepts good and evil alike, neither welcoming the one nor shrinking from the other - take him to be one who is merged in the Infinite.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_58', 'hi', 'Hindi', 'कछुवा अपने अंगों को जैसे समेट लेता है वैसे ही यह पुरुष जब सब ओर से अपनी इन्द्रियों को इन्द्रियों के विषयों से परावृत्त कर लेता है? तब उसकी बुद्धि स्थिर होती है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_58', 'en', 'English', 'He who can withdraw his senses from the attraction of their objects, as the tortoise draws his limbs within its shell - take it that such a one has attained Perfection.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_59', 'hi', 'Hindi', 'निराहारी देही पुरुष से विषय तो निवृत्त (दूर) हो जाते हैं? परन्तु (उनके प्रति) राग नहीं  परम तत्व को देखने पर इस (पुरुष) का राग भी निवृत्त हो जाता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_59', 'en', 'English', 'The objects of sense turn from him who is abstemious. Even the relish for them is lost in him who has seen the Truth.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_60', 'hi', 'Hindi', 'हे कौन्तेय  (संयम का) प्रयत्न करते हुए बुद्धिमान (विपश्चित) पुरुष के भी मन को ये इन्द्रियां बलपूर्वक हर लेती हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_60', 'en', 'English', 'O Arjuna! The mind of him, who is trying to conquer it, is forcibly carried away in spite of his efforts, by his tumultuous senses.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_61', 'hi', 'Hindi', 'उन सब इन्द्रियों को संयमित कर युक्त और मत्पर होवे। जिस पुरुष की इन्द्रियां वश में होती हैं? उसकी प्रज्ञा प्रतिष्ठित होती है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_61', 'en', 'English', 'Restraining them all, let him meditate steadfastly on Me; for who thus conquers his senses achieves perfection.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_62', 'hi', 'Hindi', 'विषयों का चिन्तन करने वाले पुरुष की उसमें आसक्ति हो जाती है? आसक्ति से इच्छा और इच्छा से क्रोध उत्पन्न होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_62', 'en', 'English', 'When a man dwells on the objects of sense, he creates an attraction for them; attraction develops into desire, and desire breeds anger.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_63', 'hi', 'Hindi', 'क्रोध से उत्पन्न होता है मोह और मोह से स्मृति विभ्रम। स्मृति के भ्रमित होने पर बुद्धि का नाश होता है और बुद्धि के नाश होने से वह मनुष्य नष्ट हो जाता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_63', 'en', 'English', 'Anger induces delusion; delusion, loss of memory; through loss of memory, reason is shattered; and loss of reason leads to destruction.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_64', 'hi', 'Hindi', 'आत्मसंयमी (विधेयात्मा) पुरुष रागद्वेष से रहित अपने वश में की हुई (आत्मवश्यै) इन्द्रियों द्वारा विषयों को भोगता हुआ प्रसन्नता (प्रस्ेााद) प्राप्त करता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_64', 'en', 'English', 'But the self-controlled soul, who moves amongst sense objects, free from either attachment or repulsion, he wins eternal Peace.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_65', 'hi', 'Hindi', 'प्रसाद के होने पर सम्पूर्ण दुखों का अन्त हो जाता है और प्रसन्नचित्त पुरुष की बुद्धि ही शीघ्र ही स्थिर हो जाती है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_65', 'en', 'English', 'Having attained Peace, he becomes free from misery; for when the mind gains peace, right discrimination follows.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_66', 'hi', 'Hindi', '(संयमरहित) अयुक्त पुरुष को (आत्म) ज्ञान नहीं होता और अयुक्त को भावना और ध्यान की क्षमता नहीं होती भावना रहित पुरुष को शान्ति नहीं मिलती अशान्त पुरुष को सुख कहाँ', FALSE, 'Swami Tejomayananda'),
  ('bg_2_66', 'en', 'English', 'Right discrimination is not for him who cannot concentrate. Without concentration, there cannot be meditation; he who cannot meditate must not expect peace; and without peace, how can anyone expect happiness?', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_67', 'hi', 'Hindi', 'जल में वायु जैसे नाव को हर लेता है वैसे ही विषयों में विरचती हुई इन्द्रियों के बीच में जिस इन्द्रिय का अनुकरण मन करता है? वह एक ही इन्द्रिय इसकी प्रज्ञा को हर लेती है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_67', 'en', 'English', 'As a ship at sea is tossed by the tempest, so the reason is carried away by the mind when preyed upon by straying senses.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_68', 'hi', 'Hindi', 'इसलिये? हे महाबाहो  जिस पुरुष की इन्द्रियाँ सब प्रकार इन्द्रियों के विषयों के वश में की हुई होती हैं? उसकी बुद्धि स्थिर होती है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_68', 'en', 'English', 'Therefore, O Might-in-Arms, he who keeps his senses detached from their objects - take it that his reason is purified.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_69', 'hi', 'Hindi', 'सब प्रणियों के लिए जो रात्रि है? उसमें संयमी पुरुष जागता है और जहाँ सब प्राणी जागते हैं? वह (तत्त्व को) देखने वाले मुनि के लिए रात्रि है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_69', 'en', 'English', 'The saint is awake when the world sleeps, and he ignores that for which the world lives.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_70', 'hi', 'Hindi', 'जैसे सब ओर से परिपूर्ण अचल प्रतिष्ठा वाले समुद्र में (अनेक नदियों के) जल (उसे विचलित किये बिना) समा जाते हैं? वैसे ही जिस पुरुष के प्रति कामनाओं के विषय उसमें (विकार उत्पन्न किये बिना) समा जाते हैं? वह पुरुष शान्ति प्राप्त करता है? न कि भोगों की कामना करने वाला पुरुष।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_70', 'en', 'English', 'He attains Peace, into whom desires flow as rivers into the ocean, which though brimming with water remains ever the same; not he whom desire carries away.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_71', 'hi', 'Hindi', 'जो पुरुष सब कामनाओं को त्यागकर स्पृहारहित? ममभाव रहित और निरहंकार हुआ विचरण करता है? वह शान्ति प्राप्त करता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_71', 'en', 'English', 'He attains Peace who, giving up desire, moves through the world without aspiration, possessing nothing which he can call his own, and free from pride.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_2_72', 'hi', 'Hindi', 'हे पार्थ  यह ब्राह्मी स्थिति है। इसे प्राप्त कर पुरुष मोहित नहीं होता। अन्तकाल में भी इस निष्ठा में स्थित होकर ब्रह्मनिर्वाण (ब्रह्म के साथ एकत्व) को प्राप्त होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_2_72', 'en', 'English', 'O Arjuna! This is the state of the Self, the Supreme Spirit, to which if a man once attain, it shall never be taken from him. Even at the time of leaving the body, he will remain firmly enthroned there, and will become one with the Eternal."', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_1', 'hi', 'Hindi', 'हे जनार्दन  यदि आपको यह मान्य है कि कर्म से ज्ञान श्रेष्ठ है तो फिर हे केशव  आप मुझे इस भयंकर कर्म में क्यों प्रवृत्त करते हैं', FALSE, 'Swami Tejomayananda'),
  ('bg_3_1', 'en', 'English', '"Arjuna questioned: My Lord! If Wisdom is above action, why dost Thou advise me to engage in this terrible fight?', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_2', 'hi', 'Hindi', 'आप इस मिश्रित वाक्य से मेरी बुद्धि को मोहितसा करते हैं अत आप उस एक (मार्ग) को निश्चित रूप से कहिये जिससे मैं परम श्रेय को प्राप्त कर सकूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_3_2', 'en', 'English', 'Thy language perplexes me and confuses my reason. Therefore please tell me the only way by which I may, without doubt, secure my spiritual welfare.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_3', 'hi', 'Hindi', 'श्री भगवान् ने कहा  हे निष्पाप (अनघ) अर्जुन  इस श्लोक में दो प्रकार की निष्ठा मेरे द्वारा पहले कही गयी है ज्ञानियों की (सांख्यानां) ज्ञानयोग से और योगियों की कर्मयोग से।।', FALSE, 'Swami Tejomayananda'),
  ('bg_3_3', 'en', 'English', 'Lord Shri Krishna replied: In this world, as I have said, there is a twofold path, O Sinless One! There is the Path of Wisdom for those who meditate, and the Path of Action for those who work.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_4', 'hi', 'Hindi', 'कर्मों के न करने से मनुष्य नैर्ष्कम्य को प्राप्त नहीं होता और न कर्मों के संन्यास से ही वह सिद्धि (पूर्णत्व) प्राप्त करता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_3_4', 'en', 'English', 'No man can attain freedom from activity by refraining from action; nor can he reach perfection by merely refusing to act.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_5', 'hi', 'Hindi', 'कोई भी पुरुष कभी क्षणमात्र भी बिना कर्म किए नहीं रह सकता क्योंकि प्रकृति से उत्पन्न गुणों के द्वारा अवश हुए सब (पुरुषों) से कर्म करवा लिया जाता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_3_5', 'en', 'English', 'He cannot even for a moment remain really inactive, for the Qualities of Nature will compel him to act whether he will or no.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_6', 'hi', 'Hindi', 'जो मूढ बुद्धि पुरुष कर्मेन्द्रियों का निग्रह कर इन्द्रियों के भोगों का मन से स्मरण (चिन्तन) करता रहता है वह मिथ्याचारी (दम्भी) कहा जाता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_3_6', 'en', 'English', 'He who remains motionless, refusing to act, but all the while brooding over sensuous object, that deluded soul is simply a hypocrite.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_7', 'hi', 'Hindi', 'परन्तु हे अर्जुन  जो पुरुष मन से इन्द्रियों को वश में करके अनासक्त हुआ कर्मेंन्द्रियों से कर्मयोग का आचरण करता है वह श्रेष्ठ है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_3_7', 'en', 'English', 'But, O Arjuna! All honour to him whose mind controls his senses, for he is thereby beginning to practise Karma-Yoga, the Path of Right Action, keeping himself always unattached.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_8', 'hi', 'Hindi', 'तुम (अपने) नियत (कर्तव्य) कर्म करो क्योंकि अकर्म से श्रेष्ठ कर्म है। तुम्हारे अकर्म होने से (तुम्हारा) शरीर निर्वाह भी नहीं सिद्ध होगा।।', FALSE, 'Swami Tejomayananda'),
  ('bg_3_8', 'en', 'English', 'Do thy duty as prescribed, for action for duty''s sake is superior to inaction. Even the maintenance of the body would be impossible if man remained inactive.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_9', 'hi', 'Hindi', 'यज्ञ के लिये किये हुए कर्म के अतिरिक्त अन्य कर्म में प्रवृत्त हुआ यह पुरुष कर्मों द्वारा बंधता है इसलिए हे कौन्तेय आसक्ति को त्यागकर यज्ञ के निमित्त ही कर्म का सम्यक् आचरण करो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_3_9', 'en', 'English', 'In this world people are fettered by action, unless it is performed as a sacrifice. Therefore, O Arjuna, let thy acts be done without attachment, as sacrifice only.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_10', 'hi', 'Hindi', 'प्रजापति (सृष्टिकर्त्ता) ने (सृष्टि के) आदि में यज्ञ सहित प्रजा का निर्माण कर कहा इस यज्ञ द्वारा तुम वृद्धि को प्राप्त हो और यह यज्ञ तुम्हारे लिये इच्छित कामनाओं को पूर्ण करने वाला (इष्टकामधुक्) होवे।।', FALSE, 'Swami Tejomayananda'),
  ('bg_3_10', 'en', 'English', 'In the beginning, when God created all beings by the sacrifice of Himself, He said unto them: Through sacrifice you can procreate, and it shall satisfy all your desires.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_11', 'hi', 'Hindi', 'तुम लोग इस यज्ञ द्वारा देवताओं की उन्नति करो और वे देवतागण तुम्हारी उन्नति करें। इस प्रकार परस्पर उन्नति करते हुये परम श्रेय को तुम प्राप्त होगे।।', FALSE, 'Swami Tejomayananda'),
  ('bg_3_11', 'en', 'English', 'Worship the Powers of Nature thereby, and let them nourish you in return; thus supporting each other, you shall attain your highest welfare.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_12', 'hi', 'Hindi', 'यज्ञ द्वारा पोषित देवतागण तुम्हें इष्ट भोग प्रदान करेंगे। उनके द्वारा दिये हुये भोगों को जो पुरुष उनको दिये बिना ही भोगता है वह निश्चय ही चोर है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_3_12', 'en', 'English', 'For, fed, on sacrifice, nature will give you all the enjoyment you can desire. But he who enjoys what she gives without returning is, indeed, a robber.''', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_13', 'hi', 'Hindi', 'यज्ञ के अवशिष्ट अन्न को खाने वाले श्रेष्ठ पुरुष सब पापों से मुक्त हो जाते हैं किन्तु जो लोग केवल स्वयं के लिये ही पकाते हैं वे तो पापों को ही खाते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_3_13', 'en', 'English', 'The sages who enjoy the food that remains after the sacrifice is made are freed from all sin; but the selfish who spread their feast only for themselves feed on sin only.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_14', 'hi', 'Hindi', 'समस्त प्राणी अन्न से उत्पन्न होते हैं अन्न की उत्पत्ति पर्जन्य से। पर्जन्य की उत्पत्ति यज्ञ से और यज्ञ कर्मों से उत्पन्न होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_3_14', 'en', 'English', 'All creatures are the product of food, food is the product of rain, rain comes by sacrifice, and sacrifice is the noblest form of action.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_15', 'hi', 'Hindi', 'कर्म की उत्पत्ति ब्रह्माजी से होती है और ब्रह्माजी अक्षर तत्त्व से व्यक्त होते हैं। इसलिये सर्व व्यापी ब्रह्म सदा ही यज्ञ में प्रतिष्ठित है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_3_15', 'en', 'English', 'All action originates in the Supreme Spirit, which is Imperishable, and in sacrificial action the all-pervading Spirit is consciously present.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_16', 'hi', 'Hindi', 'जो पुरुष यहाँ इस प्रकार प्रवर्तित हुए चक्र का अनुवर्तन नहीं करता हे पार्थ इंन्द्रियों में रमने वाला वह पाप आयु पुरुष व्यर्थ ही जीता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_3_16', 'en', 'English', 'Thus he who does not help the revolving wheel of sacrifice, but instead leads a sinful life, rejoicing in the gratification of his senses, O Arjuna, he breathes in vain.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_17', 'hi', 'Hindi', 'परन्तु जो मनुष्य आत्मा में ही रमने वाला आत्मा में ही तृप्त तथा आत्मा में ही सन्तुष्ट हो उसके लिये कोई कर्तव्य नहीं रहता।।', FALSE, 'Swami Tejomayananda'),
  ('bg_3_17', 'en', 'English', 'On the other hand, the soul who meditates on the Self is content to serve the Self and rests satisfied within the Self; there remains nothing more for him to accomplish.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_18', 'hi', 'Hindi', 'इस जगत् में उस पुरुष का कृत और अकृत से कोई प्रयोजन नहीं है और न वह किसी वस्तु के लिये भूतमात्र पर आश्रित होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_3_18', 'en', 'English', 'He has nothing to gain by the performance or non-performance of action. His welfare depends not on any contribution that an earthly creature can make.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_19', 'hi', 'Hindi', 'इसलिए,  तुम अनासक्त होकर सदैव कर्तव्य कर्म का सम्यक् आचरण करो;  क्योकि,  अनासक्त पुरुष कर्म करता हुआ परमात्मा को प्राप्त होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_3_19', 'en', 'English', 'Therefore do thy duty perfectly, without care for the results, for he who does his duty disinterestedly attains the Supreme.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_20', 'hi', 'Hindi', 'जनकादि (ज्ञानी जन) भी कर्म द्वारा ही संसिद्धि को प्राप्त हुये लोक संग्रह (लोक रक्षण) को भी देखते हुये;  तुम कर्म करने योग्य हो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_3_20', 'en', 'English', 'King Janaka and others attained perfection through action alone. Even for the sake of enlightening the world, it is thy duty to act;', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_21', 'hi', 'Hindi', 'श्रेष्ठ पुरुष जैसा आचरण करता है, अन्य लोग भी वैसा ही अनुकरण करते हैं; वह पुरुष जो कुछ प्रमाण कर देता है, लोग भी उसका अनुसरण करते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_3_21', 'en', 'English', 'For whatever a great man does, others imitate. People conform to the standard which he has set.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_22', 'hi', 'Hindi', 'यद्यपि मुझे त्रैलोक्य में कुछ भी कर्तव्य नहीं हैं तथा किंचित भी प्राप्त होने योग्य (अवाप्तव्यम्) वस्तु अप्राप्त नहीं है, तो भी मैं कर्म में ही बर्तता हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_3_22', 'en', 'English', 'There is nothing in this universe, O Arjuna, that I am compelled to do, nor anything for Me to attain; yet I am persistently active.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_23', 'hi', 'Hindi', 'यदि मैं सावधान हुआ (अतन्द्रित:) कदाचित कर्म में न लगा रहूँ तो, हे पार्थ ! सब प्रकार से मनुष्य मेरे मार्ग (र्वत्म) का अनुसरण करेंगे।।', FALSE, 'Swami Tejomayananda'),
  ('bg_3_23', 'en', 'English', 'For were I not to act without ceasing, O prince, people would be glad to do likewise.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_24', 'hi', 'Hindi', 'यदि मैं कर्म न करूँ, तो ये समस्त लोक नष्ट हो जायेंगे; और मैं वर्णसंकर का कर्ता तथा इस प्रजा का हनन करने वाला होऊँगा।।', FALSE, 'Swami Tejomayananda'),
  ('bg_3_24', 'en', 'English', 'And if I were to refrain from action, the human race would be ruined; I should lead the world to chaos, and destruction would follow.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_25', 'hi', 'Hindi', 'हे भारत ! कर्म में आसक्त हुए अज्ञानीजन जैसे कर्म करते हैं वैसे ही विद्वान् पुरुष अनासक्त होकर, लोकसंग्रह (लोक कल्याण) की इच्छा से कर्म करे।।', FALSE, 'Swami Tejomayananda'),
  ('bg_3_25', 'en', 'English', 'As the ignorant act, because of their fondness for action, so should the wise act without such attachment, fixing their eyes, O Arjuna, only on the welfare of the world.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_26', 'hi', 'Hindi', 'ज्ञानी पुरुष, कर्मों में आसक्त अज्ञानियों की बुद्धि में भ्रम उत्पन्न न करे, स्वयं (भक्ति से) युक्त होकर कर्मों का सम्यक् आचरण कर, उनसे भी वैसा ही कराये।।', FALSE, 'Swami Tejomayananda'),
  ('bg_3_26', 'en', 'English', 'But a wise man should not perturb the minds of the ignorant, who are attached to action; let him perform his own actions in the right spirit, with concentration on Me, thus inspiring all to do the same.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_27', 'hi', 'Hindi', 'सम्पूर्ण कर्म प्रकृति के गुणों द्वारा किये जाते हैं, अहंकार से मोहित हुआ पुरुष,  "मैं कर्ता हूँ"  ऐसा मान लेता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_3_27', 'en', 'English', 'Action is the product of the Qualities inherent in Nature. It is only the ignorant man who, misled by personal egotism, says: I am the doer.''', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_28', 'hi', 'Hindi', 'परन्तु हे महाबाहो ! गुण और कर्म के विभाग के सत्य (तत्त्व)को जानने वाला ज्ञानी पुरुष यह जानकर कि "गुण गुणों में बर्तते हैं" (कर्म में) आसक्त नहीं होता।।', FALSE, 'Swami Tejomayananda'),
  ('bg_3_28', 'en', 'English', 'But he, O Mighty One, who understands correctly the relation of the Qualities to action, is not attached to the act for he perceives that it is merely the action and reaction of the Qualities among themselves.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_29', 'hi', 'Hindi', 'प्रकृति के गुणों से मोहित हुए पुरुष गुण और कर्म में आसक्त होते हैं, उन अपूर्ण ज्ञान वाले (अकृत्स्नविद:) मंदबुद्धि पुरुषों को पूर्ण ज्ञान प्राप्त पुरुष विचलित न करे।।', FALSE, 'Swami Tejomayananda'),
  ('bg_3_29', 'en', 'English', 'Those who do not understand the Qualities are interested in the act. Still, the wise man who knows the truth should not disturb the mind of him who does not.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_30', 'hi', 'Hindi', 'सम्पूर्ण कर्मों का मुझ में संन्यास करके,  आशा और ममता से रहित होकर,  संतापरहित हुए तुम युद्ध करो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_3_30', 'en', 'English', 'Therefore, surrendering thy actions unto Me, thy thoughts concentrated on the Absolute, free from selfishness and without anticipation of reward, with mind devoid of excitement, begin thou to fight.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_31', 'hi', 'Hindi', 'जो मनुष्य दोष बुद्धि से रहित (अनसूयन्त:) और श्रद्धा से युक्त हुए सदा मेरे इस मत (उपदेश) का अनुष्ठानपूर्वक पालन करते हैं, वे कर्मों से (बन्धन से) मुक्त हो जाते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_3_31', 'en', 'English', 'Those who always act in accordance with My precepts, firm in faith and without cavilling, they too are freed from the bondage of action.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_32', 'hi', 'Hindi', 'परन्तु जो दोष दृष्टि वाले मूढ़ लोग इस मेरे मत का पालन नहीं करते, उन सब ज्ञानों में मोहित चित्तवालों को नष्ट हुये ही तुम समझो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_3_32', 'en', 'English', 'But they who ridicule My word and do not keep it, are ignorant, devoid of wisdom and blind. They seek but their own destruction.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_33', 'hi', 'Hindi', 'ज्ञानवान् पुरुष भी अपनी प्रकृति के अनुसार चेष्टा करता है। सभी प्राणी अपनी प्रकृति पर ही जाते हैं, फिर इनमें (किसी का) निग्रह क्या करेगा।।', FALSE, 'Swami Tejomayananda'),
  ('bg_3_33', 'en', 'English', 'Even the wise man acts in character with his nature; indeed, all creatures act according to their natures. What is the use of compulsion then?', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_34', 'hi', 'Hindi', 'इन्द्रियइन्द्रिय (अर्थात् प्रत्येक इन्द्रिय) के विषय के प्रति (मन में) रागद्वेष रहते हैं;  मनुष्य को चाहिये कि वह उन दोनों के वश में न हो;  क्योंकि वे इसके (मनुष्य के) शत्रु हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_3_34', 'en', 'English', 'The love and hate which are aroused by the objects of sense arise from Nature; do not yield to them. They only obstruct the path.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_35', 'hi', 'Hindi', 'सम्यक् प्रकार से अनुष्ठित परधर्म की अपेक्षा गुणरहित स्वधर्म का पालन श्रेयष्कर है;  स्वधर्म में मरण कल्याणकारक है (किन्तु) परधर्म भय को देने वाला है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_3_35', 'en', 'English', 'It is better to do thine own duty, however lacking in merit, than to do that of another, even though efficiently. It is better to die doing one''s own duty, for to do the duty of another is fraught with danger.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_36', 'hi', 'Hindi', 'अर्जुन ने कहा -- हे वार्ष्णेय ! फिर यह पुरुष बलपूर्वक बाध्य किये हुये के समान अनिच्छा होते हुये भी किसके द्वारा प्रेरित होकर पाप का आचरण करता है?', FALSE, 'Swami Tejomayananda'),
  ('bg_3_36', 'en', 'English', 'Arjuna asked: My Lord! Tell me, what is it that drives a man to sin, even against his will and as if by compulsion?', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_37', 'hi', 'Hindi', 'श्रीभगवान् ने कहा -- रजोगुण में उत्पन्न हुई यह ''कामना'' है,  यही क्रोध है; यह महाशना (जिसकी भूख बड़ी हो) और महापापी है, इसे ही तुम यहाँ (इस जगत् में) शत्रु जानो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_3_37', 'en', 'English', 'Lord Shri Krishna: It is desire, it is aversion, born of passion. Desire consumes and corrupts everything. It is man''s greatest enemy.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_38', 'hi', 'Hindi', 'जैसे धुयें से अग्नि और धूलि से दर्पण ढक जाता है तथा जैसे भ्रूण गर्भाशय से ढका रहता है, वैसे उस (काम) के द्वारा यह (ज्ञान) आवृत होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_3_38', 'en', 'English', 'As fire is shrouded in smoke, a mirror by dust and a child by the womb, so is the universe enveloped in desire.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_39', 'hi', 'Hindi', 'हे कौन्तेय ! अग्नि के समान जिसको तृप्त करना कठिन है ऐसे कामरूप,  ज्ञानी के इस नित्य शत्रु द्वारा ज्ञान आवृत है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_3_39', 'en', 'English', 'It is the wise man''s constant enemy; it tarnishes the face of wisdom. It is as insatiable as a flame of fire.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_40', 'hi', 'Hindi', 'इन्द्रियाँ,  मन और बुद्धि इसके निवास स्थान कहे जाते हैं;  यह काम इनके द्वारा ही ज्ञान को आच्छादित करके देही पुरुष को मोहित करता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_3_40', 'en', 'English', 'It works through the senses, the mind and the reason; and with their help destroys wisdom and confounds the soul.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_41', 'hi', 'Hindi', 'इसलिये, हे अर्जुन ! तुम पहले इन्द्रियों को वश में करके, ज्ञान और विज्ञान के नाशक इस कामरूप पापी को नष्ट करो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_3_41', 'en', 'English', 'Therefore, O Arjuna, first control thy senses and then slay desire, for it is full of sin, and is the destroyer of knowledge and of wisdom.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_42', 'hi', 'Hindi', '(शरीर से) परे (श्रेष्ठ) इन्द्रियाँ कही जाती हैं;  इन्द्रियों से परे मन है और मन से परे बुद्धि है, और जो बुद्धि से भी परे है, वह है आत्मा।।', FALSE, 'Swami Tejomayananda'),
  ('bg_3_42', 'en', 'English', 'It is said that the senses are powerful. But beyond the senses is the mind, beyond the mind is the intellect, and beyond and greater than intellect is He.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_3_43', 'hi', 'Hindi', 'इस प्रकार बुद्धि से परे (शुद्ध) आत्मा को जानकर आत्मा (बुद्धि) के द्वारा आत्मा (मन) को वश में करके, हे महाबाहो ! तुम इस दुर्जेय (दुरासदम्) कामरूप शत्रु को मारो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_3_43', 'en', 'English', 'Thus, O Mighty-in-Arms, knowing Him to be beyond the intellect and, by His help, subduing thy personal egotism, kill thine enemy, Desire, extremely difficult though it be."', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_1', 'hi', 'Hindi', 'श्रीभगवान् ने कहा ---  मैंने इस अविनाशी योग को विवस्वान् (सूर्य देवता) से कहा (सिखाया);  विवस्वान् ने मनु से कहा;  मनु ने इक्ष्वाकु से कहा।।', FALSE, 'Swami Tejomayananda'),
  ('bg_4_1', 'en', 'English', '"Lord Shri Krishna said: This imperishable philosophy I taught to Viwaswana, the founder of the Sun dynasty, Viwaswana gave it to Manu the lawgiver, and Manu to King Ikshwaku!', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_2', 'hi', 'Hindi', 'इस प्रकार परम्परा से प्राप्त हुये इस योग को राजर्षियों ने जाना, (परन्तु) हे परन्तप ! वह योग बहुत काल (के अन्तराल) से यहाँ (इस लोक में) नष्टप्राय हो गया।।', FALSE, 'Swami Tejomayananda'),
  ('bg_4_2', 'en', 'English', 'The Divine Kings knew it, for it was their tradition. Then, after a long time, at last it was forgotten.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_3', 'hi', 'Hindi', 'वह ही यह पुरातन योग आज मैंने तुम्हें कहा (सिखाया) क्योंकि तुम मेरे भक्त और मित्र हो। यह उत्तम रहस्य है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_4_3', 'en', 'English', 'It is the same ancient Path that I have now revealed to thee, since thou are My devotee and My friend. It is the supreme Secret.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_4', 'hi', 'Hindi', 'अर्जुन ने कहा -- आपका जन्म अपर अर्थात् पश्चात का है और विवस्वान् का जन्म (आपके) पूर्व का है, इसलिये यह मैं कैसे जानूँ कि (सृष्टि के) आदि में आपने (इस योग को) कहा था?', FALSE, 'Swami Tejomayananda'),
  ('bg_4_4', 'en', 'English', 'Arjuna asked: My Lord! Viwaswana was born before Thee; how then canst Thou have revealed it to him?', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_5', 'hi', 'Hindi', 'श्रीभगवान् ने कहा -- हे अर्जुन ! मेरे और तुम्हारे बहुत से जन्म हो चुके हैं, (परन्तु) हे परन्तप ! उन सबको मैं जानता हूँ और तुम नहीं जानते।।', FALSE, 'Swami Tejomayananda'),
  ('bg_4_5', 'en', 'English', 'Lord Shri Krishna replied: I have been born again and again, from time to time; thou too,O Arjuna! My births are known to Me, but thou knowest not thine.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_6', 'hi', 'Hindi', 'यद्यपि मैं अजन्मा और अविनाशी स्वरूप हूँ और भूतमात्र का ईश्वर हूँ (तथापि) अपनी प्रकृति को अपने अधीन रखकर (अधिष्ठाय) मैं अपनी माया से जन्म लेता हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_4_6', 'en', 'English', 'have no beginning. Though I am imperishable, as well as Lord of all that exists, yet by My own will and power do I manifest Myself.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_7', 'hi', 'Hindi', 'हे भारत ! जब-जब धर्म की हानि और अधर्म की वृद्धि होती है,  तब-तब मैं स्वयं को प्रकट करता हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_4_7', 'en', 'English', 'Whenever spirituality decays and materialism is rampant, then, O Arjuna, I reincarnate Myself!', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_8', 'hi', 'Hindi', 'साधु पुरुषों के रक्षण,  दुष्कृत्य करने वालों के नाश,  तथा धर्म संस्थापना के लिये,  मैं प्रत्येक युग में प्रगट होता हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_4_8', 'en', 'English', 'To protect the righteous, to destroy the wicked and to establish the kingdom of God, I am reborn from age to age.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_9', 'hi', 'Hindi', 'हे अर्जुन ! मेरा जन्म और कर्म दिव्य है,  इस प्रकार जो पुरुष तत्त्वत:  जानता है, वह शरीर को त्यागकर फिर जन्म को नहीं प्राप्त होता;  वह मुझे ही प्राप्त होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_4_9', 'en', 'English', 'He who realises the divine truth concerning My birth and life is not born again; and when he leaves his body, he becomes one with Me.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_10', 'hi', 'Hindi', 'राग भय और क्रोध से रहित मनमय मेरे शरण हुए बहुत से पुरुष ज्ञान रुप तप से पवित्र‌ हुए मेरे स्वरुप को प्राप्त हुए हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_4_10', 'en', 'English', 'Many have merged their existences in Mine, being freed from desire, fear and anger, filled always with Me and purified by the illuminating flame of self-abnegation.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_11', 'hi', 'Hindi', 'जो मुझे जैसे भजते हैं,  मैं उन पर वैसे ही अनुग्रह करता हूँ;  हे पार्थ सभी मनुष्य सब प्रकार से, मेरे ही मार्ग का अनुवर्तन करते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_4_11', 'en', 'English', 'Howsoever men try to worship Me, so do I welcome them. By whatever path they travel, it leads to Me at last.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_12', 'hi', 'Hindi', '(सामान्य मनुष्य) यहाँ (इस लोक में) कर्मों के फल को चाहते हुये देवताओं को पूजते हैं;  क्योंकि मनुष्य लोक में कर्मों के फल शीघ्र ही प्राप्त होते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_4_12', 'en', 'English', 'Those who look for success, worship the Powers; and in this world their actions bear immediate fruit.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_13', 'hi', 'Hindi', 'गुण और कर्मों के विभाग से चातुर्वण्य मेरे द्वारा रचा गया है। यद्यपि मैं उसका कर्ता हूँ, तथापि तुम मुझे अकर्ता और अविनाशी जानो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_4_13', 'en', 'English', 'The four divisions of society (the wise, the soldier, the merchant, the labourer) were created by Me, according to the natural distribution of Qualities and instincts. I am the author of them, though I Myself do no action, and am changeless.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_14', 'hi', 'Hindi', 'कर्म मुझे लिप्त नहीं करते;  न मुझे कर्मफल में स्पृहा है। इस प्रकार मुझे जो जानता है, वह भी कर्मों से नहीं बन्धता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_4_14', 'en', 'English', 'My actions do not fetter Me, nor do I desire anything that they can bring. He who thus realises Me is not enslaved by action.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_15', 'hi', 'Hindi', 'पूर्व के मुमुक्ष पुरुषों द्वारा भी इस प्रकार जानकर ही कर्म किया गया है;  इसलिये तुम भी पूर्वजों द्वारा सदा से किये हुए कर्मों को ही करो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_4_15', 'en', 'English', 'In the light of wisdom, our ancestors, who sought deliverance, performed their acts. Act thou also, as did our fathers of old.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_16', 'hi', 'Hindi', 'कर्म क्या है और अकर्म क्या है? इस विषय में बुद्धिमान पुरुष भी भ्रमित हो जाते हैं। इसलिये मैं तुम्हें कर्म कहूँगा,  (अर्थात् कर्म और अकर्म का स्वरूप समझाऊँगा) जिसको जानकर तुम अशुभ (संसार बन्धन) से मुक्त हो जाओगे।।', FALSE, 'Swami Tejomayananda'),
  ('bg_4_16', 'en', 'English', 'What is action and what is inaction? It is a question which has bewildered the wise. But I will declare unto thee the philosophy of action, and knowing it, thou shalt be free from evil.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_17', 'hi', 'Hindi', 'कर्म का (स्वरूप) जानना चाहिये और विकर्म का (स्वरूप) भी जानना चाहिये ; (बोद्धव्यम्) तथा अकर्म का भी (स्वरूप) जानना चाहिये (क्योंकि) कर्म की गति गहन है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_4_17', 'en', 'English', 'It is necessary to consider what is right action, what is wrong action, and what is inaction, for mysterious is the law of action.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_18', 'hi', 'Hindi', 'जो पुरुष कर्म में अकर्म और अकर्म में कर्म देखता है,  वह मनुष्यों में बुद्धिमान है,  वह योगी सम्पूर्ण कर्मों को करने वाला है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_4_18', 'en', 'English', 'He who can see inaction in action, and action in inaction, is the wisest among men. He is a saint, even though he still acts.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_19', 'hi', 'Hindi', 'जिसके समस्त कार्य कामना और संकल्प से रहित हैं,  ऐसे उस ज्ञानरूप अग्नि के द्वारा भस्म हुये कर्मों वाले पुरुष को ज्ञानीजन पण्डित कहते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_4_19', 'en', 'English', 'The wise call him a sage, for whatever he undertakes is free from the motive of desire, and his deeds are purified by the fire of Wisdom.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_20', 'hi', 'Hindi', 'जो पुरुष,  कर्मफलासक्ति को त्यागकर,  नित्यतृप्त और सब आश्रयों से रहित है वह कर्म में प्रवृत्त होते हुए भी (वास्तव में) कुछ भी नहीं करता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_4_20', 'en', 'English', 'Having surrendered all claim to the results of his actions, always contented and independent, in reality he does nothing, even though he is apparently acting.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_21', 'hi', 'Hindi', 'जो आशा रहित है तथा जिसने चित्त और आत्मा (शरीर) को संयमित किया है,  जिसने सब परिग्रहों का त्याग किया है,  ऐसा पुरुष शारीरिक कर्म करते हुए भी पाप को नहीं प्राप्त होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_4_21', 'en', 'English', 'Expecting nothing, his mind and personality controlled, without greed, doing bodily actions only; though he acts, yet he remains untainted.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_22', 'hi', 'Hindi', 'यदृच्छया (अपने आप) जो कुछ प्राप्त हो उसमें ही सन्तुष्ट रहने वाला,  द्वन्द्वों से अतीत तथा मत्सर से रहित,  सिद्धि व असिद्धि में समभाव वाला पुरुष कर्म करके भी नहीं बन्धता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_4_22', 'en', 'English', 'Content with what comes to him without effort of his own, mounting above the pairs of opposites, free from envy, his mind balanced both in success and failure; though he acts, yet the consequences do not bind him.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_23', 'hi', 'Hindi', 'जो आसक्तिरहित और मुक्त है,  जिसका चित्त ज्ञान में स्थित है,  यज्ञ के लिये आचरण करने वाले ऐसे पुरुष के समस्त कर्म लीन हो जाते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_4_23', 'en', 'English', 'He who is without attachment, free, his mind centered in wisdom, his actions, being done as a sacrifice, leave no trace behind.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_24', 'hi', 'Hindi', 'अर्पण (अर्थात् अर्पण करने का साधन श्रुवा) ब्रह्म है और हवि (शाकल्य अथवा हवन करने योग्य द्रव्य) भी ब्रह्म है;  ब्रह्मरूप अग्नि में ब्रह्मरूप कर्ता के द्वारा जो हवन किया गया है,  वह भी ब्रह्म ही है। इस प्रकार ब्रह्मरूप कर्म में समाधिस्थ पुरुष का गन्तव्य भी ब्रह्म ही है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_4_24', 'en', 'English', 'For him, the sacrifice itself is the Spirit; the Spirit and the oblation are one; it is the Spirit Itself which is sacrificed in Its own fire, and the man even in action is united with God, since while performing his act, his mind never ceases to be fixed on Him.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_25', 'hi', 'Hindi', 'कोई योगीजन देवताओं के पूजनरूप यज्ञ को ही करते हैं ; और दूसरे (ज्ञानीजन) ब्रह्मरूप अग्नि में यज्ञ के द्वारा यज्ञ को हवन करते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_4_25', 'en', 'English', 'Some sages sacrifice to the Powers; others offer themselves on the alter of the Eternal.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_26', 'hi', 'Hindi', 'अन्य (योगीजन) श्रोत्रादिक सब इन्द्रियों को संयमरूप अग्नि में हवन करते हैं,  और अन्य (लोग) शब्दादिक विषयों को इन्द्रियरूप अग्नि में हवन करते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_4_26', 'en', 'English', 'Some sacrifice their physical senses in the fire of self-control; others offer up their contact with external objects in the sacrificial fire of their senses.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_27', 'hi', 'Hindi', 'दूसरे (योगीजन) सम्पूर्ण इन्द्रियों के तथा प्राणों के कर्मों को ज्ञान से प्रकाशित आत्मसंयमयोगरूप अग्नि में हवन करते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_4_27', 'en', 'English', 'Other again sacrifice their activities and their vitality in the Spiritual fire of self-abnegation, kindled by wisdom.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_28', 'hi', 'Hindi', 'कुछ (साधक) द्रव्ययज्ञ, तपयज्ञ और योगयज्ञ करने वाले होते हैं;  और दूसरे कठिन व्रत करने वाले स्वाध्याय और ज्ञानयज्ञ करने वाले योगीजन होते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_4_28', 'en', 'English', 'And yet others offer as their sacrifice wealth, austerities and meditation. Monks wedded to their vows renounce their scriptural learning and even their spiritual powers.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_29', 'hi', 'Hindi', 'अन्य (योगीजन) अपानवायु में प्राणवायु को हवन करते हैं,  तथा प्राण में अपान की आहुति देते हैं,  प्राण और अपान की गति को रोककर,  वे प्राणायाम के ही समलक्ष्य समझने वाले होते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_4_29', 'en', 'English', 'There are some who practise control of the Vital Energy and govern the subtle forces of Prana and Apana, thereby sacrificing their Prana unto Apana, or their Apana unto Prana.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_30', 'hi', 'Hindi', 'दूसरे नियमित आहार करने वाले (साधक जन) प्राणों को प्राणों में हवन करते हैं। ये सभी यज्ञ को जानने वाले हैं, जिनके पाप यज्ञ के द्वारा नष्ट हो चुके हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_4_30', 'en', 'English', 'Others, controlling their diet, sacrifice their worldly life to the spiritual fire. All understand the principal of sacrifice, and by its means their sins are washed away.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_31', 'hi', 'Hindi', 'हे कुरुश्रेष्ठ ! यज्ञ के अवशिष्ट अमृत को भोगने वाले पुरुष सनातन ब्रह्म को प्राप्त होते हैं। यज्ञ रहित पुरुष को यह लोक भी नहीं मिलता,  फिर परलोक कैसे मिलेगा?', FALSE, 'Swami Tejomayananda'),
  ('bg_4_31', 'en', 'English', 'Tasting the nectar of immortality, as the reward of sacrifice, they reach the Eternal. This world is not for those who refuse to sacrifice; much less the other world.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_32', 'hi', 'Hindi', 'ऐसे अनेक प्रकार के यज्ञों का ब्रह्मा के मुख अर्थात् वेदों में प्रसार है अर्थात् वर्णित हैं। उन सब को कर्मों से उत्पन्न हुए जानो;  इस प्रकार जानकर तुम मुक्त हो जाओगे।।', FALSE, 'Swami Tejomayananda'),
  ('bg_4_32', 'en', 'English', 'In this way other sacrifices too may be undergone for the Spirit''s sake. Know thou that they all depend on action. Knowing this, thou shalt be free.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_33', 'hi', 'Hindi', 'हे परन्तप ! द्रव्यों से सम्पन्न होने वाले यज्ञ की अपेक्षा ज्ञानयज्ञ श्रेष्ठ है। हे पार्थ ! सम्पूर्ण अखिल कर्म ज्ञान में समाप्त होते हैं,  अर्थात् ज्ञान उनकी पराकाष्ठा है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_4_33', 'en', 'English', 'Shri Purohit Swami did not comment on this sloka', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_34', 'hi', 'Hindi', 'उस (ज्ञान) को (गुरु के समीप जाकर) साष्टांग प्रणिपात,  प्रश्न तथा सेवा करके जानो;  ये तत्त्वदर्शी ज्ञानी पुरुष तुम्हें ज्ञान का उपदेश करेंगे।।', FALSE, 'Swami Tejomayananda'),
  ('bg_4_34', 'en', 'English', 'This shalt thou learn by prostrating thyself at the Master''s feet, by questioning Him and by serving Him. The wise who have realised the Truth will teach thee wisdom.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_35', 'hi', 'Hindi', 'जिसको जानकर तुम पुन इस प्रकार मोह को नहीं प्राप्त होगे,  और हे पाण्डव ! जिसके द्वारा तुम भूतमात्र को अपने आत्मस्वरूप में तथा मुझमें भी देखोगे।।', FALSE, 'Swami Tejomayananda'),
  ('bg_4_35', 'en', 'English', 'Having known That, thou shalt never again be confounded; and, O Arjuna, by the power of that wisdom, thou shalt see all these people as if they were thine own Self, and therefore as Me.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_36', 'hi', 'Hindi', 'यदि तुम सब पापियों से भी अधिक पाप करने वाले हो,  तो भी ज्ञानरूपी नौका द्वारा,  निश्चय ही सम्पूर्ण पापों का तुम संतरण कर जाओगे।।', FALSE, 'Swami Tejomayananda'),
  ('bg_4_36', 'en', 'English', 'Be thou the greatest of sinners, yet thou shalt cross over all sin by the ferryboat of wisdom.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_37', 'hi', 'Hindi', 'जैसे प्रज्जवलित अग्नि ईन्धन को भस्मसात् कर देती है,  वैसे ही,  हे अर्जुन ! ज्ञानरूपी अग्नि सम्पूर्ण कर्मों को भस्मसात् कर देती है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_4_37', 'en', 'English', 'As the kindled fire consumes the fuel, so, O Arjuna, in the flame of wisdom the embers of action are burnt to ashes.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_38', 'hi', 'Hindi', 'इस लोक में ज्ञान के समान पवित्र करने वाला,  निसंदेह,  कुछ भी नहीं है। योग में संसिद्ध पुरुष स्वयं ही उसे (उचित) काल में आत्मा में प्राप्त करता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_4_38', 'en', 'English', 'There is nothing in the world so purifying as wisdom; and he who is a perfect saint finds that at last in his own Self.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_39', 'hi', 'Hindi', 'श्रद्धावान्,  तत्पर और जितेन्द्रिय पुरुष ज्ञान प्राप्त करता है। ज्ञान को प्राप्त करके शीघ्र ही वह परम शान्ति को प्राप्त होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_4_39', 'en', 'English', 'He who is full of faith attains wisdom, and he too who can control his senses, having attained that wisdom, he shall ere long attain Supreme Peace.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_40', 'hi', 'Hindi', 'अज्ञानी तथा श्रद्धारहित और संशययुक्त पुरुष नष्ट हो जाता है,  (उनमें भी) संशयी पुरुष के लिये न यह लोक है,  न परलोक और न सुख।।', FALSE, 'Swami Tejomayananda'),
  ('bg_4_40', 'en', 'English', 'But the ignorant man, and he who has no faith, and the sceptic are lost. Neither in this world nor elsewhere is there any happiness in store for him who always doubts.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_41', 'hi', 'Hindi', 'जिसने योगद्वारा कर्मों का संन्यास किया है,  ज्ञानद्वारा जिसके संशय नष्ट हो गये हैं,  ऐसे आत्मवान् पुरुष को,  हे धनंजय ! कर्म नहीं बांधते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_4_41', 'en', 'English', 'But the man who has renounced his action for meditation, who has cleft his doubt in twain by the sword of wisdom, who remains always enthroned in his Self, is not bound by his acts.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_4_42', 'hi', 'Hindi', 'इसलिये अपने हृदय में स्थित अज्ञान से उत्पन्न आत्मविषयक संशय को ज्ञान खड्ग से काटकर,  हे भारत ! योग का आश्रय लेकर खड़े हो जाओ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_4_42', 'en', 'English', 'Therefore, cleaving asunder with the sword of wisdom the doubts of the heart, which thine own ignorance has engendered, follow the Path of Wisdom and arise!"', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_5_1', 'hi', 'Hindi', 'अर्जुन ने कहा हे --  कृष्ण ! आप कर्मों के संन्यास की और फिर योग (कर्म के आचरण) की प्रशंसा करते हैं। इन दोनों में एक जो निश्चय पूर्वक श्रेयस्कर है, उसको मेरे लिए कहिये।।', FALSE, 'Swami Tejomayananda'),
  ('bg_5_1', 'en', 'English', '"Arjuna said: My Lord! At one moment Thou praisest renunciation of action; at another, right action. Tell me truly, I pray, which of these is the more conducive to my highest welfare?', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_5_2', 'hi', 'Hindi', 'श्रीभगवान् ने कहा --  कर्मसंन्यास और कर्मयोग ये दोनों ही परम कल्याणकारक हैं;  परन्तु उन दोनों में कर्मसंन्यास से कर्मयोग श्रेष्ठ है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_5_2', 'en', 'English', 'Lord Shri Krishna replied: Renunciation of action and the path of right action both lead to the highest; of the two, right action is the better.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_5_3', 'hi', 'Hindi', 'जो पुरुष न किसी से द्वेष करता है और न किसी की आकांक्षा,  वह सदा संन्यासी ही समझने योग्य है;  क्योंकि,  हे महाबाहो ! द्वन्द्वों से रहित पुरुष सहज ही बन्धन मुक्त हो जाता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_5_3', 'en', 'English', 'He is a true ascetic who never desires or dislikes, who is uninfluenced by the opposites and is easily freed from bondage.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_5_4', 'hi', 'Hindi', 'बालक अर्थात् बालबुद्धि के लोग सांख्य (संन्यास) और योग को परस्पर भिन्न समझते हैं;  किसी एक में भी सम्यक् प्रकार से स्थित हुआ पुरुष दोनों के फल को प्राप्त कर लेता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_5_4', 'en', 'English', 'Only the unenlightened speak of wisdom and right action as separate, not the wise. If any man knows one, he enjoys the fruit of both.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_5_5', 'hi', 'Hindi', 'जो स्थान ज्ञानियों द्वारा प्राप्त किया जाता है,  उसी स्थान पर कर्मयोगी भी पहुँचते हैं। इसलिए जो पुरुष सांख्य और योग को (फलरूप से) एक ही देखता है,  वही (वास्तव में) देखता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_5_5', 'en', 'English', 'The level which is reached by wisdom is attained through right action as well. He who perceives that the two are one, knows the truth.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_5_6', 'hi', 'Hindi', 'परन्तु,  हे महाबाहो ! योग के बिना संन्यास प्राप्त होना कठिन है;  योगयुक्त मननशील पुरुष परमात्मा को शीघ्र ही प्राप्त होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_5_6', 'en', 'English', 'Without concentration, O Mighty Man, renunciation is difficult. But the sage who is always meditating on the Divine, before long shall attain the Absolute.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_5_7', 'hi', 'Hindi', 'जो पुरुष योगयुक्त, विशुद्ध अन्तकरण वाला, शरीर को वश में किये हुए, जितेन्द्रिय तथा भूतमात्र में स्थित आत्मा के साथ एकत्व अनुभव किये हुए है वह कर्म करते हुए भी उनसे लिप्त नहीं होता।।', FALSE, 'Swami Tejomayananda'),
  ('bg_5_7', 'en', 'English', 'He who is spiritual, who is pure, who has overcome his senses and his personal self, who has realised his highest Self as the Self of all, such a one, even though he acts, is not bound by his acts.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_5_8', 'hi', 'Hindi', 'तत्त्ववित् युक्त पुरुष यह सोचेगा (अर्थात् जानता है) कि  "मैं किंचित् मात्र कर्म नहीं करता हूँ"  देखता हुआ, सुनता हुआ, स्पर्श करता हुआ, सूंघता हुआ, खाता हुआ, चलता हुआ, सोता हुआ, श्वास लेता हुआ,।।', FALSE, 'Swami Tejomayananda'),
  ('bg_5_8', 'en', 'English', 'Though the saint sees, hears, touches, smells, eats, moves, sleeps and breathes, yet he knows the Truth, and he knows that it is not he who acts.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_5_9', 'hi', 'Hindi', 'बोलता हुआ,  त्यागता हुआ,  ग्रहण करता हुआ  तथा आँखों को खोलता और बन्द करता हुआ (वह) निश्चयात्मक रूप से जानता है कि सब इन्द्रियाँ अपने-अपने विषयों में विचरण कर रही हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_5_9', 'en', 'English', 'Though he talks, though he gives and receives, though he opens his eyes and shuts them, he still knows that his senses are merely disporting themselves among the objects of perception.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_5_10', 'hi', 'Hindi', 'जो पुरुष सब कर्म ब्रह्म में अर्पण करके और आसक्ति को त्यागकर करता है,  वह पुरुष कमल के पत्ते के सदृश पाप से लिप्त नहीं होता।।', FALSE, 'Swami Tejomayananda'),
  ('bg_5_10', 'en', 'English', 'He who dedicates his actions to the Spirit, without any personal attachment to them, he is no more tainted by sin than the water lily is wetted by water.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_5_11', 'hi', 'Hindi', 'योगीजन, शरीर, मन, बुद्धि और इन्द्रियों द्वारा आसक्ति को त्याग कर आत्मशुद्धि (चित्तशुद्धि) के लिए कर्म करते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_5_11', 'en', 'English', 'The sage performs his action dispassionately, using his body, mind and intellect, and even his senses, always as a means of purification.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_5_12', 'hi', 'Hindi', 'युक्त पुरुष कर्मफल का त्याग करके परम शान्ति को प्राप्त होता है;  और अयुक्त पुरुष फल में आसक्त हुआ कामना के द्वारा बँधता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_5_12', 'en', 'English', 'Having abandoned the fruit of action, he wins eternal peace. Others unacquainted with spirituality, led by desire and clinging to the benefit which they think will follow their actions, become entangled in them.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_5_13', 'hi', 'Hindi', 'सब कर्मों का मन से संन्यास करके संयमी पुरुष नवद्वार वाली शरीर रूप नगरी में सुख से रहता हुआ न कर्म करता है और न करवाता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_5_13', 'en', 'English', 'Mentally renouncing all actions, the self-controlled soul enjoys bliss in this body, the city of the nine gates, neither doing anything himself nor causing anything to be done.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_5_14', 'hi', 'Hindi', 'लोकमात्र के लिए प्रभु (ईश्वर) न कर्तृत्व, न कर्म और न कर्मफल के संयोग को रचता है। परन्तु प्रकृति (सब कुछ) करती है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_5_14', 'en', 'English', 'The Lord of this universe has not ordained activity, or any incentive thereto, or any relation between an act and its consequences. All this is the work of Nature.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_5_15', 'hi', 'Hindi', 'विभु परमात्मा न किसी के पापकर्म को और न पुण्यकर्म को ही ग्रहण करता है;  (किन्तु) अज्ञान से ज्ञान ढका हुआ है,  इससे सब जीव मोहित होते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_5_15', 'en', 'English', 'The Lord does not accept responsibility for any man''s sin or merit. Men are deluded because in them wisdom is submerged in ignorance.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_5_16', 'hi', 'Hindi', 'परन्तु जिनका वह अज्ञान आत्मज्ञान से नष्ट हो जाता है,  उनके लिए वह ज्ञान,  सूर्य के सदृश,  परमात्मा को प्रकाशित करता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_5_16', 'en', 'English', 'Surely wisdom is like the sun, revealing the supreme truth to those whose ignorance is dispelled by the wisdom of the Self.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_5_17', 'hi', 'Hindi', 'जिनकी बुद्धि उस (परमात्मा) में स्थित है,  जिनका मन तद्रूप हुआ है,  उसमें ही जिनकी निष्ठा है,  वह (ब्रह्म) ही जिनका परम लक्ष्य है,  ज्ञान के द्वारा पापरहित पुरुष अपुनरावृत्ति को प्राप्त होते हैं,  अर्थात् उनका पुनर्जन्म नहीं होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_5_17', 'en', 'English', 'Meditating on the Divine, having faith in the Divine, concentrating on the Divine and losing themselves in the Divine, their sins dissolved in wisdom, they go whence there is no return.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_5_18', 'hi', 'Hindi', '(ऐसे वे) ज्ञानीजन विद्या और विनय से सम्पन्न ब्राह्मण,  तथा गाय,  हाथी,  श्वान और चाण्डाल में भी सम तत्त्व को देखते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_5_18', 'en', 'English', 'Sages look equally upon all, whether he be a minister of learning and humility, or an infidel, or whether it be a cow, an elephant or a dog.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_5_19', 'hi', 'Hindi', 'जिनका मन समत्वभाव में स्थित है,  उनके द्वारा यहीं पर यह सर्ग जीत लिया जाता है; क्योंकि ब्रह्म निर्दोष और सम है इसलिये वे ब्रह्म में ही स्थित हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_5_19', 'en', 'English', 'Even in this world they conquer their earth-life whose minds, fixed on the Supreme, remain always balanced; for the Supreme has neither blemish nor bias.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_5_20', 'hi', 'Hindi', 'जो स्थिरबुद्धि,  संमोहरहित ब्रह्मवित् पुरुष ब्रह्म में स्थित है,  वह प्रिय वस्तु को प्राप्त होकर हर्षित नहीं होता और अप्रिय को पाकर उद्विग्न नहीं होता।।', FALSE, 'Swami Tejomayananda'),
  ('bg_5_20', 'en', 'English', 'He who knows and lives in the Absolute remains unmoved and unperturbed; he is not elated by pleasure or depressed by pain.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_5_21', 'hi', 'Hindi', 'बाह्य विषयों में आसक्तिरहित अन्त:करण वाला पुरुष आत्मा में ही सुख प्राप्त करता है;  ब्रह्म के ध्यान में समाहित चित्त वाला पुरुष अक्षय सुख प्राप्त करता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_5_21', 'en', 'English', 'He finds happiness in his own Self, and enjoys eternal bliss, whose heart does not yearn for the contacts of earth and whose Self is one with the Everlasting.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_5_22', 'hi', 'Hindi', 'हे कौन्तेय (इन्द्रिय तथा विषयों के) संयोग से उत्पन्न होने वाले जो भोग हैं वे दु:ख के ही हेतु हैं, क्योंकि वे आदि-अन्त वाले हैं। बुद्धिमान् पुरुष उनमें नहीं रमता।।', FALSE, 'Swami Tejomayananda'),
  ('bg_5_22', 'en', 'English', 'The joys that spring from external associations bring pain; they have their beginning and their endings. The wise man does not rejoice in them.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_5_23', 'hi', 'Hindi', 'जो मनुष्य इसी लोक में शरीर त्यागने के पूर्व ही काम और क्रोध से उत्पन्न हुए वेग को सहन करने में समर्थ है,  वह योगी (युक्त) और सुखी मनुष्य है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_5_23', 'en', 'English', 'He who, before he leaves his body, learns to surmount the promptings of desire and anger is a saint and is happy.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_5_24', 'hi', 'Hindi', 'जो पुरुष अन्तरात्मा में ही सुख वाला,  आत्मा में ही आराम वाला तथा आत्मा में ही ज्ञान वाला है,  वह योगी ब्रह्मरूप बनकर ब्रह्मनिर्वाण अर्थात् परम मोक्ष को प्राप्त होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_5_24', 'en', 'English', 'He who is happy within his Self and has found Its peace, and in whom the inner light shines, that sage attains Eternal Bliss and becomes the Spirit Itself.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_5_25', 'hi', 'Hindi', 'वे ऋषिगण मोक्ष को प्राप्त होते हैं - जिनके पाप नष्ट हो गये हैं, जो छिन्नसंशय, संयमी और भूतमात्र के हित में रमने वाले हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_5_25', 'en', 'English', 'Sages whose sins have been washed away, whose sense of separateness has vanished, who have subdued themselves, and seek only the welfare of all, come to the Eternal Spirit.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_5_26', 'hi', 'Hindi', 'काम और क्रोध से रहित,  संयतचित्त वाले तथा आत्मा को जानने वाले यतियों के लिए सब ओर मोक्ष (या ब्रह्मानन्द) विद्यमान रहता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_5_26', 'en', 'English', 'Saints who know their Selves, who control their minds, and feel neither desire nor anger, find Eternal Bliss everywhere.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_5_27', 'hi', 'Hindi', 'बाह्य विषयों को बाहर ही रखकर नेत्रों की दृष्टि को भृकुटि के बीच में स्थित करके तथा नासिका में विचरने वाले प्राण और अपानवायु को सम करके,।।', FALSE, 'Swami Tejomayananda'),
  ('bg_5_27', 'en', 'English', 'Excluding external objects, his gaze fixed between the eyebrows, the inward and outward breathings passing equally through his nostrils;', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_5_28', 'hi', 'Hindi', 'जिस पुरुष की इन्द्रियाँ,  मन और बुद्धि संयत हैं, ऐसा मोक्ष परायण मुनि इच्छा, भय और क्रोध से रहित है, वह सदा मुक्त ही है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_5_28', 'en', 'English', 'Governing sense, mind and intellect, intent on liberation, free from desire, fear and anger, the sage is forever free.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_5_29', 'hi', 'Hindi', '(साधक भक्त) मुझे यज्ञ और तपों का भोक्ता और सम्पूर्ण लोकों का महान् ईश्वर तथा भूतमात्र का सुहृद् (मित्र) जानकर शान्ति को प्राप्त होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_5_29', 'en', 'English', 'Knowing me as Him who gladly receives all offerings of austerity and sacrifice, as the Might Ruler of all the Worlds and the Friend of all beings, he passes to Eternal Peace."', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_1', 'hi', 'Hindi', 'श्रीभगवान् ने कहा -- जो पुरुष कर्मफल पर आश्रित न होकर कर्तव्य कर्म करता है, वह संन्यासी और योगी है, न कि वह जिसने केवल अग्नि का और क्रियायों का त्याग किया है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_1', 'en', 'English', '"Lord Shri Krishna said: He who acts because it is his duty, not thinking of the consequences, is really spiritual and a true ascetic; and not he who merely observes rituals or who shuns all action.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_2', 'hi', 'Hindi', 'हे पाण्डव ! जिसको (शास्त्रवित्) संन्यास कहते हैं, उसी को तुम योग समझो; क्योंकि संकल्पों को न त्यागने वाला कोई भी पुरुष योगी नहीं होता।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_2', 'en', 'English', 'O Arjuna! Renunciation is in fact what is called Right Action. No one can become spiritual who has not renounced all desire.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_3', 'hi', 'Hindi', 'योग में आरूढ़ होने की इच्छा वाले मुनि के लिए कर्म करना ही हेतु (साधन) कहा है और योगारूढ़ हो जाने पर उसी पुरुष के लिए शम को (शांति, संकल्पसंन्यास) साधन कहा गया है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_3', 'en', 'English', 'For the sage who seeks the heights of spiritual meditation, practice is the only method, and when he has attained them, he must maintain himself there by continual self-control.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_4', 'hi', 'Hindi', 'जब (साधक) न इन्द्रियों के विषयों में और न कर्मों में आसक्त होता है तब सर्व संकल्पों के संन्यासी को योगारूढ़ कहा जाता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_4', 'en', 'English', 'When a man renounces even the thought of initiating action, when he is not interested in sense objects or any results which may flow from his acts, then in truth he understands spirituality.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_5', 'hi', 'Hindi', 'मनुष्य को अपने द्वारा अपना उद्धार करना चाहिये और अपना अध: पतन नहीं करना चाहिये; क्योंकि आत्मा ही आत्मा का मित्र है और आत्मा (मनुष्य स्वयं) ही आत्मा का (अपना) शत्रु है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_5', 'en', 'English', 'Let him seek liberation by the help of his Highest Self, and let him never disgrace his own Self. For that Self is his only friend; yet it may also be his enemy.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_6', 'hi', 'Hindi', 'जिसने आत्मा (इंद्रियों,आदि) को आत्मा के द्वारा जीत लिया है, उस पुरुष का आत्मा उसका मित्र होता है, परन्तु अजितेन्द्रिय के लिए आत्मा शत्रु के समान स्थित होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_6', 'en', 'English', 'To him who has conquered his lower nature by Its help, the Self is a friend, but to him who has not done so, It is an enemy.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_7', 'hi', 'Hindi', 'शीत-उष्ण, सुख-दु:ख तथा मान-अपमान में जो प्रशान्त रहता है, ऐसे जितात्मा पुरुष के लिये परमात्मा सम्यक् प्रकार से स्थित है, अर्थात्, आत्मरूप से विद्यमान है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_7', 'en', 'English', 'The Self of him who is self-controlled, and has attained peace is equally unmoved by heat or cold, pleasure or pain, honour or dishonour.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_8', 'hi', 'Hindi', 'जो योगी ज्ञान और विज्ञान से तृप्त है, जो विकार रहित (कूटस्थ) और जितेन्द्रिय है, जिसको मिट्टी, पाषाण और कंचन समान है, वह (परमात्मा से) युक्त कहलाता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_8', 'en', 'English', 'He who desires nothing but wisdom and spiritual insight, who has conquered his senses and who looks with the same eye upon a lump of earth, a stone or fine gold, is a real saint.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_9', 'hi', 'Hindi', 'जो पुरुष सुहृद्, मित्र, शत्रु, उदासीन, मध्यस्थ, द्वेषी और बान्धवों में तथा धर्मात्माओं में और पापियों में भी समान भाव वाला है, वह श्रेष्ठ है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_9', 'en', 'English', 'He looks impartially on all - lover, friend or foe; indifferent or hostile; alien or relative; virtuous or sinful.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_10', 'hi', 'Hindi', 'शरीर और मन को संयमित किया हुआ योगी एकान्त स्थान पर अकेला रहता हुआ आशा और परिग्रह से मुक्त होकर निरन्तर मन को आत्मा में स्थिर करे।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_10', 'en', 'English', 'Let the student of spirituality try unceasingly to concentrate his mind; Let him live in seclusion, absolutely alone, with mind and personality controlled, free from desire and without possessions.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_11', 'hi', 'Hindi', 'शुद्ध (स्वच्छ) भूमि में कुश, मृगशाला और उस पर वस्त्र रखा हो ऐसे अपने आसन को न अति ऊँचा और न अति नीचा स्थिर स्थापित करके....৷৷.।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_11', 'en', 'English', 'Having chosen a holy place, let him sit in a firm posture on a seat, neither too high nor too low, and covered with a grass mat, a deer skin and a cloth.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_12', 'hi', 'Hindi', 'वहाँ (आसन में बैठकर) मन को एकाग्र करके, चित्त और इन्द्रियों की क्रियाओं को वश में किये हुये आत्मशुद्धि के लिए योग का अभ्यास करे।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_12', 'en', 'English', 'Seated thus, his mind concentrated, its functions controlled and his senses governed, let him practise meditation for the purification of his lower nature.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_13', 'hi', 'Hindi', 'काया, सिर और ग्रीवा को समान और अचल धारण किये हुए स्थिर होकर अपनी नासिका के अग्र भाग को देखकर अन्य दिशाओं को न देखता हुआ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_13', 'en', 'English', 'Let him hold body, head and neck erect, motionless and steady; let him look fixedly at the tip of his nose, turning neither to the right nor to the left.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_14', 'hi', 'Hindi', '(साधक को) प्रशान्त अन्त:करण, निर्भय और ब्रह्मचर्य ब्रत में स्थित होकर, मन को संयमित करके चित्त को मुझमें लगाकर मुझे ही परम लक्ष्य समझकर बैठना चाहिए।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_14', 'en', 'English', 'With peace in his heart and nor fear, observing the vow of celibacy, with mind controlled and fixed on Me, let the student lose himself in contemplation of Me.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_15', 'hi', 'Hindi', 'इस प्रकार सदा मन को स्थिर करने का प्रयास करता हुआ संयमित मन का योगी मुझमें स्थित परम निर्वाण (मोक्ष) स्वरूप शांति को प्राप्त होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_15', 'en', 'English', 'Thus keeping his mind always in communion with Me, and with his thoughts subdued, he shall attain that Peace which is mine and which will lead him to liberation at last.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_16', 'hi', 'Hindi', 'परन्तु, हे अर्जुन ! यह योग उस पुरुष के लिए सम्भव नहीं होता, जो अधिक खाने वाला है या बिल्कुल न खाने वाला है तथा जो अधिक सोने वाला है या सदा जागने वाला है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_16', 'en', 'English', 'Meditation is not for him who eats too much, not for him who eats not at all; not for him who is overmuch addicted to sleep, not for him who is always awake.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_17', 'hi', 'Hindi', 'उस पुरुष के लिए योग दु:खनाशक होता है, जो युक्त आहार और विहार करने वाला है, यथायोग्य चेष्टा करने वाला है और परिमित शयन और जागरण करने वाला है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_17', 'en', 'English', 'But for him who regulates his food and recreation, who is balanced in action, in sleep and in waking, it shall dispel all unhappiness.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_18', 'hi', 'Hindi', 'वश में किया हुआ चित्त जिस कालमें अपने स्वरुपमें ही स्थित हो जाता है और स्वयं सम्पूर्ण पदार्थों नि: स्पृह हो जाता है, उस कालमें वह योगी कहा जाता है।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_18', 'en', 'English', 'When the mind, completely controlled, is centered in the Self, and free from all earthly desires, then is the man truly spiritual.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_19', 'hi', 'Hindi', 'जैसे स्पन्दनरहित वायुके स्थानमें स्थित दीपककी लौ चेष्टारहित हो जाती है, योगका अभ्यास करते हुए यतचित्तवाले योगीके चित्तकी वैसी ही उपमा कही गयी है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_19', 'en', 'English', 'The wise man who has conquered his mind and is absorbed in the Self is as a lamp which does not flicker, since it stands sheltered from every wind.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_20', 'hi', 'Hindi', 'योगका सेवन करनेसे जिस अवस्थामें निरुध्द चित्त उपराम हो जाता है तथा जिस अवस्थामें स्वयं अपने-आपमें अपने-आपको देखता हुआ अपने-आपमें सन्तुष्ट हो जाता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_20', 'en', 'English', 'There, where the whole nature is seen in the light of the Self, where the man abides within his Self and is satisfied there, its functions restrained by its union with the Divine, the mind finds rest.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_21', 'hi', 'Hindi', 'जो सुख आत्यन्तिक, अतीन्द्रिय और बुध्दिग्राह्म है, उस सुखका जिस अवस्थामें अनुभव करता है और जिस सुखमें स्थित हुआ यह ध्यानयोगी फिर कभी तत्वसे विचलित नहीं होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_21', 'en', 'English', 'When he enjoys the Bliss which passes sense, and which only the Pure Intellect can grasp, when he comes to rest within his own highest Self, never again will he stray from reality.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_22', 'hi', 'Hindi', 'जिस लाभकी प्राप्ति होनेपर उससे अधिक कोई दूसरा लाभ उसके माननेमें भी नहीं आता और जिसमें स्थित होनेपर वह बड़े भारी दु:ख से भी विचलित नहीं होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_22', 'en', 'English', 'Finding That, he will realise that there is no possession so precious. And when once established here, no calamity can disturb him.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_23', 'hi', 'Hindi', 'दु:ख के संयोग से वियोग है, उसीको ''योग'' नामसे जानना चाहिये । (वह योग जिस ध्यानयोग लक्ष्य है,) उस ध्यानयोका अभ्यास न उकताये हुए चित्तसे   निश्चयपूर्वक करना चाहिये।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_23', 'en', 'English', 'This inner severance from the affliction of misery is spirituality. It should be practised with determination and with a heart which refuses to be depressed.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_24', 'hi', 'Hindi', 'संकल्प से उत्पन्न समस्त कामनाओं को नि:शेष रूप से परित्याग कर मन के द्वारा इन्द्रिय समुदाय को सब ओर से सम्यक् प्रकार वश में करके।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_24', 'en', 'English', 'Renouncing every desire which imagination can conceive, controlling the senses at every point by the power of mind;', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_25', 'hi', 'Hindi', 'शनै: शनै: धैर्ययुक्त बुद्धि के द्वारा (योगी) उपरामता (शांति) को प्राप्त होवे;  मन को आत्मा में स्थित करके फिर अन्य कुछ भी चिन्तन न करे।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_25', 'en', 'English', 'Little by little, by the help of his reason controlled by fortitude, let him attain peace; and, fixing his mind on the Self, let him not think of any other thing.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_26', 'hi', 'Hindi', 'यह चंचल और अस्थिर मन जिन कारणों से (विषयों में) विचरण करता है, उनसे संयमित करके उसे आत्मा के ही वश में लावे अर्थात् आत्मा में स्थिर करे।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_26', 'en', 'English', 'When the volatile and wavering mind would wander, let him restrain it and bring it again to its allegiance to the Self.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_27', 'hi', 'Hindi', 'जिसका मन प्रशान्त है, जो पापरहित (अकल्मषम्) है और जिसका रजोगुण (विक्षेप) शांत हुआ है, ऐसे ब्रह्मरूप हुए इस योगी को उत्तम सुख प्राप्त होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_27', 'en', 'English', 'Supreme Bliss is the lot of the sage, whose mind attains Peace, whose passions subside, who is without sin, and who becomes one with the Absolute.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_28', 'hi', 'Hindi', 'इस प्रकार मन को सदा आत्मा में स्थिर करने का योग करने वाला पापरहित योगी सुखपूर्वक ब्रह्मसंस्पर्श का परम सुख प्राप्त करता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_28', 'en', 'English', 'Thus, free from sin, abiding always in the Eternal, the saint enjoys without effort the Bliss which flows from realisation of the Infinite.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_29', 'hi', 'Hindi', 'योगयुक्त अन्त:करण वाला और सर्वत्र समदर्शी योगी आत्मा को सब भूतों में और भूतमात्र को आत्मा में देखता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_29', 'en', 'English', 'He who experiences the unity of life sees his own Self in all beings, and all beings in his own Self, and looks on everything with an impartial eye;', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_30', 'hi', 'Hindi', 'जो पुरुष मुझे सर्वत्र देखता है और सबको मुझमें देखता है, उसके लिए मैं नष्ट नहीं होता (अर्थात् उसके लिए मैं दूर नहीं होता) और वह मुझसे वियुक्त नहीं होता।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_30', 'en', 'English', 'He who sees Me in everything and everything in Me, him shall I never forsake, nor shall he lose Me.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_31', 'hi', 'Hindi', 'जो पुरुष एकत्वभाव मंे स्थित हुआ सम्पूर्ण भूतों में स्थित मुझे भजता है, वह योगी सब प्रकार से वर्तता हुआ (रहता हुआ) मुझमें स्थित रहता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_31', 'en', 'English', 'The sage who realises the unity of life and who worships Me in all beings, lives in Me, whatever may be his lot.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_32', 'hi', 'Hindi', 'हे अर्जुन ! जो पुरुष अपने समान सर्वत्र सम देखता है, चाहे वह सुख हो या दु:ख, वह परम योगी माना गया है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_32', 'en', 'English', 'O Arjuna! He is the perfect saint who, taught by the likeness within himself, sees the same Self everywhere, whether the outer form be pleasurable or painful.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_33', 'hi', 'Hindi', 'अर्जुन ने कहा --  हे मधुसूदन ! जो यह साम्य योग आपने कहा, मैं मन के चंचल होने से इसकी चिरस्थायी स्थिति को नहीं देखता हूं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_33', 'en', 'English', 'Arjuna said: I do not see how I can attain this state of equanimity which Thou has revealed, owing to the restlessness of my mind.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_34', 'hi', 'Hindi', 'क्योंकि हे कृष्ण ! यह मन चंचल और प्रमथन स्वभाव का तथा बलवान् और दृढ़ है; उसका निग्रह करना मैं वायु के समान अति दुष्कर मानता हूँ ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_34', 'en', 'English', 'My Lord! Verily, the mind is fickle and turbulent, obstinate and strong, yea extremely difficult as the wind to control.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_35', 'hi', 'Hindi', 'श्रीभगवान् कहते हैं --  हे महबाहो ! नि:सन्देह मन चंचल और कठिनता से वश में होने वाला है; परन्तु, हे कुन्तीपुत्र ! उसे अभ्यास और वैराग्य के द्वारा वश में किया जा सकता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_35', 'en', 'English', 'Lord Shri Krishna replied: Doubtless, O Mighty One, the mind is fickle and exceedingly difficult to restrain, but, O Son of Kunti, with practice and renunciation it can be done.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_36', 'hi', 'Hindi', 'असंयत मन के पुरुष द्वारा योग प्राप्त होना कठिन है, परन्तु स्वाधीन मन वाले प्रयत्नशील पुरुष द्वारा उपाय से योग प्राप्त होना संभव है, यह मेरा मत है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_36', 'en', 'English', 'It is not possible to attain Self-Realisation if a man does not know how to control himself; but for him who, striving by proper means, learns such control, it is possible.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_37', 'hi', 'Hindi', 'अर्जुन ने कहा -- हे कृष्ण ! जिसका मन योग से चलायमान हो गया है, ऐसा अपूर्ण प्रयत्न वाला (अयति) श्रद्धायुक्त पुरुष योग की सिद्धि को न प्राप्त होकर किस गति को प्राप्त होता है?', FALSE, 'Swami Tejomayananda'),
  ('bg_6_37', 'en', 'English', 'Arjuna asked: He who fails to control himself, whose mind falls from spiritual contemplation, who attains not perfection but retains his faith, what of him, my Lord?', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_38', 'hi', 'Hindi', 'हे महबाहो ! क्या वह ब्रह्म के मार्ग में मोहित तथा आश्रयरहित पुरुष छिन्न-भिन्न मेघ के समान दोनों ओर से भ्रष्ट हुआ नष्ट तो नहीं हो जाता है?', FALSE, 'Swami Tejomayananda'),
  ('bg_6_38', 'en', 'English', 'Shri Purohit Swami did not comment on this sloka', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_39', 'hi', 'Hindi', 'हे कृष्ण ! मेरे इस संशय को नि:शेष रूप से छेदन (निराकरण) करने के लिए आप ही योग्य है; क्योंकि आपके अतिरिक्त अन्य कोई इस संशय का छेदन करन वाला (छेत्ता) मिलना संभव नहीं है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_39', 'en', 'English', 'My Lord! Thou art worthy to solve this doubt once and for all; save Thyself there is no one competent to do so.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_40', 'hi', 'Hindi', 'श्रीभगवान् ने कहा -- हे पार्थ ! उस पुरुष का, न तो इस लोक में और न ही परलोक में ही नाश होता है; हे तात ! कोई भी शुभ कर्म करने वाला दुर्गति को नहीं प्राप्त होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_40', 'en', 'English', 'Lord Shri Krishna replied: My beloved child! There is no destruction for him, either in this world or in the next. No evil fate awaits him who treads the path of righteousness.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_41', 'hi', 'Hindi', 'योगभ्रष्ट पुरुष पुण्यवानों के लोकों को प्राप्त होकर वहाँ दीर्घकाल तक वास करके शुद्ध आचरण वाले श्रीमन्त (धनवान) पुरुषों के घर में जन्म लेता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_41', 'en', 'English', 'Having reached the worlds where the righteous dwell, and having remained there for many years, he who has slipped from the path of spirituality will be born again in the family of the pure, benevolent and prosperous.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_42', 'hi', 'Hindi', 'अथवा, (साधक) ज्ञानवान् योगियों के ही कुल में जन्म लेता है, परन्तु इस प्रकार का जन्म इस लोक में नि:संदेह अति दुर्लभ है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_42', 'en', 'English', 'Or, he may be born in the family of the wise sages, though a birth like this is, indeed, very difficult to obtain.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_43', 'hi', 'Hindi', 'हे कुरुनन्दन ! वह पुरुष वहाँ पूर्व देह में प्राप्त किये गये ज्ञान से सम्पन्न होकर योगसंसिद्धि के लिए उससे भी अधिक प्रयत्न करता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_43', 'en', 'English', 'Then the experience acquired in his former life will revive, and with its help he will strive for perfection more eagerly than before.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_44', 'hi', 'Hindi', 'उसी पूर्वाभ्यास के कारण वह अवश हुआ योग की ओर आकर्षित होता है। योग का जो केवल जिज्ञासु है वह शब्दब्रह्म का अतिक्रमण करता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_44', 'en', 'English', 'Unconsciously he will return to the practices of his old life; so that he who tries to realise spiritual consciousness is certainly superior to one who only talks of it.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_45', 'hi', 'Hindi', 'परन्तु प्रयत्नपूर्वक अभ्यास करने वाला योगी सम्पूर्ण पापों से शुद्ध होकर अनेक जन्मों से (शनै: शनै:) सिद्ध होता हुआ, तब परम गति को प्राप्त होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_45', 'en', 'English', 'Then after many lives, the student of spirituality, who earnestly strives, and whose sins are absolved, attains perfection and reaches the Supreme.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_46', 'hi', 'Hindi', 'क्योंकि योगी तपस्वियों से श्रेष्ठ है और (केवल शास्त्र के) ज्ञान वालों से भी श्रेष्ठ माना गया है तथा कर्म करने वालों से भी योगी श्रेष्ठ है, इसलिए हे अर्जुन तुम योगी बनो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_46', 'en', 'English', 'The wise man is superior to the ascetic and to the scholar and to the man of action; therefore be thou a wise man, O Arjuna!', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_6_47', 'hi', 'Hindi', 'समस्त योगियों में जो भी श्रद्धावान् योगी मुझ में युक्त हुये अन्तरात्मा से (अर्थात् एकत्व भाव से मुझे भजता है, वह मुझे युक्ततम (सर्वश्रेष्ठ) मान्य है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_6_47', 'en', 'English', 'I look upon him as the best of mystics who, full of faith, worshippeth Me and abideth in Me."', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_7_1', 'hi', 'Hindi', 'हे पार्थ ! मुझमें असक्त हुए मन वाले तथा मदाश्रित होकर योग का अभ्यास करते हुए जिस प्रकार तुम मुझे समग्ररूप से, बिना किसी संशय के, जानोगे वह सुनो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_7_1', 'en', 'English', '"Lord Shri Krishna said: Listen, O Arjuna! And I will tell thee how thou shalt know Me in my Full perfection, practising meditation with thy mind devoted to Me, and having Me for thy refuge.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_7_2', 'hi', 'Hindi', 'मैं तुम्हारे लिए विज्ञान सहित इस ज्ञान को अशेष रूप से कहूँगा जिसको जानकर यहाँ (जगत् में) फिर और कुछ जानने योग्य (ज्ञातव्य) शेष नहीं रह जाता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_7_2', 'en', 'English', 'I will reveal to this knowledge unto thee, and how it may be realised; which, once accomplished, there remains nothing else worth having in this life.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_7_3', 'hi', 'Hindi', 'सहस्रों मनुष्यों में कोई ही मनुष्य पूर्णत्व की सिद्धि के लिए प्रयत्न करता है और उन प्रयत्नशील साधकों में भी कोई ही पुरुष मुझे तत्त्व से जानता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_7_3', 'en', 'English', 'Among thousands of men scarcely one strives for perfection, and even amongst those who gain occult powers, perchance but one knows me in truth.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_7_4', 'hi', 'Hindi', 'पृथ्वी, जल, अग्नि, वायु और आकाश तथा मन, बुद्धि और अहंकार - यह आठ प्रकार से विभक्त हुई मेरी प्रकृति है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_7_4', 'en', 'English', 'Earth, water, fire, air, ether, mind, intellect and personality; this is the eightfold division of My Manifested Nature.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_7_5', 'hi', 'Hindi', 'हे महाबाहो ! यह अपरा प्रकृति है। इससे भिन्न मेरी जीवरूपी पराप्रकृति को जानो, जिससे यह जगत् धारण किया जाता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_7_5', 'en', 'English', 'This is My inferior Nature; but distinct from this, O Valiant One, know thou that my Superior Nature is the very Life which sustains the universe.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_7_6', 'hi', 'Hindi', 'यह जानो कि समम्पूर्ण भूत इन दोनों प्रकृतियों से उत्पत्ति वाले हैं। (अत:) मैं सम्पूर्ण जगत् का उत्पत्ति तथा प्रलय स्थान हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_7_6', 'en', 'English', 'It is the womb of all being; for I am He by Whom the worlds were created and shall be dissolved.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_7_7', 'hi', 'Hindi', 'हे धनंजय ! मुझसे श्रेष्ठ (परे) अन्य किचिन्मात्र वस्तु नहीं है। यह सम्पूर्ण जगत् सूत्र में मणियों के सदृश मुझमें पिरोया हुआ है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_7_7', 'en', 'English', 'O Arjuna! There is nothing higher than Me; all is strung upon Me as rows of pearls upon a thread.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_7_8', 'hi', 'Hindi', 'हे कौन्तेय ! जल में मैं रस हूँ, चन्द्रमा और सूर्य में प्रकाश हूँ, सब वेदों में प्रणव (ँ़कार) हूँ तथा आकाश में शब्द और पुरुषों में पुरुषत्व हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_7_8', 'en', 'English', 'O Arjuna! I am the Fluidity in water, the Light in the sun and in the moon. I am the mystic syllable Om in the Vedic scriptures, the Sound in ether, the Virility in man.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_7_9', 'hi', 'Hindi', 'पृथ्वी में पवित्र गन्ध हूँ और अग्नि में तेज हूँ; सम्पूर्ण भूतों में जीवन हूँ और तपस्वियों में मैं तप हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_7_9', 'en', 'English', 'I am the Fragrance of earth, the Brilliance of fire. I am the Life Force in all beings, and I am the Austerity of the ascetics.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_7_10', 'hi', 'Hindi', 'हे पार्थ ! सम्पूर्ण भूतों का सनातन बीज (कारण) मुझे ही जानो; मैं बुद्धिमानों की बुद्धि और तेजस्वियों का तेज हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_7_10', 'en', 'English', 'Know, O Arjuna, that I am the eternal Seed of being; I am the Intelligence of the intelligent, the Splendour of the resplendent.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_7_11', 'hi', 'Hindi', 'हे भरत श्रेष्ठ ! मैं बलवानों का कामना तथा आसक्ति से रहित बल हूँ और सब भूतों में धर्म के अविरुद्ध अर्थात् अनुकूल काम हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_7_11', 'en', 'English', 'I am the Strength of the strong, of them who are free from attachment and desire; and, O Arjuna, I am the Desire for righteousness.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_7_12', 'hi', 'Hindi', 'जो भी सात्त्विक (शुद्ध), राजसिक (क्रियाशील) और तामसिक (जड़) भाव हैं, उन सबको तुम मेरे से उत्पन्न हुए जानो; तथापि मैं उनमें नहीं हूँ, वे मुझमें हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_7_12', 'en', 'English', 'Whatever be the nature of their life, whether it be pure or passionate or ignorant, they are all derived from Me. They are in Me, but I am not in them.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_7_13', 'hi', 'Hindi', 'त्रिगुणों से उत्पन्न इन भावों (विकारों) से सम्पूर्ण जगत् (लोग) मोहित हुआ इन (गुणों) से परे अव्यय स्वरूप मुझे नहीं जानता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_7_13', 'en', 'English', 'The inhabitants of the world, misled by those natures which the Qualities have engendered, know not that I am higher than them all, and that I do not change.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_7_14', 'hi', 'Hindi', 'यह दैवी त्रिगुणमयी मेरी माया बड़ी दुस्तर है। परन्तु जो मेरी शरण में आते हैं, वे इस माया को पार कर जाते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_7_14', 'en', 'English', 'Verily, this Divine Illusion of Phenomenon manifesting itself in the Qualities is difficult to surmount. Only they who devote themselves to Me and to Me alone can accomplish it.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_7_15', 'hi', 'Hindi', 'दुष्कृत्य करने वाले, मूढ, नराधम पुरुष मुझे नहीं भजते हैं; माया के द्वारा जिनका ज्ञान हर लिया गया है, वे आसुरी भाव को धारण किये रहते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_7_15', 'en', 'English', 'The sinner, the ignorant, the vile, deprived of spiritual perception by the glamour of Illusion, and he who pursues a godless life - none of them shall find Me.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_7_16', 'hi', 'Hindi', 'हे भरत श्रेष्ठ अर्जुन ! उत्तम कर्म करने वाले (सुकृतिन:) आर्त, जिज्ञासु, अर्थार्थी और ज्ञानी ऐसे चार प्रकार के लोग मुझे भजते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_7_16', 'en', 'English', 'O Arjuna! The righteous who worship Me are grouped by stages: first, they who suffer, next they who desire knowledge, then they who thirst after truth, and lastly they who attain wisdom.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_7_17', 'hi', 'Hindi', 'उनमें भी मुझ से नित्ययुक्त, अनन्य भक्ति वाला ज्ञानी श्रेष्ठ है, क्योंकि ज्ञानी को मैं अत्यन्त प्रिय हूँ और वह मुझे अत्यन्त प्रिय है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_7_17', 'en', 'English', 'Of all of these, he who has gained wisdom, who meditates on Me without ceasing, devoting himself only to Me, he is the best; for by the wise man I am exceedingly beloved and the wise man, too, is beloved by Me.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_7_18', 'hi', 'Hindi', '(यद्यपि) ये सब उत्कृष्ट हैं, परन्तु ज्ञानी तो मेरा स्वरूप ही है ऐसा मेरा मत है, क्योंकि वह स्थिर बुद्धि ज्ञानी अति उत्तम गतिस्वरूप मुझमें अच्छी प्रकार स्थित है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_7_18', 'en', 'English', 'Noble-minded are they all, but the wise man I hold as my own Self; for he, remaining always at peace with Me, makes me his final goal.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_7_19', 'hi', 'Hindi', 'बहुत जन्मों के अन्त में (किसी एक जन्म विशेष में) ज्ञान को प्राप्त होकर कि ''यह सब वासुदेव है'' ज्ञानी भक्त मुझे प्राप्त होता है; ऐसा महात्मा अति दुर्लभ है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_7_19', 'en', 'English', 'After many lives, at last the wise man realises Me as I am. A man so enlightened that he sees God everywhere is very difficult to find.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_7_20', 'hi', 'Hindi', 'भोगविशेष की कामना से जिनका ज्ञान हर लिया गया है, ऐसे पुरुष अपने स्वभाव से प्रेरित हुए अन्य देवताओं को विशिष्ट नियम का पालन करते हुए भजते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_7_20', 'en', 'English', 'They in whom wisdom is obscured by one desire or the other, worship the lesser Powers, practising many rites which vary according to their temperaments.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_7_21', 'hi', 'Hindi', 'जो-जो (सकामी) भक्त जिस-जिस (देवता के) रूप को श्रद्धा से पूजना चाहता है, उस-उस (भक्त) की मैं उस ही देवता के प्रति श्रद्धा को स्थिर करता हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_7_21', 'en', 'English', 'But whatever the form of worship, if the devotee have faith, then upon his faith in that worship do I set My own seal.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_7_22', 'hi', 'Hindi', 'वह (भक्त) उस श्रद्धा से युक्त होकर उस देवता का पूजन करता है और उससे मेरे द्वारा विधान किये हुये इच्छित भोगों को नि:सन्देह प्राप्त करता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_7_22', 'en', 'English', 'If he worships one form alone with real faith, then shall his desires be fulfilled through that only; for thus have I ordained.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_7_23', 'hi', 'Hindi', 'परन्तु उन अल्प बुद्धि पुरुषों का वह फल नाशवान् होता है। देवताओं के पूजक देवताओं को प्राप्त होते हैं और मेरे भक्त मुझे ही प्राप्त होते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_7_23', 'en', 'English', 'The fruit that comes to men of limited insight is, after all, finite. They who worship the Lower Powers attain them; but those who worship Me come unto Me alone.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_7_24', 'hi', 'Hindi', 'बुद्धिहीन पुरुष मेरे अनुत्तम (सर्वोत्तम) अव्यय परम भाव को न जानते हुए मुझ अव्यक्त को व्यक्त मानते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_7_24', 'en', 'English', 'The ignorant think of Me, who am the Unmanifested Spirit, as if I were really in human form. They do not understand that My Superior Nature is changeless and most excellent.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_7_25', 'hi', 'Hindi', 'अपनी योगमाया से आवृत्त मैं सबको प्रत्यक्ष नहीं होता हूँ। यह मोहित लोक (मनुष्य) मुझ जन्मरहित, अविनाशी को नहीं जानता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_7_25', 'en', 'English', 'I am not visible to all, for I am enveloped by the illusion of Phenomenon. This deluded world does not know Me as the Unborn and the Imperishable.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_7_26', 'hi', 'Hindi', 'हे अर्जुन ! पूर्व में व्यतीत हुए और वर्तमान में स्थित तथा भविष्य में होने वाले भूतमात्र को मैं जानता हूँ, परन्तु मुझे कोई भी पुरुष नहीं जानता हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_7_26', 'en', 'English', 'I know, O Arjuna, all beings in the past, the present and the future; but they do not know Me.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_7_27', 'hi', 'Hindi', 'हे परन्तप भारत ! इच्छा और द्वेष से उत्पन्न द्वन्द्वमोह से भूतमात्र उत्पत्ति काल में ही संमोह (अविवेक) को प्राप्त होते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_7_27', 'en', 'English', 'O brave Arjuna! Man lives in a fairy world, deceived by the glamour of opposite sensations, infatuated by desire and aversion.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_7_28', 'hi', 'Hindi', 'परन्तु जिन पुण्यकर्मी पुरुषों का पाप नष्ट हो गया है, वे द्वन्द्वमोह से निर्मुक्त और दृढ़वती पुरुष मुझे भजते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_7_28', 'en', 'English', 'But those who act righteously, in whom sin has been destroyed, who are free from the infatuation of the conflicting emotions, they worship Me with firm resolution.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_7_29', 'hi', 'Hindi', 'जो मेरे शरणागत होकर जरा और मरण से मुक्ति पाने के लिए यत्न करते हैं, वे पुरुष उस ब्रह्म को, सम्पूर्ण अध्यात्म को और सम्पूर्ण कर्म को जानते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_7_29', 'en', 'English', 'Those who make Me their refuge, who strive for liberation from decay and Death, they realise the Supreme Spirit, which is their own real Self, and in which all action finds its consummation.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_7_30', 'hi', 'Hindi', 'जो पुरुष अधिभूत और अधिदैव तथा अधियज्ञ के सहित मुझे जानते हैं, वे युक्तचित्त वाले पुरुष अन्तकाल में भी मुझे जानते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_7_30', 'en', 'English', 'Those who see Me in the life of the world, in the universal sacrifice, and as pure Divinity, keeping their minds steady, they live in Me, even in the crucial hour of death."', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_8_1', 'hi', 'Hindi', 'अर्जुन ने कहा -हे पुरुषोत्तम ! वह ब्रह्म क्या है अध्यात्म क्या है? तथा कर्म क्या है? और अधिभूत नाम से क्या कहा गया है? तथा अधिदैव नाम से क्या कहा जाता है,', FALSE, 'Swami Tejomayananda'),
  ('bg_8_1', 'en', 'English', 'Shri Purohit Swami did not comment on this sloka', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_8_2', 'hi', 'Hindi', 'और हे मधुसूदन ! यहाँ अधियज्ञ कौन है? और वह इस शरीर में कैसे है? और संयत चित्त वाले पुरुषों द्वारा अन्त समय में आप किस प्रकार जाने जाते हैं,', FALSE, 'Swami Tejomayananda'),
  ('bg_8_2', 'en', 'English', 'Who is it who rules the spirit sacrifice in many; and at the time of death how may those who have learned self-control come to the knowledge of Thee?', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_8_3', 'hi', 'Hindi', 'श्रीभगवान् ने कहा -- परम अक्षर (अविनाशी) तत्त्व ब्रह्म है; स्वभाव (अपना स्वरूप) अध्यात्म कहा जाता है; भूतों के भावों को उत्पन्न करने वाला विसर्ग (यज्ञ, प्रेरक बल) कर्म नाम से जाना जाता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_8_3', 'en', 'English', 'The Lord Shri Krishna replied: The Supreme Spirit is the Highest Imperishable Self, and Its Nature is spiritual consciousness. The worlds have been created and are supported by an emanation from the Spirit which is called the Law.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_8_4', 'hi', 'Hindi', 'हे देहधारियों में श्रेष्ठ अर्जुन ! नश्वर वस्तु (पंचमहाभूत) अधिभूत और पुरुष अधिदैव है; इस शरीर में मैं ही अधियज्ञ हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_8_4', 'en', 'English', 'Matter consists of the forms that perish; Divinity is the Supreme Self; and He who inspires the spirit of sacrifice in man, O noblest of thy race, is I Myself, Who now stand in human form before thee.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_8_5', 'hi', 'Hindi', 'और जो कोई पुरुष अन्तकाल में मुझे ही स्मरण करता हुआ शरीर को त्याग कर जाता है, वह मेरे स्वरूप को प्राप्त होता है, इसमें कुछ भी संशय नहीं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_8_5', 'en', 'English', 'Whosoever at the time of death thinks only of Me, and thinking thus leaves the body and goes forth, assuredly he will know Me.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_8_6', 'hi', 'Hindi', 'हे कौन्तेय ! (यह जीव) अन्तकाल में जिस किसी भी भाव को स्मरण करता हुआ शरीर को त्यागता है, वह सदैव उस भाव के चिन्तन के फलस्वरूप उसी भाव को ही प्राप्त होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_8_6', 'en', 'English', 'On whatever sphere of being the mind of a man may be intent at the time of death, thither he will go.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_8_7', 'hi', 'Hindi', 'इसलिए, तुम सब काल में मेरा निरन्तर स्मरण करो; और युद्ध करो मुझमें अर्पण किये मन, बुद्धि से युक्त हुए निःसन्देह तुम मुझे ही प्राप्त होओगे।।', FALSE, 'Swami Tejomayananda'),
  ('bg_8_7', 'en', 'English', 'Therefore meditate always on Me, and fight; if thy mind and thy reason be fixed on Me, to Me shalt thou surely come.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_8_8', 'hi', 'Hindi', 'हे पार्थ ! अभ्यासयोग से युक्त अन्यत्र न जाने वाले चित्त से निरन्तर चिन्तन करता हुआ (साधक) परम दिव्य पुरुष को प्राप्त होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_8_8', 'en', 'English', 'He whose mind does not wander, and who is engaged in constant meditation, attains the Supreme Spirit.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_8_9', 'hi', 'Hindi', 'जो पुरुष सर्वज्ञ, प्राचीन (पुराण), सबके नियन्ता, सूक्ष्म से भी सूक्ष्मतर, सब के धाता, अचिन्त्यरूप, सूर्य के समान प्रकाश रूप और (अविद्या) अन्धकार से परे तत्त्व का अनुस्मरण करता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_8_9', 'en', 'English', 'Whoso meditates on the Omniscient, the Ancient, more minute than the atom, yet the Ruler and Upholder of all, Unimaginable, Brilliant like the Sun, Beyond the reach of darkness;', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_8_10', 'hi', 'Hindi', 'वह (साधक) अन्तकाल में योगबल से प्राण को भ्रकुटि के मध्य सम्यक् प्रकार स्थापन करके निश्चल मन से भक्ति युक्त होकर उस परम दिव्य पुरुष को प्राप्त होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_8_10', 'en', 'English', 'He who leaves the body with mind unmoved and filled with devotion, by the power of his meditation gathering between his eyebrows his whole vital energy, attains the Supreme.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_8_11', 'hi', 'Hindi', 'वेद के जानने वाले विद्वान जिसे अक्षर कहते हैं; रागरहित यत्नशील पुरुष जिसमें प्रवेश करते हैं; जिसकी इच्छा से (साधक गण) ब्रह्मचर्य का पालन करते हैं - उस पद (लक्ष्य) को मैं तुम्हें संक्षेप में कहूँगा।।', FALSE, 'Swami Tejomayananda'),
  ('bg_8_11', 'en', 'English', 'Now I will speak briefly of the imperishable goal, proclaimed by those versed in the scriptures, which the mystic attains when free from passion, and for which he is content to undergo the vow of continence.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_8_12', 'hi', 'Hindi', 'सब (इन्द्रियों के) द्वारों को संयमित कर मन को हृदय में स्थिर करके और प्राण को मस्तक में स्थापित करके योगधारणा में स्थित हुआ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_8_12', 'en', 'English', 'Closing the gates of the body, drawing the forces of his mind into the heart and by the power of meditation concentrating his vital energy in the brain;', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_8_13', 'hi', 'Hindi', 'जो पुरुष ओऽम् इस एक अक्षर ब्रह्म का उच्चारण करता हुआ और मेरा स्मरण करता हुआ शरीर का त्याग करता है, वह परम गति को प्राप्त होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_8_13', 'en', 'English', 'Repeating Om, the Symbol of Eternity, holding Me always in remembrance, he who thus leaves his body and goes forth reaches the Spirit Supreme.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_8_14', 'hi', 'Hindi', 'हे पार्थ ! जो अनन्यचित्त वाला पुरुष मेरा स्मरण करता है, उस नित्ययुक्त योगी के लिए मैं सुलभ हूँ अर्थात् सहज ही प्राप्त हो जाता हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_8_14', 'en', 'English', 'To him who thinks constantly of Me, and of nothing else, to such an ever-faithful devotee, O Arjuna, am I ever accessible.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_8_15', 'hi', 'Hindi', 'परम सिद्धि को प्राप्त हुये महात्माजन मुझे प्राप्त कर अनित्य दुःख के आलयरूप (गृहरूप) पुनर्जन्म को नहीं प्राप्त होते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_8_15', 'en', 'English', 'Coming thus unto Me, these great souls go no more to the misery and death of earthly life, for they have gained perfection.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_8_16', 'hi', 'Hindi', 'हे अर्जुन ! ब्रह्म लोक तक के सब लोग पुनरावर्ती स्वभाव वाले हैं। परन्तु, हे कौन्तेय ! मुझे प्राप्त होने पर पुनर्जन्म नहीं होता।।', FALSE, 'Swami Tejomayananda'),
  ('bg_8_16', 'en', 'English', 'The worlds, with the whole realm of creation, come and go; but, O Arjuna, whoso comes to Me, for him there is nor rebirth.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_8_17', 'hi', 'Hindi', 'जो लोग ब्रह्मा जी के एक दिन की अवधि जानते हैं जो कि सहस्र वर्ष की है तथा एक सहस्र वर्ष की अवधि की एक रात्रि को जानते हैं वे दिन और रात्रि को जानने वाले पुरुष हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_8_17', 'en', 'English', 'Those who understand the cosmic day and cosmic night know that one day of creation is a thousand cycles, and that the night is of equal length.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_8_18', 'hi', 'Hindi', '(ब्रह्माजी के) दिन का उदय होने पर अव्यक्त से (यह) व्यक्त (चराचर जगत्) उत्पन्न होता है; और (ब्रह्माजी की) रात्रि के आगमन पर उसी अव्यक्त में लीन हो जाता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_8_18', 'en', 'English', 'At the dawning of that day all objects in manifestation stream forth from the Unmanifest, and when evening falls they are dissolved into It again.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_8_19', 'hi', 'Hindi', 'हे पार्थ ! वही यह भूतसमुदाय, है जो पुनः पुनः उत्पन्न होकर लीन होता है। अवश हुआ (यह भूतग्राम) रात्रि के आगमन पर लीन तथा दिन के उदय होने पर व्यक्त होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_8_19', 'en', 'English', 'The same multitude of beings, which have lived on earth so often, all are dissolved as the night of the universe approaches, to issue forth anew when morning breaks. Thus is it ordained.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_8_20', 'hi', 'Hindi', 'परन्तु उस अव्यक्त से परे अन्य जो सनातन अव्यक्त भाव है, वह समस्त भूतों के नष्ट होने पर भी नष्ट नहीं होता।।', FALSE, 'Swami Tejomayananda'),
  ('bg_8_20', 'en', 'English', 'In truth, therefore, there is the Eternal Unmanifest, which is beyond and above the Unmanifest Spirit of Creation, which is never destroyed when all these being perish.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_8_21', 'hi', 'Hindi', 'जो अव्यक्त अक्षर कहा गया है, वही परम गति (लक्ष्य) है। जिसे प्राप्त होकर (साधकगण) पुनः (संसार को) नहीं लौटते, वह मेरा परम धाम है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_8_21', 'en', 'English', 'The wise say that the Unmanifest and Indestructible is the highest goal of all; when once That is reached, there is no return. That is My Blessed Home.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_8_22', 'hi', 'Hindi', 'हे पार्थ ! जिस (परमात्मा) के अन्तर्गत समस्त भूत हैं और जिससे यह सम्पूर्ण (जगत्) व्याप्त है, वह परम पुरुष अनन्य भक्ति से ही प्राप्त करने योग्य है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_8_22', 'en', 'English', 'O Arjuna! That Highest God, in Whom all beings abide, and Who pervades the entire universe, is reached only by wholehearted devotion. [The following material (between the asterisks) is an example of what may be a "doctored'' inclusion. It does not jibe with the rest of the material because it is not presented as metaphor and clearly implies that worldly phenomena are spiritually determining. Maybe it was added by an individual or individuals who were less cognizant than the originating author. Or maybe was ''craftily'' inserted to function as a sort of litmus test - those who get"taken in'' by it may be recognized as not having "spiritual discernment''.]', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_8_23', 'hi', 'Hindi', 'हे भरतश्रेष्ठ ! जिस काल में (मार्ग में) शरीर त्याग कर गये हुए योगीजन अपुनरावृत्ति को, और (या) पुनरावृत्ति को प्राप्त होते हैं, वह काल (मार्ग) मैं तुम्हें बताऊँगा।।', FALSE, 'Swami Tejomayananda'),
  ('bg_8_23', 'en', 'English', '*Now I will tell thee, O Arjuna, of the times at which, if the mystics go forth, they do not return, and at which they go forth only to return.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_8_24', 'hi', 'Hindi', 'जो ब्रह्मविद् साधकजन मरणोपरान्त अग्नि, ज्योति, दिन, शुक्लपक्ष और उत्तरायण के छः मास वाले मार्ग से जाते हैं, वे ब्रह्म को प्राप्त होते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_8_24', 'en', 'English', 'If knowing the Supreme Spirit the sage goes forth with fire and light, in the daytime, in the fortnight of the waxing moon and in the six months before the Northern summer solstice, he will attain the Supreme.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_8_25', 'hi', 'Hindi', 'धूम, रात्रि, कृष्णपक्ष और दक्षिणायन के छः मास वाले मार्ग से चन्द्रमा की ज्योति को प्राप्त कर, योगी (संसार को) लौटता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_8_25', 'en', 'English', 'But if he departs in gloom, at night, during the fortnight of the waning moon and in the six months before the Southern solstice, then he reaches but lunar light and he will be born again.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_8_26', 'hi', 'Hindi', 'जगत् के ये दो प्रकार के शुक्ल और कृष्ण मार्ग सनातन माने गये हैं । इनमें एक (शुक्ल) के द्वारा (साधक) अपुनरावृत्ति को तथा अन्य (कृष्ण) के द्वारा पुनरावृत्ति को प्राप्त होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_8_26', 'en', 'English', 'These bright and dark paths out of the world have always existed. Whoso takes the former, returns not; he who chooses the latter, returns.*', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_8_27', 'hi', 'Hindi', 'हे पार्थ इन दो मार्गों को (तत्त्व से) जानने वाला कोई भी योगी मोहित नहीं होता। इसलिए, हे अर्जुन ! तुम सब काल में योगयुक्त बनो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_8_27', 'en', 'English', 'O Arjuna! The saint knowing these paths is not confused. Therefore meditate perpetually.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_8_28', 'hi', 'Hindi', 'योगी पुरुष यह सब (दोनों मार्गों के तत्त्व को) जानकर वेदाध्ययन, यज्ञ, तप और दान करने में जो पुण्य फल कहा गया है, उस सबका उल्लंघन कर जाता है और आद्य (सनातन), परम स्थान को प्राप्त होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_8_28', 'en', 'English', 'The sage who knows this passes beyond all merit that comes from the study of the scriptures, from sacrifice, from austerities and charity, and reaches the Supreme Primeval Abode."', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_9_1', 'hi', 'Hindi', 'श्रीभगवान् ने कहा -- तुम अनसूयु (दोष दृष्टि रहित) के लिए मैं इस गुह्यतम ज्ञान को विज्ञान के सहित कहूँगा, जिसको जानकर तुम अशुभ (संसार बंधन) से मुक्त हो जाओगे।।', FALSE, 'Swami Tejomayananda'),
  ('bg_9_1', 'en', 'English', '"Lord Shri Krishna said: I will now reveal to thee, since thou doubtest not, that profound mysticism, which when followed by experience, shall liberate thee from sin.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_9_2', 'hi', 'Hindi', 'यह ज्ञान राजविद्या (विद्याओं का राजा) और राजगुह्य (सब गुह्यों अर्थात् रहस्यों का राजा) एवं पवित्र, उत्तम, प्रत्यक्ष ज्ञानवाला और धर्मयुक्त है, तथा करने में सरल और अव्यय है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_9_2', 'en', 'English', 'This is the Premier Science, the Sovereign Secret, the Purest and Best; intuitional, righteous; and to him who practiseth it pleasant beyond measure.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_9_3', 'hi', 'Hindi', 'हे परन्तप ! इस धर्म में श्रद्धारहित पुरुष मुझे प्राप्त न होकर मृत्युरूपी संसार में रहते हैं (भ्रमण करते हैं)।।', FALSE, 'Swami Tejomayananda'),
  ('bg_9_3', 'en', 'English', 'They who have no faith in this teaching cannot find Me, but remain lost in the purlieus of this perishable world.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_9_4', 'hi', 'Hindi', 'यह सम्पूर्ण जगत् मुझ (परमात्मा) के अव्यक्त स्वरूप से व्याप्त है; भूतमात्र मुझमें स्थित है, परन्तु मैं उनमें स्थित नहीं हूं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_9_4', 'en', 'English', 'The whole world is pervaded by Me, yet My form is not seen. All living things have their being in Me, yet I am not limited by them.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_9_5', 'hi', 'Hindi', 'और (वस्तुत:) भूतमात्र मुझ में स्थित नहीं है; मेरे ईश्वरीय योग को देखो कि भूतों को धारण करने वाली और भूतों को उत्पन्न करने वाली मेरी आत्मा उन भूतों में स्थित नहीं है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_9_5', 'en', 'English', 'Nevertheless, they do not consciously abide in Me. Such is My Divine Sovereignty that though I, the Supreme Self, am the cause and upholder of all, yet I remain outside.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_9_6', 'hi', 'Hindi', 'जैसे सर्वत्र विचरण करने वाली महान् वायु सदा आकाश में स्थित रहती हैं, वैसे ही सम्पूर्ण भूत मुझमें स्थित हैं, ऐसा तुम जानो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_9_6', 'en', 'English', 'As the mighty wind, though moving everywhere, has no resting place but space, so have all these beings no home but Me.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_9_7', 'hi', 'Hindi', 'हे कौन्तेय ! (एक) कल्प के अन्त में समस्त भूत मेरी प्रकृति को प्राप्त होते हैं; और (दूसरे) कल्प के प्रारम्भ में उनको मैं फिर रचता हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_9_7', 'en', 'English', 'All beings, O Arjuna, return at the close of every cosmic cycle into the realm of Nature, which is a part of Me, and at the beginning of the next I send them forth again.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_9_8', 'hi', 'Hindi', 'प्रकृति को अपने वश में करके (अर्थात् उसे चेतनता प्रदान कर) स्वभाव के वश से परतन्त्र (अवश) हुए इस सम्पूर्ण भूत समुदाय को मैं पुन:-पुन: रचता हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_9_8', 'en', 'English', 'With the help of Nature, again and again I pour forth the whole multitude of beings, whether they will or no, for they are ruled by My Will.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_9_9', 'hi', 'Hindi', 'हे धनंजय ! उन कर्मों में आसक्ति रहित और उदासीन के समान स्थित मुझ (परमात्मा) को वे कर्म नहीं बांधते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_9_9', 'en', 'English', 'But these acts of mine do not bind Me. I remain outside and unattached.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_9_10', 'hi', 'Hindi', 'हे कौन्तेय ! मुझ अध्यक्ष के कारण ( अर्थात् मेरी अध्यक्षता में) प्रकृति चराचर जगत् को उत्पन्न करती है; इस कारण यह जगत् घूमता रहता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_9_10', 'en', 'English', 'Under my guidance, Nature produces all things movable and immovable. Thus it is, O Arjuna, that this universe revolves.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_9_11', 'hi', 'Hindi', 'समस्त भूतों के महान् ईश्वर रूप मेरे परम भाव को नहीं जानते हुए मूढ़ लोग मनुष्य शरीरधारी मुझ परमात्मा का अनादर करते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_9_11', 'en', 'English', 'Fools disregard Me, seeing Me clad in human form. They know not that in My higher nature I am the Lord-God of all.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_9_12', 'hi', 'Hindi', 'वृथा आशा, वृथा कर्म और वृथा ज्ञान वाले अविचारीजन राक्षसों के और असुरों के मोहित करने वाले स्वभाव को धारण किये रहते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_9_12', 'en', 'English', 'Their hopes are vain, their actions worthless, their knowledge futile; they are without sense, deceitful, barbarous and godless.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_9_13', 'hi', 'Hindi', 'हे पार्थ ! परन्तु दैवी प्रकृति के आश्रित महात्मा पुरुष मुझे समस्त भूतों का आदिकारण और अव्ययस्वरूप जानकर अनन्यमन से युक्त होकर मुझे भजते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_9_13', 'en', 'English', 'But the Great Souls, O Arjuna! Filled with My Divine Spirit, they worship Me, they fix their minds on Me and on Me alone, for they know that I am the imperishable Source of being.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_9_14', 'hi', 'Hindi', 'सतत मेरा कीर्तन करते हुए, प्रयत्नशील, दढ़व्रती पुरुष मुझे नमस्कार करते हुए, नित्ययुक्त होकर भक्तिपूर्वक मेरी उपासना करते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_9_14', 'en', 'English', 'Always extolling Me, strenuous, firm in their vows, prostrating themselves before Me, they worship Me continually with concentrated devotion.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_9_15', 'hi', 'Hindi', 'कोई मुझे ज्ञानयज्ञ के द्वारा पूजन करते हुए एकत्वभाव से उपासते हैं, कोई पृथक भाव से, कोई बहुत प्रकार से मुझ विराट स्वरूप (विश्वतो मुखम्) को उपासते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_9_15', 'en', 'English', 'Others worship Me with full consciousness as the One, the Manifold, the Omnipresent, the Universal.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_9_16', 'hi', 'Hindi', 'मैं ऋक्रतु हूँ; मैं यज्ञ हूँ; स्वधा और औषध मैं हूँ, मैं मन्त्र हूँ, घी हूँ, मैं अग्नि हूँ और हुतं अर्थात् हवन कर्म मैं हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_9_16', 'en', 'English', 'I am the Oblation, the Sacrifice and the Worship; I am the Fuel and the Chant, I am the Butter offered to the fire, I am the Fire itself, and I am the Act of offering.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_9_17', 'hi', 'Hindi', 'मैं ही इस जगत् का पिता, माता, धाता (धारण करने वाला) और पितामह हूँमैं वेद्य (जानने योग्य) वस्तु हूँ, पवित्र, ओंकार, ऋग्वेद, सामवेद और यजुर्वेद भी मैं ही हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_9_17', 'en', 'English', 'I am the Father of the universe and its Mother; I am its Nourisher and its Grandfather; I am the Knowable and the Pure; I am Om; and I am the Sacred Scriptures.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_9_18', 'hi', 'Hindi', 'गति (लक्ष्य), भरण-पोषण करने वाला, प्रभु (स्वामी), साक्षी, निवास, शरणस्थान तथा मित्र और उत्पत्ति, प्रलयरूप तथा स्थान (आधार), निधान और अव्यय कारण भी मैं हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_9_18', 'en', 'English', 'I am the Goal, the Sustainer, the Lord, the Witness, the Home, the Shelter, the Lover and the Origin; I am Life and Death; I am the Fountain and the Seed Imperishable.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_9_19', 'hi', 'Hindi', 'हे अर्जुन ! मैं ही (सूर्य रूप में) तपता हूँ; मैं वर्षा का निग्रह और उत्सर्जन करता हूँ। मैं ही अमृत और मृत्यु एवं सत् और असत् हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_9_19', 'en', 'English', 'I am the Heat of the Sun, I release and hold back the Rains. I am Death and Immortality; I am Being and Not-Being.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_9_20', 'hi', 'Hindi', 'तीनों वेदों के ज्ञाता (वेदोक्त सकाम कर्म करने वाले), सोमपान करने वाले एवं पापों से पवित्र हुए पुरुष मुझे यज्ञों के द्वारा पूजकर स्वर्ग प्राप्ति चाहते हैं; वे पुरुष अपने पुण्यों के फलरूप इन्द्रलोक को प्राप्त कर स्वर्ग में दिव्य देवताओं के भोग भोगते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_9_20', 'en', 'English', 'Those who are versed in the scriptures, who drink the mystic Soma-juice and are purified from sin, but who while worshipping Me with sacrifices pray that I will lead them to heaven; they reach the holy world where lives the Controller of the Powers of Nature, and they enjoy the feasts of Paradise.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_9_21', 'hi', 'Hindi', 'वे उस विशाल स्वर्गलोक को भोगकर, पुण्यक्षीण होने पर, मृत्युलोक को प्राप्त होते हैं। इस प्रकार तीनों वेदों में कहे गये कर्म के शरण हुए और भोगों की कामना वाले पुरुष आवागमन (गतागत) को प्राप्त होते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_9_21', 'en', 'English', 'Yet although they enjoy the spacious glories of Paradise, nevertheless, when their merit is exhausted, they are born again into this world of mortals. They have followed the letter of the scriptures, yet because they have sought but to fulfill their own desires, they must depart and return again and again.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_9_22', 'hi', 'Hindi', 'अनन्य भाव से मेरा चिन्तन करते हुए जो भक्तजन मेरी ही उपासना करते हैं, उन नित्ययुक्त पुरुषों का योगक्षेम मैं वहन करता हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_9_22', 'en', 'English', 'But if a man will meditate on Me and Me alone, and will worship Me always and everywhere, I will take upon Myself the fulfillment of his aspiration, and I will safeguard whatsoever he shall attain.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_9_23', 'hi', 'Hindi', 'हे कौन्तेय ! श्रद्धा से युक्त जो भक्त अन्य देवताओं को पूजते हैं, वे भी मुझे ही अविधिपूर्वक पूजते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_9_23', 'en', 'English', 'Even those who worship the lesser Powers, if they do so with faith, they thereby worship Me, though not in the right way.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_9_24', 'hi', 'Hindi', 'क्योंकि सब यज्ञों का भोक्ता और स्वामी मैं ही हूँ, परन्तु वे मुझे तत्त्वत: नहीं जानते हैं, इसलिए वे गिरते हैं, अर्थात् संसार को प्राप्त होते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_9_24', 'en', 'English', 'I am the willing recipient of sacrifice, and I am its true Lord. But these do not know me in truth, and so they sink back.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_9_25', 'hi', 'Hindi', 'देवताओं के पूजक देवताओं को प्राप्त होते हैं, पितरपूजक पितरों को जाते हैं, भूतों का यजन करने वाले भूतों को प्राप्त होते हैं और मुझे पूजने वाले भक्त मुझे ही प्राप्त होते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_9_25', 'en', 'English', 'The votaries of the lesser Powers go to them; the devotees of spirits go to them; they who worship the Powers of Darkness, to such Powers shall they go; and so, too, those who worship Me shall come to Me.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_9_26', 'hi', 'Hindi', 'जो कोई भी भक्त मेरे लिए पत्र, पुष्प, फल, जल आदि भक्ति से अर्पण करता है, उस शुद्ध मन के भक्त का वह भक्तिपूर्वक अर्पण किया हुआ (पत्र पुष्पादि) मैं भोगता हूँ अर्थात् स्वीकार करता हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_9_26', 'en', 'English', 'Whatever a man offers to Me, whether it be a leaf, or a flower, or fruit, or water, I accept it, for it is offered with devotion and purity of mind.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_9_27', 'hi', 'Hindi', 'हे कौन्तेय ! तुम जो कुछ कर्म करते हो, जो कुछ खाते हो, जो कुछ हवन करते हो, जो कुछ दान देते हो और जो कुछ तप करते हो, वह सब तुम मुझे अर्पण करो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_9_27', 'en', 'English', 'Whatever thou doest, whatever thou dost eat, whatever thou dost sacrifice and give, whatever austerities thou practisest, do all as an offering to Me.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_9_28', 'hi', 'Hindi', 'इस प्रकार तुम शुभाशुभ फलस्वरूप कर्मबन्धनों से मुक्त हो जाओगे; और संन्यासयोग से युक्तचित्त हुए तुम विमुक्त होकर मुझे ही प्राप्त हो जाओगे।।', FALSE, 'Swami Tejomayananda'),
  ('bg_9_28', 'en', 'English', 'So shall thy action be attended by no result, either good or bad; but through the spirit of renunciation thou shalt come to Me and be free.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_9_29', 'hi', 'Hindi', 'मैं समस्त भूतों में सम हूँ; न कोई मुझे अप्रिय है और न प्रिय; परन्तु जो मुझे भक्तिपूर्वक भजते हैं, वे मुझमें और मैं भी उनमें हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_9_29', 'en', 'English', 'I am the same to all beings. I favour none, and I hate none. But those who worship Me devotedly, they live in Me, and I in them.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_9_30', 'hi', 'Hindi', 'यदि कोई अतिशय दुराचारी भी अनन्यभाव से मेरा भक्त होकर मुझे भजता है, वह साधु ही मानने योग्य है, क्योंकि वह यथार्थ निश्चय वाला है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_9_30', 'en', 'English', 'Even the most sinful, if he worship Me with his whole heart, shalt be considered righteous, for he is treading the right path.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_9_31', 'hi', 'Hindi', 'हे कौन्तेय, वह शीघ्र ही धर्मात्मा बन जाता है और शाश्वत शान्ति को प्राप्त होता है। तुम निश्चयपूर्वक सत्य जानो कि मेरा भक्त कभी नष्ट नहीं होता।।', FALSE, 'Swami Tejomayananda'),
  ('bg_9_31', 'en', 'English', 'He shall attain spirituality ere long, and Eternal Peace shall be his. O Arjuna! Believe me, My devotee is never lost.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_9_32', 'hi', 'Hindi', 'हे पार्थ ! स्त्री, वैश्य और शूद्र ये जो कोई पापयोनि वाले हों, वे भी मुझ पर आश्रित (मेरे शरण) होकर परम गति को प्राप्त होते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_9_32', 'en', 'English', 'For even the children of sinful parents, and those miscalled the weaker sex, and merchants, and labourers, if only they will make Me their refuge, they shall attain the Highest.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_9_33', 'hi', 'Hindi', 'फिर क्या कहना है कि पुण्यशील ब्राह्मण और राजर्षि भक्तजन (परम गति को प्राप्त होते हैं); (इसलिए) इस अनित्य और सुखरहित लोक को प्राप्त होकर (अब) तुम भक्तिपूर्वक मेरी ही पूजा करो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_9_33', 'en', 'English', 'What need then to mention the holy Ministers of God, the devotees and the saintly rulers? Do thou, therefore, born in this changing and miserable world, do thou too worship Me.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_9_34', 'hi', 'Hindi', '(तुम) मुझमें स्थिर मन वाले बनो; मेरे भक्त और मेरे पूजन करने वाले बनो; मुझे नमस्कार करो; इस प्रकार मत्परायण (अर्थात् मैं ही जिसका परम लक्ष्य हूँ ऐसे) होकर आत्मा को मुझसे युक्त करके तुम मुझे ही प्राप्त होओगे।।', FALSE, 'Swami Tejomayananda'),
  ('bg_9_34', 'en', 'English', 'Fix thy mind on Me, devote thyself to Me, sacrifice for Me, surrender to Me, make Me the object of thy aspirations, and thou shalt assuredly become one with Me, Who am thine own Self."', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_1', 'hi', 'Hindi', 'श्रीभगवान् ने कहा -- हे महाबाहो ! पुन: तुम मेरे परम वचनों का श्रवण करो, जो मैं तुझ अतिशय प्रेम रखने वाले के लिये हित की इच्छा से कहूँगा।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_1', 'en', 'English', '"Lord Shri Krishna said: Now, O Prince! Listen to My supreme advice, which I give thee for the sake of thy welfare, for thou art My beloved.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_2', 'hi', 'Hindi', 'मेरी उत्पत्ति (प्रभव) को न देवतागण जानते हैं और न महर्षिजन; क्योंकि मैं सब प्रकार से देवताओं और महर्षियों का भी आदिकारण हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_2', 'en', 'English', 'Neither the professors of divinity nor the great ascetics know My origin, for I am the source of them all.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_3', 'hi', 'Hindi', 'जो मुझे अजन्मा, अनादि और लोकों के महान् ईश्वर के रूप में जानता है, र्मत्य मनुष्यों में ऐसा संमोहरहित (ज्ञानी) पुरुष सब पापों से मुक्त हो जाता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_3', 'en', 'English', 'He who knows Me as the unborn, without beginning, the Lord of the universe, he, stripped of his delusion, becomes free from all conceivable sin.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_4', 'hi', 'Hindi', 'बुद्धि, ज्ञान, मोह का अभाव, क्षमा, सत्य, दम (इन्द्रिय संयम), शम (मन: संयम), सुख, दु:ख, जन्म और मृत्यु, भय और अभय।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_4', 'en', 'English', 'Intelligence, wisdom, non-illusion, forgiveness, truth, self-control, calmness, pleasure, pain, birth, death, fear and fearlessness;', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_5', 'hi', 'Hindi', 'अहिंसा, समता, सन्तोष, तप, दान. यश और अपयश ऐसे ये प्राणियों के नानाविध भाव मुझ से ही प्रकट होते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_5', 'en', 'English', 'Harmlessness, equanimity, contentment, austerity, beneficence, fame and failure, all these, the characteristics of beings, spring from Me only.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_6', 'hi', 'Hindi', 'सात महर्षिजन, पूर्वकाल के चार (सनकादि) तथा (चौदह) मनु ये मेरे प्रभाव वाले मेरे संकल्प से उत्पन्न हुए हैं, जिनकी संसार (लोक) में यह प्रजा है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_6', 'en', 'English', 'The seven Great Seers,* the Progenitors of mankind, the Ancient Four,** and the Lawgivers were born of My Will and come forth direct from Me. The race of mankind has sprung from them. [* Mareechi, Atri, Angira, Pulah, Kratu, Pulastya, Vahishta. ** The Masters: Sanak, Sanandan, Sanatan, Sanatkumar.]', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_7', 'hi', 'Hindi', 'जो पुरुष इस मेरी विभूति और योग को तत्त्व से जानता है, वह पुरुष अविकम्प योग (अर्थात् निश्चल ध्यान योग) से युक्त हो जाता है, इसमें कुछ भी संशय नहीं है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_7', 'en', 'English', 'He who rightly understands My manifested glory and My Creative Power, beyond doubt attains perfect peace.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_8', 'hi', 'Hindi', 'मैं ही सबका प्रभव स्थान हूँ; मुझसे ही सब (जगत्) विकास को प्राप्त होता है, इस प्रकार जानकर बुधजन भक्ति भाव से युक्त होकर मुझे ही भजते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_8', 'en', 'English', 'I am the source of all; from Me everything flows. Therefore the wise worship Me with unchanging devotion.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_9', 'hi', 'Hindi', 'मुझमें ही चित्त को स्थिर करने वाले और मुझमें ही प्राणों (इन्द्रियों) को अर्पित करने वाले भक्तजन, सदैव परस्पर मेरा बोध कराते हुए, मेरे ही विषय में कथन करते हुए सन्तुष्ट होते हैं और रमते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_9', 'en', 'English', 'With minds concentrated on Me, with lives absorbed in Me, and enlightening each other, they ever feel content and happy.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_10', 'hi', 'Hindi', 'उन (मुझ से) नित्य युक्त हुए और प्रेमपूर्वक मेरा भजन करने वाले भक्तों को, मैं वह ''बुद्धियोग'' देता हूँ जिससे वे मुझे प्राप्त होते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_10', 'en', 'English', 'To those who are always devout and who worship Me with love, I give the power of discrimination, which leads them to Me.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_11', 'hi', 'Hindi', 'उनके ऊपर अनुग्रह करने के लिए मैं उनके अन्त:करण में स्थित होकर, अज्ञानजनित अन्धकार को प्रकाशमय ज्ञान के दीपक द्वारा नष्ट करता हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_11', 'en', 'English', 'By My grace, I live in their hearts; and I dispel the darkness of ignorance by the shining light of wisdom.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_12', 'hi', 'Hindi', 'अर्जुन ने कहा आप -परम ब्रह्म, परम धाम और परम पवित्र हंै; सनातन दिव्य पुरुष, देवों के भी आदि देव, जन्म रहित और सर्वव्यापी हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_12', 'en', 'English', 'Arjuna asked: Thou art the Supreme Spirit, the Eternal Home, the Holiest of the Holy, the Eternal Divine Self, the Primal God, the Unborn and the Omnipresent.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_13', 'hi', 'Hindi', 'ऐसा आपको समस्त ऋषिजन कहते हैं;  वैसे ही देवर्षि नारद, असित, देवल ऋषि तथा व्यास और स्वयं आप भी मेरे प्रति कहते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_13', 'en', 'English', 'So have said the seers and the divine sage Narada; as well as Asita, Devala and Vyasa; and Thou Thyself also sayest it.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_14', 'hi', 'Hindi', 'हे केशव ! जो कुछ भी आप मेरे प्रति कहते हैं, इस सबको मैं सत्य मानता हूँ। हे भगवन्, आपके (वास्तविक) स्वरूप को न देवता जानते हैं और न दानव।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_14', 'en', 'English', 'I believe in what Thou hast said, my Lord! For neither the godly not the godless comprehend Thy manifestation.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_15', 'hi', 'Hindi', 'हे पुरुषोत्तम ! हे भूतभावन ! हे भूतेश ! हे देवों के देव ! हे जगत् के स्वामी ! आप स्वयं ही अपने आप को जानते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_15', 'en', 'English', 'Shri Purohit Swami did not comment on this sloka', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_16', 'hi', 'Hindi', 'आप ही उन अपनी दिव्य विभूतियों को अशेषत: कहने के लिए योग्य हैं, जिन विभूतियों के द्वारा इन समस्त लोकों को आप व्याप्त करके स्थित हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_16', 'en', 'English', 'Please tell me all about Thy glorious manifestations, by means of which Thou pervadest the world.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_17', 'hi', 'Hindi', 'हे योगेश्वर ! मैं किस प्रकार निरन्तर चिन्तन करता हुआ आपको जानूँ, और हे भगवन् ! आप किनकिन भावों में मेरे द्वारा चिन्तन करने योग्य हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_17', 'en', 'English', 'O Master! How shall I, by constant meditation, know Thee? My Lord! What are Thy various manifestations through which I am to mediate on Thee?', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_18', 'hi', 'Hindi', 'हे जनार्दन ! अपनी योग शक्ति और विभूति को पुन: विस्तारपूर्वक कहिए, क्योंकि आपके अमृतमय वचनों को सुनते हुए मुझे तृप्ति नहीं होती।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_18', 'en', 'English', 'Tell me again, I pray, about the fullness of Thy power and Thy glory; for I feel that I am never satisfied when I listen to Thy immortal words.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_19', 'hi', 'Hindi', 'श्रीभगवान् ने कहा -हन्त अब मैं तुम्हें अपनी दिव्य विभूतियों को प्रधानता से कहूँगा। हे कुरुश्रेष्ठ मेरे विस्तार का अन्त नहीं है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_19', 'en', 'English', 'Lord Shri Krishna replied: So be it, My beloved fried! I will unfold to thee some of the chief aspects of My glory. Of its full extent there is no end.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_20', 'hi', 'Hindi', 'हे गुडाकेश (निद्राजित्) ! मैं समस्त भूतों के हृदय में स्थित सबकी आत्मा हूँ तथा सम्पूर्ण भूतों का आदि, मध्य और अन्त भी मैं ही हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_20', 'en', 'English', 'O Arjuna! I am the Self, seated in the hearts of all beings; I am the beginning and the life, and I am the end of them all.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_21', 'hi', 'Hindi', 'मैं (बारह) आदित्यों में विष्णु और ज्योतियों में अंशुमान् सूर्य हूँ; मैं (उनचास) मरुतों (वायु देवताओं) में मरीचि हूँ और नक्षत्रों में शशी (चन्द्रमा) हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_21', 'en', 'English', 'Of all the creative Powers I am the Creator, of luminaries the Sun; the Whirlwind among the winds, and the Moon among planets.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_22', 'hi', 'Hindi', 'मैं वेदों में सामवेद हूँ, देवों में वासव (इन्द्र) हूँ; मैं इन्द्रियों में मन और भूतप्राणियों में चेतना (ज्ञानशक्ति) हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_22', 'en', 'English', 'Of the Vedas I am the Hymns, I am the Electric Force in the Powers of Nature; of the senses I am the Mind; and I am the Intelligence in all that lives.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_23', 'hi', 'Hindi', 'मैं (ग्यारह) रुद्रों में शंकर हूँ और यक्ष तथा राक्षसों में धनपति कुबेर (वित्तेश) हूँ; (आठ) वसुओं में अग्नि हूँ तथा शिखर वाले पर्वतों में मेरु हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_23', 'en', 'English', 'Among Forces of Vitality I am the life, I am Mammon to the heathen and the godless; I am the Energy in fire, earth, wind, sky, heaven, sun, moon and planets; and among mountains am the Mount Meru.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_24', 'hi', 'Hindi', 'हे पार्थ ! पुरोहितों में मुझे बृहस्पति जानो; मैं सेनापतियों में स्कन्द और जलाशयों में समुद्र हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_24', 'en', 'English', 'Among the priests, know, O Arjuna, that I am the Apostle Brihaspati; of generals I am Skanda, the Commander-in-Chief, and of waters I am the Ocean.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_25', 'hi', 'Hindi', 'मैं महर्षियों में भृगु और वाणी (शब्दों) में एकाक्षर ओंकार हूँ। मैं यज्ञों में जपयज्ञ और स्थावरों (अचलों) में हिमालय हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_25', 'en', 'English', 'Of the great seers I am Bhrigu, of words I am Om, of offerings I am the silent prayer, among things immovable I am the Himalayas.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_26', 'hi', 'Hindi', 'मैं समस्त वृक्षों में अश्वत्थ (पीपल) हूँ और देवर्षियों में नारद हूँ; मैं गन्धर्वों में चित्ररथ और सिद्ध पुरुषों में कपिल मुनि हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_26', 'en', 'English', 'Of trees I am the sacred Fig-tree, of the Divine Seers Narada, of the heavenly singers I am Chitraratha, their Leader, and of sages I am Kapila.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_27', 'hi', 'Hindi', 'अश्वों में अमृत से उत्पन्न हुए उच्चैश्रवा नामक अश्व, हाथियों में ऐरावत और मनुष्यों में राजा मुझे ही जानो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_27', 'en', 'English', 'Know that among horses I am Pegasus, the heaven-born; among the lordly elephants I am the White one, and I am the Ruler among men.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_28', 'hi', 'Hindi', 'मैं शस्त्रों में वज्र और धेनुओं (गायों) में कामधेनु हूँ, प्रजा उत्पत्ति का हेतु कन्दर्प (कामदेव) मैं हूँ और सर्पों में वासुकि हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_28', 'en', 'English', 'I am the Thunderbolt among weapons; of cows I am the Cow of Plenty, I am Passion in those who procreate, and I am the Cobra among serpents.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_29', 'hi', 'Hindi', 'मैं नागों में अनन्त (शेषनाग) हूँ और जल देवताओं में वरुण हूँ; मैं पितरों में अर्यमा हँ और नियमन करने वालों में यम हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_29', 'en', 'English', 'I am the King-python among snakes, I am the Aqueous Principle among those that live in water, I am the Father of fathers, and among rulers I am Death.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_30', 'hi', 'Hindi', 'मैं दैत्यों में प्रह्लाद और गणना करने वालों में काल हूँ, मैं ''पशुओं'' में सिंह (मृगेन्द्र) और पक्षियों में गरुड़ हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_30', 'en', 'English', 'And I am the devotee Prahlad among the heathen; of Time I am the Eternal Present; I am the Lion among beasts and the Eagle among birds.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_31', 'hi', 'Hindi', 'मैं पवित्र करने वालों में वायु हूँ और शस्त्रधारियों में राम हूँ; तथा मत्स्यों (जलचरों) में मैं मगरमच्छ और नदियों में मैं गंगा हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_31', 'en', 'English', 'I am the Wind among purifiers, the King Rama among warriors; I am the Crocodile among the fishes, and I am the Ganges among rivers.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_32', 'hi', 'Hindi', 'हे अर्जुन ! सृष्टियों का आदि, अन्त और मध्य भी मैं ही हूँ, मैं विद्याओं में अध्यात्मविद्या और विवाद करने वालों में (अर्थात् विवाद के प्रकारों में) मैं वाद हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_32', 'en', 'English', 'I am the Beginning, the Middle and the End in creation; among sciences, I am the science of Spirituality; I am the Discussion among disputants.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_33', 'hi', 'Hindi', 'मैं अक्षरों (वर्णमाला) में अकार और समासों में द्वन्द्व (नामक समास) हूँ; मैं अक्षय काल और विश्वतोमुख (विराट् स्वरूप) धाता हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_33', 'en', 'English', 'Of letters I am A; I am the copulative in compound words; I am Time inexhaustible; and I am the all-pervading Preserver.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_34', 'hi', 'Hindi', 'मैं सर्वभक्षक मृत्यु और भविष्य में होने वालों की उत्पत्ति का कारण हूँ; स्त्रियों में कीर्ति, श्री, वाक (वाणी), स्मृति, मेधा, धृति और क्षमा हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_34', 'en', 'English', 'I am all-devouring Death; I am the Origin of all that shall happen; I am Fame, Fortune, Speech, Memory, Intellect, Constancy and Forgiveness.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_35', 'hi', 'Hindi', 'सामों (गेय मन्त्रों) में मैं बृहत्साम और छन्दों में गायत्री छन्द हूँ; मैं मासों में मार्गशीर्ष (दिसम्बरजनवरी के भाग) और ऋतुओं में वसन्त हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_35', 'en', 'English', 'Of hymns I am Brihatsama, of metres I am Garatri, among the months I am Margasheersha (December), and I am the Spring among seasons.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_36', 'hi', 'Hindi', 'मैं छल करने वालों में द्यूत हूँ और तेजस्वियों में तेज हूँ, मैं विजय हूँ; मैं व्यवसाय (उद्यमशीलता) हूँ और सात्विक पुरुषों का सात्विक भाव हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_36', 'en', 'English', 'I am the Gambling of the cheat and the Splendour of the splendid; I am Victory; I am Effort; and I am the Purity of the pure.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_37', 'hi', 'Hindi', 'मैं वृष्णियों में वासुदेव हूँ और पाण्डवों में धनंजय, मैं मुनियों में व्यास और कवियों में उशना कवि हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_37', 'en', 'English', 'I am Shri Krishna among the Vishnu-clan and Arjuna among the Pandavas; of the saints I am Vyasa, and I am Shukracharya among the sages.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_38', 'hi', 'Hindi', 'मैं दमन करने वालों का दण्ड हूँ और विजयेच्छुओं की नीति हूँ; मैं गुह्यों में मौन हूँ और ज्ञानवानों का ज्ञान हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_38', 'en', 'English', 'I am the Sceptre of rulers, the Strategy of the conquerors, the Silence of mystery, the Wisdom of the wise.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_39', 'hi', 'Hindi', 'हे अर्जुन ! जो समस्त भूतों की उत्पत्ति का बीज (कारण) है, वह भी में ही हूँ, क्योंकि ऐसा कोई चर और अचर भूत नहीं है, जो मुझसे रहित है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_39', 'en', 'English', 'I am the Seed of all being, O Arjuna! No creature moving or unmoving can live without Me.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_40', 'hi', 'Hindi', 'हे परन्तप ! मेरी दिव्य विभूतियों का अन्त नहीं है; अपनी विभूतियों का यह विस्तार मैंने एक देश से अर्थात् संक्षेप में कहा है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_40', 'en', 'English', 'O Arjuna! The aspects of My divine life are endless. I have mentioned but a few by way of illustration.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_41', 'hi', 'Hindi', 'जो कोई भी विभूतियुक्त, कान्तियुक्त अथवा शक्तियुक्त वस्तु (या प्राणी) है, उसको तुम मेरे तेज के अंश से ही उत्पन्न हुई जानो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_41', 'en', 'English', 'Whatever is glorious, excellent, beautiful and mighty, be assured that it comes from a fragment of My splendour.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_10_42', 'hi', 'Hindi', 'अथवा हे अर्जुन ! बहुत जानने से तुम्हारा क्या प्रयोजन है? मैं इस सम्पूर्ण जगत् को अपने एक अंश मात्र से धारण करके स्थित हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_10_42', 'en', 'English', 'But what is the use of all these details to thee? O Arjuna! I sustain this universe with only small part of Myself."', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_1', 'hi', 'Hindi', 'अर्जुन ने कहा -- मुझ पर अनुग्रह करने के लिए जो परम गोपनीय, अध्यात्मविषयक वचन (उपदेश) आपके द्वारा कहा गया, उससे मेरा मोह दूर हो गया है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_1', 'en', 'English', '"Arjuna said: My Lord! Thy words concerning the Supreme Secret of Self, given for my blessing, have dispelled the illusions which surrounded me.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_2', 'hi', 'Hindi', 'हे कमलनयन ! मैंने भूतों की उत्पत्ति और प्रलय आपसे विस्तारपूर्वक सुने हैं तथा आपका अव्यय माहात्म्य (प्रभाव) भी सुना है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_2', 'en', 'English', 'O Lord, whose eyes are like the lotus petal! Thou hast described in detail the origin and the dissolution of being, and Thine own Eternal Majesty.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_3', 'hi', 'Hindi', 'हे परमेश्वर ! आप अपने को जैसा कहते हो, यह ठीक ऐसा ही है। (परन्तु) हे पुरुषोत्तम ! मैं आपके ईश्वरीय रूप को प्रत्यक्ष देखना चाहता हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_3', 'en', 'English', 'I believe all as Thou hast declared it. I long now to have a vision of thy Divine Form, O Thou Most High!', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_4', 'hi', 'Hindi', 'हे प्रभो ! यदि आप मानते हैं कि मेरे द्वारा वह आपका रूप देखा जाना संभव है, तो हे योगेश्वर ! आप अपने अव्यय रूप का दर्शन कराइये।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_4', 'en', 'English', 'If Thou thinkest that it can be made possible for me to see it, show me, O Lord of Lords, Thine own Eternal Self.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_5', 'hi', 'Hindi', 'श्रीभगवान् ने कहा -- हे पार्थ ! मेरे सैकड़ों तथा सहस्रों नाना प्रकार के और नाना वर्ण तथा आकृति वाले दिव्य रूपों को देखो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_5', 'en', 'English', 'Lord Shri Krishna replied: Behold, O Arjuna! My celestial forms, by hundred and thousands, various in kind, in colour and in shape.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_6', 'hi', 'Hindi', 'हे भारत ! (मुझमें) आदित्यों, वसुओं, रुद्रों तथा अश्विनीकुमारों और मरुद्गणों को देखो, तथा और भी अनेक इसके पूर्व कभी न देखे हुए आश्चर्यों को देखो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_6', 'en', 'English', 'Behold thou the Powers of Nature: fire, earth, wind and sky; the sun, the heavens, the moon, the stars; all forces of vitality and of healing; and the roving winds. See the myriad wonders revealed to none but thee.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_7', 'hi', 'Hindi', 'हे गुडाकेश ! आज (अब) इस मेरे शरीर में एक स्थान पर स्थित हुए चराचर सहित सम्पूर्ण जगत् को देखो तथा और भी जो कुछ तुम देखना चाहते हो, उसे भी देखो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_7', 'en', 'English', 'Here in Me living as one, O Arjuna, behold the whole universe, movable and immovable, and anything else that thou wouldst see!', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_8', 'hi', 'Hindi', 'परन्तु तुम अपने इन्हीं (प्राकृत) नेत्रों के द्वारा मुझे देखने में समर्थ नहीं हो; (इसलिए) मैं तुम्हें दिव्यचक्षु देता हूँ, जिससे तुम मेरे ईश्वरीय ''योग'' को देखो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_8', 'en', 'English', 'Yet since with mortal eyes thou canst not see Me, lo! I give thee the Divine Sight. See now the glory of My Sovereignty."', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_9', 'hi', 'Hindi', 'संजय ने कहा -- हे राजन् ! महायोगेश्वर हरि ने इस प्रकार कहकर फिर अर्जुन के लिए परम ऐश्वर्ययुक्त रूप को दर्शाया।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_9', 'en', 'English', 'Sanjaya continued: "Having thus spoken, O King, the Lord Shri Krishna, the Almighty Prince of Wisdom, showed to Arjuna the Supreme Form of the Great God.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_10', 'hi', 'Hindi', 'उस अनेक मुख और नेत्रों से युक्त तथा अनेक अद्भुत दर्शनों वाले एवं बहुत से दिव्य भूषणों से युक्त और बहुत से दिव्य शस्त्रों को हाथों में उठाये हुये।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_10', 'en', 'English', 'There were countless eyes and mouths, and mystic forms innumerable, with shining ornaments and flaming celestial weapons.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_11', 'hi', 'Hindi', 'दिव्य माला और वस्त्रों को धारण किये हुये और दिव्य गन्ध का लेपन किये हुये एवं समस्त प्रकार के आश्चर्यों से युक्त अनन्त, विश्वतोमुख (विराट् स्वरूप) परम देव (को अर्जुन ने देखा)।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_11', 'en', 'English', 'Crowned with heavenly garlands, clothed in shining garments, anointed with divine unctions, He showed Himself as the Resplendent One, Marvellous, Boundless, Omnipresent.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_12', 'hi', 'Hindi', 'आकाश में सहस्र सूर्यों के एक साथ उदय होने से उत्पन्न जो प्रकाश होगा, वह उस (विश्वरूप) परमात्मा के प्रकाश के सदृश होगा।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_12', 'en', 'English', 'Could a thousand suns blaze forth together it would be but a faint reflection of the radiance of the Lord God.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_13', 'hi', 'Hindi', 'पाण्डुपुत्र अर्जुन ने उस समय अनेक प्रकार से विभक्त हुए सम्पूर्ण जगत् को देवों के देव श्रीकृष्ण के शरीर में एक स्थान पर स्थित देखा।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_13', 'en', 'English', 'In that vision Arjuna saw the universe, with its manifold shapes, all embraced in One, its Supreme Lord.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_14', 'hi', 'Hindi', 'उसके उपरान्त वह आश्चर्यचकित हुआ हर्षित रोमों वाला (जिसे रोमांच का अनुभव हो रहा हो) धनंजय अर्जुन विश्वरूप देव को (श्रद्धा भक्ति सहित) शिर से प्रणाम करके हाथ जोड़कर बोला।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_14', 'en', 'English', 'Thereupon Arjuna, dumb with awe, his hair on end, his head bowed, his hands clasped in salutation, addressed the Lord thus:', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_15', 'hi', 'Hindi', 'अर्जुन ने कहा -- हे देव! मैं आपके शरीर में समस्त देवों को तथा अनेक भूतविशेषों के समुदायों को और कमलासन पर स्थित सृष्टि के स्वामी ब्रह्माजी को, ऋषियों को और दिव्य सर्पों को देख रहा हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_15', 'en', 'English', 'Arjuna said: O almighty God! I see in Thee the powers of Nature, the various creatures of the world, the Progenitor on his lotus throne, the Sages and the shining angels.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_16', 'hi', 'Hindi', 'हे विश्वेश्वर! मैं आपकी अनेक बाहु, उदर, मुख और नेत्रों से युक्त तथा सब ओर से अनन्त रूपों वाला देखता हूँ। हे विश्वरूप! मैं आपके न अन्त को देखता हूँ और न मध्य को और न आदि को।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_16', 'en', 'English', 'I see Thee, infinite in form, with, as it were, faces, eyes and limbs everywhere; no beginning, no middle, no end; O Thou Lord of the Universe, Whose Form is universal!', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_17', 'hi', 'Hindi', 'मैं आपका मुकुटयुक्त, गदायुक्त और चक्रधारण किये हुये तथा सब ओर से प्रकाशमान् तेज का पुंज, दीप्त अग्नि और सूर्य के समान ज्योतिर्मय, देखने में अति कठिन और अप्रमेयस्वरूप सब ओर से देखता हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_17', 'en', 'English', 'I see thee with the crown, the sceptre and the discus; a blaze of splendour. Scarce can I gaze on thee, so radiant thou art, glowing like the blazing fire, brilliant as the sun, immeasurable.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_18', 'hi', 'Hindi', 'आप ही जानने योग्य (वेदितव्यम्) परम अक्षर हैं; आप ही इस विश्व के परम आश्रय (निधान) हैं ! आप ही शाश्वत धर्म के रक्षक हैं और आप ही सनातन पुरुष हैं,ऐसा मेरा मत है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_18', 'en', 'English', 'Imperishable art Thou, the Sole One worthy to be known, the priceless Treasure-house of the universe, the immortal Guardian of the Life Eternal, the Spirit Everlasting.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_19', 'hi', 'Hindi', 'मैं आपको आदि, अन्त और मध्य से रहित तथा अनंत सार्मथ्य से युक्त और अनंत बाहुओं वाला तथा चन्द्रसूर्यरूपी नेत्रों वाला और दीप्त अग्निरूपी मुख वाला तथा अपने तेज से इस विश्व को तपाते हुए देखता हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_19', 'en', 'English', 'Without beginning, without middle and without end, infinite in power, Thine arms all-embracing, the sun and moon Thine eyes, Thy face beaming with the fire of sacrifice, flooding the whole universe with light.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_20', 'hi', 'Hindi', 'हे महात्मन् ! स्वर्ग और पृथ्वी के मध्य का यह आकाश तथा समस्त दिशाएं अकेले आप से ही व्याप्त हैं; आपके इस अद्भुत और उग्र रूप को देखकर तीनों लोक अतिव्यथा (भय) को प्राप्त हो रहे हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_20', 'en', 'English', 'Alone thou fillest all the quarters of the sky, earth and heaven, and the regions between. O Almighty Lord! Seeing Thy marvellous and awe-inspiring Form, the spheres tremble with fear.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_21', 'hi', 'Hindi', 'ये समस्त देवताओं के समूह आप में ही प्रवेश कर रहे हैं और कई एक भयभीत होकर हाथ जोड़े हुए आप की स्तुति करते हैं; महर्षि और सिद्धों के समुदाय ''कल्याण होवे'' (स्वस्तिवाचन करते हुए) ऐसा कहकर, उत्तम (या सम्पूर्ण) स्रोतों द्वारा आपकी स्तुति करते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_21', 'en', 'English', 'The troops of celestial beings enter into Thee, some invoking Thee in fear, with folded palms; the Great Seers and Adepts sing hymns to Thy Glory, saying All Hail.''', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_22', 'hi', 'Hindi', 'रुद्रगण, आदित्य, वसु और साध्यगण, विश्वेदेव तथा दो अश्विनीकुमार, मरुद्गण और उष्मपा, गन्धर्व, यक्ष, असुर और सिद्धगणों के समुदाय- ये सब ही विस्मित होते हुए आपको देखते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_22', 'en', 'English', 'The Vital Forces, the Major stars, Fire, Earth, Air, Sky, Sun, Heaven, Moon and Planets; the Angels, the Guardians of the Universe, the divine Healers, the Winds, the Fathers, the Heavenly Singers; and hosts of Mammon-worshippers, demons as well as saints, are amazed.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_23', 'hi', 'Hindi', 'हे महाबाहो! आपके बहुत मुख तथा नेत्र वाले, बहुत बाहु, उरु (जंघा) तथा पैरों वाले, बहुत-ंंसी उदरों वाले तथा बहुतसी विकराल दाढ़ों वाले महान् रूप को देखकर सब लोग व्यथित हो रहे हैं और उसी प्रकार मैं भी (व्याकुल हो रहा हूँ)।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_23', 'en', 'English', 'Seeing Thy stupendous Form, O Most Mighty, with its myriad faces, its innumerable eyes and limbs and terrible jaws, I myself and all the worlds are overwhelmed with awe.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_24', 'hi', 'Hindi', 'हे विष्णो! आकाश के साथ स्पर्श किये हुए देदीप्यमान अनेक रूपों से युक्त तथा विस्तरित मुख और प्रकाशमान विशाल नेत्रों से युक्त आपको देखकर भयभीत हुआ मैं धैर्य और शान्ति को नहीं प्राप्त हो रहा हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_24', 'en', 'English', 'When I see Thee, touching the Heavens, glowing with colour, with open mouth and wide open fiery eyes, I am terrified. O My Lord! My courage and peace of mind desert me.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_25', 'hi', 'Hindi', 'आपके विकराल दाढ़ों वाले और प्रलयाग्नि के समान प्रज्वलित मुखों को देखकर, मैं न दिशाओं को जान पा रहा हूँ और न शान्ति को प्राप्त हो रहा हूँ; इसलिए हे देवेश!  हे जगन्निवास! आप प्रसन्न हो जाइए।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_25', 'en', 'English', 'When I see Thy mouths with their fearful jaws like glowing fires at the dissolution of creation, I lose all sense of place; I find no rest. Be merciful, O Lord in whom this universe abides!', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_26', 'hi', 'Hindi', 'और ये समस्त धृतराष्ट्र के पुत्र राजाओं के समुदाय सहित आप में प्रवेश करते हैं। भीष्म, द्रोण तथा कर्ण और हमारे पक्ष के भी प्रधान योद्धाओं के सहित.।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_26', 'en', 'English', 'All these sons of Dhritarashtra, with the hosts of princes, Bheeshma, Drona and Karna, as well as the other warrior chiefs belonging to our side;', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_27', 'hi', 'Hindi', 'तीव्र वेग से आपके विकराल दाढ़ों वाले भयानक मुखों में प्रवेश करते हैं और कई एक चूर्णित शिरों सहित आपके दांतों के बीच में फँसे हुए दिख रहे हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_27', 'en', 'English', '1	see them all rushing headlong into Thy mouths, with terrible tusks, horrible to behold. Some are mangled between thy jaws, with their heads crushed to atoms.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_28', 'hi', 'Hindi', 'जैसे नदियों के बहुत से जलप्रवाह समुद्र की ओर वेग से बहते हैं, वैसे ही मनुष्यलोक के ये वीर योद्धागण आपके प्रज्वलित मुखों में प्रवेश करते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_28', 'en', 'English', 'As rivers in flood surge furiously to the ocean, so these heroes, the greatest among men, fling themselves into Thy flaming mouths.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_29', 'hi', 'Hindi', 'जैसे पतंगे अपने नाश के लिए प्रज्वलित अग्नि में अतिवेग से प्रवेश करते हैं, वैसे ही ये लोग भी अपने नाश के लिए आपके मुखों में अतिवेग से प्रवेश करते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_29', 'en', 'English', 'As moths fly impetuously to the flame only to be killed, so these men rush into Thy mouths to court their own destruction.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_30', 'hi', 'Hindi', 'हे विष्णो! आप प्रज्वलित मुखों के द्वारा इन समस्त लोकों का ग्रसन करते हुए आस्वाद ले रहे हैं, आपका उग्र प्रकाश सम्पूर्ण जगत् को तेज के द्वारा परिपूर्ण करके तपा रहा है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_30', 'en', 'English', 'Thou seemest to swallow up the worlds, to lap them in flame. Thy glory fills the universe. Thy fierce rays beat down upon it irresistibly.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_31', 'hi', 'Hindi', '(कृपया) मेरे प्रति कहिये, कि उग्ररूप वाले आप कौन हैं? हे देवों में श्रेष्ठ! आपको नमस्कार है, आप प्रसन्न होइये। आदि स्वरूप आपको मैं (तत्त्व से) जानना चाहता हूँ, क्योंकि आपकी प्रवृत्ति (अर्थात् प्रयोजन को) को मैं नहीं समझ पा रहा हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_31', 'en', 'English', 'Tell me then who Thou art, that wearest this dreadful Form? I bow before Thee, O Mighty One! Have mercy, I pray, and let me see Thee as Thou wert at first. I do not know what Thou intendest.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_32', 'hi', 'Hindi', 'श्रीभगवान् ने कहा -- मैं लोकों का नाश करने वाला प्रवृद्ध काल हूँ। इस समय, मैं इन लोकों का संहार करने में प्रवृत्त हूँ। जो प्रतिपक्षियों की सेना में स्थित योद्धा हैं, वे सब तुम्हारे बिना भी नहीं रहेंगे।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_32', 'en', 'English', 'Lord Shri Krishna replied: I have shown myself to thee as the Destroyer who lays waste the world and whose purpose is destruction. In spite of thy efforts, all these warriors gathered for battle shall not escape death.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_33', 'hi', 'Hindi', 'इसलिए तुम उठ खड़े हो जाओ और यश को प्राप्त करो; शत्रुओं को जीतकर समृद्ध राज्य को भोगो। ये सब पहले से ही मेरे द्वारा मारे जा चुके हैं। हे सव्यसाचिन्! तुम केवल निमित्त ही बनो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_33', 'en', 'English', 'Then gird up thy loins and conquer. Subdue thy foes and enjoy the kingdom in prosperity. I have already doomed them. Be thou my instrument, Arjuna!', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_34', 'hi', 'Hindi', 'द्रोण, भीष्म, जयद्रथ, कर्ण तथा और भी बहुत से मेरे द्वारा मारे गये वीर योद्धाओं को तुम मारो; भय मत करो; युद्ध करो; तुम युद्ध में शत्रुओं को जीतोगे।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_34', 'en', 'English', 'Drona and Bheeshma, Jayadratha and Karna, and other brave warriors - I have condemned them all. Destroy them; fight and fear not. Thy foes shall be crushed."', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_35', 'hi', 'Hindi', 'संजय ने कहा -- केशव भगवान् के इस वचन को सुनकर मुकुटधारी अर्जुन हाथ जोड़े हुए, कांपता हुआ नमस्कार करके पुन: भयभीत हुआ श्रीकृष्ण के प्रति गद्गद् वाणी से बोला।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_35', 'en', 'English', 'Sanjaya continued: "Having heard these words from the Lord Shri Krishna, the Prince Arjuna, with folded hands trembling, prostrated himself and with choking voice, bowing down again and again, and overwhelmed with awe, once more addressed the Lord.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_36', 'hi', 'Hindi', 'अर्जुन ने कहा -- यह योग्य ही है कि आपके कीर्तन से जगत् अति हर्षित होता है और अनुराग को भी प्राप्त होता है। भयभीत राक्षस लोग समस्त दिशाओं में भागते हैं और समस्त सिद्धगणों के समुदाय आपको नमस्कार करते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_36', 'en', 'English', 'Arjuna said: My Lord! It is natural that the world revels and rejoices when it sings the praises of Thy glory; the demons fly in fear and the saints offer Thee their salutations.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_37', 'hi', 'Hindi', 'हे महात्मन् ! ब्रह्मा के भी आदि कर्ता और सबसे श्रेष्ठ आपके लिए वे कैसे नमस्कार नहीं करें? (क्योंकि) हे अनन्त! हे देवेश! हे जगन्निवास! जो सत् असत् और इन दोनों से परे अक्षरतत्त्व है, वह आप ही हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_37', 'en', 'English', 'How should they do otherwise? O Thou Supremest Self, greater than the Powers of creation, the First Cause, Infinite, the Lord of Lords, the Home of the universe, Imperishable, Being and Not-Being, yet transcending both.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_38', 'hi', 'Hindi', 'आप आदिदेव और पुराण (सनातन) पुरुष हैं। आप इस जगत् के परम आश्रय, ज्ञाता, ज्ञेय, (जानने योग्य) और परम धाम हैं। हे अनन्तरूप आपसे ही यह विश्व व्याप्त है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_38', 'en', 'English', 'Thou art the Primal God, the Ancient, the Supreme Abode of this universe, the Knower, the Knowledge and the Final Home. Thou fillest everything. Thy form is infinite.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_39', 'hi', 'Hindi', 'आप वायु, यम, अग्नि, वरुण, चन्द्रमा, प्रजापति (ब्रह्मा) और प्रपितामह (ब्रह्मा के भी कारण) हैं; आपके लिए सहस्र बार नमस्कार, नमस्कार है, पुन: आपको बारम्बार नमस्कार, नमस्कार है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_39', 'en', 'English', 'Thou art the Wind, Thou art Death, Thou art the Fire, the Water, the Moon, the Father and the Grandfather. Honour and glory to Thee a thousand and a thousand times! Again and again, salutation be to Thee, O my Lord!', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_40', 'hi', 'Hindi', 'हे अनन्तसार्मथ्य वाले भगवन्! आपके लिए अग्रत: और पृष्ठत: नमस्कार है, हे सर्वात्मन्! आपको सब ओर से नमस्कार है। आप अमित विक्रमशाली हैं और आप सबको व्याप्त किये हुए हैं, इससे आप सर्वरूप हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_40', 'en', 'English', 'Salutations to Thee in front and on every side, Thou who encompasseth me round about. Thy power is infinite; Thy majesty immeasurable; thou upholdest all things; yea,Thou Thyself art All.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_41', 'hi', 'Hindi', 'हे भगवन्! आपको सखा मानकर आपकी इस महिमा को न जानते हुए मेरे द्वारा प्रमाद से अथवा प्रेम से भी "हे कृष्ण हे! यादव हे सखे!" इस प्रकार जो कुछ बलात् कहा गया है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_41', 'en', 'English', 'Whatever I have said unto Thee in rashness, taking Thee only for a friend and addressing Thee as O Krishna! O Yadava! O Friend!'' in thoughtless familiarity, no understanding Thy greatness;', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_42', 'hi', 'Hindi', 'और, हे अच्युत! जो आप मेरे द्वारा हँसी के लिये बिहार, शय्या, आसन और भोजन के समय अकेले में अथवा अन्यों के समक्ष भी अपमानित किये गये हैं, उन सब के लिए अप्रमेय स्वरूप आप से मैं क्षमायाचना करता हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_42', 'en', 'English', 'Whatever insult I have offered to Thee in jest, in sport or in repose, in conversation or at the banquet, alone or in a multitude, I ask Thy forgiveness for them all, O Thou Who art without an equal!', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_43', 'hi', 'Hindi', 'आप इस चराचर जगत् के पिता, पूजनीय और सर्वश्रेष्ठ गुरु हैं। हे अप्रितम प्रभाव वाले भगवन्! तीनों लोकों में आपके समान भी कोई नहीं हैं, तो फिर आपसे अधिक श्रेष्ठ कैसे होगा?।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_43', 'en', 'English', 'For Thou art the Father of all things movable and immovable, the Worshipful, the Master of Masters! In all the worlds there is none equal to Thee, how then superior, O Thou who standeth alone, Supreme.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_44', 'hi', 'Hindi', 'इसलिये हे भगवन्! मैं शरीर के द्वारा साष्टांग प्रणिपात करके स्तुति के योग्य आप ईश्वर को प्रसन्न होने के लिये प्रार्थना करता हूँ। हे देव! जैसे पिता पुत्र के, मित्र अपने मित्र के और प्रिय अपनी प्रिया के(अपराध को क्षमा करता है), वैसे ही आप भी मेरे अपराधों को क्षमा कीजिये।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_44', 'en', 'English', 'Therefore I prostrate myself before Thee, O Lord! Most Adorable! I salute Thee, I ask Thy blessing. Only Thou canst be trusted to bear with me, as father to son, as friend to friend, as lover to his beloved.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_45', 'hi', 'Hindi', 'मैं आपके इस अदृष्टपूर्व रूप को देखकर हर्षित हो रहा हूँ और मेरा मन भय से अतिव्याकुल भी हो रहा हैं। इसलिए हे देव! आप उस पूर्वकाल को ही मुझे दिखाइये। हे देवेश! हे जगन्निवास! आप प्रसन्न होइये।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_45', 'en', 'English', 'I rejoice that I have seen what never man saw before; yet, O Lord! I am overwhelmed with fear. Please take again the Form I know. Be merciful, O Lord! thou Who are the Home of the whole universe.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_46', 'hi', 'Hindi', 'मैं आपको उसी प्रकार मुकुटधारी, गदा और चक्र हाथ में लिए हुए देखना चाहता हूँ। हे विश्वमूर्ते! हे सहस्रबाहो! आप उस चतुर्भुजरूप के ही बन जाइए।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_46', 'en', 'English', 'I long to see Thee as thou wert before, with the crown, the sceptre and the discus in Thy hands; in Thy other Form, with Thy four hands, O Thou Whose arms are countless and Whose forms are infinite.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_47', 'hi', 'Hindi', 'हे अर्जुन! तुम पर प्रसन्न होकर मैंने अपनी योगशक्ति (आत्मयोगात्) के प्रभाव से यह अपना परम तेजोमय, सबका आदि और अनन्त विश्वरूप तुझे दर्शाया है, जिसे तुम्हारे पूर्व किसी ने नहीं देखा है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_47', 'en', 'English', 'Lord Shri Krishna replied: My beloved friend! It is only through My grace and power that thou hast been able to see this vision of splendour, the Universal, the Infinite, the Original. Never has it been seen by any but thee.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_48', 'hi', 'Hindi', 'हे कुरुप्रवीर! तुम्हारे अतिरिक्त इस मनुष्य लोक में किसी अन्य के द्वारा मैं इस रूप में, न वेदाध्ययन और न यज्ञ, न दान और न (धार्मिक) क्रियायों के द्वारा और न उग्र तपों के द्वारा ही देखा जा सकता हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_48', 'en', 'English', 'Not by study of the scriptures, not by sacrifice or gift, not by ritual or rigorous austerity, is it possible for man on earth to see what thou hast seen, O thou foremost hero of the Kuru-clan!', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_49', 'hi', 'Hindi', 'इस प्रकार मेरे इस घोर रूप को देखकर तुम व्यथा और मूढ़भाव को मत प्राप्त हो। निर्भय और प्रसन्नचित्त होकर तुम पुन: मेरे उसी (पूर्व के) रूप को देखो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_49', 'en', 'English', 'Be not afraid or bewildered by the terrible vision. Put away thy fear and, with joyful mind, see Me once again in My usual Form."', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_50', 'hi', 'Hindi', 'संजय ने कहा -- भगवान् वासुदेव ने अर्जुन से इस प्रकार कहकर, पुन: अपने (पूर्व) रूप को दर्शाया, और फिर, सौम्यरूप महात्मा श्रीकृष्ण ने इस भयभीत अर्जुन को आश्वस्त किया।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_50', 'en', 'English', 'Sanjaya continued: "Having thus spoken to Arjuna, Lord Shri Krishna showed Himself again in His accustomed form; and the Mighty Lord, in gentle tones, softly consoled him who lately trembled with fear.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_51', 'hi', 'Hindi', 'अर्जुन ने कहा -- हे जनार्दन! आपके इस सौम्य मनुष्य रूप को देखकर अब मैं शांतचित्त हुआ अपने स्वभाव को प्राप्त हो गया हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_51', 'en', 'English', 'Arjuna said: Seeing Thee in Thy gentle human form, my Lord, I am myself again, calm once more.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_52', 'hi', 'Hindi', 'श्रीभगवान् ने कहा -- मेरा यह रूप देखने को मिलना अति दुर्लभ है, जिसको कि तुमने देखा है। देवतागण भी सदा इस रूप के दर्शन के इच्छुक रहते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_52', 'en', 'English', 'Lord Shri Krishna replied: It is hard to see this vision of Me that thou hast seen. Even the most powerful have longed for it in vain.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_53', 'hi', 'Hindi', 'न वेदों से, न तप से, न दान से और न यज्ञ से ही मैं इस प्रकार देखा जा सकता हूँ, जैसा कि तुमने मुझे देखा है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_53', 'en', 'English', 'Not by study of the scriptures, or by austerities, not by gifts or sacrifices, is it possible to see Me as thou hast done.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_54', 'hi', 'Hindi', 'परन्तु हे परन्तप अर्जुन! अनन्य भक्ति के द्वारा मैं तत्त्वत: ''जानने'', ''देखने'' और ''प्रवेश'' करने के लिए (एकी भाव से प्राप्त होने के लिए) भी, शक्य हूँ!।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_54', 'en', 'English', 'Only by tireless devotion can I be seen and known; only thus can a man become one with Me, O Arjuna!', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_11_55', 'hi', 'Hindi', 'हे पाण्डव! जो पुरुष मेरे लिए ही कर्म करने वाला है, और मुझे ही परम लक्ष्य मानता है, जो मेरा भक्त है तथा संगरहित है, जो भूतमात्र के प्रति निर्वैर है, वह मुझे प्राप्त होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_11_55', 'en', 'English', 'He whose every action is done for My sake, to whom I am the final goal, who loves Me only and hates no one - O My dearest son, only he can realize Me!"', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_12_1', 'hi', 'Hindi', 'अर्जुन ने कहा -- जो भक्त, सतत युक्त होकर इस (पूर्वोक्त) प्रकार से आपकी उपासना करते हैं और जो भक्त अक्षर, और अव्यक्त की उपासना करते हैं, उन दोनों में कौन उत्तम योगवित् है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_12_1', 'en', 'English', '"Arjuna asked: My Lord! Which are the better devotees who worship Thee, those who try to know Thee as a Personal God, or those who worship Thee as Impersonal and Indestructible?', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_12_2', 'hi', 'Hindi', 'श्रीभगवान् ने कहा -- मुझमें मन को एकाग्र करके नित्ययुक्त हुए जो भक्तजन परम श्रद्धा से युक्त होकर मेरी उपासना करते हैं, वे, मेरे मत से, युक्ततम हैं अर्थात् श्रेष्ठ हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_12_2', 'en', 'English', 'Lord Shri Krishna replied: Those who keep their minds fixed on Me, who worship Me always with unwavering faith and concentration; these are the very best.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_12_3', 'hi', 'Hindi', 'Swami Tejomayananda did not comment on this sloka', FALSE, 'Swami Tejomayananda'),
  ('bg_12_3', 'en', 'English', 'Shri Purohit Swami did not comment on this sloka', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_12_4', 'hi', 'Hindi', 'इन्द्रिय समुदाय को सम्यक् प्रकार से नियमित करके, सर्वत्र समभाव वाले, भूतमात्र के हित में रत वे भक्त मुझे ही प्राप्त होते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_12_4', 'en', 'English', 'Subduing their senses, viewing all conditions of life with the same eye, and working for the welfare of all beings, assuredly they come to Me.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_12_5', 'hi', 'Hindi', 'परन्तु उन अव्यक्त में आसक्त हुए चित्त वाले पुरुषों को क्लेश अधिक होता है, क्योंकि देहधारियों से अव्यक्त की गति कठिनाईपूर्वक प्राप्त की जाती है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_12_5', 'en', 'English', 'But they who thus fix their attention on the Absolute and Impersonal encounter greater hardships, for it is difficult for those who possess a body to realise Me as without one.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_12_6', 'hi', 'Hindi', 'परन्तु जो भक्तजन मुझे ही परम लक्ष्य समझते हुए सब कर्मों को मुझे अर्पण करके अनन्ययोग के द्वारा मेरा (सगुण का) ही ध्यान करते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_12_6', 'en', 'English', 'Verily, those who surrender their actions to Me, who muse on Me, worship Me and meditate on Me alone, with no thought save of Me,', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_12_7', 'hi', 'Hindi', 'हे पार्थ ! जिनका चित्त मुझमें ही स्थिर हुआ है ऐसे भक्तों का मैं शीघ्र ही मृत्युरूप संसार सागर से उद्धार करने वाला होता हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_12_7', 'en', 'English', 'O Arjuna! I rescue them from the ocean of life and death, for their minds are fixed on Me.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_12_8', 'hi', 'Hindi', 'तुम अपने मन और बुद्धि को मुझमें ही स्थिर करो, तदुपरान्त तुम मुझमें ही निवास करोगे, इसमें कोई संशय नहीं है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_12_8', 'en', 'English', 'Then let thy mind cling only to Me, let thy intellect abide in Me; and without doubt thou shalt live hereafter in Me alone.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_12_9', 'hi', 'Hindi', 'हे धनंजय ! यदि तुम अपने मन को मुझमें स्थिर करने में समर्थ नहीं हो, तो अभ्यासयोग के द्वारा तुम मुझे प्राप्त करने की इच्छा (अर्थात् प्रयत्न) करो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_12_9', 'en', 'English', 'But if thou canst not fix thy mind firmly on Me, then, My beloved friend, try to do so by constant practice.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_12_10', 'hi', 'Hindi', 'यदि तुम अभ्यास में भी असमर्थ हो तो मत्कर्म परायण बनो; इस प्रकार मेरे लिए कर्मों को करते हुए भी तुम सिद्धि को प्राप्त करोगे।।', FALSE, 'Swami Tejomayananda'),
  ('bg_12_10', 'en', 'English', 'And if thou are not strong enough to practise concentration, then devote thyself to My service, do all thine acts for My sake, and thou shalt still attain the goal.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_12_11', 'hi', 'Hindi', 'और यदि इसको भी करने के लिए तुम असमर्थ हो, तो आत्मसंयम से युक्त होकर मेरी प्राप्ति रूप योग का आश्रय लेकर, तुम समस्त कर्मों के फल का त्याग करो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_12_11', 'en', 'English', 'And if thou art too weak even for this, then seek refuge in union with Me, and with perfect self-control renounce the fruit of thy action.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_12_12', 'hi', 'Hindi', 'अभ्यास से ज्ञान श्रेष्ठ है; ज्ञान से श्रेष्ठ ध्यान है और ध्यान से भी श्रेष्ठ कर्मफल त्याग है त्याग; से तत्काल ही शान्ति मिलती है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_12_12', 'en', 'English', 'Knowledge is superior to blind action, meditation to mere knowledge, renunciation of the fruit of action to meditation, and where there is renunciation peace will follow.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_12_13', 'hi', 'Hindi', 'भूतमात्र के प्रति जो द्वेषरहित है तथा सबका मित्र तथा करुणावान् है; जो ममता और अहंकार से रहित, सुख और दु:ख में सम और क्षमावान् है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_12_13', 'en', 'English', 'He who is incapable of hatred towards any being, who is kind and compassionate, free from selfishness, without pride, equable in pleasure and in pain, and forgiving,', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_12_14', 'hi', 'Hindi', 'जो संयतात्मा, दृढ़निश्चयी योगी सदा सन्तुष्ट है, जो अपने मन और बुद्धि को मुझमें अर्पण किये हुए है, जो ऐसा मेरा भक्त है, वह मुझे प्रिय है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_12_14', 'en', 'English', 'Always contented, self-centred, self-controlled, resolute, with mind and reason dedicated to Me, such a devotee of Mine is My beloved.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_12_15', 'hi', 'Hindi', 'जिससे कोई लोक (अर्थात् जीव, व्यक्ति) उद्वेग को प्राप्त नहीं होता और जो स्वयं भी किसी व्यक्ति से उद्वेग अनुभव नहीं करता तथा जो हर्ष, अमर्ष (असहिष्णुता) भय और उद्वेगों से मुक्त है,वह भक्त मुझे प्रिय है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_12_15', 'en', 'English', 'He who does not harm the world, and whom the world cannot harm, who is not carried away by any impulse of joy, anger or fear, such a one is My beloved.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_12_16', 'hi', 'Hindi', 'जो अपेक्षारहित, शुद्ध, दक्ष, उदासीन, व्यथारहित और सर्वकर्मों का संन्यास करने वाला मेरा भक्त है, वह मुझे प्रिय है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_12_16', 'en', 'English', 'He who expects nothing, who is pure, watchful, indifferent, unruffled, and who renounces all initiative, such a one is My beloved.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_12_17', 'hi', 'Hindi', 'जो न हर्षित होता है और न द्वेष करता है; न शोक करता है और न आकांक्षा; तथा जो शुभ और अशुभ को त्याग देता है, वह भक्तिमान् पुरुष मुझे प्रिय है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_12_17', 'en', 'English', 'He who is beyond joy and hate, who neither laments nor desires, to whom good and evil fortunes are the same, such a one is My beloved.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_12_18', 'hi', 'Hindi', 'Swami Tejomayananda did not comment on this sloka', FALSE, 'Swami Tejomayananda'),
  ('bg_12_18', 'en', 'English', 'Shri Purohit Swami did not comment on this sloka', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_12_19', 'hi', 'Hindi', 'जिसको निन्दा और स्तुति दोनों ही तुल्य है, जो मौनी है, जो किसी अल्प वस्तु से भी सन्तुष्ट है, जो अनिकेत है, वह स्थिर बुद्धि का भक्तिमान् पुरुष मुझे प्रिय है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_12_19', 'en', 'English', 'Who is indifferent to praise and censure, who enjoys silence, who is contented with every fate, who has no fixed abode, who is steadfast in mind, and filled with devotion, such a one is My beloved.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_12_20', 'hi', 'Hindi', 'जो भक्त श्रद्धावान् तथा मुझे ही परम लक्ष्य समझने वाले हैं और इस यथोक्त धर्ममय अमृत का अर्थात् धर्ममय जीवन का पालन करते हैं, वे मुझे अतिशय प्रिय हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_12_20', 'en', 'English', 'Verily those who love the spiritual wisdom as I have taught, whose faith never fails, and who concentrate their whole nature on Me, they indeed are My most beloved."', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_13_1', 'hi', 'Hindi', 'अर्जुन ने कहा -- हे केशव ! मैं, प्रकृति और पुरुष, क्षेत्र और क्षेत्रज्ञ तथा ज्ञान और ज्ञेय को जानना चाहता हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_13_1', 'en', 'English', '"Arjuna asked: My Lord! Who is God and what is Nature; what is Matter and what is the Self; what is that they call Wisdom, and what is it that is worth knowing? I wish to have this explained.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_13_2', 'hi', 'Hindi', 'श्रीभगवान् ने कहा -- हे कौन्तेय ! यह शरीर क्षेत्र कहा जाता है और इसको जो जानता है, उसे तत्त्वज्ञ जन, क्षेत्रज्ञ कहते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_13_2', 'en', 'English', 'Lord Shri Krishna replied: O Arjuna! The body of man is the playground of the Self; and That which knows the activities of Matter, sages call the Self.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_13_3', 'hi', 'Hindi', 'हे भारत ! तुम समस्त क्षेत्रों में क्षेत्रज्ञ मुझे ही जानो। क्षेत्र और क्षेत्रज्ञ का जो ज्ञान है, वही (वास्तव में) ज्ञान है , ऐसा मेरा मत है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_13_3', 'en', 'English', 'I am the Omniscient self that abides in the playground of Matter; knowledge of Matter and of the all-knowing Self is wisdom.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_13_4', 'hi', 'Hindi', 'इसलिये, वह क्षेत्र जो है और जैसा है तथा जिन विकारों वाला है, और जिस (कारण) से जो (कार्य) हुआ है तथा वह (क्षेत्रज्ञ) भी जो है और जिस प्रभाव वाला है, वह संक्षेप में मुझसे सुनो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_13_4', 'en', 'English', 'What is called Matter, of what it is composed, whence it came, and why it changes, what the Self is, and what Its power - this I will now briefly set forth.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_13_5', 'hi', 'Hindi', '(क्षेत्र-क्षेत्रज्ञ के विषय में) ऋषियों द्वारा विभिन्न और विविध छन्दों में बहुत प्रकार से गाया गया है, तथा सम्यक् प्रकार से निश्चित किये हुये युक्तियुक्त ब्रह्मसूत्र के पदों द्वारा (अर्थात् ब्रह्म के सूचक शब्दों द्वारा) भी (वैसे ही कहा गया है)।।', FALSE, 'Swami Tejomayananda'),
  ('bg_13_5', 'en', 'English', 'Seers have sung of It in various ways, in many hymns and sacred Vedic songs, weighty in thought and convincing in argument.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_13_6', 'hi', 'Hindi', 'पंच महाभूत, अहंकार, बुद्धि, अव्यक्त (प्रकृति), दस इन्द्रियाँ, एक मन, इन्द्रियों के पाँच विषय।।', FALSE, 'Swami Tejomayananda'),
  ('bg_13_6', 'en', 'English', 'The five great fundamentals (earth, fire, air, water and ether), personality, intellect, the mysterious life force, the ten organs of perception and action, the mind and the five domains of sensation;', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_13_7', 'hi', 'Hindi', 'इच्छा, द्वेष, सुख, दुख, संघात (स्थूलदेह), चेतना (अन्त:करण की चेतन वृत्ति) तथा धृति -  इस प्रकार यह क्षेत्र विकारों के सहित संक्षेप में कहा गया है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_13_7', 'en', 'English', 'Desire, aversion, pleasure, pain, sympathy, vitality and the persistent clinging to life, these are in brief the constituents of changing Matter.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_13_8', 'hi', 'Hindi', 'अमानित्व, अदम्भित्व, अहिंसा, क्षमा, आर्जव, आचार्य की सेवा, शुद्धि, स्थिरता और आत्मसंयम।।', FALSE, 'Swami Tejomayananda'),
  ('bg_13_8', 'en', 'English', 'Humility, sincerity, harmlessness, forgiveness, rectitude, service of the Master, purity, steadfastness, self-control;', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_13_9', 'hi', 'Hindi', 'इन्द्रियों के विषय के प्रति वैराग्य, अहंकार का अभाव, जन्म, मृत्यु, वृद्धवस्था, व्याधि और दुख में दोष दर्शन...৷৷.।।', FALSE, 'Swami Tejomayananda'),
  ('bg_13_9', 'en', 'English', 'Renunciation of the delights of sense, absence of pride, right understanding of the painful problem of birth and death, of age and sickness;', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_13_10', 'hi', 'Hindi', 'आसक्ति तथा पुत्र, पत्नी, गृह आदि में अनभिष्वङ्ग (तादात्म्य का अभाव); और इष्ट और अनिष्ट की प्राप्ति में समचित्तता।।', FALSE, 'Swami Tejomayananda'),
  ('bg_13_10', 'en', 'English', 'Indifference, non-attachment to sex, progeny or home, equanimity in good fortune and in bad;', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_13_11', 'hi', 'Hindi', 'अनन्ययोग के द्वारा मुझमें अव्यभिचारिणी भक्ति; एकान्त स्थान में रहने का स्वभाव और (असंस्कृत) जनों के समुदाय में अरुचि।।', FALSE, 'Swami Tejomayananda'),
  ('bg_13_11', 'en', 'English', 'Unswerving devotion to Me, by concentration on Me and Me alone, a love for solitude, indifference to social life;', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_13_12', 'hi', 'Hindi', 'अध्यात्मज्ञान में नित्यत्व अर्थात् स्थिरता तथा तत्त्वज्ञान के अर्थ रूप परमात्मा का दर्शन, यह सब तो ज्ञान कहा गया है, और जो इससे विपरीत है, वह अज्ञान है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_13_12', 'en', 'English', 'Constant yearning for the knowledge of Self, and pondering over the lessons of the great Truth - this is Wisdom, all else ignorance.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_13_13', 'hi', 'Hindi', 'मैं उस ज्ञेय वस्तु को स्पष्ट कहूंगा जिसे जानकर मनुष्य अमृतत्व को प्राप्त करता है। वह ज्ञेय है - अनादि, परम ब्रह्म, जो न सत् और न असत् ही कहा जा सकता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_13_13', 'en', 'English', 'I will speak to thee now of that great Truth which man ought to know, since by its means he will win immortal bliss - that which is without beginning, the Eternal Spirit which dwells in Me, neither with form, nor yet without it.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_13_14', 'hi', 'Hindi', 'वह सब ओर हाथ-पैर वाला है और सब ओर से नेत्र, शिर और मुखवाला तथा सब ओर से श्रोत्रवाला है; वह जगत् में सबको व्याप्त करके स्थित है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_13_14', 'en', 'English', 'Everywhere are Its hands and Its feet; everywhere It has eyes that see, heads that think and mouths that speak; everywhere It listens; It dwells in all the worlds; It envelops them all.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_13_15', 'hi', 'Hindi', 'वह समस्त इन्द्रियों के गुणो (कार्यों) के द्वारा प्रकाशित होने वाला, परन्तु (वस्तुत:) समस्त इन्द्रियों से रहित है; आसक्ति रहित तथा गुण रहित होते हुए भी सबको धारणपोषण करने वाला और गुणों का भोक्ता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_13_15', 'en', 'English', 'Beyond the senses, It yet shines through every sense perception. Bound to nothing, It yet sustains everything. Unaffected by the Qualities, It still enjoys them all.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_13_16', 'hi', 'Hindi', '(वह ब्रह्म) भूत मात्र के अन्तर्बाह्य स्थित है; वह चर है और अचर भी। सूक्ष्म होने से वह अविज्ञेय है; वह सुदूर और अत्यन्त समीपस्थ भी है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_13_16', 'en', 'English', 'It is within all beings, yet outside; motionless yet moving; too subtle to be perceived; far away yet always near.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_13_17', 'hi', 'Hindi', 'और वह अविभक्त है, तथापि वह भूतों में विभक्त के समान स्थित है। वह ज्ञेय ब्रह्म भूतमात्र का भर्ता, संहारकर्ता और उत्पत्ति कर्ता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_13_17', 'en', 'English', 'In all beings undivided, yet living in division, It is the upholder of all, Creator and Destroyer alike;', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_13_18', 'hi', 'Hindi', '(वह ब्रह्म) ज्योतियों की भी ज्योति और (अज्ञान) अन्धकार से परे कहा जाता है। वह ज्ञान (चैतन्यस्वरूप) ज्ञेय और ज्ञान के द्वारा जानने योग्य (ज्ञानगम्य) है। वह सभी के हृदय में स्थित है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_13_18', 'en', 'English', 'It is the Light of lights, beyond the reach of darkness; the Wisdom, the only thing that is worth knowing or that wisdom can teach; the Presence in the hearts of all.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_13_19', 'hi', 'Hindi', 'इस प्रकार, (मेरे द्वारा) क्षेत्र, ज्ञान और ज्ञेय को संक्षेपत: कहा गया। इसे तत्त्व से जानकर (विज्ञाय) मेरा भक्त मेरे स्वरूप को प्राप्त होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_13_19', 'en', 'English', 'Thus I have told thee in brief what Matter is, and the Self worth realising and what is Wisdom. He who is devoted to Me knows; and assuredly he will enter into Me.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_13_20', 'hi', 'Hindi', 'प्रकृति और पुरुष इन दोनों को ही तुम अनादि जानो। और तुम यह भी जानो कि सभी विकार और गुण प्रकृति से ही उत्पन्न हुए हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_13_20', 'en', 'English', 'Know thou further that Nature and God have no beginning; and that differences of character and quality have their origin in Nature only.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_13_21', 'hi', 'Hindi', 'कार्य और कारण के उत्पन्न करने में हेतु प्रकृति कही जाती है और पुरुष सुख-दु:ख के भोक्तृत्व में हेतु कहा जाता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_13_21', 'en', 'English', 'Nature is the Law which generates cause and effect; God is the source of the enjoyment of all pleasure and pain.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_13_22', 'hi', 'Hindi', 'प्रकृति में स्थित पुरुष प्रकृति से उत्पन्न गुणों को भोगता है। इन गुणों का संग ही इस पुरुष (जीव) के शुभ और अशुभ योनियों में जन्म लेने का कारण है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_13_22', 'en', 'English', 'God dwelling in the heart of Nature experiences the Qualities which nature brings forth; and His affinity towards the Qualities is the reason for His living in a good or evil body.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_13_23', 'hi', 'Hindi', 'परम पुरुष ही इस देह में उपद्रष्टा, अनुमन्ता ,भर्ता, भोक्ता, महेश्वर और परमात्मा कहा जाता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_13_23', 'en', 'English', 'Thus in the body of man dwells the Supreme God; He who sees and permits, upholds and enjoys, the Highest God and the Highest Self.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_13_24', 'hi', 'Hindi', 'इस प्रकार पुरुष और गुणों के सहित प्रकृति को जो मनुष्य जानता है, वह सब प्रकार से रहता हुआ (व्यवहार करता हुआ) भी पुन: नहीं जन्मता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_13_24', 'en', 'English', 'He who understands God and Nature along with her qualities, whatever be his condition in life, he comes not again to earth.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_13_25', 'hi', 'Hindi', 'कोई पुरुष ध्यान के अभ्यास से आत्मा को आत्मा (हृदय) में आत्मा (शुद्ध बुद्धि) के द्वारा देखते हैं; अन्य लोग सांख्य योग के द्वारा तथा कोई साधक कर्मयोग से (आत्मा को देखते हैं )।।', FALSE, 'Swami Tejomayananda'),
  ('bg_13_25', 'en', 'English', 'Some realise the Supreme by meditating, by its aid, on the Self within, others by pure reason, others by right action.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_13_26', 'hi', 'Hindi', 'परन्तु, अन्य लोग जो स्वयं इस प्रकार न जानते हुए, दूसरों से (आचार्यों से) सुनकर ही उपासना करते हैं, वे श्रुतिपरायण (अर्थात् श्रवण ही जिनके लिए परम साधन है) लोग भी मृत्यु को नि:सन्देह तर जाते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_13_26', 'en', 'English', 'Others again, having no direct knowledge but only hearing from others, nevertheless worship, and they, too, if true to the teachings, cross the sea of death.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_13_27', 'hi', 'Hindi', 'हे भरत श्रेष्ठ ! यावन्मात्र जो कुछ भी स्थावर जंगम (चराचर) वस्तु उत्पन्न होती है, उस सबको तुम क्षेत्र और क्षेत्रज्ञ के संयोग से उत्पन्न हुई जानो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_13_27', 'en', 'English', 'Wherever life is seen in things movable or immovable, it is the joint product of Matter and Spirit.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_13_28', 'hi', 'Hindi', 'जो पुरुष समस्त नश्वर भूतों में अनश्वर परमेश्वर को समभाव से स्थित देखता है, वही (वास्तव में) देखता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_13_28', 'en', 'English', 'He who can see the Supreme Lord in all beings, the Imperishable amidst the perishable, he it is who really sees.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_13_29', 'hi', 'Hindi', 'निश्चय ही, वह पुरुष सर्वत्र सम भाव से स्थित परमेश्वर को समान हुआ आत्मा (स्वयं) के द्वारा आत्मा (स्वयं) का नाश नहीं करता है, इससे वह परम गति को प्राप्त होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_13_29', 'en', 'English', 'Beholding the Lord in all things equally, his actions do not mar his spiritual life but lead him to the height of Bliss.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_13_30', 'hi', 'Hindi', 'जो पुरुष समस्त कर्मों को सर्वश: प्रकृति द्वारा ही किये गये देखता है तथा आत्मा को अकर्ता देखता है, वही (वास्तव में) देखता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_13_30', 'en', 'English', 'He who understands that it is only the Law of Nature that brings action to fruition, and that the Self never acts, alone knows the Truth.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_13_31', 'hi', 'Hindi', 'यह पुरुष जब भूतों के पृथक् भावों को एक (परमात्मा) में स्थित देखता है तथा उस (परमात्मा) से ही यह विस्तार हुआ जानता है, तब वह ब्रह्म को प्राप्त होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_13_31', 'en', 'English', 'He who sees the diverse forms of life all rooted in One, and growing forth from Him, he shall indeed find the Absolute.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_13_32', 'hi', 'Hindi', 'हे कौन्तेय ! अनादि और निर्गुण होने से यह परमात्मा अव्यय है। शरीर में स्थित हुआ भी, वस्तुत:, वह न (कर्म) करता है और न (फलों से) लिप्त होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_13_32', 'en', 'English', 'The Supreme Spirit, O Prince, is without beginning, without Qualities and Imperishable, and though it be within the body, yet It does not act, nor is It affected by action.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_13_33', 'hi', 'Hindi', 'जिस प्रकार सर्वगत आकाश सूक्ष्म होने के कारण लिप्त नहीं होता, उसी प्रकार सर्वत्र देह में स्थित आत्मा लिप्त नहीं होता।।', FALSE, 'Swami Tejomayananda'),
  ('bg_13_33', 'en', 'English', 'As space, though present everywhere, remains by reason of its subtlety unaffected, so the Self, though present in all forms, retains its purity unalloyed.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_13_34', 'hi', 'Hindi', 'हे भारत ! जिस प्रकार एक ही सूर्य इस सम्पूर्ण लोक को प्रकाशित करता है, उसी प्रकार एक ही क्षेत्री (क्षेत्रज्ञ) सम्पूर्ण क्षेत्र को प्रकाशित करता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_13_34', 'en', 'English', 'As the one Sun illuminates the whole earth, so the Lord illumines the whole universe.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_13_35', 'hi', 'Hindi', 'इस प्रकार, जो पुरुष ज्ञानचक्षु के द्वारा क्षेत्र और क्षेत्रज्ञ के भेद को तथा प्रकृति के विकारों से मोक्ष को जानते हैं, वे परम ब्रह्म को प्राप्त होते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_13_35', 'en', 'English', 'Those who with the eyes of wisdom thus see the difference between Matter and Spirit, and know how to liberate Life from the Law of Nature, they attain the Supreme."', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_14_1', 'hi', 'Hindi', 'श्री भगवान् ने कहा -- समस्त ज्ञानों में उत्तम परम ज्ञान को मैं पुन: कहूंगा, जिसको जानकर सभी मुनिजन इस (लोक) से जाकर (इस जीवनोपरान्त) परम सिद्धि को प्राप्त हुए हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_14_1', 'en', 'English', '"Lord Shri Krishna continued: Now I will reveal unto the Wisdom which is beyond knowledge, by attaining which the sages have reached Perfection.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_14_2', 'hi', 'Hindi', 'इस ज्ञान का आश्रय लेकर मेरे स्वरूप (सार्धम्यम्) को प्राप्त पुरुष सृष्टि के आदि में जन्म नहीं लेते और प्रलयकाल में व्याकुल भी नहीं होते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_14_2', 'en', 'English', 'Dwelling in Wisdom and realising My Divinity, they are not born again when the universe is re-created at the beginning of every cycle, nor are they affected when it is dissolved.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_14_3', 'hi', 'Hindi', 'हे भारत ! मेरी महद् ब्रह्मरूप प्रकृति, (भूतों की) योनि है, जिसमें मैं गर्भाधान करता हूँ; इससे समस्त भूतों की उत्पत्ति होती है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_14_3', 'en', 'English', 'The eternal Cosmos is My womb, in which I plant the seed, from which all beings are born, O Prince!', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_14_4', 'hi', 'Hindi', 'हे कौन्तेय ! समस्त योनियों में जितनी मूर्तियाँ (शरीर) उत्पन्न होती हैं, उन सबकी योनि अर्थात् गर्भ है महद्ब्रह्म और मैं बीज की स्थापना करने वाला पिता हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_14_4', 'en', 'English', 'O illustrious son of Kunti! Through whatever wombs men are born, it is the Spirit Itself that conceives, and I am their Father.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_14_5', 'hi', 'Hindi', 'हे महाबाहो ! सत्त्व, रज और तम ये प्रकृति से उत्पन्न तीनों गुण देही आत्मा को देह के साथ बांध देते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_14_5', 'en', 'English', 'Purity, Passion and Ignorance are the Qualities which the Law of nature bringeth forth. They fetter the free Spirit in all beings.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_14_6', 'hi', 'Hindi', 'हे निष्पाप अर्जुन ! इन (तीनों) में, सत्त्वगुण निर्मल होने से प्रकाशक और अनामय (निरुपद्रव, निर्विकार या निरोग) है; (वह जीव को) सुख की आसक्ति से और ज्ञान की आसक्ति से बांध देता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_14_6', 'en', 'English', 'O Sinless One! Of these, Purity, being luminous, strong and invulnerable, binds one by its yearning for happiness and illumination.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_14_7', 'hi', 'Hindi', 'हे कौन्तेय ! रजोगुण को रागस्वरूप जानो, जिससे तृष्णा और आसक्ति उत्पन्न होती है। वह देही आत्मा को कर्मों की आसक्ति से बांधता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_14_7', 'en', 'English', 'Passion, engendered by thirst for pleasure and attachment, binds the soul through its fondness for activity.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_14_8', 'hi', 'Hindi', 'और हे भारत ! तमोगुण को अज्ञान से उत्पन्न जानो; जो समस्त देहधारियों (जीवों) को मोहित करने वाला है। वह प्रमाद, आलस्य और निद्रा के द्वारा जीव को बांधता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_14_8', 'en', 'English', 'But Ignorance, the product of darkness, stupefies the senses in all embodied beings, binding them by chains of folly, indolence and lethargy.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_14_9', 'hi', 'Hindi', 'हे भारत ! सत्त्वगुण सुख में आसक्त कर देता है और रजोगुण कर्म में, किन्तु तमोगुण ज्ञान को आवृत्त करके जीव को प्रमाद से युक्त कर देता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_14_9', 'en', 'English', 'Purity brings happiness, Passion commotion, and Ignorance, which obscures wisdom, leads to a life of failure.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_14_10', 'hi', 'Hindi', 'हे भारत ! कभी रज और तम को अभिभूत (दबा) करके सत्त्वगुण की वृद्धि होती है, कभी रज और सत्त्व को दबाकर तमोगुण की वृद्धि होती है, तो कभी तम और सत्त्व को अभिभूत कर रजोगुण की वृद्धि होती है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_14_10', 'en', 'English', 'O Prince! Purity prevails when Passion and Ignorance are overcome; Passion, when Purity and Ignorance are overcome; and Ignorance when it overcomes Purity and Passion.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_14_11', 'hi', 'Hindi', 'जब इस देह के द्वारों अर्थात् समस्त इन्द्रियों में ज्ञानरूप प्रकाश उत्पन्न होता है, तब सत्त्वगुण को प्रवृद्ध हुआ जानो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_14_11', 'en', 'English', 'When the light of knowledge gleams forth from all the gates of the body, then be sure that Purity prevails.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_14_12', 'hi', 'Hindi', 'हे भरत-श्रेष्ठ ! रजोगुण के प्रवृद्ध होने पर लोभ, प्रवृत्ति (सामान्य चेष्टा) कर्मों का आरम्भ, शम का अभाव तथा स्पृहा, ये सब उत्पन्न होते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_14_12', 'en', 'English', 'O best of Indians! Avarice, the impulse to act and the beginning of action itself are all due to the dominance of Passion.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_14_13', 'hi', 'Hindi', 'हे कुरुनन्दन ! तमोगुण के प्रवृद्ध होने पर अप्रकाश, अप्रवृत्ति, प्रमाद और मोह ये सब उत्पन्न होते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_14_13', 'en', 'English', 'Darkness, stagnation, folly and infatuation are the result of the dominance of Ignorance, O joy of the Kuru-clan!', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_14_14', 'hi', 'Hindi', 'जब यह जीव (देहभृत्) सत्त्वगुण की प्रवृद्धि में मृत्यु को प्राप्त होता है, तब उत्तम कर्म करने वालों के निर्मल अर्थात् स्वर्गादि लोकों को प्राप्त होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_14_14', 'en', 'English', 'When Purity prevails, the soul on quitting the body passes on to the pure regions where live those who know the Highest.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_14_15', 'hi', 'Hindi', 'रजोगुण के प्रवृद्ध काल में मृत्यु को प्राप्त होकर कर्मासक्ति वाले (मनुष्य) लोक में वह जन्म लेता है तथा तमोगुण के प्रवृद्धकाल में (मरण होने पर) मूढ़योनि में जन्म लेता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_14_15', 'en', 'English', 'When Passion prevails, the soul is reborn among those who love activity; when Ignorance rules, it enters the wombs of the ignorant.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_14_16', 'hi', 'Hindi', 'शुभ कर्म का फल सात्विक और निर्मल कहा गया है; रजोगुण का फल दु;ख और तमोगुण का फल अज्ञान है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_14_16', 'en', 'English', 'They say the fruit of a meritorious action is spotless and full of purity; the outcome of Passion is misery, and of Ignorance darkness.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_14_17', 'hi', 'Hindi', 'सत्त्वगुण से ज्ञान उत्पन्न होता है। रजोगुण से लोभ तथा तमोगुण से प्रमाद, मोह और अज्ञान उत्पन्न होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_14_17', 'en', 'English', 'Purity engenders Wisdom, Passion avarice, and Ignorance folly, infatuation and darkness.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_14_18', 'hi', 'Hindi', 'सत्त्वगुण में स्थित पुरुष उच्च (लोकों को) जाते हैं; राजस पुरुष मध्य (मनुष्य लोक) में रहते हैं और तमोगुण की अत्यन्त हीन प्रवृत्तियों में स्थित तामस लोग अधोगति को प्राप्त होते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_14_18', 'en', 'English', 'When Purity is in the ascendant, the man evolves; when Passion, he neither evolves nor degenerates; when Ignorance, he is lost.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_14_19', 'hi', 'Hindi', 'जब द्रष्टा (साधक) पुरुष तीनों गुणों के अतिरिक्त किसी अन्य को कर्ता नहीं देखता, अर्थात् नहीं समझता है और तीनों गुणों से परे मेरे तत्व को जानता है, तब वह मेरे स्वरूप को प्राप्त होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_14_19', 'en', 'English', 'As soon as man understands that it is only the Qualities which act and nothing else, and perceives That which is beyond, he attains My divine nature.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_14_20', 'hi', 'Hindi', 'यह देही पुरुष शरीर की उत्पत्ति के कारणरूप तीनों गुणों से अतीत होकर जन्म, मृत्यु, जरा और दु:खों से विमुक्त हुआ अमृतत्व को प्राप्त होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_14_20', 'en', 'English', 'When the soul transcends the Qualities, which are the real cause of physical existence, then, freed from birth and death, from old age and misery, he quaffs the nectar of immortality.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_14_21', 'hi', 'Hindi', 'अर्जुन ने कहा -- हे प्रभो ! इन तीनो गुणों से अतीत हुआ पुरुष किन लक्षणों से युक्त होता है ? वह किस प्रकार के आचरण वाला होता है ? और, वह किस उपाय से इन तीनों गुणों से अतीत होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_14_21', 'en', 'English', 'Arjuna asked: My Lord! By what signs can he who has transcended the Qualities be recognized? How does he act? How does he live beyond them?', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_14_22', 'hi', 'Hindi', 'श्रीभगवान् ने कहा -- हे पाण्डव ! (ज्ञानी पुरुष) प्रकाश, प्रवृत्ति और मोह के प्रवृत्त होने पर भी उनका द्वेष नहीं करता तथा निवृत्त होने पर उनकी आकांक्षा नहीं करता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_14_22', 'en', 'English', 'Lord Shri Krishna replied: O Prince! He who shuns not the Quality which is present, and longs not for that which is absent;', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_14_23', 'hi', 'Hindi', 'जो उदासीन के समान आसीन होकर गुणों के द्वारा विचलित नहीं किया जा सकता और "गुण ही व्यवहार करते हैं" ऐसा जानकर स्थित रहता है और उस स्थिति से विचलित नहीं होता।।', FALSE, 'Swami Tejomayananda'),
  ('bg_14_23', 'en', 'English', 'He who maintains an attitude of indifference, who is not disturbed by the Qualities, who realises that it is only they who act, and remains calm;', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_14_24', 'hi', 'Hindi', 'जो स्वस्थ (स्वरूप में स्थित), सुख-दु:ख में समान रहता है तथा मिट्टी, पत्थर और स्वर्ण में समदृष्टि रखता है; ऐसा वीर पुरुष प्रिय और अप्रिय को तथा निन्दा और आत्मस्तुति को तुल्य समझता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_14_24', 'en', 'English', 'Who accepts pain and pleasure as it comes, is centred in his Self, to whom a piece of clay or stone or gold are the same, who neither likes nor dislikes, who is steadfast, indifferent alike to praise or censure;', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_14_25', 'hi', 'Hindi', 'जो मान और अपमान में सम है; शत्रु और मित्र के पक्ष में भी सम है, ऐसा सर्वारम्भ परित्यागी पुरुष गुणातीत कहा जाता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_14_25', 'en', 'English', 'Who looks equally upon honour and dishonour, loves friends and foes alike, abandons all initiative, such is he who transcends the Qualities.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_14_26', 'hi', 'Hindi', 'जो पुरुष अव्यभिचारी भक्तियोग के द्वारा मेरी सेवा अर्थात् उपासना करता है, वह इन तीनों गुणों के अतीत होकर ब्रह्म बनने के लिये योग्य हो जाता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_14_26', 'en', 'English', 'And he who serves Me and only Me, with unfaltering devotion, shall overcome the Qualities, and become One with the Eternal.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_14_27', 'hi', 'Hindi', 'क्योंकि मैं अमृत, अव्यय, ब्रह्म, शाश्वत धर्म और ऐकान्तिक अर्थात् पारमार्थिक सुख की प्रतिष्ठा हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_14_27', 'en', 'English', 'For I am the Home of the Spirit, the continual Source of immortality, of eternal Righteousness and of infinite Joy."', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_15_1', 'hi', 'Hindi', 'श्री भगवान् ने कहा -- (ज्ञानी पुरुष इस संसार वृक्ष को) ऊर्ध्वमूल और अध:शाखा वाला अश्वत्थ और अव्यय कहते हैं; जिसके पर्ण छन्द अर्थात् वेद हैं, ऐसे (संसार वृक्ष) को जो जानता है, वह वेदवित् है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_15_1', 'en', 'English', '"Lord Shri Krishna continued: This phenomenal creation, which is both ephemeral and eternal, is like a tree, but having its seed above in the Highest and its ramifications on this earth below. The scriptures are its leaves, and he who understands this, knows.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_15_2', 'hi', 'Hindi', 'उस वृक्ष की शाखाएं गुणों से प्रवृद्ध हुईं नीचे और ऊपर फैली हुईं हैं; (पंच) विषय इसके अंकुर हैं; मनुष्य लोक में कर्मों का अनुसरण करने वाली इसकी अन्य जड़ें नीचे फैली हुईं हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_15_2', 'en', 'English', 'Its branches shoot upwards and downwards, deriving their nourishment from the Qualities; its buds are the objects of sense; and its roots, which follow the Law causing man''s regeneration and degeneration, pierce downwards into the soil.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_15_3', 'hi', 'Hindi', 'इस (संसार वृक्ष) का स्वरूप जैसा कहा गया है वैसा यहाँ उपलब्ध नहीं होता है, क्योंकि इसका न आदि है और न अंत और न प्रतिष्ठा ही है। इस अति दृढ़ मूल वाले अश्वत्थ वृक्ष को दृढ़ असङ्ग शस्त्र से काटकर ...৷৷৷৷।।', FALSE, 'Swami Tejomayananda'),
  ('bg_15_3', 'en', 'English', 'In this world its true form is not known, neither its origin nor its end, and its strength is not understood., until the tree with its roots striking deep into the earth is hewn down by the sharp axe of non-attachment.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_15_4', 'hi', 'Hindi', '(तदुपरान्त) उस पद का अन्वेषण करना चाहिए जिसको प्राप्त हुए पुरुष पुन: संसार में नहीं लौटते हैं। "मैं उस आदि पुरुष की शरण हूँ, जिससे यह पुरातन प्रवृत्ति प्रसृत हुई है"।।', FALSE, 'Swami Tejomayananda'),
  ('bg_15_4', 'en', 'English', 'Beyond lies the Path, from which, when found, there is no return. This is the Primal God from whence this ancient creation has sprung.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_15_5', 'hi', 'Hindi', 'जिनका मान और मोह निवृत्त हो गया है, जिन्होंने संगदोष को जीत लिया है, जो अध्यात्म में स्थित हैं जिनकी कामनाएं निवृत्त हो चुकी हैं और जो सुख-दु:ख नामक द्वन्द्वों से विमुक्त हो गये हैं, ऐसे सम्मोह रहित ज्ञानीजन उस अव्यय पद को प्राप्त होते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_15_5', 'en', 'English', 'The wise attain Eternity when, freed from pride and delusion, they have conquered their love for the things of sense; when, renouncing desire and fixing their gaze on the Self, they have ceased to be tossed to and fro by the opposing sensations, like pleasure and pain.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_15_6', 'hi', 'Hindi', 'उसे न सूर्य प्रकाशित कर सकता है और न चन्द्रमा और न अग्नि। जिसे प्राप्त कर मनुष्य पुन: (संसार को) नहीं लौटते हैं, वह मेरा परम धाम है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_15_6', 'en', 'English', 'Neither sun, moon, nor fire shines there. Those who go thither never come back. For, O Arjuna, that is my Celestial Home!', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_15_7', 'hi', 'Hindi', 'इस जीव लोक में मेरा ही एक सनातन अंश जीव बना है। वह प्रकृति में स्थित हुआ (देहत्याग के समय) पाँचो इन्द्रियों तथा मन को अपनी ओर खींच लेता है अर्थात् उन्हें एकत्रित कर लेता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_15_7', 'en', 'English', 'It is only a very small part of My Eternal Self, which is the life of the universe, drawing round itself the six senses, the mind the last, which have their source in Nature.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_15_8', 'hi', 'Hindi', 'जब (देहादि का) ईश्वर (जीव) (एक शरीर से) उत्क्रमण करता है, तब इन (इन्द्रियों और मन) को ग्रहण कर अन्य शरीर में इस प्रकार ले जाता है, जैसे गन्ध के आश्रय (फूलादि) से गन्ध को वायु ले जाता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_15_8', 'en', 'English', 'When the Supreme Lord enters a body or leaves it, He gathers these senses together and travels on with them, as the wind gathers perfume while passing through the flowers.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_15_9', 'hi', 'Hindi', '(यह जीव) श्रोत्र, चक्षु, स्पर्शेन्द्रिय, रसना और घ्राण (नाक) इन इन्द्रियों तथा मन को आश्रय करके अर्थात् इनके द्वारा विषयों का सेवन करता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_15_9', 'en', 'English', 'He is the perception of the ear, the eye, the touch, the taste and the smell, yea and of the mind also; and the enjoyment the things which they perceive is also His.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_15_10', 'hi', 'Hindi', 'शरीर को त्यागते हुये, उसमें स्थित हुये अथवा (विषयों को) भोगते हुये, गुणों से समन्वित आत्मा को विमूढ़ लोग नहीं देखते हैं; (परन्तु) ज्ञानचक्षु वाले पुरुष उसे देखते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_15_10', 'en', 'English', 'The ignorant do not see that it is He Who is present in life and Who departs at death or even that it is He Who enjoys pleasure through the Qualities. Only the eye of wisdom sees.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_15_11', 'hi', 'Hindi', 'योगीजन प्रयत्न करते हुये ही अपने हृदय में स्थित आत्मा को देखते हैं, जब कि अशुद्ध अन्त:करण वाले (अकृतात्मान:) और अविवेकी (अचेतस:) लोग यत्न करते हुये भी इसे नहीं देखते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_15_11', 'en', 'English', 'The saints with great effort find Him within themselves; but not the unintelligent, who in spite of every effort cannot control their minds.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_15_12', 'hi', 'Hindi', 'जो तेज सूर्य में स्थित होकर सम्पूर्ण जगत् को प्रकाशित करता है तथा जो तेज चन्द्रमा में है और अग्नि में है, उस तेज को तुम मेरा ही जानो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_15_12', 'en', 'English', 'Remember that the Light which, proceeding from the sun, illumines the whole world, and the Light which is in the moon, and That which is in the fire also, all are born of Me.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_15_13', 'hi', 'Hindi', 'मैं ही पृथ्वी में प्रवेश करके अपने ओज से भूतमात्र को धारण करता हूँ और रसस्वरूप चन्द्रमा बनकर समस्त औषधियों का अर्थात् वनस्पतियों का पोषण करता हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_15_13', 'en', 'English', '1	enter this world and animate all My creatures with My vitality; and by My cool moonbeams I nourish the plants.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_15_14', 'hi', 'Hindi', 'मैं ही समस्त प्राणियों के देह में स्थित वैश्वानर अग्निरूप होकर प्राण और अपान से युक्त चार प्रकार के अन्न को पचाता हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_15_14', 'en', 'English', 'Becoming the fire of life, I pass into their bodies and, uniting with the vital streams of Prana and Apana, I digest the various kinds of food.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_15_15', 'hi', 'Hindi', 'मैं ही समस्त प्राणियों के हृदय में स्थित हूँ। मुझसे ही स्मृति, ज्ञान और अपोहन (उनका अभाव) होता है। समस्त वेदों के द्वारा मैं ही वेद्य (जानने योग्य) वस्तु हूँ तथा वेदान्त का और वेदों का ज्ञाता भी मैं ही हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_15_15', 'en', 'English', 'I am enthroned in the hearts of all; memory, wisdom and discrimination owe their origins to Me. I am He Who is to be realised in the scriptures; I inspire their wisdom and I know their truth.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_15_16', 'hi', 'Hindi', 'इस लोक में क्षर (नश्वर) और अक्षर (अनश्वर) ये दो पुरुष हैं, समस्त भूत क्षर हैं और ''कूटस्थ'' अक्षर कहलाता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_15_16', 'en', 'English', 'There are two aspects in Nature: the perishable and the imperishable. All life in this world belongs to the former, the unchanging element belongs to the latter.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_15_17', 'hi', 'Hindi', 'परन्तु उत्तम पुरुष अन्य ही है, जो परमात्मा कहलाता है और जो तीनों लोकों में प्रवेश करके सबका धारण करने वाला अव्यय ईश्वर है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_15_17', 'en', 'English', 'But higher than all am I, the Supreme God, the Absolute Self, the Eternal Lord, Who pervades the worlds and upholds them all.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_15_18', 'hi', 'Hindi', 'क्योंकि मैं क्षर से अतीत हूँ और अक्षर से भी उत्तम हूँ, इसलिये लोक में और वेद में भी पुरुषोत्तम के नाम से प्रसिद्ध हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_15_18', 'en', 'English', 'Beyond comparison of the Eternal with the non-eternal am I, Who am called by scriptures and sages the Supreme Personality, the Highest God.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_15_19', 'hi', 'Hindi', 'हे भारत ! इस प्रकार, जो, संमोहरहित, पुरुष मुझ पुरुषोत्तम को जानता है, वह सर्वज्ञ होकर सम्पूर्ण भाव से अर्थात् पूर्ण हृदय से मेरी भक्ति करता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_15_19', 'en', 'English', 'He who with unclouded vision sees Me as the Lord-God, knows all there is to be known, and always shall worship Me with his whole heart.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_15_20', 'hi', 'Hindi', 'हे निष्पाप भारत ! इस प्रकार यह गुह्यतम शास्त्र मेरे द्वारा कहा गया, इसको जानकर मनुष्य बुद्धिमान और कृतकृत्य हो जाता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_15_20', 'en', 'English', 'Thus, O Sinless One, I have revealed to thee this most mystic knowledge. He who understands gains wisdom and attains the consummation of life."', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_16_1', 'hi', 'Hindi', 'श्री भगवान् ने कहा -- अभय, अन्त:करण की शुद्धि, ज्ञानयोग में दृढ़ स्थिति, दान, दम, यज्ञ, स्वाध्याय, तप और आर्जव।।', FALSE, 'Swami Tejomayananda'),
  ('bg_16_1', 'en', 'English', '"Lord Shri Krishna continued: Fearlessness, clean living, unceasing concentration on wisdom, readiness to give, self-control, a spirit of sacrifice, regular study of the scriptures, austerities, candour,', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_16_2', 'hi', 'Hindi', 'अहिंसा, सत्य, क्रोध का अभाव, त्याग, शान्ति, अपैशुनम् (किसी की निन्दा न करना), भूतमात्र के प्रति दया, अलोलुपता , मार्दव (कोमलता), लज्जा, अचंचलता।।', FALSE, 'Swami Tejomayananda'),
  ('bg_16_2', 'en', 'English', 'harmlessness, truth, absence of wrath, renunciation, contentment, straightforwardness, compassion towards all, uncovetousness, courtesy, modesty, constancy,', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_16_3', 'hi', 'Hindi', 'हे भारत ! तेज, क्षमा, धैर्य, शौच (शुद्धि), अद्रोह और अतिमान (गर्व) का अभाव ये सब दैवी संपदा को प्राप्त पुरुष के लक्षण हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_16_3', 'en', 'English', 'Valour, forgiveness, fortitude, purity, freedom from hate and vanity; these are his who possesses the Godly Qualities, O Arjuna!', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_16_4', 'hi', 'Hindi', 'हे पार्थ ! दम्भ, दर्प, अभिमान, क्रोध, कठोर वाणी (पारुष्य) और अज्ञान यह सब आसुरी सम्पदा है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_16_4', 'en', 'English', 'Hypocrisy, pride, insolence, cruelty, ignorance belong to him who is born of the godless qualities.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_16_5', 'hi', 'Hindi', 'हे पाण्डव ! दैवी सम्पदा मोक्ष के लिए और आसुरी सम्पदा बन्धन के लिए मानी गयी है, तुम शोक मत करो, क्योंकि तुम दैवी सम्पदा को प्राप्त हुए हो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_16_5', 'en', 'English', 'Godly qualities lead to liberation; godless to bondage. Do not be anxious, Prince! Thou hast the Godly qualities.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_16_6', 'hi', 'Hindi', 'हे पार्थ ! इस लोक में दो प्रकार की भूतिसृष्टि है, दैवी और आसुरी। उनमें देवों का स्वभाव (दैवी सम्पदा) विस्तारपूर्वक कहा गया है; अब असुरों के स्वभाव को विस्तरश: मुझसे सुनो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_16_6', 'en', 'English', 'All beings are of two classes: Godly and godless. The Godly I have described; I will now describe the other.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_16_7', 'hi', 'Hindi', 'आसुरी स्वभाव के लोग न प्रवृत्ति को; जानते हैं और न निवृत्ति को उनमें न शुद्धि होती है, न सदाचार और न सत्य ही होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_16_7', 'en', 'English', 'The godless do not know how to act or how to renounce. They have neither purity nor truth. They do not understand the right principles of conduct.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_16_8', 'hi', 'Hindi', 'वे कहते हैं कि यह जगत् आश्रयरहित, असत्य और ईश्वर रहित है, यह (स्त्रीपुरुष के) परस्पर कामुक संबंध से ही उत्पन्न हुआ है, और (इसका कारण) क्या हो सकता है?', FALSE, 'Swami Tejomayananda'),
  ('bg_16_8', 'en', 'English', 'They say the universe is an accident with no purpose and no God. Life is created by sexual union, a product of lust and nothing else.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_16_9', 'hi', 'Hindi', 'इस दृष्टि का अवलम्बन करके नष्टस्वभाव के अल्प बुद्धि वाले, घोर कर्म करने वाले लोग जगत् के शत्रु (अहित चाहने वाले) के रूप में उसका नाश करने के लिए उत्पन्न होते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_16_9', 'en', 'English', 'Thinking thus, these degraded souls, these enemies of mankind - whose intelligence is negligible and whose deeds are monstrous - come into the world only to destroy.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_16_10', 'hi', 'Hindi', 'दम्भ, मान और मद से युक्त कभी न पूर्ण होने वाली कामनाओं का आश्रय लिये, मोहवश मिथ्या धारणाओं को ग्रहण करके ये अशुद्ध संकल्पों के लोग जगत् में कार्य करते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_16_10', 'en', 'English', 'Giving themselves up to insatiable passions, hypocritical, self-sufficient and arrogant, cherishing false conception founded on delusion, they work only to carry out their own unholy purposes.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_16_11', 'hi', 'Hindi', 'मरणपर्यन्त रहने वाली अपरिमित चिन्ताओं से ग्रस्त और विषयोपभोग को ही परम लक्ष्य मानने वाले ये आसुरी लोग इस निश्चित मत के होते हैं कि "इतना ही (सत्य, आनन्द) है"।।', FALSE, 'Swami Tejomayananda'),
  ('bg_16_11', 'en', 'English', 'Poring anxiously over evil resolutions, which only end in death; seeking only the gratification of desire as the highest goal; seeing nothing beyond;', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_16_12', 'hi', 'Hindi', 'सैकड़ों आशापाशों से बन्धे हुये, काम और क्रोध के वश में ये लोग विषयभोगों की पूर्ति के लिये अन्यायपूर्वक धन का संग्रह करने के लिये चेष्टा करते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_16_12', 'en', 'English', 'Caught in the toils of a hundred vain hopes, the slaves of passion and wrath, they accumulate hoards of unjust wealth, only to pander to their sensual desire.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_16_13', 'hi', 'Hindi', 'मैंने आज यह पाया है और इस मनोरथ को भी प्राप्त करूंगा, मेरे पास यह इतना धन है और इससे भी अधिक धन भविष्य में होगा।।', FALSE, 'Swami Tejomayananda'),
  ('bg_16_13', 'en', 'English', 'This I have gained today; tomorrow I will gratify another desire; this wealth is mine now, the rest shall be mine ere long;', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_16_14', 'hi', 'Hindi', '"यह शत्रु मेरे द्वारा मारा गया है और दूसरे शत्रुओं को भी मैं मारूंगा", "मैं ईश्वर हूँ और भोगी हूँ", "मैं सिद्ध पुरुष हूँ", "मैं बलवान और सुखी हूँ",।।', FALSE, 'Swami Tejomayananda'),
  ('bg_16_14', 'en', 'English', 'I have slain one enemy, I will slay the others also; I am worthy to enjoy, I am the Almighty, I am perfect, powerful and happy;', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_16_15', 'hi', 'Hindi', '"मैं धनवान् और श्रेष्ठकुल में जन्मा हूँ। मेरे समान दूसरा कौन है?",''मैं यज्ञ करूंगा'', ''मैं दान दूँगा'', ''मैं मौज करूँगा'' - इस प्रकार के अज्ञान से वे मोहित होते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_16_15', 'en', 'English', 'I am rich, I am well-bred; who is there to compare with me? I will sacrifice, I will give, I will pay - and I will enjoy. Thus blinded by Ignorance,', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_16_16', 'hi', 'Hindi', 'अनेक प्रकार से भ्रमित चित्त वाले, मोह जाल में फँसे तथा विषयभोगों में आसक्त ये लोग घोर, अपवित्र नरक में गिरते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_16_16', 'en', 'English', 'Perplexed by discordant thoughts, entangled in the snares of desire, infatuated by passion, they sink into the horrors of hell.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_16_17', 'hi', 'Hindi', 'अपने आप को ही श्रेष्ठ मानने वाले, स्तब्ध (गर्वयुक्त), धन और मान के मद से युक्त लोग शास्त्रविधि से रहित केवल नाममात्र के यज्ञों द्वारा दम्भपूर्वक यजन करते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_16_17', 'en', 'English', 'Self-conceited, stubborn, rich, proud and insolent, they make a display of their patronage, disregarding the rules of decency.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_16_18', 'hi', 'Hindi', 'अहंकार, बल, दर्प, काम और क्रोध के वशीभूत हुए परनिन्दा करने वाले ये लोग अपने और दूसरों के शरीर में स्थित मुझ (परमात्मा) से द्वेष करने वाले होते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_16_18', 'en', 'English', 'Puffed up by power and inordinate conceit, swayed by lust and wrath, these wicked people hate Me Who am within them, as I am within all.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_16_19', 'hi', 'Hindi', 'ऐसे उन द्वेष करने वाले,  क्रूरकर्मी और नराधमों को मैं संसार में बारम्बार (अजस्रम्) आसुरी योनियों में ही गिराता हूँ अर्थात् उत्पन्न करता हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_16_19', 'en', 'English', 'Those who thus hate Me, who are cruel, the dregs of mankind, I condemn them to a continuous, miserable and godless rebirth.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_16_20', 'hi', 'Hindi', 'हे कौन्तेय ! वे मूढ़ पुरुष जन्मजन्मान्तर में आसुरी योनि को प्राप्त होते हैं और ( इस प्रकार) मुझे प्राप्त न होकर अधम गति को प्राप्त होते है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_16_20', 'en', 'English', 'So reborn, they spend life after life, enveloped in delusion. And they never reach Me, O Prince, but degenerate into still lower forms of life.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_16_21', 'hi', 'Hindi', 'काम, क्रोध और लोभ ये आत्मनाश के त्रिविध द्वार हैं, इसलिए इन तीनों को त्याग देना चाहिए।।', FALSE, 'Swami Tejomayananda'),
  ('bg_16_21', 'en', 'English', 'The gates of hell are three: lust, wrath and avarice. They destroy the Self. Avoid them.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_16_22', 'hi', 'Hindi', 'हे कौन्तेय ! नरक के इन तीनों द्वारों से विमुक्त पुरुष अपने कल्याण के साधन का आचरण करता है और इस प्रकार परा गति को प्राप्त होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_16_22', 'en', 'English', 'These are the gates which lead to darkness; if a man avoid them he will ensure his own welfare, and in the end will attain his liberation.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_16_23', 'hi', 'Hindi', 'जो पुरुष शास्त्रविधि को त्यागकर अपनी कामना से प्रेरित होकर ही कार्य करता है, वह न पूर्णत्व की सिद्धि प्राप्त करता है, न सुख और न परा गति।।', FALSE, 'Swami Tejomayananda'),
  ('bg_16_23', 'en', 'English', 'But he who neglects the commands of the scriptures, and follows the promptings of passion, he does not attain perfection, happiness or the final goal.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_16_24', 'hi', 'Hindi', 'इसलिए तुम्हारे लिए कर्तव्य और अकर्तव्य की व्यवस्था (निर्णय) में शास्त्र ही प्रमाण है शास्त्रोक्त विधान को जानकर तुम्हें अपने कर्म करने चाहिए।।', FALSE, 'Swami Tejomayananda'),
  ('bg_16_24', 'en', 'English', 'Therefore whenever there is doubt whether thou shouldst do a thing or not, let the scriptures guide thy conduct. In the light of the scriptures shouldst thou labour the whole of thy life."', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_17_1', 'hi', 'Hindi', 'अर्जुन ने कहा -- हे कृष्ण ! जो लोग शास्त्रविधि को त्यागकर (केवल) श्रद्धा युक्त यज्ञ (पूजा) करते हैं, उनकी स्थिति (निष्ठा) कौन सी है ?क्या वह सात्त्विक है अथवा राजसिक या तामसिक ?', FALSE, 'Swami Tejomayananda'),
  ('bg_17_1', 'en', 'English', '"Arjuna asked: My Lord! Those who do acts of sacrifice, not according to the scriptures but nevertheless with implicit faith, what is their condition? Is it one of Purity, of Passion or of Ignorance?', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_17_2', 'hi', 'Hindi', 'श्री भगवान् ने कहा -- देहधारियों (मनुष्यों) की वह स्वाभाविक (ज्ञानरहित) श्रद्धा तीन प्रकार की - सात्त्विक, राजसिक और तामसिक - होती हैं, उसे तुम मुझसे सुनो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_17_2', 'en', 'English', 'Lord Shri Krishna replied: Man has an inherent faith in one or another of the Qualities -Purity, Passion and Ignorance. Now listen.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_17_3', 'hi', 'Hindi', 'हे भारत सभी मनुष्यों की श्रद्धा उनके सत्त्व (स्वभाव, संस्कार) के अनुरूप होती है। यह पुरुष श्रद्धामय है, इसलिए जो पुरुष जिस श्रद्धा वाला है वह स्वयं भी वही है अर्थात् जैसी जिसकी श्रद्धा वैसा ही उसका स्वरूप होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_17_3', 'en', 'English', 'The faith of every man conforms to his nature. By nature he is full of faith. He is in fact what his faith makes him.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_17_4', 'hi', 'Hindi', 'सात्त्विक पुरुष देवताओं को पूजते हैं और राजस लोग यक्ष और राक्षसों को, तथा अन्य तामसी जन प्रेत और भूतगणों को पूजते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_17_4', 'en', 'English', 'The Pure worship the true God; the Passionate, the powers of wealth and magic; the Ignorant, the spirits of the dead and of the lower orders of nature.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_17_5', 'hi', 'Hindi', 'जो लोग शास्त्रविधि से रहित घोर तप करते हैं तथा दम्भ, अहंकार, काम और राग से भी युक्त होते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_17_5', 'en', 'English', 'Those who practise austerities not commanded by scripture, who are slaves to hypocrisy and egotism, who are carried away by the fury of desire and passion,', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_17_6', 'hi', 'Hindi', 'और शरीरस्थ भूतसमुदाय को तथा मुझ अन्तर्यामी को भी कृश करने वाले अर्थात् कष्ट पहुँचाने वाले जो अविवेकी लोग हैं, उन्हें तुम आसुरी निश्चय वाले जानो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_17_6', 'en', 'English', 'They are ignorant. They torment the organs of the body; and they harass Me also, Who lives within. Know that they are devoted to evil.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_17_7', 'hi', 'Hindi', '(अपनीअपनी प्रकृति के अनुसार) सब का प्रिय भोजन भी तीन प्रकार का होता है? उसी प्रकार यज्ञ? तप और दान भी तीन प्रकार के होते हैं? उनके भेद को तुम मुझसे सुनो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_17_7', 'en', 'English', 'The food which men enjoy is also threefold, like the ways of sacrifice, austerity and almsgiving. Listen to the distinction.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_17_8', 'hi', 'Hindi', 'आयु, सत्त्व (शुद्धि), बल, आरोग्य, सुख और प्रीति को प्रवृद्ध करने वाले एवं रसयुक्त, स्निग्ध ( घी आदि की चिकनाई से युक्त) स्थिर तथा मन को प्रसन्न करने वाले आहार अर्थात् भोज्य पदार्थ सात्त्विक पुरुषों को प्रिय होते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_17_8', 'en', 'English', 'The foods that prolong life and increase purity, vigour, health, cheerfulness and happiness are those that are delicious, soothing, substantial and agreeable. These are loved by the Pure.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_17_9', 'hi', 'Hindi', 'कड़वे, खट्टे, लवणयुक्त, अति उष्ण, तीक्ष्ण (तीखे, मिर्च युक्त), रूखे. दाहकारक, दु:ख, शोक और रोग उत्पन्न कारक भोज्य पदार्थ राजस पुरुष को प्रिय होते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_17_9', 'en', 'English', 'Those in whom Passion is dominant like foods that are bitter, sour, salty, over-hot, pungent, dry and burning. These produce unhappiness, repentance and disease.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_17_10', 'hi', 'Hindi', 'अर्धपक्व, रसरहित, दुर्गन्धयुक्त, बासी, उच्छिष्ट तथा अपवित्र (अमेध्य) अन्न तामस जनों को प्रिय होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_17_10', 'en', 'English', 'The Ignorant love food which is stale, not nourishing, putrid and corrupt, the leavings of others and unclean.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_17_11', 'hi', 'Hindi', 'जो यज्ञ शास्त्रविधि से नियन्त्रित किया हुआ तथा जिसे "यह मेरा कर्तव्य है" ऐसा मन का समाधान (निश्चय) कर फल की आकांक्षा नहीं रखने वाले लोगों के द्वारा किया जाता है, वह यज्ञ सात्त्विक है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_17_11', 'en', 'English', 'Sacrifice is Pure when it is offered by one who does not covet the fruit thereof, when it is done according to the commands of scripture, and with implicit faith that the sacrifice is a duty.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_17_12', 'hi', 'Hindi', 'हे भरतश्रेष्ठ अर्जुन ! जो यज्ञ दम्भ के लिए तथा फल की आकांक्षा रख कर किया जाता है, उस यज्ञ को तुम राजस समझो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_17_12', 'en', 'English', 'Sacrifice which is performed for the sake of its results, or for self-glorification - that, O best of Aryans, is the product of Passion.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_17_13', 'hi', 'Hindi', 'शास्त्रविधि से रहित, अन्नदान से रहित, बिना मन्त्रों, बिना दक्षिणा और बिना श्रद्धा के किये हुए यज्ञ को तामस यज्ञ कहते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_17_13', 'en', 'English', 'Sacrifice that is contrary to scriptural command, that is unaccompanied by prayers or gifts of food or money, and is without faith - that is the product of Ignorance.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_17_14', 'hi', 'Hindi', 'देव, द्विज (ब्राह्मण), गुरु और ज्ञानी जनों का पूजन, शौच, आर्जव (सरलता), ब्रह्मचर्य और अहिंसा, यह शरीर संबंधी तप कहा जाता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_17_14', 'en', 'English', 'Worship of God and the Master; respect for the preacher and the philosopher; purity, rectitude, continence and harmlessness - all this is physical austerity.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_17_15', 'hi', 'Hindi', 'जो वाक्य (भाषण) उद्वेग उत्पन्न करने वाला नहीं है, जो प्रिय, हितकारक और सत्य है तथा वेदों का स्वाध्याय अभ्यास वाङ्मय (वाणी का) तप कहलाता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_17_15', 'en', 'English', 'Speech that hurts no one, that is true, is pleasant to listen to and beneficial, and the constant study of the scriptures - this is austerity in speech.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_17_16', 'hi', 'Hindi', 'मन की प्रसन्नता, सौम्यभाव, मौन आत्मसंयम और अन्त:करण की शुद्धि यह सब मानस तप कहलाता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_17_16', 'en', 'English', 'Serenity, kindness, silence, self-control and purity - this is austerity of mind.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_17_17', 'hi', 'Hindi', 'फल की आकांक्षा न रखने वाले युक्त पुरुषों के द्वारा परम श्रद्धा से किये गये उस पूर्वोक्त त्रिविध तप को सात्त्विक कहते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_17_17', 'en', 'English', 'These threefold austerities performed with faith, and without thought of reward, may truly be accounted Pure.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_17_18', 'hi', 'Hindi', 'जो तप सत्कार, मान और पूजा के लिए अथवा केवल दम्भ (पाखण्ड) से ही किया जाता है, वह अनिश्चित और क्षणिक तप यहाँ राजस कहा गया है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_17_18', 'en', 'English', 'Austerity coupled with hypocrisy or performed for the sake of self-glorification, popularity or vanity, comes from Passion, and its result is always doubtful and temporary.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_17_19', 'hi', 'Hindi', 'जो तप मूढ़तापूर्वक स्वयं को पीड़ित करते हुए अथवा अन्य लोगों के नाश के लिए किया जाता है, वह तप तामस कहा गया है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_17_19', 'en', 'English', 'Austerity done under delusion, and accompanied with sorcery or torture to oneself or another, may be assumed to spring from Ignorance.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_17_20', 'hi', 'Hindi', '"दान देना ही कर्तव्य है" - इस भाव से जो दान योग्य देश, काल को देखकर ऐसे (योग्य) पात्र (व्यक्ति) को दिया जाता है, जिससे प्रत्युपकार की अपेक्षा नहीं होती है, वह दान सात्त्विक माना गया है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_17_20', 'en', 'English', 'The gift which is given without thought of recompense, in the belief that it ought to be made, in a fit place, at an opportune time and to a deserving person - such a gift is Pure.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_17_21', 'hi', 'Hindi', 'और जो दान क्लेशपूर्वक तथा प्रत्युपकार के उद्देश्य से अथवा फल की कामना रखकर दिया जाता हैं, वह दान राजस माना गया है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_17_21', 'en', 'English', 'That which is given for the sake of the results it will produce, or with the hope of recompense,or grudgingly - that may truly be said to be the outcome of Passion.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_17_22', 'hi', 'Hindi', 'जो दान बिना सत्कार किये, अथवा तिरस्कारपूर्वक, अयोग्य देशकाल में, कुपात्रों के लिए दिया जाता है, वह दान तामस माना गया है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_17_22', 'en', 'English', 'And that which is given at an unsuitable place or time or to one who is unworthy, or with disrespect or contempt - such a gift is the result of Ignorance.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_17_23', 'hi', 'Hindi', '''ऊँ, तत् सत्'' ऐसा यह ब्रह्म का त्रिविध निर्देश (नाम) कहा गया है; उसी से आदिकाल में (पुरा) ब्राहम्ण, वेद और यज्ञ निर्मित हुए हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_17_23', 'en', 'English', 'Om Tat Sat'' is the triple designation of the Eternal Spirit, by which of old the Vedic Scriptures, the ceremonials and the sacrifices were ordained.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_17_24', 'hi', 'Hindi', 'इसलिए, ब्रह्मवादियों की शास्त्र प्रतिपादित यज्ञ, दान और तप की क्रियायें सदैव ओंकार के उच्चारण के साथ प्रारम्भ होती हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_17_24', 'en', 'English', 'Therefore all acts of sacrifice, gifts and austerities, prescribed by the scriptures, are always begun by those who understand the Spirit with the word Om.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_17_25', 'hi', 'Hindi', '''तत्'' शब्द का उच्चारण कर, फल की इच्छा नहीं रखते हुए, मुमुक्षुजन यज्ञ, तप, दान आदि विविध कर्म करते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_17_25', 'en', 'English', 'Those who desire deliverance begin their acts of sacrifice, austerity or gift with the word Tat'' (meaning That''), without thought of reward.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_17_26', 'hi', 'Hindi', 'हे पार्थ ! सत्य भाव व साधुभाव में ''सत्'' शब्द का प्रयोग किया जाता है, और प्रशस्त (श्रेष्ठ, शुभ) कर्म में ''सत्'' शब्द प्रयुक्त होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_17_26', 'en', 'English', 'Sat'' means Reality or the highest Good, and also, O Arjuna, it is used to mean an action of exceptional merit.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_17_27', 'hi', 'Hindi', 'यज्ञ, तप और दान में दृढ़ स्थिति भी सत् कही जाती है, और उस (परमात्मा) के लिए किया गया कर्म भी सत् ही कहलाता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_17_27', 'en', 'English', 'Conviction in sacrifice, in austerity and in giving is also called Sat.'' So too an action done only for the Lord''s sake.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_17_28', 'hi', 'Hindi', 'हे पार्थ ! जो यज्ञ, दान, तप और कर्म अश्रद्धापूर्वक किया जाता है, वह ''असत्'' कहा जाता है; वह न इस लोक में (इह) और न मरण के पश्चात् (उस लोक में) लाभदायक होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_17_28', 'en', 'English', 'Whatsoever is done without faith, whether it be sacrifice, austerity or gift or anything else, as called Asat'' (meaning Unreal'') for it is the negation of Sat,'' O Arjuna! Such an act has no significance, here or hereafter."', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_1', 'hi', 'Hindi', 'अर्जुन ने कहा -- हे महाबाहो ! हे हृषीकेश ! हे केशनिषूदन ! मैं संन्यास और त्याग के तत्त्व को पृथक्-पृथक् जानना चाहता हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_1', 'en', 'English', '"Arjuna asked: O mighty One! I desire to know how relinquishment is distinguished from renunciation.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_2', 'hi', 'Hindi', 'श्रीभगवान् ने कहा -- (कुछ) कवि (पण्डित) जन काम्य कर्मों के त्याग को "संन्यास" समझते हैं और विचारशील जन समस्त कर्मों के फलों के त्याग को "त्याग" कहते हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_2', 'en', 'English', 'Lord Shri Krishna replied: The sages say that renunciation means forgoing an action which springs from desire; and relinquishing means the surrender of its fruit.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_3', 'hi', 'Hindi', 'कुछ मनीषी जन कहते हैं कि समस्त कर्म दोषयुक्त होने के कारण त्याज्य हैं; और अन्य जन कहते हैं कि यज्ञ, दान और तपरूप कर्म त्याज्य नहीं हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_3', 'en', 'English', 'Some philosophers say that all action is evil and should be abandoned. Others that acts of sacrifice, benevolence and austerity should not be given up.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_4', 'hi', 'Hindi', 'हे भरतसत्तम ! उस त्याग के विषय में तुम मेरे निर्णय को सुनो। हे पुरुष श्रेष्ठ ! वह त्याग तीन प्रकार का कहा गया है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_4', 'en', 'English', 'O best of Indians! Listen to my judgment as regards this problem. It has a threefold aspect.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_5', 'hi', 'Hindi', 'यज्ञ, दान और तपरूप कर्म त्याज्य नहीं है, किन्तु वह नि:सन्देह कर्तव्य है; यज्ञ, दान और तप ये मनीषियों (साधकों) को पवित्र करने वाले हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_5', 'en', 'English', 'Acts of sacrifice, benevolence and austerity should not be given up but should be performed, for they purify the aspiring soul.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_6', 'hi', 'Hindi', 'हे पार्थ ! इन कर्मों को भी, फल और आसक्ति को त्यागकर करना चाहिए, यह मेरा निश्चय किया हुआ उत्तम मत है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_6', 'en', 'English', 'But they should be done with detachment and without thought of recompense. This is my final judgment.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_7', 'hi', 'Hindi', 'नियत कर्म का त्याग उचित नहीं है; मोहवश उसका त्याग करना "तामस त्याग" कहा गया है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_7', 'en', 'English', 'It is not right to give up actions which are obligatory; and if they are misunderstood, it is the result of sheer ignorance.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_8', 'hi', 'Hindi', 'जो मनुष्य, कर्म को दु:ख समझकर शारीरिक कष्ट के भय से त्याग देता है, वह पुरुष उस राजसिक त्याग को करके कदापि त्याग के फल को प्राप्त नहीं होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_8', 'en', 'English', 'To avoid an action through fear of physical suffering, because it is likely to be painful, is to act from passion, and the benefit of renunciation will not follow.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_9', 'hi', 'Hindi', 'हे अर्जुन ! "कर्म करना कर्तव्य है" ऐसा समझकर जो नियत कर्म आसक्ति और फल को त्यागकर किया जाता है, वही सात्त्विक त्याग माना गया है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_9', 'en', 'English', 'He who performs an obligatory action, because he believes it to be a duty which ought to be done, without any personal desire to do the act or to receive any return - such renunciation is Pure.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_10', 'hi', 'Hindi', 'जो पुरुष अकुशल (अशुभ) कर्म से द्वेष नहीं करता और कुशल (शुभ) कर्म में आसक्त नहीं होता, वह सत्त्वगुण से सम्पन्न पुरुष संशयरहित, मेधावी (ज्ञानी) और त्यागी है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_10', 'en', 'English', 'The wise man who has attained purity, whose doubts are solved, who is filled with the spirit of self-abnegation, does not shrink from action because it brings pain, nor does he desire it because it brings pleasure.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_11', 'hi', 'Hindi', 'क्योंकि देहधारी पुरुष के द्वारा अशेष कर्मों का त्याग संभव नहीं है, इसलिए जो कर्मफल त्यागी है, वही पुरुष त्यागी कहा जाता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_11', 'en', 'English', 'But since those still in the body cannot entirely avoid action, in their case abandonment of the fruit of action is considered as complete renunciation.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_12', 'hi', 'Hindi', 'कर्मों के शुभ, अशुभ और मिश्र ये त्रिविध फल केवल अत्यागी जनों को मरण के पश्चात् भी प्राप्त होते हैं; परन्तु संन्यासी पुरुषों को कदापि नहीं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_12', 'en', 'English', 'For those who cannot renounce all desire, the fruit of action hereafter is threefold - good, evil, and partly good and partly evil. But for him who has renounced, there is none.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_13', 'hi', 'Hindi', 'हे महाबाहो ! समस्त कर्मों की सिद्धि के लिए ये पांच कारण सांख्य सिद्धांत में कहे गये हैं, जिनको तुम मुझसे भलीभांति जानो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_13', 'en', 'English', 'I will tell thee now, O Mighty Man, the five causes which, according to the final decision of philosophy, must concur before an action can be accomplished.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_14', 'hi', 'Hindi', 'अधिष्ठान (शरीर), कर्ता ,विविध करण (इन्द्रियादि) ,विविध और पृथक्-पृथक् चेष्टाएं तथा पाँचवा हेतु दैव है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_14', 'en', 'English', 'They are a body, a personality, physical organs, their manifold activity and destiny.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_15', 'hi', 'Hindi', 'मनुष्य अपने शरीर, वाणी और मन से जो कोई न्याय्य (उचित) या विपरीत (अनुचित) कर्म करता है, उसके ये पाँच कारण ही हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_15', 'en', 'English', 'Whatever action a man performs, whether by muscular effort or by speech or by thought, and whether it be right or wrong, these five are the essential causes.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_16', 'hi', 'Hindi', 'अब इस स्थिति में जो पुरुष असंस्कृत बुद्धि होने के कारण, केवल शुद्ध आत्मा को कर्ता समझता हैं, वह दुर्मति पुरुष (यथार्थ) नहीं देखता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_16', 'en', 'English', 'But the fool who supposes, because of his immature judgment, that it is his own Self alone that acts, he perverts the truth and does not see rightly.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_17', 'hi', 'Hindi', 'जिस पुरुष में अहंकार का भाव नहीं है और बुद्धि किसी (गुण दोष) से लिप्त नहीं होती, वह पुरुष इन सब लोकों को मारकर भी वास्तव में न मरता है और न (पाप से) बँधता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_17', 'en', 'English', 'He who has no pride, and whose intellect is unalloyed by attachment, even though he kill these people, yet he does not kill them, and his act does not bind him.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_18', 'hi', 'Hindi', 'ज्ञान, ज्ञेय और परिज्ञाता ये त्रिविध कर्म प्रेरक हैं, और, करण, कर्म. कर्ता ये त्रिविध कर्म संग्रह हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_18', 'en', 'English', 'Knowledge, the knower and the object of knowledge, these are the three incentives to action; and the act, the actor and the instrument are the threefold constituents.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_19', 'hi', 'Hindi', 'ज्ञान, कर्म और कर्ता भी गुणों के भेद से सांख्यशास्त्र (गुणसंख्याने) में त्रिविध ही कहे गये हैं; उनको भी तुम मुझ से यथावत् श्रवण करो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_19', 'en', 'English', 'The knowledge, the act and the doer differ according to the Qualities. Listen to this too:', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_20', 'hi', 'Hindi', 'जिस ज्ञान से मनुष्य, विभक्त रूप में स्थित समस्त भूतों में एक अविभक्त और अविनाशी (अव्यय) स्वरूप को देखता है, उस ज्ञान को तुम सात्त्विक जानो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_20', 'en', 'English', 'That knowledge which sees the One Indestructible in all beings, the One Indivisible in all separate lives, may be truly called Pure Knowledge.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_21', 'hi', 'Hindi', 'जिस ज्ञान के द्वारा मनुष्य समस्त भूतों में नाना भावों को पृथक्-पृथक् जानता है, उस ज्ञान को तुम राजस जानो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_21', 'en', 'English', 'The knowledge which thinks of the manifold existence in all beings as separate - that comes from Passion.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_22', 'hi', 'Hindi', 'और जिस ज्ञान के द्वारा मनुष्य एक कार्य (शरीर) में ही आसक्त हो जाता है, मानो वह (कार्य ही) पूर्ण वस्तु हो तथा जो (ज्ञान) हेतुरहित (अयुक्तिक), तत्त्वार्थ से रहित तथा संकुचित (अल्प) है, वह (ज्ञान) तामस है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_22', 'en', 'English', 'But that which clings blindly to one idea as if it were all, without logic, truth or insight, that has its origin in Darkness.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_23', 'hi', 'Hindi', 'जो कर्म (शास्त्रविधि से) नियत और संगरहित है, तथा फल को न चाहने वाले पुरुष के द्वारा बिना किसी राग द्वेष के किया गया है, वह (कर्म) सात्त्विक कहा जाता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_23', 'en', 'English', 'An obligatory action done by one who is disinterested, who neither likes nor dislikes it, and gives no thought to the consequences that follow, such an action is Pure.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_24', 'hi', 'Hindi', 'और जो कर्म बहुत परिश्रम से युक्त है तथा फल की कामना वाले, अहंकारयुक्त पुरुष के द्वारा किया जाता है, वह कर्म राजस कहा गया है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_24', 'en', 'English', 'But even though an action involve the most strenuous endeavour, yet if the doer is seeking to gratify his desires, and is filled with personal vanity, it may be assumed to originate in Passion.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_25', 'hi', 'Hindi', 'जो कर्म परिणाम, हानि, हिंसा और सार्मथ्य (पौरुषम्) का विचार न करके केवल मोहवश आरम्भ किया जाता है, वह कर्म तामस कहलाता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_25', 'en', 'English', 'An action undertaken through delusion, and with no regard to the spiritual issues involved, or the real capacity of the doer, or to the injury which may follow, such an act may be assumed to be the product of Ignorance.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_26', 'hi', 'Hindi', 'जो कर्ता संगरहित, अहंमन्यता से रहित, धैर्य और उत्साह से युक्त एवं कार्य की सिद्धि (सफलता) और असिद्धि (विफलता) में निर्विकार रहता है, वह कर्ता सात्त्विक कहा जाता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_26', 'en', 'English', 'But when a man has no sentiment and no personal vanity, when he possesses courage and confidence, cares not whether he succeeds or fails, then his action arises from Purity.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_27', 'hi', 'Hindi', 'रागी, कर्मफल का इच्छुक, लोभी, हिंसक स्वभाव वाला, अशुद्ध और हर्षशोक से युक्त कर्ता राजस कहलाता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_27', 'en', 'English', 'In him who is impulsive, greedy, looking for reward, violent, impure, torn between joy and sorrow,it may be assumed that in him Passion is predominant.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_28', 'hi', 'Hindi', 'अयुक्त, प्राकृत, स्तब्ध, शठ, नैष्कृतिक, आलसी, विषादी और दीर्घसूत्री कर्ता तामस कहा जाता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_28', 'en', 'English', 'While he whose purpose is infirm, who is low-minded, stubborn, dishonest, malicious, indolent, despondent, procrastinating - he may be assumed to be in Darkness.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_29', 'hi', 'Hindi', 'हे धनंजय ! मेरे द्वारा अशेषत: और पृथकत: कहे जाने वाले, गुणों के कारण उत्पन्न हुए बुद्धि और धृति के त्रिविध भेद को सुनो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_29', 'en', 'English', 'Reason and conviction are threefold, according to the Quality which is dominant. I will explain them fully and severally, O Arjuna!', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_30', 'hi', 'Hindi', 'हे पार्थ ! जो बुद्धि प्रवृत्ति और निवृत्ति, कार्य और अकार्य, भय और अभय तथा बन्ध और मोक्ष को तत्त्वत जानती है, वह बुद्धि सात्विकी है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_30', 'en', 'English', 'That intellect which understands the creation and dissolution of life, what actions should be done and what not, which discriminates between fear and fearlessness, bondage and deliverance, that is Pure.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_31', 'hi', 'Hindi', 'हे पार्थ ! जिस बुद्धि के द्वारा मनुष्य धर्म और अधर्म को तथा कर्तव्य और अकर्तव्य को यथावत् नहीं जानता है, वह बुद्धि राजसी है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_31', 'en', 'English', 'The intellect which does not understand what is right and what is wrong, and what should be done and what not, is under the sway of Passion.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_32', 'hi', 'Hindi', 'हे पार्थ ! तमस् (अज्ञान अन्ध:कार) से आवृत जो बुद्धि अधर्म को ही धर्म मानती है और सभी पदार्थों को विपरीत रूप से जानती है, वह बुद्धि तामसी है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_32', 'en', 'English', 'And that which, shrouded in Ignorance, thinks wrong right, and sees everything perversely, O Arjuna, that intellect is ruled by Darkness.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_33', 'hi', 'Hindi', 'सात्त्विकी है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_33', 'en', 'English', 'The conviction and steady concentration by which the mind, the vitality and the senses are controlled - O Arjuna! They are the product of Purity.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_34', 'hi', 'Hindi', 'हे पृथापुत्र अर्जुन ! कर्मफल का इच्छुक पुरुष अति आसक्ति (प्रसंग) से जिस धृति के द्वारा धर्म, अर्थ और काम (इन तीन पुरुषार्थों) को धारण करता है, वह धृति राजसी है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_34', 'en', 'English', 'The conviction which always holds fast to rituals, to self-interest and wealth, for the sake of what they may bring forth - that comes from Passion.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_35', 'hi', 'Hindi', 'हो पार्थ ! दुर्बुद्धि पुरुष जिस धारणा के द्वारा, स्वप्न, भय, शोक, विषाद और मद को नहीं त्यागता है, वह धृति तामसी है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_35', 'en', 'English', 'And that which clings perversely to false idealism, fear, grief, despair and vanity is the product of Ignorance.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_36', 'hi', 'Hindi', 'हे भरतश्रेष्ठ ! अब तुम त्रिविध सुख को मुझसे सुनो, जिसमें (साधक पुरुष) अभ्यास से रमता है और दु:खों के अन्त को प्राप्त होता है (जहाँ उसके दु:खों का अन्त हो जाता है।)।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_36', 'en', 'English', 'Hear further the three kinds of pleasure. That which increases day after day delivers one from misery,', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_37', 'hi', 'Hindi', 'जो सुख प्रथम (प्रारम्भ में) विष के समान (भासता) है, परन्तु परिणाम में अमृत के समान है, वह आत्मबुद्धि के प्रसाद से उत्पन्न सुख सात्त्विक कहा गया है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_37', 'en', 'English', 'Which at first seems like poison but afterwards acts like nectar - that pleasure is Pure, for it is born of Wisdom.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_38', 'hi', 'Hindi', 'जो सुख विषयों और इन्द्रियों के संयोग से उत्पन्न होता है, वह प्रथम तो अमृत के समान, परन्तु परिणाम में विष तुल्य होता है, वह सुख राजस कहा गया है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_38', 'en', 'English', 'That which as first is like nectar, because the senses revel in their objects, but in the end acts like poison - that pleasure arises from Passion.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_39', 'hi', 'Hindi', 'जो सुख प्रारम्भ में और परिणाम (अनुबन्ध) में भी आत्मा (मनुष्य) को मोहित करने वाला होता है, वह निद्रा, आलस्य और प्रमाद से उत्पन्न सुख तामस कहा जाता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_39', 'en', 'English', 'While the pleasure which from first to last merely drugs the senses, which springs from indolence, lethargy and folly - that pleasure flows from Ignorance.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_40', 'hi', 'Hindi', 'पृथ्वी पर अथवा स्वर्ग के देवताओं में ऐसा कोई प्राणी (सत्त्वं अर्थात् विद्यमान वस्तु) नहीं है जो प्रकृति से उत्पन्न इन तीन गुणों से मुक्त (रहित) हो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_40', 'en', 'English', 'There is nothing anywhere on earth or in the higher worlds which is free from the three Qualities - for they are born of Nature.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_41', 'hi', 'Hindi', 'हे परन्तप!  ब्राह्मणों, क्षत्रियों, वैश्यों और शूद्रों के कर्म, स्वभाव से उत्पन्न गुणों के अनुसार विभक्त किये गये हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_41', 'en', 'English', 'O Arjuna! The duties of spiritual teachers, the soldiers, the traders and the servants have all been fixed according to the dominant Quality in their nature.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_42', 'hi', 'Hindi', 'शम, दम, तप, शौच, क्षान्ति, आर्जव, ज्ञान, विज्ञान और आस्तिक्य - ये ब्राह्मण के स्वाभाविक कर्म हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_42', 'en', 'English', 'Serenity, self-restraint, austerity, purity, forgiveness, as well as uprightness, knowledge, wisdom and faith in God - these constitute the duty of a spiritual Teacher.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_43', 'hi', 'Hindi', 'शौर्य, तेज, धृति, दाक्ष्य (दक्षता), युद्ध से पलायन न करना, दान और ईश्वर भाव (स्वामी भाव) - ये सब क्षत्रिय के स्वाभाविक कर्म हैं।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_43', 'en', 'English', 'Valour, glory, firmness, skill, generosity, steadiness in battle and ability to rule - these constitute the duty of a soldier. They flow from his own nature.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_44', 'hi', 'Hindi', 'कृषि, गौपालन तथा वाणिज्य - ये वैश्य के स्वाभाविक कर्म हैं, और शूद्र का स्वाभाविक कर्म है परिचर्या अर्थात् सेवा करना।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_44', 'en', 'English', 'Agriculture, protection of the cow and trade are the duty of a trader, again in accordance with his nature. The duty of a servant is to serve, and that too agrees with his nature.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_45', 'hi', 'Hindi', 'जो पुरुष सब कर्म ब्रह्म में अर्पण करके और आसक्ति को त्यागकर करता है,  वह पुरुष कमल के पत्ते के सदृश पाप से लिप्त नहीं होता।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_45', 'en', 'English', 'He who dedicates his actions to the Spirit, without any personal attachment to them, he is no more tainted by sin than the water lily is wetted by water.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_46', 'hi', 'Hindi', 'जिस (परमात्मा) से भूतमात्र की प्रवृत्ति अर्थात् उत्पत्ति हुई है और जिससे यह सम्पूर्ण जगत् व्याप्त है, उस (परमात्मा) की स्वकर्म द्वारा पूजा करके मनुष्य सिद्धि को प्राप्त होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_46', 'en', 'English', 'Man reaches perfection by dedicating his actions to God, Who is the source of all being, and fills everything.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_47', 'hi', 'Hindi', 'सम्यक् अनुष्ठित परधर्म की अपेक्षा गुणरहित स्वधर्म श्रेष्ठ है। (क्योंकि) स्वभाव से नियत किये गये कर्म को करते हुए मनुष्य पाप को नहीं प्राप्त करता।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_47', 'en', 'English', 'It is better to do one''s own duty, however defective it may be, than to follow the duty of another, however well one may perform it. He who does his duty as his own nature reveals it, never sins.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_48', 'hi', 'Hindi', 'हे कौन्तेय ! दोषयुक्त होने पर भी सहज कर्म को नहीं त्यागना चाहिए; क्योंकि सभी कर्म दोष से आवृत होते है, जैसे धुयें से अग्नि।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_48', 'en', 'English', 'The duty that of itself falls to one''s lot should not be abandoned, though it may have its defects. All acts are marred by defects, as fire is obscured by smoke.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_49', 'hi', 'Hindi', 'सर्वत्र आसक्ति रहित बुद्धि वाला वह पुरुष जो स्पृहारहित तथा जितात्मा है, संन्यास के द्वारा परम नैर्ष्कम्य सिद्धि को प्राप्त होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_49', 'en', 'English', 'He whose mind is entirely detached, who has conquered himself, whose desires have vanished, by his renunciation reaches that stage of perfect freedom where action completes itself and leaves no seed.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_50', 'hi', 'Hindi', 'सिद्धि को प्राप्त पुरुष किस प्रकार ब्रह्म को प्राप्त होता है, तथा ज्ञान की परा निष्ठा को भी तुम मुझसे संक्षेप में जानो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_50', 'en', 'English', 'I will now state briefly how he, who has reached perfection, finds the Eternal Spirit, the state of Supreme Wisdom.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_51', 'hi', 'Hindi', 'विशुद्ध बुद्धि से युक्त, धृति से आत्मसंयम कर, शब्दादि विषयों को त्याग कर और राग-द्वेष का परित्याग कर....৷৷৷৷।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_51', 'en', 'English', 'Guided always by pure reason, bravely restraining himself, renouncing the objects of sense and giving up attachment and hatred;', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_52', 'hi', 'Hindi', 'विविक्त सेवी, लघ्वाशी (मिताहारी) जिसने अपने शरीर, वाणी और मन को संयत किया है, ध्यानयोग के अभ्यास में सदैव तत्पर तथा वैराग्य पर समाश्रित।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_52', 'en', 'English', 'Enjoying solitude, abstemiousness, his body, mind and speech under perfect control, absorbed in meditation, he becomes free - always filled with the spirit of renunciation.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_53', 'hi', 'Hindi', 'अहंकार, बल, दर्प, काम, क्रोध और परिग्रह को त्याग कर ममत्वभाव से रहित और शान्त पुरुष ब्रह्म प्राप्ति के योग्य बन जाता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_53', 'en', 'English', 'Having abandoned selfishness, power, arrogance, anger and desire, possessing nothing of his own and having attained peace, he is fit to join the Eternal Spirit.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_54', 'hi', 'Hindi', 'ब्रह्मभूत (जो साधक ब्रह्म बन गया है), प्रसन्न मन वाला पुरुष न इच्छा करता है और न शोक, समस्त भूतों के प्रति सम होकर वह मेरी परा भक्ति को प्राप्त करता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_54', 'en', 'English', 'And when he becomes one with the Eternal, and his soul knows the bliss that belongs to the Self, he feels no desire and no regret, he regards all beings equally and enjoys the blessing of supreme devotion to Me.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_55', 'hi', 'Hindi', '(उस परा) भक्ति के द्वारा मुझे वह तत्त्वत: जानता है कि मैं कितना (व्यापक) हूँ तथा मैं क्या हूँ। (इस प्रकार) तत्त्वत: जानने के पश्चात् तत्काल ही वह मुझमें प्रवेश कर जाता है, अर्थात् मत्स्वरूप बन जाता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_55', 'en', 'English', 'By such devotion, he sees Me, who I am and what I am; and thus realising the Truth, he enters My Kingdom.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_56', 'hi', 'Hindi', 'जो पुरुष मदाश्रित होकर सदैव समस्त कर्मों को करता है, वह मेरे प्रसाद (अनुग्रह) से शाश्वत, अव्यय पद को प्राप्त कर लेता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_56', 'en', 'English', 'Relying on Me in all his action and doing them for My sake, he attains, by My Grace, Eternal and Unchangeable Life.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_57', 'hi', 'Hindi', 'मन से समस्त कर्मों का संन्यास मुझमें करके मत्परायण होकर बुद्धियोग का आश्रय लेकर तुम सतत मच्चित्त बनो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_57', 'en', 'English', 'Surrender then thy actions unto Me, live in Me, concentrate thine intellect on Me, and think always of Me.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_58', 'hi', 'Hindi', 'मच्चित्त होकर तुम मेरी कृपा से समस्त कठिनाइयों (सर्वदुर्गाणि) को पार कर जाओगे; और यदि अहंकारवश (इस उपदेश को) नहीं सुनोगे, तो तुम नष्ट हो जाओगे।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_58', 'en', 'English', 'Fix but thy mind on Me, and by My grace thou shalt overcome the obstacles in thy path. But if, misled by pride, thou wilt not listen, then indeed thou shalt be lost.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_59', 'hi', 'Hindi', 'और अहंकारवश तुम जो यह सोच रहे हो, "मैं युद्ध नहीं करूंगा", यह तुम्हारा निश्चय मिथ्या है, (क्योंकि) प्रकृति (तुम्हारा स्वभाव) ही तुम्हें (बलात् कर्म में) प्रवृत्त करेगी।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_59', 'en', 'English', 'If thou in thy vanity thinkest of avoiding this fight, thy will shall not be fulfilled, for Nature herself will compel thee.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_60', 'hi', 'Hindi', 'हे कौन्तेय ! तुम अपने स्वाभाविक कर्मों से बंधे हो, (अत:) मोहवशात् जिस कर्म को तुम करना नहीं चाहते हो, वही तुम विवश होकर करोगे।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_60', 'en', 'English', 'O Arjuna! Thy duty binds thee. From thine own nature has it arisen, and that which in thy delusion thou desire not to do, that very thing thou shalt do. Thou art helpless.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_61', 'hi', 'Hindi', 'हे अर्जुन (मानों किसी) यन्त्र पर आरूढ़ समस्त भूतों को ईश्वर अपनी माया से घुमाता हुआ (भ्रामयन्) भूतमात्र के हृदय में स्थित रहता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_61', 'en', 'English', 'God dwells in the hearts of all beings, O Arjuna! He causes them to revolve as it were on a wheel by His mystic power.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_62', 'hi', 'Hindi', 'हे भारत ! तुम सम्पूर्ण भाव से उसी (ईश्वर) की शरण में जाओ। उसके प्रसाद से तुम परम शान्ति और शाश्वत स्थान को प्राप्त करोगे।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_62', 'en', 'English', 'With all thy strength, fly unto Him and surrender thyself, and by His grace shalt thou attain Supreme Peace and reach the Eternal Home.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_63', 'hi', 'Hindi', 'इस प्रकार समस्त गोपनीयों से अधिक गुह्य ज्ञान मैंने तुमसे कहा; इस पर पूर्ण विचार (विमृश्य) करने के पश्चात् तुम्हारी जैसी इच्छा हो, वैसा तुम करो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_63', 'en', 'English', 'Thus have I revealed to thee the Truth, the Mystery of mysteries. Having thought it over, thou art free to act as thou wilt.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_64', 'hi', 'Hindi', 'पुन: एक बार तुम मुझसे समस्त गुह्यों में गुह्यतम परम वचन (उपदेश) को सुनो। तुम मुझे अतिशय प्रिय हो, इसलिए मैं तुम्हें तुम्हारे हित की बात कहूंगा।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_64', 'en', 'English', 'Only listen once more to My last word, the deepest secret of all; thou art My beloved, thou are My friend, and I speak for thy welfare.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_65', 'hi', 'Hindi', 'तुम मच्चित, मद्भक्त और मेरे पूजक (मद्याजी) बनो और मुझे नमस्कार करो; (इस प्रकार) तुम मुझे ही प्राप्त होगे; यह मैं तुम्हे सत्य वचन देता हूँ,(क्योंकि) तुम मेरे प्रिय हो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_65', 'en', 'English', 'Dedicate thyself to Me, worship Me, sacrifice all for Me, prostrate thyself before Me, and to Me thou shalt surely come. Truly do I pledge thee; thou art My own beloved.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_66', 'hi', 'Hindi', 'सब धर्मों का परित्याग करके तुम एक मेरी ही शरण में आओ, मैं तुम्हें समस्त पापों से मुक्त कर दूँगा, तुम शोक मत करो।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_66', 'en', 'English', 'Give up then thy earthly duties, surrender thyself to Me only. Do not be anxious; I will absolve thee from all thy sin.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_67', 'hi', 'Hindi', 'यह ज्ञान ऐसे पुरुष से नहीं कहना चाहिए, जो अतपस्क (तपरहित) है, और न उसे जो अभक्त है; उसे भी नहीं जो अशुश्रुषु (सेवा में अतत्पर) है और उस पुरुष से भी नहीं कहना चाहिए, जो मुझ (ईश्वर) से असूया करता है, अर्थात् मुझ में दोष देखता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_67', 'en', 'English', 'Speak not this to one who has not practised austerities, or to him who does not love, or who will not listen, or who mocks.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_68', 'hi', 'Hindi', 'जो पुरुष मुझसे परम प्रेम (परा भक्ति) करके इस परम गुह्य ज्ञान का उपदेश मेरे भक्तों को देता है, वह नि:सन्देह मुझे ही प्राप्त होता है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_68', 'en', 'English', 'But he who teaches this great secret to My devotees, his is the highest devotion, and verily he shall come unto Me.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_69', 'hi', 'Hindi', 'न तो उससे बढ़कर मेरा अतिशय प्रिय कार्य करने वाला मनुष्यों में कोई है और न उससे बढ़कर मेरा प्रिय इस पृथ्वी पर दूसरा कोई होगा।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_69', 'en', 'English', 'Nor is there among men any who can perform a service dearer to Me than this, or any man on earth more beloved by Me than he.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_70', 'hi', 'Hindi', 'जो पुरुष, हम दोनों के इस धर्ममय संवाद का पठन करेगा, उसके द्वारा मैं ज्ञानयज्ञ से पूजित होऊँगा - ऐसा मेरा मत है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_70', 'en', 'English', 'He who will study this spiritual discourse of ours, I assure thee, he shall thereby worship Me at the altar of Wisdom.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_71', 'hi', 'Hindi', 'तथा जो श्रद्धावान् और अनसुयु (दोषदृष्टि रहित) पुरुष इसका श्रवणमात्र भी करेगा, वह भी (पापों से) मुक्त होकर पुण्यकर्मियों के शुभ (श्रेष्ठ) लोकों को प्राप्त कर लेगा।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_71', 'en', 'English', 'Yea, he who listens to it with faith and without doubt, even he, freed from evil, shalt rise to the worlds which the virtuous attain through righteous deeds.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_72', 'hi', 'Hindi', 'हे पार्थ ! क्या इसे (मेरे उपदेश को) तुमने एकाग्रचित्त होकर श्रवण किया ? और हे धनञ्जय ! क्या तुम्हारा अज्ञान जनित संमोह पूर्णतया नष्ट हुआ ?', FALSE, 'Swami Tejomayananda'),
  ('bg_18_72', 'en', 'English', 'O Arjuna! Hast thou listened attentively to My words? Has thy ignorance and thy delusion gone?', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_73', 'hi', 'Hindi', 'अर्जुन ने कहा -- हे अच्युत ! आपके कृपाप्रसाद से मेरा मोह नष्ट हो गया है, और मुझे स्मृति (ज्ञान) प्राप्त हो गयी है? अब मैं संशयरहित हो गया हूँ और मैं आपके वचन (आज्ञा) का पालन करूँगा।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_73', 'en', 'English', 'Arjuna replied: My Lord! O Immutable One! My delusion has fled. By Thy Grace, O Changeless One, the light has dawned. My doubts are gone, and I stand before Thee ready to do Thy will."', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_74', 'hi', 'Hindi', 'संजय ने कहा -- इस प्रकार मैंने भगवान् वासुदेव और महात्मा अर्जुन के इस अद्भुत और रोमान्चक संवाद का वर्णन किया।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_74', 'en', 'English', 'Sanjaya told: "Thus have I heard this rare, wonderful and soul-stirring discourse of the Lord Shri Krishna and the great-souled Arjuna.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_75', 'hi', 'Hindi', 'व्यास जी की कृपा से मैंने इस परम् गुह्य योग को साक्षात् कहते हुए स्वयं योगोश्वर श्रीकृष्ण भगवान् से सुना।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_75', 'en', 'English', 'Through the blessing of the sage Vyasa, I listened to this secret and noble science from the lips of its Master, the Lord Shri Krishna.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_76', 'hi', 'Hindi', 'हे राजन् ! भगवान् केशव और अर्जुन के इस अद्भुत और पुण्य (पवित्र) संवाद को स्मरण करके मैं बारम्बार हर्षित होता हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_76', 'en', 'English', 'O King! The more I think of that marvellous and holy discourse, the more I lose myself in joy.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_77', 'hi', 'Hindi', 'हे राजन ! श्री हरि के अति अद्भुत रूप को भी पुन: पुन: स्मरण करके मुझे महान् विस्मय होता है और मैं बारम्बार हर्षित हो रहा हूँ।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_77', 'en', 'English', 'As memory recalls again and again the exceeding beauty of the Lord, I am filled with amazement and happiness.', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;

INSERT INTO verse_translations (verse_id, language_code, language_name, text, is_primary, translation_source) VALUES
  ('bg_18_78', 'hi', 'Hindi', 'जहाँ योगेश्वर श्रीकृष्ण हैं और जहाँ धनुर्धारी अर्जुन है वहीं पर श्री, विजय, विभूति और ध्रुव नीति है, ऐसा मेरा मत है।।', FALSE, 'Swami Tejomayananda'),
  ('bg_18_78', 'en', 'English', 'Wherever is the Lord Shri Krishna, the Prince of Wisdom, and wherever is Arjuna, the Great Archer, I am more than convinced that good fortune, victory, happiness and righteousness will follow"', TRUE, 'Swami Tejomayananda')
ON CONFLICT (verse_id, language_code) DO UPDATE SET text = EXCLUDED.text, translation_source = EXCLUDED.translation_source;
