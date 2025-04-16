import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tellus/services/admin/admin_controller.dart';
import 'package:tellus/views/widgets/dropdown_widget.dart';
import 'package:tellus/views/widgets/text_input_widget.dart';
import 'package:tellus/views/widgets/custom_size_button.dart';

class CreateUserPage extends StatelessWidget {
  final bool isEdit;
  final String userId;
  final String name;
  final String phone;
  final String role;

  const CreateUserPage({
    super.key,
    this.isEdit = false,
    this.userId = '',
    this.name = '',
    this.phone = '',
    this.role = '',
  });

  @override
  Widget build(BuildContext context) {
    final AdminUserController controller = Get.put(AdminUserController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isEdit) {
        controller.nameController.text = name;
        controller.phoneController.text = phone;
        controller.selectedRole.value = role;
      } else {
        controller.resetState(); // Reset state for creating a new user
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit User' : 'Create User'),
        centerTitle: true,
        forceMaterialTransparency: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextInput(
              label: 'Name',
              controller: controller.nameController,
              icon: Icons.person,
            ),
            const SizedBox(height: 10),
            CustomTextInput(
              label: 'Phone Number',
              controller: controller.phoneController,
              icon: Icons.phone,
            ),
            const SizedBox(height: 10),
            Obx(
              () => CustomDropdown(
                label: 'Select Role',
                items: controller.roles,
                selectedValue: controller.selectedRole.value,
                onChanged: (value) {
                  controller.selectedRole.value = value!;
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a Role';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomSubmitButton(
                    text: isEdit ? 'Update User' : 'Create User',
                    isLoading: false,
                    onTap:
                        isEdit
                            ? () => controller.updateUser(userId)
                            : controller.createUser,
                  ),
                ),
                if (isEdit) const SizedBox(width: 10),
                if (isEdit)
                  Expanded(
                    child: CustomSubmitButton(
                      text: 'Delete User',
                      isLoading:
                          false, // Replace with actual loading state if needed
                      onTap: () => controller.deleteUser(userId),
                      backgroundColor: Colors.red,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
