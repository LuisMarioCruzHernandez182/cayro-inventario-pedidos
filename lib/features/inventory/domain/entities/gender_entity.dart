import 'package:equatable/equatable.dart';

class GenderEntity extends Equatable {
  final int id;
  final String name;

  const GenderEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
