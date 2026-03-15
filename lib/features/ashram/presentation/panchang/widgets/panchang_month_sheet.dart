import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../data/panchang/panchang_engine.dart';
import '../../../data/panchang/panchang_models.dart';

/// Full month calendar with nav arrows, weekday row, grid (date + tithi + festival), legend.
/// onDaySelected: close sheet and open detail for that day.
class PanchangMonthSheet extends StatefulWidget {
  const PanchangMonthSheet({
    super.key,
    required this.initialDate,
    required this.onDaySelected,
  });

  final DateTime initialDate;
  final void Function(DateTime date) onDaySelected;

  @override
  State<PanchangMonthSheet> createState() => _PanchangMonthSheetState();
}

class _PanchangMonthSheetState extends State<PanchangMonthSheet> {
  late int _viewYear;
  late int _viewMonth;
  late DateTime _today;

  @override
  void initState() {
    super.initState();
    _viewYear = widget.initialDate.year;
    _viewMonth = widget.initialDate.month;
    _today = widget.initialDate;
  }

  void _shift(int delta) {
    setState(() {
      _viewMonth += delta;
      if (_viewMonth > 12) {
        _viewMonth = 1;
        _viewYear++;
      } else if (_viewMonth < 1) {
        _viewMonth = 12;
        _viewYear--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final first = DateTime(_viewYear, _viewMonth, 1);
    final last = DateTime(_viewYear, _viewMonth + 1, 0);
    final daysInMonth = last.day;
    final startWeekday = first.weekday; // 1=Mon .. 7=Sun; we want Sun=0
    final leadingEmpty = (startWeekday % 7); // Sun=1 -> 1 empty; Mon=2 -> 2 empty...
    final totalCells = leadingEmpty + daysInMonth;
    final rows = (totalCells / 7).ceil();
    final gridCount = rows * 7;
    final vs = PanchangEngine.vikramSamvatYear(DateTime(_viewYear, _viewMonth, 15));
    final monthName = PanchangEngine.monthNames[_viewMonth - 1];
    final masaLabel = PanchangEngine.masaRangeLabel(_viewMonth);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.panchangBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border.all(color: AppColors.panchangBorder2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _navButton(onPressed: () => _shift(-1), icon: Icons.chevron_left),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$monthName $_viewYear',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: AppColors.panchangText,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '$masaLabel · VS $vs',
                      style: GoogleFonts.notoSansDevanagari(
                        fontSize: 9,
                        color: AppColors.panchangMuted2,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _navButton(onPressed: () => _shift(1), icon: Icons.chevron_right),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'].map((wd) {
              final isSun = wd == 'SUN';
              return Expanded(
                child: Center(
                  child: Text(
                    wd,
                    style: GoogleFonts.outfit(
                      fontSize: 8,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w500,
                      color: isSun
                          ? AppColors.panchangSaffron2.withValues(alpha: 0.45)
                          : AppColors.panchangMuted2,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(4, 2, 4, 8),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 2.5,
                  crossAxisSpacing: 2.5,
                  childAspectRatio: 0.75,
                ),
                itemCount: gridCount,
                itemBuilder: (context, index) {
                  if (index < leadingEmpty) {
                    return const SizedBox.shrink();
                  }
                  final dayNum = index - leadingEmpty + 1;
                  if (dayNum > daysInMonth) {
                    return const SizedBox.shrink();
                  }
                  final d = DateTime(_viewYear, _viewMonth, dayNum);
                  final info = PanchangEngine.getPanchangDay(_viewYear, _viewMonth, dayNum);
                  final isToday = d.year == _today.year &&
                      d.month == _today.month &&
                      d.day == _today.day;
                  final isSun = d.weekday == DateTime.sunday;
                  String cellType = '';
                  if (info.festivals.any((f) => f.major)) {
                    cellType = 'major';
                  } else if (info.festivals.isNotEmpty) {
                    cellType = info.festivals.first.type;
                  } else if (info.tithiType == 'ekadashi') {
                    cellType = 'ekadashi';
                  } else if (info.tithiType == 'purnima') {
                    cellType = 'purnima';
                  } else if (info.tithiType == 'amavasya') {
                    cellType = 'amavasya';
                  }
                  final fest = info.festivals.isNotEmpty ? info.festivals.first : null;
                  return _DayCell(
                    dayNum: dayNum,
                    tithiShort: info.tithiEn.length > 5 ? '${info.tithiEn.substring(0, 5)}' : info.tithiEn,
                    festivalIcon: fest?.icon,
                    festivalName: fest?.name,
                    isToday: isToday,
                    cellType: cellType,
                    isSunday: isSun,
                    onTap: () => widget.onDaySelected(d),
                  );
                },
              ),
            ),
          ),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _navButton({required VoidCallback onPressed, required IconData icon}) {
    return Material(
      color: AppColors.panchangGlass,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.panchangBorder),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.panchangGold, size: 20),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.panchangBorder)),
        color: AppColors.panchangBg.withValues(alpha: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem(AppColors.panchangCrimson.withValues(alpha: 0.8), 'Major'),
          const SizedBox(width: 8),
          _legendItem(AppColors.panchangGold.withValues(alpha: 0.8), 'Festival'),
          const SizedBox(width: 8),
          _legendItem(AppColors.panchangJade.withValues(alpha: 0.7), 'Ekadashi'),
          const SizedBox(width: 8),
          _legendItem(AppColors.panchangIce.withValues(alpha: 0.6), 'Purnima'),
          const SizedBox(width: 8),
          _legendItem(AppColors.panchangViolet.withValues(alpha: 0.8), 'Amavasya'),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 7,
            letterSpacing: 1,
            fontWeight: FontWeight.w500,
            color: AppColors.panchangMuted2,
          ),
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.dayNum,
    required this.tithiShort,
    this.festivalIcon,
    this.festivalName,
    required this.isToday,
    required this.cellType,
    required this.isSunday,
    required this.onTap,
  });

  final int dayNum;
  final String tithiShort;
  final String? festivalIcon;
  final String? festivalName;
  final bool isToday;
  final String cellType;
  final bool isSunday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color? bgColor;
    Color? borderColor;
    if (isToday) {
      borderColor = AppColors.panchangGold.withValues(alpha: 0.55);
      bgColor = AppColors.panchangGold.withValues(alpha: 0.1);
    } else if (cellType == 'major') {
      borderColor = AppColors.panchangCrimson.withValues(alpha: 0.4);
      bgColor = AppColors.panchangCrimson.withValues(alpha: 0.08);
    } else if (cellType == 'festival' || cellType == 'major') {
      borderColor = AppColors.panchangGold.withValues(alpha: 0.3);
      bgColor = AppColors.panchangGold.withValues(alpha: 0.06);
    } else if (cellType == 'ekadashi') {
      borderColor = AppColors.panchangJade.withValues(alpha: 0.25);
      bgColor = AppColors.panchangJade.withValues(alpha: 0.05);
    } else if (cellType == 'purnima') {
      borderColor = AppColors.panchangIce.withValues(alpha: 0.18);
      bgColor = AppColors.panchangIce.withValues(alpha: 0.04);
    } else if (cellType == 'amavasya') {
      borderColor = AppColors.panchangViolet.withValues(alpha: 0.28);
      bgColor = AppColors.panchangViolet.withValues(alpha: 0.07);
    } else {
      bgColor = AppColors.panchangGlass;
      borderColor = AppColors.panchangBorder;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$dayNum',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isSunday
                          ? AppColors.panchangSaffron2.withValues(alpha: 0.7)
                          : AppColors.panchangText,
                    ),
                  ),
                  Text(
                    tithiShort,
                    style: GoogleFonts.outfit(
                      fontSize: 6,
                      color: AppColors.panchangMuted2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (festivalIcon != null) ...[
                    const SizedBox(height: 1),
                    Text(festivalIcon!, style: const TextStyle(fontSize: 12)),
                  ],
                  if (festivalName != null && festivalName!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Text(
                        festivalName!,
                        style: GoogleFonts.outfit(
                          fontSize: 5,
                          color: cellType == 'major'
                              ? AppColors.panchangCrimson.withValues(alpha: 0.85)
                              : AppColors.panchangJade.withValues(alpha: 0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
              if (isToday)
                Positioned(
                  bottom: 2,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      height: 2,
                      width: 16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: LinearGradient(
                          colors: [AppColors.panchangGold, AppColors.panchangSaffron2],
                        ),
                      ),
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
