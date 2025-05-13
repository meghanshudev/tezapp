import 'dart:convert';

import 'package:http/http.dart';

class HttpResponseUtil{

  static responseErrorMessage(Response response,
    {String defaultMsg = "Error", required Map<String, String> params}) {

    dynamic status = response.statusCode.toString();
    dynamic body = jsonDecode(response.body);
    switch (status) {
        case "403":
        case "400":
          var message = body["message"];
          return message;
        case "422":
          var message = body["errors"] ?? body["message"];
          String error =  message[params];
          String propertyErrorText = error.toString();
          return propertyErrorText;
        case "500":
          var message = body["message"];
          return message;
        default:
          return defaultMsg;
    }
  
  }

  static responseData(response, {
    required Map<String, String> params
  }){
    if(response.statusCode.toString() != "200"){
      String msg = responseErrorMessage(response, params: params);
      return {
        "resp_code" : response.statusCode.toString(),
        "resp_data" : msg
      };
    }
    return {
      "resp_code" : response.statusCode.toString(),
      "resp_data" : jsonDecode(response.body)
    };
  }

  static responseListData(response){
    return {
      "list" : response["resp_data"]["data"]["list"],
      "total" : response["resp_data"]["data"]["total"]
    };
  }
}