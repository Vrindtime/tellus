import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:get/get.dart';

class PdfEarthMovingInvoice {
  static Future<Uint8List> generateInvoice({
    required String organizationName,
    required String organizationAddress,
    String? organizationPhone,
    dynamic organizationLogo,
    required String clientName,
    String? clientPhone,
    dynamic clientLogo,
    required String vehicleName,
    required DateTime startDate,
    required DateTime endDate,
    required String workLocation,
    required String notes,
    required String rentType,
    required double rate,
    required String quantity,
    double? startMeter,
    double? endMeter,
    required String shiftingVehicle,
    required double shiftingVehicleCharge,
    required double operatorBata,
    required double taxPercent,
    required double discount,
    required String discountType,
    required double amountDeposited,
    required double amountPaid,
    required double netAmount,
    String? upiId,
    String? bankAccountName,
    String? bankAccountNumber,
    String? bankIfscCode,
    String? paymentNotes,
    String? invoiceNumber,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd-MMM-yyyy');
    const accentColor = PdfColors.blue800;

    Future<pw.ImageProvider?> loadImage(dynamic image) async {
      try {
        if (image is Uint8List) {
          return pw.MemoryImage(image);
        } else if (image is String && image.isNotEmpty) {
          if (image.startsWith('http')) {
            final response = await http.get(Uri.parse(image));
            if (response.statusCode == 200) {
              return pw.MemoryImage(response.bodyBytes);
            }
          } else {
            final file = File(image);
            if (await file.exists()) {
              return pw.MemoryImage(await file.readAsBytes());
            }
          }
        }
        return null;
      } catch (e) {
        print('Error loading image: $e');
        return null;
      }
    }

    final pw.ImageProvider? orgLogoImage = await loadImage(organizationLogo);
    final pw.ImageProvider? clientLogoImage = await loadImage(clientLogo);

    double parsedQuantity = 0;
    if (rentType == 'Per Hour') {
      final parts = quantity.split(':');
      if (parts.length == 2) {
        final hours = double.tryParse(parts[0]) ?? 0;
        final minutes = double.tryParse(parts[1]) ?? 0;
        parsedQuantity = hours + (minutes / 60.0);
      } else {
        parsedQuantity = double.tryParse(quantity) ?? 0;
      }
    } else {
      parsedQuantity = double.tryParse(quantity.replaceAll(':', '.')) ?? 1;
      if (rentType == 'Fixed') parsedQuantity = 1;
    }
    final double baseRent = (rentType == 'Fixed') ? rate : (rate * parsedQuantity);
    final double subtotal = baseRent + shiftingVehicleCharge + operatorBata;
    final double taxAmount = subtotal * (taxPercent / 100.0);
    final double discountAmount = (discountType == '%')
        ? ((subtotal + taxAmount) * (discount / 100.0))
        : discount;
    final double grossTotal = subtotal + taxAmount;

    final String invNum = invoiceNumber ?? 'INV-${DateTime.now().millisecondsSinceEpoch}';
    final String invDate = dateFormat.format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        header: (context) => _buildHeader(
          context,
          organizationName,
          organizationAddress,
          organizationPhone,
          orgLogoImage,
          invNum,
          invDate,
          clientName: clientName,
          clientPhone: clientPhone,
          clientLogoImage: clientLogoImage,
          vehicleName: vehicleName,
          startDate: dateFormat.format(startDate),
          endDate: dateFormat.format(endDate),
          workLocation: workLocation,
          showEndDate: startDate != endDate,
        ),
        footer: (context) => _buildFooter(
          context: context,
          notes: notes,
          paymentNotes: paymentNotes,
          organizationName: organizationName,
          netAmountDue: netAmount,
          upiId: upiId,
          bankAccountName: bankAccountName,
          bankAccountNumber: bankAccountNumber,
          bankIfscCode: bankIfscCode,
        ),
        build: (context) => [
          pw.SizedBox(height: 20),
          _buildInvoiceTable(
            rentType: rentType,
            rate: rate,
            quantity: quantity,
            startMeter: startMeter,
            endMeter: endMeter,
            shiftingVehicle: shiftingVehicle,
            shiftingVehicleCharge: shiftingVehicleCharge,
            operatorBata: operatorBata,
            baseRentAmount: baseRent,
            vehicleName: vehicleName,
          ),
          pw.SizedBox(height: 20),
          _buildTotals(
            subtotal: subtotal,
            taxPercent: taxPercent,
            taxAmount: taxAmount,
            discount: discount,
            discountType: discountType,
            discountAmount: discountAmount,
            grossTotal: grossTotal,
            amountDeposited: amountDeposited,
            amountPaid: amountPaid,
            netAmountDue: netAmount,
          ),
          pw.SizedBox(height: 30),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(
    pw.Context context,
    String organizationName,
    String organizationAddress,
    String? organizationPhone,
    pw.ImageProvider? orgLogoImage,
    String invoiceNumber,
    String invoiceDate, {
    required String clientName,
    required String? clientPhone,
    required pw.ImageProvider? clientLogoImage,
    required String vehicleName,
    required String startDate,
    required String endDate,
    required String workLocation,
    required bool showEndDate,
  }) {
    final List<pw.Widget> orgDetails = [
      if (orgLogoImage != null) pw.Image(orgLogoImage, height: 40),
      pw.Text(organizationName, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
      if (organizationAddress.isNotEmpty) pw.Text(organizationAddress, style: const pw.TextStyle(fontSize: 10)),
      if (organizationPhone != null && organizationPhone.isNotEmpty) pw.Text('Phone: $organizationPhone', style: const pw.TextStyle(fontSize: 10)),
    ];

    final List<pw.Widget> clientDetails = [
      if (clientLogoImage != null) pw.Image(clientLogoImage, height: 40),
      pw.Text('Bill To: $clientName', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      if (clientPhone != null && clientPhone.isNotEmpty) pw.Text('Phone: $clientPhone', style: const pw.TextStyle(fontSize: 10)),
      pw.Text('Vehicle: ${vehicleName.isEmpty ? 'Not Specified' : vehicleName}', style: const pw.TextStyle(fontSize: 10)),
      pw.Text('Start Date: $startDate', style: const pw.TextStyle(fontSize: 10)),
      if (showEndDate) pw.Text('End Date: $endDate', style: const pw.TextStyle(fontSize: 10)),
      if (workLocation.isNotEmpty) pw.Text('Work Location: $workLocation', style: const pw.TextStyle(fontSize: 10)),
    ];

    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Invoice #: $invoiceNumber', style: const pw.TextStyle(fontSize: 10, color: PdfColors.blue800)),
            pw.Text('Date: $invoiceDate', style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(flex: 2, child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: orgDetails)),
            pw.SizedBox(width: 20),
            pw.Expanded(flex: 2, child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: clientDetails)),
          ],
        ),
        pw.Divider(color: PdfColors.blue800),
      ],
    );
  }

  static pw.Widget _buildInvoiceTable({
    required String rentType,
    required double rate,
    required String quantity,
    double? startMeter,
    double? endMeter,
    required String shiftingVehicle,
    required double shiftingVehicleCharge,
    required double operatorBata,
    required double baseRentAmount,
    required String vehicleName,
  }) {
    final List<pw.TableRow> rows = [
      pw.TableRow(children: [
        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Rate', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
      ]),
    ];

    // if (baseRentAmount != 0) {
    if (vehicleName.isNotEmpty) {
      final rentDescription = vehicleName.isEmpty ? '$rentType Rent' : '$rentType Rent - $vehicleName';
      rows.add(pw.TableRow(children: [
        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(rentDescription)),
        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(quantity)),
        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(rate.toStringAsFixed(2))),
        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(baseRentAmount.toStringAsFixed(2))),
      ]));
    }

    if (shiftingVehicle.isNotEmpty && shiftingVehicleCharge != 0) {
      rows.add(pw.TableRow(children: [
        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Shifting Vehicle: $shiftingVehicle')),
        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('1')),
        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(shiftingVehicleCharge.toStringAsFixed(2))),
        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(shiftingVehicleCharge.toStringAsFixed(2))),
      ]));
    }

    if (operatorBata != 0) {
      rows.add(pw.TableRow(children: [
        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Operator Bata')),
        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('1')),
        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(operatorBata.toStringAsFixed(2))),
        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(operatorBata.toStringAsFixed(2))),
      ]));
    }

    return pw.Table(
      border: pw.TableBorder.all(width: 0.5, color: PdfColors.blue800),
      children: rows,
    );
  }

  static pw.Widget _buildTotals({
    required double subtotal,
    required double taxPercent,
    required double taxAmount,
    required double discount,
    required String discountType,
    required double discountAmount,
    required double grossTotal,
    required double amountDeposited,
    required double amountPaid,
    required double netAmountDue,
  }) {
    final List<pw.Widget> rows = [
      _buildTotalRow('Subtotal', subtotal.toStringAsFixed(2)),
    ];

    if (taxAmount != 0) {
      rows.add(_buildTotalRow('Tax ($taxPercent%)', taxAmount.toStringAsFixed(2)));
    }

    if (discountAmount != 0) {
      rows.add(_buildTotalRow('Discount ($discountType)', discountAmount.toStringAsFixed(2)));
    }

    rows.add(_buildTotalRow('Gross Total', grossTotal.toStringAsFixed(2), isBold: true));

    if (amountDeposited != 0) {
      rows.add(_buildTotalRow('Amount Deposited', amountDeposited.toStringAsFixed(2)));
    }

    if (amountPaid != 0) {
      rows.add(_buildTotalRow('Amount Paid', amountPaid.toStringAsFixed(2)));
    }

    rows.add(pw.Divider(color: PdfColors.blue800));

    rows.add(_buildTotalRow('Net Amount Due', netAmountDue.toStringAsFixed(2), isBold: true, isLarge: true, isAccent: true));

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: rows,
    );
  }

  static pw.Widget _buildTotalRow(String title, String value, {bool isBold = false, bool isLarge = false, bool isAccent = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(2),
      child: pw.Row(
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              fontSize: isLarge ? 12 : 10,
              color: isAccent ? PdfColors.blue800 : PdfColors.black,
            ),
          ),
          pw.Spacer(),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              fontSize: isLarge ? 12 : 10,
              color: isAccent ? PdfColors.blue800 : PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter({
    required pw.Context context,
    required String notes,
    String? paymentNotes,
    required String organizationName,
    required double netAmountDue,
    String? upiId,
    String? bankAccountName,
    String? bankAccountNumber,
    String? bankIfscCode,
  }) {
    bool showUpi = upiId != null && upiId.isNotEmpty;
    bool showBank = bankAccountName != null &&
        bankAccountName.isNotEmpty &&
        bankAccountNumber != null &&
        bankAccountNumber.isNotEmpty &&
        bankIfscCode != null &&
        bankIfscCode.isNotEmpty;

    String? upiData;
    if (showUpi) {
      upiData = 'upi://pay'
          '?pa=${Uri.encodeComponent(upiId!)}'
          '&pn=${Uri.encodeComponent(organizationName)}'
          '&am=${netAmountDue.toStringAsFixed(2)}'
          '&cu=INR';
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(height: 20, thickness: 1, color: PdfColors.blue800),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              flex: 3,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (notes.isNotEmpty) ...[
                    pw.Text('Work Notes:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(notes, style: const pw.TextStyle(fontSize: 9)),
                    pw.SizedBox(height: 10),
                  ],
                  pw.Text('Payment Terms:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(paymentNotes ?? 'Due on receipt', style: const pw.TextStyle(fontSize: 9)),
                  pw.SizedBox(height: 15),
                  pw.Text('Thank you for your business!', style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
                ],
              ),
            ),
            pw.SizedBox(width: 20),
            pw.Expanded(
              flex: 2,
              child: pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    if (showUpi && upiData != null) ...[
                      pw.Text('Scan to Pay (UPI):', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      pw.SizedBox(height: 5),
                      pw.Container(
                        height: 80,
                        width: 80,
                        child: pw.BarcodeWidget(
                          color: PdfColors.black,
                          barcode: pw.Barcode.qrCode(),
                          data: upiData,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.UrlLink(
                        destination: upiData,
                        child: pw.Text(
                          'Pay via UPI: $upiId',
                          style: pw.TextStyle(
                            fontSize: 8,
                            color: PdfColors.blue,
                            decoration: pw.TextDecoration.underline,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    if (showBank) ...[
                      if (showUpi) pw.SizedBox(height: 10),
                      pw.Text('Bank Account Details:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      pw.SizedBox(height: 5),
                      pw.Text('Acc Name: ${bankAccountName!}', style: const pw.TextStyle(fontSize: 9)),
                      pw.Text('Acc Number: ${bankAccountNumber!}', style: const pw.TextStyle(fontSize: 9)),
                      pw.Text('IFSC Code: ${bankIfscCode!}', style: const pw.TextStyle(fontSize: 9)),
                    ],
                    if (!showUpi && !showBank) ...[
                      pw.Text('Payment details not provided.', style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic, color: PdfColors.grey)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Align(
          alignment: pw.Alignment.center,
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
          ),
        ),
      ],
    );
  }

  static Future<void> generateAndSharePdf({
    required Map<String, dynamic> invoiceData,
    dynamic logo,
    dynamic clientLogo,
  }) async {
    try {
      final Uint8List pdfBytes = await generateInvoice(
        organizationName: invoiceData['organizationName'] ?? 'Unknown Organization',
        organizationAddress: invoiceData['organizationAddress'] ?? 'N/A',
        organizationPhone: invoiceData['organizationPhone'] ?? 'N/A',
        organizationLogo: logo,
        clientName: invoiceData['clientName'] ?? 'Unknown Client',
        clientPhone: invoiceData['clientPhone'],
        clientLogo: clientLogo,
        vehicleName: invoiceData['vehicleName'] ?? 'Not Specified',
        startDate: invoiceData['startDate'] is DateTime
            ? invoiceData['startDate']
            : DateTime.parse(invoiceData['startDate'] ?? DateTime.now().toIso8601String()),
        endDate: invoiceData['endDate'] is DateTime
            ? invoiceData['endDate']
            : DateTime.parse(invoiceData['endDate'] ?? DateTime.now().toIso8601String()),
        workLocation: invoiceData['workLocation'] ?? '',
        notes: invoiceData['notes'] ?? '',
        rentType: invoiceData['rentType'] ?? 'Fixed',
        rate: (invoiceData['rate'] ?? 0).toDouble(),
        quantity: invoiceData['quantity']?.toString() ?? '1',
        startMeter: invoiceData['startMeter']?.toDouble(),
        endMeter: invoiceData['endMeter']?.toDouble(),
        shiftingVehicle: invoiceData['shiftingVehicle'] ?? '',
        shiftingVehicleCharge: (invoiceData['shiftingVehicleCharge'] ?? 0).toDouble(),
        operatorBata: (invoiceData['operatorBata'] ?? 0).toDouble(),
        taxPercent: (invoiceData['taxPercent'] ?? 0).toDouble(),
        discount: (invoiceData['discount'] ?? 0).toDouble(),
        discountType: invoiceData['discountType'] ?? 'Flat',
        amountDeposited: (invoiceData['amountDeposited'] ?? 0).toDouble(),
        amountPaid: (invoiceData['amountPaid'] ?? 0).toDouble(),
        upiId: invoiceData['upiId'],
        bankAccountName: invoiceData['bankAccountName'],
        bankAccountNumber: invoiceData['bankAccountNumber'],
        bankIfscCode: invoiceData['bankIfscCode'],
        paymentNotes: invoiceData['paymentNotes'],
        invoiceNumber: invoiceData['invoiceNumber'],
        netAmount: invoiceData['netAmount'] ?? 0.0,
      );

      final outputDir = await getTemporaryDirectory();
      final filename = 'invoice_${invoiceData['invoiceNumber'] ?? DateTime.now().millisecondsSinceEpoch}.pdf';
      final outputFile = File('${outputDir.path}/$filename');
      await outputFile.writeAsBytes(pdfBytes);
      print('PDF Saved to: ${outputFile.path}');

      List<XFile> filesToShare = [XFile(outputFile.path)];

      await Share.shareXFiles(
        filesToShare,
      );
      print('PDF Shared successfully!');
    } catch (e) {
      print('Error generating or sharing PDF: $e');
      Get.snackbar('Error', 'Could not generate or share PDF: $e');
    }
  }
}
