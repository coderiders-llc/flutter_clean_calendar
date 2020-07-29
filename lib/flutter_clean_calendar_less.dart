library flutter_clean_calendar_less;

import 'package:flutter/material.dart';
import 'package:date_utils/date_utils.dart';
import './simple_gesture_detector.dart';
import './calendar_tile.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';



class CalendarLess extends StatelessWidget {

  final BuildContext context;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged onRangeSelected;
  final bool hideTodayIcon;
  final Map<DateTime, List> events;
  final Color selectedColor;
  final Color todayColor;
  final Color eventColor;
  final Color eventDoneColor;
  DateTime initialDate;
  final bool isExpanded;
  final List<String> weekDays;
  final String locale;
  final bool startOnMonday;
  final bool hideBottomBar;
  final TextStyle dayOfWeekStyle;
  final TextStyle bottomBarTextStyle;
  final Color bottomBarArrowColor;
  final Color bottomBarColor;
  final Color inMonthDayColor;
  final Color todayIconColor;
  final Color displayMonthColor;

  CalendarLess({
    this.context,
    this.onMonthChanged,
    this.onDateSelected,
    this.onRangeSelected,
    this.hideBottomBar: false,
    this.events: null,
    this.hideTodayIcon: false,
    this.selectedColor,
    this.todayColor,
    this.eventColor,
    this.eventDoneColor,
    this.initialDate,
    this.isExpanded = false,
    this.weekDays = const ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"],
    this.locale = "en_US",
    this.startOnMonday = false,
    this.dayOfWeekStyle,
    this.bottomBarTextStyle,
    this.bottomBarArrowColor,
    this.bottomBarColor,
    this.inMonthDayColor,
    this.todayIconColor = Colors.black,
    this.displayMonthColor = Colors.black,
  }) {
    initialDate = initialDate ?? DateTime.now();
    _selectedDate = initialDate ?? DateTime.now();
    selectedMonthsDays = _daysInMonth(_selectedDate);
    selectedWeekDays = Utils.daysInRange(
        _firstDayOfWeek(_selectedDate), _lastDayOfWeek(_selectedDate))
        .toList();
    var monthFormat = DateFormat("MMMM yyyy", locale).format(_selectedDate);
    selectedDateMonth = "${monthFormat[0].toUpperCase()}${monthFormat.substring(1)}";
  }

  final calendarUtils = Utils();
  List<DateTime> selectedMonthsDays;
  Iterable<DateTime> selectedWeekDays;
  DateTime _selectedDate = DateTime.now();
  String currentMonth;
  String selectedDateMonth;

  Future<String> displayMonthName() async {
      var monthFormat = DateFormat("MMMM yyyy", 'zh_HK').format(_selectedDate);
      print(monthFormat);
      return "${monthFormat[0].toUpperCase()}${monthFormat.substring(1)}";
  }

  DateTime get selectedDate => _selectedDate;

  Widget get nameAndIconRow {
    var todayIcon;

    if (!hideTodayIcon) {
      todayIcon = Container(
        child: Text('Today', style: TextStyle(
            color: todayIconColor
        ),),
      );
    } else {
      todayIcon = Container();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: <Widget>[
            todayIcon ?? Container(),
            Text(
              selectedDateMonth,
              style: TextStyle(
                  fontSize: 20.0,
                  color: displayMonthColor
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget get calendarGridView {
    return Container(
      child: Column(children: <Widget>[
        GridView.count(
          childAspectRatio: 1.5,
          primary: false,
          shrinkWrap: true,
          crossAxisCount: 7,
          padding: EdgeInsets.only(bottom: 0.0),
          children: calendarBuilder(),
        ),
      ]),
    );
  }

  List<Widget> calendarBuilder() {
    List<Widget> dayWidgets = [];
    List<DateTime> calendarDays =
    isExpanded ? selectedMonthsDays : selectedWeekDays;
    weekDays.forEach(
          (day) {
        dayWidgets.add(
          CalendarTile(
            selectedColor: selectedColor,
            todayColor: todayColor,
            eventColor: eventColor,
            eventDoneColor: eventDoneColor,
            events: events == null  ? null : events[day],
            isDayOfWeek: true,
            dayOfWeek: day,
            inMonthDayColor: inMonthDayColor,
            dayOfWeekStyle: dayOfWeekStyle ??
                TextStyle(
                  color: selectedColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
          ),
        );
      },
    );

    bool monthStarted = false;
    bool monthEnded = false;

    calendarDays.forEach(
          (day) {
        if (day.hour > 0) {
          day = day.toLocal();
          day = day.subtract(new Duration(hours: day.hour));
        }

        if (monthStarted && day.day == 01) {
          monthEnded = true;
        }

        if (Utils.isFirstDayOfMonth(day)) {
          monthStarted = true;
        }

        dayWidgets.add(
          CalendarTile(
              selectedColor: selectedColor,
              todayColor: todayColor,
              eventColor: eventColor,
              inMonthDayColor: inMonthDayColor,
              eventDoneColor: eventDoneColor,
              events: events == null  ? null : events[day],
              date: day,
              dateStyles: configureDateStyle(monthStarted, monthEnded),
              isSelected: Utils.isSameDay(selectedDate, day),
              inMonth: day.month == selectedDate.month),
        );
      },
    );
    return dayWidgets;
  }

  TextStyle configureDateStyle(monthStarted, monthEnded) {
    TextStyle dateStyles;
    final TextStyle body1Style = Theme.of(context).textTheme.body1;

    if (isExpanded) {
      final TextStyle body1StyleDisabled = body1Style.copyWith(
          color: Color.fromARGB(
            100,
            body1Style.color.red,
            body1Style.color.green,
            body1Style.color.blue,
          ));

      dateStyles =
      monthStarted && !monthEnded ? body1Style : body1StyleDisabled;
    } else {
      dateStyles = body1Style;
    }
    return dateStyles;
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          nameAndIconRow,
          ExpansionCrossFade(
            collapsed: calendarGridView,
            expanded: calendarGridView,
            isExpanded: isExpanded,
          ),
        ],
      ),
    );
  }


  _firstDayOfWeek(DateTime date) {
    var day = new DateTime.utc(
        _selectedDate.year, _selectedDate.month, _selectedDate.day, 12);
    return day.subtract(
        new Duration(days: day.weekday - (startOnMonday ? 1 : 0)));
  }

  _lastDayOfWeek(DateTime date) {
    return _firstDayOfWeek(date).add(new Duration(days: 7));
  }

  List<DateTime> _daysInMonth(DateTime month) {
    var first = Utils.firstDayOfMonth(month);
    var daysBefore = first.weekday;
    var firstToDisplay = first.subtract(new Duration(days: daysBefore - 1));
    var last = Utils.lastDayOfMonth(month);

    var daysAfter = 7 - last.weekday;

    // If the last day is sunday (7) the entire week must be rendered
    if (daysAfter == 0) {
      daysAfter = 7;
    }

    var lastToDisplay = last.add(new Duration(days: daysAfter));
    return Utils.daysInRange(firstToDisplay, lastToDisplay).toList();
  }
}

class ExpansionCrossFade extends StatelessWidget {
  final Widget collapsed;
  final Widget expanded;
  final bool isExpanded;

  ExpansionCrossFade({this.collapsed, this.expanded, this.isExpanded});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      child: AnimatedCrossFade(
        firstChild: collapsed,
        secondChild: expanded,
        firstCurve: const Interval(0.0, 1.0, curve: Curves.fastOutSlowIn),
        secondCurve: const Interval(0.0, 1.0, curve: Curves.fastOutSlowIn),
        sizeCurve: Curves.decelerate,
        crossFadeState:
            isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 300),
      ),
    );
  }
}
