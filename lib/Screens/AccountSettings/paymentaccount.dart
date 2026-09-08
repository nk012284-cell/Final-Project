import 'package:flutter/material.dart';

class Paymentaccount extends StatefulWidget {
  const Paymentaccount({super.key});

  @override
  State<Paymentaccount> createState() => _PaymentaccountState();
}

class _PaymentaccountState extends State<Paymentaccount> {
  // Brand color based on the design
  static const Color primaryGreen = Color(0xFF0C8A43);

  // List of payment methods
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'name': 'Apple Pay',
      'icon': Icons.apple,
      'status': 'Connected',
      'iconColor': Colors.black,
    },
    {
      'name': 'Google Pay',
      'icon': Icons.g_mobiledata_rounded,
      'status': 'Connected',
      'iconColor': Colors.blue,
    },
    {
      'name': 'PayPal',
      'icon': Icons.account_balance_wallet,
      'status': 'Connected',
      'iconColor': Colors.indigo,
    },
  ];

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
          'Payment Account',
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
                child: ListView.separated(
                  itemCount: _paymentMethods.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = _paymentMethods[index];
                    return _buildPaymentCard(
                      name: item['name'],
                      icon: item['icon'],
                      status: item['status'],
                      iconColor: item['iconColor'],
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle Add New Card action
                  },
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

  Widget _buildPaymentCard({
    required String name,
    required IconData icon,
    required String status,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          Text(
            status,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}
