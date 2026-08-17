import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLanguage {
  english('en', 'English'),
  marathi('mr', 'मराठी'),
  hindi('hi', 'हिंदी');

  final String code;
  final String label;
  const AppLanguage(this.code, this.label);
}

class AppLanguageNotifier extends StateNotifier<AppLanguage> {
  AppLanguageNotifier() : super(AppLanguage.english);

  void setLanguage(AppLanguage lang) {
    state = lang;
  }
}

final appLanguageProvider = StateNotifierProvider<AppLanguageNotifier, AppLanguage>((ref) {
  return AppLanguageNotifier();
});

class AppStrings {
  static String tr(String key, AppLanguage lang) {
    final map = _dict[key];
    if (map != null && map.containsKey(lang.code)) {
      return map[lang.code]!;
    }
    return map?['en'] ?? key;
  }

  static const Map<String, Map<String, String>> _dict = {
    'appName': {
      'en': 'NagarDrishti',
      'mr': 'नगरदृष्टी',
      'hi': 'नगरदृष्टि',
    },
    'tagline': {
      'en': 'Vikasit Nagpur Civic AI Platform',
      'mr': 'विकसित नागपूर नागरी एआय प्लॅटफॉर्म',
      'hi': 'विकसित नागपुर नागरिक एआई प्लेटफॉर्म',
    },
    'newReport': {
      'en': 'New AI Report',
      'mr': 'नवीन तक्रार नोंदी',
      'hi': 'नया एआई रिपोर्ट',
    },
    'emergencySos': {
      'en': '🚨 Emergency SOS Hazard',
      'mr': '🚨 आपत्कालीन एसओएस धोका',
      'hi': '🚨 आपातकालीन एसओएस खतरा',
    },
    'publicFeed': {
      'en': 'Public Feed',
      'mr': 'सार्वजनिक फीड',
      'hi': 'पब्लिक फीड',
    },
    'activeWork': {
      'en': 'Active Works',
      'mr': 'सुरू असलेली कामे',
      'hi': 'सक्रिय कार्य',
    },
    'leaderboard': {
      'en': 'Civic Karma Leaderboard',
      'mr': 'नागरी कर्मा लीडरबोर्ड',
      'hi': 'नागरिक कर्म लीडरबोर्ड',
    },
    'adminPortal': {
      'en': 'NMC Officer Portal',
      'mr': 'एनएमसी अधिकारी पोर्टल',
      'hi': 'एनएमसी अधिकारी पोर्टल',
    },
    'zonalOfficer': {
      'en': 'Zonal Officer / CSO',
      'mr': 'विभागीय अधिकारी / सीएसओ',
      'hi': 'ज़ोनल अधिकारी / सीएसओ',
    },
    'callOfficer': {
      'en': 'Call Zonal Officer',
      'mr': 'विभागीय अधिकाऱ्याला कॉल करा',
      'hi': 'ज़ोनल अधिकारी को कॉल करें',
    },
    'helpline': {
      'en': 'NMC Citizen Helpline',
      'mr': 'एनएमसी नागरिक हेल्पलाइन',
      'hi': 'एनएमसी नागरिक हेल्पलाइन',
    },
    'responsibleOfficer': {
      'en': 'Responsible Officer',
      'mr': 'जबाबदार अधिकारी',
      'hi': 'जिम्मेदार अधिकारी',
    },
    'needFasterAction': {
      'en': 'Need Faster Action?',
      'mr': 'जलद कारवाई हवी आहे?',
      'hi': 'त्वरित कार्रवाई चाहिए?',
    },
    'criticalIssue': {
      'en': 'Critical Public Hazard',
      'mr': 'गंभीर सार्वजनिक धोका',
      'hi': 'गंभीर सार्वजनिक खतरा',
    },
    'redAlert': {
      'en': 'Red Alert Cluster',
      'mr': 'रेड अलर्ट क्लस्टर',
      'hi': 'रेड अलर्ट क्लस्टर',
    },
    'yourZone': {
      'en': 'My NMC Zone',
      'mr': 'माझा एनएमसी झोन',
      'hi': 'मेरा एनएमसी ज़ोन',
    },
  };
}
