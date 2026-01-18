import 'package:robandigital/domain/entities/channel_entity.dart';

class ChannelResponse {
  final bool success;
  final String message;
  final List<ChannelModel> data;
  final ChannelMeta meta;
  final int code;

  ChannelResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.meta,
    required this.code,
  });

  factory ChannelResponse.fromJson(Map<String, dynamic> json) {
    return ChannelResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List?)
              ?.map((e) => ChannelModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      meta: ChannelMeta.fromJson(json['meta'] as Map<String, dynamic>? ?? {}),
      code: json['code'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
      'meta': meta.toJson(),
      'code': code,
    };
  }
}

class ChannelModel extends ChannelEntity {
  const ChannelModel({
    required super.id,
    required super.unitId,
    required super.name,
    required super.code,
    required super.isActive,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ChannelModel.fromJson(Map<String, dynamic> json) {
    return ChannelModel(
      id: json['id'] ?? 0,
      unitId: json['unitId'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      isActive: json['isActive'] ?? false,
      createdBy: json['createdBy'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'unitId': unitId,
      'name': name,
      'code': code,
      'isActive': isActive,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ChannelModel.fromEntity(ChannelEntity entity) {
    return ChannelModel(
      id: entity.id,
      unitId: entity.unitId,
      name: entity.name,
      code: entity.code,
      isActive: entity.isActive,
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

class ChannelMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasMore;

  ChannelMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasMore,
  });

  factory ChannelMeta.fromJson(Map<String, dynamic> json) {
    return ChannelMeta(
      page: json['page'] ?? 0,
      limit: json['limit'] ?? 0,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      hasMore: json['hasMore'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'totalPages': totalPages,
      'hasMore': hasMore,
    };
  }
}
