import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/inputs/custom_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() => _isLoading = true);
    
    // Simular proceso de login
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                AppStrings.hello,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.welcomeToCayro,
                style: const TextStyle(
                  fontSize: 24,
                  color: AppColors.gray600,
                ),
              ),
              const SizedBox(height: 48),
              
              // Login Form
              Text(
                AppStrings.systemAccess,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.loginInstructions,
                style: const TextStyle(
                  color: AppColors.gray600,
                ),
              ),
              const SizedBox(height: 32),
              
              // Form Fields
              CustomTextField(
                label: AppStrings.email,
                hintText: AppStrings.emailHint,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {},
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: AppStrings.password,
                hintText: AppStrings.passwordHint,
                obscureText: true,
                onChanged: (value) {},
              ),
              const Spacer(),
              
              // Login Button
              PrimaryButton(
                text: AppStrings.login,
                onPressed: _handleLogin,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
