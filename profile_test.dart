import 'package:flutter_test/flutter_test.dart';
import 'package:student_buddy/core/services/profile.dart';

void main() {
  test('Profile.fromJson parses a Supabase row', () {
    final p = Profile.fromJson({
      'id': 'abc',
      'full_name': 'Ayesha Khan',
      'grade': 'Class 10',
      'preferred_language': 'urdu',
      'subjects': ['Physics', 'Urdu'],
      'plan': 'free',
    }, email: 'a@example.com');

    expect(p.firstName, 'Ayesha');
    expect(p.initials, 'AK');
    expect(p.subjects, ['Physics', 'Urdu']);
    expect(p.preferredLanguage, 'urdu');
  });

  test('Profile handles missing optional fields', () {
    final p = Profile.fromJson({'id': 'x'});
    expect(p.fullName, '');
    expect(p.initials, 'S');
    expect(p.subjects, isEmpty);
    expect(p.preferredLanguage, 'english');
  });
}
