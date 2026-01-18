import 'package:dartz/dartz.dart';
import 'package:robandigital/core/errors/failures.dart';
import 'package:robandigital/domain/entities/channel_entity.dart';
import 'package:robandigital/domain/repositories/channel_repository.dart';

class GetChannelsUsecase {
  final ChannelRepository repository;

  GetChannelsUsecase({required this.repository});

  Future<Either<Failure, ChannelListResponse>> call({
    String? search,
    int? unitId,
    String? isActive,
    int page = 1,
    int limit = 10,
  }) {
    return repository.getChannels(
      search: search,
      unitId: unitId,
      isActive: isActive,
      page: page,
      limit: limit,
    );
  }
}
