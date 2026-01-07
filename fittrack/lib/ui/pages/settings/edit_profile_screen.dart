import 'package:flutter/material.dart';
import '../../../core/models/user.dart';
import '../../../services/user_service.dart';
import '../../../core/constants/enums.dart';
import '../../utils/snackbar_utils.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/common/back_button.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;
  final Function(User) onSave;

  const EditProfileScreen({
    super.key,
    required this.user,
    required this.onSave,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _userService = UserService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late int _age;
  late double _weight;
  late double _height;
  late Level _selectedLevel;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _age = widget.user.age;
    _weight = widget.user.weight;
    _height = widget.user.height;
    _selectedLevel = widget.user.selectedLevel;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final result = await _userService.updateProfile(
      currentUser: widget.user,
      name: _nameController.text,
      email: _emailController.text,
      age: _age,
      weight: _weight,
      height: _height,
      level: _selectedLevel,
    );

    if (result.isSuccess && result.user != null) {
      if (mounted) {
        widget.onSave(result.user!);
        context.showSuccess('Profile updated successfully!');
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        context.showError(result.errorMessage ?? 'Failed to save profile');
      }
    }

    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = context.isSmallScreen;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const OrangeBackButton(),
        leadingWidth: 90,
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: isSmall ? 18 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isSmall ? 16 : 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name field
              _buildLabel('Name', isSmall),
              SizedBox(height: isSmall ? 6 : 8),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Enter your name', isSmall),
                style: TextStyle(fontSize: isSmall ? 14 : 16),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(height: isSmall ? 16 : 20),

              // Email field
              _buildLabel('Email', isSmall),
              SizedBox(height: isSmall ? 6 : 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration('Enter your email', isSmall),
                style: TextStyle(fontSize: isSmall ? 14 : 16),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: isSmall ? 16 : 20),

              // Age slider
              _buildLabel('Age: $_age years', isSmall),
              _buildSlider(
                value: _age.toDouble(),
                min: 13,
                max: 80,
                divisions: 67,
                onChanged: (value) => setState(() => _age = value.toInt()),
              ),
              SizedBox(height: isSmall ? 12 : 16),

              // Weight slider
              _buildLabel('Weight: ${_weight.toStringAsFixed(1)} kg', isSmall),
              _buildSlider(
                value: _weight,
                min: 30,
                max: 150,
                divisions: 240,
                onChanged: (value) => setState(() => _weight = value),
              ),
              SizedBox(height: isSmall ? 12 : 16),

              // Height slider
              _buildLabel('Height: ${_height.toStringAsFixed(0)} cm', isSmall),
              _buildSlider(
                value: _height,
                min: 120,
                max: 220,
                divisions: 100,
                onChanged: (value) => setState(() => _height = value),
              ),
              SizedBox(height: isSmall ? 20 : 24),

              // Level selection
              _buildLabel('Fitness Level', isSmall),
              SizedBox(height: isSmall ? 10 : 12),
              _buildLevelSelection(isSmall),
              SizedBox(height: isSmall ? 24 : 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(isSmall ? 16 : 20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            minimumSize: Size.fromHeight(isSmall ? 48 : 55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _isSaving ? null : _saveProfile,
          child: _isSaving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  'Save Profile',
                  style: TextStyle(
                    fontSize: isSmall ? 16 : 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isSmall) {
    return Text(
      text,
      style: TextStyle(
        fontSize: isSmall ? 14 : 16,
        fontWeight: FontWeight.w600,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildSlider({
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return SliderTheme(
      data: SliderThemeData(
        activeTrackColor: Colors.orange[800],
        inactiveTrackColor: Colors.grey[300],
        thumbColor: Colors.orange[800],
        trackHeight: 6,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
        tickMarkShape: SliderTickMarkShape.noTickMark,
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        onChanged: onChanged,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, bool isSmall) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: isSmall ? 12 : 16,
        vertical: isSmall ? 12 : 16,
      ),
    );
  }

  Widget _buildLevelSelection(bool isSmall) {
    return Row(
      children: Level.values.map((level) {
        final isSelected = _selectedLevel == level;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: level == Level.values.first ? 0 : (isSmall ? 4 : 6),
              right: level == Level.values.last ? 0 : (isSmall ? 4 : 6),
            ),
            child: GestureDetector(
              onTap: () => setState(() => _selectedLevel = level),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: isSmall ? 10 : 14),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.orange[800] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.orange[800]! : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      level == Level.beginner
                          ? Icons.star_border
                          : level == Level.intermediate
                          ? Icons.star_half
                          : Icons.star,
                      color: isSelected ? Colors.white : Colors.orange[800],
                      size: isSmall ? 20 : 24,
                    ),
                    SizedBox(height: isSmall ? 2 : 4),
                    Text(
                      level.displayName,
                      style: TextStyle(
                        fontSize: isSmall ? 10 : 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
