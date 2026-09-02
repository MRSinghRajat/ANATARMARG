import 'package:flutter/material.dart';

import 'app_intro_chapter.dart';

/// Ordered chapters shown after profile summary, before sign-in.
const List<AppIntroChapter> kAppIntroChapters = [
  AppIntroChapter(
    titleEn: 'Your Aangan — your calm home',
    titleHi: 'आपका आँगन — आपका शांत घर',
    bodyEn:
        'This is where you rest and return each day. You can open the Mandir and gently decorate your space as you grow.',
    bodyHi:
        'यहाँ आप रोज़ लौटकर आराम कर सकते हैं। मंदिर खोलकर अपनी जगह को धीरे-धीरे सजा सकते हैं।',
    icon: Icons.home_rounded,
  ),
  AppIntroChapter(
    titleEn: 'Ashram — small steps, steady blessings',
    titleHi: 'आश्रम — छोटे कदम, निरंतर आशीर्वाद',
    bodyEn:
        'Simple daily tasks help you stay close to practice. When you finish, you earn karma coins — you will see them collect, ready to use in your home.',
    bodyHi:
        'रोज़ के छोटे कार्य आपको अभ्यास से जोड़े रखते हैं। पूरा करने पर कर्म सिक्के मिलते हैं — वे इकट्ठे होते दिखेंगे, घर में इस्तेमाल के लिए।',
    icon: Icons.temple_buddhist,
  ),
  AppIntroChapter(
    titleEn: 'Granthalaya — read and journey',
    titleHi: 'ग्रंथालय — पढ़ें और यात्रा करें',
    bodyEn:
        'Sacred texts, stories, and life-stage journeys live here. Listening is coming soon.',
    bodyHi:
        'पवित्र ग्रंथ, कथाएँ और जीवन-यात्राएँ यहाँ हैं। श्रवण शीघ्र आ रहा है।',
    icon: Icons.menu_book_rounded,
  ),
  AppIntroChapter(
    titleEn: 'Longer journeys',
    titleHi: 'लंबी यात्राएँ',
    bodyEn:
        'When you are ready, structured journeys help you go deeper. You will find them from Granthalaya and the Ashram.',
    bodyHi:
        'जब तैयार हों, संरचित यात्राएँ गहराई में ले जाती हैं। इन्हें ग्रंथालय और आश्रम से खोल सकते हैं।',
    icon: Icons.route_rounded,
  ),
];
