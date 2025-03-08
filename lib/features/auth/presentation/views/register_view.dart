import 'package:flutter/material.dart';
import 'package:mecook_application/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:mecook_application/core/constants.dart';
import 'package:mecook_application/common_widgets/error_popup.dart';
import 'dart:ui';

class RegisterView extends StatefulWidget {
  final AuthViewModel authViewModel;
  const RegisterView({Key? key, required this.authViewModel}) : super(key: key);

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> with SingleTickerProviderStateMixin {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool loading = false;
  String? errorMessage;
  Map<String, String> fieldErrors = {}; 
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  
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

  void _clearErrors() {
    setState(() {
      errorMessage = null;
      fieldErrors = {};
    });
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
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.12,
                    left: MediaQuery.of(context).size.width * 0.2,
                    child: Container(
                      width: 30,
                      height: 30,
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
                              padding: const EdgeInsets.all(12),
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
                                Icons.person_add_outlined,
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
                    "Регистрация",
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
                              
                              _buildInputLabel("Имя пользователя"),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: usernameController,
                                hintText: "Введите имя пользователя",
                                icon: Icons.person_outline,
                                errorText: fieldErrors['username'],
                                onChanged: (value) {
                                  if (fieldErrors.containsKey('username')) {
                                    setState(() {
                                      fieldErrors.remove('username');
                                    });
                                  }
                                },
                                validator: (value) =>
                              (value == null || value.isEmpty)
                                  ? "Обязательное поле"
                                  : null,
                    ),
                              
                    const SizedBox(height: 16),
                              
                              _buildInputLabel("Email"),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: emailController,
                                hintText: "Введите ваш email",
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                errorText: fieldErrors['email'],
                                onChanged: (value) {
                                  if (fieldErrors.containsKey('email')) {
                                    setState(() {
                                      fieldErrors.remove('email');
                                    });
                                  }
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Обязательное поле";
                                  }
                                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                  if (!emailRegex.hasMatch(value)) {
                                    return "Введите корректный email";
                                  }
                                  return null;
                                },
                              ),
                              
                              const SizedBox(height: 16),
                              
                              _buildInputLabel("Пароль"),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: passwordController,
                                hintText: "Минимум 6 символов",
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
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Обязательное поле";
                                  }
                                  if (value.length < 6) {
                                    return "Минимум 6 символов";
                                  }
                                  return null;
                                },
                              ),
                              
                              const SizedBox(height: 16),
                              
                              _buildInputLabel("Подтверждение пароля"),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: confirmPasswordController,
                                hintText: "Повторите пароль",
                                icon: Icons.lock_outline,
                                obscureText: _obscureConfirmPassword,
                                showPasswordToggle: true,
                                errorText: fieldErrors['confirm_password'],
                                onChanged: (value) {
                                  if (fieldErrors.containsKey('confirm_password')) {
                              setState(() {
                                      fieldErrors.remove('confirm_password');
                                    });
                                  }
                                },
                                onPasswordVisibilityChanged: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Обязательное поле";
                                  }
                                  if (value != passwordController.text) {
                                    return "Пароли не совпадают";
                                  }
                                  return null;
                                },
                              ),
                              
                              const SizedBox(height: 16),
                              
                              Theme(
                                data: Theme.of(context).copyWith(
                                  checkboxTheme: CheckboxThemeData(
                          shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Checkbox(
                                        value: _acceptTerms,
                                        activeColor: AppColors.primaryColor,
                                        onChanged: (value) {
                                          setState(() {
                                            _acceptTerms = value ?? false;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "Я согласен на обработку персональных данных",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textSecondaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (fieldErrors.containsKey('terms'))
                                Padding(
                                  padding: const EdgeInsets.only(top: 8, left: 36),
                                  child: Text(
                                    fieldErrors['terms']!,
                                    style: TextStyle(
                                      color: AppColors.errorColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              
                              const SizedBox(height: 24),
                              
                              _buildRegisterButton(),
                              
                              const SizedBox(height: 16),
                              Center(
                                child: Hero(
                                  tag: 'loginLink',
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: "Уже есть аккаунт? ",
                                                style: TextStyle(
                                                  color: AppColors.textSecondaryColor,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              TextSpan(
                                                text: "Войти",
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
                          "Создание аккаунта...",
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
        fontSize: 14,
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
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            spreadRadius: 0,
            offset: Offset(0, 1),
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
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: AppColors.textSecondaryColor.withOpacity(0.7),
              ),
              prefixIcon: Icon(
                icon,
                color: errorText != null ? AppColors.errorColor : AppColors.secondaryColor,
                size: 20,
              ),
              suffixIcon: showPasswordToggle
                  ? IconButton(
                      icon: Icon(
                        obscureText
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.secondaryColor,
                        size: 20,
                      ),
                      onPressed: onPasswordVisibilityChanged,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 14,
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
  
  Widget _buildRegisterButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: _acceptTerms 
              ? [AppColors.primaryColor, AppColors.accentColor]
              : [Colors.grey.shade400, Colors.grey.shade400],
        ),
        boxShadow: _acceptTerms 
            ? [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _acceptTerms ? _registerUser : () {
            setState(() {
              fieldErrors['terms'] = "Необходимо согласиться с условиями";
            });
          },
          child: Center(
            child: Text(
              "Зарегистрироваться",
              style: TextStyle(
                fontSize: 16,
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
  
  void _parseErrorMessage(String error) {
    setState(() {
      fieldErrors.clear();
      errorMessage = null;
      
      final errorLower = error.toLowerCase();
      
      if (errorLower.contains('username already exists') || 
          errorLower.contains('username is already taken') ||
          errorLower.contains('пользователь') && errorLower.contains('уже существует') ||
          errorLower.contains('имя пользователя') && errorLower.contains('уже занято')) {
        fieldErrors['username'] = "Пользователь с таким именем уже существует";
      } 
      else if (errorLower.contains('username') && errorLower.contains('invalid') ||
               errorLower.contains('имя пользователя') && errorLower.contains('недопустим')) {
        fieldErrors['username'] = "Имя пользователя содержит недопустимые символы";
      }
      else if (errorLower.contains('username') && errorLower.contains('too short') || 
               errorLower.contains('имя пользователя') && errorLower.contains('короткое')) {
        fieldErrors['username'] = "Имя пользователя слишком короткое (минимум 3 символа)";
      }
      else if (errorLower.contains('username') && errorLower.contains('too long') || 
               errorLower.contains('имя пользователя') && errorLower.contains('длинное')) {
        fieldErrors['username'] = "Имя пользователя слишком длинное (максимум 30 символов)";
      }
      
      else if (errorLower.contains('email already exists') || 
               errorLower.contains('email is already registered') ||
               errorLower.contains('email') && errorLower.contains('уже') && 
              (errorLower.contains('существует') || errorLower.contains('зарегистрирован'))) {
        fieldErrors['email'] = "Этот email уже зарегистрирован";
      } 
      else if (errorLower.contains('email') && 
              (errorLower.contains('invalid') || errorLower.contains('некорректный') || 
               errorLower.contains('неверный'))) {
        fieldErrors['email'] = "Неверный формат email";
      } 
      
      else if (errorLower.contains('password') && errorLower.contains('short') || 
               errorLower.contains('пароль') && errorLower.contains('короткий')) {
        fieldErrors['password'] = "Пароль должен содержать не менее 6 символов";
      } 
      else if (errorLower.contains('password') && 
              (errorLower.contains('weak') || errorLower.contains('simple')) || 
               errorLower.contains('пароль') && 
              (errorLower.contains('слабый') || errorLower.contains('простой'))) {
        fieldErrors['password'] = "Пароль должен содержать буквы и цифры";
      } 
      else if (errorLower.contains('password') && errorLower.contains('match') || 
               errorLower.contains('пароль') && errorLower.contains('совпад')) {
        fieldErrors['confirm_password'] = "Пароли не совпадают";
      } 
      
      else if (errorLower.contains('connection') || 
               errorLower.contains('connectivity') || 
               errorLower.contains('connect') ||
               errorLower.contains('подключ') || 
               errorLower.contains('соедин') ||
               error == "no_connection") {
        errorMessage = "Проблема с подключением к серверу. Проверьте интернет и попробуйте снова.";
      } 
      
      else if (errorLower.contains('server error') || 
               errorLower.contains('internal error') ||
               errorLower.contains('ошибка сервера') ||
               errorLower.contains('500') || 
               errorLower.contains('502') ||
               errorLower.contains('503')) {
        errorMessage = "Внутренняя ошибка сервера. Пожалуйста, попробуйте позже.";
      }
      
      else if (errorLower.contains('terms') || 
               errorLower.contains('agreement') ||
               errorLower.contains('согласи') || 
               errorLower.contains('услови')) {
        fieldErrors['terms'] = "Для регистрации необходимо принять условия";
      }
      
      else {
        errorMessage = error;
      }
    });
  }
  
  Future<void> _registerUser() async {
    if (!_acceptTerms) {
      setState(() {
        fieldErrors['terms'] = "Необходимо согласиться с условиями";
      });
      return;
    }
    
    _clearErrors();
    
    if (!_validateFormBeforeSubmit()) {
      return;
    }
    
    if (_formKey.currentState!.validate()) {
      setState(() {
        loading = true;
      });
      
      try {
        String? error = await widget.authViewModel.register(
          usernameController.text.trim(),
          emailController.text.trim(),
          passwordController.text,
          confirmPasswordController.text,
        );
        
        if (mounted) {
          setState(() {
            loading = false;
          });
          
          if (error == null) {
            await _animationController.reverse();
            Navigator.pushReplacementNamed(context, '/home');
          } else if (error.toLowerCase().contains("нет подключения") || 
                    error.toLowerCase().contains("соединение") ||
                    error.toLowerCase().contains("connection") ||
                    error == "no_connection") {
            Navigator.pushReplacementNamed(context, '/noConnection');
          } else {
            _parseErrorMessage(error);
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            loading = false;
            errorMessage = "Произошла непредвиденная ошибка. Пожалуйста, попробуйте позже.";
          });
        }
      }
    }
  }
  
  bool _validateFormBeforeSubmit() {
    bool isValid = true;
    
    if (usernameController.text.trim().length < 3) {
      setState(() {
        fieldErrors['username'] = "Имя пользователя должно содержать минимум 3 символа";
      });
      isValid = false;
    } else if (usernameController.text.trim().length > 30) {
      setState(() {
        fieldErrors['username'] = "Имя пользователя должно быть не более 30 символов";
      });
      isValid = false;
    } else if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(usernameController.text.trim())) {
      setState(() {
        fieldErrors['username'] = "Имя пользователя может содержать только буквы, цифры и знак подчеркивания";
      });
      isValid = false;
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(emailController.text.trim())) {
      setState(() {
        fieldErrors['email'] = "Некорректный формат email";
      });
      isValid = false;
    }
    
    if (passwordController.text.length < 6) {
      setState(() {
        fieldErrors['password'] = "Пароль должен содержать минимум 6 символов";
      });
      isValid = false;
    } else if (!RegExp(r'[A-Za-z]').hasMatch(passwordController.text) || 
              !RegExp(r'[0-9]').hasMatch(passwordController.text)) {
      setState(() {
        fieldErrors['password'] = "Пароль должен содержать как минимум одну букву и одну цифру";
      });
      isValid = false;
    }
    
    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        fieldErrors['confirm_password'] = "Пароли не совпадают";
      });
      isValid = false;
    }
    
    return isValid;
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

