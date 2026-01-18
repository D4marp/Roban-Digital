import 'package:dartz/dartz.dart';
import 'package:robandigital/core/errors/failures.dart';
import 'package:robandigital/domain/entities/channel_entity.dart';
import 'package:robandigital/domain/repositories/channel_repository.dart';

class GetChannelByIdUsecase {
  final ChannelRepository repository;

  GetChannelByIdUsecase({required this.repository});

  Future<Either<Failure, ChannelEntity>> call(int id) {
    return repository.getChannelById(id);
  }
}
