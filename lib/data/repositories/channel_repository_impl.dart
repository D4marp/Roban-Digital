import 'package:dartz/dartz.dart';
import 'package:robandigital/core/errors/failures.dart';
import 'package:robandigital/data/datasources/remote/channel_remote_datasource.dart';
import 'package:robandigital/domain/entities/channel_entity.dart';
import 'package:robandigital/domain/repositories/channel_repository.dart';

class ChannelRepositoryImpl implements ChannelRepository {
  final ChannelRemoteDatasource channelRemoteDatasource;

  ChannelRepositoryImpl({required this.channelRemoteDatasource});

  @override
  Future<Either<Failure, ChannelListResponse>> getChannels({
    String? search,
    int? unitId,
    String? isActive,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await channelRemoteDatasource.getChannels(
        search: search,
        unitId: unitId,
        isActive: isActive,
        page: page,
        limit: limit,
      );

      final channels = response.data;
      final listResponse = ChannelListResponse(
        channels: channels,
        page: response.meta.page,
        limit: response.meta.limit,
        total: response.meta.total,
        totalPages: response.meta.totalPages,
        hasMore: response.meta.hasMore,
      );

      return Right(listResponse);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChannelEntity>> getChannelById(int id) async {
    try {
      final channelModel = await channelRemoteDatasource.getChannelById(id);
      return Right(channelModel);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
