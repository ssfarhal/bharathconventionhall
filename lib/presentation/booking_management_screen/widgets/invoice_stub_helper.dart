import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class InvoiceDownloader {
  /// Generates a PDF from the invoice data map and shares it via the system share sheet.
  static Future<void> downloadPdf(
    Map<String, dynamic> data,
    String filename,
  ) async {
    if (kIsWeb) return;
    try {
      final pdfBytes = await _buildPdf(data);
      final dir = await getTemporaryDirectory();
      final pdfFilename = filename.replaceAll('.html', '.pdf');
      final file = File('${dir.path}/$pdfFilename');
      await file.writeAsBytes(pdfBytes, flush: true);
      await Share.shareXFiles([
        XFile(file.path, mimeType: 'application/pdf'),
      ], subject: pdfFilename);
    } catch (e) {
      // Silently fail — caller shows its own snackbar
    }
  }

  /// Fallback: saves HTML and shares (used on web path or if PDF fails)
  static Future<void> download(String htmlContent, String filename) async {
    if (kIsWeb) return;
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$filename');
      await file.writeAsString(htmlContent, flush: true);
      await Share.shareXFiles([
        XFile(file.path, mimeType: 'text/html'),
      ], subject: filename);
    } catch (e) {
      // Silently fail
    }
  }

  static void openUrl(String url) {
    // No-op on mobile — mailto handled by share sheet or email app
  }

  /// Saves the PDF to a temp file and opens the share sheet for printing.
  static Future<void> printPdf(Map<String, dynamic> data) async {
    if (kIsWeb) return;
    try {
      final pdfBytes = await _buildPdf(data);
      await Printing.sharePdf(
        bytes: Uint8List.fromList(pdfBytes),
        filename: 'invoice_print.pdf',
      );
    } catch (e) {
      // Silently fail
    }
  }

  /// Legacy print via HTML share
  static Future<void> print(String htmlContent) async {
    if (kIsWeb) return;
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/invoice_print.html');
      await file.writeAsString(htmlContent, flush: true);
      await Share.shareXFiles([
        XFile(file.path, mimeType: 'text/html'),
      ], subject: 'Print Invoice');
    } catch (e) {
      // Silently fail
    }
  }

  static Future<List<int>> _buildPdf(Map<String, dynamic> d) async {
    final doc = pw.Document();

    // Load Unicode-capable fonts that support the ₹ (Rupee) symbol
    final fontRegular = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();

    // Helper to build a TextStyle with the Unicode font
    pw.TextStyle ts({
      double fontSize = 11,
      pw.FontWeight fontWeight = pw.FontWeight.normal,
      PdfColor? color,
      double? letterSpacing,
      double? lineSpacing,
    }) {
      return pw.TextStyle(
        font: fontWeight == pw.FontWeight.bold ? fontBold : fontRegular,
        fontBold: fontBold,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        lineSpacing: lineSpacing,
      );
    }

    // Colors
    const primaryColor = PdfColor.fromInt(0xFF8B1A4A);
    const primaryLight = PdfColor.fromInt(0xFFC2185B);
    const textDark = PdfColor.fromInt(0xFF1A1A1A);
    const textMuted = PdfColor.fromInt(0xFF9E9E9E);
    const textBody = PdfColor.fromInt(0xFF5A4A50);
    const successColor = PdfColor.fromInt(0xFF2E7D32);
    const warningColor = PdfColor.fromInt(0xFFF57F17);
    const bgLight = PdfColor.fromInt(0xFFFAFAFA);
    const borderColor = PdfColor.fromInt(0xFFEEEEEE);

    final clientName = d['clientName'] as String? ?? '';
    final phone = d['phone'] as String? ?? '';
    final eventType = d['eventType'] as String? ?? '';
    final guestCount = d['guestCount'] as int? ?? 0;
    final total = (d['totalAmount'] as double?) ?? 0.0;
    final advance = (d['advance'] as double?) ?? 0.0;
    final balance = (d['balance'] as double?) ?? 0.0;
    final notes = d['notes'] as String? ?? '';
    final status = d['status'] as String? ?? '';
    final bookingId = d['bookingId'] as String? ?? 'N/A';
    final eventDateStr = d['eventDateStr'] as String? ?? '';
    final invoiceDateStr = d['invoiceDateStr'] as String? ?? '';
    final termsAndConditions = d['termsAndConditions'] as String? ?? '';
    final functionTime = d['functionTime'] as String? ?? '';

    String fmt(double v) {
      final intVal = v.round();
      final formatted = intVal.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
      return 'Rs $formatted/-';
    }

    PdfColor statusColor(String s) {
      switch (s.toLowerCase()) {
        case 'confirmed':
          return successColor;
        case 'pending':
          return warningColor;
        case 'cancelled':
          return const PdfColor.fromInt(0xFFC62828);
        default:
          return textMuted;
      }
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        build: (context) => [
          // Header
          pw.Container(
            width: double.infinity,
            decoration: const pw.BoxDecoration(
              gradient: pw.LinearGradient(
                colors: [primaryColor, primaryLight],
                begin: pw.Alignment.centerLeft,
                end: pw.Alignment.centerRight,
              ),
            ),
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 40,
              vertical: 28,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'BHARATH CONVENTION HALL',
                  style: ts(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                    letterSpacing: 1,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Tax Invoice / Receipt',
                  style: ts(fontSize: 11, color: PdfColors.white),
                ),
              ],
            ),
          ),

          // Invoice Meta Row
          pw.Container(
            color: bgLight,
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 40,
              vertical: 16,
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _metaBlock(
                  'Invoice No.',
                  bookingId,
                  textMuted,
                  textDark,
                  fontRegular,
                  fontBold,
                ),
                _metaBlock(
                  'Invoice Date',
                  invoiceDateStr,
                  textMuted,
                  textDark,
                  fontRegular,
                  fontBold,
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Status', style: ts(fontSize: 9, color: textMuted)),
                    pw.SizedBox(height: 3),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: pw.BoxDecoration(
                        color: statusColor(status).shade(0.15),
                        borderRadius: pw.BorderRadius.circular(12),
                      ),
                      child: pw.Text(
                        status.toUpperCase(),
                        style: ts(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: statusColor(status),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.Divider(height: 1, color: borderColor),

          // Client Details
          _sectionWidget(
            title: 'CLIENT DETAILS',
            primaryColor: primaryColor,
            fontRegular: fontRegular,
            fontBold: fontBold,
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: _infoItem(
                    'Client Name',
                    clientName,
                    textMuted,
                    textDark,
                    fontRegular,
                    fontBold,
                  ),
                ),
                pw.Expanded(
                  child: _infoItem(
                    'Phone',
                    phone.isNotEmpty ? '+91 $phone' : 'Not provided',
                    textMuted,
                    textDark,
                    fontRegular,
                    fontBold,
                  ),
                ),
              ],
            ),
          ),

          // Event Details
          _sectionWidget(
            title: 'EVENT DETAILS',
            primaryColor: primaryColor,
            fontRegular: fontRegular,
            fontBold: fontBold,
            child: pw.Column(
              children: [
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: _infoItem(
                        'Event Type',
                        eventType,
                        textMuted,
                        textDark,
                        fontRegular,
                        fontBold,
                      ),
                    ),
                    pw.Expanded(
                      child: _infoItem(
                        'Event Date',
                        eventDateStr,
                        textMuted,
                        textDark,
                        fontRegular,
                        fontBold,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: _infoItem(
                        'Guest Count',
                        '$guestCount Guests',
                        textMuted,
                        textDark,
                        fontRegular,
                        fontBold,
                      ),
                    ),
                    pw.Expanded(
                      child: _infoItem(
                        'Function Time',
                        functionTime.isNotEmpty ? functionTime : '-',
                        textMuted,
                        textDark,
                        fontRegular,
                        fontBold,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: _infoItem(
                        'Booking ID',
                        bookingId,
                        textMuted,
                        textDark,
                        fontRegular,
                        fontBold,
                      ),
                    ),
                    pw.Expanded(child: pw.SizedBox()),
                  ],
                ),
              ],
            ),
          ),

          // Payment Summary
          _sectionWidget(
            title: 'PAYMENT SUMMARY',
            primaryColor: primaryColor,
            fontRegular: fontRegular,
            fontBold: fontBold,
            child: pw.Table(
              border: pw.TableBorder(
                bottom: pw.BorderSide(color: borderColor),
                horizontalInside: pw.BorderSide(color: borderColor),
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(1.5),
              },
              children: [
                // Header row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: bgLight),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: pw.Text(
                        'Description',
                        style: ts(
                          fontSize: 9,
                          color: textMuted,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: pw.Text(
                        'Amount',
                        textAlign: pw.TextAlign.right,
                        style: ts(
                          fontSize: 9,
                          color: textMuted,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                // Hall booking row
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      child: pw.Text(
                        'Hall Booking - $eventType ($guestCount guests)',
                        style: ts(fontSize: 11, color: textDark),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      child: pw.Text(
                        fmt(total),
                        textAlign: pw.TextAlign.right,
                        style: ts(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                    ),
                  ],
                ),
                // Advance paid row
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      child: pw.Text(
                        'Advance Paid',
                        style: ts(fontSize: 11, color: textDark),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      child: pw.Text(
                        '- ${fmt(advance)}',
                        textAlign: pw.TextAlign.right,
                        style: ts(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: successColor,
                        ),
                      ),
                    ),
                  ],
                ),
                // Total row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: bgLight),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      child: pw.Text(
                        'Total Amount',
                        style: ts(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      child: pw.Text(
                        fmt(total),
                        textAlign: pw.TextAlign.right,
                        style: ts(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                    ),
                  ],
                ),
                // Balance row
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      child: pw.Text(
                        balance > 0 ? 'Balance Due' : 'Fully Paid',
                        style: ts(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: balance > 0 ? warningColor : successColor,
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      child: pw.Text(
                        fmt(balance),
                        textAlign: pw.TextAlign.right,
                        style: ts(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: balance > 0 ? warningColor : successColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Notes (if any)
          if (notes.isNotEmpty)
            _sectionWidget(
              title: 'NOTES',
              primaryColor: primaryColor,
              fontRegular: fontRegular,
              fontBold: fontBold,
              child: pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: bgLight,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Text(
                  notes,
                  style: ts(fontSize: 11, color: textBody, lineSpacing: 4),
                ),
              ),
            ),

          // Terms & Conditions
          if (termsAndConditions.trim().isNotEmpty)
            _sectionWidget(
              title: 'TERMS & CONDITIONS',
              primaryColor: primaryColor,
              fontRegular: fontRegular,
              fontBold: fontBold,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: termsAndConditions
                    .split('\n')
                    .where((line) => line.trim().isNotEmpty)
                    .map(
                      (line) => pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 4),
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              '- ',
                              style: ts(fontSize: 10, color: primaryColor),
                            ),
                            pw.Expanded(
                              child: pw.Text(
                                line.trim(),
                                style: ts(
                                  fontSize: 10,
                                  color: textBody,
                                  lineSpacing: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

          // Footer
          pw.Container(
            width: double.infinity,
            color: bgLight,
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 40,
              vertical: 16,
            ),
            child: pw.Column(
              children: [
                pw.Text(
                  'Thank you for choosing Bharath Convention Hall',
                  textAlign: pw.TextAlign.center,
                  style: ts(fontSize: 11, color: textMuted),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'This is a computer-generated invoice. For queries, please contact the hall management.',
                  textAlign: pw.TextAlign.center,
                  style: ts(fontSize: 9, color: textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _metaBlock(
    String label,
    String value,
    PdfColor labelColor,
    PdfColor valueColor,
    pw.Font fontRegular,
    pw.Font fontBold,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            font: fontRegular,
            fontSize: 9,
            color: labelColor,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          value,
          style: pw.TextStyle(
            font: fontBold,
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  static pw.Widget _infoItem(
    String label,
    String value,
    PdfColor labelColor,
    PdfColor valueColor,
    pw.Font fontRegular,
    pw.Font fontBold,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            font: fontRegular,
            fontSize: 9,
            color: labelColor,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          value,
          style: pw.TextStyle(
            font: fontBold,
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  static pw.Widget _sectionWidget({
    required String title,
    required pw.Widget child,
    required PdfColor primaryColor,
    required pw.Font fontRegular,
    required pw.Font fontBold,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.fromLTRB(40, 18, 40, 18),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColor.fromInt(0xFFEEEEEE)),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: primaryColor,
              letterSpacing: 0.5,
            ),
          ),
          pw.SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // Keep old _section for backward compatibility (unused but avoids compile errors)
  static pw.Widget _section({
    required String title,
    required pw.Widget child,
    required PdfColor primaryColor,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.fromLTRB(40, 18, 40, 18),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColor.fromInt(0xFFEEEEEE)),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: primaryColor,
              letterSpacing: 0.5,
            ),
          ),
          pw.SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
