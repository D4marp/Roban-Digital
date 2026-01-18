import 'package:dartz/dartz.dart';
import 'package:robandigital/core/errors/failures.dart';
import 'package:robandigital/domain/entities/channel_entity.dart';

abstract class ChannelRepository {
  Future<Either<Failure, ChannelListResponse>> getChannels({
    String? search,
    int? unitId,
    String? isActive,
    int page = 1,
    int limit = 10,
  });

  Future<Either<Failure, ChannelEntity>> getChannelById(int id);
}
