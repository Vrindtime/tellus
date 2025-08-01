import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:tellus/views/screens/accountant/add_party_details_page.dart';
import 'package:tellus/views/widgets/extras/custom_list_tile_widget.dart';
import 'package:get/get.dart';
import 'package:tellus/services/accountant/party_controller.dart';
import 'package:tellus/views/widgets/text_input_widget.dart';

class PartyDetailsPage extends StatefulWidget {
  const PartyDetailsPage({super.key});

  @override
  State<PartyDetailsPage> createState() => _PartyDetailsPageState();
}

class _PartyDetailsPageState extends State<PartyDetailsPage> {
  final PartyController partyController = Get.put(PartyController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Party Details'),
        centerTitle: true,
        forceMaterialTransparency: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.067,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: CustomTextInput(
                        label: 'Search Party',
                        controller: partyController.searchController,
                        icon: Icons.search,
                        onChanged: (value) {
                          partyController.searchQuery.value = value ?? '';
                        },
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeftWithFade,
                            child: const AddPartyDetailsPage(),
                          ),
                        );
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.width * 0.1,
                        width: MediaQuery.of(context).size.width * 0.1,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  final parties = partyController.filteredParties;
                  if (parties.isEmpty) {
                    return const Center(child: Text('No parties found'));
                  }
                  return ListView.builder(
                    itemCount: parties.length,
                    itemBuilder: (context, index) {
                      final party = parties[index];
                      return UserListTileWidget(
                        title: party.name,
                        subtitle: party.phoneNumber,
                        avatarUrl: party.pfp,
                        onTap: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.rightToLeftWithFade,
                              child: AddPartyDetailsPage(party: party),
                            ),
                          );
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
