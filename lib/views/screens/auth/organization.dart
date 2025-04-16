import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:tellus/services/auth/organization_controller.dart';
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
  final OrganizationController _orgController = Get.put(OrganizationController());
  final TextEditingController _orgTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
      ),
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
    return Row(
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
          },
          child: Text(
            'Add Organization',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
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
}
