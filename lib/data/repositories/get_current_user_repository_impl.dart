import 'package:dartz/dartz.dart';
import 'package:robandigital/core/errors/failures.dart';
import 'package:robandigital/data/datasources/remote/auth_remote_datasource.dart';
import 'package:robandigital/domain/entities/auth_entity.dart';
import 'package:robandigital/domain/repositories/get_current_user_repository.dart';

class GetCurrentUserRepositoryImpl implements GetCurrentUserRepository {
  final AuthRemoteDataSource remoteDataSource;

  GetCurrentUserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      return Right(
        UserEntity(
          id: userModel.id,
          email: userModel.email,
          username: userModel.username,
          role: userModel.role,
          unitId: userModel.unitId,
          createdAt: userModel.createdAt,
        ),
      );
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on ForbiddenException catch (e) {
      return Left(ForbiddenFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(
        UnknownFailure(message: e.toString()),
      );
    }
  }
}
