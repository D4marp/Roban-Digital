import 'package:dio/dio.dart';
import 'package:robandigital/data/datasources/api/api_client.dart';
import 'package:robandigital/data/models/channel_model.dart';

abstract class ChannelRemoteDatasource {
  Future<ChannelResponse> getChannels({
    String? search,
    int? unitId,
    String? isActive,
    int page = 1,
    int limit = 10,
  });

  Future<ChannelModel> getChannelById(int id);
}

class ChannelRemoteDatasourceImpl implements ChannelRemoteDatasource {
  final ApiClient apiClient;

  ChannelRemoteDatasourceImpl({required this.apiClient});

  @override
  Future<ChannelResponse> getChannels({
    String? search,
    int? unitId,
    String? isActive,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }

      if (unitId != null) {
        queryParameters['unitId'] = unitId;
      }

      if (isActive != null && isActive.isNotEmpty) {
        queryParameters['isActive'] = isActive;
      }

      final response = await apiClient.get(
        '/channel',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        return ChannelResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to load channels');
      }
    } on DioException catch (e) {
      throw Exception('Failed to load channels: ${e.message}');
    }
  }

  @override
  Future<ChannelModel> getChannelById(int id) async {
    try {
      final response = await apiClient.get('/channel/$id');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final channelData = data['data'] as Map<String, dynamic>;
        return ChannelModel.fromJson(channelData);
      } else {
        throw Exception('Failed to load channel');
      }
    } on DioException catch (e) {
      throw Exception('Failed to load channel: ${e.message}');
    }
  }
}
