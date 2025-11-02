enum MuscleGroup { peito, costas, ombros, biceps, triceps, pernas, gluteos, abdomen }

String muscleLabel(MuscleGroup g) {
  switch (g) {
    case MuscleGroup.peito:   return 'Peito';
    case MuscleGroup.costas:  return 'Costas';
    case MuscleGroup.ombros:  return 'Ombros';
    case MuscleGroup.biceps:  return 'Bíceps';
    case MuscleGroup.triceps: return 'Tríceps';
    case MuscleGroup.pernas:  return 'Pernas';
    case MuscleGroup.gluteos: return 'Glúteos';
    case MuscleGroup.abdomen: return 'Abdômen';
  }
}
