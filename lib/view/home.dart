import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mypagination/bloc/passenger_bloc.dart';
import 'package:mypagination/model/passenger_model.dart';
import 'package:mypagination/repo/products_repository.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const _pageSize = 20;
  static const _firstPage = 0;
  late PassengerBloc _bloc;
  late ScrollController _scrollController;
  final PagingController<int, Passenger> pagingController =
      PagingController(firstPageKey: _firstPage);
  @override
  void initState() {
    pagingController.addPageRequestListener((pageKey) {
      _fetchPage(
        pageKey,
      );
    });
    super.initState();

    _bloc = PassengerBloc();
    _scrollController = ScrollController();
  }

  int totalPageLength() => pagingController.itemList?.length ?? 0;

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await PassgenerRepository().fetchPassgenerList(
        page: pageKey,
        size: _pageSize,
      );
      if (newItems == null) {
        pagingController.error = 'error';
        return;
      }

      final totalPassengers = newItems.totalPassengers;

      final isLastPage = totalPageLength() >= totalPassengers;
      log('A: ${totalPageLength()} | $totalPassengers | $isLastPage ',
          name: 'isLastPage');
      if (isLastPage) {
        pagingController.appendLastPage(newItems.data);
      } else {
        final nextPageKey =
            (pageKey + newItems.data.length / _pageSize).round();
        pagingController.appendPage(newItems.data, nextPageKey);
      }
      log('B: ${totalPageLength()} | $totalPassengers | $isLastPage ',
          name: 'isLastPage');
    } catch (error) {
      pagingController.error = error;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bloc.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagination Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => pagingController.refresh(),
          ),
          IconButton(
              icon: const Icon(Icons.arrow_circle_down_sharp),
              onPressed: () {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                );
              }),
          IconButton(
              icon: const Icon(Icons.arrow_circle_up_sharp),
              onPressed: () {
                _scrollController.animateTo(
                  _scrollController.position.minScrollExtent,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                );
              }),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 20,
            ),
            child: AnimatedBuilder(
                animation: pagingController,
                builder: (context, _) {
                  return Text(
                    'Current Passengers Loaded ${totalPageLength()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }),
          ),
        ),
      ),
      body: Center(
        child: ProductsList(
          pagingController: pagingController,
          scrollController: _scrollController,
          // StreamBuilder<ApiResponse<PassengerModel>>(
          //   stream: _bloc.passgenersListStream,
          //   builder: (context, snapshot) {
          //     if (snapshot.hasData) {
          //       switch (snapshot.data?.status) {
          //         case null:
          //           return Loading(loadingMessage: snapshot.data?.message);
          //         case Status.loading:
          //           return Loading(loadingMessage: snapshot.data?.message);

          //         case Status.completed:
          //           return ProductsList(
          //             productsList: snapshot.data?.data,
          //             pagingController: pagingController,
          //           );

          //         case Status.error:
          //           return Error(
          //             errorMessage: snapshot.data?.message,
          //             onRetryPressed: () => _bloc.fetchpassgenerslist(),
          //           );
          //       }
          //     }
          //     return Container();
          //   },
        ),
      ),
    );
  }
}

class ProductsList extends StatelessWidget {
  const ProductsList({
    Key? key,
    required this.pagingController,
    required this.scrollController,
  }) : super(key: key);

  final PagingController<int, Passenger> pagingController;
  final ScrollController scrollController;
  @override
  Widget build(BuildContext context) {
    return PagedListView<int, Passenger>(
      pagingController: pagingController,
      scrollController: scrollController,
      builderDelegate: PagedChildBuilderDelegate<Passenger>(
        itemBuilder: (context, item, index) {
          return ListTile(
            title: Text(
              item.name,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            leading: item.airline.isEmpty
                ? null
                : Image.network(
                    item.airline.first.logo,
                    height: 50,
                    width: 50,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error);
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const CircularProgressIndicator();
                    },
                  ),
            trailing: Text("${index + 1}"),
            subtitle: item.airline.isEmpty
                ? null
                : Text(
                    item.airline.first.slogan,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
          );
        },
      ),
    );
  }
}

class Loading extends StatelessWidget {
  const Loading({
    Key? key,
    required this.loadingMessage,
  }) : super(key: key);

  final String? loadingMessage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          Text(loadingMessage ?? ''),
        ],
      ),
    );
  }
}

class Error extends StatelessWidget {
  const Error({
    Key? key,
    required this.errorMessage,
    required this.onRetryPressed,
  }) : super(key: key);

  final String? errorMessage;
  final VoidCallback onRetryPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(errorMessage ?? ''),
          ElevatedButton(
            onPressed: onRetryPressed,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
