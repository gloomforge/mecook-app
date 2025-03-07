import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mecook_application/core/constants.dart';
import 'package:mecook_application/features/auth/presentation/view_models/auth_view_model.dart';
import 'no_connection_screen.dart';

class LoadingScreen extends StatefulWidget {
  final AuthViewModel authViewModel;
  const LoadingScreen({Key? key, required this.authViewModel})
    : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool _isConnected = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkServerConnection();
  }

  Future<void> _checkServerConnection() async {
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.serverUrl}/api/ping"),
      );
      setState(() {
        _isConnected = (response.statusCode == 200);
      });
    } catch (_) {
      setState(() {
        _isConnected = false;
      });
    }
    _navigate();
  }

  void _navigate() async {
    if (_isConnected) {
      Navigator.pushReplacementNamed(context, '/getStarted');
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isConnected && !_isLoading) {
      return NoConnectionScreen(
        onRetry: () {
          setState(() {
            _isLoading = true;
          });
          _checkServerConnection();
        },
      );
    }
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
