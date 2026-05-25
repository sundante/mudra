import 'package:isar/isar.dart';

part 'outgoing.g.dart';

@collection
class Outgoing {
  Id id = Isar.autoIncrement;

  late String uid;
  late String name;

  @enumerated
  late OutgoingType outgoingType;

  @enumerated
  late OutgoingCategory category;

  double amount = 0.0;
  int debitDate = 1;
  bool isActive = true;
  late DateTime createdAt;
}

enum OutgoingType { expense, investment }

enum OutgoingCategory {
  loan,
  insurance,
  utility,
  subscription,
  sip,
  ppf,
  epf,
  nps,
  other,
}
