import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_routes.dart';
import 'view_models/auth_view_model.dart';
import 'notifiers/favorites_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authViewModel = AuthViewModel();
  await authViewModel.loadToken();
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => FavoritesNotifier())],
      child: MyApp(authViewModel: authViewModel),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthViewModel authViewModel;
  const MyApp({required this.authViewModel});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/loading',
      onGenerateRoute:
          (settings) => AppRoutes.onGenerateRoute(settings, authViewModel),
    );
  }
}
