import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:location/location.dart';
import 'package:mealup/model/order_history_list_model.dart';
import 'package:mealup/model/order_status.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/bottom_navigation/dashboard_screen.dart';
import 'package:mealup/screens/order_details_screen.dart';
import 'package:mealup/screens/order_review_screen.dart';
import 'package:mealup/screens/track_your_order_screen_here_map.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/app_toolbar_with_btn_clr.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/localization/lang_constant.dart';
import 'package:mealup/localization/localization_constant.dart';
import 'package:mealup/utils/extension_methods.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class OrderHistoryScreen extends StatefulWidget {
  final bool isFromProfile;

  const OrderHistoryScreen({required this.isFromProfile});

  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  bool _isSyncing = false;
  List<OrderHistoryData> _listOrderHistory = [];
  List<OrderStatusData> _listOrderStatus = [];

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  late Timer timer;
  int counter = 0;
  LocationData? _locationData;
  Location _location = Location();
  double? _currentLatitude;
  double? _currentLongitude;

  void _onRefresh() async {
    await Future.delayed(Duration(milliseconds: 1000));
    Constants.checkNetwork().whenComplete(() => callGetOrderHistoryList());

    if (mounted) setState(() {});
    _refreshController.refreshCompleted();
  }

  @override
  void dispose() {
    super.dispose();
    if (timer.isActive) {
      timer.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    getUserLocation();
    Constants.checkNetwork().whenComplete(() => callGetOrderHistoryList());
    timer = Timer.periodic(
        Duration(
            minutes: SharedPreferenceUtil.getInt(
                Constants.appSettingDriverAutoRefresh)), (t) {
      // setState(() {
      //   counter++;
      //   Constants.checkNetwork().whenComplete(() => callGetOrderStatus());
      // });
    });
    callGetOrderStatus();
    callSetState();
  }

  Future<void> getUserLocation() async {
    if (SharedPreferenceUtil.getString('selectedLat1').toString().isNotEmpty) {
      _currentLatitude =
          double.parse(SharedPreferenceUtil.getString('selectedLat1'));
      _currentLongitude =
          double.parse(SharedPreferenceUtil.getString('selectedLng1'));
    } else {
      _locationData = await _location.getLocation();
      if (_locationData != null) {
        _currentLatitude = _locationData!.latitude;
        _currentLongitude = _locationData!.longitude;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (widget.isFromProfile) {
          Navigator.pop(context);
        } else {
          Navigator.of(context).pushAndRemoveUntil(
              Transitions(
                transitionType: TransitionType.fade,
                curve: Curves.bounceInOut,
                reverseCurve: Curves.fastLinearToSlowEaseIn,
                widget: DashboardScreen(3),
              ),
              (Route<dynamic> route) => false);
        }
        return Future.value(true);
      },
      child: SafeArea(
        child: Scaffold(
          appBar: ApplicationToolbarWithClrBtn(
            appbarTitle: getTranslated(context, LangConst.labelOrderHistory).toString(),
            strButtonTitle: "",
            btnColor: Constants.colorLike,
            onBtnPress: () {},
          ),
          body: SmartRefresher(
            enablePullDown: true,
            header: MaterialClassicHeader(
              backgroundColor: Constants.colorTheme,
              color: Constants.colorWhite,
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: ModalProgressHUD(
              inAsyncCall: _isSyncing,
              child: Container(
                decoration: BoxDecoration(
                    color: Constants.colorBackground,
                    image: DecorationImage(
                      image: AssetImage('images/ic_background_image.png'),
                      fit: BoxFit.cover,
                    )),
                child: _listOrderHistory.length == 0
                    ? !_isSyncing
                        ? Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image(
                                  width: 150,
                                  height: 180,
                                  image: AssetImage(
                                      'images/ic_no_order_history.png'),
                                ),
                                Text(
                                  getTranslated(context, LangConst.labelNoOrderHistory).toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: ScreenUtil().setSp(18),
                                    fontFamily: Constants.appFontBold,
                                    color: Constants.colorTheme,
                                  ),
                                )
                              ],
                            ),
                          )
                        : Container()
                    : SingleChildScrollView(
                        child: ListView.builder(
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            padding: EdgeInsets.only(
                                bottom: 20, left: 10, right: 10),
                            scrollDirection: Axis.vertical,
                            itemCount: _listOrderHistory.length,
                            itemBuilder:
                                (BuildContext context, int index) => Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10, right: 10),
                                          child: Text(
                                            (() {
                                                  if (_listOrderHistory[index]
                                                          .addressId !=
                                                      null) {
                                                    if (_listOrderHistory[index]
                                                            .orderStatus ==
                                                        'PENDING') {
                                                      return '${getTranslated(context, LangConst.labelOrderedOn).toString()} ${_listOrderHistory[index].date}, ${_listOrderHistory[index].time}';
                                                    } else if (_listOrderHistory[
                                                                index]
                                                            .orderStatus ==
                                                        'ACCEPT') {
                                                      return '${getTranslated(context, LangConst.labelAcceptedOn).toString()} ${_listOrderHistory[index].date}, ${_listOrderHistory[index].time}';
                                                    } else if (_listOrderHistory[
                                                                index]
                                                            .orderStatus ==
                                                        'APPROVE') {
                                                      return '${getTranslated(context, LangConst.labelApproveOn).toString()} ${_listOrderHistory[index].date}, ${_listOrderHistory[index].time}';
                                                    } else if (_listOrderHistory[
                                                                index]
                                                            .orderStatus ==
                                                        'REJECT') {
                                                      return '${getTranslated(context, LangConst.labelRejectedOn).toString()} ${_listOrderHistory[index].date}, ${_listOrderHistory[index].time}';
                                                    } else if (_listOrderHistory[
                                                                index]
                                                            .orderStatus ==
                                                        'PICKUP') {
                                                      return '${getTranslated(context, LangConst.labelPickedUpOn).toString()} ${_listOrderHistory[index].date}, ${_listOrderHistory[index].time}';
                                                    } else if (_listOrderHistory[
                                                                index]
                                                            .orderStatus ==
                                                        'DELIVERED') {
                                                      return '${getTranslated(context, LangConst.labelDeliveredOn).toString()} ${_listOrderHistory[index].date}, ${_listOrderHistory[index].time}';
                                                    } else if (_listOrderHistory[
                                                                index]
                                                            .orderStatus ==
                                                        'CANCEL') {
                                                      return '${getTranslated(context, LangConst.labelCanceledOn).toString()} ${_listOrderHistory[index].date}, ${_listOrderHistory[index].time}';
                                                    } else if (_listOrderHistory[
                                                                index]
                                                            .orderStatus ==
                                                        'COMPLETE') {
                                                      return '${getTranslated(context, LangConst.labelDeliveredOn).toString()} ${_listOrderHistory[index].date}, ${_listOrderHistory[index].time}';
                                                    }
                                                  } else {
                                                    if (_listOrderHistory[index]
                                                            .orderStatus ==
                                                        'PENDING') {
                                                      return '${getTranslated(context, LangConst.labelOrderedOn).toString()} ${_listOrderHistory[index].date}, ${_listOrderHistory[index].time}';
                                                    } else if (_listOrderHistory[
                                                                index]
                                                            .orderStatus ==
                                                        'ACCEPT') {
                                                      return '${getTranslated(context, LangConst.labelAcceptedOn).toString()} ${_listOrderHistory[index].date}, ${_listOrderHistory[index].time}';
                                                    } else if (_listOrderHistory[
                                                                index]
                                                            .orderStatus ==
                                                        'APPROVE') {
                                                      return '${getTranslated(context, LangConst.labelApproveOn).toString()} ${_listOrderHistory[index].date}, ${_listOrderHistory[index].time}';
                                                    } else if (_listOrderHistory[
                                                                index]
                                                            .orderStatus ==
                                                        'REJECT') {
                                                      return '${getTranslated(context, LangConst.labelRejectedOn).toString()} ${_listOrderHistory[index].date}, ${_listOrderHistory[index].time}';
                                                    } else if (_listOrderHistory[
                                                                index]
                                                            .orderStatus ==
                                                        'PREPARE_FOR_ORDER') {
                                                      return '${getTranslated(context, LangConst.labelPREPAREFORORDER).toString()} ${_listOrderHistory[index].date}, ${_listOrderHistory[index].time}';
                                                    } else if (_listOrderHistory[
                                                                index]
                                                            .orderStatus ==
                                                        'READY_FOR_ORDER') {
                                                      return '${getTranslated(context, LangConst.labelREADYFORORDER).toString()} ${_listOrderHistory[index].date}, ${_listOrderHistory[index].time}';
                                                    } else if (_listOrderHistory[
                                                                index]
                                                            .orderStatus ==
                                                        'CANCEL') {
                                                      return '${getTranslated(context, LangConst.labelCanceledOn).toString()} ${_listOrderHistory[index].date}, ${_listOrderHistory[index].time}';
                                                    } else if (_listOrderHistory[
                                                                index]
                                                            .orderStatus ==
                                                        'COMPLETE') {
                                                      return '${getTranslated(context, LangConst.labelDeliveredOn).toString()} ${_listOrderHistory[index].date}, ${_listOrderHistory[index].time}';
                                                    }
                                                  }
                                                }()) ??
                                                '',
                                            style: TextStyle(
                                                color: Constants.colorGray,
                                                fontFamily: Constants.appFont,
                                                fontSize: 12),
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).push(
                                                Transitions(
                                                    transitionType:
                                                        TransitionType.fade,
                                                    curve: Curves.bounceInOut,
                                                    reverseCurve: Curves
                                                        .fastLinearToSlowEaseIn,
                                                    widget: OrderDetailsScreen(
                                                      orderId:
                                                          _listOrderHistory[
                                                                  index]
                                                              .id,
                                                      orderDate:
                                                          _listOrderHistory[
                                                                  index]
                                                              .date,
                                                      orderTime:
                                                          _listOrderHistory[
                                                                  index]
                                                              .time,
                                                    )));
                                          },
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                            ),
                                            margin: EdgeInsets.only(
                                                top: 5, right: 5, bottom: 20),
                                            child: Column(
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5.0),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15.0),
                                                        child:
                                                            CachedNetworkImage(
                                                          height: ScreenUtil()
                                                              .setHeight(70),
                                                          width: ScreenUtil()
                                                              .setWidth(70),
                                                          imageUrl:
                                                              _listOrderHistory[
                                                                      index]
                                                                  .vendor!
                                                                  .image!,
                                                          fit: BoxFit.cover,
                                                          placeholder: (context,
                                                                  url) =>
                                                              SpinKitFadingCircle(
                                                                  color: Constants
                                                                      .colorTheme),
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              Container(
                                                            child: Center(
                                                                child: Image.asset(
                                                                    'images/noimage.png')),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                flex: 4,
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      left: 10,
                                                                      top: 10),
                                                                  child: Text(
                                                                    _listOrderHistory[
                                                                            index]
                                                                        .vendor!
                                                                        .name!,
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            Constants
                                                                                .appFontBold,
                                                                        fontSize:
                                                                            16),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 3,
                                                                    left: 10,
                                                                    right: 5),
                                                            child: Text(
                                                              _listOrderHistory[
                                                                          index]
                                                                      .vendor!
                                                                      .mapAddress ??
                                                                  '',
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      Constants
                                                                          .appFont,
                                                                  color: Constants
                                                                      .colorGray,
                                                                  fontSize: 13),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: ScreenUtil()
                                                                .setHeight(10),
                                                          ),
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      left: 10,
                                                                      top: 10),
                                                                  child: Text(
                                                                    SharedPreferenceUtil.getString(
                                                                            Constants.appSettingCurrencySymbol) +
                                                                        '${_listOrderHistory[index].amount?.toStringAsFixed(2)}',
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            Constants
                                                                                .appFont,
                                                                        fontSize:
                                                                            14),
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        top: 10,
                                                                        right:
                                                                            20),
                                                                child: RichText(
                                                                  text:
                                                                      TextSpan(
                                                                    children: [
                                                                      WidgetSpan(
                                                                        child:
                                                                            Padding(
                                                                          padding:
                                                                              const EdgeInsets.only(right: 5),
                                                                          child:
                                                                              SvgPicture.asset(
                                                                            (() {
                                                                                  if (_listOrderHistory[index].addressId != null) {
                                                                                    if (_listOrderHistory[index].orderStatus == 'PENDING') {
                                                                                      return 'images/ic_pending.svg';
                                                                                    } else if (_listOrderHistory[index].orderStatus == 'APPROVE') {
                                                                                      return 'images/ic_accept.svg';
                                                                                    } else if (_listOrderHistory[index].orderStatus == 'ACCEPT') {
                                                                                      return 'images/ic_accept.svg';
                                                                                    } else if (_listOrderHistory[index].orderStatus == 'REJECT') {
                                                                                      return 'images/ic_cancel.svg';
                                                                                    } else if (_listOrderHistory[index].orderStatus == 'PICKUP') {
                                                                                      return 'images/ic_pickup.svg';
                                                                                    } else if (_listOrderHistory[index].orderStatus == 'DELIVERED') {
                                                                                      return 'images/ic_completed.svg';
                                                                                    } else if (_listOrderHistory[index].orderStatus == 'CANCEL') {
                                                                                      return 'images/ic_cancel.svg';
                                                                                    } else if (_listOrderHistory[index].orderStatus == 'COMPLETE') {
                                                                                      return 'images/ic_completed.svg';
                                                                                    }
                                                                                  } else {
                                                                                    if (_listOrderHistory[index].orderStatus == 'PENDING') {
                                                                                      return 'images/ic_pending.svg';
                                                                                    } else if (_listOrderHistory[index].orderStatus == 'APPROVE') {
                                                                                      return 'images/ic_accept.svg';
                                                                                    } else if (_listOrderHistory[index].orderStatus == 'PREPARE_FOR_ORDER') {
                                                                                      return 'images/ic_pickup.svg';
                                                                                    } else if (_listOrderHistory[index].orderStatus == 'READY_FOR_ORDER') {
                                                                                      return 'images/ic_completed.svg';
                                                                                    } else if (_listOrderHistory[index].orderStatus == 'REJECT') {
                                                                                      return 'images/ic_cancel.svg';
                                                                                    } else if (_listOrderHistory[index].orderStatus == 'CANCEL') {
                                                                                      return 'images/ic_cancel.svg';
                                                                                    } else if (_listOrderHistory[index].orderStatus == 'COMPLETE') {
                                                                                      return 'images/ic_completed.svg';
                                                                                    }
                                                                                  }
                                                                                }()) ??
                                                                                '',
                                                                        colorFilter:
                                                                                (() {
                                                                              if (_listOrderHistory[index].orderStatus == 'PENDING') {
                                                                            return Constants
                                                                                .colorOrderPending.toColorFilter;
                                                                              } else if (_listOrderHistory[index].orderStatus == 'ACCEPT') {
                                                                            return Constants.colorBlack.toColorFilter;
                                                                              } else if (_listOrderHistory[index].orderStatus == 'PICKUP') {
                                                                            return Constants
                                                                                .colorOrderPickup.toColorFilter;
                                                                              }
                                                                            }()),
                                                                            width:
                                                                                15,
                                                                            height:
                                                                                ScreenUtil().setHeight(15),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      TextSpan(
                                                                          text:
                                                                              (() {
                                                                            if (_listOrderHistory[index].addressId !=
                                                                                null) {
                                                                              if (_listOrderHistory[index].orderStatus == 'PENDING') {
                                                                                return getTranslated(context, LangConst.labelOrderPending).toString();
                                                                              } else if (_listOrderHistory[index].orderStatus == 'APPROVE') {
                                                                                return getTranslated(context, LangConst.labelOrderAccepted).toString();
                                                                              } else if (_listOrderHistory[index].orderStatus == 'ACCEPT') {
                                                                                return getTranslated(context, LangConst.labelOrderAccepted).toString();
                                                                              } else if (_listOrderHistory[index].orderStatus == 'REJECT') {
                                                                                return getTranslated(context, LangConst.labelOrderRejected).toString();
                                                                              } else if (_listOrderHistory[index].orderStatus == 'PICKUP') {
                                                                                return getTranslated(context, LangConst.labelOrderPickedUp).toString();
                                                                              } else if (_listOrderHistory[index].orderStatus == 'DELIVERED') {
                                                                                return getTranslated(context, LangConst.labelDeliveredSuccess).toString();
                                                                              } else if (_listOrderHistory[index].orderStatus == 'CANCEL') {
                                                                                return getTranslated(context, LangConst.labelOrderCanceled).toString();
                                                                              } else if (_listOrderHistory[index].orderStatus == 'COMPLETE') {
                                                                                return getTranslated(context, LangConst.labelOrderCompleted).toString();
                                                                              }
                                                                            } else {
                                                                              if (_listOrderHistory[index].orderStatus == 'PENDING') {
                                                                                return getTranslated(context, LangConst.labelOrderPending).toString();
                                                                              } else if (_listOrderHistory[index].orderStatus == 'APPROVE') {
                                                                                return getTranslated(context, LangConst.labelOrderAccepted).toString();
                                                                              } else if (_listOrderHistory[index].orderStatus == 'ACCEPT') {
                                                                                return getTranslated(context, LangConst.labelOrderAccepted).toString();
                                                                              } else if (_listOrderHistory[index].orderStatus == 'PREPARE_FOR_ORDER') {
                                                                                return getTranslated(context, LangConst.labelPREPAREFORORDER).toString();
                                                                              } else if (_listOrderHistory[index].orderStatus == 'READY_FOR_ORDER') {
                                                                                return getTranslated(context, LangConst.labelREADYFORORDER).toString();
                                                                              } else if (_listOrderHistory[index].orderStatus == 'REJECT') {
                                                                                return getTranslated(context, LangConst.labelOrderRejected).toString();
                                                                              } else if (_listOrderHistory[index].orderStatus == 'COMPLETE') {
                                                                                return getTranslated(context, LangConst.labelOrderCompleted).toString();
                                                                              } else if (_listOrderHistory[index].orderStatus == 'CANCEL') {
                                                                                return getTranslated(context, LangConst.labelOrderCanceled).toString();
                                                                              }
                                                                            }
                                                                          }()),
                                                                          style: TextStyle(
                                                                              color: (() {
                                                                                if (_listOrderHistory[index].addressId != null) {
                                                                                  if (_listOrderHistory[index].orderStatus == 'PENDING') {
                                                                                    return Constants.colorOrderPending;
                                                                                  } else if (_listOrderHistory[index].orderStatus == 'APPROVE') {
                                                                                    return Constants.colorBlack;
                                                                                  } else if (_listOrderHistory[index].orderStatus == 'ACCEPT') {
                                                                                    return Constants.colorBlack;
                                                                                  } else if (_listOrderHistory[index].orderStatus == 'REJECT') {
                                                                                    return Constants.colorLike;
                                                                                  } else if (_listOrderHistory[index].orderStatus == 'PICKUP') {
                                                                                    return Constants.colorOrderPickup;
                                                                                  } else if (_listOrderHistory[index].orderStatus == 'DELIVERED') {
                                                                                    return Constants.colorTheme;
                                                                                  } else if (_listOrderHistory[index].orderStatus == 'CANCEL') {
                                                                                    return Constants.colorLike;
                                                                                  } else if (_listOrderHistory[index].orderStatus == 'COMPLETE') {
                                                                                    return Constants.colorTheme;
                                                                                  }
                                                                                } else {
                                                                                  if (_listOrderHistory[index].orderStatus == 'PENDING') {
                                                                                    return Constants.colorOrderPending;
                                                                                  } else if (_listOrderHistory[index].orderStatus == 'APPROVE') {
                                                                                    return Constants.colorBlack;
                                                                                  } else if (_listOrderHistory[index].orderStatus == 'ACCEPT') {
                                                                                    return Constants.colorBlack;
                                                                                  } else if (_listOrderHistory[index].orderStatus == 'REJECT') {
                                                                                    return Constants.colorLike;
                                                                                  } else if (_listOrderHistory[index].orderStatus == 'PREPARE_FOR_ORDER') {
                                                                                    return Constants.colorOrderPickup;
                                                                                  } else if (_listOrderHistory[index].orderStatus == 'READY_FOR_ORDER') {
                                                                                    return Constants.colorTheme;
                                                                                  } else if (_listOrderHistory[index].orderStatus == 'CANCEL') {
                                                                                    return Constants.colorLike;
                                                                                  } else if (_listOrderHistory[index].orderStatus == 'COMPLETE') {
                                                                                    return Constants.colorTheme;
                                                                                  }
                                                                                }
                                                                              }()),
                                                                              fontFamily: Constants.appFont,
                                                                              fontSize: 12)),
                                                                    ],
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5,
                                                          right: 5,
                                                          top: 20),
                                                  child: DottedLine(
                                                    dashColor:
                                                        Color(0xffcccccc),
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                        flex: 5,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .stretch,
                                                          children: [
                                                            ListView.builder(
                                                              physics:
                                                                  ClampingScrollPhysics(),
                                                              shrinkWrap: true,
                                                              scrollDirection:
                                                                  Axis.vertical,
                                                              itemCount:
                                                                  _listOrderHistory[
                                                                          index]
                                                                      .orderItems!
                                                                      .length,
                                                              itemBuilder: (BuildContext
                                                                          context,
                                                                      int innerindex) =>
                                                                  Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            20,
                                                                        top:
                                                                            20),
                                                                child: Column(
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Text(
                                                                          _listOrderHistory[index]
                                                                              .orderItems![innerindex]
                                                                              .itemName
                                                                              .toString(),
                                                                          style: TextStyle(
                                                                              fontFamily: Constants.appFont,
                                                                              fontSize: 12),
                                                                        ),
                                                                        Padding(
                                                                          padding:
                                                                              const EdgeInsets.only(left: 5),
                                                                          child: Text(
                                                                              (() {
                                                                                String qty = '';
                                                                                if (_listOrderHistory[index].orderItems!.length > 0 && _listOrderHistory[index].orderItems != null) {
                                                                                  qty = ' X ${_listOrderHistory[index].orderItems![innerindex].qty.toString()}';
                                                                                  return qty;
                                                                                } else {
                                                                                  return '';
                                                                                }
                                                                              }()),
                                                                              style: TextStyle(color: Constants.colorTheme, fontFamily: Constants.appFont, fontSize: 12)),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height:
                                                                  ScreenUtil()
                                                                      .setHeight(
                                                                          10),
                                                            ),
                                                            (() {
                                                              if (_listOrderHistory[
                                                                          index]
                                                                      .orderStatus ==
                                                                  'COMPLETE') {
                                                                return Container(
                                                                  height: ScreenUtil()
                                                                      .setHeight(
                                                                          40),
                                                                  child:
                                                                      ElevatedButton(
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      backgroundColor: Constants
                                                                              .colorWhite,
                                                                      shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.only(
                                                                              bottomLeft: Radius.circular(20),
                                                                              bottomRight: Radius.circular(20)),
                                                                          side: BorderSide.none),
                                                                    ),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(context).push(Transitions(
                                                                          transitionType: TransitionType.fade,
                                                                          curve: Curves.bounceInOut,
                                                                          reverseCurve: Curves.fastLinearToSlowEaseIn,
                                                                          widget: OrderReviewScreen(
                                                                            orderId:
                                                                                _listOrderHistory[index].id,
                                                                          )));
                                                                    },
                                                                    child:
                                                                        RichText(
                                                                      text:
                                                                          TextSpan(
                                                                        children: [
                                                                          WidgetSpan(
                                                                            child:
                                                                                Padding(
                                                                              padding: EdgeInsets.only(right: ScreenUtil().setHeight(10)),
                                                                              child: SvgPicture.asset(
                                                                                'images/ic_star.svg',
                                                                                width: ScreenUtil().setWidth(20),
                                                                            colorFilter:
                                                                                Constants.colorRate.toColorFilter,
                                                                                height: ScreenUtil().setHeight(20),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          TextSpan(
                                                                            text:
                                                                                (() {
                                                                              if (_listOrderHistory[index].orderStatus == 'CANCEL' || _listOrderHistory[index].orderStatus == 'COMPLETE') {
                                                                                return getTranslated(context, LangConst.labelRateNow).toString();
                                                                              } else {
                                                                                return '';
                                                                              }
                                                                            }()),
                                                                            style: TextStyle(
                                                                                color: Constants.colorRate,
                                                                                fontSize: 18,
                                                                                fontFamily: Constants.appFont),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              } else if (_listOrderHistory[
                                                                              index]
                                                                          .orderStatus ==
                                                                      'ACCEPT' ||
                                                                  _listOrderHistory[
                                                                              index]
                                                                          .orderStatus ==
                                                                      'PICKUP') {
                                                                return Container(
                                                                  height: ScreenUtil()
                                                                      .setHeight(
                                                                          40),
                                                                  child:
                                                                      ElevatedButton(
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      foregroundColor: Constants
                                                                              .colorWhite, backgroundColor: Color(
                                                                              0xff132229),
                                                                      shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.only(
                                                                              bottomLeft: Radius.circular(20),
                                                                              bottomRight: Radius.circular(20)),
                                                                          side: BorderSide.none),
                                                                    ),
                                                                    onPressed:
                                                                        () async {
                                                                      await getUserLocation();
                                                                      if (_currentLatitude !=
                                                                              null &&
                                                                          _currentLongitude !=
                                                                              null) {
                                                                        Navigator.of(context).push(Transitions(
                                                                            transitionType: TransitionType.fade,
                                                                            curve: Curves.bounceInOut,
                                                                            reverseCurve: Curves.fastLinearToSlowEaseIn,
                                                                            widget: TrackYourOrderScreen(
                                                                              vendorName: _listOrderHistory[index].deliveryPerson!.name,
                                                                              vendorNumber: _listOrderHistory[index].deliveryPerson!.contact,
                                                                              vendorImage: _listOrderHistory[index].deliveryPerson!.image,
                                                                              orderId: _listOrderHistory[index].id,
                                                                              orderTime: _listOrderHistory[index].time,
                                                                              orderDate: _listOrderHistory[index].date,
                                                                              shopLat: double.parse(_listOrderHistory[index].vendor!.lat.toString()),
                                                                              shopLong: double.parse(_listOrderHistory[index].vendor!.lang.toString()),
                                                                              currentLat: _currentLatitude,
                                                                              currentLong: _currentLongitude,
                                                                            )));
                                                                      } else {
                                                                        await getUserLocation();
                                                                      }
                                                                    },
                                                                    child: Text(
                                                                      (() {
                                                                        print(
                                                                            "my status ${_listOrderHistory[index].orderStatus} my index ${_listOrderHistory[index].vendor!.name} and id ");
                                                                        if (_listOrderHistory[index].orderStatus ==
                                                                            'PENDING') {
                                                                          return '';
                                                                        } else if (_listOrderHistory[index].orderStatus ==
                                                                            'ACCEPT') {
                                                                          return getTranslated(context, LangConst.labelTrackOrder).toString();
                                                                        } else if (_listOrderHistory[index].orderStatus ==
                                                                            'PICKUP') {
                                                                          return getTranslated(context, LangConst.labelTrackOrder).toString();
                                                                        } else if (_listOrderHistory[index].orderStatus ==
                                                                            'APPROVE') {
                                                                          return getTranslated(context, LangConst.labelTrackOrder).toString();
                                                                        } else {
                                                                          return '';
                                                                        }
                                                                      }()),
                                                                      style: TextStyle(
                                                                          color: Constants
                                                                              .colorWhite,
                                                                          fontSize:
                                                                              18,
                                                                          fontFamily:
                                                                              Constants.appFont),
                                                                    ),
                                                                  ),
                                                                );
                                                              } else {
                                                                return Container();
                                                              }
                                                            }()),
                                                          ],
                                                        )),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void callSetState() {
    setState(() {});
  }

  Future<BaseModel<OrderHistoryListModel>> callGetOrderHistoryList() async {
    OrderHistoryListModel response;
    try {
      _listOrderHistory.clear();
      _isSyncing = true;
      callSetState();
      response = await RestClient(RetroApi().dioData()).showOrder();
      print(response.success);
      _isSyncing = false;
      callSetState();
      if (response.success!) {
        _listOrderHistory.addAll(response.data!);
        callSetState();
      } else {
        Constants.toastMessage(getTranslated(context, LangConst.labelNoData).toString());
      }
    } catch (error, stacktrace) {
      _isSyncing = false;
      callSetState();
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<OrderStatus>> callGetOrderStatus() async {
    OrderStatus response;
    try {
      response = await RestClient(RetroApi().dioData()).userOrderStatus();
      print(response.success);

      if (response.success!) {
        if (response.data!.length > 0) {
          _listOrderStatus.clear();
          _listOrderStatus.addAll(response.data!);
          getOrderStatusText();
          callSetState();
        } else {
          if (timer.isActive) {
            timer.cancel();
          }
        }
      }
    } catch (error, stacktrace) {
      _isSyncing = false;
      callSetState();
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  void getOrderStatusText() {
    if (_listOrderStatus.length > 0) {
      int i = 0, j = 0;
      for (j = 0; j < _listOrderHistory.length; j++) {
        for (i = 0; i < _listOrderStatus.length; i++) {
          if (_listOrderHistory[j].id == _listOrderStatus[i].id) {
            _listOrderHistory[j].orderStatus = _listOrderStatus[i].orderStatus;
          }
        }
      }
      print("VALUE OF I : $i");
      print("VALUE OF I : $j");
      setState(() {});
    }
  }
}
