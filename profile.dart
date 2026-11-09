class Profile {
  const Profile({
    required this.id,
    required this.fullName,
    this.email,
    this.grade,
    this.preferredLanguage = 'english',
    this.subjects = const [],
    this.plan = 'free',
  });

  final String id;
  final String fullName;
  final String? email;
  final String? grade;
  final String preferredLanguage; // english | urdu | roman_urdu
  final List<String> subjects;
  final String plan;

  factory Profile.fromJson(Map<String, dynamic> j, {String? email}) => Profile(
        id: j['id'] as String,
        fullName: (j['full_name'] as String?) ?? '',
        email: email,
        grade: j['grade'] as String?,
        preferredLanguage: (j['preferred_language'] as String?) ?? 'english',
        subjects: ((j['subjects'] as List?) ?? const []).cast<String>(),
        plan: (j['plan'] as String?) ?? 'free',
      );

  String get firstName {
    final t = fullName.trim();
    return t.isEmpty ? '' : t.split(RegExp(r'\s+')).first;
  }

  String get initials {
    final parts =
        fullName.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty);
    if (parts.isEmpty) return 'S';
    return parts.take(2).map((s) => s[0].toUpperCase()).join();
  }
}

const gradeOptions = <String>[
  'Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5', 'Class 6',
  'Class 7', 'Class 8', 'Class 9', 'Class 10', 'Class 11', 'Class 12',
  'O Levels', 'A Levels', 'College / University', 'Other',
];

const subjectOptions = <String>[
  'Mathematics', 'Physics', 'Chemistry', 'Biology', 'Computer Science',
  'English', 'Urdu', 'General Knowledge', 'History', 'Geography',
  'Islamic Studies', 'Other',
];

const answerLanguageOptions = <String, String>{
  'english': 'English',
  'urdu': 'اردو (Urdu)',
  'roman_urdu': 'Roman Urdu',
};
