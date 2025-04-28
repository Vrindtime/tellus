import 'dart:async';
import 'package:get/get.dart';
import 'package:tellus/services/accountant/consumer_controller.dart';
import 'package:tellus/services/accountant/emw_controller.dart';
import 'package:tellus/services/accountant/payment_in_controller.dart';

class GeneralController extends GetxController {
  final ConsumerController consumerController = Get.put(ConsumerController());
  final EMWBookingController earthController = Get.put(EMWBookingController());
  final PaymentInController paymentInController = Get.put(PaymentInController());
  
  var combinedList = <dynamic>[].obs;

  @override
  onInit(){
    super.onInit();
    fetchCombinedList();
  }

  Future<List<dynamic>> fetchCombinedList() async {
    try {
      await consumerController.fetchAllBookings();
      final consumerList = consumerController.consumerBookings;

      await earthController.fetchEWF();
      final emwList = earthController.bookings;

      await paymentInController.fetchPaymentIn();
      final paymentList = paymentInController.paymentBookings;

      // Update RxList reactively
      combinedList.assignAll([...consumerList, ...emwList, ...paymentList]);
      
      combinedList.sort((a, b) {
        DateTime dateA = _getDateFromItem(a);
        DateTime dateB = _getDateFromItem(b);
        return dateB.compareTo(dateA);
      });

      return combinedList;
    } catch (e) {
      print('Error fetching combined list: $e');
      return [];
    }
  }

  void refreshData() async {
    await fetchCombinedList();
  }


  DateTime _getDateFromItem(dynamic item) {
    if (item is ConsumerModel) {
      return item.workDate;
    } else if (item is EMWBooking) {
      return item.startDate;
    } else if (item is PaymentInModel) {
      return item.date;
    } else {
      return DateTime(1970);
    }
  }
}