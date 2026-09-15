import 'package:flutter/material.dart';
import 'package:mobil_app_project/models/security_payment_models.dart';
import 'package:mobil_app_project/network/apiservices.dart';
import 'package:mobil_app_project/network/networkclient.dart';
import 'package:mobil_app_project/Screens/AccountSettings/addcard.dart';

class Paymentaccount extends StatefulWidget {
  const Paymentaccount({super.key});

  @override
  State<Paymentaccount> createState() => _PaymentaccountState();
}

class _PaymentaccountState extends State<Paymentaccount> {
  // Brand color based on the design
  static const Color primaryGreen = Color(0xFF0C8A43);

  final List<PaymentMethodResponse> _paymentMethods = [];
  final ApiServices _api = ApiServices(NetworkClient());
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    try {
      final response = await _api.paymentMethods();
      if (!mounted) return;

      if (response.statusCode != 200) {
        setState(() {
          _loadError = 'Unable to load payment accounts.';
        });
        return;
      }

      final responseData = response.data;
      final data = responseData is List<dynamic>
          ? responseData
          : responseData is Map<String, dynamic>
          ? responseData['paymentMethods'] ??
                responseData['payment_methods'] ??
                responseData['data'] ??
                responseData['content'] ??
                responseData['items']
          : null;

      if (data is List<dynamic>) {
        setState(() {
          _loadError = null;
          _paymentMethods
            ..clear()
            ..addAll(
              data.whereType<Map<String, dynamic>>().map(
                PaymentMethodResponse.fromJson,
              ),
            );
        });
      } else {
        setState(() {
          _loadError = 'Unable to read payment accounts.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadError = 'Unable to load payment accounts.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openAddCardScreen() async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddCardScreen()),
    );
    if (!mounted || added != true) return;
    await _loadPaymentMethods();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF5F6F8),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ),
        title: const Text(
          'Payment Accounts',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            children: [
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _loadError != null
                    ? Center(child: Text(_loadError!))
                    : _paymentMethods.isEmpty
                    ? const Center(child: Text('No payment accounts found.'))
                    : ListView.separated(
                        itemCount: _paymentMethods.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final item = _paymentMethods[index];
                          return _buildPaymentCard(item);
                        },
                      ),
              ),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _openAddCardScreen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Add New Card',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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

  String _paymentName(PaymentMethodResponse payment) {
    if (payment.accountLabel?.isNotEmpty == true) {
      return payment.accountLabel!;
    }
    if (payment.last4?.isNotEmpty == true) {
      return '${payment.brand ?? payment.type} ending ${payment.last4}';
    }
    return payment.type.replaceAll('_', ' ');
  }

  IconData _paymentIcon(String type, String? brand) {
    final paymentType = type.toUpperCase();
    final paymentBrand = brand?.toUpperCase();
    switch (paymentType) {
      case 'APPLE_PAY':
        return Icons.apple;
      case 'GOOGLE_PAY':
        return Icons.g_mobiledata_rounded;
      case 'PAYPAL':
        return Icons.account_balance_wallet;
      default:
        if (paymentBrand == 'PAYPAL') {
          return Icons.account_balance_wallet;
        }
        return Icons.credit_card;
    }
  }

  List<Color> _paymentGradient(PaymentMethodResponse payment) {
    final value = '${payment.type} ${payment.brand}'.toUpperCase();
    if (value.contains('PAYPAL')) {
      return const [Color(0xFF003087), Color(0xFF009CDE)];
    }
    if (value.contains('MASTERCARD')) {
      return const [Color(0xFF8E1B2E), Color(0xFFF26A21)];
    }
    if (value.contains('APPLE')) {
      return const [Color(0xFF171717), Color(0xFF4B5563)];
    }
    if (value.contains('GOOGLE')) {
      return const [Color(0xFF1769AA), Color(0xFF38A3D1)];
    }
    return const [Color(0xFF182B75), Color(0xFF7A4BA5)];
  }

  Widget _buildPaymentCard(PaymentMethodResponse payment) {
    final icon = _paymentIcon(payment.type, payment.brand);
    final status = payment.expired
        ? 'Expired'
        : (payment.isDefault ? 'Default' : 'Connected');
    final brand = payment.brand?.toUpperCase() ?? payment.type;
    final maskedNumber = payment.last4 == null
        ? 'Card account'
        : '****  ****  ****  ${payment.last4}';

    return Container(
      height: 190,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _paymentGradient(payment),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33182B75),
            blurRadius: 16,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(35),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 29, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _paymentName(payment),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$brand  -  $maskedNumber',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: payment.expired
                      ? const Color(0x66FF6B6B)
                      : const Color(0x44FFFFFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          if (payment.expiry != null && payment.expiry!.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, color: Colors.white24),
            const SizedBox(height: 11),
            Row(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 16,
                  color: Colors.white70,
                ),
                const SizedBox(width: 7),
                Text(
                  'Expires ${payment.expiry}',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
