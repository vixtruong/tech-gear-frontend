// import 'dart:io';
// import 'package:flutter/foundation.dart';

class Environment {
  static String get baseUrl {
    return "https://techgear-gateway.azurewebsites.net/";
    // if (kIsWeb) {
    //   return "https://localhost:5001";
    // } else if (Platform.isAndroid) {
    //   return "https://10.0.2.2:5001";
    // } else {
    //   return "https://localhost:5001";
    // }
  }

  static String get wsUrl {
    return "wss://techgear-gateway.azurewebsites.net/wss";
    // if (kIsWeb) {
    //   return "wss://localhost:5001/wss";
    // } else if (Platform.isAndroid) {
    //   return "wss://10.0.2.2:5001/wss";
    // } else {
    //   return "wss://localhost:5001/wss";
    // }
  }
}
