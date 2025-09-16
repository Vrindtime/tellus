import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:tellus/services/admin/organization_controller.dart';
import 'package:tellus/views/screens/auth/add_organization_page.dart';
import 'package:tellus/views/screens/common/privacy_policy_page.dart';
import 'package:tellus/views/widgets/submit_button.dart';
import 'package:tellus/views/widgets/text_input_widget.dart';

class OrganizationPage extends StatefulWidget {
  const OrganizationPage({super.key});

  @override
  _OrganizationPageState createState() => _OrganizationPageState();
}

class _OrganizationPageState extends State<OrganizationPage> {
  final OrganizationController _orgController = Get.put(
    OrganizationController(),
  );
  final TextEditingController _orgTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(forceMaterialTransparency: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(26.0),
          child: SingleChildScrollView(
            child: Column(
              spacing: 17,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(),
                _buildTitle(context),
                _buildSearchTextField(),
                _buildSubmitButton(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.12),
                _buildRegistrationPrompt(context),
                _buildPrivacyPolicyLink(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Image.asset('assets/images/tellus_logo.png', height: 200),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      'Select Organization',
      style: Theme.of(context).textTheme.headlineLarge,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSearchTextField() {
    return CustomTextInput(
      label: 'Enter your Organization',
      controller: _orgTextController,
      icon: Icons.business,
    );
    // return SearchTextField(
    //   label: 'Enter your Organization',
    //   controller: _orgTextController,
    //   suggestionsCallback: _orgController.getOrgSuggestions,
    //   onSuggestionSelected: (suggestion) {
    //     _orgTextController.text = suggestion['name']!;
    //     FocusScope.of(context).unfocus();
    //   },
    // );
  }

  Widget _buildSubmitButton() {
    return Obx(
      () => SubmitButton(
        text: "Submit",
        isLoading: _orgController.isLoading.value,
        onTap: () {
          _orgController.selectedOrg.value = _orgTextController.text;
          _orgController.selectOrgAndNavigate(_orgTextController);

          debugPrint(
            '----- Selected Org: ${_orgController.selectedOrg.value} -----',
          );
          _orgTextController.clear();
        },
      ),
    );
  }

  Widget _buildRegistrationPrompt(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Not Registered? ',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.black),
            ),
            GestureDetector(
              onTap: () async {
                // Open the modal bottom sheet to add a new organization.
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const AddOrganizationModal(),
                );
                Get.back();
              },
              child: Text(
                'Add Organization',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: _openFindOrgByPhone,
          child: Text(
            'Forgot org? Find by phone number',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyPolicyLink(BuildContext context) {
    return GestureDetector(
      onTap: _navigateToPrivacyPolicy,
      child: Text(
        'Privacy Policy',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  // void _handleContactAdmin() {
  //   Navigator.push(
  //     context,
  //     PageTransition(
  //       type: PageTransitionType.bottomToTop,
  //       child: const AddOrganizationPage(),
  //       childCurrent: widget,
  //     ),
  //   );
  // }

  void _navigateToPrivacyPolicy() {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.bottomToTop,
        child: const PrivacyPolicyPage(),
        childCurrent: widget,
      ),
    );
  }

  void _openFindOrgByPhone() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _FindOrgByPhoneModal(orgController: _orgController),
    );
  }
}

class _FindOrgByPhoneModal extends StatefulWidget {
  final OrganizationController orgController;
  const _FindOrgByPhoneModal({required this.orgController});

  @override
  State<_FindOrgByPhoneModal> createState() => _FindOrgByPhoneModalState();
}

class _FindOrgByPhoneModalState extends State<_FindOrgByPhoneModal> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, String>> _results = [];

  @override
  Widget build(BuildContext context) {
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
            label: 'Enter your phone number',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            icon: Icons.phone,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _isLoading ? null : _onFind,
                child:
                    _isLoading
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Find'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_results.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                ..._results.map(
                  (e) => ListTile(
                    leading: const Icon(Icons.business),
                    title: Text(e['orgName'] ?? ''),
                    subtitle: Text('ID: ${e['orgId'] ?? ''}'),
                    onTap: () {
                      widget.orgController.selectedOrg.value = e['orgId']!;
                      Navigator.pop(context);
                      Get.toNamed('/login');
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _onFind() async {
    final raw = _phoneController.text.trim();
    final digitsOnly = raw.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digitsOnly.replaceAll(RegExp(r'[^0-9]'), '').length < 10) {
      Get.snackbar('Error', 'Please enter a valid phone number');
      return;
    }
    setState(() => _isLoading = true);
    final res = await widget.orgController.findOrganizationsByPhone(digitsOnly);
    setState(() {
      _results = res;
      _isLoading = false;
    });
    if (res.isEmpty) {
      Get.snackbar('Not found', 'No organizations linked to this phone');
    }
  }
}
