import 'package:objectbox/objectbox.dart';

/// Entity for storing search history entries in ObjectBox.
@Entity()
class SearchHistoryEntity {
  @Id()
  int id = 0;

  @Unique(onConflict: ConflictStrategy.replace)
  String symbol;

  @Property(type: PropertyType.date)
  DateTime searchedAt;

  SearchHistoryEntity({
    required this.symbol,
    required this.searchedAt,
    this.id = 0,
  });
}
