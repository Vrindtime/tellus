import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:tellus/views/screens/accountant/add_party_details_page.dart';
import 'package:tellus/views/widgets/list_tile_widget.dart';
import 'package:tellus/views/widgets/search_text_field_widget.dart';

class PartyDetailsPage extends StatefulWidget {
  const PartyDetailsPage({super.key});

  @override
  State<PartyDetailsPage> createState() => _PartyDetailsPageState();
}

class _PartyDetailsPageState extends State<PartyDetailsPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _partyMembers = [
    {'title': 'John Doe', 'subtitle': '1234567890', 'page': Placeholder()},
    {'title': 'Jane Smith', 'subtitle': '9876543210', 'page': Placeholder()},
    {'title': 'Alice Johnson', 'subtitle': '4567891230', 'page': Placeholder()},
  ];
  List<Map<String, dynamic>> _filteredMembers = [];

  @override
  void initState() {
    super.initState();
    _filteredMembers = _partyMembers;
    _searchController.addListener(_filterMembers);
  }

  void _filterMembers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMembers =
          _partyMembers
              .where(
                (member) =>
                    member['title'].toLowerCase().contains(query) ||
                    member['subtitle'].contains(query),
              )
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
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
                    child: SearchTextField(
                      label: 'Search Party',
                      controller: _searchController,
                      suggestionsCallback: (query) async => [],
                      onSuggestionSelected: (_) {},
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeftWithFade,
                          child: AddPartyDetailsPage(),
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
              child: ListTileWidget(
                items:
                    _filteredMembers
                        .map(
                          (member) => {
                            'title': member['title'],
                            'page': member['page'],
                          },
                        )
                        .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
