import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/buttons/primary_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 700;

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
                flex: isSmallScreen ? 8 : 7,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.width * 0.06,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: screenSize.height * 0.02),
                        Image.asset(
                          'assets/images/logo.png',
                          height: screenSize.height * 0.08,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: screenSize.height * 0.02),

                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            AppStrings.hello,
                            style: TextStyle(
                              fontSize:
                                  screenSize.width *
                                  0.1, // 10% del ancho de pantalla
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.01),

                        Text(
                          AppStrings.welcomeToCayro,
                          style: TextStyle(
                            fontSize:
                                screenSize.width *
                                0.05, // 5% del ancho de pantalla
                            color: Colors.white70,
                            fontWeight: FontWeight.w300,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: screenSize.height * 0.03),

                        SizedBox(
                          height: screenSize.height * 0.3,
                          width: double.infinity,
                          child: Stack(
                            children: [
                              Center(
                                child: Image.asset(
                                  'assets/images/Logistics.png',
                                  height: screenSize.height * 0.35,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              Positioned(
                                top: screenSize.height * 0.01,
                                right: screenSize.width * 0.05,
                                child: CircleAvatar(
                                  radius: screenSize.width * 0.04,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: screenSize.width * 0.045,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: screenSize.height * 0.01,
                                left: screenSize.width * 0.05,
                                child: CircleAvatar(
                                  radius: screenSize.width * 0.04,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.inventory_2,
                                    color: Colors.orange,
                                    size: screenSize.width * 0.045,
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
              ),

              Expanded(
                flex: isSmallScreen ? 4 : 3,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              AppStrings.inventoryManagement,
                              style: TextStyle(
                                fontSize: screenSize.width * 0.065,
                                fontWeight: FontWeight.bold,
                                color: AppColors.gray900,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.015),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              AppStrings.inventoryDescription,
                              style: TextStyle(
                                fontSize: screenSize.width * 0.04,
                                color: AppColors.gray600,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.02),
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
