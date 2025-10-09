import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// 🔹 Core
import '../../core/network/http_client.dart';
import '../../core/constants/app_constants.dart';

// 🔹 Auth Feature
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// 🔹 Stats Feature
import '../../features/stats/data/datasources/stats_remote_datasource.dart';
import '../../features/stats/data/repositories/stats_repository_impl.dart';
import '../../features/stats/domain/repositories/stats_repository.dart';
import '../../features/stats/domain/usecases/get_current_month_stats_usecase.dart';
import '../../features/stats/presentation/bloc/stats_bloc.dart';

// 🔹 Inventory Feature
import '../../features/inventory/data/datasources/inventory_remote_datasource.dart';
import '../../features/inventory/data/repositories/inventory_repository_impl.dart';
import '../../features/inventory/domain/repositories/inventory_repository.dart';
import '../../features/inventory/domain/usecases/get_inventory_usecase.dart';
import '../../features/inventory/domain/usecases/get_inventory_stats_usecase.dart';
import '../../features/inventory/domain/usecases/get_product_by_id_usecase.dart';
import '../../features/inventory/domain/usecases/get_product_variants_usecase.dart';
import '../../features/inventory/domain/usecases/update_variant_stock_usecase.dart';
import '../../features/inventory/presentation/bloc/inventory_bloc.dart';

// 🔹 Orders Feature
import '../../features/orders/data/datasources/orders_remote_datasource.dart';
import '../../features/orders/data/repositories/orders_repository_impl.dart';
import '../../features/orders/domain/repositories/orders_repository.dart';
import '../../features/orders/domain/usecases/get_order_detail_usecase.dart';
import '../../features/orders/domain/usecases/get_orders_metrics_usecase.dart';
import '../../features/orders/domain/usecases/get_orders_usecase.dart';
import '../../features/orders/domain/usecases/take_order_usecase.dart';
import '../../features/orders/domain/usecases/update_order_status_usecase.dart';
import '../../features/orders/domain/usecases/get_assigned_orders_usecase.dart'; // ✅ Nuevo
import '../../features/orders/presentation/bloc/orders_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // =========================================================
  // 🧩 CORE DEPENDENCIES
  // =========================================================
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<http.Client>(() => http.Client());

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  sl.registerLazySingleton<HttpClient>(
    () => HttpClient(client: sl(), authLocalDataSource: sl()),
  );

  // =========================================================
  // 🔐 AUTH FEATURE
  // =========================================================
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      client: sl(),
      baseUrl: AppConstants.fullApiUrl,
    ),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
    ),
  );

  // =========================================================
  // 📊 STATS FEATURE
  // =========================================================
  sl.registerLazySingleton<StatsRemoteDataSource>(
    () => StatsRemoteDataSourceImpl(
      client: sl(),
      baseUrl: AppConstants.fullApiUrl,
    ),
  );

  sl.registerLazySingleton<StatsRepository>(
    () => StatsRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton(() => GetCurrentMonthStatsUseCase(sl()));

  sl.registerFactory(() => StatsBloc(getCurrentMonthStatsUseCase: sl()));

  // =========================================================
  // 📦 INVENTORY FEATURE
  // =========================================================
  sl.registerLazySingleton<InventoryRemoteDataSource>(
    () => InventoryRemoteDataSourceImpl(
      client: sl(),
      baseUrl: AppConstants.fullApiUrl,
    ),
  );

  sl.registerLazySingleton<InventoryRepository>(
    () => InventoryRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton(() => GetInventoryUseCase(sl()));
  sl.registerLazySingleton(() => GetInventoryStatsUseCase(sl()));
  sl.registerLazySingleton(() => GetProductByIdUseCase(sl()));
  sl.registerLazySingleton(() => GetProductVariantsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateVariantStockUseCase(sl()));

  sl.registerFactory(
    () => InventoryBloc(
      getInventoryUseCase: sl(),
      getInventoryStatsUseCase: sl(),
      getProductByIdUseCase: sl(),
      getProductVariantsUseCase: sl(),
      updateVariantStockUseCase: sl(),
    ),
  );

  // =========================================================
  // 🧾 ORDERS FEATURE
  // =========================================================
  sl.registerLazySingleton<OrdersRemoteDataSource>(
    () =>
        OrdersRemoteDataSource(client: sl(), baseUrl: AppConstants.fullApiUrl),
  );

  sl.registerLazySingleton<OrdersRepository>(
    () => OrdersRepositoryImpl(remoteDataSource: sl()),
  );

  // ✅ Casos de uso
  sl.registerLazySingleton(() => GetOrdersUseCase(sl()));
  sl.registerLazySingleton(() => GetOrderDetailUseCase(sl()));
  sl.registerLazySingleton(() => TakeOrderUseCase(sl()));
  sl.registerLazySingleton(() => UpdateOrderStatusUseCase(sl()));
  sl.registerLazySingleton(() => GetOrdersMetricsUseCase(sl()));
  sl.registerLazySingleton(() => GetAssignedOrdersUseCase(sl())); // ✅ NUEVO

  // ✅ Bloc de pedidos
  sl.registerFactory(
    () => OrdersBloc(
      getOrders: sl(),
      getOrderDetail: sl(),
      takeOrder: sl(),
      updateStatus: sl(),
      getMetrics: sl(),
      getAssignedOrders: sl(), // ✅ NUEVO
    ),
  );
}
