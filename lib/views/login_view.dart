import 'package:flutter/material.dart';
import 'register_view.dart';
import '../view_models/auth_view_model.dart';
import '../widgets/error_popup.dart';

class LoginView extends StatefulWidget {
  final AuthViewModel authViewModel;
  const LoginView({required this.authViewModel});
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController identifierController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  String? errorMessage;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Вход")),
      body: Stack(
        children: [
          loading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: identifierController,
                        decoration: InputDecoration(
                          labelText: "Логин или Email",
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? "Обязательное поле"
                                    : null,
                      ),
                      TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(labelText: "Пароль"),
                        obscureText: true,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? "Обязательное поле"
                                    : null,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              loading = true;
                              errorMessage = null;
                            });
                            String? error = await widget.authViewModel.login(
                              identifierController.text,
                              passwordController.text,
                            );
                            setState(() {
                              loading = false;
                            });
                            if (error == null) {
                              Navigator.pushReplacementNamed(context, '/home');
                            } else {
                              setState(() {
                                errorMessage = error;
                              });
                            }
                          }
                        },
                        child: Text("Войти"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      RegisterView(
                                        authViewModel: widget.authViewModel,
                                      ),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) => FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                            ),
                          );
                        },
                        child: Text("Нет аккаунта? Зарегистрируйтесь"),
                      ),
                    ],
                  ),
                ),
              ),
          if (errorMessage != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: ErrorPopup(
                message: errorMessage!,
                onClose: () => setState(() => errorMessage = null),
              ),
            ),
        ],
      ),
    );
  }
}
