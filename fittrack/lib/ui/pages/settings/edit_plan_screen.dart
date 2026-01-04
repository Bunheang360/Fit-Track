import 'package:flutter/material.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../core/constants/enums.dart';
import '../../widgets/common/back_button.dart';

/// ============================================
/// EDIT PLAN SCREEN
/// ============================================
/// This screen allows users to change their:
/// 1. Workout Plan (Home or Gym)
/// 2. Fitness Categories (Abs, Arms, Back, etc.)
/// 3. Workout Days (Monday to Sunday)
/// ============================================

class EditPlanScreen extends StatefulWidget {
  // The current user data
  final User user;
  
  // Callback function to notify parent when changes are saved
  final Function(User) onSave;

  const EditPlanScreen({
    super.key,
    required this.user,
    required this.onSave,
  });

  @override
  State<EditPlanScreen> createState() => _EditPlanScreenState();
}

class _EditPlanScreenState extends State<EditPlanScreen> {
  // Repository to save user data to database
  final _userRepository = UserRepository();

  // ==========================================
  // STATE VARIABLES
  // ==========================================
  // These variables hold the user's selections
  // They are initialized with the user's current values
  
  late Plan _selectedPlan;              // Home or Gym
  late List<Categories> _selectedCategories;  // List of fitness goals
  late List<DayOfWeek> _selectedDays;   // List of workout days
  bool _isSaving = false;               // Shows loading spinner when true

  // ==========================================
  // INITIALIZATION
  // ==========================================
  @override
  void initState() {
    super.initState();
    // Copy the user's current selections
    // We use List.from() to create a copy, not a reference
    _selectedPlan = widget.user.selectedPlan;
    _selectedCategories = List.from(widget.user.selectedCategories);
    _selectedDays = List.from(widget.user.selectedDays);
  }

  // ==========================================
  // SAVE CHANGES TO DATABASE
  // ==========================================
  Future<void> _saveChanges() async {
    // Step 1: Validate - make sure user selected at least one category
    if (_selectedCategories.isEmpty) {
      _showError('Please select at least one category');
      return;
    }

    // Step 2: Validate - make sure user selected at least one day
    if (_selectedDays.isEmpty) {
      _showError('Please select at least one workout day');
      return;
    }

    // Step 3: Show loading spinner
    setState(() {
      _isSaving = true;
    });

    try {
      // Step 4: Create updated user with new selections
      // We keep all the old data but update plan, categories, and days
      final updatedUser = User(
        id: widget.user.id,
        name: widget.user.name,
        email: widget.user.email,
        password: widget.user.password,
        age: widget.user.age,
        gender: widget.user.gender,
        weight: widget.user.weight,
        height: widget.user.height,
        selectedPlan: _selectedPlan,           // Updated
        selectedLevel: widget.user.selectedLevel,
        selectedCategories: _selectedCategories, // Updated
        selectedDays: _selectedDays,            // Updated
        hasCompletedAssessment: widget.user.hasCompletedAssessment,
      );

      // Step 5: Save to database
      await _userRepository.saveUser(updatedUser);

      // Step 6: If still on this screen, notify parent and go back
      if (mounted) {
        widget.onSave(updatedUser);
        _showSuccess('Plan updated successfully!');
        Navigator.pop(context);
      }
    } catch (e) {
      // If something went wrong, show error message
      _showError('Failed to save changes. Please try again.');
    } finally {
      // Step 7: Hide loading spinner
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ==========================================
  // HELPER METHODS FOR SHOWING MESSAGES
  // ==========================================
  
  /// Shows a red error message at the bottom of the screen
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Shows a green success message at the bottom of the screen
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  // ==========================================
  // MAIN BUILD METHOD - Creates the UI
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      // App Bar with back button and title
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const OrangeBackButton(),
        leadingWidth: 90,
        title: const Text(
          'Edit Plan',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      
      // Main content - scrollable
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Workout Plan (Home/Gym)
            _buildSectionTitle('Workout Plan'),
            const SizedBox(height: 12),
            _buildPlanSelection(),
            const SizedBox(height: 32),

            // Section 2: Categories
            _buildSectionTitle('Categories'),
            const SizedBox(height: 4),
            Text(
              'Select your fitness goals',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            _buildCategoriesSelection(),
            const SizedBox(height: 32),

            // Section 3: Schedule
            _buildSectionTitle('Workout Schedule'),
            const SizedBox(height: 4),
            Text(
              'Choose your workout days',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            _buildScheduleSelection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
      
      // Save button at the bottom
      bottomNavigationBar: _buildSaveButton(),
    );
  }

  // ==========================================
  // UI BUILDING METHODS
  // ==========================================

  /// Creates a section title text
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
      ),
    );
  }

  /// Creates the Save Changes button at the bottom
  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        // Disable button while saving
        onPressed: _isSaving ? null : _saveChanges,
        // Show spinner while saving, otherwise show text
        child: _isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Save Changes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  /// Creates the Home/Gym plan selection buttons
  Widget _buildPlanSelection() {
    return Row(
      children: [
        // Home Plan Button
        Expanded(
          child: _buildPlanButton(Plan.home, Icons.home),
        ),
        const SizedBox(width: 16),
        // Gym Plan Button
        Expanded(
          child: _buildPlanButton(Plan.gym, Icons.fitness_center),
        ),
      ],
    );
  }

  /// Creates a single plan button (Home or Gym)
  Widget _buildPlanButton(Plan plan, IconData icon) {
    final isSelected = _selectedPlan == plan;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = plan;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          // Orange background if selected, white if not
          color: isSelected ? Colors.orange[800] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.orange[800]! : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.orange[800],
              size: 36,
            ),
            const SizedBox(height: 8),
            Text(
              plan.displayName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Creates the category chips that can be selected/deselected
  Widget _buildCategoriesSelection() {
    // Single row with all categories expanded to fill screen width
    return Row(
      children: Categories.values.map((category) {
        final index = Categories.values.toList().indexOf(category);
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 6,
              right: index == Categories.values.length - 1 ? 0 : 6,
            ),
            child: _buildCategoryChip(category),
          ),
        );
      }).toList(),
    );
  }

  /// Creates a single category chip
  Widget _buildCategoryChip(Categories category) {
    final isSelected = _selectedCategories.contains(category);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          // Toggle selection: add if not selected, remove if selected
          if (isSelected) {
            _selectedCategories.remove(category);
          } else {
            _selectedCategories.add(category);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange[800] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.orange[800]! : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            category.displayName,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  /// Creates the day selection grid (Mon-Sun)
  Widget _buildScheduleSelection() {
    // Day names to display
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    // Use Row with Expanded to spread days across screen
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final day = DayOfWeek.values[index];
        return _buildDayButton(day, dayNames[index]);
      }),
    );
  }

  /// Creates a single day button
  Widget _buildDayButton(DayOfWeek day, String dayName) {
    final isSelected = _selectedDays.contains(day);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            // Toggle selection: add if not selected, remove if selected
            if (isSelected) {
              _selectedDays.remove(day);
            } else {
              _selectedDays.add(day);
            }
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 70,
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange[800] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.orange[800]! : Colors.grey[300]!,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Show checkmark if selected
              if (isSelected)
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
              if (isSelected) 
                const SizedBox(height: 4),
              // Day name text
              Text(
                dayName,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
