import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'data/repositories/auth_repository.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  const googleIosClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');
  const googleWebClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
  AuthRepository authRepository = const UnconfiguredAuthRepository();
  if (supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty) {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
    authRepository = SupabaseAuthRepository(
      client: Supabase.instance.client,
      googleIosClientId: googleIosClientId.isEmpty ? null : googleIosClientId,
      googleWebClientId: googleWebClientId.isEmpty ? null : googleWebClientId,
    );
  }

  runApp(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
      ],
      child: const MudraApp(),
    ),
  );
}
