import 'package:equatable/equatable.dart';

class ColorEntity extends Equatable {
  final int id;
  final String name;
  final String hexValue;

  const ColorEntity({
    required this.id,
    required this.name,
    required this.hexValue,
  });

  @override
  List<Object?> get props => [id, name, hexValue];
}
