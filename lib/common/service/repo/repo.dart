

import 'package:ecom_task/common/service/api_client/api_client.dart';

class Repo {
  Future<dynamic> getProduct() async {
    dynamic response;
    response = await ApiClient().openGet('products');
    return ApiClient().getResponse(response);
  }
}
