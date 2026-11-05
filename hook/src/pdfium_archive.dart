import 'package:archive/archive.dart';

/// Verifies both archive layers before returning the requested PDFium library.
///
/// archive 4.6 otherwise permits damaged input to return partial data, which
/// must never be cached as a usable native library.
List<int> decodePdfiumLibrary(List<int> bytes, {required String libraryPath}) {
  final tar = GZipDecoder().decodeBytes(bytes, verify: true);
  final archive = TarDecoder().decodeBytes(tar, verify: true);
  final member = archive.findFile(libraryPath);
  if (member == null || !member.isFile || member.isSymbolicLink) {
    throw FormatException('PDFium archive does not contain $libraryPath.');
  }
  return member.content;
}
