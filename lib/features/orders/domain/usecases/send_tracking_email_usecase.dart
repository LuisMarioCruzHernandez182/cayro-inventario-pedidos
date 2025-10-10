import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/orders_repository.dart';

class SendTrackingEmailUseCase {
  final OrdersRepository repository;

  SendTrackingEmailUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required Map<String, dynamic> emailData,
  }) {
    return repository.sendTrackingEmail(emailData: emailData);
  }
}
