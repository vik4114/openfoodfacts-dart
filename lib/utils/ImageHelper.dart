import 'package:image/image.dart';
import 'package:openfoodfacts/utils/OpenFoodAPIConfiguration.dart';
import 'package:openfoodfacts/utils/QueryType.dart';
import '../model/ProductImage.dart';
import 'LanguageHelper.dart';

/// Helper class related to product pictures
class ImageHelper {
  static const int MAX_IMAGE_SIZE = 2048;
  static const String IMAGE_PROD_URL_BASE =
      'https://static.openfoodfacts.org/images/products/';
  static const String IMAGE_TEST_URL_BASE =
      'https://static.openfoodfacts.net/images/products/';

  /// Returns a copy of the [image] with its bigger size GTE [maxsize]
  static Image resize(Image image, {int maxSize = MAX_IMAGE_SIZE}) {
    // check if the image is already small enough
    if (image.width <= maxSize || image.height <= maxSize) {
      return image;
    }

    // resize the image
    if (image.width > image.height) {
      return copyResize(image, width: maxSize);
    } else {
      return copyResize(image, height: maxSize);
    }
  }

  /// Returns the product image full url, or null if [barcode] is null
  ///
  /// E.g. "https://static.openfoodfacts.org/images/products/359/671/046/2858/front_fr.4.100.jpg"
  static String? buildUrl(
    final String? barcode,
    final ProductImage image, {
    final QueryType? queryType,
  }) =>
      barcode == null
          ? null
          : getProductImageRootUrl(barcode, queryType: queryType) +
              '/' +
              image.field.value +
              '_' +
              image.language.code +
              '.' +
              image.rev.toString() +
              '.' +
              image.size.toNumber() +
              '.jpg';

  /// Returns the product image filename
  ///
  /// E.g. "front_fr.4.100.jpg"
  static String getProductImageFilename(final ProductImage image) =>
      image.field.value +
      '_' +
      image.language.code +
      '.' +
      image.rev.toString() +
      '.' +
      image.size.toNumber() +
      '.jpg';

  /// Returns the web folder of the product images (without trailing '/')
  ///
  /// E.g. "https://static.openfoodfacts.org/images/products/359/671/046/2858"
  static String getProductImageRootUrl(
    final String barcode, {
    final QueryType? queryType,
  }) {
    final String barcodeUrl;
    if (barcode.length >= 9) {
      var p1 = barcode.substring(0, 3);
      var p2 = barcode.substring(3, 6);
      var p3 = barcode.substring(6, 9);
      var p4 = barcode.length >= 10 ? barcode.substring(9) : '';
      barcodeUrl = p1 + '/' + p2 + '/' + p3 + '/' + p4;
    } else {
      barcodeUrl = barcode;
    }

    return OpenFoodAPIConfiguration.getQueryType(queryType) == QueryType.PROD
        ? IMAGE_PROD_URL_BASE + barcodeUrl
        : IMAGE_TEST_URL_BASE + barcodeUrl;
  }
}
