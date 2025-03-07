import 'package:flutter/material.dart';
import 'package:mecook_application/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:mecook_application/core/constants.dart';
import 'register_view.dart';
import 'package:mecook_application/common_widgets/error_popup.dart';
import 'dart:ui';

class LoginView extends StatefulWidget {
  final AuthViewModel authViewModel;
  const LoginView({Key? key, required this.authViewModel}) : super(key: key);

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with SingleTickerProviderStateMixin {
  final TextEditingController identifierController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  String? errorMessage;
  bool _obscurePassword = true;
  Map<String, String> fieldErrors = {};
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.backgroundColor,
                  AppColors.backgroundColor,
                  Color(0xFFEBF4F3),
                ],
              ),
            ),
          ),
          
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentColor.withOpacity(0.08),
              ),
            ),
          ),
          
          Positioned(
            bottom: -100,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentOrange.withOpacity(0.06),
              ),
            ),
          ),
          
          ClipPath(
            clipper: _WaveClipper(),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.26,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryColor,
                    AppColors.accentColor,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.05,
                    right: MediaQuery.of(context).size.width * 0.1,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.15,
                    left: MediaQuery.of(context).size.width * 0.2,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Hero(
                            tag: 'authIcon',
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    spreadRadius: 0,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.lock_outline_rounded,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Hero(
                            tag: 'authTitle',
                            child: Material(
                              color: Colors.transparent,
                              child: const Text(
                                "Вход",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.20,
                  left: 16,
                  right: 16,
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Card(
                      elevation: 4,
                      shadowColor: Colors.black.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 32),
                              
                              if (errorMessage != null)
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  margin: EdgeInsets.only(bottom: 20),
                                  decoration: BoxDecoration(
                                    color: AppColors.errorColor.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.errorColor.withOpacity(0.5),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline_rounded,
                                        color: AppColors.errorColor,
                                        size: 20,
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          errorMessage!,
                                          style: TextStyle(
                                            color: AppColors.errorColor,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: _clearErrors,
                                        child: Icon(
                                          Icons.close,
                                          color: AppColors.errorColor.withOpacity(0.7),
                                          size: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              
                              _buildInputLabel("Логин или Email"),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: identifierController,
                                hintText: "Введите ваш логин или email",
                                icon: Icons.person_outline,
                                errorText: fieldErrors['identifier'],
                                onChanged: (value) {
                                  if (fieldErrors.containsKey('identifier')) {
                                    setState(() {
                                      fieldErrors.remove('identifier');
                                    });
                                  }
                                },
                                validator: (value) =>
                                    (value == null || value.isEmpty)
                                        ? "Обязательное поле"
                                        : null,
                              ),
                              
                              const SizedBox(height: 24),
                              
                              _buildInputLabel("Пароль"),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: passwordController,
                                hintText: "Введите ваш пароль",
                                icon: Icons.lock_outline,
                                obscureText: _obscurePassword,
                                showPasswordToggle: true,
                                errorText: fieldErrors['password'],
                                onChanged: (value) {
                                  if (fieldErrors.containsKey('password')) {
                                    setState(() {
                                      fieldErrors.remove('password');
                                    });
                                  }
                                },
                                onPasswordVisibilityChanged: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                validator: (value) =>
                                    (value == null || value.isEmpty)
                                        ? "Обязательное поле"
                                        : null,
                              ),
                              
                              const SizedBox(height: 24),
                              
                              _buildLoginButton(),
                              
                              const SizedBox(height: 16),
                              
                              Center(
                                child: Hero(
                                  tag: 'loginLink',
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () => _navigateToRegister(),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: "Нет аккаунта? ",
                                                style: TextStyle(
                                                  color: AppColors.textSecondaryColor,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              TextSpan(
                                                text: "Зарегистрируйтесь",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.accentColor,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          if (loading)
            Container(
              color: Colors.black26,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Вход в аккаунт...",
                          style: TextStyle(
                            color: AppColors.textPrimaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryColor,
        fontSize: 15,
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    bool showPasswordToggle = false,
    Function(String)? onChanged,
    VoidCallback? onPasswordVisibilityChanged,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    String? errorText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: TextStyle(
              color: AppColors.textPrimaryColor,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: AppColors.textSecondaryColor.withOpacity(0.7),
              ),
              prefixIcon: Icon(
                icon,
                color: errorText != null ? AppColors.errorColor : AppColors.secondaryColor,
              ),
              suffixIcon: showPasswordToggle
                  ? IconButton(
                      icon: Icon(
                        obscureText
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.secondaryColor,
                      ),
                      onPressed: onPasswordVisibilityChanged,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              filled: true,
              fillColor: errorText != null 
                  ? AppColors.errorColor.withOpacity(0.05) 
                  : Colors.white,
              isDense: true,
              errorStyle: TextStyle(
                color: AppColors.errorColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.errorColor.withOpacity(0.5),
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.errorColor,
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: errorText != null 
                    ? BorderSide(
                        color: AppColors.errorColor.withOpacity(0.5),
                        width: 1,
                      )
                    : BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: errorText != null 
                    ? BorderSide(
                        color: AppColors.errorColor,
                        width: 1.5,
                      )
                    : BorderSide(
                        color: AppColors.primaryColor.withOpacity(0.5),
                        width: 1.5,
                      ),
              ),
            ),
            validator: validator,
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppColors.errorColor,
                    size: 14,
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      errorText,
                      style: TextStyle(
                        color: AppColors.errorColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildTextLink({
    required String text,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.primaryColor,
            AppColors.accentColor,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _loginUser,
          child: Center(
            child: const Text(
              "Войти",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  void _clearErrors() {
    setState(() {
      errorMessage = null;
      fieldErrors = {};
    });
  }
  
  Future<void> _loginUser() async {
    _clearErrors();
    
    if (_formKey.currentState!.validate()) {
      setState(() {
        loading = true;
      });
      
      final error = await widget.authViewModel.login(
        identifierController.text,
        passwordController.text,
      );
      
      setState(() {
        loading = false;
      });
      
      if (error == null) {
        await _animationController.reverse();
        Navigator.pushReplacementNamed(context, '/home');
      } else if (error.toLowerCase().contains("нет подключения") || 
                error.toLowerCase().contains("соединение") ||
                error == "no_connection") {
        setState(() {
          errorMessage = "Нет подключения к интернету. Проверьте соединение и попробуйте снова.";
        });
      } else {
        _parseErrorMessage(error);
      }
    }
  }
  
  void _navigateToRegister() async {
    await _animationController.reverse();
    
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => RegisterView(
          authViewModel: widget.authViewModel,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          
          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 500),
      ),
    ).then((_) {
      _animationController.forward();
    });
  }

  void _parseErrorMessage(String error) {
    setState(() {
      fieldErrors.clear();
      errorMessage = null;
      
    final errorLower = error.toLowerCase();
      if (errorLower.contains('пользователь не найден') || 
          errorLower.contains('не существует') ||
          errorLower.contains('неверный email') ||
          errorLower.contains('user not found') ||
          errorLower.contains('not found') ||
          errorLower.contains('не найден')) {
        fieldErrors['identifier'] = "Пользователь с такими данными не найден";
      } 
      
      else if (errorLower.contains('неверный логин или пароль') ||
               errorLower.contains('incorrect login or password') ||
               errorLower.contains('invalid credentials') ||
               errorLower.contains('неверные учетные данные')) {
        fieldErrors['identifier'] = "Проверьте правильность ввода";
        fieldErrors['password'] = "Проверьте правильность ввода";
      } 
      
      else if (errorLower.contains('неверный пароль') || 
               errorLower.contains('неправильный пароль') ||
               errorLower.contains('wrong password') ||
               errorLower.contains('incorrect password')) {
        fieldErrors['password'] = "Неверный пароль";
      } 
      
      else if (errorLower.contains('блокирован') || 
               errorLower.contains('заблокирован') ||
               errorLower.contains('blocked') ||
               errorLower.contains('forbidden') ||
               errorLower.contains('доступ запрещен')) {
        errorMessage = "Аккаунт заблокирован. Пожалуйста, обратитесь в службу поддержки.";
      } 
      
      else if (errorLower.contains('подключение') || 
               errorLower.contains('соединение') ||
               errorLower.contains('connection')) {
        errorMessage = "Проблема с подключением к серверу. Проверьте интернет и попробуйте снова.";
      } 
      
      else if (errorLower.contains('ошибка сервера') || 
               errorLower.contains('server error') ||
               errorLower.contains('500') || 
               errorLower.contains('502') ||
               errorLower.contains('503')) {
        errorMessage = "Внутренняя ошибка сервера. Пожалуйста, попробуйте позже.";
      }
      
      else if (errorLower.contains('подтверждение email') || 
               errorLower.contains('verify email') ||
               errorLower.contains('подтвердите')) {
        errorMessage = "Необходимо подтвердить ваш email. Проверьте почтовый ящик.";
      }
      
      else {
        errorMessage = error;
      }
    });
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.85);
    
    path.cubicTo(
      size.width * 0.15, 
      size.height * 0.95, 
      size.width * 0.35, 
      size.height * 0.82, 
      size.width * 0.5, 
      size.height * 0.85,
    );
    
    path.cubicTo(
      size.width * 0.65, 
      size.height * 0.88, 
      size.width * 0.85, 
      size.height * 0.7, 
      size.width, 
      size.height * 0.8,
    );
    
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

