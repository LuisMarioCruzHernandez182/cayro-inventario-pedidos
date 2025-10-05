import 'package:equatable/equatable.dart';

class SleeveEntity extends Equatable {
  final int id;
  final String name;

  const SleeveEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
