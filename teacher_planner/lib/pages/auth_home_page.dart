import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import 'home_page.dart';
import 'database_test_page.dart';

class AuthHomePage extends StatefulWidget {
  @override
  _AuthHomePageState createState() => _AuthHomePageState();
}

class _AuthHomePageState extends State<AuthHomePage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _schoolController = TextEditingController();
  final _roleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _animationController, curve: Curves.easeOutCubic));
    _animationController.forward();
    _checkAuthStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _schoolController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    final auth = await AuthService.instance.isAuthenticated();
    if (auth) _navigateToMainApp();
  }

  void _navigateToMainApp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomePage()),
    );
  }

  void _navigateToDatabaseTest() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DatabaseTestPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-screen background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/login_background.png',
              fit: BoxFit.cover,
            ),
          ),
          // Login form positioned over the background
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            left: 24,
            right: 24,
            child: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildAuthCard(),
                        SizedBox(height: 24),
                        _buildToggleButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthCard() {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: 400),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isLogin ? 'Welcome Back' : 'Create Account',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              _isLogin ? 'Sign in to continue' : 'Join thousands of teachers',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 24),
            if (!_isLogin) ...[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: InputDecoration(labelText: 'First Name'),
                      validator: (val) => val!.isEmpty ? 'Enter first name' : null,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      decoration: InputDecoration(labelText: 'Last Name'),
                      validator: (val) => val!.isEmpty ? 'Enter last name' : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
            ],
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              validator: (val) => val!.isEmpty ? 'Enter email' : null,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (val) {
                if (val == null || val.isEmpty) return 'Enter password';
                if (!_isLogin && val.length < 8) return 'Min 8 chars';
                return null;
              },
            ),
            SizedBox(height: 16),
            if (!_isLogin) ...[
              TextFormField(
                controller: _schoolController,
                decoration: InputDecoration(labelText: 'School (Optional)'),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _roleController.text.isEmpty ? null : _roleController.text,
                items: [
                  DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                  DropdownMenuItem(value: 'admin', child: Text('Administrator')),
                  DropdownMenuItem(value: 'principal', child: Text('Principal')),
                  DropdownMenuItem(value: 'assistant', child: Text('Assistant')),
                ],
                onChanged: (v) => setState(() => _roleController.text = v!),
                decoration: InputDecoration(labelText: 'Role'),
                validator: (val) => val == null ? 'Select role' : null,
              ),
              SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(_isLogin ? 'Sign In' : 'Create'),
              ),
            ),
            SizedBox(height: 12),
            if (_isLogin)
              Center(
                child: TextButton(
                  onPressed: _showForgotPasswordDialog,
                  child: Text('Forgot Password?'),
                ),
              ),
            SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: _navigateToDatabaseTest,
                child: Text('Test DB Connection'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final emailCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Password'),
        content: TextFormField(
          controller: emailCtrl,
          decoration: InputDecoration(labelText: 'Email'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _sendPasswordResetEmail(emailCtrl.text.trim());
            },
            child: Text('Send'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendPasswordResetEmail(String email) async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Reset email sent')));
    } catch (_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error sending email')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final res = _isLogin
          ? await AuthService.instance.login(
              email: _emailController.text.trim(),
              password: _passwordController.text)
          : await AuthService.instance.register(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              school: _schoolController.text.trim(),
              role: _roleController.text.trim());
      if (res.success) _navigateToMainApp();
      else
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(res.error ?? 'Failed')));
    } catch (_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error occurred')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildToggleButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(_isLogin
            ? "Don't have an account? "
            : "Already have an account? "),
        GestureDetector(
          onTap: () => setState(() {
            _isLogin = !_isLogin;
            _formKey.currentState!.reset();
          }),
          child: Text(
            _isLogin ? 'Sign Up' : 'Sign In',
            style: TextStyle(decoration: TextDecoration.underline),
          ),
        )
      ],
    );
  }
}
