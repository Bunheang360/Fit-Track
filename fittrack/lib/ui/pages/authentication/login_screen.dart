import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../utils/snackbar_utils.dart';
import 'signup_screen.dart';
import '../home/home_screen.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  /// FORM CONTROLLERS
  final _formKey = GlobalKey<FormState>();
  final _focusNodePassword = FocusNode();
  final _controllerUsername = TextEditingController();
  final _controllerPassword = TextEditingController();

  // STATE VARIABLES
  bool _hidePassword = true; // Toggle password visibility

  // SERVICE (for business logic)
  final _authService = AuthService();

  // LOGIN LOGIC
  Future<void> _handleLogin() async {
    // 1: Validate form fields
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // 2: Get username and password from text fields
    final username = _controllerUsername.text;
    final password = _controllerPassword.text;

    // 3: Attempt login via service
    final result = await _authService.login(username, password);

    // 4: Handle login result
    if (result.isSuccess) {
      _onLoginSuccess();
    } else {
      _onLoginFailed(result.errorMessage ?? 'Login failed');
    }
  }

  // LOGIN SUCCESS - Navigate to home
  void _onLoginSuccess() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  // LOGIN FAILED - Show error message
  void _onLoginFailed(String message) {
    if (mounted) {
      context.showError(message);
    }
  }

  // TOGGLE PASSWORD VISIBILITY
  void _togglePasswordVisibility() {
    setState(() {
      _hidePassword = !_hidePassword;
    });
  }

  // NAVIGATE TO SIGNUP
  void _goToSignup() {
    _formKey.currentState?.reset();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Signup()),
    );
  }

  // CLEANUP
  @override
  void dispose() {
    _focusNodePassword.dispose();
    _controllerUsername.dispose();
    _controllerPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 360;
    final padding = isSmall ? 20.0 : 30.0;
    final logoSize = (screenWidth * 0.3).clamp(80.0, 120.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                Center(
                  child: Image(
                    image: const AssetImage('assets/images/logo.png'),
                    width: logoSize,
                    height: logoSize,
                  ),
                ),
                SizedBox(height: isSmall ? 20 : 30),

                // Login title
                Text(
                  "Login",
                  style: TextStyle(
                    fontSize: isSmall ? 24 : 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: isSmall ? 20 : 30),

                // Username field
                Text(
                  "Username",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _controllerUsername,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    hintText: "Enter your username",
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  onEditingComplete: () => _focusNodePassword.requestFocus(),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter username.";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password field
                Text(
                  "Password",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _controllerPassword,
                  focusNode: _focusNodePassword,
                  obscureText: _hidePassword,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    hintText: "Enter your password",
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    suffixIcon: IconButton(
                      onPressed: _togglePasswordVisibility,
                      icon: Icon(
                        _hidePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter password.";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // Login button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[800],
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _handleLogin,
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Sign up link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account ? ",
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      GestureDetector(
                        onTap: _goToSignup,
                        child: Text(
                          "Register",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
