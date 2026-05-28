import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const authCallbackUrl = 'mudra://auth/callback';
const resetPasswordCallbackUrl = 'mudra://auth/reset-password';

abstract class AuthRepository {
  bool get isConfigured;
  Session? get currentSession;
  Stream<AuthState> get authStateChanges;

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  });

  Future<void> login({
    required String email,
    required String password,
  });

  Future<void> resendConfirmation(String email);
  Future<void> requestPasswordReset(String email);
  Future<void> updatePassword(String password);
  Future<void> signInWithGoogle();
  Future<void> signInWithApple();
  Future<void> signOut();
}

class AuthNotConfiguredException implements Exception {
  const AuthNotConfiguredException();

  @override
  String toString() =>
      'Authentication is not configured for this build. Add Supabase keys.';
}

class UnconfiguredAuthRepository implements AuthRepository {
  const UnconfiguredAuthRepository();

  @override
  bool get isConfigured => false;

  @override
  Session? get currentSession => null;

  @override
  Stream<AuthState> get authStateChanges => const Stream.empty();

  Never _fail() => throw const AuthNotConfiguredException();

  @override
  Future<void> login({required String email, required String password}) async =>
      _fail();

  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async =>
      _fail();

  @override
  Future<void> requestPasswordReset(String email) async => _fail();

  @override
  Future<void> resendConfirmation(String email) async => _fail();

  @override
  Future<void> signInWithApple() async => _fail();

  @override
  Future<void> signInWithGoogle() async => _fail();

  @override
  Future<void> signOut() async => _fail();

  @override
  Future<void> updatePassword(String password) async => _fail();
}

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository({
    required SupabaseClient client,
    this.googleIosClientId,
    this.googleWebClientId,
  }) : _client = client;

  final SupabaseClient _client;
  final String? googleIosClientId;
  final String? googleWebClientId;

  @override
  bool get isConfigured => true;

  @override
  Session? get currentSession => _client.auth.currentSession;

  @override
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: authCallbackUrl,
      data: {'full_name': fullName},
    );
  }

  @override
  Future<void> login({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> resendConfirmation(String email) async {
    await _client.auth.resend(
      type: OtpType.signup,
      email: email,
      emailRedirectTo: authCallbackUrl,
    );
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    await _client.auth.resetPasswordForEmail(
      email,
      redirectTo: resetPasswordCallbackUrl,
    );
  }

  @override
  Future<void> updatePassword(String password) async {
    await _client.auth.updateUser(UserAttributes(password: password));
  }

  @override
  Future<void> signInWithGoogle() async {
    final account = await GoogleSignIn(
      clientId: googleIosClientId,
      serverClientId: googleWebClientId,
    ).signIn();
    if (account == null) return;
    final tokens = await account.authentication;
    final idToken = tokens.idToken;
    if (idToken == null) {
      throw const AuthException('Google sign in did not return an ID token.');
    }
    await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: tokens.accessToken,
    );
  }

  @override
  Future<void> signInWithApple() async {
    final rawNonce = _randomNonce();
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: sha256.convert(utf8.encode(rawNonce)).toString(),
    );
    final token = credential.identityToken;
    if (token == null) {
      throw const AuthException('Apple sign in did not return an ID token.');
    }
    await _client.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: token,
      nonce: rawNonce,
    );
    final fullName = [
      credential.givenName,
      credential.familyName,
    ].whereType<String>().where((part) => part.trim().isNotEmpty).join(' ');
    if (fullName.isNotEmpty) {
      await _client.auth.updateUser(
        UserAttributes(data: {'full_name': fullName}),
      );
    }
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  String _randomNonce([int length = 32]) {
    const chars =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)])
        .join();
  }
}
