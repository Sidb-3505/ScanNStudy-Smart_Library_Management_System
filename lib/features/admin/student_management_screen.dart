import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../models/student_model.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/validators.dart';
import '../../widgets/cards/student_card.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_textfield.dart';

class StudentManagementScreen extends StatefulWidget {
  const StudentManagementScreen({super.key});

  @override
  State<StudentManagementScreen> createState() =>
      _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showStudentForm({Student? student}) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl =
        TextEditingController(text: student?.name ?? '');
    final idCtrl =
        TextEditingController(text: student?.collegeId ?? '');
    final pwCtrl =
        TextEditingController(text: student?.password ?? '');
    final deptCtrl =
        TextEditingController(text: student?.department ?? '');
    final yearCtrl =
        TextEditingController(text: student?.year ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                student == null
                    ? AppStrings.addStudent
                    : AppStrings.editStudent,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: AppStrings.name,
                hint: AppStrings.enterName,
                controller: nameCtrl,
                validator: AppValidators.name,
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: AppStrings.collegeId,
                hint: AppStrings.enterCollegeId,
                controller: idCtrl,
                validator: AppValidators.collegeId,
                prefixIcon: Icons.badge_outlined,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: AppStrings.password,
                hint: 'Set password',
                controller: pwCtrl,
                validator: AppValidators.password,
                isPassword: true,
                prefixIcon: Icons.lock_outline,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: AppStrings.department,
                hint: AppStrings.enterDepartment,
                controller: deptCtrl,
                validator: AppValidators.required,
                prefixIcon: Icons.school_outlined,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: AppStrings.year,
                hint: AppStrings.enterYear,
                controller: yearCtrl,
                validator: AppValidators.required,
                prefixIcon: Icons.grade_outlined,
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: AppStrings.save,
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  final provider = context.read<UserProvider>();
                  if (student == null) {
                    provider.addStudent(Student(
                      id: provider.generateStudentId(),
                      name: nameCtrl.text.trim(),
                      collegeId: idCtrl.text.trim(),
                      password: pwCtrl.text.trim(),
                      department: deptCtrl.text.trim(),
                      year: yearCtrl.text.trim(),
                    ));
                  } else {
                    provider.updateStudent(student.copyWith(
                      name: nameCtrl.text.trim(),
                      collegeId: idCtrl.text.trim(),
                      password: pwCtrl.text.trim(),
                      department: deptCtrl.text.trim(),
                      year: yearCtrl.text.trim(),
                    ));
                  }
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.deleteStudent),
        content: Text('Delete "$name"? ${AppStrings.confirmDelete}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<UserProvider>().deleteStudent(id);
              Navigator.pop(context);
            },
            child: const Text(
              AppStrings.confirm,
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final students = provider.searchStudents(_query);

    return Scaffold(
      appBar: AppBar(title: const Text('Student Management')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showStudentForm(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: AppStrings.searchStudents,
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: students.isEmpty
                ? const Center(
                    child: Text(
                      AppStrings.noStudentsFound,
                      style: TextStyle(color: AppColors.textLight),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingMedium,
                    ),
                    itemCount: students.length,
                    itemBuilder: (_, i) => StudentCard(
                      student: students[i],
                      onEdit: () => _showStudentForm(student: students[i]),
                      onDelete: () => _confirmDelete(
                        context,
                        students[i].id,
                        students[i].name,
                      ),
                      onToggleBlock: () =>
                          provider.toggleBlock(students[i].id),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
