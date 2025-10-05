import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/http_client.dart';
import '../../core/constants/app_constants.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/stats/data/datasources/stats_remote_datasource.dart';
import '../../features/stats/data/repositories/stats_repository_impl.dart';
import '../../features/stats/domain/repositories/stats_repository.dart';
import '../../features/stats/domain/usecases/get_current_month_stats_usecase.dart';
import '../../features/stats/presentation/bloc/stats_bloc.dart';

import '../../features/inventory/data/datasources/inventory_remote_datasource.dart';
import '../../features/inventory/data/repositories/inventory_repository_impl.dart';
import '../../features/inventory/domain/repositories/inventory_repository.dart';
import '../../features/inventory/domain/usecases/get_inventory_usecase.dart';
import '../../features/inventory/domain/usecases/get_inventory_stats_usecase.dart';
import '../../features/inventory/domain/usecases/get_product_by_id_usecase.dart';
import '../../features/inventory/domain/usecases/get_product_variants_usecase.dart';
import '../../features/inventory/domain/usecases/update_variant_stock_usecase.dart';
import '../../features/inventory/presentation/bloc/inventory_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<http.Client>(() => http.Client());

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl<SharedPreferences>()),
  );

  sl.registerLazySingleton<HttpClient>(
    () => HttpClient(
      client: sl<http.Client>(),
      authLocalDataSource: sl<AuthLocalDataSource>(),
    ),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      client: sl<HttpClient>(),
      baseUrl: AppConstants.fullApiUrl,
    ),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localDataSource: sl<AuthLocalDataSource>(),
    ),
  );

  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(sl<AuthRepository>()),
  );

  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUseCase: sl<LoginUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
      getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
    ),
  );

  sl.registerLazySingleton<StatsRemoteDataSource>(
    () => StatsRemoteDataSourceImpl(
      client: sl<HttpClient>(),
      baseUrl: AppConstants.fullApiUrl,
    ),
  );

  sl.registerLazySingleton<StatsRepository>(
    () => StatsRepositoryImpl(remoteDataSource: sl<StatsRemoteDataSource>()),
  );

  sl.registerLazySingleton<GetCurrentMonthStatsUseCase>(
    () => GetCurrentMonthStatsUseCase(sl<StatsRepository>()),
  );

  sl.registerFactory<StatsBloc>(
    () => StatsBloc(
      getCurrentMonthStatsUseCase: sl<GetCurrentMonthStatsUseCase>(),
    ),
  );

  sl.registerLazySingleton<InventoryRemoteDataSource>(
    () => InventoryRemoteDataSourceImpl(
      client: sl<HttpClient>(),
      baseUrl: AppConstants.fullApiUrl,
    ),
  );

  sl.registerLazySingleton<InventoryRepository>(
    () => InventoryRepositoryImpl(
      remoteDataSource: sl<InventoryRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<GetInventoryUseCase>(
    () => GetInventoryUseCase(sl<InventoryRepository>()),
  );
  sl.registerLazySingleton<GetInventoryStatsUseCase>(
    () => GetInventoryStatsUseCase(sl<InventoryRepository>()),
  );
  sl.registerLazySingleton<GetProductByIdUseCase>(
    () => GetProductByIdUseCase(sl<InventoryRepository>()),
  );
  sl.registerLazySingleton<GetProductVariantsUseCase>(
    () => GetProductVariantsUseCase(sl<InventoryRepository>()),
  );
  sl.registerLazySingleton<UpdateVariantStockUseCase>(
    () => UpdateVariantStockUseCase(sl<InventoryRepository>()),
  );

  sl.registerFactory<InventoryBloc>(
    () => InventoryBloc(
      getInventoryUseCase: sl<GetInventoryUseCase>(),
      getInventoryStatsUseCase: sl<GetInventoryStatsUseCase>(),
      getProductByIdUseCase: sl<GetProductByIdUseCase>(),
      getProductVariantsUseCase: sl<GetProductVariantsUseCase>(),
      updateVariantStockUseCase: sl<UpdateVariantStockUseCase>(),
    ),
  );
}
