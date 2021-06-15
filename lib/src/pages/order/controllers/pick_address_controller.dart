import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:van_transport/src/routes/app_pages.dart';
import 'package:van_transport/src/services/distance_service.dart';
import 'package:van_transport/src/services/user_service.dart';
import 'package:van_transport/src/widgets/snackbar.dart';
import 'dart:convert' as convert;

class PickAddressController extends GetxController {
  StreamController<dynamic> listTransport =
      StreamController<dynamic>.broadcast();
  TextEditingController addressController = TextEditingController();
  final DistanceService distanceService = DistanceService();
  final userService = UserService();
  String placeTo, placeFrom;
  LatLng locationTo, locationFrom;
  String distance;
  String idAddressFrom, idAddressTo;
  String phone;
  InfoReceiver infoReceiver = InfoReceiver(
    fullName: '',
    phone: '',
    title: '',
    description: '',
    address: '',
  );
  var senderInfo, recipientInfo, transportInfo;

  initData() {
    placeTo = '';
    placeFrom = '';
    update();
  }

  initialFormInput() {
    addressController.text = placeTo ?? '';
  }

  disposeFormInput() {
    locationTo = null;
    phone = null;
    placeTo = null;
    idAddressTo = null;
    infoReceiver = InfoReceiver(
      fullName: '',
      phone: '',
      title: '',
      description: '',
      address: '',
    );
  }

  pickAddress(lat, lng, fullAddress, idAddress, phoneNumber) {
    locationTo = LatLng(
      lat,
      lng,
    );
    phone = phoneNumber;
    placeTo = fullAddress;
    this.idAddressTo = idAddress;
    addressController.text = placeTo;
    update();
  }

  pickFromAddress(lat, lng, fullAddress, idAddress) {
    locationFrom = LatLng(
      lat,
      lng,
    );
    placeFrom = fullAddress;
    this.idAddressFrom = idAddress;
    update();
  }

  saveInfoReceiver(fullName, phone, title, description) {
    infoReceiver = InfoReceiver(
      fullName: fullName,
      phone: phone,
      title: title,
      description: description,
      address: placeTo,
    );
    update();
    Get.back();
  }

  calDistance() async {
    var res = await distanceService.calculateDistance(
      locationFrom.latitude,
      locationFrom.longitude,
      locationTo.latitude,
      locationTo.longitude,
    );
    distance = res['rows'][0]['elements'][0]['distance']['text'];
    update();
  }

  getListTransport(idMerchant) async {
    var res = await userService.getTransportDelivery(idAddressFrom, idMerchant);
    listTransport.add(res);
  }

  getListTransportForClientCart() async {
    var res = await userService.getTransportDeliveryClient(
      idAddressFrom,
      locationFrom.latitude,
      locationFrom.longitude,
    );
    listTransport.add(res);
  }

  pickDelivery(sender, recipient, transportInfo) {
    this.transportInfo = transportInfo;
    senderInfo = sender;
    recipientInfo = recipient;
    update();
  }

  paymentCartMerchant(price, paymentMethod, context) async {
    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        },
        barrierColor: Color(0x80000000),
        barrierDismissible: false);
    var body = {
      "title": "Đơn hàng Van Transport",
      "description": "Đơn hàng mới",
      "recipientAddress": recipientInfo['fullAddress'],
      "recipientLat": recipientInfo['coordinates']['lat'],
      "recipientLng": recipientInfo['coordinates']['lng'],
      "recipientPhone": recipientInfo['phoneNumber'],
      "senderName": senderInfo['name'],
      "senderPhone": senderInfo['address']['phoneNumber'],
      "senderAddress": senderInfo['address']['fullAddress'],
      "senderLat": senderInfo['address']['coordinates']['lat'],
      "senderLng": senderInfo['address']['coordinates']['lng'],
      "FK_Transport": transportInfo['FK_Transport']['_id'],
      "FK_SubTransport": transportInfo['start']['_id'],
      "FK_SubTransportAwait": transportInfo['end']['_id'],
      "distance": transportInfo['distance'],
      "prices": (int.parse(price.toString().replaceAll(',', '')) +
              double.tryParse(transportInfo['price']).round() +
              200)
          .toString(),
      "weight": "0",
      "estimatedDate": "1622221281950",
      "typePayment": paymentMethod.toString().toUpperCase(),
    };
    var response = await userService.paymentCartMerchant(body);
    var res = convert.jsonDecode(response.body);
    print(senderInfo['name']);
    print(res);
    Get.back();
    if (response.statusCode == 200) {
      if (paymentMethod == 'POINT') {
        transportInfo = null;
        senderInfo = null;
        recipientInfo = null;
        idAddressFrom = null;
        Get.offAndToNamed(Routes.ROOT);
        GetSnackBar getSnackBar = GetSnackBar(
          title: 'Mua hàng thành công!',
          subTitle: 'Kiểm tra lại đơn hàng nhé.',
        );
        getSnackBar.show();
      } else {
        String url = res['data'];
        update();
        if (url != null) {
          Get.toNamed(Routes.PAYMENTWEBVIEW, arguments: url);
        } else {
          GetSnackBar getSnackBar = GetSnackBar(
            title: 'Mua hàng thất bại!',
            subTitle: 'Máy chủ đang quá tải.',
          );
          getSnackBar.show();
        }
      }
    } else {
      GetSnackBar getSnackBar = GetSnackBar(
        title: 'Mua hàng thất bại!',
        subTitle: 'Máy chủ đang quá tải.',
      );
      getSnackBar.show();
    }
  }

  paymentCartClient(weight, paymentMethod, context) async {
    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        },
        barrierColor: Color(0x80000000),
        barrierDismissible: false);
    var body = {
      "title": infoReceiver.title,
      "description": infoReceiver.description,
      "recipientName": infoReceiver.fullName,
      "recipientAddress": placeTo,
      "recipientLat": locationTo.latitude.toString(),
      "recipientLng": locationFrom.longitude.toString(),
      "recipientPhone": infoReceiver.phone,
      "senderPhone": phone,
      "senderAddress": placeTo,
      "senderLat": locationTo.latitude.toString(),
      "senderLng": locationTo.longitude.toString(),
      "estimatedDate": "1622221281950",
      "FK_Transport": transportInfo['FK_Transport']['_id'],
      "FK_SubTransport": transportInfo['start']['_id'],
      "FK_SubTransportAwait": transportInfo['end']['_id'],
      "distance": transportInfo['distance'],
      "prices":
          (double.tryParse(transportInfo['price']).round() + 200).toString(),
      "weight": weight,
      "typePayment": paymentMethod.toString().toUpperCase(),
    };
    var response = await userService.paymentCartClient(body);
    var res = convert.jsonDecode(response.body);
    print(res);
    Get.back();
    if (response.statusCode == 200) {
      disposeFormInput();
      if (paymentMethod == 'POINT') {
        transportInfo = null;
        senderInfo = null;
        recipientInfo = null;
        idAddressFrom = null;
        Get.offAndToNamed(Routes.ROOT);
        GetSnackBar getSnackBar = GetSnackBar(
          title: 'Mua hàng thành công!',
          subTitle: 'Kiểm tra lại đơn hàng nhé.',
        );
        getSnackBar.show();
      } else {
        String url = res['data'];
        if (url != null) {
          Get.toNamed(Routes.PAYMENTWEBVIEW, arguments: url);
        } else {
          GetSnackBar getSnackBar = GetSnackBar(
            title: 'Mua hàng thất bại!',
            subTitle: 'Máy chủ đang quá tải.',
          );
          getSnackBar.show();
        }
      }
    } else {
      GetSnackBar getSnackBar = GetSnackBar(
        title: 'Mua hàng thất bại!',
        subTitle: 'Máy chủ đang quá tải.',
      );
      getSnackBar.show();
    }
  }

  Stream<dynamic> get getListTransportController => listTransport.stream;
}

class InfoReceiver {
  final String fullName;
  final String phone;
  final String address;
  final String title;
  final String description;

  InfoReceiver({
    this.address,
    this.description,
    this.fullName,
    this.phone,
    this.title,
  });
}
