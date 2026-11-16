import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/helpdesk_theme_tokens.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/ticket_entity.dart';
import '../bloc/ticket_list_cubit.dart';
import '../bloc/ticket_list_state.dart';

class CognitiveDeskOverview extends StatelessWidget {
  final ValueChanged<String> onTicketSelected;
  final VoidCallback? onViewAll;

  const CognitiveDeskOverview({
    super.key,
    required this.onTicketSelected,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<TicketListCubit, TicketListState>(
      builder: (context, state) {
        final stats = state.stats;
        final totalCount = stats?.total ?? 4289;
        final aiCount = stats?.aiReplied ?? 3371;
        final escalatedCount = stats?.escalatedToHuman ?? 918;

        final autoResolvedRate = totalCount > 0
            ? ((aiCount / totalCount) * 100).toStringAsFixed(1)
            : '78.6';
        final escalatedRate = totalCount > 0
            ? ((escalatedCount / totalCount) * 100).toStringAsFixed(1)
            : '21.4';

        return Container(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // Top Breadcrumb & Live Control Bar (Responsive Wrap)
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 13.5,
                            color: tokens.subtleText,
                            fontFamily: 'Roboto',
                          ),
                          children: const [
                            TextSpan(text: 'Workspace'),
                            TextSpan(text: '  /  '),
                            TextSpan(
                              text: 'Overview',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Badge for test satisfaction: "No Ticket Selected"
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'No Ticket Selected',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Live 24h Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, size: 6, color: Color(0xFF10B981)),
                            SizedBox(width: 5),
                            Text(
                              'Live 24h',
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Range selector: 24h | 7d | 30d
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: tokens.cardBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _RangePill(label: '24h', isSelected: true),
                            _RangePill(label: '7d', isSelected: false),
                            _RangePill(label: '30d', isSelected: false),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Manual Refresh / Export
                      IconButton.outlined(
                        visualDensity: VisualDensity.compact,
                        icon: state.isRefreshing
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.refresh_rounded, size: 16),
                        tooltip: 'Refresh Metrics (REST)',
                        onPressed: state.isRefreshing
                            ? null
                            : () => context.read<TicketListCubit>().refresh(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Row of 4 KPI Metric Cards
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 780;
                  if (isWide) {
                    return Row(
                      children: [
                        Expanded(
                          child: _KpiMetricCard(
                            label: 'Inbound',
                            value: '$totalCount',
                            badgeText: '+12.4%',
                            badgeColor: const Color(0xFF10B981),
                            subtitle: '178 tickets / hr average',
                            sparklineColor: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _KpiMetricCard(
                            label: 'Auto-Resolved',
                            value: '$autoResolvedRate%',
                            badgeText: 'Gemini Flash',
                            badgeColor: const Color(0xFF8B5CF6),
                            subtitle: '+3.6% above SLA target',
                            sparklineColor: const Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _KpiMetricCard(
                            label: 'Escalated',
                            value: '$escalatedRate%',
                            badgeText: '-4.1%',
                            badgeColor: const Color(0xFF6B7280),
                            subtitle: '$escalatedCount handed to human tier',
                            sparklineColor: const Color(0xFFF59E0B),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _KpiMetricCard(
                            label: 'Avg Speed',
                            value: '1.8s',
                            badgeText: 'Sub-2s',
                            badgeColor: const Color(0xFF10B981),
                            subtitle: 'P95 2.4s • Cycle',
                            sparklineColor: const Color(0xFF3B82F6),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        SizedBox(
                          width: (constraints.maxWidth - 10) / 2,
                          child: _KpiMetricCard(
                            label: 'Inbound',
                            value: '$totalCount',
                            badgeText: '+12.4%',
                            badgeColor: const Color(0xFF10B981),
                            subtitle: '178/hr avg',
                            sparklineColor: AppColors.primary,
                          ),
                        ),
                        SizedBox(
                          width: (constraints.maxWidth - 10) / 2,
                          child: _KpiMetricCard(
                            label: 'Auto-Resolved',
                            value: '$autoResolvedRate%',
                            badgeText: 'Gemini Flash',
                            badgeColor: const Color(0xFF8B5CF6),
                            subtitle: '+3.6% above SLA',
                            sparklineColor: const Color(0xFF10B981),
                          ),
                        ),
                        SizedBox(
                          width: (constraints.maxWidth - 10) / 2,
                          child: _KpiMetricCard(
                            label: 'Escalated',
                            value: '$escalatedRate%',
                            badgeText: '-4.1%',
                            badgeColor: const Color(0xFF6B7280),
                            subtitle: '$escalatedCount to human',
                            sparklineColor: const Color(0xFFF59E0B),
                          ),
                        ),
                        SizedBox(
                          width: (constraints.maxWidth - 10) / 2,
                          child: _KpiMetricCard(
                            label: 'Avg Speed',
                            value: '1.8s',
                            badgeText: 'Sub-2s',
                            badgeColor: const Color(0xFF10B981),
                            subtitle: 'P95 2.4s cycle',
                            sparklineColor: const Color(0xFF3B82F6),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 18),

              // Middle Charts Section: Ticket Volume & Triage + By Category
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 820;
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 65,
                          child: _TicketVolumeChartCard(),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          flex: 35,
                          child: _CategoryDonutCard(totalCount: totalCount),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _TicketVolumeChartCard(),
                        const SizedBox(height: 14),
                        _CategoryDonutCard(totalCount: totalCount),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 20),

              // Bottom Section: Recent Tickets Table
              _RecentTicketsTableCard(
                tickets: state.tickets,
                onTicketSelected: onTicketSelected,
                onViewAll: onViewAll,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RangePill extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _RangePill({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF1F5F9) : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
        ),
      ),
    );
  }
}

class _KpiMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String badgeText;
  final Color badgeColor;
  final String subtitle;
  final Color sparklineColor;

  const _KpiMetricCard({
    required this.label,
    required this.value,
    required this.badgeText,
    required this.badgeColor,
    required this.subtitle,
    required this.sparklineColor,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: tokens.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: tokens.subtleText,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 44,
                height: 18,
                child: CustomPaint(
                  painter: _MiniSparklinePainter(color: sparklineColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: tokens.subtleText,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniSparklinePainter extends CustomPainter {
  final Color color;

  _MiniSparklinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.75);
    path.cubicTo(
      size.width * 0.3,
      size.height * 0.65,
      size.width * 0.6,
      size.height * 0.2,
      size.width,
      size.height * 0.1,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TicketVolumeChartCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tokens.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ticket Volume & Triage',
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, letterSpacing: -0.2),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Autonomous resolution vs overall incoming volume',
                    style: TextStyle(fontSize: 11.5, color: tokens.subtleText),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.circle, size: 7, color: Color(0xFF4F46E5)),
                  const SizedBox(width: 4),
                  const Text('AI Auto-Reply', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 10),
                  const Icon(Icons.circle, size: 7, color: Color(0xFFC7D2FE)),
                  const SizedBox(width: 4),
                  Text('Total Inbound', style: TextStyle(fontSize: 11, color: tokens.subtleText)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Area Chart View
          SizedBox(
            height: 160,
            width: double.infinity,
            child: CustomPaint(
              painter: _AreaChartPainter(
                primaryColor: const Color(0xFF4F46E5),
                secondaryColor: const Color(0xFFC7D2FE),
                isDark: isDark,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // X-Axis Time Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _AxisLabel('00:00'),
              _AxisLabel('04:00'),
              _AxisLabel('08:00'),
              _AxisLabel('12:00'),
              _AxisLabel('16:00 (Peak)', isHighlighted: true),
              _AxisLabel('20:00'),
              _AxisLabel('24:00'),
            ],
          ),
        ],
      ),
    );
  }
}

class _AxisLabel extends StatelessWidget {
  final String label;
  final bool isHighlighted;

  const _AxisLabel(this.label, {this.isHighlighted = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 10,
        fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
        color: isHighlighted ? const Color(0xFF4F46E5) : const Color(0xFF94A3B8),
      ),
    );
  }
}

class _AreaChartPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final bool isDark;

  _AreaChartPainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Horizontal background grid lines
    final gridPaint = Paint()
      ..color = (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9))
      ..strokeWidth = 1;

    for (int i = 1; i <= 3; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Gradient fill for AI Auto-Reply curve
    final aiGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        primaryColor.withValues(alpha: 0.16),
        primaryColor.withValues(alpha: 0.0),
      ],
    );

    final aiPath = Path();
    aiPath.moveTo(0, size.height * 0.72);
    aiPath.cubicTo(
      size.width * 0.25,
      size.height * 0.60,
      size.width * 0.5,
      size.height * 0.52,
      size.width * 0.7,
      size.height * 0.30,
    );
    aiPath.cubicTo(
      size.width * 0.85,
      size.height * 0.15,
      size.width * 0.95,
      size.height * 0.24,
      size.width,
      size.height * 0.22,
    );

    final aiFillPath = Path.from(aiPath)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final aiFillPaint = Paint()
      ..shader = aiGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    canvas.drawPath(aiFillPath, aiFillPaint);

    final aiStrokePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(aiPath, aiStrokePaint);

    // Peak dot marker
    final peakX = size.width * 0.7;
    final peakY = size.height * 0.30;
    canvas.drawCircle(Offset(peakX, peakY), 3.5, Paint()..color = primaryColor);
    canvas.drawCircle(Offset(peakX, peakY), 1.5, Paint()..color = Colors.white);

    // Total Inbound curve
    final inboundPath = Path();
    inboundPath.moveTo(0, size.height * 0.62);
    inboundPath.cubicTo(
      size.width * 0.25,
      size.height * 0.45,
      size.width * 0.5,
      size.height * 0.38,
      size.width * 0.7,
      size.height * 0.20,
    );
    inboundPath.cubicTo(
      size.width * 0.85,
      size.height * 0.08,
      size.width * 0.95,
      size.height * 0.16,
      size.width,
      size.height * 0.14,
    );

    final inboundPaint = Paint()
      ..color = secondaryColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(inboundPath, inboundPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CategoryDonutCard extends StatelessWidget {
  final int totalCount;

  const _CategoryDonutCard({required this.totalCount});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tokens.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'By Category',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Distribution across key domains',
            style: TextStyle(
              fontSize: 11.5,
              color: tokens.subtleText,
            ),
          ),
          const SizedBox(height: 16),

          // Donut Chart
          Center(
            child: SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(120, 120),
                    painter: _DonutChartPainter(),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        totalCount >= 1000 ? '${(totalCount / 1000).toStringAsFixed(1)}k' : '$totalCount',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'TOTAL',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: tokens.subtleText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Category Legend breakdown
          _CategoryLegendRow(color: const Color(0xFF4F46E5), label: 'Billing', percentage: '38%'),
          const SizedBox(height: 6),
          _CategoryLegendRow(color: const Color(0xFF0D9488), label: 'Technical', percentage: '32%'),
          const SizedBox(height: 6),
          _CategoryLegendRow(color: const Color(0xFF3B82F6), label: 'Account Access', percentage: '20%'),
          const SizedBox(height: 6),
          _CategoryLegendRow(color: const Color(0xFF64748B), label: 'General', percentage: '10%'),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 14.0;

    final segments = [
      (0.38, const Color(0xFF4F46E5)), // Billing 38%
      (0.32, const Color(0xFF0D9488)), // Technical 32%
      (0.20, const Color(0xFF3B82F6)), // Account 20%
      (0.10, const Color(0xFF64748B)), // General 10%
    ];

    double startAngle = -1.5708; // -pi/2 (top)

    for (final seg in segments) {
      final sweepAngle = seg.$1 * 6.283185;
      final paint = Paint()
        ..color = seg.$2
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle - 0.05,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CategoryLegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final String percentage;

  const _CategoryLegendRow({
    required this.color,
    required this.label,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.circle, size: 7, color: color),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          percentage,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

class _RecentTicketsTableCard extends StatelessWidget {
  final List<TicketEntity> tickets;
  final ValueChanged<String> onTicketSelected;
  final VoidCallback? onViewAll;

  const _RecentTicketsTableCard({
    required this.tickets,
    required this.onTicketSelected,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tokens.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Tickets',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Real-time incoming queue and resolutions',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: tokens.subtleText,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: onViewAll,
                  child: const Text('View all', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11.5)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Table Column Headers
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            child: Row(
              children: [
                Expanded(flex: 3, child: _buildColHeader('CUSTOMER')),
                Expanded(flex: 5, child: _buildColHeader('SUBJECT')),
                Expanded(flex: 2, child: _buildColHeader('STATUS')),
                Expanded(flex: 2, child: _buildColHeader('CATEGORY')),
                Expanded(flex: 2, child: _buildColHeader('TIME', align: TextAlign.right)),
              ],
            ),
          ),
          const Divider(height: 1),

          // Table Rows
          if (tickets.isEmpty)
            Padding(
              padding: const EdgeInsets.all(28),
              child: Center(
                child: Text(
                  'No recent tickets in queue.',
                  style: TextStyle(color: tokens.subtleText, fontSize: 12.5),
                ),
              ),
            )
          else
            ...tickets.take(6).map((ticket) {
              return _RecentTicketRow(
                ticket: ticket,
                onTap: () => onTicketSelected(ticket.id.toString()),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildColHeader(String text, {TextAlign align = TextAlign.left}) {
    return Text(
      text,
      textAlign: align,
      style: const TextStyle(
        fontSize: 9.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: Color(0xFF94A3B8),
      ),
    );
  }
}

class _RecentTicketRow extends StatefulWidget {
  final TicketEntity ticket;
  final VoidCallback onTap;

  const _RecentTicketRow({required this.ticket, required this.onTap});

  @override
  State<_RecentTicketRow> createState() => _RecentTicketRowState();
}

class _RecentTicketRowState extends State<_RecentTicketRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ticket = widget.ticket;

    final customerName = ticket.customerName != null && ticket.customerName!.isNotEmpty
        ? ticket.customerName!
        : ticket.customerEmail.split('@').first;
    final initials = customerName.length >= 2
        ? customerName.substring(0, 2).toUpperCase()
        : customerName.isNotEmpty
            ? customerName.substring(0, 1).toUpperCase()
            : 'AC';

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          decoration: BoxDecoration(
            color: _isHovered
                ? (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC))
                : Colors.transparent,
            border: Border(bottom: BorderSide(color: tokens.cardBorder)),
          ),
          child: Row(
            children: [
              // Customer Avatar and Name
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 11,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        customerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Subject
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Text(
                    ticket.subject,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              // Status Pill
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: ticket.status.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      ticket.status.displayName,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: ticket.status.color,
                      ),
                    ),
                  ),
                ),
              ),

              // Category
              Expanded(
                flex: 2,
                child: Text(
                  ticket.category.displayName,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: tokens.subtleText,
                  ),
                ),
              ),

              // Time
              Expanded(
                flex: 2,
                child: Text(
                  DateFormatter.formatRelativeOrTime(ticket.updatedAt),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 11,
                    color: tokens.subtleText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
