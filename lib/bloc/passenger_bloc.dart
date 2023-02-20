import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mypagination/model/passenger_model.dart';
import 'package:mypagination/networking/api_response.dart';
import 'package:mypagination/repo/products_repository.dart';

class PassengerBloc {
  late PassgenerRepository _passgenerRepository;

  late StreamController<ApiResponse<PassengerModel>> _passgenersListController;

  StreamSink<ApiResponse<PassengerModel>> get passgenersListSink =>
      _passgenersListController.sink;

  Stream<ApiResponse<PassengerModel>> get passgenersListStream =>
      _passgenersListController.stream;

  PassengerBloc() {
    _passgenersListController = StreamController<ApiResponse<PassengerModel>>();
    _passgenerRepository = PassgenerRepository();
    fetchpassgenerslist();
  }

  Future<List<Passenger>?> fetchpassgenerslist(
      {int page = 0, int size = 10}) async {
    passgenersListSink.add(ApiResponse.loading('Fetching passgeners'));
    try {
      PassengerModel? passgeners =
          await _passgenerRepository.fetchPassgenerList();

      passgenersListSink.add(ApiResponse.completed(passgeners));
      return passgeners?.data ?? [];
    } catch (e) {
      passgenersListSink.add(ApiResponse.error(e.toString()));
      debugPrint('$e');
      rethrow;
    }
  }

  dispose() {
    _passgenersListController.close();
  }
}
