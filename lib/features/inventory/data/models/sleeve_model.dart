import '../../domain/entities/sleeve_entity.dart';

class SleeveModel extends SleeveEntity {
  const SleeveModel({required super.id, required super.name});

  factory SleeveModel.fromJson(Map<String, dynamic> json) {
    return SleeveModel(id: json['id'] ?? 0, name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
