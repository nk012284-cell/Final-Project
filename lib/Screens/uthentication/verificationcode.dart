import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobil_app_project/Screens/uthentication/createnewpassword.dart';
import 'package:mobil_app_project/network/apiservices.dart';
import 'package:mobil_app_project/network/networkclient.dart';
import 'package:pinput/pinput.dart';

class Verification extends StatefulWidget {
  final String email;

  const Verification({super.key, required this.email});

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  final TextEditingController _otpController = TextEditingController();
  final ApiServices api = ApiServices(NetworkClient());

  Timer? _timer;
  int _secondsRemaining = 56;
  bool _isVerifying = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = 56;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        if (mounted) {
          setState(() {
            _secondsRemaining--;
          });
        }
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  // Verify OTP API Method
  Future<void> _verifyOtp(String code) async {
    if (_isVerifying) return;

    setState(() {
      _isVerifying = true;
    });

    try {
      final response = await api.verifyotpresponse({
        "email": widget.email,
        "code": code,
      });

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resetTicket = response.data is Map<String, dynamic>
            ? response.data["resetTicket"]?.toString()
            : null;

        if (resetTicket == null || resetTicket.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid reset response from server")),
          );
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP verified successfully!")),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return CreateNewPassword(ticket: resetTicket);
            },
          ),
        );
        // TODO: Navigate to Next Screen (e.g. Reset Password Screen)
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.data?["message"]?.toString() ?? "Invalid or expired OTP",
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString().replaceAll('Exception:', '')}"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  // Resend OTP API Method
  Future<void> _resendCode() async {
    if (_secondsRemaining > 0 || _isResending) return;

    setState(() {
      _isResending = true;
    });

    try {
      final response = await api.forgetopassword({"email": widget.email});

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP resent successfully!")),
        );
        _startTimer();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to resend OTP")));
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to resend OTP. Try again.")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Custom Styling for Pinput Boxes
    final defaultPinTheme = PinTheme(
      width: 60,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: const Color(0xFFE8F5E9),
        border: Border.all(color: const Color(0xFF138048), width: 1.5),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: const Color(0xFFE8F5E9),
        border: Border.all(color: const Color(0xFF138048), width: 1),
      ),
    );

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Title
              const Text(
                "Enter Verification Code",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                "We have sent a verification code to ${widget.email}",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 36),

              // Pinput Widget (Defaulting to 4 Digits)
              Center(
                child: Pinput(
                  controller: _otpController,
                  length: 6, // 4-digit OTP support
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  submittedPinTheme: submittedPinTheme,
                  enabled: !_isVerifying,
                  onCompleted: _verifyOtp,
                ),
              ),
              const SizedBox(height: 36),

              // Resend Code & Countdown Timer
              Center(
                child: Column(
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        children: [
                          const TextSpan(text: "You can resend the code in "),
                          TextSpan(
                            text: "$_secondsRemaining",
                            style: const TextStyle(
                              color: Color(0xFF138048),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(text: " seconds"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _secondsRemaining == 0 ? _resendCode : null,
                      child: _isResending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF138048),
                              ),
                            )
                          : Text(
                              "Resend Code",
                              style: TextStyle(
                                color: _secondsRemaining == 0
                                    ? const Color(0xFF138048)
                                    : const Color(0xFF138048).withValues(alpha: 0.5),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
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
    );
  }
}
