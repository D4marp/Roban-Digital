import 'package:flutter/material.dart';
import 'package:robandigital/core/utils/service_locator.dart';
import 'package:robandigital/data/datasources/api/api_client.dart';
import '../../domain/usecases/get_channels_usecase.dart';
import '../../domain/usecases/get_channel_by_id_usecase.dart';
import '../../domain/entities/channel_entity.dart';

enum ChannelState { initial, loading, success, error }

class ChannelProvider extends ChangeNotifier {
  final GetChannelsUsecase _getChannelsUseCase;
  final GetChannelByIdUsecase _getChannelByIdUseCase;

  ChannelState _state = ChannelState.initial;
  List<ChannelEntity> _channels = [];
  ChannelEntity? _selectedChannel;
  String? _errorMessage;
  int _currentPage = 1;
  int _pageSize = 10;
  bool _hasMorePages = false;

  ChannelProvider({
    GetChannelsUsecase? getChannelsUseCase,
    GetChannelByIdUsecase? getChannelByIdUseCase,
  })  : _getChannelsUseCase =
            getChannelsUseCase ?? getIt<GetChannelsUsecase>(),
        _getChannelByIdUseCase =
            getChannelByIdUseCase ?? getIt<GetChannelByIdUsecase>();

  // Getters
  ChannelState get state => _state;
  List<ChannelEntity> get channels => _channels;
  ChannelEntity? get selectedChannel => _selectedChannel;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == ChannelState.loading;
  int get currentPage => _currentPage;
  bool get hasMorePages => _hasMorePages;

  /// Get channels with pagination and optional filters
  Future<void> getChannels({
    String? search,
    int? unitId,
    String? isActive,
    int page = 1,
    int pageSize = 10,
    bool append = false,
  }) async {
    if (_state == ChannelState.loading) return;

    // Ensure token is initialized before making request
    await getIt<ApiClient>().initializeAuthToken();

    _state = ChannelState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _getChannelsUseCase(
      search: search,
      unitId: unitId,
      isActive: isActive,
      page: page,
      limit: pageSize,
    );

    result.fold(
      (failure) {
        _state = ChannelState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (response) {
        if (append) {
          _channels.addAll(response.channels);
        } else {
          _channels = response.channels;
        }

        _currentPage = response.page;
        _pageSize = response.limit;
        _hasMorePages = response.hasMore;

        _state = ChannelState.success;
        notifyListeners();
      },
    );
  }

  /// Get channel by ID
  Future<void> getChannelById(int id) async {
    // Ensure token is initialized before making request
    await getIt<ApiClient>().initializeAuthToken();

    _state = ChannelState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _getChannelByIdUseCase(id);

    result.fold(
      (failure) {
        _state = ChannelState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (channel) {
        _selectedChannel = channel;
        _state = ChannelState.success;
        notifyListeners();
      },
    );
  }

  /// Load next page of channels
  Future<void> loadMoreChannels({
    String? search,
    int? unitId,
    String? isActive,
  }) async {
    if (!_hasMorePages || _state == ChannelState.loading) return;

    await getChannels(
      search: search,
      unitId: unitId,
      isActive: isActive,
      page: _currentPage + 1,
      pageSize: _pageSize,
      append: true,
    );
  }

  /// Refresh channels (reload first page)
  Future<void> refreshChannels({
    String? search,
    int? unitId,
    String? isActive,
  }) async {
    await getChannels(
      search: search,
      unitId: unitId,
      isActive: isActive,
      page: 1,
      pageSize: _pageSize,
    );
  }

  /// Reset provider state
  void reset() {
    _state = ChannelState.initial;
    _channels = [];
    _selectedChannel = null;
    _errorMessage = null;
    _currentPage = 1;
    notifyListeners();
  }
}
