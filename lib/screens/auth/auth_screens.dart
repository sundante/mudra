import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/mudra_button.dart';
import '../../widgets/common/mudra_card.dart';
import '../../widgets/common/mudra_input.dart';

class AuthLoadingScreen extends StatelessWidget {
  const AuthLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
    );
  }
}

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(appSessionControllerProvider).state;
    return _AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Text(
            'Mudra',
            style: AppTypography.displayMedium.copyWith(color: AppColors.gold),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Your money, clear and private.',
            style: AppTypography.headingLarge.copyWith(color: AppColors.ink),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Build a calm picture of your finances. Your records remain '
            'private to your account on this device.',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.inkDim),
          ),
          const SizedBox(height: AppSpacing.xl),
          MudraButton(
            label: 'Create account',
            onPressed: () => context.push('/auth/register'),
          ),
          const SizedBox(height: AppSpacing.sm),
          MudraButton(
            label: 'Log in',
            variant: MudraButtonVariant.secondary,
            onPressed: () => context.push('/auth/login'),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SocialButtons(isBusy: session.isBusy),
          if (!session.authConfigured) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Authentication configuration is required before sign-in can '
              'complete in this build.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(color: AppColors.inkDim),
            ),
          ],
          const Spacer(),
          Text(
            'By continuing, you agree to Mudra Terms and Privacy Policy.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(color: AppColors.inkDim),
          ),
        ],
      ),
    );
  }
}

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _consented = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(appSessionControllerProvider);
    final state = controller.state;
    return _AuthScaffold(
      title: 'Create account',
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Begin with a private account',
              style: AppTypography.headingLarge.copyWith(color: AppColors.ink),
            ),
            const SizedBox(height: AppSpacing.lg),
            MudraInput(
              label: 'Full name',
              controller: _name,
              textInputAction: TextInputAction.next,
              validator: _required,
            ),
            const SizedBox(height: AppSpacing.md),
            MudraInput(
              label: 'Email',
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: _validateEmail,
            ),
            const SizedBox(height: AppSpacing.md),
            MudraInput(
              label: 'Password',
              controller: _password,
              obscureText: true,
              textInputAction: TextInputAction.next,
              validator: _validatePassword,
            ),
            const SizedBox(height: AppSpacing.md),
            MudraInput(
              label: 'Confirm password',
              controller: _confirmPassword,
              obscureText: true,
              textInputAction: TextInputAction.done,
              validator: (value) =>
                  value != _password.text ? 'Passwords do not match' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.gold,
              value: _consented,
              onChanged: state.isBusy
                  ? null
                  : (value) => setState(() => _consented = value ?? false),
              title: Text(
                'I agree to the Terms and Privacy Policy',
                style:
                    AppTypography.bodySmall.copyWith(color: AppColors.inkMid),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            if (state.errorMessage != null) _AuthError(state.errorMessage!),
            const SizedBox(height: AppSpacing.md),
            MudraButton(
              key: const ValueKey('register-submit'),
              label: state.isBusy ? 'Creating...' : 'Create account',
              onPressed: state.isBusy ? null : _submit,
            ),
            const SizedBox(height: AppSpacing.md),
            _InlineLink(
              text: 'Already have an account?',
              action: 'Log in',
              onTap: () => context.go('/auth/login'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState!.validate();
    if (!valid || !_consented) {
      if (!_consented) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Accept Terms and Privacy to continue.')),
        );
      }
      await HapticFeedback.vibrate();
      return;
    }
    await ref.read(appSessionControllerProvider).register(
          fullName: _name.text.trim(),
          email: _email.text.trim(),
          password: _password.text,
        );
  }
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appSessionControllerProvider).state;
    return _AuthScaffold(
      title: 'Log in',
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const SizedBox(height: AppSpacing.lg),
            Text('Welcome back',
                style:
                    AppTypography.headingLarge.copyWith(color: AppColors.ink)),
            const SizedBox(height: AppSpacing.lg),
            MudraInput(
              label: 'Email',
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: _validateEmail,
            ),
            const SizedBox(height: AppSpacing.md),
            MudraInput(
              label: 'Password',
              controller: _password,
              obscureText: true,
              textInputAction: TextInputAction.done,
              validator: _required,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push('/auth/forgot-password'),
                child: const Text('Forgot password?'),
              ),
            ),
            if (state.errorMessage != null) _AuthError(state.errorMessage!),
            MudraButton(
              label: state.isBusy ? 'Logging in...' : 'Log in',
              onPressed: state.isBusy ? null : _submit,
            ),
            const SizedBox(height: AppSpacing.lg),
            _SocialButtons(isBusy: state.isBusy),
            const SizedBox(height: AppSpacing.md),
            _InlineLink(
              text: 'New to Mudra?',
              action: 'Create account',
              onTap: () => context.go('/auth/register'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(appSessionControllerProvider).login(
          email: _email.text.trim(),
          password: _password.text,
        );
  }
}

class VerifyEmailScreen extends ConsumerWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(appSessionControllerProvider);
    final state = controller.state;
    return _AuthScaffold(
      title: 'Verify email',
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mark_email_unread_outlined,
                size: 50, color: AppColors.gold),
            const SizedBox(height: AppSpacing.lg),
            Text('Check your inbox',
                style:
                    AppTypography.headingLarge.copyWith(color: AppColors.ink)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'We sent a confirmation link to\n${state.email ?? 'your email'}.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.inkDim),
            ),
            if (state.errorMessage != null) _AuthError(state.errorMessage!),
            const SizedBox(height: AppSpacing.lg),
            MudraButton(
              label: state.isBusy ? 'Sending...' : 'Resend confirmation',
              onPressed: state.isBusy ? null : controller.resendConfirmation,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: state.isBusy
                  ? null
                  : () async {
                      await controller.signOut();
                      if (context.mounted) context.go('/auth/login');
                    },
              child: const Text('Use another email'),
            ),
          ],
        ),
      ),
    );
  }
}

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appSessionControllerProvider).state;
    return _AuthScaffold(
      title: 'Reset password',
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Recover access',
                style:
                    AppTypography.headingLarge.copyWith(color: AppColors.ink)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _sent
                  ? 'A reset link has been sent. Open it on this device.'
                  : 'Enter the email used for your Mudra account.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.inkDim),
            ),
            const SizedBox(height: AppSpacing.lg),
            MudraInput(
              label: 'Email',
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),
            if (state.errorMessage != null) _AuthError(state.errorMessage!),
            const SizedBox(height: AppSpacing.lg),
            MudraButton(
              label: state.isBusy ? 'Sending...' : 'Send reset link',
              onPressed: state.isBusy ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final sent = await ref
        .read(appSessionControllerProvider)
        .requestPasswordReset(_email.text.trim());
    if (sent && mounted) setState(() => _sent = true);
  }
}

class NewPasswordScreen extends ConsumerStatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  ConsumerState<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends ConsumerState<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appSessionControllerProvider).state;
    return _AuthScaffold(
      title: 'New password',
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MudraInput(
              label: 'New password',
              controller: _password,
              obscureText: true,
              validator: _validatePassword,
            ),
            const SizedBox(height: AppSpacing.md),
            MudraInput(
              label: 'Confirm new password',
              controller: _confirmation,
              obscureText: true,
              validator: (value) =>
                  value != _password.text ? 'Passwords do not match' : null,
            ),
            if (state.errorMessage != null) _AuthError(state.errorMessage!),
            const SizedBox(height: AppSpacing.lg),
            MudraButton(
              label: state.isBusy ? 'Updating...' : 'Update password',
              onPressed: state.isBusy ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(appSessionControllerProvider).updatePassword(_password.text);
  }
}

class LegacyDataScreen extends ConsumerWidget {
  const LegacyDataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(appSessionControllerProvider);
    final state = controller.state;
    return _AuthScaffold(
      child: Center(
        child: MudraCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Existing data found',
                style:
                    AppTypography.headingLarge.copyWith(color: AppColors.ink),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Mudra found financial records from before account sign-in. '
                'Attach them privately to this account or begin with an '
                'empty workspace.',
                textAlign: TextAlign.center,
                style:
                    AppTypography.bodyMedium.copyWith(color: AppColors.inkDim),
              ),
              if (state.errorMessage != null) _AuthError(state.errorMessage!),
              const SizedBox(height: AppSpacing.lg),
              MudraButton(
                label:
                    state.isBusy ? 'Attaching...' : 'Attach my existing data',
                onPressed: state.isBusy ? null : controller.attachLegacyData,
              ),
              const SizedBox(height: AppSpacing.sm),
              MudraButton(
                label: 'Start fresh',
                variant: MudraButtonVariant.secondary,
                onPressed: state.isBusy ? null : controller.startFresh,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SetupWelcomeScreen extends ConsumerWidget {
  const SetupWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(appSessionControllerProvider);
    return _AuthScaffold(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Welcome to Mudra',
                style:
                    AppTypography.displaySmall.copyWith(color: AppColors.gold)),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Your private account is ready. Financial setup begins in the '
              'next step of your journey.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.inkDim),
            ),
            const SizedBox(height: AppSpacing.xl),
            MudraCard(
              child: Text(
                'No sample financial data has been added to your account.',
                textAlign: TextAlign.center,
                style:
                    AppTypography.bodySmall.copyWith(color: AppColors.inkMid),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextButton(
              onPressed: controller.state.isBusy ? null : controller.signOut,
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialButtons extends ConsumerWidget {
  const _SocialButtons({required this.isBusy});

  final bool isBusy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(appSessionControllerProvider);
    final showApple = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text('or continue with',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.inkDim)),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        MudraButton(
          label: 'Continue with Google',
          variant: MudraButtonVariant.secondary,
          onPressed: isBusy ? null : controller.signInWithGoogle,
        ),
        if (showApple) ...[
          const SizedBox(height: AppSpacing.sm),
          MudraButton(
            label: 'Continue with Apple',
            variant: MudraButtonVariant.secondary,
            onPressed: isBusy ? null : controller.signInWithApple,
          ),
        ],
      ],
    );
  }
}

class _AuthScaffold extends StatelessWidget {
  const _AuthScaffold({required this.child, this.title});

  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: title == null
          ? null
          : AppBar(
              backgroundColor: AppColors.background,
              surfaceTintColor: Colors.transparent,
              title: Text(title!,
                  style: AppTypography.headingMedium
                      .copyWith(color: AppColors.gold)),
            ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenH,
            AppSpacing.screenV,
            AppSpacing.screenH,
            AppSpacing.screenV,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _AuthError extends StatelessWidget {
  const _AuthError(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Text(
        message,
        style: AppTypography.bodySmall.copyWith(color: AppColors.red),
      ),
    );
  }
}

class _InlineLink extends StatelessWidget {
  const _InlineLink({
    required this.text,
    required this.action,
    required this.onTap,
  });

  final String text;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('$text ', style: AppTypography.bodySmall),
        TextButton(onPressed: onTap, child: Text(action)),
      ],
    );
  }
}

String? _required(String? value) =>
    value == null || value.trim().isEmpty ? 'This field is required' : null;

String? _validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
    return 'Enter a valid email address';
  }
  return null;
}

String? _validatePassword(String? value) {
  if ((value ?? '').length < 8) return 'Use at least 8 characters';
  return null;
}
