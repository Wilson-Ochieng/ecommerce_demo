import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_app/constants/app_colors.dart';
import 'package:test_app/constants/theme_data.dart';
import 'package:test_app/ui/screens/auth/widgets/gradient_button.dart';
import 'package:test_app/ui/screens/viewmodels/register_viewmodel.dart';


class PhoneVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const PhoneVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState
    extends State<PhoneVerificationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _codeController =
      TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  // ============================================================
  // VERIFY OTP
  // ============================================================

  Future<void> _verifyCode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final viewModel =
        context.read<RegisterViewModel>();

    final success =
        await viewModel.verifyPhoneCode(
      smsCode: _codeController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Phone number verified successfully.',
          ),
        ),
      );

      // Navigate to the next screen.
      //
      // For example:
      //
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (_) =>
      //         const EmailVerificationScreen(),
      //   ),
      // );

      Navigator.pop(context, true);
    }
  }

  // ============================================================
  // RESEND OTP
  // ============================================================

  Future<void> _resendCode() async {
    final viewModel =
        context.read<RegisterViewModel>();

    final success =
        await viewModel.sendPhoneVerificationCode(
      phoneNumber: widget.phoneNumber,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A new verification code has been sent.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Verify Phone Number',
        ),
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: Container(
              width: double.infinity,

              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                gradient: Styles.cardGradient(
                  isDarkTheme: isDark,
                ),

                borderRadius:
                    BorderRadius.circular(16),

                border: Border.all(
                  color: isDark
                      ? AppColors.darkBorderColor
                      : AppColors.lightBorderColor,
                ),

                boxShadow: [
                  BoxShadow(
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    color: Colors.black.withValues(
                      alpha: 0.08,
                    ),
                  ),
                ],
              ),

              child: Form(
                key: _formKey,

                child: Column(
                  children: [
                    // ==================================================
                    // PHONE ICON
                    // ==================================================

                    Container(
                      width: 70,
                      height: 70,

                      decoration: BoxDecoration(
                        gradient:
                            Styles.primaryGradient(
                          isDarkTheme: isDark,
                        ),

                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.phone_android,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ==================================================
                    // TITLE
                    // ==================================================

                    Text(
                      'Verify Your Phone',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium,
                    ),

                    const SizedBox(height: 10),

                    // ==================================================
                    // DESCRIPTION
                    // ==================================================

                    Text(
                      'We sent a 6-digit verification code to:',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium,
                    ),

                    const SizedBox(height: 8),

                    // ==================================================
                    // PHONE NUMBER
                    // ==================================================

                    Text(
                      widget.phoneNumber,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.lightPrimary,
                          ),
                    ),

                    const SizedBox(height: 30),

                    // ==================================================
                    // OTP FIELD
                    // ==================================================

                    TextFormField(
                      controller:
                          _codeController,

                      keyboardType:
                          TextInputType.number,

                      textAlign: TextAlign.center,

                      maxLength: 6,

                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            letterSpacing: 8,
                            fontWeight:
                                FontWeight.w700,
                          ),

                      decoration:
                          const InputDecoration(
                        labelText:
                            'Verification Code',

                        hintText:
                            '000000',

                        prefixIcon: Icon(
                          Icons.lock_outline,
                        ),

                        counterText: '',
                      ),

                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Enter the verification code';
                        }

                        if (value.trim().length !=
                            6) {
                          return 'Code must contain 6 digits';
                        }

                        if (!RegExp(
                          r'^[0-9]+$',
                        ).hasMatch(
                          value.trim(),
                        )) {
                          return 'Enter numbers only';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // ==================================================
                    // ERROR MESSAGE
                    // ==================================================

                    Consumer<RegisterViewModel>(
                      builder: (
                        context,
                        viewModel,
                        child,
                      ) {
                        if (viewModel
                                .errorMessage ==
                            null) {
                          return const SizedBox
                              .shrink();
                        }

                        return Padding(
                          padding:
                              const EdgeInsets.only(
                            bottom: 16,
                          ),

                          child: Text(
                            viewModel
                                .errorMessage!,
                            textAlign:
                                TextAlign.center,

                            style: TextStyle(
                              color: Theme.of(
                                context,
                              )
                                  .colorScheme
                                  .error,

                              fontSize: 13,
                            ),
                          ),
                        );
                      },
                    ),

                    // ==================================================
                    // VERIFY BUTTON
                    // ==================================================

                    Consumer<RegisterViewModel>(
                      builder: (
                        context,
                        viewModel,
                        child,
                      ) {
                        return GradientButton(
                          text: 'VERIFY PHONE',
                          isLoading:
                              viewModel.isLoading,
                          onPressed:
                              _verifyCode,
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // RESEND CODE
                    // ==================================================

                    Consumer<RegisterViewModel>(
                      builder: (
                        context,
                        viewModel,
                        child,
                      ) {
                        return TextButton(
                          onPressed:
                              viewModel.isLoading
                                  ? null
                                  : _resendCode,

                          child: const Text(
                            'Did not receive the code? Resend',
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

