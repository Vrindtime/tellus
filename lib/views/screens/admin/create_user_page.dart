import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tellus/services/admin/new_employee_controller.dart';
import 'package:tellus/views/widgets/custom_size_button.dart';
import 'package:tellus/views/widgets/dropdown_widget.dart';
import 'package:tellus/views/widgets/file_list_widget.dart';
import 'package:tellus/views/widgets/text_input_widget.dart';


class CreateUserEmployeePage extends StatefulWidget {
  final bool isEdit;
  final String userId; // Only for edit
  const CreateUserEmployeePage({super.key, this.isEdit = false, this.userId = ''});
  @override
  State<CreateUserEmployeePage> createState() => _CreateUserEmployeePageState();
}

class _CreateUserEmployeePageState extends State<CreateUserEmployeePage> {
  late final UserEmployeeController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(UserEmployeeController());
    if (widget.isEdit && widget.userId.isNotEmpty) {
      controller.loadUserAndEmployee(widget.userId);
    } else {
      controller.resetForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final double scaleFactor = width / 360;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Update Employee' : 'Create Employee', style: Theme.of(context).textTheme.titleLarge),
        centerTitle: true,
        actions: widget.isEdit
            ? [
                IconButton(
                  icon: const Icon(Icons.delete,color: Colors.red,),
                  onPressed: () {
                    controller.deleteUser(widget.userId);
                  },
                )
              ]
            : null,
      ),
      body: Obx(() => controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _ProfilePicWidget(controller: controller),
            const SizedBox(height: 10),
            CustomTextInput(
              label: 'Name',
              controller: controller.nameController,
              icon: Icons.person,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Obx(() => CustomDropdown(
                    label: 'Country',
                    selectedValue: controller.selectedCountryCode.value,
                    items: controller.countryCodeList,
                    onChanged: (val) => controller.selectedCountryCode.value = val??'+91',
                  )),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomTextInput(
                    controller: controller.phoneController,
                    icon: Icons.phone,
                    label: 'Phone',
                    keyboardType: TextInputType.phone,
                  ),
                )
              ]
            ),
            const SizedBox(height: 10),
            CustomTextInput(
              label: 'Address',
              controller: controller.addressController,
              icon: Icons.home,
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async { await controller.pickDob(context); setState((){}); },
              child: AbsorbPointer(
                child: CustomTextInput(
                  label: 'Date of Birth',
                  controller: controller.dobController,
                  icon: Icons.calendar_today,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Obx(() => CustomDropdown(
              label: 'Role',
              selectedValue: controller.selectedRole.value,
              items: controller.roles,
              onChanged: (val) => controller.selectedRole.value = val??'driver',
            )),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12 * scaleFactor)
              ),
              color: Theme.of(context).cardColor,
            child: Container(
              height: 130 * scaleFactor,
              width: double.infinity,
              padding: EdgeInsets.all(8.0 * scaleFactor),
              child: Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomDropdown(
                    label: 'Salary Type',
                    selectedValue: controller.salaryType.value,
                    items: const ['Fixed', 'Hour', 'Work'],
                    onChanged: (val) => controller.salaryType.value = val ?? 'Fixed',
                  ),
                  const SizedBox(height: 10),
                  if (controller.salaryType.value == 'Fixed')
                    CustomTextInput(
                      label: 'Fixed Salary',
                      controller: controller.fixedSalaryController,
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                    ),
                  if (controller.salaryType.value == 'Hour')
                    CustomTextInput(
                      label: 'Hourly Rate',
                      controller: controller.hourlyRateController,
                      icon: Icons.timer,
                      keyboardType: TextInputType.number,
                    ),
                  if (controller.salaryType.value == 'Work')
                    CustomTextInput(
                      label: 'Per Work Rate',
                      controller: controller.perWorkRateController,
                      icon: Icons.work,
                      keyboardType: TextInputType.number,
                    ),
                ],
              )),
            ),),
          const SizedBox(height: 10),
            CustomTextInput(
              label: 'Note (Optional)',
              controller: controller.noteController,
              icon: Icons.note_alt,
            ),
            const SizedBox(height: 10),
            _DocUploadWidget(controller: controller),
            const SizedBox(height: 20),
            CustomSubmitButton(
              text: widget.isEdit ? 'Update' : 'Create',
              isLoading: controller.isLoading.value,
              onTap: () => widget.isEdit
                ? controller.handleUpdate(widget.userId)
                : controller.handleCreate(),
            ),
            const SizedBox(height: 10),
            FileListWidget(fileUrls: controller.docsPaths)
          ],
        ),
      )),
    );
  }
}

class _ProfilePicWidget extends StatelessWidget {
  final UserEmployeeController controller;
  const _ProfilePicWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        controller.profilePicPath.value.isEmpty
          ? const CircleAvatar(radius: 28, child: Icon(Icons.person))
          : CircleAvatar(radius: 28, backgroundImage: NetworkImage(controller.profilePicPath.value)),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: controller.pickProfilePic,
          icon: const Icon(Icons.image),
          label: const Text('Upload Profile Pic'),
        ),
      ],
    );
  }
}

class _DocUploadWidget extends StatelessWidget {
  final UserEmployeeController controller;
  const _DocUploadWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.upload_file),
          label: const Text('Upload Documents'),
          onPressed: controller.pickDocuments,
        ),
        const SizedBox(width: 8),
        Obx(() => Text(
          controller.docsPaths.isNotEmpty ? "${controller.docsPaths.length} files" : "No document",
          style: Theme.of(context).textTheme.bodySmall,
        )),
      ],
    );
  }
}
