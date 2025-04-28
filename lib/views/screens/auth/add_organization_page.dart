import 'package:animation_list/animation_list.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tellus/services/admin/organization_controller.dart';
import 'package:tellus/views/widgets/submit_button.dart';
import 'package:tellus/views/widgets/text_input_widget.dart';

class AddOrganizationPage extends StatefulWidget {
  const AddOrganizationPage({Key? key}) : super(key: key);

  @override
  _AddOrganizationPageState createState() => _AddOrganizationPageState();
}

class _AddOrganizationPageState extends State<AddOrganizationPage> {
  final OrganizationController orgController = Get.find<OrganizationController>();
  final TextEditingController searchController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Organizations",
          style: TextStyle(fontSize: 20),
        ),
        centerTitle: true,
        forceMaterialTransparency: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: orgController.getOrgs(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No organizations found.'));
            }
            final allOrgs = snapshot.data!;
            // Optionally filter based on the search query.
            final filteredOrgs = searchController.text.isEmpty
                ? allOrgs
                : allOrgs.where((org) {
                    return org['orgName']
                        .toString()
                        .toLowerCase()
                        .contains(searchController.text.toLowerCase());
                  }).toList();

            return OrganizationListTileWidget(items: filteredOrgs);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          // Open the modal bottom sheet to add a new organization.
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const AddOrganizationModal(),
          );
        },
      ),
    );
  }
}

class AddOrganizationModal extends StatefulWidget {
  const AddOrganizationModal({Key? key}) : super(key: key);

  @override
  _AddOrganizationModalState createState() => _AddOrganizationModalState();
}

class _AddOrganizationModalState extends State<AddOrganizationModal> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController orgNameController = TextEditingController();
  final TextEditingController phoneNumbersController = TextEditingController();
  final OrganizationController orgController = Get.find<OrganizationController>();
  
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    // Padding to account for the keyboard.
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextInput(
            controller: userNameController,
            icon: Icons.person,
            label: 'Enter User Name',
          ),
          const SizedBox(height: 16),
          CustomTextInput(
            controller: orgNameController,
            icon: Icons.business,
            label: 'Enter Organization Name',
          ),
          const SizedBox(height: 16),
          CustomTextInput(
            controller: phoneNumbersController,
            icon: Icons.phone,
            label: 'Enter Phone Number (+911234567890)',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),
          SubmitButton(
            text: 'Add Org',
            isLoading: isLoading,
            onTap: () async {
              String orgName = orgNameController.text.trim();
              String userName = userNameController.text.trim();
              String phoneNumbersStr = phoneNumbersController.text.trim();
              if (orgName.isEmpty || phoneNumbersStr.isEmpty || userName.isEmpty) {
                Get.snackbar('Error', 'Please fill in all fields.');
                return;
              }
              setState(() {
                isLoading = true;
              });
              Get.back();
              // Call the controller's addOrganization method.
              Document? newOrg = await orgController.addOrganization(orgName, phoneNumbersStr, userName);
              if (newOrg != null) {
                Get.snackbar('Success', 'Organization added.');
              } else {
                Get.snackbar('Error', 'Failed to add organization.');
              }
              setState(() {
                isLoading = false;
              });
              // Close the modal.
              
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class OrganizationListTileWidget extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const OrganizationListTileWidget({required this.items, Key? key})
      : super(key: key);

  /// Builds a tile for each organization using its name.
  Widget _buildTile(String orgName, BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.075,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Text(
          orgName,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimationList(
      duration: 1200,
      animationDirection: AnimationDirection.horizontal,
      children: items.map((item) {
        return _buildTile(item['orgName'] ?? 'Unnamed Organization', context);
      }).toList(),
    );
  }
}
