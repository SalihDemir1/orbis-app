import 'package:isar/isar.dart';

// Isar kod üretimi için bu satır şarttır
part 'sohbet_model.g.dart';

@collection
class SohbetMesaji {
  Id id = Isar.autoIncrement;
  late String metin;
  late DateTime tarih;
  late bool asistanMi;
  String? baslik;
  String? sessionId; // 🆕 Sohbetleri gruplamak için eklediğimiz alan
}