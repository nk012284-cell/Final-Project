import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobil_app_project/Screens/uthentication/createnewpassword.dart';

class Verification extends StatefulWidget {
  const Verification({super.key});

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  // 4 Controllers & FocusNodes for the 4 OTP boxes
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  // Focus tracking state
  int _focusedIndex = -1;

  // Countdown Timer state
  Timer? _timer;
  //int _secondsRemaining = 56;

  @override
  void initState() {
    super.initState();
    // _startTimer();

    // Listen to focus changes to update green background highlight
    for (int i = 0; i < 4; i++) {
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus) {
          setState(() {
            _focusedIndex = i;
          });
        }
      });
    }
  }

  // void _startTimer() {
  //   _timer?.cancel();
  //   setState(() {
  //     _secondsRemaining = 2;
  //   });
  //   _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
  //     if (_secondsRemaining > 0) {
  //       setState(() {
  //         _secondsRemaining--;
  //       });
  //     } else {
  //       timer.cancel();
  //     }
  //   });
  // }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
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
                "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 36),

              // 4-Digit OTP Code Boxes Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) => _buildOtpBox(index)),
              ),
              const SizedBox(height: 36),

              // Resend Code & Countdown Timer Text
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
                            // text: "$_secondsRemaining",
                            style: const TextStyle(
                              color: Color(0xFF138048),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(text: " seconds"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // GestureDetector(
                    //   // _secondsRemaining == 0 ? _startTimer : null,
                    //   onTap: () {},
                    //   child: Text(
                    //     "Resend Code",
                    //     style: TextStyle(
                    //       color: _secondsRemaining == 0
                    //           ? const Color(0xFF138048)
                    //           : const Color(0xFF138048).withOpacity(0.6),
                    //       fontWeight: FontWeight.bold,
                    //       fontSize: 14,
                    //     ),
                    //   ),
                    // ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return CreateNewPassword();
                            },
                          ),
                        );
                      },
                      child: Text("create password"),
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

  // OTP Single Box Builder Widget
  Widget _buildOtpBox(int index) {
    final bool isFocused = _focusedIndex == index;
    final bool hasValue = _controllers[index].text.isNotEmpty;

    return SizedBox(
      width: 65,
      height: 60,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          if (value.isNotEmpty) {
            // Move to next box automatically
            if (index < 3) {
              FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
            } else {
              _focusNodes[index].unfocus();
            }
          } else {
            // Move back to previous box on backspace
            if (index > 0) {
              FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
            }
          }
          setState(() {});
        },
        decoration: InputDecoration(
          filled: true,

          // Active or Filled Box = Light Green, Unfocused Box = White/Light Grey
          fillColor: (isFocused || hasValue)
              ? const Color(0xFFE8F5E9)
              : Colors.grey.shade50,

          contentPadding: EdgeInsets.zero,

          // Default Border (Light Grey)
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: hasValue ? const Color(0xFF138048) : Colors.grey.shade300,
              width: 1,
            ),
          ),

          // Focused Border (Green)
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF138048), width: 1.5),
          ),
        ),
      ),
    );
  }
}
