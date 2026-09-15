import 'package:flutter/material.dart';
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    final request = AddCardRequest(
      holderName: _holderNameController.text.trim(),
      cardNumber: _cardNumberController.text.replaceAll(RegExp(r'\D'), ''),
      expMonth: int.parse(_monthController.text.trim()),
      expYear: int.parse(_yearController.text.trim()),
      makeDefault: false,
    );

    try {
      var response = await _api.addCard(request.toJson());
      if (response.statusCode == 401) {
        final refreshToken = Session.instance.refreshToken;
        if (refreshToken != null && refreshToken.isNotEmpty) {
          final refreshResponse = await _api.refreshToken({
            'refreshToken': refreshToken,
          });
          if (refreshResponse.statusCode == 200 &&
              refreshResponse.data is Map<String, dynamic>) {
            Session.instance.setCredentials(
              JwtResponse.fromJson(
                refreshResponse.data as Map<String, dynamic>,
              ),
            );
            response = await _api.addCard(request.toJson());
          }
        }
      }

      if (!mounted) return;
      if ((response.statusCode ?? 0) >= 200 &&
          (response.statusCode ?? 0) < 300) {
        Navigator.pop(context, true);
        return;
      }

      _showApiError(response.data);
    } catch (_) {
      if (mounted) {
        _showApiError(null);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showApiError(dynamic data) {
    final fieldErrors = data is Map<String, dynamic>
        ? data['fieldErrors']
        : null;
    final message = fieldErrors is List && fieldErrors.isNotEmpty
        ? (fieldErrors.first as Map<String, dynamic>)['message']?.toString()
        : data is Map<String, dynamic>
        ? data['message']?.toString()
        : null;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message ?? 'Unable to add card.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Add Card',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _CardPreview(
                cardNumberController: _cardNumberController,
                holderNameController: _holderNameController,
                monthController: _monthController,
                yearController: _yearController,
              ),
              const SizedBox(height: 28),
              _field(
                label: 'Card holder name',
                controller: _holderNameController,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter card holder name'
                    : null,
              ),
              const SizedBox(height: 18),
              _field(
                label: 'Card number',
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  final digits = value?.replaceAll(RegExp(r'\D'), '') ?? '';
                  return digits.length < 12
                      ? 'Enter a valid card number'
                      : null;
                },
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      label: 'Expiry month',
                      controller: _monthController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final month = int.tryParse(value?.trim() ?? '');
                        return month == null || month < 1 || month > 12
                            ? 'Use 1-12'
                            : null;
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _field(
                      label: 'Expiry year',
                      controller: _yearController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final year = int.tryParse(value?.trim() ?? '');
                        final currentYear = DateTime.now().year;
                        return year == null ||
                                (value?.trim().length != 4) ||
                                year < currentYear ||
                                year > currentYear + 30
                            ? 'Use YYYY'
                            : null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 34),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.add_card),
                  label: Text(_isSubmitting ? 'Adding...' : 'Add Card'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0C8A43),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _CardPreview extends StatelessWidget {
  final TextEditingController cardNumberController;
  final TextEditingController holderNameController;
  final TextEditingController monthController;
  final TextEditingController yearController;

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
        final digits = cardNumberController.text.replaceAll(RegExp(r'\D'), '');
        final visibleNumber = digits.isEmpty
            ? '****  ****  ****  ****'
            : _formatCardNumber(digits);
        final holder = holderNameController.text.trim().isEmpty
            ? 'CARD HOLDER NAME'
            : holderNameController.text.trim().toUpperCase();
        final month = monthController.text.trim().isEmpty
            ? 'MM'
            : monthController.text.trim().padLeft(2, '0');
        final yearText = yearController.text.trim();
        final year = yearText.isEmpty
            ? 'YY'
            : yearText.length < 2
            ? yearText
            : yearText.substring(yearText.length - 2);

        return Container(
          height: 205,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF182B75), Color(0xFF5742A8), Color(0xFFB94678)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33182B75),
                blurRadius: 18,
                offset: Offset(0, 9),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD982),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.memory,
                      color: Color(0xFF8D6720),
                      size: 21,
                    ),
                  ),
                  const Row(
                    children: [
                      Icon(Icons.contactless, color: Colors.white, size: 25),
                      SizedBox(width: 8),
                      Text(
                        'VISA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                visibleNumber,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      holder,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),
                  Text(
                    '$month/$year',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
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

  String _formatCardNumber(String digits) {
    final groups = <String>[];
    for (var index = 0; index < digits.length; index += 4) {
      final end = (index + 4 < digits.length) ? index + 4 : digits.length;
      groups.add(digits.substring(index, end));
    }
    while (groups.length < 4) {
      groups.add('****');
    }
    return groups.take(4).join('  ');
  }
}
