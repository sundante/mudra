import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/database.dart';
import '../data/models/app_settings.dart';
import '../data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => const UnconfiguredAuthRepository(),
);

enum AppSessionStage {
  loading,
  signedOut,
  guest,
  verificationRequired,
  passwordRecovery,
  legacyDataDecision,
  setupRequired,
  ready,
}

class AppSessionState {
  const AppSessionState({
    required this.stage,
    this.email,
    this.errorMessage,
    this.isBusy = false,
    this.authConfigured = true,
  });

  const AppSessionState.loading()
      : stage = AppSessionStage.loading,
        email = null,
        errorMessage = null,
        isBusy = false,
        authConfigured = true;

  final AppSessionStage stage;
  final String? email;
  final String? errorMessage;
  final bool isBusy;
  final bool authConfigured;

  AppSessionState copyWith({
    AppSessionStage? stage,
    String? email,
    String? errorMessage,
    bool? isBusy,
    bool? authConfigured,
    bool clearError = false,
  }) {
    return AppSessionState(
      stage: stage ?? this.stage,
      email: email ?? this.email,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isBusy: isBusy ?? this.isBusy,
      authConfigured: authConfigured ?? this.authConfigured,
    );
  }
}

class AppSessionController extends ChangeNotifier {
  AppSessionController(this._ref, this._auth) {
    unawaited(_initialise());
  }

  final Ref _ref;
  final AuthRepository _auth;
  StreamSubscription<AuthState>? _subscription;
  Isar? _activeDatabase;
  AppSessionState _state = const AppSessionState.loading();

  AppSessionState get state => _state;
  bool get authConfigured => _auth.isConfigured;

  Future<void> _initialise() async {
    _subscription = _auth.authStateChanges.listen((event) {
      unawaited(_handleAuthState(event));
    });
    await _handleSession(_auth.currentSession);
  }

  Future<void> _handleAuthState(AuthState event) async {
    if (event.event == AuthChangeEvent.passwordRecovery) {
      _setState(AppSessionState(
        stage: AppSessionStage.passwordRecovery,
        email: event.session?.user.email,
      ));
      return;
    }
    await _handleSession(event.session);
  }

  Future<void> _handleSession(Session? session) async {
    if (session == null) {
      await _releaseDatabase();
      _setState(AppSessionState(
        stage: AppSessionStage.signedOut,
        authConfigured: _auth.isConfigured,
      ));
      return;
    }
    final user = session.user;
    if (user.emailConfirmedAt == null) {
      _setState(AppSessionState(
        stage: AppSessionStage.verificationRequired,
        email: user.email,
      ));
      return;
    }
    await _prepareAuthenticatedUser(user);
  }

  Future<void> _prepareAuthenticatedUser(User user) async {
    _setState(_state.copyWith(isBusy: true, clearError: true));
    try {
      final bootstrap = await openUserDatabase(user.id);
      await _activateDatabase(bootstrap.isar);
      await _ensureSettings(user);
      if (await legacyDatabaseHasData()) {
        _setState(AppSessionState(
          stage: AppSessionStage.legacyDataDecision,
          email: user.email,
        ));
        return;
      }
      await _routeFromSettings(email: user.email);
    } catch (error) {
      _setState(AppSessionState(
        stage: AppSessionStage.signedOut,
        errorMessage: 'Could not open your private local data: $error',
      ));
    }
  }

  /// Debug helper to sign in without hitting real auth backends.
  /// Creates/opens a user database for [userId] and routes the app.
  Future<void> signInAsDebug({
    required String userId,
    required String email,
    String? fullName,
  }) async {
    _setState(_state.copyWith(isBusy: true, clearError: true));
    try {
      final bootstrap = await openUserDatabase(userId);
      await _activateDatabase(bootstrap.isar);

      // Ensure settings using provided fullName if available.
      final db = _activeDatabase!;
      final existing = await db.appSettings.get(1);
      if (existing == null) {
        final name = fullName?.trim() ?? '';
        final settings = AppSettings()..userName = name;
        await db.writeTxn(() => db.appSettings.put(settings));
      }

      if (await legacyDatabaseHasData()) {
        _setState(AppSessionState(
          stage: AppSessionStage.legacyDataDecision,
          email: email,
        ));
        return;
      }
      await _routeFromSettings(email: email);
    } catch (error) {
      _setState(AppSessionState(
        stage: AppSessionStage.signedOut,
        errorMessage: 'Could not open your private local data: $error',
      ));
    }
  }

  Future<void> _ensureSettings(User user) async {
    final db = _activeDatabase!;
    final existing = await db.appSettings.get(1);
    if (existing != null) return;
    final name = (user.userMetadata?['full_name'] as String?)?.trim() ?? '';
    final settings = AppSettings()..userName = name;
    await db.writeTxn(() => db.appSettings.put(settings));
  }

  Future<void> _routeFromSettings({String? email}) async {
    final settings = await _activeDatabase!.appSettings.get(1) ?? AppSettings();
    _setState(AppSessionState(
      stage: settings.safeHasCompletedSetup
          ? AppSessionStage.ready
          : AppSessionStage.setupRequired,
      email: email,
    ));
  }

  Future<void> _activateDatabase(Isar database) async {
    if (_activeDatabase != null && _activeDatabase != database) {
      await _activeDatabase!.close();
    }
    _activeDatabase = database;
    _ref.read(activeDatabaseProvider.notifier).state = database;
  }

  Future<void> _releaseDatabase() async {
    _ref.read(activeDatabaseProvider.notifier).state = null;
    final db = _activeDatabase;
    _activeDatabase = null;
    if (db != null && db.isOpen) {
      await db.close();
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    return _perform(() async {
      await _auth.register(
        fullName: fullName,
        email: email,
        password: password,
      );
      _setState(AppSessionState(
        stage: AppSessionStage.verificationRequired,
        email: email,
      ));
    });
  }

  Future<bool> login({required String email, required String password}) {
    return _perform(() => _auth.login(email: email, password: password));
  }

  Future<bool> signInWithGoogle() => _perform(_auth.signInWithGoogle);

  Future<bool> signInWithApple() => _perform(_auth.signInWithApple);

  Future<bool> resendConfirmation() async {
    final email = _state.email;
    if (email == null || email.isEmpty) return false;
    return _perform(() => _auth.resendConfirmation(email));
  }

  Future<bool> requestPasswordReset(String email) {
    return _perform(() => _auth.requestPasswordReset(email));
  }

  Future<bool> updatePassword(String password) async {
    final result = await _perform(() => _auth.updatePassword(password));
    if (result) {
      await _handleSession(_auth.currentSession);
    }
    return result;
  }

  Future<void> attachLegacyData() async {
    final database = _activeDatabase;
    if (database == null) return;
    _setState(_state.copyWith(isBusy: true, clearError: true));
    try {
      await migrateLegacyDatabaseInto(database);
      final settings = await database.appSettings.get(1) ?? AppSettings();
      settings.hasCompletedSetup = true;
      await database.writeTxn(() => database.appSettings.put(settings));
      await _routeFromSettings(email: _state.email);
    } catch (error) {
      _setState(_state.copyWith(
        isBusy: false,
        errorMessage: 'Could not attach existing data: $error',
      ));
    }
  }

  Future<void> startFresh() async {
    _setState(_state.copyWith(isBusy: true, clearError: true));
    try {
      await discardLegacyDatabase();
      await _routeFromSettings(email: _state.email);
    } catch (error) {
      _setState(_state.copyWith(
        isBusy: false,
        errorMessage: 'Could not discard legacy data: $error',
      ));
    }
  }

  Future<void> enterGuestMode() async {
    _setState(_state.copyWith(isBusy: true, clearError: true));
    try {
      final isar = await openGuestDatabase();
      await _activateDatabase(isar);
      _setState(const AppSessionState(stage: AppSessionStage.guest));
    } catch (error) {
      _setState(AppSessionState(
        stage: AppSessionStage.signedOut,
        errorMessage: 'Could not load demo data: $error',
        authConfigured: _auth.isConfigured,
      ));
    }
  }

  Future<void> completeSetup() async {
    await _routeFromSettings(email: _state.email);
  }

  Future<void> exitGuestMode() async {
    await _releaseDatabase();
    _setState(AppSessionState(
      stage: AppSessionStage.signedOut,
      authConfigured: _auth.isConfigured,
    ));
  }

  Future<void> signOut() async {
    await _releaseDatabase();
    await _perform(_auth.signOut);
    _setState(AppSessionState(
      stage: AppSessionStage.signedOut,
      authConfigured: _auth.isConfigured,
    ));
  }

  Future<bool> _perform(Future<void> Function() action) async {
    _setState(_state.copyWith(isBusy: true, clearError: true));
    try {
      await action();
      _setState(_state.copyWith(isBusy: false, clearError: true));
      return true;
    } on AuthNotConfiguredException {
      _setState(_state.copyWith(
        isBusy: false,
        errorMessage:
            'Authentication is not configured in this build. Provide Supabase keys.',
      ));
    } on AuthException catch (error) {
      _setState(_state.copyWith(isBusy: false, errorMessage: error.message));
    } catch (error) {
      _setState(_state.copyWith(
        isBusy: false,
        errorMessage: 'Authentication failed. Please try again.',
      ));
    }
    return false;
  }

  void clearError() {
    if (_state.errorMessage == null) return;
    _setState(_state.copyWith(clearError: true));
  }

  void _setState(AppSessionState next) {
    _state = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    final db = _activeDatabase;
    if (db != null && db.isOpen) {
      unawaited(db.close());
    }
    super.dispose();
  }
}

final appSessionControllerProvider =
    ChangeNotifierProvider<AppSessionController>(
  (ref) => AppSessionController(ref, ref.watch(authRepositoryProvider)),
);
