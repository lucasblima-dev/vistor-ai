import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vistor_ai_mobile/app/router.dart';
import 'package:vistor_ai_mobile/app/theme.dart';
import 'package:vistor_ai_mobile/features/auth/domain/auth_cubit.dart';
import 'package:vistor_ai_mobile/features/auth/domain/auth_state.dart';
import 'package:vistor_ai_mobile/features/auth/presentation/widgets/login_form.dart';
import 'package:vistor_ai_mobile/shared/widgets/app_logo.dart';
import 'package:vistor_ai_mobile/shared/widgets/error_snackbar.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          state.whenOrNull(
            authenticated: (_) => context.go(AppRoutes.home),
            error: (message) => showErrorSnackbar(context, message),
          );
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: [
                const SizedBox(height: 48),
                const AppLogo(size: 80),
                const SizedBox(height: 20),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.onBgLight,
                    ),
                    children: const [
                      TextSpan(text: 'Bem-vindo ao '),
                      TextSpan(
                        text: 'Vistor AI',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Inspeções técnicas potencializadas por IA',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.subtextLight,
                  ),
                ),
                const SizedBox(height: 36),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    final isLoading = state.maybeWhen(
                      loading: () => true,
                      orElse: () => false,
                    );
                    return LoginForm(
                      isLoading: isLoading,
                      onSubmit: (email, password) {
                        context.read<AuthCubit>().login(email, password);
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Protegido por criptografia Vistor AI',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    color: AppColors.subtextLight,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
