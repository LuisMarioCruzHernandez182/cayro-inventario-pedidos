import '../../domain/entities/color_entity.dart';

class ColorModel extends ColorEntity {
  const ColorModel({
    required super.id,
    required super.name,
    required super.hexValue,
  });

  factory ColorModel.fromJson(Map<String, dynamic> json) {
    return ColorModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      hexValue: json['hexValue'] ?? '#000000',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'hexValue': hexValue,
    };
  }
}
