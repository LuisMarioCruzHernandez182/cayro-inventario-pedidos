import '../../domain/entities/size_entity.dart';

class SizeModel extends SizeEntity {
  const SizeModel({required super.id, required super.name});

  factory SizeModel.fromJson(Map<String, dynamic> json) {
    return SizeModel(id: json['id'] ?? 0, name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
