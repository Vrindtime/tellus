import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:appwrite/appwrite.dart';
import 'package:tellus/core/id.dart';
import 'package:tellus/services/auth/auth_service.dart';

class ExpenseModel {
  String? id;
  String organizationId;
  String vehicleId;
  String vehicleName;
  String category;
  double amount;
  String? description;
  DateTime date;
  String?
  billImagePath; // Stores the Appwrite preview URL or local path temporarily

  ExpenseModel({
    this.id,
    required this.organizationId,
    required this.vehicleId,
    required this.vehicleName,
    required this.category,
    required this.amount,
    this.description,
    required this.date,
    this.billImagePath,
  });

  // Convert model to JSON for Appwrite
  Map<String, dynamic> toJson() => {
    'organizationId': organizationId,
    'vehicleId': vehicleId,
    'vehicleName': vehicleName,
    'category': category,
    'amount': amount,
    'description': description,
    'date': date.toIso8601String(),
    'billImagePath': billImagePath,
  };

  // Create model from Appwrite document
  factory ExpenseModel.fromJson(Map<String, dynamic> json) => ExpenseModel(
    id: json['\$id'],
    organizationId: json['organizationId'],
    vehicleId: json['vehicleId'],
    vehicleName: json['vehicleName'],
    category: json['category'],
    amount: (json['amount'] as num).toDouble(),
    description: json['description'],
    date: DateTime.parse(json['date']),
    billImagePath: json['billImagePath'],
  );
}

// Expense Controller
class ExpenseController extends GetxController {
  final Databases databases = Get.find<Databases>();
  final Storage storage = Get.find<Storage>();
  final AuthService authService = Get.find<AuthService>();

  var expenses = <ExpenseModel>[].obs;
  var isLoading = false.obs;
  final _searchQuery = ''.obs;
  Function? onDataChanged;

  // Getter for search query
  String get searchQuery => _searchQuery.value;

  // Setter for search query
  set searchQuery(String value) => _searchQuery.value = value;

  // Filter expenses based on search query
  List<ExpenseModel> get filteredExpenses {
    final query = searchQuery.toLowerCase();
    if (query.isEmpty) {
      return expenses;
    }
    return expenses.where((expense) {
      return expense.vehicleName.toLowerCase().contains(query) ||
          expense.category.toLowerCase().contains(query) ||
          expense.amount.toString().contains(query) ||
          (expense.description?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  // Generate preview URL for a file
  String _generatePreviewUrl(String fileId) {
    return '${CId.endPoint}/v1/storage/buckets/${CId.expenseBucketId}/files/$fileId/view?project=${CId.project}&mode=admin';
  }

  // // Extract file ID from preview URL
  // String? _extractFileId(String? url) {
  //   if (url == null) return null;
  //   final regex = RegExp(r'/files/([^/]+)/preview');
  //   final match = regex.firstMatch(url);
  //   return match?.group(1);
  // }

  // Fetch all expense records
  Future<void> fetchExpenses() async {
    final orgId = authService.orgId.value;
    if (orgId.isEmpty) {
      throw Exception('Organization ID is not set. Please log in again.');
    }
    try {
      isLoading.value = true;
      final response = await databases.listDocuments(
        databaseId: CId.databaseId,
        collectionId: CId.expenseCollectionId,
        queries: [Query.equal('organizationId', orgId)],
      );
      expenses.assignAll(
        response.documents
            .map((doc) => ExpenseModel.fromJson(doc.data))
            .toList(),
      );
      onDataChanged?.call();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch expenses: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Add a new expense record
  Future<void> addExpense(ExpenseModel expense, String? billImagePath) async {
    try {
      isLoading.value = true;

      // Update expense model with billImagePath
      final expenseToSave = ExpenseModel(
        organizationId: expense.organizationId,
        vehicleId: expense.vehicleId,
        vehicleName: expense.vehicleName,
        category: expense.category,
        amount: expense.amount,
        description: expense.description,
        date: expense.date,
        billImagePath: billImagePath,
      );

      // Save expense to database
      final response = await databases.createDocument(
        databaseId: CId.databaseId,
        collectionId: CId.expenseCollectionId,
        documentId: 'unique()',
        data: expenseToSave.toJson(),
      );
      expenses.add(ExpenseModel.fromJson(response.data));
      Get.snackbar('Success', 'Expense added successfully');
      onDataChanged?.call();
    } catch (e) {
      Get.snackbar('Error', 'Failed to add expense: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Update an existing expense record
  Future<void> updateExpense(
    ExpenseModel expense,
    String? billImagePath,
    String id,
  ) async {
    try {
      isLoading.value = true;
      // String? billImagePath = expense.billImagePath;

      // Upload new bill image if provided
      // if (billImagePath != null) {
        // Delete old image if it exists

        // final fileId = billImagePath;
        // if (fileId != null) {
        //   await storage.deleteFile(
        //     bucketId: CId.expenseBucketId,
        //     fileId: fileId,
        //   );
        // }
        // final file = await storage.createFile(
        //   bucketId: CId.expenseBucketId,
        //   fileId: 'unique()',
        //   file: InputFile.fromPath(
        //     path: billImage.path,
        //     filename: billImage.name,
        //   ),
        // );
        // billImagePath = _generatePreviewUrl(file.$id);
      // }

      // Update expense model with new billImagePath
      final expenseToSave = ExpenseModel(
        organizationId: expense.organizationId,
        vehicleId: expense.vehicleId,
        vehicleName: expense.vehicleName,
        category: expense.category,
        amount: expense.amount,
        description: expense.description,
        date: expense.date,
        billImagePath: billImagePath,
      );

      final response = await databases.updateDocument(
        databaseId: CId.databaseId,
        collectionId: CId.expenseCollectionId,
        documentId: id,
        data: expenseToSave.toJson(),
      );
      final index = expenses.indexWhere((e) => e.id == id);
      if (index != -1) {
        expenses[index] = ExpenseModel.fromJson(response.data);
      }
      Get.snackbar('Success', 'Expense updated successfully');
      onDataChanged?.call();
    } catch (e) {
      print('Error: update expense: $e');
      Get.snackbar('Error', 'Failed to update expense: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Delete an expense record
  Future<void> deleteExpense(String id, String? billImagePath) async {
    try {
      isLoading.value = true;
      // Delete bill image if it exists
      // if (billImagePath != null) {
      //   final fileId = billImagePath;
      //   if (fileId != null) {
      //     await storage.deleteFile(
      //       bucketId: CId.expenseBucketId,
      //       fileId: fileId,
      //     );
      //   }
      // }
      await databases.deleteDocument(
        databaseId: CId.databaseId,
        collectionId: CId.expenseCollectionId,
        documentId: id,
      );
      expenses.removeWhere((e) => e.id == id);
      Get.snackbar('Success', 'Expense deleted successfully');
      onDataChanged?.call();
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete expense: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
