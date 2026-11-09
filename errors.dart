import 'dart:async';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class AiException implements Exception {
  AiException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Turns any error into a short, friendly message for the user.
String friendlyError(Object e) {
  if (e is AiException) return e.message;
  if (e is AuthException) return e.message;
  if (e is PostgrestException) return e.message;
  if (e is TimeoutException) {
    return 'The request timed out. Please check your connection and try again.';
  }
  if (e is SocketException) {
    return 'No internet connection. Please connect and try again.';
  }
  return 'Something went wrong. Please try again.';
}
