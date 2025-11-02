import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/training_controller.dart';
import '../models/muscle_group.dart';

class WorkoutSummaryScreen extends StatelessWidget {
  const WorkoutSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TrainingController>(
      builder: (context, training, _) {
        final tempoData = training.weeklyMinutesByGroup();
        final pesoData = training.totalWeightByGroup();
        final groups = MuscleGroup.values;

        // 🎯 CONVERSÃO PARA HORAS
        final tempoValues = groups.map((g) => (tempoData[g] ?? 0).toDouble() / 60.0).toList();
        // 🎯 CONVERSÃO PARA TONELADAS
        final pesoValues = groups.map((g) => (pesoData[g] ?? 0).toDouble() / 1000.0).toList();

        final maxTempo = tempoValues.isEmpty ? 0.0 : tempoValues.reduce((a, b) => a > b ? a : b);
        final maxPeso = pesoValues.isEmpty ? 0.0 : pesoValues.reduce((a, b) => a > b ? a : b);

        final totalTempo = tempoValues.fold<double>(0, (a, b) => a + b);
        final totalPeso = pesoValues.fold<double>(0, (a, b) => a + b);

        if (totalTempo <= 0 && totalPeso <= 0) {
          return const Center(child: Text('Nenhum dado disponível'));
        }

        // Cor para a linha de base (para manter consistência com o tema)
        final baseLineColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.6);

        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 60),
              children: [
                // ======== GRÁFICO DE TEMPO (HORAS) ========
                Text(
                  'Tempo por grupo muscular (horas) — últimos 7 dias', // 👈 TÍTULO ATUALIZADO
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 26),
                SizedBox(
                  height: 260,
                  child: BarChart(
                    BarChartData(
                      maxY: maxTempo <= 0 ? 10 : maxTempo * 1.2,
                      barGroups: [
                        for (var i = 0; i < groups.length; i++)
                          BarChartGroupData(
                            x: i,
                            barsSpace: 12,
                            barRods: [
                              BarChartRodData(
                                toY: tempoValues[i],
                                width: 21,
                                borderRadius: BorderRadius.circular(6),
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ],
                          ),
                      ],
                      gridData: const FlGridData(
                        show: true,
                        drawVerticalLine: false, // Oculta as linhas verticais
                      ),
                      // ➡️ Adicionado a borda inferior como linha de base
                      borderData: FlBorderData(
                        show: true,
                        border: Border(
                          bottom: BorderSide(color: baseLineColor, width: 1.0),
                          left: const BorderSide(color: Colors.transparent),
                          right: const BorderSide(color: Colors.transparent),
                          top: const BorderSide(color: Colors.transparent),
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (v, meta) {
                              if (v == meta.max) {
                                return const SizedBox.shrink();
                              }
                              // 🎯 FORMATADO PARA HORA (1 casa decimal)
                              return Text(
                                v.toStringAsFixed(1),
                                style: Theme.of(context).textTheme.bodySmall,
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 60,
                            getTitlesWidget: (v, _) {
                              final i = v.toInt();
                              if (i < 0 || i >= groups.length) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Transform.rotate(
                                  angle: -0.8,
                                  child: Text(
                                    muscleLabel(groups[i]),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      alignment: BarChartAlignment.center,
                      groupsSpace: 18,
                    ),
                    swapAnimationDuration: const Duration(milliseconds: 900),
                    swapAnimationCurve: Curves.easeOutCubic,
                  ),
                ),

                const SizedBox(height: 40),

                // ======== GRÁFICO DE PESO (TONELADAS) ========
                Text(
                  'Peso total por grupo muscular (toneladas)', // 👈 TÍTULO ATUALIZADO
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 22),
                SizedBox(
                  height: 280,
                  child: BarChart(
                    BarChartData(
                      maxY: maxPeso <= 0 ? 10 : maxPeso * 1.2,
                      barGroups: [
                        for (var i = 0; i < groups.length; i++)
                          BarChartGroupData(
                            x: i,
                            barsSpace: 12,
                            barRods: [
                              BarChartRodData(
                                toY: pesoValues[i],
                                width: 21,
                                borderRadius: BorderRadius.circular(6),
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ],
                          ),
                      ],
                      gridData: const FlGridData(
                        show: true,
                        drawVerticalLine: false, // Oculta as linhas verticais
                      ),
                      // ➡️ Adicionado a borda inferior como linha de base
                      borderData: FlBorderData(
                        show: true,
                        border: Border(
                          bottom: BorderSide(color: baseLineColor, width: 1.0),
                          left: const BorderSide(color: Colors.transparent),
                          right: const BorderSide(color: Colors.transparent),
                          top: const BorderSide(color: Colors.transparent),
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (v, meta) {
                              if (v == meta.max) {
                                return const SizedBox.shrink();
                              }
                              // 🎯 FORMATADO PARA TONELADAS (2 casas decimais para precisão)
                              return Text(
                                v.toStringAsFixed(2),
                                style: Theme.of(context).textTheme.bodySmall,
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 70,
                            getTitlesWidget: (v, _) {
                              final i = v.toInt();
                              if (i < 0 || i >= groups.length) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 14),
                                child: Transform.rotate(
                                  angle: -0.8,
                                  child: Text(
                                    muscleLabel(groups[i]),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      alignment: BarChartAlignment.center,
                      groupsSpace: 18,
                    ),
                    swapAnimationDuration: const Duration(milliseconds: 900),
                    swapAnimationCurve: Curves.easeOutCubic,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}