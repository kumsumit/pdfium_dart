import 'package:archive/archive.dart';
import 'package:test/test.dart';

import '../hook/src/pdfium_archive.dart';

void main() {
  const path = 'lib/libpdfium.so';
  final library = [1, 2, 3, 4];

  List<int> tar() => TarEncoder().encode(
    Archive()..addFile(ArchiveFile(path, library.length, library)),
  );

  test('extracts the requested library from a verified archive', () {
    expect(
      decodePdfiumLibrary(GZipEncoder().encode(tar()), libraryPath: path),
      library,
    );
  });

  test('rejects a damaged gzip checksum', () {
    final bytes = GZipEncoder().encode(tar());
    bytes[bytes.length - 8] ^= 0xff;
    expect(
      () => decodePdfiumLibrary(bytes, libraryPath: path),
      throwsA(isA<ArchiveException>()),
    );
  });

  test('rejects a truncated gzip stream', () {
    final bytes = GZipEncoder().encode(tar());
    expect(
      () => decodePdfiumLibrary(
        bytes.sublist(0, bytes.length - 4),
        libraryPath: path,
      ),
      throwsA(isA<ArchiveException>()),
    );
  });

  test('rejects a damaged tar header inside a valid gzip stream', () {
    final bytes = tar();
    bytes[0] ^= 0xff;
    expect(
      () => decodePdfiumLibrary(GZipEncoder().encode(bytes), libraryPath: path),
      throwsA(isA<ArchiveException>()),
    );
  });

  test('reports a missing library', () {
    expect(
      () => decodePdfiumLibrary(
        GZipEncoder().encode(tar()),
        libraryPath: 'bin/pdfium.dll',
      ),
      throwsFormatException,
    );
  });
}
