import 'dart:convert';

import 'package:tezchal/helpers/constant.dart';
import 'package:http/http.dart' as http;
import 'package:tezchal/helpers/utils.dart';

netGet(
    {String endPoint = "",
    dynamic params = const {'row': "10", 'page': "1"},
    bool isUserToken = true}) async {
  String userToken = (isUserToken) ? userSession['access_token'] ?? "" : "";
  var url = Uri.parse(API_URL + endPoint);
  final newURI = url.replace(queryParameters: params);

  final response = await http.get(newURI, headers: {
    "Authorization": "Bearer $userToken",
    "Accept": "application/json",
    "content-type": "application/json",
    "Locale": "en",
  });
  print(response);
  
  redirectLogin(response);
  return {
    "resp_code": response.statusCode.toString(),
    "resp_data": jsonDecode(response.body)
  };
}

netPost({
  String endPoint = "",
  required Map<dynamic, dynamic> params,
  bool isUserToken = true,
}) async {
  String userToken = (isUserToken) ? userSession['access_token'] ?? "" : "";
  String userTokenType =
      (isUserToken) ? userSession['token_type'] ?? "Bearer" : "";
  var url = Uri.parse(API_URL + endPoint);
  final response = await http.post(url, body: json.encode(params), headers: {
    "Authorization": "$userTokenType $userToken",
    "Accept": "application/json",
    "content-type": "application/json",
    "Locale": "en"
  });
  redirectLogin(response);
  return {
    "resp_code": response.statusCode.toString(),
    "resp_data": jsonDecode(response.body)
  };
}

netPatch({
  String endPoint = "",
  required Map<dynamic, dynamic> params,
  bool isUserToken = true,
}) async {
  String userToken = (isUserToken) ? userSession['access_token'] ?? "" : "";
  String userTokenType = (isUserToken) ? userSession['token_type'] ?? "" : "";
  var url = Uri.parse(API_URL + endPoint);
  final response = await http.patch(url, body: json.encode(params), headers: {
    "Authorization": "$userTokenType $userToken",
    "Accept": "application/json",
    "content-type": "application/json",
    "Locale": "en"
  });
  redirectLogin(response);
  return {
    "resp_code": response.statusCode.toString(),
    "resp_data": jsonDecode(response.body)
  };
}

netPut({
  String endPoint = "",
  required Map<dynamic, dynamic> params,
  bool isUserToken = true,
}) async {
  String userToken = (isUserToken) ? userSession['access_token'] ?? "" : "";
  String userTokenType = (isUserToken) ? userSession['token_type'] ?? "" : "";
  var url = Uri.parse(API_URL + endPoint);
  final response = await http.put(url, body: json.encode(params), headers: {
    "Authorization": "$userTokenType $userToken",
    "Accept": "application/json",
    "content-type": "application/json",
    "Locale": "en"
  });
  redirectLogin(response);
  return {
    "resp_code": response.statusCode.toString(),
    "resp_data": jsonDecode(response.body)
  };
}

netDelete(
    {String endPoint = "",
    required Map<dynamic, dynamic> params,
    bool isUserToken = true}) async {
  String userToken = (isUserToken) ? userSession['access_token'] ?? "" : "";
  String userTokenType = (isUserToken) ? userSession['token_type'] ?? "" : "";
  var url = Uri.parse(API_URL + endPoint);
  final response = await http.delete(url, body: json.encode(params), headers: {
    "Authorization": "$userTokenType $userToken",
    "Accept": "application/json",
    "content-type": "application/json",
    "Locale": "en",
  });
  redirectLogin(response);
  return {
    "resp_code": response.statusCode.toString(),
    "resp_data": jsonDecode(response.body)
  };
}
