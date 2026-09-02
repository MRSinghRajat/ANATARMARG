import 'package:flutter_test/flutter_test.dart';
import 'package:antarmarg/features/books/presentation/widgets/deity_portrait.dart';

void main() {
  test('every bundled deity slug maps to a webp path', () {
    expect(kBundledDeitySlugs.length, 12);
    expect(bundledDeityAssetPath('Vishnu'), 'assets/images/deities/vishnu.webp');
    expect(bundledDeityAssetPath('Krishna'), 'assets/images/deities/krishna.webp');
    expect(bundledDeityAssetPath('unknown'), isNull);
    expect(bundledDeityAssetPath(null), isNull);
  });
}
