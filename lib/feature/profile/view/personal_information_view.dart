import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_track/product/service/auth_service.dart';

class PersonalInformationView extends StatefulWidget {
  const PersonalInformationView({super.key});

  @override
  State<PersonalInformationView> createState() =>
      _PersonalInformationViewState();
}

class _PersonalInformationViewState extends State<PersonalInformationView> {
  static const Color _background = Color(0xFF0D0D0D);
  static const Color _card = Color(0xFF1A1A1A);
  static const Color _orange = Color(0xFFE8622A);
  static const Color _textPrimary = Color(0xFFFFFFFF);
  static const Color _textSecondary = Color(0xFF8A8F98);
  static const Color _inputFill = Color(0xFF161616);

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _dobController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;
  String _selectedGender = 'Male';
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = AuthService.instance.currentUser;
    _nameController = TextEditingController(
        text: _currentUser?.displayName ?? 'Alex Johnson');
    _emailController = TextEditingController(
        text: _currentUser?.email ?? 'alex.j@fitnessapp.com');
    _dobController = TextEditingController(text: '05/14/1992');
    _heightController = TextEditingController(text: '182');
    _weightController = TextEditingController(text: '78');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Personal Information',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 32),
              _buildSectionTitle(Icons.person, 'Basic Details'),
              const SizedBox(height: 16),
              _buildTextField('FULL NAME', _nameController),
              const SizedBox(height: 16),
              _buildTextField('EMAIL', _emailController),
              const SizedBox(height: 16),
              _buildDateField('DATE OF BIRTH', _dobController),
              const SizedBox(height: 16),
              _buildDropdownField('GENDER', ['Male', 'Female', 'Other']),
              const SizedBox(height: 32),
              _buildSectionTitle(Icons.fitness_center, 'Body Metrics'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: _buildTextField('HEIGHT (CM)', _heightController)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildTextField('WEIGHT (KG)', _weightController)),
                ],
              ),
              const SizedBox(height: 48),
              _buildSaveButton(),
              const SizedBox(height: 16),
              _buildDiscardButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _orange.withOpacity(0.3), width: 2),
              ),
              child: Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFF2A1A0A),
                  backgroundImage: _currentUser?.photoURL != null
                      ? NetworkImage(_currentUser!.photoURL!)
                      : null,
                  child: _currentUser?.photoURL == null
                      ? Icon(Icons.person,
                          size: 52, color: _orange.withOpacity(0.7))
                      : null,
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: _orange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _currentUser?.displayName ?? 'Alex Johnson',
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Pro Member since 2023',
          style: TextStyle(
            color: _orange.withOpacity(0.8),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: _orange, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: _textPrimary, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: _inputFill,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: true,
          style: const TextStyle(color: _textPrimary, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: _inputFill,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: const Icon(Icons.calendar_today,
                color: _textSecondary, size: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onTap: () async {
            // Implement Date Picker
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _inputFill,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedGender,
              dropdownColor: _card,
              isExpanded: true,
              icon:
                  const Icon(Icons.keyboard_arrow_down, color: _textSecondary),
              style: const TextStyle(color: _textPrimary, fontSize: 14),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() => _selectedGender = newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.save, color: Colors.white),
        label: const Text(
          'Save Changes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildDiscardButton() {
    return TextButton(
      onPressed: () => context.pop(),
      child: const Text(
        'Discard changes',
        style: TextStyle(
          color: _textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
