import '../models/muscle_group.dart';

MuscleGroup mapTitleToGroup(String title) {
  final t = title.toLowerCase();
  if (t.contains('peito') || t.contains('chest'))   return MuscleGroup.peito;
  if (t.contains('costas') || t.contains('back'))    return MuscleGroup.costas;
  if (t.contains('ombro') || t.contains('should'))   return MuscleGroup.ombros;
  if (t.contains('bíceps') || t.contains('biceps'))  return MuscleGroup.biceps;
  if (t.contains('tríceps') || t.contains('triceps'))return MuscleGroup.triceps;
  if (t.contains('perna') || t.contains('legs') || t.contains('quad')) return MuscleGroup.pernas;
  if (t.contains('glúte') || t.contains('glute'))    return MuscleGroup.gluteos;
  if (t.contains('abdô') || t.contains('abdom') || t.contains('core') || t.contains('abs')) return MuscleGroup.abdomen;
  return MuscleGroup.pernas;
}
