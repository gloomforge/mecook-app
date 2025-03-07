import 'package:flutter/material.dart';
import 'app_routes.dart';
import 'package:provider/provider.dart';
import 'core/network/connectivity_notifier.dart';
import 'package:mecook_application/features/auth/presentation/view_models/auth_view_model.dart';
import 'main.dart';
import 'package:mecook_application/core/constants.dart';

class MyApp extends StatelessWidget {
  final AuthViewModel authViewModel;
  const MyApp({Key? key, required this.authViewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MeCook',
      theme: ThemeData(
        primaryColor: AppColors.primaryColor,
        scaffoldBackgroundColor: AppColors.backgroundColor,
        colorScheme: ColorScheme.light(
          primary: AppColors.primaryColor,
          secondary: AppColors.secondaryColor,
          tertiary: AppColors.accentColor,
          error: AppColors.errorColor,
          background: AppColors.backgroundColor,
          surface: AppColors.cardColor,
        ),
        cardTheme: CardTheme(
          color: AppColors.cardColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryColor,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryColor,
            side: BorderSide(color: AppColors.primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.dividerColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: AppColors.primaryColor,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.errorColor),
          ),
        ),
        dividerTheme: DividerThemeData(
          color: AppColors.dividerColor,
          thickness: 1,
          space: 16,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.chipUnselectedColor,
          selectedColor: AppColors.chipSelectedColor,
          secondarySelectedColor: AppColors.accentColor,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          labelStyle: TextStyle(color: AppColors.textPrimaryColor),
          secondaryLabelStyle: const TextStyle(color: Colors.white),
          brightness: Brightness.light,
        ),
      ),
      initialRoute: '/loading',
      navigatorKey: navigatorKey,
      onGenerateRoute:
          (settings) => AppRoutes.onGenerateRoute(settings, authViewModel),
      builder: (context, child) {
        return Consumer<ConnectivityNotifier>(
          builder: (context, connectivity, _) {
            if (!connectivity.isConnected && 
                ModalRoute.of(context)?.settings.name != '/noConnection') {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  primaryColor: AppColors.primaryColor,
                  colorScheme: ColorScheme.light(
                    primary: AppColors.primaryColor,
                    secondary: AppColors.secondaryColor,
                  ),
                ),
                home: AppRoutes.onGenerateRoute(
                  const RouteSettings(name: '/noConnection'),
                  authViewModel,
                )?.buildContent(context),
              );
            }
            return child!;
          },
        );
      },
    );
  }
}
