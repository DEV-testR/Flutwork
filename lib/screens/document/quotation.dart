import 'package:flutter/material.dart';

import '../../constants/style_constants.dart';
import '../../widgets/date_input_field.dart';
import '../../widgets/dropdown_input_field.dart';
import '../../widgets/header.dart';
import '../../widgets/text_input_field.dart';

class QuotationScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const QuotationScreen({super.key, required this.scaffoldKey});

  @override
  State<QuotationScreen> createState() => _QuotationScreenState();
}

class _QuotationScreenState extends State<QuotationScreen> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _resultKey = GlobalKey();

  List<Map<String, dynamic>> _searchResults = [];

  final List<Map<String, dynamic>> _mockDocuments = [
    {
      "docNo": "QT202512001",
      "customer": "Siam Trading Co.",
      "date": "01/12/2025",
      "status": "Approved",
      "amount": 15000,
    },
    {
      "docNo": "QT202512002",
      "customer": "ABC Supply",
      "date": "05/12/2025",
      "status": "Draft",
      "amount": 22000,
    },
    {
      "docNo": "QT202512003",
      "customer": "ABC Supply",
      "date": "05/12/2025",
      "status": "Draft",
      "amount": 22000,
    },
    {
      "docNo": "QT202512004",
      "customer": "ABC Supply",
      "date": "05/12/2025",
      "status": "Draft",
      "amount": 22000,
    },
    {
      "docNo": "QT202512005",
      "customer": "ABC Supply",
      "date": "05/12/2025",
      "status": "Draft",
      "amount": 22000,
    },
    {
      "docNo": "QT202512006",
      "customer": "ABC Supply",
      "date": "05/12/2025",
      "status": "Draft",
      "amount": 22000,
    },
    {
      "docNo": "QT202512007",
      "customer": "ABC Supply",
      "date": "05/12/2025",
      "status": "Draft",
      "amount": 22000,
    },
    {
      "docNo": "QT202512008",
      "customer": "ABC Supply",
      "date": "05/12/2025",
      "status": "Draft",
      "amount": 22000,
    },
    {
      "docNo": "QT202512009",
      "customer": "ABC Supply",
      "date": "05/12/2025",
      "status": "Draft",
      "amount": 22000,
    },
    {
      "docNo": "QT202512010",
      "customer": "ABC Supply",
      "date": "05/12/2025",
      "status": "Draft",
      "amount": 22000,
    },
  ];

  DateTime? _documentDateFrom;
  DateTime? _documentDateTo;

  String? _documentStatus;
  String? _excludeFOC;

  final TextEditingController _docNoController = TextEditingController();
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _saleManController = TextEditingController();
  final TextEditingController _saleAreaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _documentDateFrom = DateTime.parse("2025-12-01");
    _documentDateTo = DateTime.parse("2025-12-31");
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _docNoController.dispose();
    _customerController.dispose();
    _saleManController.dispose();
    _saleAreaController.dispose();
    super.dispose();
  }

  void _performSearch() {
    setState(() {
      _searchResults = _mockDocuments.where((doc) {
        if (_docNoController.text.isNotEmpty &&
            !doc["docNo"].contains(_docNoController.text)) {
          return false;
        }

        if (_documentStatus != null &&
            doc["status"] != _documentStatus) {
          return false;
        }

        if (_customerController.text.isNotEmpty &&
            !doc["customer"]
                .toLowerCase()
                .contains(_customerController.text.toLowerCase())) {
          return false;
        }

        return true;
      }).toList();
    });

    if (_searchResults.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToResults();
      });
    }
  }

  void _scrollToResults() {
    final ctx = _resultKey.currentContext;
    if (ctx == null) return;

    final box = ctx.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(
      Offset.zero,
      ancestor: Scrollable.of(ctx).context.findRenderObject(),
    ).dy;

    _scrollController.animateTo(
      _scrollController.offset + offset - 20,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Header(
                title: "Quotation Search",
                scaffoldKey: widget.scaffoldKey,
              ),

              const SizedBox(height: 16),

              _buildSearchCriteriaHeader(primaryColor),

              const SizedBox(height: 16),

              Form(
                key: _formKey,
                child: _buildFormSearch(context, primaryColor),
              ),

              const SizedBox(height: 30),

              _buildSearchResults(primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------
  //      FORM SECTION ONLY
  // --------------------------
  Widget _buildFormSearch(BuildContext context, Color primaryColor) {
    return Card(
      color: secondaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextInputField(
              label: "Document No.",
              primaryColor: primaryColor,
              controller: _docNoController,
            ),
            const SizedBox(height: 20),

            DropdownInputField(
              label: 'Document Status',
              hintText: 'Select Status',
              items: const ['Draft', 'Approved', 'Rejected'],
              primaryColor: primaryColor,
              selectedValue: _documentStatus,
              onChanged: (v) => setState(() => _documentStatus = v),
            ),
            const SizedBox(height: 20),

            DateInputField(
              label: 'Document Date From',
              selectedDate: _documentDateFrom,
              primaryColor: primaryColor,
              onDateSelected: (d) => setState(() => _documentDateFrom = d),
            ),
            const SizedBox(height: 20),

            DateInputField(
              label: 'Document Date To',
              selectedDate: _documentDateTo,
              primaryColor: primaryColor,
              onDateSelected: (d) => setState(() => _documentDateTo = d),
            ),
            const SizedBox(height: 20),

            _buildSearchField(label: 'Customer', primaryColor: primaryColor),
            const SizedBox(height: 20),

            _buildSearchField(label: 'Sale Man', primaryColor: primaryColor),
            const SizedBox(height: 20),

            _buildSearchField(label: 'Sale Area', primaryColor: primaryColor),
            const SizedBox(height: 20),

            DropdownInputField(
              label: 'Exclude FOC',
              hintText: 'Select Option',
              items: const ['Yes', 'No'],
              primaryColor: primaryColor,
              selectedValue: _excludeFOC,
              onChanged: (v) => setState(() => _excludeFOC = v),
            ),

            const SizedBox(height: 25),

            _buildActionButtons(primaryColor),
          ],
        ),
      ),
    );
  }

  // --------------------------
  //        RESULTS SECTION
  // --------------------------
  Widget _buildSearchResults(Color primaryColor) {
    if (_searchResults.isEmpty) return const SizedBox();

    return Card(
      color: secondaryColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              key: _resultKey,   // ⭐ เพิ่ม key เพื่อรู้ตำแหน่ง
              child: const Text(
                "Search Results",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: defaultTextColor,
                ),
              ),
            ),
            const SizedBox(height: 12),

            ..._searchResults.map((doc) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc["docNo"],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text("Customer: ${doc["customer"]}"),
                    Text(
                      "Date: ${doc["date"]}",
                      style: const TextStyle(color: Colors.black54),
                    ),
                    Text(
                      "Status: ${doc["status"]}",
                      style: const TextStyle(color: Colors.black54),
                    ),
                    Text("Amount: ${doc["amount"]} THB"),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // --------------------------
  //  SUPPORT WIDGETS
  // --------------------------

  Widget _buildSearchCriteriaHeader(Color primaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Quotation Search",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: defaultTextColor,
          ),
        ),
        FloatingActionButton(
          onPressed: () {},
          backgroundColor: primaryColor,
          mini: true,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildSearchField({
    required String label,
    required Color primaryColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: defaultTextColor,
            )),
        TextField(
          controller: label == "Customer"
              ? _customerController
              : label == "Sale Man"
              ? _saleManController
              : _saleAreaController,
          decoration: InputDecoration(
            hintText: '',
            suffixIcon: Icon(Icons.search, color: primaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Color primaryColor) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _performSearch,
            icon: const Icon(Icons.search),
            label: const Text("Search"),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _docNoController.clear();
                _customerController.clear();
                _saleManController.clear();
                _saleAreaController.clear();
                _documentStatus = null;
                _excludeFOC = null;
                _documentDateFrom = null;
                _documentDateTo = null;
                _searchResults = [];
              });
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text("Clear"),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange.shade700,
            ),
          ),
        ),
      ],
    );
  }
}
