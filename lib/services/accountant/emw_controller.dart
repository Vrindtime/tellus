import 'package:get/get.dart';
import 'package:appwrite/appwrite.dart';
import 'package:tellus/core/id.dart';
import 'package:tellus/services/auth/auth_service.dart';

// Model representing an Earth Moving Work (EMW) booking
class EMWBooking {
  final String? id; // Document ID for update/delete

  // Client Details
  final String partyId; // ID of the client (party) associated with the booking
  final String vehicleId; // ID of the vehicle assigned to the booking
  final String
  partyName; // ID of the client (party) associated with the booking
  final String vehicleName; // ID of the vehicle assigned to the booking
  final DateTime startDate; // Start date and time of the booking
  final DateTime endDate; // End date and time of the booking
  final String? notes; // Additional notes for the booking
  final String createdBy; // ID of the user who created the booking
  final String organizationId; // ID of the organization managing the booking

  // Charges Details
  final String? rentType; // Type of rental (e.g., Per Hour, Fixed)
  final String? quantity; // Quantity (e.g., hours or units) for the booking
  final double? rate; // Rate per unit (e.g., rate per hour)
  final double?
  startMeter; // Starting meter reading (used for Per Hour rent type)
  final double? endMeter; // Ending meter reading (used for Per Hour rent type)

  // Shifting Details
  final double? operatorBata; // Operator's bata charge
  final String? shiftingVehicle; // ID or name of the shifting vehicle
  final double? shiftingVehicleCharge; // Charge for the shifting vehicle

  // Payment Details
  final double? tax; // Tax amount applied to the booking
  final double? discount; // Discount amount or percentage
  final String? discountType; // Type of discount (e.g., %, Rs)
  final double? amountDeposited; // Amount deposited by the client
  final double? netAmount; // Net amount after all calculations
  final double? amountPaid; // Amount paid by the client

  // Status of the Invoice
  final String status; // Current status of the booking (e.g., finished)

  final String? workLocation; // Work location for the booking

  EMWBooking({
    this.id,
    required this.partyId,
    required this.vehicleId,
    required this.partyName,
    required this.vehicleName,
    required this.startDate,
    required this.endDate,
    this.notes,
    required this.createdBy,
    required this.organizationId,
    required this.rentType,
    required this.quantity,
    required this.rate,
    required this.startMeter,
    required this.endMeter,
    required this.operatorBata,
    required this.shiftingVehicle,
    required this.shiftingVehicleCharge,
    required this.tax,
    required this.discount,
    required this.discountType,
    required this.amountDeposited,
    required this.netAmount,
    required this.amountPaid,
    required this.status,
    this.workLocation,
  });

  Map<String, dynamic> toJson() => {
    // Client Details
    'partyId': partyId,
    'vehicleId': vehicleId,
    'partyName': partyName,
    'vehicleName': vehicleName,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'notes': notes,
    'createdBy': createdBy,
    'organizationId': organizationId,

    // Charges Details
    'rentType': rentType,
    'quantity': quantity,
    'rate': rate,
    'startMeter': startMeter,
    'endMeter': endMeter,

    // Shifting Details
    'operatorBata': operatorBata,
    'shiftingVehicle': shiftingVehicle,
    'shiftingVehicleCharge': shiftingVehicleCharge,

    // Payment Details
    'tax': tax,
    'discount': discount,
    'discountType': discountType,
    'amountDeposited': amountDeposited,
    'netAmount': netAmount,
    'amountPaid': amountPaid,

    // Status
    'status': status,

    // Work Location
    'workLocation': workLocation,
  };

  factory EMWBooking.fromJson(Map<String, dynamic> json) => EMWBooking(
    id: json['\$id'],
    partyId: json['partyId'],
    vehicleId: json['vehicleId'],
    partyName: json['partyName'],
    vehicleName: json['vehicleName'],
    startDate: DateTime.parse(json['startDate']),
    endDate: DateTime.parse(json['endDate']),
    notes: json['notes'],
    createdBy: json['createdBy'],
    organizationId: json['organizationId'],
    rentType: json['rentType'],
    quantity: json['quantity'],
    rate:
        (json['rate'] is int) ? (json['rate'] as int).toDouble() : json['rate'],
    startMeter:
        (json['startMeter'] is int)
            ? (json['startMeter'] as int).toDouble()
            : json['startMeter'],
    endMeter:
        (json['endMeter'] is int)
            ? (json['endMeter'] as int).toDouble()
            : json['endMeter'],
    operatorBata:
        (json['operatorBata'] is int)
            ? (json['operatorBata'] as int).toDouble()
            : json['operatorBata'],
    shiftingVehicle: json['shiftingVehicle'],
    shiftingVehicleCharge:
        (json['shiftingVehicleCharge'] is int)
            ? (json['shiftingVehicleCharge'] as int).toDouble()
            : json['shiftingVehicleCharge'],
    tax: (json['tax'] is int) ? (json['tax'] as int).toDouble() : json['tax'],
    discount:
        (json['discount'] is int)
            ? (json['discount'] as int).toDouble()
            : json['discount'],
    discountType: json['discountType'],
    amountDeposited:
        (json['amountDeposited'] is int)
            ? (json['amountDeposited'] as int).toDouble()
            : json['amountDeposited'],
    netAmount:
        (json['netAmount'] is int)
            ? (json['netAmount'] as int).toDouble()
            : json['netAmount'],
    amountPaid:
        (json['amountPaid'] is int)
            ? (json['amountPaid'] as int).toDouble()
            : json['amountPaid'],
    status: json['status'],
    workLocation: json['workLocation'],
  );
}

class EMWBookingController extends GetxController {
  final Databases databases = Get.find<Databases>();
  final AuthService authService = Get.find<AuthService>();
  var bookings = <EMWBooking>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchEWF();
  }

  void onRefresh() async {
    await fetchEWF();
  }

  @override
  void onClose() {
    bookings.clear();
  }

  Future<void> createEMWFinishedBooking(EMWBooking booking, bool isSave) async {
    try {
      // Ensure the booking status is set to 'finished'
      booking = EMWBooking(
        partyId: booking.partyId,
        vehicleId: booking.vehicleId,
        partyName: booking.partyName,
        vehicleName: booking.vehicleName,
        startDate: booking.startDate,
        endDate: booking.endDate,
        rentType: booking.rentType,
        startMeter: booking.startMeter,
        endMeter: booking.endMeter,
        operatorBata: booking.operatorBata,
        discount: booking.discount,
        discountType: booking.discountType,
        amountPaid: booking.amountPaid,
        tax: booking.tax,
        notes: booking.notes,
        createdBy: booking.createdBy,
        quantity: booking.quantity,
        rate: booking.rate,
        amountDeposited: booking.amountDeposited,
        netAmount: booking.netAmount,
        organizationId: booking.organizationId,
        shiftingVehicle: booking.shiftingVehicle,
        shiftingVehicleCharge: booking.shiftingVehicleCharge,
        status: booking.status,
        workLocation: booking.workLocation,
      );

      print('Creating booking: ${booking.toJson()}');
      // Create a new document in the Appwrite database
      final response = await databases.createDocument(
        databaseId: CId.databaseId,
        collectionId: CId.emwBookingCollectionId,
        documentId: 'unique()',
        data: booking.toJson(),
      );

      bookings.add(
        EMWBooking.fromJson({...response.data, '\$id': response.$id}),
      );
      // debugPrint('Booking created: ${response.data}');

      print(response.data); // Log the response for debugging
      // true go back
      if (isSave) {
        Get.back();
      }

      // Show success snackbar
      Get.snackbar(
        'Success',
        'Booking created successfully',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      // Log the error and show an error snackbar
      print('Error creating booking: $e');
      Get.snackbar(
        'Error',
        'Failed to create booking',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> updateEMWFinishedBooking(
    EMWBooking oldBooking,
    EMWBooking newBooking,
  ) async {
    try {
      if (oldBooking.id == null) throw Exception('Booking ID is missing');
      await databases.updateDocument(
        databaseId: CId.databaseId,
        collectionId: CId.emwBookingCollectionId,
        documentId: oldBooking.id!,
        data: newBooking.toJson(),
      );
      fetchEWF();
      Get.back();
      Get.snackbar(
        'Success',
        'Booking updated successfully',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      print('Error updating booking: $e');
      Get.snackbar(
        'Error',
        'Failed to update booking',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> deleteEMWFinishedBooking(EMWBooking booking) async {
    try {
      if (booking.id == null) throw Exception('Booking ID is missing');
      await databases.deleteDocument(
        databaseId: CId.databaseId,
        collectionId: CId.emwBookingCollectionId,
        documentId: booking.id!,
      );
      bookings.removeWhere((b) => b.id == booking.id);
      fetchEWF();
      Get.back();
      Get.snackbar(
        'Success',
        'Booking deleted successfully',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      print('Error deleting booking: $e');
      Get.snackbar(
        'Error',
        'Failed to delete booking',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> fetchEWF() async {
    try {
      final orgId = authService.orgId.value;
      if (orgId.isEmpty) {
        throw Exception('Organization ID is not set. Please log in again.');
      }
      final response = await databases.listDocuments(
        databaseId: CId.databaseId,
        collectionId: CId.emwBookingCollectionId,
        queries: [Query.equal('organizationId', orgId)],
      );
      print(
        'Raw response documents: ${response.documents.map((doc) => doc.data).toList()}',
      );
      bookings.value =
          response.documents.map((doc) {
            final booking = EMWBooking.fromJson({
              ...doc.data,
              '\$id': doc.$id, // Ensure $id is included
            });
            print('Booking ID: ${booking.id}'); // Debug log
            return booking;
          }).toList();
      print('Fetched bookings: ${bookings.length}');
      print('Fetched bookings: ${bookings.map((b) => b.toJson()).toList()}');
    } catch (e) {
      print('Error fetching EWF bookings: $e');
    }
  }
}
