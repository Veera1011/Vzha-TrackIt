import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/snackbar_util.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      SnackbarUtil.showError(context, 'Please enter both email and password.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_isSignUp) {
        await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
        );
        if (mounted) {
          SnackbarUtil.showSuccess(context, 'Registration successful! Please check your email for confirmation or sign in if auto-confirmed.');
          setState(() => _isSignUp = false); // switch to login
        }
      } else {
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        if (mounted) {
          SnackbarUtil.showSuccess(context, 'Signed in successfully.');
          context.go('/tenant-selection'); // Go to tenant selection after login
        }
      }
    } on AuthException catch (error) {
      if (mounted) SnackbarUtil.showError(context, error.message);
    } catch (error) {
      if (mounted) SnackbarUtil.showError(context, 'An unexpected error occurred.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isSignUp ? 'Create Account' : 'Sign In')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/images/App_log.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    _isSignUp ? Icons.person_add_alt_1 : Icons.lock_outline, 
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.password_outlined),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_isSignUp ? 'Sign Up' : 'Sign In'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() => _isSignUp = !_isSignUp);
                },
                child: Text(_isSignUp 
                  ? 'Already have an account? Sign In' 
                  : 'Need an account? Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
