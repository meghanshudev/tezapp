import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tez_mobile/helpers/constant.dart';
import 'package:tez_mobile/helpers/response.dart';
import 'package:tez_mobile/helpers/utils.dart';

class NetworkV2{

  String endPoint;
  bool isUserToken;
  dynamic params;

  static String encryptAccess = "";
  static Map<String,String>? headers;
  static Uri? url;

  NetworkV2({
    this.endPoint = "",
    this.isUserToken = true,
    this.params = const {"page" : "1"},
  }){

    String userToken = (isUserToken) ? userSession['access_token'] : "";
    String userTokenType = (isUserToken) ? userSession['token_type'] : "";
    headers = {
      "Authorization": "$userTokenType $userToken",
      "Accept": "application/json",
      "content-type": "application/json",
    };
    url = Uri.parse(API_URL + endPoint);
    
  }


  Future get() async {  

    final newURI = url!.replace(queryParameters: params);
    var response = await http.get(newURI, headers: headers);
    redirectLogin(response);
    return HttpResponseUtil.responseData(response, params: params);
  }

  Future post() async {  
    var response = await http.post(
      url!,
      body: json.encode(params),
      headers: headers);
    redirectLogin(response);
    return HttpResponseUtil.responseData(response, params: params);
  }

  Future put() async {  
    var response = await http.put(
      url!,
      body: json.encode(params),
      headers: headers);
    redirectLogin(response);
    return HttpResponseUtil.responseData(response, params: params);
  }

  Future delete() async {  
    var response = await http.delete(
      url!,
      body: json.encode(params),
      headers: headers);
      redirectLogin(response);
    return HttpResponseUtil.responseData(response, params: params);
  }



}