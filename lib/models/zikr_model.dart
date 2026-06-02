import 'package:flutter/foundation.dart';

@immutable
class ZikrModel {
  const ZikrModel({
    required this.id,
    required this.nameEn,
    required this.nameUr,
    required this.targetCount,
    this.currentCount = 0,
    this.isCustom = false,
  });

  final String id;
  final String nameEn;
  final String nameUr;
  final int targetCount;
  final int currentCount;
  final bool isCustom;

  ZikrModel copyWith({
    String? id,
    String? nameEn,
    String? nameUr,
    int? targetCount,
    int? currentCount,
    bool? isCustom,
  }) {
    return ZikrModel(
      id: id ?? this.id,
      nameEn: nameEn ?? this.nameEn,
      nameUr: nameUr ?? this.nameUr,
      targetCount: targetCount ?? this.targetCount,
      currentCount: currentCount ?? this.currentCount,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  factory ZikrModel.fromMap(Map<String, dynamic> map) {
    return ZikrModel(
      id: map['id'] as String,
      nameEn: map['nameEn'] as String,
      nameUr: map['nameUr'] as String,
      targetCount: (map['targetCount'] as num).toInt(),
      currentCount: (map['currentCount'] as num?)?.toInt() ?? 0,
      isCustom: map['isCustom'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nameEn': nameEn,
      'nameUr': nameUr,
      'targetCount': targetCount,
      'currentCount': currentCount,
      'isCustom': isCustom,
    };
  }

  static const List<ZikrModel> defaultZikrs = [
    ZikrModel(
      id: 'kalma_tayyaba',
      nameEn: 'Kalma Tayyaba',
      nameUr: 'کلمہ طیبہ',
      targetCount: 2000,
    ),
    ZikrModel(
      id: 'astaghfar',
      nameEn: 'Astaghfar',
      nameUr: 'استغفار',
      targetCount: 313,
    ),
    ZikrModel(
      id: 'darood_sharif',
      nameEn: 'Darood Sharif',
      nameUr: 'درود شریف',
      targetCount: 100,
    ),
    ZikrModel(
      id: 'surah_ikhlas',
      nameEn: 'Surah Ikhlas',
      nameUr: 'سورۃ اخلاص',
      targetCount: 41,
    ),
  ];
}
