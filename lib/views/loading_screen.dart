import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../view_models/auth_view_model.dart';

class LoadingScreen extends StatefulWidget {
  final AuthViewModel authViewModel;

  const LoadingScreen({required this.authViewModel});

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
        Uri.parse("http://localhost:8080/api/ping"),
      );
      if (response.statusCode == 200) {
        setState(() {
          _isConnected = true;
        });
      } else {
        setState(() {
          _isConnected = false;
        });
      }
    } catch (_) {
      setState(() {
        _isConnected = false;
      });
    }

    _navigate();
  }

  void _navigate() async {
    if (_isConnected) {
      final token = await widget.authViewModel.tokenStorage.readToken();
      if (token != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isConnected) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.red, size: 50),
              SizedBox(height: 10),
              Text(
                "Нет подключения к серверу",
                style: TextStyle(fontSize: 20, color: Colors.red),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return SizedBox.shrink();
  }
}
