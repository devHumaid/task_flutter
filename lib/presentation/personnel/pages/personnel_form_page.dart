// lib/presentation/personnel/pages/personnel_form_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_task/core/theme/app_theme.dart';
import 'package:flutter_task/core/utils/validators.dart';
import 'package:flutter_task/data/models/personnel_model.dart';
import 'package:flutter_task/data/models/role_model.dart';
import 'package:flutter_task/presentation/personnel/bloc/personal_bloc.dart';
import 'package:flutter_task/presentation/personnel/bloc/personal_event.dart';
import 'package:flutter_task/presentation/personnel/bloc/personal_state.dart';

class PersonnelFormPage extends StatefulWidget {
  final int? personnelId;

  const PersonnelFormPage({Key? key, this.personnelId}) : super(key: key);

  @override
  State<PersonnelFormPage> createState() => _PersonnelFormPageState();
}

class _PersonnelFormPageState extends State<PersonnelFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _suburbController = TextEditingController();
  final _stateController = TextEditingController();
  final _postcodeController = TextEditingController();
  final _contactController = TextEditingController();
  final _notesController = TextEditingController();

  List<RoleModel> _roles = [];
  int? _selectedRoleId;
  String? _selectedCountry;
  bool _isActive = true;
  bool _isLoading = false;
  PersonnelModel? _existingPersonnel;

  // Predefined countries list
  final List<String> _countries = [
    'Australia',
    'United States',
    'United Kingdom',
    'Canada',
    'New Zealand',
  ];

  @override
  void initState() {
    super.initState();
    // Load roles first
    context.read<PersonnelBloc>().add(LoadRoles());
    
    // Then load personnel details if editing
    if (widget.personnelId != null) {
      context.read<PersonnelBloc>().add(LoadPersonnelDetails(widget.personnelId!));
    }
  }

void _populateForm(PersonnelModel personnel) {
  setState(() {
    _firstNameController.text = personnel.firstName;
    _addressController.text = personnel.address ?? '';
    _suburbController.text = personnel.suburb ?? '';
    _stateController.text = personnel.state ?? '';
    _postcodeController.text = personnel.postcode ?? '';
    _contactController.text = personnel.contactNumber ?? '';
    _notesController.text = personnel.additionalNotes ?? '';
    _selectedCountry = personnel.country;
    
    // Handle roleIds (it's now a List<String>?)
    if (personnel.roleIds != null && personnel.roleIds!.isNotEmpty) {
      // Get the first role ID from the list and parse it to int
      _selectedRoleId = int.tryParse(personnel.roleIds!.first);
    } else if (personnel.roleDetails != null && personnel.roleDetails!.isNotEmpty) {
      // Fallback: get role ID from roleDetails
      _selectedRoleId = personnel.roleDetails!.first.id;
    }
    
    _isActive = personnel.status == 1;
    _existingPersonnel = personnel;
  });
}

  @override
  void dispose() {
    _firstNameController.dispose();
    _addressController.dispose();
    _suburbController.dispose();
    _stateController.dispose();
    _postcodeController.dispose();
    _contactController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedRoleId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a role'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedCountry == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a country'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final data = {
        'first_name': _firstNameController.text.trim(),
        'address': _addressController.text.trim(),
        'suburb': _suburbController.text.trim(),
        'state': _stateController.text.trim(),
        'postcode': _postcodeController.text.trim(),
        'country': _selectedCountry!,
        'contact_number': _contactController.text.trim(),
        'latitude': _existingPersonnel?.latitude ?? '',
        'longitude': _existingPersonnel?.longitude ?? '',
        'status': _isActive ? '1' : '0',
      };

      if (widget.personnelId == null) {
        // For ADD: API expects 'role_ids' (plural)
        data['role_ids'] = _selectedRoleId.toString();
        context.read<PersonnelBloc>().add(AddPersonnel(data));
      } else {
        // For UPDATE: API expects 'role_id' (singular)
        data['role_id'] = _selectedRoleId.toString();
        context.read<PersonnelBloc>().add(
              UpdatePersonnel(widget.personnelId!, data),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<PersonnelBloc, PersonnelState>(
        listener: (context, state) {
          print('Current state: $state'); // Debug print
          
          if (state is PersonnelLoading) {
            setState(() => _isLoading = true);
          }

          if (state is RolesLoaded) {
            print('Roles loaded: ${state.roles.length}'); // Debug print
            setState(() {
              _roles = state.roles;
              _isLoading = false;
            });
          }

          if (state is PersonnelDetailsLoaded) {
            print('Personnel details loaded'); // Debug print
            _populateForm(state.personnel);
            setState(() => _isLoading = false);
          }

          if (state is PersonnelOperationSuccess) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          }

          if (state is PersonnelError) {
            print('Error: ${state.message}'); // Debug print
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Stack(
          children: [
            Column(
              children: [
                // Custom Header
                _buildCustomAppBar(),
                
                // Form Content
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        _buildTextField(
                          controller: _firstNameController,
                          label: 'Full name',
                          hint: 'Please type',
                          validator: (value) =>
                              Validators.validateRequired(value, 'Full name'),
                        ),
                        const SizedBox(height: 16),
                        
                        _buildTextField(
                          controller: _addressController,
                          label: 'Address',
                          hint: 'Please type',
                          prefixIcon: Icons.location_on_outlined,
                          suffixIcon: Icons.my_location,
                        ),
                        const SizedBox(height: 16),
                        
                        _buildTextField(
                          controller: _suburbController,
                          label: 'Suburb',
                          hint: 'Please type',
                        ),
                        const SizedBox(height: 16),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _stateController,
                                label: 'State',
                                hint: 'Please type',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: _postcodeController,
                                label: 'Post code',
                                hint: 'Please type',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        _buildTextField(
                          controller: _contactController,
                          label: 'Contact number',
                          hint: 'Please type',
                          keyboardType: TextInputType.phone,
                          validator: Validators.validatePhone,
                        ),
                        const SizedBox(height: 16),
                        
                        _buildCountryDropdown(),
                        const SizedBox(height: 16),
                        
                        _buildRoleSection(),
                        const SizedBox(height: 16),
                        
                        _buildNotesField(),
                        const SizedBox(height: 16),
                        
                        _buildStatusToggle(),
                        const SizedBox(height: 32),
                        
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_isLoading)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFDB913),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
Widget _buildCustomAppBar() {
    return Container(
      height: 270,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/app_bar_bg.png'), // Place your wave pattern image here
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Background overlay gradient (optional, for better readability)
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/top_bg.png'), 
                fit: BoxFit.cover,
              ),
              // gradient: LinearGradient(
              //   begin: Alignment.topCenter,
              //   end: Alignment.bottomCenter,
              //   colors: [
              //     const Color(0xFFFFC107).withOpacity(0.9),
              //     const Color(0xFFFFC107).withOpacity(0.7),
              //   ],
              // ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Top bar with icons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left menu icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.grid_view, color: Colors.black),
                          onPressed: () {
                           Navigator.pop(context);
                          },
                        ),
                      ),
                      // Right profile icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
shape: BoxShape.circle,                        ),
                        child: IconButton(
                          icon: const Icon(Icons.person, color: Colors.black),
                          onPressed: () {
                            // TODO: Implement profile/logout
                            // Navigator.pushReplacementNamed(context, '/');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                const Text(
                  'Personnel Details',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                // Search bar
              
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20),
      decoration: const BoxDecoration(
        color: Color(0xFFFDB913),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.grid_view, size: 20),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.person, size: 20),
                ),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Personnel Details',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? prefixIcon,
    IconData? suffixIcon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint ?? 'Please type',
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.grey) : null,
            suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: Colors.grey) : null,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Color(0xFFFDB913), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: validator,
          keyboardType: keyboardType,
          readOnly: readOnly,
        ),
      ],
    );
  }

  Widget _buildCountryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Country',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCountry,
          decoration: InputDecoration(
            hintText: 'Please select',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          items: _countries.map((country) {
            return DropdownMenuItem(
              value: country,
              child: Text(country),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCountry = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a country';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildRoleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Role',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        if (_roles.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFDB913),
              ),
            ),
          )
        else
          ..._roles.map((role) {
            final isSelected = _selectedRoleId == role.id;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedRoleId = isSelected ? null : role.id;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? const Color(0xFFFDB913) : Colors.grey,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              size: 18,
                              color: Color(0xFFFDB913),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      role.role,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Additional Notes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          maxLines: 5,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: 'Please type',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Status',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        Switch(
          value: _isActive,
          thumbColor: MaterialStateProperty.all(Colors.white),
          onChanged: (value) {
            setState(() {
              _isActive = value;
            });
          },
          activeColor: Colors.green,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'CANCEL',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFDB913),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'SAVE',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}