import 'package:flutter/material.dart';

import 'constants.dart';

// ignore: must_be_immutable
class CardTextFieldWidget extends StatelessWidget {
  CardTextFieldWidget({
    required this.hintText,
    required this.textInputType,
    required this.textInputAction,
    required this.textEditingController,
    this.errorText,
    this.validator,
    required this.focus, this.readOnly,
  });

  final String? hintText, errorText;
  Function? validator, focus;
  final TextEditingController textEditingController;
  final TextInputType textInputType;
  final TextInputAction textInputAction;
  final bool? readOnly;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0,right: 10),
      child: TextFormField(
        readOnly: readOnly ?? false,
        textInputAction: textInputAction,
        onFieldSubmitted: focus as void Function(String)?,
        validator: validator as String? Function(String?)?,
        keyboardType: textInputType,
        controller: textEditingController,
        decoration: Constants.kTextFieldInputDecoration.copyWith(hintText: hintText, errorText: errorText),
      ),
    );
  }
}
