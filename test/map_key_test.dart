import 'package:flutter_test/flutter_test.dart';
import 'package:mealup/utils/constants.dart';

void main() {
  test(
    'Check if map key exists/entered in constants',
    () {
      expect(
        (Constants.androidKey != "Enter_Your_Google_Map_Key" &&
            Constants.iosKey != "Enter_Your_Google_Map_Key_For_iOS"),
        isTrue,
        reason: 'The Google Map keys are not set in "/lib/utils/constants.dart"',
      );
    },
  );
}
