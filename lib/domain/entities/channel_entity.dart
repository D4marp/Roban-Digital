import 'package:equatable/equatable.dart';

class ChannelEntity extends Equatable {
  final int id;
  final int unitId;
  final String name;
  final String code;
  final bool isActive;
  final int createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChannelEntity({
    required this.id,
    required this.unitId,
    required this.name,
    required this.code,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        unitId,
        name,
        code,
        isActive,
        createdBy,
        createdAt,
        updatedAt,
      ];
}

class ChannelListResponse extends Equatable {
  final List<ChannelEntity> channels;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasMore;

  const ChannelListResponse({
    required this.channels,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [
        channels,
        page,
        limit,
        total,
        totalPages,
        hasMore,
      ];
}
