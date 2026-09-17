import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mobil_app_project/models/authentication/jwt_response_model.dart';
import 'package:mobil_app_project/models/security_payment_models.dart';
import 'package:mobil_app_project/network/apiservices.dart';
import 'package:mobil_app_project/network/networkclient.dart';
import 'package:mobil_app_project/network/session.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();

  final _holderNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _monthController = TextEditingController();
  final _yearController = TextEditingController();

  final _api = ApiServices(NetworkClient());

  bool _isSubmitting = false;

  @override
  void dispose() {
    _holderNameController.dispose();
    _cardNumberController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // LUHN CARD VALIDATION
  // ------------------------------------------------------------

  bool _isValidCardNumber(String number) {
    final digits = number.replaceAll(RegExp(r'\D'), '');

    if (digits.length < 12 || digits.length > 19) {
      return false;
    }

    int sum = 0;
    bool doubleDigit = false;

    for (int i = digits.length - 1; i >= 0; i--) {
      int digit = int.parse(digits[i]);

      if (doubleDigit) {
        digit *= 2;

        if (digit > 9) {
          digit -= 9;
        }
      }

      sum += digit;
      doubleDigit = !doubleDigit;
    }

    return sum % 10 == 0;
  }

  // ------------------------------------------------------------
  // EXPIRY CHECK
  // ------------------------------------------------------------

  bool _isExpired(int month, int year) {
    final now = DateTime.now();

    if (year < now.year) {
      return true;
    }

    if (year == now.year && month < now.month) {
      return true;
    }

    return false;
  }

  // ------------------------------------------------------------
  // SUBMIT
  // ------------------------------------------------------------

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (_isSubmitting) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final holderName = _holderNameController.text.trim();

    // Spaces are removed before sending to API.
    final cardNumber =
        _cardNumberController.text.replaceAll(RegExp(r'\D'), '');

    final expMonth = int.tryParse(
      _monthController.text.trim(),
    );

    final expYear = int.tryParse(
      _yearController.text.trim(),
    );

    if (expMonth == null || expYear == null) {
      _showMessage('Enter a valid expiry date.');
      return;
    }

    if (_isExpired(expMonth, expYear)) {
      _showMessage('Card has expired.');
      return;
    }

    final request = AddCardRequest(
      holderName: holderName,
      cardNumber: cardNumber,
      expMonth: expMonth,
      expYear: expYear,
      makeDefault: false,
    );

    // Useful while debugging your backend.
    debugPrint('========== ADD CARD REQUEST ==========');
    debugPrint('Holder: $holderName');
    debugPrint('Card digits: ${cardNumber.length}');
    debugPrint('Expiry: $expMonth/$expYear');
    debugPrint('JSON: ${request.toJson()}');
    debugPrint('======================================');

    setState(() {
      _isSubmitting = true;
    });

    try {
      var response = await _api.addCard(
        request.toJson(),
      );

      debugPrint('ADD CARD STATUS: ${response.statusCode}');
      debugPrint('ADD CARD RESPONSE: ${response.data}');

      // --------------------------------------------------------
      // ACCESS TOKEN EXPIRED
      // --------------------------------------------------------

      if (response.statusCode == 401) {
        final refreshToken = Session.instance.refreshToken;

        if (refreshToken != null &&
            refreshToken.isNotEmpty) {
          debugPrint(
            'Access token expired. Refreshing token...',
          );

          final refreshResponse =
              await _api.refreshToken({
            'refreshToken': refreshToken,
          });

          debugPrint(
            'REFRESH STATUS: ${refreshResponse.statusCode}',
          );

          if (refreshResponse.statusCode == 200 &&
              refreshResponse.data
                  is Map<String, dynamic>) {
            final jwtResponse =
                JwtResponse.fromJson(
              refreshResponse.data
                  as Map<String, dynamic>,
            );

            Session.instance.setCredentials(
              jwtResponse,
            );

            // Retry request with new access token.
            response = await _api.addCard(
              request.toJson(),
            );

            debugPrint(
              'RETRY STATUS: ${response.statusCode}',
            );

            debugPrint(
              'RETRY RESPONSE: ${response.data}',
            );
          }
        }
      }

      if (!mounted) {
        return;
      }

      final statusCode =
          response.statusCode ?? 0;

      // --------------------------------------------------------
      // SUCCESS
      // --------------------------------------------------------

      if (statusCode >= 200 &&
          statusCode < 300) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                'Card added successfully.',
              ),
              backgroundColor: Colors.green,
            ),
          );

        Navigator.pop(context, true);

        return;
      }

      // --------------------------------------------------------
      // BACKEND ERROR
      // --------------------------------------------------------

      _showApiError(response.data);
    } catch (error, stackTrace) {
      debugPrint('ADD CARD ERROR: $error');
      debugPrint('STACK TRACE: $stackTrace');

      if (!mounted) {
        return;
      }

      _showMessage(
        'Unable to add card. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // ------------------------------------------------------------
  // BACKEND ERROR
  // ------------------------------------------------------------

  void _showApiError(dynamic data) {
    String? message;

    debugPrint('API ERROR DATA: $data');

    if (data is Map) {
      final fieldErrors = data['fieldErrors'];

      if (fieldErrors is List &&
          fieldErrors.isNotEmpty) {
        final firstError = fieldErrors.first;

        if (firstError is Map) {
          message =
              firstError['message']?.toString();
        }
      }

      message ??=
          data['message']?.toString();

      message ??=
          data['error']?.toString();

      message ??=
          data['detail']?.toString();
    }

    _showMessage(
      message ?? 'Unable to add card.',
    );
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ------------------------------------------------------------
  // UI
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).maybePop();
          },
        ),

        title: const Text(
          'Add Card',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,

          child: ListView(
            padding: const EdgeInsets.all(20),

            children: [
              _CardPreview(
                cardNumberController:
                    _cardNumberController,
                holderNameController:
                    _holderNameController,
                monthController:
                    _monthController,
                yearController:
                    _yearController,
              ),

              const SizedBox(height: 28),

              // CARD HOLDER
              _buildField(
                label: 'Card holder name',
                controller:
                    _holderNameController,
                textCapitalization:
                    TextCapitalization.words,
                validator: (value) {
                  final name =
                      value?.trim() ?? '';

                  if (name.isEmpty) {
                    return 'Enter card holder name';
                  }

                  if (name.length < 2) {
                    return 'Enter a valid name';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              // CARD NUMBER
              _buildField(
                label: 'Card number',
                controller:
                    _cardNumberController,
                keyboardType:
                    TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter
                      .digitsOnly,
                  LengthLimitingTextInputFormatter(
                    19,
                  ),
                  CardNumberFormatter(),
                ],
                validator: (value) {
                  final digits =
                      value
                          ?.replaceAll(
                            RegExp(r'\D'),
                            '',
                          ) ??
                      '';

                  if (digits.isEmpty) {
                    return 'Enter card number';
                  }

                  if (digits.length < 12 ||
                      digits.length > 19) {
                    return 'Enter a valid card number';
                  }

                  if (!_isValidCardNumber(
                    digits,
                  )) {
                    return 'That card number is not valid';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  // MONTH
                  Expanded(
                    child: _buildField(
                      label: 'Expiry month',
                      controller:
                          _monthController,
                      keyboardType:
                          TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .digitsOnly,
                        LengthLimitingTextInputFormatter(
                          2,
                        ),
                      ],
                      validator: (value) {
                        final month =
                            int.tryParse(
                          value?.trim() ?? '',
                        );

                        if (month == null ||
                            month < 1 ||
                            month > 12) {
                          return 'Use 1-12';
                        }

                        return null;
                      },
                    ),
                  ),

                  const SizedBox(width: 14),

                  // YEAR
                  Expanded(
                    child: _buildField(
                      label: 'Expiry year',
                      controller:
                          _yearController,
                      keyboardType:
                          TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .digitsOnly,
                        LengthLimitingTextInputFormatter(
                          4,
                        ),
                      ],
                      validator: (value) {
                        final text =
                            value?.trim() ?? '';

                        final year =
                            int.tryParse(text);

                        final currentYear =
                            DateTime.now().year;

                        if (text.length != 4 ||
                            year == null) {
                          return 'Use YYYY';
                        }

                        if (year <
                                currentYear ||
                            year >
                                currentYear +
                                    30) {
                          return 'Use YYYY';
                        }

                        final month =
                            int.tryParse(
                          _monthController.text
                              .trim(),
                        );

                        if (month != null &&
                            month >= 1 &&
                            month <= 12 &&
                            _isExpired(
                              month,
                              year,
                            )) {
                          return 'Card expired';
                        }

                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 34),

              // ADD CARD BUTTON
              SizedBox(
                height: 52,

                child: ElevatedButton.icon(
                  onPressed:
                      _isSubmitting
                          ? null
                          : _submit,

                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                                Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.add_card,
                        ),

                  label: Text(
                    _isSubmitting
                        ? 'Adding...'
                        : 'Add Card',
                  ),

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF0C8A43,
                    ),
                    foregroundColor:
                        Colors.white,
                    disabledBackgroundColor:
                        const Color(
                      0xFF7AB995,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController
        controller,
    required String? Function(String?)
        validator,
    TextInputType keyboardType =
        TextInputType.text,
    TextCapitalization
        textCapitalization =
        TextCapitalization.none,
    List<TextInputFormatter>?
        inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization:
          textCapitalization,
      inputFormatters:
          inputFormatters,
      validator: validator,
      autovalidateMode:
          AutovalidateMode
              .onUserInteraction,

      decoration: InputDecoration(
        labelText: label,

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(10),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(10),
          borderSide:
              const BorderSide(
            color: Color(0xFF0C8A43),
            width: 2,
          ),
        ),

        errorBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(10),
          borderSide:
              const BorderSide(
            color: Colors.red,
          ),
        ),

        focusedErrorBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(10),
          borderSide:
              const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
      ),
    );
  }
}

// ================================================================
// CARD NUMBER FORMATTER
// ================================================================

class CardNumberFormatter
    extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text
        .replaceAll(RegExp(r'\D'), '');

    final buffer = StringBuffer();

    for (int i = 0;
        i < digits.length;
        i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }

      buffer.write(digits[i]);
    }

    final formatted =
        buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection:
          TextSelection.collapsed(
        offset: formatted.length,
      ),
    );
  }
}

// ================================================================
// CARD PREVIEW
// ================================================================

class _CardPreview
    extends StatelessWidget {
  final TextEditingController
      cardNumberController;

  final TextEditingController
      holderNameController;

  final TextEditingController
      monthController;

  final TextEditingController
      yearController;

  const _CardPreview({
    required this.cardNumberController,
    required this.holderNameController,
    required this.monthController,
    required this.yearController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        cardNumberController,
        holderNameController,
        monthController,
        yearController,
      ]),

      builder: (context, child) {
        final digits =
            cardNumberController.text
                .replaceAll(
          RegExp(r'\D'),
          '',
        );

        final visibleNumber =
            digits.isEmpty
                ? '****  ****  ****  ****'
                : _formatCardNumber(
                    digits,
                  );

        final holder =
            holderNameController.text
                    .trim()
                    .isEmpty
                ? 'CARD HOLDER NAME'
                : holderNameController
                    .text
                    .trim()
                    .toUpperCase();

        final month =
            monthController.text
                    .trim()
                    .isEmpty
                ? 'MM'
                : monthController.text
                    .trim()
                    .padLeft(
                      2,
                      '0',
                    );

        final yearText =
            yearController.text.trim();

        final year =
            yearText.isEmpty
                ? 'YY'
                : yearText.length < 2
                    ? yearText
                    : yearText.substring(
                        yearText.length -
                            2,
                      );

        return Container(
          height: 205,
          padding:
              const EdgeInsets.all(
            22,
          ),

          decoration: BoxDecoration(
            gradient:
                const LinearGradient(
              colors: [
                Color(0xFF182B75),
                Color(0xFF5742A8),
                Color(0xFFB94678),
              ],
              begin:
                  Alignment.topLeft,
              end:
                  Alignment.bottomRight,
            ),

            borderRadius:
                BorderRadius.circular(
              20,
            ),

            boxShadow: const [
              BoxShadow(
                color:
                    Color(0x33182B75),
                blurRadius: 18,
                offset: Offset(0, 9),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,

            children: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,

                children: [
                  Container(
                    width: 40,
                    height: 30,

                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFFFFD982,
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        6,
                      ),
                    ),

                    child: const Icon(
                      Icons.memory,
                      color: Color(
                        0xFF8D6720,
                      ),
                      size: 21,
                    ),
                  ),

                  const Row(
                    children: [
                      Icon(
                        Icons
                            .contactless,
                        color:
                            Colors.white,
                        size: 25,
                      ),

                      SizedBox(
                        width: 8,
                      ),

                      Text(
                        'VISA',
                        style:
                            TextStyle(
                          color:
                              Colors.white,
                          fontSize: 25,
                          fontStyle:
                              FontStyle
                                  .italic,
                          fontWeight:
                              FontWeight
                                  .w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              Text(
                visibleNumber,
                style:
                    const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  letterSpacing: 1.8,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      holder,
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize: 12,
                        fontWeight:
                            FontWeight
                                .w700,
                        letterSpacing:
                            0.7,
                      ),
                    ),
                  ),

                  Text(
                    '$month/$year',
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontSize: 12,
                      fontWeight:
                          FontWeight
                              .w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatCardNumber(
    String digits,
  ) {
    final groups = <String>[];

    for (int index = 0;
        index < digits.length;
        index += 4) {
      final end =
          index + 4 <
                  digits.length
              ? index + 4
              : digits.length;

      groups.add(
        digits.substring(
          index,
          end,
        ),
      );
    }

    while (groups.length < 4) {
      groups.add('****');
    }

    return groups
        .take(4)
        .join('  ');
  }
}