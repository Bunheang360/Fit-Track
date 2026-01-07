import 'package:flutter/material.dart';
import '../data/repositories/settings_repository.dart';
import '../data/database/database_helper.dart';
import 'pages/authentication/login_screen.dart';
import 'pages/home/home_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with SingleTickerProviderStateMixin {
  // Animation controller manages the animation timing
  late AnimationController _animationController;

  // Fade animation: logo goes from invisible (0) to visible (1)
  late Animation<double> _fadeAnimation;

  // Scale animation: logo grows from 80% to 100% size
  late Animation<double> _scaleAnimation;

  // Flag to prevent navigating multiple times if user taps repeatedly
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSplashTimer();
  }

  // Set up the fade and scale animations for the logo
  void _setupAnimations() {
    // Create animation controller (1.5 seconds duration)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Fade animation: 0.0 (invisible) to 1.0 (fully visible)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Scale animation: 0.8 (80% size) to 1.0 (full size)
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack, // Gives a nice "bounce" effect
      ),
    );

    // Start the animation
    _animationController.forward();
  }

  // Wait for splash duration, then navigate to next screen
  Future<void> _startSplashTimer() async {
    try {
      // Initialize the database while showing splash
      await DatabaseHelper.instance.database;

      // Wait 4 seconds for user to see the logo
      await Future.delayed(const Duration(seconds: 4));

      // Navigate to the appropriate screen
      _goToNextScreen();
    } catch (e) {
      // If something goes wrong, go to login screen
      _goToLoginScreen();
    }
  }

  // Called when user taps the screen to skip intro
  void _skipIntro() {
    if (_isNavigating) return; // Already navigating, ignore tap
    _goToNextScreen();
  }

  // Navigate to Home or Login based on login status
  Future<void> _goToNextScreen() async {
    // Prevent multiple navigations
    if (_isNavigating || !mounted) return;
    _isNavigating = true;

    try {
      // Check if user is logged in
      final settings = SettingsRepository();
      final isLoggedIn = await settings.isLoggedIn();

      if (!mounted) return;

      // Choose which screen to show
      final nextScreen = isLoggedIn ? const HomeScreen() : const Login();

      // Navigate with a fade transition
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } catch (e) {
      _goToLoginScreen();
    }
  }

  // Go directly to login screen (used when errors occur)
  void _goToLoginScreen() {
    if (!mounted || _isNavigating) return;
    _isNavigating = true;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoSize = (screenWidth * 0.45).clamp(120.0, 220.0);

    return Scaffold(
      backgroundColor: Colors.white,
      // GestureDetector makes the whole screen tappable
      body: GestureDetector(
        onTap: _skipIntro,
        behavior: HitTestBehavior.opaque, // Detect taps on empty areas too
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: logoSize,
                    // Show fallback icon if image fails to load
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.fitness_center,
                      size: logoSize,
                      color: Colors.orange[800],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
