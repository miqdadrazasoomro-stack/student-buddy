import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/settings_controller.dart';

/// Interface strings. Order of each list: [English, Urdu, Roman Urdu].
const Map<String, List<String>> _s = {
  'tagline': ['Your Personal AI Study Partner', 'آپ کا ذاتی اے آئی اسٹڈی پارٹنر', 'Aap ka personal AI study partner'],
  'welcome_back': ['Welcome back', 'خوش آمدید', 'Khush aamdeed'],
  'sign_in': ['Sign in', 'سائن اِن کریں', 'Sign in karein'],
  'sign_up': ['Sign up', 'سائن اپ کریں', 'Sign up karein'],
  'create_account': ['Create account', 'اکاؤنٹ بنائیں', 'Account banayein'],
  'email': ['Email', 'ای میل', 'Email'],
  'password': ['Password', 'پاس ورڈ', 'Password'],
  'confirm_password': ['Confirm password', 'پاس ورڈ کی تصدیق کریں', 'Password confirm karein'],
  'full_name': ['Full name', 'پورا نام', 'Poora naam'],
  'no_account': ["Don't have an account?", 'اکاؤنٹ نہیں ہے؟', 'Account nahi hai?'],
  'have_account': ['Already have an account?', 'پہلے سے اکاؤنٹ ہے؟', 'Pehle se account hai?'],
  'guest': ['Continue as guest', 'مہمان کے طور پر جاری رکھیں', 'Guest ke taur par jaari rakhein'],
  'home': ['Home', 'ہوم', 'Home'],
  'tutor': ['AI Tutor', 'اے آئی ٹیوٹر', 'AI Tutor'],
  'notes': ['Notes', 'نوٹس', 'Notes'],
  'planner': ['Planner', 'پلانر', 'Planner'],
  'profile': ['Profile', 'پروفائل', 'Profile'],
  'hello': ['Hello', 'السلام علیکم', 'Assalam o Alaikum'],
  'student': ['Student', 'طالب علم', 'Student'],
  'guest_name': ['Guest', 'مہمان', 'Guest'],
  'appearance': ['Appearance', 'ظاہری شکل', 'Appearance'],
  'theme_system': ['System', 'سسٹم', 'System'],
  'theme_light': ['Light', 'لائٹ', 'Light'],
  'theme_dark': ['Dark', 'ڈارک', 'Dark'],
  'language': ['App language', 'ایپ کی زبان', 'App ki zubaan'],
  'edit_profile': ['Edit profile', 'پروفائل ایڈٹ کریں', 'Profile edit karein'],
  'grade': ['Class / grade', 'کلاس / گریڈ', 'Class / grade'],
  'answer_language': ['Preferred answer language', 'جوابات کی پسندیدہ زبان', 'Jawabat ki pasandeeda zubaan'],
  'subjects': ['Subjects', 'مضامین', 'Mazameen'],
  'save': ['Save', 'محفوظ کریں', 'Save karein'],
  'saved': ['Saved', 'محفوظ ہو گیا', 'Save ho gaya'],
  'account': ['Account', 'اکاؤنٹ', 'Account'],
  'sign_out': ['Sign out', 'سائن آؤٹ', 'Sign out'],
  'delete_account': ['Delete account', 'اکاؤنٹ حذف کریں', 'Account delete karein'],
  'delete_title': ['Delete your account?', 'کیا اکاؤنٹ حذف کریں؟', 'Kya account delete karein?'],
  'delete_body': [
    'This permanently deletes your account and all your data. This cannot be undone.',
    'یہ آپ کا اکاؤنٹ اور تمام ڈیٹا مستقل طور پر حذف کر دے گا۔ اسے واپس نہیں کیا جا سکتا۔',
    'Yeh aap ka account aur tamam data hamesha ke liye delete kar dega. Isay wapis nahi kiya ja sakta.'
  ],
  'cancel': ['Cancel', 'منسوخ کریں', 'Cancel'],
  'delete': ['Delete', 'حذف کریں', 'Delete'],
  'ok': ['OK', 'ٹھیک ہے', 'OK'],
  'offline': [
    "You're offline. Saved content is still available.",
    'آپ آف لائن ہیں۔ محفوظ شدہ مواد دستیاب ہے۔',
    'Aap offline hain. Saved content available hai.'
  ],
  'ai_check': ['Test AI connection', 'اے آئی کنکشن چیک کریں', 'AI connection check karein'],
  'ai_check_sub': [
    'Confirms the secure AI backend is set up',
    'تصدیق کرتا ہے کہ محفوظ اے آئی بیک اینڈ تیار ہے',
    'Confirm karta hai ke secure AI backend tayyar hai'
  ],
  'ai_needs_account': ['Sign in to use AI features', 'اے آئی استعمال کرنے کے لیے سائن اِن کریں', 'AI use karne ke liye sign in karein'],
  'coming_soon': ['Coming soon', 'جلد آ رہا ہے', 'Jald aa raha hai'],
  'guest_banner': [
    'You are in guest mode. Create an account to save your data and use AI.',
    'آپ مہمان موڈ میں ہیں۔ ڈیٹا محفوظ کرنے اور اے آئی استعمال کرنے کے لیے اکاؤنٹ بنائیں۔',
    'Aap guest mode mein hain. Data save karne aur AI use karne ke liye account banayein.'
  ],
  'guest_exit': ['Create account / sign in', 'اکاؤنٹ بنائیں / سائن اِن کریں', 'Account banayein / sign in karein'],
  'email_confirm_title': ['Check your email', 'اپنی ای میل چیک کریں', 'Apni email check karein'],
  'email_confirm_body': [
    'We sent you a confirmation link. Confirm your email, then sign in.',
    'ہم نے آپ کو تصدیقی لنک بھیجا ہے۔ ای میل کی تصدیق کریں، پھر سائن اِن کریں۔',
    'Humne aap ko confirmation link bheja hai. Email confirm karein, phir sign in karein.'
  ],
  'required': ['This field is required', 'یہ خانہ ضروری ہے', 'Yeh field zaroori hai'],
  'invalid_email': ['Enter a valid email', 'درست ای میل درج کریں', 'Durust email likhein'],
  'short_password': ['At least 8 characters', 'کم از کم 8 حروف', 'Kam az kam 8 characters'],
  'password_mismatch': ['Passwords do not match', 'پاس ورڈ مماثل نہیں', 'Password match nahi karte'],
  'choose': ['Choose', 'منتخب کریں', 'Select karein'],
};

String trFor(AppLang lang, String key) => _s[key]?[lang.index] ?? key;

extension TrX on WidgetRef {
  /// Translate [key] in the current app language. Call only inside build().
  String tr(String key) => trFor(watch(settingsProvider).lang, key);

  /// Same as [tr] but safe to call inside callbacks (button handlers, etc.).
  String trRead(String key) => trFor(read(settingsProvider).lang, key);
}
