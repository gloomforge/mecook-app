import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'package:mecook_application/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:mecook_application/core/network/connectivity_notifier.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authViewModel = AuthViewModel();
  await authViewModel.loadToken();
  final connectivityNotifier = ConnectivityNotifier();
  connectivityNotifier.startMonitoring();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => connectivityNotifier),
        ChangeNotifierProvider.value(value: authViewModel),
      ],
      child: MyApp(authViewModel: authViewModel),
    ),
  );
}
