import 'package:flutter/material.dart';

class Helpcenter extends StatefulWidget {
  const Helpcenter({super.key});

  @override
  State<Helpcenter> createState() => _HelpcenterState();
}

class _HelpcenterState extends State<Helpcenter> {
  // Track expanded state for each FAQ item
  final List<bool> _isExpandedList = [false, true, false, false, false];

  final List<Map<String, String>> _faqItems = [
    {
      'question': 'Lorem ipsum dolar sit amet',
      'answer': 'Turpis lectus egestas dui proin natoque nulla egestas fames molestie. Euismod orci nisl enim pharetra lectus morbi massa nibh non.',
    },
    {
      'question': 'Lorem ipsum dolar sit amet',
      'answer': 'Turpis lectus egestas dui proin natoque nulla egestas fames molestie. Euismod orci nisl enim pharetra lectus morbi massa nibh non.',
    },
    {
      'question': 'Lorem ipsum dolar sit amet',
      'answer': 'Turpis lectus egestas dui proin natoque nulla egestas fames molestie. Euismod orci nisl enim pharetra lectus morbi massa nibh non.',
    },
    {
      'question': 'Lorem ipsum dolar sit amet',
      'answer': 'Turpis lectus egestas dui proin natoque nulla egestas fames molestie. Euismod orci nisl enim pharetra lectus morbi massa nibh non.',
    },
    {
      'question': 'Lorem ipsum dolar sit amet',
      'answer': 'Turpis lectus egestas dui proin natoque nulla egestas fames molestie. Euismod orci nisl enim pharetra lectus morbi massa nibh non.',
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
          'Help Center',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            children: [
              // Search Field with Filter Icon
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 15,
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                  suffixIcon: Icon(Icons.tune, color: Colors.grey.shade400),
                  filled: true,
                  fillColor: const Color(0xFFF8F9FA),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Accordion / Expansion FAQ List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _faqItems.length,
                separatorBuilder: (context, index) => Divider(
                  color: Colors.grey.shade200,
                  height: 1,
                  thickness: 1,
                ),
                itemBuilder: (context, index) {
                  final isExpanded = _isExpandedList[index];
                  final item = _faqItems[index];

                  return Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      key: Key('expansion_tile_$index'),
                      initiallyExpanded: isExpanded,
                      onExpansionChanged: (expanded) {
                        setState(() {
                          _isExpandedList[index] = expanded;
                        });
                      },
                      tilePadding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 0,
                      ),
                      childrenPadding: const EdgeInsets.only(bottom: 16),
                      title: Text(
                        item['question']!,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      trailing: Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.grey.shade600,
                      ),
                      children: [
                        Text(
                          item['answer']!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
