import 'dart:convert';
import 'dart:io';
import 'package:ecom_task/service/local_storage/shared_preference.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Map<String, String> defaultHeader = {
    "Content-Type": "application/json",
    "Accept": "application/json"
  };
  String baseUrl = "https://fakestoreapi.com/";

  bool debug = false;

  Future<String> getToken() async {
    await SharedPreferencesHelper().init();
    final bool status = SharedPreferencesHelper().getBool("isLoggedIn") ?? false;
    final String token = SharedPreferencesHelper().getString("token") ?? "";
    print(token);
    if (status && token.isNotEmpty) {
      return token;
    }
    return "";
  }



  Future<dynamic> openGet(String url) async {
    dynamic response;

    if (debug) {
      print("===========OPEN GET hit =============");
    }
    response =
    await http.get(Uri.parse('$baseUrl/$url'), headers: defaultHeader);
    if (debug) {
      print("header --> $defaultHeader");
      print("url --> ${Uri.parse('$baseUrl/$url')}");
      print("response --> $response");
      print("response body --> ${response.body}");
      print("=========== end OPEN GET hit =============");
    }
    return response;
  }

  dynamic getResponse(dynamic response) {
    dynamic responseJson;
    bool unauthenticated = false;
    if (debug) {
      print("=========== response =============");
    }
    if (response != null) {
      if (response.statusCode == 200) {
        responseJson = json.decode(response.body);
      } else if (response.statusCode == 422) {
        var responseDecoded = json.decode(response.body);
        if (responseDecoded.containsKey("errors")) {
          List keyList = responseDecoded['errors'].keys.toList();
          String message = "";
          keyList.asMap().forEach((i, value) {
            message += "${responseDecoded['errors']["$value"][0]}\n";
          });
          responseJson = {
            "status": 0,
            "message": message.trim(),
          };
        }
      } else if (response.statusCode == 401) {
        unauthenticated = true;
      } else {
        unauthenticated = true;
      }
      if (debug) {
        print("Response ? --> YES !");
        print("code --> ${response.statusCode}");
        print("body --> ${response.body}");
      }
    } else {
      if (debug) {
        print("Response ? --> No Null given");
      }
      unauthenticated = true;
    }
    if (unauthenticated) {
      responseJson = {
        "status": 2,
        "message": "Unauthenticated",
      };
    }
    if (debug) {
      print("responseJson --> $responseJson");
      print("=========== end response =============");
    }
    return responseJson;
  }
}
