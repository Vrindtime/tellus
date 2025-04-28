
import 'package:get/get.dart';
import 'package:appwrite/appwrite.dart';
import 'package:tellus/core/id.dart';
import 'package:tellus/helper/helper.dart';
import 'package:tellus/services/auth/auth_service.dart';

class ReportController extends GetxController {
  var startDate = DateTime.now().obs;
  var endDate = DateTime.now().obs;
  var totalEarnings = 0.0.obs;
  var totalExpenses = 0.0.obs;
  var isLoading = false.obs;

  void setDateRange(DateTime start, DateTime end) {
    startDate.value = startOfDay(start);
    endDate.value = endOfDay(end);
    fetchReportData(startDate.value, endDate.value);
  }
  final Databases databases = Get.find<Databases>();
  final AuthService authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    fetchReportData(startDate.value, endDate.value);
  }


  Future<double> _fetchBookingEarnings(
      DateTime start,
      DateTime end,
      String orgId,
      ) async {
    final response = await databases.listDocuments(
      databaseId: CId.databaseId,
      collectionId: CId.emwBookingCollectionId,
      queries: [
        Query.equal('organizationId', orgId),
        Query.greaterThanEqual('startDate', start.toIso8601String()),
        Query.lessThanEqual('startDate', end.toIso8601String()),
        Query.equal('status', 'finished'),
      ],
    );
    double earnings = 0.0;
    for (var doc in response.documents) {
      earnings += (doc.data['netAmount'] as num?)?.toDouble() ?? 0.0;
    }
    return earnings;
  }

  Future<double> _fetchConsumerEarnings(
      DateTime start,
      DateTime end,
      String orgId,
      ) async {
    final response = await databases.listDocuments(
      databaseId: CId.databaseId,
      collectionId: CId.consumerBookingCollectionId,
      queries: [
        Query.equal('organizationId', orgId),
        Query.greaterThanEqual('workDate', start.toIso8601String()),
        Query.lessThanEqual('workDate', end.toIso8601String()),
      ],
    );
    double earnings = 0.0;
    for (var doc in response.documents) {
      earnings += (doc.data['netAmount'] as num?)?.toDouble() ?? 0.0;
    }
    return earnings;
  }

  Future<double> _fetchPaymentEarnings(
      DateTime start,
      DateTime end,
      String orgId,
      ) async {
    final response = await databases.listDocuments(
      databaseId: CId.databaseId,
      collectionId: CId.paymentCollectionId,
      queries: [
        Query.equal('organizationId', orgId),
        Query.greaterThanEqual('date', start.toIso8601String()),
        Query.lessThanEqual('date', end.toIso8601String()),
      ],
    );
    double earnings = 0.0;
    for (var doc in response.documents) {
      earnings += (doc.data['receivedAmount'] as num?)?.toDouble() ?? 0.0;
    }
    return earnings;
  }

  Future<double> _fetchExpenses(
      DateTime start,
      DateTime end,
      String orgId,
      ) async {
    final response = await databases.listDocuments(
      databaseId: CId.databaseId,
      collectionId: CId.expenseCollectionId,
      queries: [
        Query.equal('organizationId', orgId),
        Query.greaterThanEqual('date', start.toIso8601String()),
        Query.lessThanEqual('date', end.toIso8601String()),
      ],
    );
    double expenses = 0.0;
    for (var doc in response.documents) {
      expenses += (doc.data['amount'] as num?)?.toDouble() ?? 0.0;
    }
    return expenses;
  }

  Future<void> fetchReportData(DateTime start, DateTime end) async {
    try {
      isLoading.value = true;
      final orgId = authService.orgId.value;
      if (orgId.isEmpty) {
        throw Exception('Organization ID is not set. Please log in again.');
      }

      // Fetch all data concurrently
      final results = await Future.wait([
        _fetchBookingEarnings(start, end, orgId),
        _fetchConsumerEarnings(start, end, orgId),
        _fetchPaymentEarnings(start, end, orgId),
        _fetchExpenses(start, end, orgId),
      ]);

      totalEarnings.value = results[0] + results[1] + results[2];
      totalExpenses.value = results[3];
    } catch (e) {
      print('Error fetching report data: $e');
      Get.snackbar('Error', 'Failed to fetch report data: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

