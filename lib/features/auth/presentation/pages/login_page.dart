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
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 700;
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.blue600, AppColors.blue500, AppColors.blue400],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Sección superior (gradiente)
              Expanded(
                flex: keyboardOpen ? 3 : (isSmallScreen ? 3 : 4),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.06,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: screenSize.height * 0.02),

                        // Header con botón back y logo
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: _handleBackToHome,
                              child: Container(
                                width: screenSize.width * 0.12,
                                height: screenSize.width * 0.12,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.arrow_back,
                                  color: AppColors.blue500,
                                  size: screenSize.width * 0.06,
                                ),
                              ),
                            ),
                            Image.asset(
                              'assets/images/logo.png',
                              height: screenSize.height * 0.06,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),

                        SizedBox(height: screenSize.height * 0.02),

                        // Título principal
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            AppStrings.hello,
                            style: TextStyle(
                              fontSize: screenSize.width * 0.1,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        SizedBox(height: screenSize.height * 0.01),

                        // Subtítulo
                        Text(
                          AppStrings.welcomeToCayro,
                          style: TextStyle(
                            fontSize: screenSize.width * 0.05,
                            color: Colors.white70,
                            fontWeight: FontWeight.w300,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: screenSize.height * 0.02),

                        // Imagen
                        SizedBox(
                          height: screenSize.height * 0.18,
                          child: Image.asset(
                            'assets/images/Password.png',
                            fit: BoxFit.contain,
                          ),
                        ),

                        SizedBox(height: screenSize.height * 0.02),
                      ],
                    ),
                  ),
                ),
              ),

              
              Expanded(
                flex: keyboardOpen ? 5 : (isSmallScreen ? 5 : 4),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      screenSize.width * 0.06,
                      screenSize.height * 0.02,
                      screenSize.width * 0.06,
                      screenSize.height * 0.02,
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: BlocListener<AuthBloc, AuthState>(
                        listener: (context, state) {
                          if (state is AuthAuthenticated) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Login exitoso'),
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
                              // Título del formulario
                              Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    AppStrings.systemAccess,
                                    style: TextStyle(
                                      fontSize: screenSize.width * 0.065,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.gray900,
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: screenSize.height * 0.01),

                              // Instrucciones
                              Text(
                                AppStrings.loginInstructions,
                                style: TextStyle(
                                  fontSize: screenSize.width * 0.038,
                                  color: AppColors.gray600,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(height: screenSize.height * 0.02),

                              // Campo de correo/teléfono
                              Text(
                                'Correo o Teléfono',
                                style: TextStyle(
                                  fontSize: screenSize.width * 0.04,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.gray900,
                                ),
                              ),

                              SizedBox(height: screenSize.height * 0.008),

                              _buildTextField(
                                controller: _userController,
                                hint: 'ejemplo@correo.com o 5512345678',
                                validator: Validators.validateUser,
                                screenSize: screenSize,
                              ),

                              SizedBox(height: screenSize.height * 0.016),

                              // Campo de contraseña
                              Text(
                                'Contraseña',
                                style: TextStyle(
                                  fontSize: screenSize.width * 0.04,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.gray900,
                                ),
                              ),

                              SizedBox(height: screenSize.height * 0.008),

                              _buildTextField(
                                controller: _passwordController,
                                hint: '••••••••',
                                validator: Validators.validatePassword,
                                isPassword: true,
                                screenSize: screenSize,
                              ),

                              SizedBox(height: screenSize.height * 0.024),

                              // Botón de login
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required String? Function(String?) validator,
    required Size screenSize,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: screenSize.width * 0.04,
            vertical: screenSize.height * 0.02,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.gray400,
                    size: screenSize.width * 0.06,
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
