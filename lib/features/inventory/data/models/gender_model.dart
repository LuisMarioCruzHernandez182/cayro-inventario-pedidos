import '../../domain/entities/gender_entity.dart';

class GenderModel extends GenderEntity {
  const GenderModel({
    required super.id,
    required super.name,
  });

  factory GenderModel.fromJson(Map<String, dynamic> json) {
    return GenderModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
