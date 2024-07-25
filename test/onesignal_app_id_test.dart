import 'package:flutter_test/flutter_test.dart';
import 'package:mealup/model/app_setting_model.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/api_header.dart';

void main() {
  test(
    'Check if OneSignal App ID is not entered in the admin panel & in code locally',
    () async {
      AppSettingModel response;
      response = await RestClient(RetroApi().dioData()).setting();
      bool isAppIDComingFromBackend = (response.data!.customerAppId as String).isNotEmpty;

      bool success = isAppIDComingFromBackend;
      expect(success, true, reason: 'OneSignal App ID is not entered in the admin panel yet');
    },
  );
}
