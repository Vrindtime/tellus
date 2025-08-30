import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:appwrite/appwrite.dart';
import 'package:tellus/core/id.dart';
import 'package:tellus/services/auth/auth_service.dart';
import 'package:tellus/models/payroll_model.dart';

class PayrollController extends GetxController {
  final Databases databases = Get.find<Databases>();
  final AuthService authService = Get.find<AuthService>();

  var payrolls = <Payroll>[].obs;
  var isLoading = false.obs;
  var error = ''.obs;

  /// Fetch payrolls for a specific employee and organization, sorted by date descending
  Future<List<Payroll>> fetchPayrollsByEmployeeAndOrg({
    required String employeeId,
    required String organizationId,
  }) async {
    try {
      isLoading.value = true;
      final res = await databases.listDocuments(
        databaseId: CId.databaseId,
        collectionId: CId.payrollCollectionId,
        queries: [
          Query.equal('organizationId', organizationId),
          Query.equal('employeeId', employeeId),
          Query.orderDesc('salaryDate'),
        ],
      );
      final all = res.documents.map((d) => Payroll.fromJson(d.data)).toList();
      return all.where((p) => p.employeeId == employeeId).toList();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPayrolls() async {
    final orgId = authService.orgId.value;
    if (orgId.isEmpty) {
      error.value = 'Organization ID is not set.';
      return;
    }
    try {
      isLoading.value = true;
      final response = await databases.listDocuments(
        databaseId: CId.databaseId,
        collectionId: CId.payrollCollectionId,
        queries: [Query.equal('organizationId', orgId)],
      );
      payrolls.assignAll(
        response.documents.map((doc) => Payroll.fromJson(doc.data)).toList(),
      );
      error.value = '';
    } catch (e) {
      error.value = 'Failed to fetch payrolls: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createPayroll(Payroll payroll) async {
    try {
      isLoading.value = true;
      debugPrint('Payroll to be created: ${payroll.toJson()}');
      final response = await databases.createDocument(
        databaseId: CId.databaseId,
        collectionId: CId.payrollCollectionId,
        documentId: 'unique()',
        data: payroll.toJson(),
      );
      debugPrint('\n Response of Payroll: ${response.data}');
      payrolls.add(Payroll.fromJson(response.data));
      error.value = '';
    } catch (e) {
      error.value = 'Failed to create payroll: $e';
      debugPrint('\n Payroll Creating Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePayroll(Payroll payroll) async {
    if (payroll.id == null) return;
    try {
      isLoading.value = true;
      final response = await databases.updateDocument(
        databaseId: CId.databaseId,
        collectionId: CId.payrollCollectionId,
        documentId: payroll.id!,
        data: payroll.toJson(),
      );
      final index = payrolls.indexWhere((p) => p.id == payroll.id);
      if (index != -1) {
        payrolls[index] = Payroll.fromJson(response.data);
      }
      error.value = '';
    } catch (e) {
      error.value = 'Failed to update payroll: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePayroll(String id) async {
    try {
      isLoading.value = true;
      await databases.deleteDocument(
        databaseId: CId.databaseId,
        collectionId: CId.payrollCollectionId,
        documentId: id,
      );
      payrolls.removeWhere((p) => p.id == id);
      error.value = '';
    } catch (e) {
      error.value = 'Failed to delete payroll: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
