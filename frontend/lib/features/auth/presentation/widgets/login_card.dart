import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/helpdesk_theme_tokens.dart';
import '../bloc/auth_state.dart';

class LoginCard extends StatefulWidget {
  final AuthState authState;
  final void Function(String username, String password) onSubmit;

  const LoginCard({
    super.key,
    required this.authState,
    required this.onSubmit,
  });

  @override
  State<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(
        _usernameController.text,
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLoading = widget.authState is AuthLoading;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: tokens.cardBorder),
        ),
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Brand Header
                Center(
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, Color(0xFF4F46E5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Helpdesk Admin',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'AI Customer Management Portal',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: tokens.subtleText,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Error alert
                if (widget.authState is AuthFailure) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: tokens.statusEscalated.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: tokens.statusEscalated.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: tokens.statusEscalated,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            (widget.authState as AuthFailure).message,
                            style: TextStyle(
                              color: tokens.statusEscalated,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],

                // Username field
                TextFormField(
                  controller: _usernameController,
                  enabled: !isLoading,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    hintText: 'admin',
                    prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  enabled: !isLoading,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 18,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Submit button
                ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
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
