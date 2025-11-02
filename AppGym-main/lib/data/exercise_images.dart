/// Mapeia o nome do exercício para o caminho da imagem.
/// Aceita asset ("assets/...") ou URL ("http...").
/// Se não encontrar, o popup mostra um placeholder.

final Map<String, String> exerciseImages = {
  // Peito
  'Supino reto': 'assets/exercises/supinoReto.png',
  'Supino inclinado': 'assets/exercises/supinoInclinado.png',
  'Crucifixo': 'assets/exercises/crucifixo_halteres.gif',
  'Flexão': 'assets/exercises/flexao.gif',

  // Costas
  'Barra fixa': 'assets/exercises/barra_fixa.gif',
  'Puxada na frente': 'assets/exercises/puxada_frente.webp',
  'Remada curvada': 'assets/exercises/remada_curvada.gif',
  'Remada baixa': 'assets/exercises/remada_baixa.gif',

  // Ombros
  'Desenvolvimento': 'assets/exercises/desenvolvimento_ombros.gif',
  'Elevação lateral': 'assets/exercises/elevacao_lateral.webp',
  'Elevação frontal': 'assets/exercises/elevacao_frontal.gif',
  'Remada alta': 'assets/exercises/remada_alta.gif',

  // Bíceps
  'Rosca direta': 'assets/exercises/rosca_direta.gif',
  'Rosca alternada': 'assets/exercises/rosca_alternada.gif',
  'Rosca martelo': 'assets/exercises/rosca_martelo.gif',
  'Scott': 'assets/exercises/rosca_scott.gif',

  // Tríceps
  'Tríceps testa': 'assets/exercises/triceps_testa.gif',
  'Tríceps corda': 'assets/exercises/triceps_corda.gif',
  'Mergulho em banco': 'assets/exercises/mergulho_banco.gif',
  'Paralelas': 'assets/exercises/mergulho_paralelas.gif',

  // Pernas
  'Agachamento livre': 'assets/exercises/agachamento_livre.gif',
  'Leg press': 'assets/exercises/leg_press.gif',
  'Cadeira extensora': 'assets/exercises/cadeira_extensora.gif',
  'Mesa flexora': 'assets/exercises/mesa_flexora.gif',

  // Glúteos
  'Levantamento terra': 'assets/exercises/levantamento_terra.gif',
  'Avanço': 'assets/exercises/avanco.gif',
  'Elevação pélvica': 'assets/exercises/elevacao_pelvica.gif',
  'Cadeira abdutora': 'assets/exercises/cadeira_abdutora.gif',

  // Abdômen
  'Abdominal crunch': 'assets/exercises/abdominal_crunch.gif',
  'Prancha': 'assets/exercises/prancha.jpg',
  'Infra': 'assets/exercises/infra_abdominal.gif',
  'Oblíquos na polia': 'assets/exercises/obliquos_polia.gif',
};
