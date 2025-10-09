import 'package:dartz/dartz.dart';
import 'package:stock_control_app/features/stats/domain/entities/orders_page_entity.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/order_detail_entity.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_remote_datasource.dart';
import '../models/order_model.dart';
import '../models/order_detail_model.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource remoteDataSource;

  OrdersRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, OrdersPageEntity>> getOrders(
    String? search,
    int page, [
    String? status,
  ]) async {
    try {
      final response = await remoteDataSource.getOrders(
        search: search,
        page: page,
        status: status,
      );

      if (!response.containsKey('data')) {
        throw ServerException('Respuesta inesperada del servidor.');
      }

      final orders = (response['data'] as List)
          .map((o) => OrderModel.fromJson(o))
          .toList();

      final totalPages = (response['totalPages'] ?? 1) as int;
      final currentPage = (response['page'] ?? 1) as int;

      return Right(
        OrdersPageEntity(
          orders: orders,
          totalPages: totalPages,
          currentPage: currentPage,
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure('Error del servidor: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, OrdersPageEntity>> getAssignedOrders(
    int employeeId, [
    String? status,
    String? search,
    int page = 1,
  ]) async {
    try {
      final response = await remoteDataSource.getAssignedOrders(
        employeeId,
        status: status,
        search: search,
        page: page,
      );

      if (!response.containsKey('data')) {
        throw ServerException('Respuesta inesperada del servidor.');
      }

      final orders = (response['data'] as List)
          .map((o) => OrderModel.fromJson(o))
          .toList();

      final totalPages = (response['totalPages'] ?? 1) as int;
      final currentPage = (response['page'] ?? 1) as int;

      return Right(
        OrdersPageEntity(
          orders: orders,
          totalPages: totalPages,
          currentPage: currentPage,
        ),
      );
    } on ServerException catch (e) {
      return Left(
        ServerFailure('Error obteniendo pedidos asignados: ${e.message}'),
      );
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, OrderDetailEntity>> getOrderDetail(String id) async {
    try {
      final data = await remoteDataSource.getOrderDetail(id);

      if (data.isEmpty) {
        throw ServerException('El servidor devolvió un pedido vacío.');
      }

      final model = OrderDetailModel.fromJson(data);
      final entity = model.toEntity();

      return Right(entity);
    } on ServerException catch (e) {
      return Left(ServerFailure('Error al obtener detalle: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> takeOrder(String id, int employeeId) async {
    try {
      await remoteDataSource.takeOrder(id, employeeId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure('Error al tomar pedido: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateStatus(String id, String status) async {
    try {
      await remoteDataSource.updateStatus(id, status);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure('Error al actualizar estado: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getMetrics() async {
    try {
      final data = await remoteDataSource.getMetrics();

      if (data.isEmpty) {
        throw ServerException('El servidor devolvió datos vacíos.');
      }

      return Right(data);
    } on ServerException catch (e) {
      return Left(ServerFailure('Error obteniendo métricas: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }
}
