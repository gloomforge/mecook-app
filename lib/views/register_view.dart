import 'package:flutter/material.dart';
import 'login_view.dart';
import '../view_models/auth_view_model.dart';
import '../widgets/error_popup.dart';

class RegisterView extends StatefulWidget {
  final AuthViewModel authViewModel;
  const RegisterView({required this.authViewModel});
  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  String? errorMessage;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Регистрация")),
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
                        controller: usernameController,
                        decoration: InputDecoration(
                          labelText: "Имя пользователя",
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? "Обязательное поле"
                                    : null,
                      ),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(labelText: "Email"),
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
                      TextFormField(
                        controller: confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: "Подтвердите пароль",
                        ),
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
                            String? error = await widget.authViewModel.register(
                              usernameController.text,
                              emailController.text,
                              passwordController.text,
                              confirmPasswordController.text,
                            );
                            setState(() {
                              loading = false;
                            });
                            if (error == null) {
                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => LoginView(
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
                            } else {
                              setState(() {
                                errorMessage = error;
                              });
                            }
                          }
                        },
                        child: Text("Зарегистрироваться"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      LoginView(
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
                        child: Text("Уже есть аккаунт? Войти"),
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
