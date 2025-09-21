import 'package:barcode/barcode.dart';

/// Lookup table for all supported barcode types
final Map<String, Barcode> barcodeTypes = {
  "QR": Barcode.qrCode(),
  "Code39": Barcode.code39(),
  "Code93": Barcode.code93(),
  "Code128": Barcode.code128(),
  "EAN8": Barcode.ean8(),
  "EAN13": Barcode.ean13(),
  "EAN2": Barcode.ean2(),
  "EAN5": Barcode.ean5(),
  "UPCA": Barcode.upcA(),
  "UPCE": Barcode.upcE(),
  "ISBN": Barcode.isbn(),
  "ITF": Barcode.itf(),
  "PDF417": Barcode.pdf417(),
  "Aztec": Barcode.aztec(),
  "Codabar": Barcode.codabar(),
  "Telepen": Barcode.telepen(),
  "RM4SCC": Barcode.rm4scc(),
};
