import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../models/student_model.dart';
import '../../providers/user_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_textfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _rollCtrl = TextEditingController();
  final _deptCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  // Year dropdown options
  final List<String> _years = ['1st', '2nd', '3rd', '4th'];
  String _selectedYear = '1st';

  // Department options
  final List<String> _departments = [
    'Computer Science',
    'Electronics',
    'Mechanical',
    'Civil',
    'Electrical',
    'Information Technology',
    'Other',
  ];
  String _selectedDept = 'Computer Science';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _rollCtrl.dispose();
    _deptCtrl.dispose();
    _yearCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  /// Auto-fills email when name + roll number are filled
  void _autoFillEmail() {
    final name = _nameCtrl.text.trim().toLowerCase().split(' ').first;
    final roll = _rollCtrl.text.trim().toLowerCase();
    if (name.isNotEmpty && roll.isNotEmpty) {
      _emailCtrl.text = '$name.$roll@jecrcu.edu.in';
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    // Check passwords match
    if (_passCtrl.text != _confirmPassCtrl.text) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final provider = context.read<UserProvider>();

    // Check if college ID already registered
    final existing = provider.getStudentByCollegeId(_rollCtrl.text.trim());
    if (existing != null) {
      setState(() {
        _errorMessage = 'This Roll Number is already registered.';
        _isLoading = false;
      });
      return;
    }

    final newStudent = Student(
      id: provider.generateStudentId(),
      name: _nameCtrl.text.trim(),
      collegeId: _rollCtrl.text.trim(),
      password: _passCtrl.text.trim(),
      department: _selectedDept,
      year: _selectedYear,
    );

    await provider.addStudent(newStudent);

    setState(() => _isLoading = false);

    if (!mounted) return;

    // Show success and go to login
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registration successful! Please login.'),
        backgroundColor: AppColors.secondary,
      ),
    );
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Student Registration'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_add_rounded,
                          size: 48,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Create Your Account',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Register with your college details',
                        style: TextStyle(color: AppColors.textLight),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ── Full Name ──────────────────────────────────────────
                CustomTextField(
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  controller: _nameCtrl,
                  validator: AppValidators.name,
                  prefixIcon: Icons.person_outline,
                  onChanged: (_) => _autoFillEmail(),
                ),
                const SizedBox(height: 16),

                // ── Roll Number ────────────────────────────────────────
                CustomTextField(
                  label: 'Roll Number',
                  hint: 'e.g. CS2021001',
                  controller: _rollCtrl,
                  validator: AppValidators.collegeId,
                  prefixIcon: Icons.badge_outlined,
                  onChanged: (_) => _autoFillEmail(),
                ),
                const SizedBox(height: 16),

                // ── College Email (auto-filled, read only) ─────────────
                CustomTextField(
                  label: 'College Email (Auto-filled)',
                  hint: 'name.rollno@jecrcu.edu.in',
                  controller: _emailCtrl,
                  validator: AppValidators.collegeEmail,
                  prefixIcon: Icons.email_outlined,
                  readOnly: true, // auto-filled — student can't edit
                ),
                const SizedBox(height: 4),
                const Text(
                  '  Auto-generated from your name & roll number',
                  style: TextStyle(fontSize: 11, color: AppColors.textLight),
                ),
                const SizedBox(height: 16),

                // ── Department dropdown ────────────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Department',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedDept,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.school_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: _departments
                          .map(
                            (d) => DropdownMenuItem(value: d, child: Text(d)),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedDept = v ?? _selectedDept),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Year dropdown ──────────────────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Year',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedYear,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.grade_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: _years
                          .map(
                            (y) => DropdownMenuItem(
                              value: y,
                              child: Text('$y Year'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedYear = v ?? _selectedYear),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Password ───────────────────────────────────────────
                CustomTextField(
                  label: 'Password',
                  hint: 'Create a password',
                  controller: _passCtrl,
                  validator: AppValidators.password,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                ),
                const SizedBox(height: 16),

                // ── Confirm Password ───────────────────────────────────
                CustomTextField(
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  controller: _confirmPassCtrl,
                  validator: AppValidators.password,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                ),
                const SizedBox(height: 8),

                // Error message
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 4),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: AppColors.danger,
                        fontSize: 13,
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // Register button
                CustomButton(
                  text: 'Register',
                  onPressed: _register,
                  isLoading: _isLoading,
                  icon: Icons.person_add_rounded,
                ),
                const SizedBox(height: 16),

                // Already have account
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.login,
                    ),
                    child: const Text.rich(
                      TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(color: AppColors.textLight),
                        children: [
                          TextSpan(
                            text: 'Login',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
