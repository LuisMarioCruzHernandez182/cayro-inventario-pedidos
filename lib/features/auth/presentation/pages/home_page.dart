import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/buttons/primary_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    double scaleW(double value) => value * (width / 390);
    double scaleH(double value) => value * (height / 844);

    return Scaffold(
      backgroundColor: AppColors.blue600,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: scaleW(24),
                  vertical: scaleH(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: scaleH(20)),

                    /// LOGO
                    Image.asset(
                      'assets/images/logo.png',
                      height: scaleH(70),
                      fit: BoxFit.contain,
                    ),

                    SizedBox(height: scaleH(20)),

                    Text(
                      AppStrings.hello,
                      style: TextStyle(
                        fontSize: scaleW(44),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
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

                    SizedBox(height: scaleH(28)),

                    SizedBox(
                      height: scaleH(250),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/Logistics.png',
                            height: scaleH(280),
                            fit: BoxFit.contain,
                          ),
                          Positioned(
                            top: scaleH(10),
                            right: scaleW(30),
                            child: CircleAvatar(
                              radius: scaleW(20),
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: scaleW(22),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: scaleH(10),
                            left: scaleW(30),
                            child: CircleAvatar(
                              radius: scaleW(20),
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.inventory_2,
                                color: Colors.orange,
                                size: scaleW(22),
                              ),
                            ),
                          ),
                        ],
                      ),
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
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.inventoryManagement,
                      style: TextStyle(
                        fontSize: scaleW(26),
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: scaleH(15)),
                    Text(
                      AppStrings.inventoryDescription,
                      style: TextStyle(
                        fontSize: scaleW(16),
                        color: AppColors.gray600,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: scaleH(25)),
                    PrimaryButton(
                      text: AppStrings.getStarted,
                      onPressed: () => context.go("/login"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
