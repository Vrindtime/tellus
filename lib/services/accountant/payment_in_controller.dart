import 'package:appwrite/appwrite.dart';
import 'package:get/get.dart';
import 'package:tellus/core/id.dart';
import 'package:tellus/services/auth/auth_service.dart';

class PaymentInModel {
  String? id;
  String organizationId; // ID of the organization managing the payment
  String customerId;
  String customerName;
  double receivedAmount;
  String paymentType;
  DateTime date;

  PaymentInModel({
    this.id,
    required this.organizationId,
    required this.customerId,
    required this.customerName,
    required this.receivedAmount,
    required this.paymentType,
    required this.date,
  });

  // Convert model to JSON for Appwrite
  Map<String, dynamic> toJson() => {
    'organizationId': organizationId,
    'customerId': customerId,
    'customerName': customerName,
    'receivedAmount': receivedAmount,
    'paymentType': paymentType,
    'date': date.toIso8601String(),
  };

  // Create model from Appwrite document
  factory PaymentInModel.fromJson(Map<String, dynamic> json) => PaymentInModel(
    id: json['\$id'],
    organizationId: json['organizationId'],
    customerId: json['customerId'],
    customerName: json['customerName'],
    receivedAmount: (json['receivedAmount'] as num).toDouble(),
    paymentType: json['paymentType'],
    date: DateTime.parse(json['date']),
  );
}

class PaymentInController extends GetxController {
  final Databases databases = Get.find<Databases>();
  final AuthService authService = Get.find<AuthService>();


  var paymentBookings = <PaymentInModel>[].obs;
  var isLoading = false.obs;
  Function? onDataChanged; // Callback for data changes

  // Fetch all payment records
  Future<void> fetchPaymentIn() async {
    final orgId = authService.orgId.value;
    if (orgId.isEmpty) {
      throw Exception('Organization ID is not set. Please log in again.');
    }
    try {
      isLoading.value = true;
      final response = await databases.listDocuments(
        databaseId: CId.databaseId,
        collectionId: CId.paymentCollectionId,
        queries: [Query.equal('organizationId', orgId)],
      );
      paymentBookings.assignAll(
        response.documents
            .map((doc) => PaymentInModel.fromJson(doc.data))
            .toList(),
      );
      onDataChanged?.call(); // Trigger callback
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch payments: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Add a new payment record
  Future<void> addPaymentIn(PaymentInModel paymentIn) async {
    try {
      isLoading.value = true;
      final response = await databases.createDocument(
        databaseId: CId.databaseId,
        collectionId: CId.paymentCollectionId,
        documentId: 'unique()',
        data: paymentIn.toJson(),
      );
      paymentBookings.add(PaymentInModel.fromJson(response.data));
      Get.snackbar('Success', 'Payment added successfully');
      onDataChanged?.call(); // Trigger callback
    } catch (e) {
      Get.snackbar('Error', 'Failed to add payment: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Update an existing payment record
  Future<void> updatePaymentIn(PaymentInModel paymentIn, String id) async {
    try {
      isLoading.value = true;
      final response = await databases.updateDocument(
        databaseId: CId.databaseId,
        collectionId: CId.paymentCollectionId,
        documentId: id,
        data: paymentIn.toJson(),
      );
      final index = paymentBookings.indexWhere((p) => p.id == id);
      if (index != -1) {
        paymentBookings[index] = PaymentInModel.fromJson(response.data);
      }
      Get.snackbar('Success', 'Payment updated successfully');
      onDataChanged?.call(); // Trigger callback
    } catch (e) {
      Get.snackbar('Error', 'Failed to update payment: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Delete a payment record
  Future<void> deletePaymentIn(String id) async {
    try {
      isLoading.value = true;
      await databases.deleteDocument(
        databaseId: CId.databaseId,
        collectionId: CId.paymentCollectionId,
        documentId: id,
      );
      paymentBookings.removeWhere((p) => p.id == id);
      Get.snackbar('Success', 'Payment deleted successfully');
      onDataChanged?.call(); // Trigger callback
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete payment: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
