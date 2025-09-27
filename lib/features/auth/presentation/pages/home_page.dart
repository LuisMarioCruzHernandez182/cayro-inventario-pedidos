import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/buttons/primary_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              Expanded(
                flex: 7, 
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Image.asset(
                        'assets/images/logo.png',
                        height: 70,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        AppStrings.hello,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        AppStrings.welcomeToCayro,
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white70,
                          fontWeight: FontWeight.w300,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),

                      SizedBox(
                        height: 280,
                        width: double.infinity,
                        child: Stack(
                          children: [
                            Center(
                              child: Image.asset(
                                'assets/images/Logistics.png',
                                height: 380,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 30,
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.white,
                                child: const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 22,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              left: 30,
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.white,
                                child: const Icon(
                                  Icons.inventory_2,
                                  color: Colors.orange,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                flex: 3, 
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
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            AppStrings.inventoryManagement,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.gray900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15), 
                        Text(
                          AppStrings.inventoryDescription,
                          style: TextStyle(
                            fontSize: 18, 
                            color: AppColors.gray600,
                            height: 1.4,
                          ),
                          textAlign: TextAlign
                              .center,
                        ),
                        const Spacer(),
                        PrimaryButton(
                          text: AppStrings.getStarted,
                          onPressed: () {
                            context.go("/login");
                          },
                        ),
                      ],
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
}
