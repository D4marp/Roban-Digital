import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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

      if (kDebugMode) {
        print('[ChannelRemoteDatasource.getChannels] GET /channel');
        print('  - page: $page');
        print('  - limit: $limit');
        if (search != null) print('  - search: $search');
        if (unitId != null) print('  - unitId: $unitId');
        if (isActive != null) print('  - isActive: $isActive');
      }

      final response = await apiClient.get(
        '/channel',
        queryParameters: queryParameters,
      );

      if (kDebugMode) {
        print('[ChannelRemoteDatasource.getChannels] Response status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        return ChannelResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to load channels: status ${response.statusCode}');
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errorMessage = e.response?.data?['error'] ?? e.message ?? 'Unknown error';

      if (kDebugMode) {
        print('[ChannelRemoteDatasource.getChannels] DioException');
        print('  - statusCode: $statusCode');
        print('  - message: ${e.message}');
        print('  - error response: ${e.response?.data}');
      }

      if (statusCode == 403) {
        throw Exception('Anda tidak memiliki akses ke channel. Hubungi administrator.');
      } else if (statusCode == 401) {
        throw Exception('Sesi Anda telah berakhir. Silakan login kembali.');
      }

      throw Exception('Failed to load channels: $errorMessage');
    } catch (e) {
      if (kDebugMode) {
        print('[ChannelRemoteDatasource.getChannels] Exception: $e');
      }
      rethrow;
    }
  }

  @override
  Future<ChannelModel> getChannelById(int id) async {
    try {
      if (kDebugMode) {
        print('[ChannelRemoteDatasource.getChannelById] GET /channel/$id');
      }

      final response = await apiClient.get('/channel/$id');

      if (kDebugMode) {
        print('[ChannelRemoteDatasource.getChannelById] Response status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final channelData = data['data'] as Map<String, dynamic>;
        return ChannelModel.fromJson(channelData);
      } else {
        throw Exception('Failed to load channel: status ${response.statusCode}');
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errorMessage = e.response?.data?['error'] ?? e.message ?? 'Unknown error';

      if (kDebugMode) {
        print('[ChannelRemoteDatasource.getChannelById] DioException');
        print('  - statusCode: $statusCode');
        print('  - message: ${e.message}');
      }

      if (statusCode == 403) {
        throw Exception('Anda tidak memiliki akses ke channel ini.');
      } else if (statusCode == 401) {
        throw Exception('Sesi Anda telah berakhir. Silakan login kembali.');
      }

      throw Exception('Failed to load channel: $errorMessage');
    } catch (e) {
      if (kDebugMode) {
        print('[ChannelRemoteDatasource.getChannelById] Exception: $e');
      }
      rethrow;
    }
  }
}
