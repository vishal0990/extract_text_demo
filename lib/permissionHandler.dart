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


