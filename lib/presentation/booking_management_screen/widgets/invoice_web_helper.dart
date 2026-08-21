import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

class InvoiceDownloader {
  static void download(String htmlContent, String filename) {
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

  static void openUrl(String url) {
    web.window.open(url, '_blank');
  }

  static void print(String htmlContent) {
    final printWindow = web.window.open('', '_blank');
    if (printWindow != null) {
      printWindow.document.write(htmlContent.toJS);
      printWindow.document.close();
      printWindow.focus();
      printWindow.print();
    }
  }
}
