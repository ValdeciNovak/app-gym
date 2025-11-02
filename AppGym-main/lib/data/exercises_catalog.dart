import '../models/muscle_group.dart';

final Map<MuscleGroup, List<String>> exercisesCatalog = {
  MuscleGroup.peito: [
    'Supino reto', 'Supino inclinado', 'Crucifixo', 'Flexão',
  ],
  MuscleGroup.costas: [
    'Barra fixa', 'Puxada na frente', 'Remada curvada', 'Remada baixa',
  ],
  MuscleGroup.ombros: [
    'Desenvolvimento', 'Elevação lateral', 'Elevação frontal', 'Remada alta',
  ],
  MuscleGroup.biceps: [
    'Rosca direta', 'Rosca alternada', 'Rosca martelo', 'Scott',
  ],
  MuscleGroup.triceps: [
    'Tríceps testa', 'Tríceps corda', 'Mergulho em banco', 'Paralelas',
  ],
  MuscleGroup.pernas: [
    'Agachamento livre', 'Leg press', 'Cadeira extensora', 'Mesa flexora',
  ],
  MuscleGroup.gluteos: [
    'Levantamento terra', 'Avanço', 'Elevação pélvica', 'Cadeira abdutora',
  ],
  MuscleGroup.abdomen: [
    'Abdominal crunch', 'Prancha', 'Infra', 'Oblíquos na polia',
  ],
};
