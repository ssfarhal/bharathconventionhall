import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

class InvoiceDownloader {
  static Future<void> download(String htmlContent, String filename) async {
    final Uint8List bytes = Uint8List.fromList(utf8.encode(htmlContent));
    final jsArray = bytes.toJS;
    final blob = web.Blob(
      [jsArray].toJS,
      web.BlobPropertyBag(type: 'text/html'),
    );
    final url = web.URL.createObjectURL(blob);
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
    anchor.href = url;
    anchor.download = filename;
    web.document.body!.appendChild(anchor);
    anchor.click();
    web.document.body!.removeChild(anchor);
    web.URL.revokeObjectURL(url);
  }

  /// Web stub — PDF download is handled natively on mobile only
  static Future<void> downloadPdf(
    Map<String, dynamic> data,
    String filename,
  ) async {
    // On web, fall back to HTML download
    final htmlFilename = filename.replaceAll('.pdf', '.html');
    // We don't have htmlContent here on web path, so this is a no-op
    // The caller only passes invoiceData for mobile; web uses _triggerWebDownload separately
  }

  static void openUrl(String url) {
    web.window.open(url, '_blank');
  }

  static Future<void> print(String htmlContent) async {
    final printWindow = web.window.open('', '_blank');
    if (printWindow != null) {
      printWindow.document.write(htmlContent.toJS);
      printWindow.document.close();
      printWindow.focus();
      printWindow.print();
    }
  }
}
