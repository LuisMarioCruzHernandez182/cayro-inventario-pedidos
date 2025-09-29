import 'package:equatable/equatable.dart';

class ImageEntity extends Equatable {
  final int id;
  final String url;
  final String angle;

  const ImageEntity({required this.id, required this.url, required this.angle});

  @override
  List<Object?> get props => [id, url, angle];
}
