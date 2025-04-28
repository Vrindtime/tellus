import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:get/get.dart';

class PdfConsumerInvoice {
  static Future<Uint8List> generateInvoice({
    required Map<String, dynamic> invoiceData,
    dynamic organizationLogo,
    dynamic clientLogo,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd-MMM-yyyy');
    const accentColor = PdfColors.blue800;

    // Load image from URL, file, or Uint8List
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

    // Calculate financials
    final items =
        (invoiceData['items'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        [];
    double subtotal =
        items.fold(0.0, (sum, item) {
          final quantity =
              (item['quantity'] is int)
                  ? (item['quantity'] as int).toDouble()
                  : item['quantity'] as double;
          final sellPrice =
              (item['sellPrice'] is int)
                  ? (item['sellPrice'] as int).toDouble()
                  : item['sellPrice'] as double;
          return sum + (quantity * sellPrice);
        }) +
        (invoiceData['shiftingVehicleCharge']?.toDouble() ?? 0.0);

    final double taxAmount = items.fold(0.0, (sum, item) {
      final quantity =
          (item['quantity'] is int)
              ? (item['quantity'] as int).toDouble()
              : item['quantity'] as double;
      final sellPrice =
          (item['sellPrice'] is int)
              ? (item['sellPrice'] as int).toDouble()
              : item['sellPrice'] as double;
      final amount = quantity * sellPrice;
      final taxRate = item['taxOption'] == 'With Tax (18%)' ? 18.0 : 0.0;
      return sum + (amount * taxRate / 100.0);
    });

    final double discountAmount =
        (invoiceData['discountType'] == 'Percentage')
            ? ((subtotal + taxAmount) *
                ((invoiceData['discount'] ?? 0.0) / 100.0))
            : (invoiceData['discount'] ?? 0.0).toDouble();
    final double grossTotal = subtotal + taxAmount;

    final String invDate = dateFormat.format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        header:
            (context) => _buildHeader(
              context,
              invoiceData['organizationName'] ?? 'Unknown Organization',
              invoiceData['organizationAddress'] ?? 'N/A',
              invoiceData['organizationPhone'],
              orgLogoImage,
              invoiceData['invoiceNumber'] ??
                  'INV-${DateTime.now().millisecondsSinceEpoch}',
              invDate,
              clientName: invoiceData['clientName'] ?? 'Unknown Client',
              clientPhone: invoiceData['clientPhone'],
              clientLogoImage: clientLogoImage,
              workDate: dateFormat.format(
                invoiceData['workDate'] is DateTime
                    ? invoiceData['workDate']
                    : DateTime.parse(
                      invoiceData['workDate'] ??
                          DateTime.now().toIso8601String(),
                    ),
              ),
              workLocation: invoiceData['workLocation'] ?? 'N/A',
            ),
        footer:
            (context) => _buildFooter(
              context: context,
              paymentNotes: invoiceData['paymentNotes'],
              organizationName:
                  invoiceData['organizationName'] ?? 'Unknown Organization',
              netAmountDue: (invoiceData['netAmount'] ?? 0.0).toDouble(),
              upiId: invoiceData['upiId'],
              bankAccountName: invoiceData['bankAccountName'],
              bankAccountNumber: invoiceData['bankAccountNumber'],
              bankIfscCode: invoiceData['bankIfscCode'],
            ),
        build:
            (context) => [
              pw.SizedBox(height: 20),
              _buildInvoiceTable(
                items: items,
                shiftingVehicle: invoiceData['shiftingVehicle'] ?? '',
                shiftingVehicleCharge:
                    (invoiceData['shiftingVehicleCharge'] ?? 0.0).toDouble(),
              ),
              pw.SizedBox(height: 20),
              _buildTotals(
                subtotal: subtotal,
                taxAmount: taxAmount,
                discount: (invoiceData['discount'] ?? 0.0).toDouble(),
                discountType: invoiceData['discountType'] ?? 'Flat',
                discountAmount: discountAmount,
                grossTotal: grossTotal,
                amountPaid: (invoiceData['amountPaid'] ?? 0.0).toDouble(),
                netAmountDue: (invoiceData['netAmount'] ?? 0.0).toDouble(),
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
    required String workDate,
    required String workLocation,
  }) {
    final List<pw.Widget> orgDetails = [
      if (orgLogoImage != null) pw.Image(orgLogoImage, height: 40),
      pw.Text(
        organizationName,
        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
      ),
      if (organizationAddress.isNotEmpty)
        pw.Text(organizationAddress, style: const pw.TextStyle(fontSize: 10)),
      if (organizationPhone != null && organizationPhone.isNotEmpty)
        pw.Text(
          'Phone: $organizationPhone',
          style: const pw.TextStyle(fontSize: 10),
        ),
    ];

    final List<pw.Widget> clientDetails = [
      if (clientLogoImage != null) pw.Image(clientLogoImage, height: 40),
      pw.Text(
        'Bill To: $clientName',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
      if (clientPhone != null && clientPhone.isNotEmpty)
        pw.Text('Phone: $clientPhone', style: const pw.TextStyle(fontSize: 10)),
      pw.Text('Work Date: $workDate', style: const pw.TextStyle(fontSize: 10)),
      if (workLocation.isNotEmpty)
        pw.Text(
          'Work Location: $workLocation',
          style: const pw.TextStyle(fontSize: 10),
        ),
    ];

    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Invoice #: $invoiceNumber',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.blue800),
            ),
            pw.Text(
              'Date: $invoiceDate',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              flex: 2,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: orgDetails,
              ),
            ),
            pw.SizedBox(width: 20),
            pw.Expanded(
              flex: 2,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: clientDetails,
              ),
            ),
          ],
        ),
        pw.Divider(color: PdfColors.blue800),
      ],
    );
  }

  static pw.Widget _buildInvoiceTable({
    required List<Map<String, dynamic>> items,
    required String shiftingVehicle,
    required double shiftingVehicleCharge,
  }) {
    final List<pw.TableRow> rows = [
      pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(
              'Description',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(
              'Unit',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(
              'Qty',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(
              'Rate',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(
              'Tax',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(
              'Amount',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    ];

    for (var item in items) {
      final quantity =
          (item['quantity'] is int)
              ? (item['quantity'] as int).toDouble()
              : item['quantity'] as double;
      final sellPrice =
          (item['sellPrice'] is int)
              ? (item['sellPrice'] as int).toDouble()
              : item['sellPrice'] as double;
      final amount = quantity * sellPrice;
      final taxOption = item['taxOption'] as String? ?? 'Without Tax';
      final taxText = taxOption == 'With Tax (18%)' ? '18%' : '0%';

      rows.add(
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(item['name'] ?? 'Unknown Item'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(item['unit'] ?? 'N/A'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(quantity.toStringAsFixed(2)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(sellPrice.toStringAsFixed(2)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(taxText),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(amount.toStringAsFixed(2)),
            ),
          ],
        ),
      );
    }

    if (shiftingVehicle.isNotEmpty && shiftingVehicleCharge != 0) {
      rows.add(
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text('Shifting Vehicle: $shiftingVehicle'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text('N/A'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text('1'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(shiftingVehicleCharge.toStringAsFixed(2)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text('0%'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(shiftingVehicleCharge.toStringAsFixed(2)),
            ),
          ],
        ),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(width: 0.5, color: PdfColors.blue800),
      children: rows,
    );
  }

  static pw.Widget _buildTotals({
    required double subtotal,
    required double taxAmount,
    required double discount,
    required String discountType,
    required double discountAmount,
    required double grossTotal,
    required double amountPaid,
    required double netAmountDue,
  }) {
    final List<pw.Widget> rows = [
      _buildTotalRow('Subtotal', subtotal.toStringAsFixed(2)),
    ];

    if (taxAmount != 0) {
      rows.add(_buildTotalRow('Tax', taxAmount.toStringAsFixed(2)));
    }

    if (discountAmount != 0) {
      rows.add(
        _buildTotalRow(
          'Discount ($discountType)',
          discountAmount.toStringAsFixed(2),
        ),
      );
    }

    rows.add(
      _buildTotalRow(
        'Gross Total',
        grossTotal.toStringAsFixed(2),
        isBold: true,
      ),
    );

    if (amountPaid != 0) {
      rows.add(_buildTotalRow('Amount Paid', amountPaid.toStringAsFixed(2)));
    }

    rows.add(pw.Divider(color: PdfColors.blue800));

    rows.add(
      _buildTotalRow(
        'Net Amount Due',
        netAmountDue.toStringAsFixed(2),
        isBold: true,
        isLarge: true,
        isAccent: true,
      ),
    );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: rows,
    );
  }

  static pw.Widget _buildTotalRow(
    String title,
    String value, {
    bool isBold = false,
    bool isLarge = false,
    bool isAccent = false,
  }) {
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
    String? paymentNotes,
    required String organizationName,
    required double netAmountDue,
    String? upiId,
    String? bankAccountName,
    String? bankAccountNumber,
    String? bankIfscCode,
  }) {
    bool showUpi = upiId != null && upiId.isNotEmpty;
    bool showBank =
        bankAccountName != null &&
        bankAccountName.isNotEmpty &&
        bankAccountNumber != null &&
        bankAccountNumber.isNotEmpty &&
        bankIfscCode != null &&
        bankIfscCode.isNotEmpty;

    String? upiData;
    if (showUpi) {
      upiData =
          'upi://pay'
          '?pa=${Uri.encodeComponent(upiId)}'
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
                  pw.Text(
                    'Payment Terms:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    paymentNotes ?? 'Due on receipt',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  pw.SizedBox(height: 15),
                  pw.Text(
                    'Thank you for your business!',
                    style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
                  ),
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
                      pw.Text(
                        'Scan to Pay (UPI):',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
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
                      pw.Text(
                        'Bank Account Details:',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'Acc Name: $bankAccountName',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                      pw.Text(
                        'Acc Number: $bankAccountNumber',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                      pw.Text(
                        'IFSC Code: $bankIfscCode',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ],
                    if (!showUpi && !showBank) ...[
                      pw.Text(
                        'Payment details not provided.',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontStyle: pw.FontStyle.italic,
                          color: PdfColors.grey,
                        ),
                      ),
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
      print(
        'Starting PDF generation for invoice: ${invoiceData['invoiceNumber']}',
      );
      final Uint8List pdfBytes = await generateInvoice(
        invoiceData: invoiceData,
        organizationLogo: logo,
        clientLogo: clientLogo,
      );
      print('PDF generated, size: ${pdfBytes.length} bytes');

      final outputDir = await getTemporaryDirectory();
      final filename =
          'consumer_invoice_${invoiceData['invoiceNumber'] ?? DateTime.now().millisecondsSinceEpoch}.pdf';
      final outputFile = File('${outputDir.path}/$filename');
      await outputFile.writeAsBytes(pdfBytes);
      print('PDF Saved to: ${outputFile.path}');

      if (await outputFile.exists()) {
        print('File exists, attempting to share...');
        List<XFile> filesToShare = [XFile(outputFile.path)];
        await Share.shareXFiles(
          filesToShare,
        ); // Remove text parameter to match working code
        print('PDF Shared successfully!');
      } else {
        print('File does not exist: ${outputFile.path}');
        Get.snackbar('Error', 'PDF file could not be found for sharing');
      }
    } catch (e, stackTrace) {
      print('Error generating or sharing PDF: $e');
      print('Stack Trace: $stackTrace');
      Get.snackbar('Error', 'Could not generate or share PDF: $e');
    }
  }
}
