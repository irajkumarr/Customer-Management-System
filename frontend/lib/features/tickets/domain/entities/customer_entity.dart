import 'package:equatable/equatable.dart';

class CustomerEntity extends Equatable {
  final String id;
  final String email;
  final String? name;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CustomerEntity({
    required this.id,
    required this.email,
    this.name,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, email, name, createdAt, updatedAt];
}
