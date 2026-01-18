import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:robandigital/data/datasources/api/api_client.dart';
import 'package:robandigital/data/datasources/remote/login_remote_datasource.dart';
import 'package:robandigital/data/datasources/remote/channel_remote_datasource.dart';
import 'package:robandigital/data/datasources/local/auth_local_datasource.dart';
import 'package:robandigital/data/repositories/auth_repository_impl.dart';
import 'package:robandigital/data/repositories/channel_repository_impl.dart';
import 'package:robandigital/domain/usecases/login_usecase.dart';
import 'package:robandigital/domain/usecases/get_channels_usecase.dart';
import 'package:robandigital/domain/usecases/get_channel_by_id_usecase.dart';
import 'package:robandigital/presentation/providers/login_provider.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/channel_repository.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // External Dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // API Client
  getIt.registerSingleton<ApiClient>(
    ApiClient(),
  );

  // Data Sources
  getIt.registerSingleton<AuthLocalDataSource>(
    AuthLocalDataSource(prefs: getIt<SharedPreferences>()),
  );

  getIt.registerSingleton<LoginRemoteDataSource>(
    LoginRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );

  // Repositories
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(
      remoteDataSource: getIt<LoginRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
      apiClient: getIt<ApiClient>(),
    ),
  );

  // Use Cases
  getIt.registerSingleton<LoginUseCase>(
    LoginUseCase(repository: getIt<AuthRepository>()),
  );

  // Channel Remote Data Source
  getIt.registerSingleton<ChannelRemoteDatasource>(
    ChannelRemoteDatasourceImpl(apiClient: getIt<ApiClient>()),
  );

  // Channel Repository
  getIt.registerSingleton<ChannelRepository>(
    ChannelRepositoryImpl(channelRemoteDatasource: getIt<ChannelRemoteDatasource>()),
  );

  // Channel Use Cases
  getIt.registerSingleton<GetChannelsUsecase>(
    GetChannelsUsecase(repository: getIt<ChannelRepository>()),
  );

  getIt.registerSingleton<GetChannelByIdUsecase>(
    GetChannelByIdUsecase(repository: getIt<ChannelRepository>()),
  );

  // Providers
  getIt.registerSingleton<LoginProvider>(
    LoginProvider(loginUseCase: getIt<LoginUseCase>()),
  );
}
