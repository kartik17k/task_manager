import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants/styles.dart';
import '../../service/authservice.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reset Password')),
      body: SafeArea(
        child: Padding(
          padding: AppStyles.screenPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Enter your email address to reset your password',
                  style: AppStyles.subtitle1,
                ),
                SizedBox(height: AppStyles.spacingL),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Please enter your email'
                      : null,
                ),
                SizedBox(height: AppStyles.spacingL),
                ElevatedButton(
                  style: AppStyles.primaryButton,
                  onPressed: _isLoading ? null : _handlePasswordReset,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Reset Password'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handlePasswordReset() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        await AuthService().resetPassword(_emailController.text.trim());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset email sent!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
}
