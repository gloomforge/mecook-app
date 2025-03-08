import 'package:flutter/material.dart';
import 'package:mecook_application/features/recipes/data/models/dish.dart';
import 'package:mecook_application/features/recipes/presentation/views/dish_detail_view.dart';
import 'package:mecook_application/features/splash/presentation/views/loading_screen.dart';
import 'package:mecook_application/features/splash/presentation/views/get_started_view.dart';
import 'package:mecook_application/features/auth/presentation/views/login_view.dart';
import 'package:mecook_application/features/auth/presentation/views/register_view.dart';
import 'package:mecook_application/features/recipes/presentation/views/home_view.dart';
import 'package:mecook_application/features/splash/presentation/views/no_connection_screen.dart';
import 'package:mecook_application/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:provider/provider.dart';
import 'package:mecook_application/features/recipes/data/repositories/dish_card_repository.dart';
import 'package:mecook_application/features/recipes/presentation/view_models/dish_card_view_model.dart';
import 'package:mecook_application/core/network/network_service.dart';
import 'package:mecook_application/core/network/connectivity_notifier.dart';
import 'package:mecook_application/main.dart';

class AppRoutes {
  static Widget home() {
    final authViewModel = Provider.of<AuthViewModel>(navigatorKey.currentContext!, listen: false);
    return HomeView(authViewModel: authViewModel);
  }
  
  static Widget login() {
    final authViewModel = Provider.of<AuthViewModel>(navigatorKey.currentContext!, listen: false);
    return LoginView(authViewModel: authViewModel);
  }
  
  static Route? onGenerateRoute(
    RouteSettings settings,
    AuthViewModel authViewModel,
  ) {
    switch (settings.name) {
      case '/dishDetail':
        final dish = settings.arguments as Dish;
        return MaterialPageRoute(
          builder: (context) {
            return ChangeNotifierProvider(
              create:
                  (_) => DishCardViewModel(repository: DishCardRepository()),
              child: DishDetailView(dish: dish),
            );
          },
        );
      case '/loading':
        return MaterialPageRoute(
          builder: (context) => LoadingScreen(authViewModel: authViewModel),
        );
      case '/getStarted':
        return MaterialPageRoute(
          builder: (context) => GetStartedView(authViewModel: authViewModel),
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
      case '/noConnection':
        return MaterialPageRoute(
          builder: (context) => NoConnectionScreen(
            onRetry: () async {
              final connectivityNotifier = Provider.of<ConnectivityNotifier>(context, listen: false);
              final isConnected = await connectivityNotifier.retryConnection();
              
              if (isConnected) {
                if (Navigator.canPop(context)) {
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pushReplacementNamed('/getStarted');
                }
              }
            },
          ),
        );
      default:
        return null;
    }
  }
  
  static Widget buildPage(BuildContext context) {
    final route = onGenerateRoute(
      ModalRoute.of(context)?.settings ?? const RouteSettings(name: '/loading'),
      Provider.of<AuthViewModel>(context, listen: false),
    );
    
    if (route != null) {
      return route.buildContent(context);
    }
    
    return const Scaffold(
      body: Center(
        child: Text('Страница не найдена'),
      ),
    );
  }
}

extension RouteExtension on Route {
  Widget buildContent(BuildContext context) {
    if (this is MaterialPageRoute) {
      return (this as MaterialPageRoute).builder(context);
    }
    return const Scaffold(
      body: Center(
        child: Text('Неизвестный тип маршрута'),
      ),
    );
  }
}
