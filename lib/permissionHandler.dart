import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:location/location.dart' as location;
import 'package:permission_handler/permission_handler.dart' as permission;

Future<bool> serviceEnabled() async {
  bool locationService = await location.Location().serviceEnabled();
  if (!locationService) {
    locationService = await location.Location().requestService();
    if (locationService) {
      return true;
    } else {
      return false;
    }
  } else {
    return true;
  }
}

Future<bool> locationPermission({bool isPopUpShow = true}) async {
  var status = await location.Location().hasPermission();
  if (status == location.PermissionStatus.denied) {
    status = await location.Location().requestPermission();
    if (status == location.PermissionStatus.granted) {
      return true;
    }
  } else if (status == location.PermissionStatus.granted) {
    return true;
  }

  return false;
}

Future<bool> storagePermission() async {
  DeviceInfoPlugin plugin = DeviceInfoPlugin();
  AndroidDeviceInfo? androidInfo;
  permission.PermissionStatus status = permission.PermissionStatus.denied;

  if (Platform.isAndroid) {
    androidInfo = await plugin.androidInfo;
  }

  if ((androidInfo != null && androidInfo.version.sdkInt < 35) ||
      Platform.isIOS) {
    status = await permission.Permission.storage.status;
  } else {
    status = await permission.Permission.photos.status;
  }

  if (status == permission.PermissionStatus.denied) {
    if ((androidInfo != null && androidInfo.version.sdkInt < 35) ||
        Platform.isIOS) {
      status = await permission.Permission.storage.request();
    } else {
      status = await permission.Permission.photos.request();
    }
    if (status.isGranted) {
      return true;
    }
  } else if (status == permission.PermissionStatus.granted) {
    return true;
  } else if (status == permission.PermissionStatus.limited) {
    return true;
  }

  return false;
}

Future<bool> cameraPermission() async {
  var status = await permission.Permission.camera.status;

  if (status == permission.PermissionStatus.denied) {
    var requestValue = await permission.Permission.camera.request();
    if (requestValue.isGranted) {
      return true;
    }
  } else if (status == permission.PermissionStatus.granted) {
    return true;
  }
  return false;
}

/*void showServiceDialog(String errorMessage) {
  Get.dialog(Dialog(
    elevation: 5.0,
    child: PopScope(
        canPop: true,
        onPopInvoked: (_) {
          return;
        },
        child: serviceDisabled(errorMessage)),
  ));
}

Widget serviceDisabled(String errorMessage) {
  return Stack(
    children: [
      Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            Assets.images.location.path,
            height: GResponsive().w * 0.65,
            width: Dimensions.d4x40,
            package: initialValue.package,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.d2x10),
            child: Text(
              errorMessage,
              style: GTextStyle.text14,
            ),
          ),
          ButtonWidget(
              buttonText: "Open setting",
              onTap: () {
                Get.back();
                permission.openAppSettings();
              },
              rightSpacing: Dimensions.d2x10,
              leftSpacing: Dimensions.d2x10,
              topSpacing: Dimensions.d2x10,
              bottomSpacing: Dimensions.d2x10),
        ],
      ),
      Positioned(
        right: Dimensions.d2x5,
        top: 0,
        child: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.clear),
          color: Colors.grey,
        ),
      )
    ],
  );
}*/
