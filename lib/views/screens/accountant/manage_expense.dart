import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:tellus/services/accountant/expense_controller.dart';
import 'package:tellus/views/screens/accountant/expense_page.dart';
import 'package:tellus/views/widgets/extras/custom_list_tile_widget.dart';
import 'package:tellus/views/widgets/extras/transcation_list_tile_widget.dart';
import 'package:tellus/views/widgets/text_input_widget.dart';

class ExpenseManagementPage extends StatefulWidget {
  const ExpenseManagementPage({super.key});

  @override
  State<ExpenseManagementPage> createState() => _ExpenseManagementPageState();
}

class _ExpenseManagementPageState extends State<ExpenseManagementPage> {
  final ExpenseController expenseController = Get.put(ExpenseController());
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    expenseController.fetchExpenses();
    searchController.addListener(() {
      expenseController.searchQuery = searchController.text; // Use setter
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Management'),
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
                        label: 'Search Expenses',
                        controller: searchController,
                        icon: Icons.search,
                        onChanged: (value) {
                          expenseController.searchQuery = value ?? '';
                        },
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeftWithFade,
                            child: const ExpensePage(),
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
              // In the ListView
              Expanded(
                child: Obx(() {
                  final expenses =
                      expenseController.filteredExpenses; // Use getter
                  if (expenses.isEmpty) {
                    return const Center(child: Text('No expenses found'));
                  }
                  return ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      return TransactionListTileWidget(
                        title: expense.vehicleName,
                        status: expense.category,
                        startdate: expense.date.toString().split(' ')[0],
                        total: expense.amount.toStringAsFixed(2),
                        onTap: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.rightToLeftWithFade,
                              child: ExpensePage(expense: expense),
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
