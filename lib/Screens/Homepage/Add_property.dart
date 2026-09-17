import 'package:flutter/material.dart';
import 'package:mobil_app_project/network/apiservices.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobil_app_project/network/networkclient.dart';

class AddProperty extends StatefulWidget {
  final ApiServices? apiServices;

  const AddProperty({super.key, this.apiServices});

  @override
  State<AddProperty> createState() => _AddPropertyState();
}

class _AddPropertyState extends State<AddProperty> {
  static const _green = Color(0xFF087F43);

  late final ApiServices _apiServices;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController(text: '100000');
  final _cityController = TextEditingController(text: 'Chicago');
  final _countryController = TextEditingController(text: 'United States');
  final _bedsController = TextEditingController(text: '3');
  final _bathsController = TextEditingController(text: '2');
  final _sellerNameController = TextEditingController(text: 'Jane Doe');
  final _phoneController = TextEditingController(text: '(409) 487-1935');
  final _emailController = TextEditingController(text: 'jane.doe@example.com');
  final _availableHoursController = TextEditingController(
    text: '09:00 - 18:00 WIB',
  );
  final _additionalNotesController = TextEditingController(
    text: 'The house was newly renovated in 2022\nwith high-quality materials.',
  );
  String _landArea = '250 m²';
  String _buildingArea = '180 m²';
  String _bedrooms = '3';
  String _bathrooms = '2';
  String _floors = '2';
  String _yearBuilt = '2018';
  String _amenities = 'Garage, Garden, Swimming Pool, Fiber...';
  String _type = 'APARTMENT';
  String _status = 'FOR_SALE';
  String _mediaType = 'Photos';
  String _publishingStatus = 'Active';
  String _openHouseSchedule = 'Saturday, 10:00 AM - 12:00 PM';
  String _ownershipStatus = 'Placeholder';
  final List<XFile> _selectedDocuments = [];
  final List<XFile> _selectedPhotos = [];
  int _step = 0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _apiServices = widget.apiServices ?? ApiServices(NetworkClient());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _bedsController.dispose();
    _bathsController.dispose();
    _sellerNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _availableHoursController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }

  Future<void> _saveProperty() async {
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      _formKey.currentState!.validate();
      return;
    }
    setState(() => _isSaving = true);

    try {
      final response = await _apiServices.addProperty({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'type': _type,
        'status': _publishingStatus,
        'price': double.tryParse(_priceController.text.trim()) ?? 0,
        'currency': 'USD',
        'city': _cityController.text.trim(),
        'country': _countryController.text.trim(),
        'beds': int.tryParse(_bedsController.text.trim()) ?? 0,
        'baths': int.tryParse(_bathsController.text.trim()) ?? 0,
        'landAreaSqft':
            int.tryParse(_landArea.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
        'floors': int.tryParse(_floors) ?? 0,
        'yearBuilt': int.tryParse(_yearBuilt) ?? 0,
      }) as dynamic;
      final responseStatusCode = response?.statusCode as int?;
      if (response == null ||
          responseStatusCode == null ||
          responseStatusCode < 200 ||
          responseStatusCode >= 300) {
        throw Exception(_apiErrorMessage(response?.data));
      }
      final responseData = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : <String, dynamic>{};
      final nestedData = responseData['data'] is Map
          ? Map<String, dynamic>.from(responseData['data'] as Map)
          : const <String, dynamic>{};
      final rawPropertyId =
          responseData['id'] ??
          responseData['propertyId'] ??
          nestedData['id'] ??
          nestedData['propertyId'];
      final propertyId = rawPropertyId is num
          ? rawPropertyId.toInt()
          : int.tryParse('$rawPropertyId');
      if (propertyId != null && _selectedPhotos.isNotEmpty) {
        debugPrint(
          'Property $propertyId created with ${_selectedPhotos.length} '
          'selected ${_mediaType.toLowerCase()} file(s).',
        );
      }
      if (!mounted) return;
      setState(() => _isSaving = false);
      await _showUploadSuccessDialog();
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to add property: ${_apiErrorMessage(error)}'),
        ),
      );
    }
  }

  String _apiErrorMessage(Object? data) {
    if (data is Map) {
      final message = data['message'] ?? data['error'] ?? data['detail'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }
    return data?.toString().replaceFirst('Exception: ', '') ??
        'Property creation failed';
  }

  Future<void> _showUploadSuccessDialog() async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 22),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFE6F3EC),
                  ),
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: _green,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Property Uploaded\nSuccessfully!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF171A1F),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your property has been successfully\nuploaded and is now live on the platform.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    height: 1.4,
                    color: Color(0xFFAAB3BF),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      Navigator.pop(context, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'View Property',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildWizardHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
                children: [
                  if (_step == 0) _buildGeneralInformation(),
                  if (_step == 1) _buildPropertyDetails(),
                  if (_step == 2) _buildPhotosAndMedia(),
                  if (_step == 3) _buildContactInformation(),
                  if (_step == 4) _buildAdditionalSettings(),
                  if (_step == 5) _buildLegalDocuments(),
                  if (_step == 6) _buildPreviewAndSubmit(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWizardHeader() {
    return Container(
      color: _green,
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: Colors.white.withValues(alpha: 0.18),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: _step == 0
                      ? () => Navigator.pop(context)
                      : () => setState(() => _step--),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 18,
                  ),
                  tooltip: 'Back',
                ),
              ),
              const Expanded(
                child: Text(
                  'Add Property',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 34),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _stepIndicator('1', 'General Information', _step >= 0),
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.22),
                ),
              ),
              _stepIndicator('2', 'Property Details', _step >= 1),
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.22),
                ),
              ),
              _stepIndicator('3', 'Photos and Media', _step >= 2),
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.22),
                ),
              ),
              _stepIndicator('4', 'Contact Information', _step >= 3),
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.22),
                ),
              ),
              _stepIndicator('5', 'Additional Settings', _step >= 4),
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.22),
                ),
              ),
              _stepIndicator('6', 'Legal and Documents', _step >= 5),
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.22),
                ),
              ),
              _stepIndicator('7', 'Preview and Submit', _step >= 6),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepIndicator(String number, String label, bool active) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            number,
            style: TextStyle(
              fontSize: 8,
              color: active ? _green : Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: active ? Colors.white : Colors.white.withValues(alpha: 0.35),
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('General Information'),
        _plainField(
          _titleController,
          'Property Title',
          'Title',
          requiredField: true,
        ),
        _plainField(
          _descriptionController,
          'Property Description',
          'Short description',
          maxLines: 4,
          requiredField: true,
        ),
        _plainDropdown('Property Type', 'Select type', _type, const {
          'APARTMENT': 'Apartment',
          'HOUSE': 'House',
          'VILLA': 'Villa',
          'HOTEL': 'Hotel',
        }, (value) => setState(() => _type = value)),
        _plainDropdown('Property Status', 'Select status', _status, const {
          'FOR_SALE': 'For Sale',
          'FOR_RENT': 'For Rent',
          'PENDING': 'Pending',
          'SOLD': 'Sold',
        }, (value) => setState(() => _status = value)),
        const SizedBox(height: 4),
        _continueButton(),
      ],
    );
  }

  Widget _buildPropertyDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Property Details'),
        Row(
          children: [
            Expanded(
              child: _detailsDropdown('Land Area', _landArea, const [
                '150 m²',
                '250 m²',
                '350 m²',
              ], (value) => setState(() => _landArea = value)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _detailsDropdown('Building Area', _buildingArea, const [
                '120 m²',
                '180 m²',
                '240 m²',
              ], (value) => setState(() => _buildingArea = value)),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _detailsDropdown('Bedrooms', _bedrooms, const [
                '1',
                '2',
                '3',
                '4',
                '5',
              ], (value) => setState(() => _bedrooms = value)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _detailsDropdown('Bathrooms', _bathrooms, const [
                '1',
                '2',
                '3',
                '4',
              ], (value) => setState(() => _bathrooms = value)),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _detailsDropdown('Floors', _floors, const [
                '1',
                '2',
                '3',
                '4',
              ], (value) => setState(() => _floors = value)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _detailsDropdown('Year Built', _yearBuilt, const [
                '2018',
                '2019',
                '2020',
                '2021',
                '2022',
              ], (value) => setState(() => _yearBuilt = value)),
            ),
          ],
        ),
        _detailsDropdown('Additional Amenities', _amenities, const [
          'Garage, Garden, Swimming Pool, Fiber...',
          'Garage, Garden',
          'Swimming Pool, Fiber Internet',
        ], (value) => setState(() => _amenities = value)),
        const SizedBox(height: 68),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: _isSaving ? null : () => setState(() => _step = 2),
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Continue', style: TextStyle(fontSize: 12)),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotosAndMedia() {
    final hasPhotos = _selectedPhotos.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Photos and Media'),
        _sectionLabel('Upload Media'),
        _mediaDropdown(),
        _sectionLabel('Upload Property Photos'),
        GestureDetector(
          onTap: _pickPhotos,
          child: Container(
            width: double.infinity,
            height: 96,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFDDE2E8)),
              borderRadius: BorderRadius.circular(7),
            ),
            child: hasPhotos
                ? _selectedPhotoSummary()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 23,
                        height: 23,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFF0F2F5),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 17,
                          color: Color(0xFF86909C),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Upload photos from various',
                        style: TextStyle(fontSize: 8, color: Color(0xFFAAB3BF)),
                      ),
                      const Text(
                        'angles: front view, living room, bedrooms, kitchen,',
                        style: TextStyle(fontSize: 8, color: Color(0xFFAAB3BF)),
                      ),
                      const Text(
                        'backyard',
                        style: TextStyle(fontSize: 8, color: Color(0xFFAAB3BF)),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 128),
        SizedBox(
          width: double.infinity,
          height: 34,
          child: ElevatedButton(
            onPressed: hasPhotos ? () => setState(() => _step = 3) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              disabledBackgroundColor: const Color(0xFFDDE0E6),
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
            ),
            child: const Text('Continue', style: TextStyle(fontSize: 11)),
          ),
        ),
      ],
    );
  }

  Widget _buildContactInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Contact Information'),
        _plainField(
          _sellerNameController,
          'Seller Name',
          'Jane Doe',
          requiredField: true,
        ),
        _phoneField(),
        _plainField(
          _emailController,
          'Email Address',
          'jane.doe@example.com',
          keyboardType: TextInputType.emailAddress,
          requiredField: true,
        ),
        _plainField(
          _availableHoursController,
          'Available Hours',
          '09:00 - 18:00 WIB',
          requiredField: true,
        ),
        const SizedBox(height: 76),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) setState(() => _step = 4);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Continue', style: TextStyle(fontSize: 12)),
          ),
        ),
      ],
    );
  }

  Widget _phoneField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phone Number',
            style: TextStyle(fontSize: 10, color: Color(0xFF20242A)),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'Required' : null,
            decoration: InputDecoration(
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 9, right: 5),
                child: Text(
                  'US +1',
                  style: TextStyle(fontSize: 11, color: Color(0xFF343A40)),
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
              hintText: '(409) 487-1935',
              hintStyle: const TextStyle(
                fontSize: 11,
                color: Color(0xFFAAB3BF),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: const BorderSide(color: Color(0xFFDDE2E8)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: const BorderSide(color: Color(0xFFDDE2E8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: const BorderSide(color: _green),
              ),
              errorStyle: const TextStyle(fontSize: 9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Additional Settings'),
        _sectionLabel('Publishing Status'),
        _settingsDropdown(_publishingStatus, const [
          'Active',
          'Pending',
          'Sold',
          'Draft',
        ], (value) => setState(() => _publishingStatus = value)),
        _sectionLabel('Open House Schedule'),
        _settingsDropdown(_openHouseSchedule, const [
          'Saturday, 10:00 AM - 12:00 PM',
          'Sunday, 10:00 AM - 12:00 PM',
          'By appointment only',
        ], (value) => setState(() => _openHouseSchedule = value)),
        _plainField(
          _additionalNotesController,
          'Additional Notes',
          'Additional notes',
          maxLines: 4,
        ),
        const SizedBox(height: 64),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: () => setState(() {
              _step = 5;
            }),
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Continue', style: TextStyle(fontSize: 12)),
          ),
        ),
      ],
    );
  }

  Widget _settingsDropdown(
    String value,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        icon: const Icon(
          Icons.keyboard_arrow_down,
          size: 17,
          color: Color(0xFF7C8794),
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: const BorderSide(color: Color(0xFFDDE2E8)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: const BorderSide(color: Color(0xFFDDE2E8)),
          ),
        ),
        style: const TextStyle(fontSize: 10, color: Color(0xFF343A40)),
        items: options
            .map(
              (option) => DropdownMenuItem(
                value: option,
                child: Text(option, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      ),
    );
  }

  Widget _buildLegalDocuments() {
    final hasOwnershipStatus = _ownershipStatus != 'Placeholder';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Legal and Documents'),
        _sectionLabel('Ownership Status'),
        _settingsDropdown(_ownershipStatus, const [
          'Placeholder',
          'Owned',
          'For Sale Agreement',
          'Leased',
        ], (value) => setState(() => _ownershipStatus = value)),
        _sectionLabel('Upload Documents (Optional)'),
        GestureDetector(
          onTap: _pickDocuments,
          child: Container(
            width: double.infinity,
            height: 98,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFDDE2E8)),
              borderRadius: BorderRadius.circular(7),
            ),
            child: _selectedDocuments.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 23,
                        height: 23,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFF0F2F5),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 17,
                          color: Color(0xFF86909C),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Option to upload supporting documents like',
                        style: TextStyle(fontSize: 8, color: Color(0xFFAAB3BF)),
                      ),
                      const Text(
                        'certificate, IMB, etc.',
                        style: TextStyle(fontSize: 8, color: Color(0xFFAAB3BF)),
                      ),
                    ],
                  )
                : Center(
                    child: Text(
                      '${_selectedDocuments.length} document${_selectedDocuments.length == 1 ? '' : 's'} selected',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF7C8794),
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 137),
        SizedBox(
          width: double.infinity,
          height: 34,
          child: ElevatedButton(
            onPressed: hasOwnershipStatus
                ? () => setState(() => _step = 6)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              disabledBackgroundColor: const Color(0xFFDDE0E6),
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
            ),
            child: const Text('Continue', style: TextStyle(fontSize: 11)),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDocuments() async {
    final documents = await ImagePicker().pickMultiImage();
    if (!mounted || documents.isEmpty) return;
    setState(() => _selectedDocuments.addAll(documents));
  }

  Widget _buildPreviewAndSubmit() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Preview and Submit'),
        _plainField(
          _titleController,
          'Property Title',
          '3 Bedroom Luxury House in City Center',
          requiredField: true,
        ),
        _plainField(
          _descriptionController,
          'Property Description',
          'A luxurious 3-bedroom house with a modern design in the city center. The property features a spacious living room, fully equipped kitchen, and a backyard ide...',
          maxLines: 4,
          requiredField: true,
        ),
        _plainDropdown('Property Type', 'Select type', _type, const {
          'APARTMENT': 'Apartment',
          'HOUSE': 'House',
          'VILLA': 'Villa',
          'HOTEL': 'Hotel',
        }, (value) => setState(() => _type = value)),
        _plainDropdown('Property Status', 'Select status', _status, const {
          'FOR_SALE': 'Active',
          'PENDING': 'Pending',
          'SOLD': 'Sold',
          'DRAFT': 'Draft',
        }, (value) => setState(() => _status = value)),
        const SizedBox(height: 3),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveProperty,
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Continue', style: TextStyle(fontSize: 12)),
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Text(
      label,
      style: const TextStyle(fontSize: 9, color: Color(0xFF20242A)),
    ),
  );

  Widget _mediaDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: DropdownButtonFormField<String>(
        initialValue: _mediaType,
        icon: const Icon(
          Icons.keyboard_arrow_down,
          size: 16,
          color: Color(0xFF7C8794),
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: const BorderSide(color: Color(0xFFDDE2E8)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: const BorderSide(color: Color(0xFFDDE2E8)),
          ),
        ),
        style: const TextStyle(fontSize: 10, color: Color(0xFF343A40)),
        items: const [
          DropdownMenuItem(value: 'Photos', child: Text('Photos')),
          DropdownMenuItem(value: 'Videos', child: Text('Videos')),
        ],
        onChanged: (value) {
          if (value != null) setState(() => _mediaType = value);
        },
      ),
    );
  }

  Widget _selectedPhotoSummary() => Center(
    child: Text(
      '${_selectedPhotos.length} photo${_selectedPhotos.length == 1 ? '' : 's'} selected\nTap to add more',
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 10, color: Color(0xFF7C8794)),
    ),
  );

  Future<void> _pickPhotos() async {
    final picker = ImagePicker();
    if (_mediaType == 'Videos') {
      final video = await picker.pickVideo(source: ImageSource.gallery);
      if (!mounted || video == null) return;
      setState(() => _selectedPhotos.add(video));
      return;
    }
    final photos = await picker.pickMultiImage();
    if (!mounted || photos.isEmpty) return;
    setState(() => _selectedPhotos.addAll(photos));
  }

  Widget _detailsDropdown(
    String label,
    String value,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 9, color: Color(0xFF20242A)),
          ),
          const SizedBox(height: 5),
          DropdownButtonFormField<String>(
            initialValue: value,
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: Color(0xFF7C8794),
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: const BorderSide(color: Color(0xFFDDE2E8)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: const BorderSide(color: Color(0xFFDDE2E8)),
              ),
            ),
            style: const TextStyle(fontSize: 10, color: Color(0xFF343A40)),
            items: options
                .map(
                  (option) => DropdownMenuItem(
                    value: option,
                    child: Text(option, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: (selected) {
              if (selected != null) onChanged(selected);
            },
          ),
        ],
      ),
    );
  }

  Widget _continueButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) setState(() => _step = 1);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('Continue'),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    ),
  );

  Widget _plainField(
    TextEditingController controller,
    String label,
    String hint, {
    int maxLines = 1,
    TextInputType? keyboardType,
    bool requiredField = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF20242A)),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: requiredField
                ? (value) =>
                      value == null || value.trim().isEmpty ? 'Required' : null
                : null,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 11,
                color: Color(0xFFAAB3BF),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: const BorderSide(color: Color(0xFFDDE2E8)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: const BorderSide(color: Color(0xFFDDE2E8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: const BorderSide(color: _green),
              ),
              errorStyle: const TextStyle(fontSize: 9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _plainDropdown(
    String label,
    String hint,
    String value,
    Map<String, String> options,
    ValueChanged<String> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF20242A)),
          ),
          const SizedBox(height: 5),
          DropdownButtonFormField<String>(
            initialValue: value,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: Color(0xFF7C8794),
            ),
            decoration: InputDecoration(
              hintText: hint,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 1,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: const BorderSide(color: Color(0xFFDDE2E8)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: const BorderSide(color: Color(0xFFDDE2E8)),
              ),
            ),
            items: options.entries
                .map(
                  (entry) => DropdownMenuItem(
                    value: entry.key,
                    child: Text(
                      entry.value,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                )
                .toList(),
            onChanged: (selected) {
              if (selected != null) onChanged(selected);
            },
          ),
        ],
      ),
    );
  }
}