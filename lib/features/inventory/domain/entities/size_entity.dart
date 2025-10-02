import 'package:equatable/equatable.dart';

class SizeEntity extends Equatable {
  final int id;
  final String name;

  const SizeEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
