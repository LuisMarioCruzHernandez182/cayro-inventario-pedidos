import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<AuthBloc>(),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthBloc>().add(
      LoginRequested(
        identifier: _userController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  void _handleBackToHome() {
    context.go('/');
  }

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    double scaleW(double value) => value * (width / 390);
    double scaleH(double value) => value * (height / 844);

    return Scaffold(
      backgroundColor: AppColors.blue600,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: scaleW(24),
                  vertical: scaleH(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: scaleH(10)),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: _handleBackToHome,
                          child: Container(
                            width: scaleW(50),
                            height: scaleW(50),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_back,
                              color: AppColors.blue600,
                              size: scaleW(24),
                            ),
                          ),
                        ),
                        Image.asset(
                          'assets/images/logo.png',
                          height: scaleH(60),
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),

                    SizedBox(height: scaleH(20)),

                    Text(
                      AppStrings.hello,
                      style: TextStyle(
                        fontSize: scaleW(44),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: scaleH(8)),
                    Text(
                      AppStrings.welcomeToCayro,
                      style: TextStyle(
                        fontSize: scaleW(20),
                        color: Colors.white70,
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: scaleH(24)),

                    Image.asset(
                      'assets/images/Password.png',
                      height: scaleH(180),
                      fit: BoxFit.contain,
                    ),

                    SizedBox(height: scaleH(160)),
                  ],
                ),
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  scaleW(24),
                  scaleH(20),
                  scaleW(24),
                  scaleH(16),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(scaleW(32)),
                    topRight: Radius.circular(scaleW(32)),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: scaleW(10),
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: BlocListener<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state is AuthAuthenticated) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Inicio de sesión exitoso'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        context.go('/main/inventory');
                      } else if (state is AuthError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              AppStrings.systemAccess,
                              style: TextStyle(
                                fontSize: scaleW(26),
                                fontWeight: FontWeight.bold,
                                color: AppColors.gray900,
                              ),
                            ),
                          ),
                          SizedBox(height: scaleH(8)),
                          Text(
                            AppStrings.loginInstructions,
                            style: TextStyle(
                              fontSize: scaleW(16),
                              color: AppColors.gray600,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: scaleH(20)),

                          Text(
                            'Correo o Teléfono',
                            style: TextStyle(
                              fontSize: scaleW(16),
                              fontWeight: FontWeight.bold,
                              color: AppColors.gray900,
                            ),
                          ),
                          SizedBox(height: scaleH(8)),
                          _buildTextField(
                            controller: _userController,
                            hint: 'ejemplo@correo.com o 5512345678',
                            validator: Validators.validateUser,
                            scaleW: scaleW,
                            scaleH: scaleH,
                          ),
                          SizedBox(height: scaleH(16)),

                          Text(
                            'Contraseña',
                            style: TextStyle(
                              fontSize: scaleW(16),
                              fontWeight: FontWeight.bold,
                              color: AppColors.gray900,
                            ),
                          ),
                          SizedBox(height: scaleH(8)),
                          _buildTextField(
                            controller: _passwordController,
                            hint: '••••••••',
                            validator: Validators.validatePassword,
                            isPassword: true,
                            scaleW: scaleW,
                            scaleH: scaleH,
                          ),
                          SizedBox(height: scaleH(24)),

                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              final isLoading = state is AuthLoading;
                              return PrimaryButton(
                                text: AppStrings.login,
                                onPressed: isLoading ? null : _handleLogin,
                                isLoading: isLoading,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required String? Function(String?) validator,
    required double Function(double) scaleW,
    required double Function(double) scaleH,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(scaleW(12)),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: scaleW(16),
            vertical: scaleH(16),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.gray400,
                    size: scaleW(22),
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                )
              : null,
        ),
      ),
    );
  }
}
