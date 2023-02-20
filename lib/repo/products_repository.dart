import 'dart:developer';

import 'package:mypagination/model/passenger_model.dart';
import 'package:mypagination/networking/api_base_helper.dart';

class PassgenerRepository {
  final ApiBaseHelper _helper = ApiBaseHelper();

  Future<PassengerModel?> fetchPassgenerList({
    int page = 0,
    int size = 10,
  }) async {
    final response = await _helper.get("passenger?page=$page&size=$size");
    final passengerModel = passengerModelFromJson(response.toString());
    log(passengerModelToJson(passengerModel));
    return passengerModel;
  }
}
