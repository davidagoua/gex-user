import 'package:dio/dio.dart' hide Headers;
import 'package:mealup/utils/constants.dart';

class ServerError implements Exception {
  int? _errorCode;
  String _errorMessage = "";

  ServerError.withError({error}) {
    _handleError(error);
  }

  getErrorCode() {
    return _errorCode;
  }

  getErrorMessage() {
    return _errorMessage;
  }

  _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        _errorMessage = "Connection timeout";
        Constants.toastMessage('Connection timeout');
        break;
      case DioExceptionType.connectionError:
        _errorMessage = "Connection failed. Please check your internet connection";
        Constants.toastMessage('Connection failed due to internet connection');
        break;
      case DioExceptionType.sendTimeout:
        _errorMessage = "Receive timeout in send request";
        Constants.toastMessage('Receive timeout in send request');
        break;
      case DioExceptionType.receiveTimeout:
        _errorMessage = "Receive timeout in connection";
        Constants.toastMessage('Receive timeout in connection');
        break;
      case DioExceptionType.badResponse:
      case DioExceptionType.badCertificate:
        _errorMessage = "Received invalid status code: ${error.response!.data}";
        try {
          if (error.response!.data['errors']['name'] != null) {
            Constants.toastMessage(error.response!.data['errors']['name'][0]);
            return;
          } else if (error.response!.data['errors']['phone'] != null) {
            Constants.toastMessage(error.response!.data['errors']['phone'][0]);
            return;
          } else if (error.response!.data['errors']['email_id'] != null) {
            Constants.toastMessage(error.response!.data['errors']['email_id'][0]);
            return;
          } else if (error.response!.data['errors']['comment'] != null) {
            Constants.toastMessage(error.response!.data['errors']['comment'][0]);
            return;
          } else {
            Constants.toastMessage(error.response!.data['message'].toString());
            return;
          }
        } catch (error1, stacktrace) {
          Constants.toastMessage(error.response!.data.toString());
          print(
              "Exception occurred: $error stackTrace: $stacktrace apiError: ${error.response!.data}");
        }
        break;
      case DioExceptionType.cancel:
        _errorMessage = "Request was cancelled";
        Constants.toastMessage('Request was cancelled');
        break;
      case DioExceptionType.unknown:
        _errorMessage =
        "Something Went Wrong !";
        Constants.toastMessage('Something Went Wrong! Try After Some Time.');
        break;
    }
    return _errorMessage;
  }
}