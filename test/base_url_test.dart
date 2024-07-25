import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealup/model/app_setting_model.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/utils/constants.dart';

void main() {
  test(
    'Check pattern of baseURL in Constants',
    () {
      // Define the regex pattern for the URL
      var pattern1 = RegExp(r'^https:\/\/.*\/api\/$');
      var pattern2 = RegExp(r'^http:\/\/.*\/api\/$');

      /// Check if the [Constants.baseURL] matches the pattern
      expect(
        ((pattern1.hasMatch(Constants.baseURL) || pattern2.hasMatch(Constants.baseURL)) &&
            Constants.baseURL != "https://ENTER_YOUR_BASE_URL/api/"),
        isTrue,
        reason: 'The baseURL is not set or does not match the required format',
      );
    },
  );

  test(
    'api_client.g.dart file exists',
    () {
      var filePath = 'lib/retrofit/api_client.g.dart';

      // Check if the file exists
      expect(File(filePath).existsSync(), isTrue,
          reason: 'api_client.g.dart file does not exist/\n'
              'Please run the command: flutter pub run build_runner build --delete-conflicting-outputs');
    },
  );

  test(
    'Check if [Apis.settings] endpoint is giving response',
    () async {
      AppSettingModel response;
      response = await RestClient(RetroApi().dioData()).setting();
      expect(response.success, true, reason: 'The response from app setting api is not successful');
    },
  );
}
