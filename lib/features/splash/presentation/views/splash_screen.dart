import 'package:flutter/material.dart';
import 'dart:math';
import 'package:mecook_application/core/constants.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onSplashComplete;
  
  const SplashScreen({Key? key, required this.onSplashComplete}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _loopedController;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );
    
    _loopedController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
    
    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeIn),
      ),
    );
    
    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );
    
    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _loopedController,
        curve: Curves.easeInOut,
      ),
    );
    
    _mainController.forward();
    
    _mainController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 700), () {
          widget.onSplashComplete();
        });
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _loopedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_mainController, _loopedController]),
        builder: (context, child) {
          return Stack(
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
                top: -100,
                right: -100,
                child: Opacity(
                  opacity: _backgroundAnimation.value,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accentColor.withOpacity(0.08),
                    ),
                  ),
                ),
              ),
              
              Positioned(
                bottom: -120,
                left: -70,
                child: Opacity(
                  opacity: _backgroundAnimation.value,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accentOrange.withOpacity(0.06),
                    ),
                  ),
                ),
              ),
              
              ClipPath(
                clipper: WaveClipper(animationValue: _waveAnimation.value),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.5,
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
                        child: Opacity(
                          opacity: _backgroundAnimation.value,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: MediaQuery.of(context).size.height * 0.15,
                        left: MediaQuery.of(context).size.width * 0.15,
                        child: Opacity(
                          opacity: _backgroundAnimation.value,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 60),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FadeTransition(
                                opacity: _logoOpacityAnimation,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  padding: const EdgeInsets.all(20),
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
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Icon(
                                        Icons.restaurant_menu,
                                        size: 50,
                                        color: Colors.white,
                                      ),
                                      Positioned(
                                        bottom: 10,
                                        right: 10,
                                        child: Icon(
                                          Icons.food_bank_outlined,
                                          size: 30,
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              FadeTransition(
                                opacity: _fadeInAnimation,
                                child: const Text(
                                  "MeCook",
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: _fadeInAnimation.value,
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryColor,
                            ),
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "Идет загрузка ресурсов...",
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  final double animationValue;
  
  WaveClipper({this.animationValue = 0.0});
  
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.85);
    
    final waveOffset = sin(animationValue * 2 * pi) * 0.03;
    
    path.cubicTo(
      size.width * (0.15 + waveOffset), 
      size.height * (0.95 - waveOffset), 
      size.width * (0.35 + waveOffset), 
      size.height * (0.82 + waveOffset), 
      size.width * 0.5, 
      size.height * 0.85,
    );
    
    path.cubicTo(
      size.width * (0.65 - waveOffset), 
      size.height * (0.88 - waveOffset), 
      size.width * (0.85 - waveOffset), 
      size.height * (0.7 + waveOffset), 
      size.width, 
      size.height * 0.8,
    );
    
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(WaveClipper oldClipper) => oldClipper.animationValue != animationValue;
} 