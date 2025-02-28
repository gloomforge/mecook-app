import 'package:flutter/material.dart';
import 'views/login_view.dart';
import 'views/register_view.dart';
import 'views/home_view.dart';
import 'views/loading_screen.dart';
import 'view_models/auth_view_model.dart';

class AppRoutes {
  static Route? onGenerateRoute(
    RouteSettings settings,
    AuthViewModel authViewModel,
  ) {
    switch (settings.name) {
      case '/loading':
        return MaterialPageRoute(
          builder: (context) => LoadingScreen(authViewModel: authViewModel),
        );
      case '/login':
        return MaterialPageRoute(
          builder: (context) => LoginView(authViewModel: authViewModel),
        );
      case '/register':
        return MaterialPageRoute(
          builder: (context) => RegisterView(authViewModel: authViewModel),
        );
      case '/home':
        return MaterialPageRoute(
          builder: (context) => HomeView(authViewModel: authViewModel),
        );
      default:
        return null;
    }
  }
}
