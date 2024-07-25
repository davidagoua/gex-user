import 'dart:convert';
import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealup/model/common_res.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/app_lable_widget.dart';
import 'package:mealup/utils/app_toolbar.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/localization/lang_constant.dart';
import 'package:mealup/localization/localization_constant.dart';
import 'package:mealup/utils/extension_methods.dart';
import 'package:mealup/utils/rounded_corner_app_button.dart';

class OrderReviewScreen extends StatefulWidget {

  final int? orderId;

  const OrderReviewScreen({Key? key, this.orderId}) : super(key: key);

  @override
  _OrderReviewScreenState createState() => _OrderReviewScreenState();
}

class Item {
  const Item(this.name, this.icon);

  final String name;
  final Icon icon;
}

class _OrderReviewScreenState extends State<OrderReviewScreen> {
  /// 😠 😕 😐 ☺ 😍
  int radioindex = -1;

  String? strCountryCode = '+91';

  bool isFirst = true,
      isSecond = false,
      isThird = false,
      isAllAdded = false;

  final picker = ImagePicker();

  final _textContactNo = TextEditingController();
  final _textComment = TextEditingController();
  final _textContactCode = TextEditingController();

  List<File> _imageList = [];
  final _formKey = new GlobalKey<FormState>();
  List<String> _listBase64String = [];

  double orderRate = 0;

  @override
  void initState() {
    super.initState();
    _textContactNo.text = SharedPreferenceUtil.getString(Constants.loginPhone);
    _textContactCode.text = SharedPreferenceUtil.getString(Constants.loginPhoneCode);
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
          appBar: ApplicationToolbar(
            appbarTitle: getTranslated(context, LangConst.labelOrderReview).toString(),
          ),
          backgroundColor: Color(0xFFFAFAFA),
          body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints viewportConstraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: viewportConstraints.maxHeight),
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('images/ic_background_image.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: ScreenUtil().setHeight(150),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Image.asset('images/ic_review_start.png'),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(25.0),
                          child: Container(
                            child: Form(
                              key: _formKey,
                              autovalidateMode: AutovalidateMode.always,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5, bottom: 5),
                                    child: Text(
                                      getTranslated(context, LangConst.labelGiveStar).toString(),
                                      style: TextStyle(
                                          fontSize: ScreenUtil().setSp(16),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Center(
                                    child: RatingBar.builder(
                                      minRating: 1,
                                      direction: Axis.horizontal,
                                      glow: false,
                                      itemSize: ScreenUtil().setWidth(50),
                                      allowHalfRating: true,
                                      itemBuilder: (context, _) =>
                                          Icon(
                                            Icons.star,
                                            color: Constants.colorTheme,
                                          ),
                                      onRatingUpdate: (double rating) {
                                        setState(() => orderRate = rating);
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: ScreenUtil().setWidth(5),
                                        bottom: ScreenUtil().setHeight(5),
                                        top: ScreenUtil().setHeight(15)),
                                    child: Text(
                                      getTranslated(context, LangConst.labelReviewThisFood).toString(),
                                      style: TextStyle(
                                          fontSize: ScreenUtil().setSp(16),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Container(
                                    height: ScreenUtil().setHeight(130),
                                    child: Card(
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextFormField(
                                          controller: _textComment,
                                          keyboardType: TextInputType.text,
                                          validator: kvalidateFeedbackComment,
                                          decoration: InputDecoration(
                                              hintText: getTranslated(context, LangConst.labelAddYourValuableFeedback).toString(),
                                              errorStyle: TextStyle(
                                                  fontFamily: Constants.appFontBold,
                                                  color: Colors.red),
                                              border: InputBorder.none),
                                          maxLines: 4,
                                          style: TextStyle(
                                            fontFamily: Constants.appFont,
                                            fontSize: ScreenUtil().setSp(14),
                                            color:
                                            Constants.colorGray,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Wrap(
                                      direction: Axis.horizontal,
                                      children: [
                                        Card(
                                          elevation: 3,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                          child: _imageList.length > 0
                                              ? Image.file(
                                            _imageList[0],
                                            width: ScreenUtil().setWidth(60),
                                            height: ScreenUtil().setHeight(60),
                                            fit: BoxFit.cover,
                                          )
                                              : Container(
                                            width: ScreenUtil().setWidth(60),
                                            height: ScreenUtil().setHeight(60),
                                          ),
                                        ),
                                        Card(
                                          elevation: 3,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                          child: _imageList.length > 1
                                              ? Image.file(
                                            _imageList[1],
                                            width: ScreenUtil().setWidth(60),
                                            height: ScreenUtil().setHeight(60),
                                            fit: BoxFit.cover,
                                          )
                                              : Container(
                                            width: ScreenUtil().setWidth(60),
                                            height: ScreenUtil().setHeight(60),
                                          ),
                                        ),
                                        Card(
                                          elevation: 3,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                          child: _imageList.length > 2
                                              ? Image.file(
                                            _imageList[2],
                                            width: ScreenUtil().setWidth(60),
                                            height: ScreenUtil().setHeight(60),
                                            fit: BoxFit.cover,
                                          )
                                              : Container(
                                            width: ScreenUtil().setWidth(60),
                                            height: ScreenUtil().setHeight(60),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            if (!isAllAdded) {
                                              if (isFirst) {
                                                _showPicker(context, 0);
                                              } else if (isSecond) {
                                                _showPicker(context, 1);
                                              } else if (isThird) {
                                                _showPicker(context, 2);
                                              }
                                            } else {
                                              Constants.toastMessage(
                                                  getTranslated(context, LangConst.labelMax3Image).toString());
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 10, top: 5),
                                            child: DottedBorder(
                                              borderType: BorderType.RRect,
                                              radius: Radius.circular(16),
                                              strokeWidth: 2,
                                              dashPattern: [8, 4],
                                              color: Color(0xffdddddd),
                                              child: ClipRRect(
                                                borderRadius:
                                                BorderRadius.all(Radius.circular(12)),
                                                child: Container(
                                                  height: ScreenUtil().setHeight(60),
                                                  width: ScreenUtil().setWidth(60),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(20.0),
                                                    child: SvgPicture.asset(
                                                      'images/ic_plus1.svg',
                                                      colorFilter: Color(0xffdddddd).toColorFilter,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: ScreenUtil().setHeight(20),
                                  ),
                                  AppLableWidget(
                                    title: getTranslated(context, LangConst.labelContactNumber).toString(),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            new BorderRadius.circular(
                                                15.0),
                                            color: Constants.colorWhite,
                                            border: Border.all(
                                              color: Colors.grey,
                                              width: 0.5,
                                            ),
                                          ),
                                          height: ScreenUtil().setHeight(48),
                                          child: CountryCodePicker(
                                            enabled: false,
                                            padding: EdgeInsets.zero,
                                            onChanged: (c) {
                                              setState(() {
                                                strCountryCode = c.dialCode;
                                              });
                                            },
                                            // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                                            initialSelection: _textContactCode
                                                .text
                                                .toString(),
                                            favorite: [
                                              _textContactCode.text
                                                  .toString(),
                                              ''
                                            ],
                                            hideMainText: true,
                                            alignLeft: true,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Container(
                                          width: 215,
                                          child: TextFormField(
                                            textInputAction:
                                            TextInputAction.next,
                                            controller: _textContactNo,
                                            validator: kvalidateCotactNum,
                                            maxLength: 10,
                                            buildCounter: (context,
                                                {required currentLength,
                                                  required isFocused,
                                                  maxLength}) =>
                                            null,
                                            keyboardType:
                                            TextInputType.number,
                                            onFieldSubmitted: (v) {
                                              FocusScope.of(context)
                                                  .nextFocus();
                                            },
                                            decoration: InputDecoration(
                                              enabled: false,
                                              prefixIcon: Padding(
                                                  padding: EdgeInsets.all(15),
                                                  child: Text(
                                                      '${_textContactCode.text.toString()} ')),
                                              hintStyle: TextStyle(
                                                  color: Constants.colorHint),
                                              errorStyle: TextStyle(
                                                  fontFamily:
                                                  Constants.appFontBold,
                                                  color: Colors.red),
                                              filled: true,
                                              fillColor: Constants.colorWhite,
                                              contentPadding:
                                              const EdgeInsets.only(
                                                  left: 14.0,
                                                  bottom: 6.0,
                                                  top: 8.0,
                                                  right: 14),
                                              errorMaxLines: 2,
                                              border: new OutlineInputBorder(
                                                borderRadius:
                                                new BorderRadius.circular(
                                                    15.0),
                                                borderSide: BorderSide(
                                                    width: 0.5,
                                                    color: Colors.grey),
                                              ),
                                              enabledBorder:
                                              new OutlineInputBorder(
                                                borderRadius:
                                                new BorderRadius.circular(
                                                    15.0),
                                                borderSide: BorderSide(
                                                    width: 0.5,
                                                    color: Colors.grey),
                                              ),
                                              disabledBorder:
                                              new OutlineInputBorder(
                                                borderRadius:
                                                new BorderRadius.circular(
                                                    15.0),
                                                borderSide: BorderSide(
                                                    width: 0.5,
                                                    color: Colors.grey),
                                              ),
                                              focusedBorder:
                                              new OutlineInputBorder(
                                                borderRadius:
                                                new BorderRadius.circular(
                                                    15.0),
                                                borderSide: BorderSide(
                                                    width: 0.5,
                                                    color: Colors.grey),
                                              ),
                                              errorBorder:
                                              new OutlineInputBorder(
                                                borderRadius:
                                                new BorderRadius.circular(
                                                    15.0),
                                                borderSide: BorderSide(
                                                    width: 0.5,
                                                    color: Colors.red),
                                              ),
                                              focusedErrorBorder:
                                              new OutlineInputBorder(
                                                borderRadius:
                                                new BorderRadius.circular(
                                                    15.0),
                                                borderSide: BorderSide(
                                                    width: 1,
                                                    color: Colors.red),
                                              ),
                                              hintText: '000 000 0000',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: ScreenUtil().setHeight(50),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: RoundedCornerAppButton(
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          print(_listBase64String.toString());
                                          print(radioindex);
                                          if (orderRate != 0) {
                                            callShareAppFeedback(orderRate);
                                          } else {
                                            Constants.toastMessage(
                                                getTranslated(context, LangConst.labelPleaseGiveStar).toString());
                                          }
                                        } else {
                                          setState(() {
                                          });
                                        }
                                      },
                                      btnLabel: getTranslated(context, LangConst.labelSubmitIt).toString(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          )),
    );
  }

  String? kvalidateCotactNum(String? value) {
    if (value!.length == 0) {
      return getTranslated(context, LangConst.labelContactNumberRequired).toString();
    } else if (value.length > 10) {
      return getTranslated(context, LangConst.labelContactNumberNotValid).toString();
    } else
      return null;
  }

  String? kvalidateFeedbackComment(String? value) {
    if (value!.length == 0) {
      return getTranslated(context, LangConst.labelFeedbackCommentRequired).toString();
    } else
      return null;
  }

  bool isCurrentDateInRange(DateTime startDate, DateTime endDate) {
    final currentDate = DateTime.now();
    return currentDate.isAfter(startDate) && currentDate.isBefore(endDate);
  }

  _imgFromGallery(int pos) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageList.add(File(pickedFile.path));
        List<int> imageBytes = _imageList[pos].readAsBytesSync();
        _listBase64String.add(base64Encode(imageBytes));

        if (pos == 0) {
          isFirst = false;
          isSecond = true;
        } else if (pos == 1) {
          isSecond = false;
          isThird = true;
        } else if (pos == 2) {
          isThird = false;
          isAllAdded = true;
        }
      } else {
        print('No image selected.');
      }
    });
  }

  Future getImage(int pos) async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _imageList.add(File(pickedFile.path));
        List<int> imageBytes = _imageList[pos].readAsBytesSync();
        _listBase64String.add(base64Encode(imageBytes));
        if (pos == 0) {
          isFirst = false;
          isSecond = true;
        } else if (pos == 1) {
          isSecond = false;
          isThird = true;
        } else if (pos == 2) {
          isThird = false;
          isAllAdded = true;
        }
      } else {
        print('No image selected.');
      }
    });
  }

  void _showPicker(context, int pos) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.photo_library),
                    title: new Text(
                      getTranslated(context, LangConst.labelPhotoLibrary).toString(),
                      style: TextStyle(fontFamily: Constants.appFont),
                    ),
                    onTap: () {
                      _imgFromGallery(pos);
                      Navigator.of(context).pop();
                    }),
                new ListTile(
                  leading: new Icon(Icons.photo_camera),
                  title: new Text(
                    getTranslated(context, LangConst.labelCamera).toString(),
                    style: TextStyle(fontFamily: Constants.appFont),
                  ),
                  onTap: () {
                    getImage(pos);
                    Navigator.of(context).pop();
                  },
                ),
                new ListTile(
                  leading: new Icon(Icons.close),
                  title: new Text(
                    getTranslated(context, LangConst.labelCancel).toString(),
                    style: TextStyle(fontFamily: Constants.appFont),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<BaseModel<CommenRes>> callShareAppFeedback(double rate) async {
    CommenRes response;
    try {
      Map<String, dynamic> body = {
        'rate': rate.toString(),
        'comment': _textComment.text,
        'order_id': widget.orderId,
        'contact': _textContactNo.text,
      };
      response = await RestClient(RetroApi().dioData()).addReview(body, _listBase64String);
      print(response.success);
      if (response.success!) {
        Constants.toastMessage(response.data!);
        Navigator.pop(context);
      } else {
        Constants.toastMessage(response.data!);
      }
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()
        ..setException(ServerError.withError(error: error));
    }
    return BaseModel()
      ..data = response;
  }
}