import 'package:flutter/material.dart';
import 'package:todolist_app/util/center_tab.dart';
import 'package:todolist_app/view/add_view.dart';
import 'package:todolist_app/view/calendar_view.dart';
import 'package:todolist_app/view/data_view.dart';
import 'package:todolist_app/view/detail_view.dart';
import 'package:todolist_app/view/overview.dart';

class Home extends StatefulWidget {
  final String userid;                                 // 유저 정보

  const Home({super.key, required this.userid});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin{

  // Property
  late TabController tabController;                    // TabController

  final overviewKey = GlobalKey<OverviewState>();      // OverView 화면에 접근
  final calendarKey = GlobalKey<CalendarViewState>();  // CalendarView 화면에 접근

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 5, vsync: this);
    tabController.addListener((){setState(() {});});   // 탭이 변경될 때마다 새로고침
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: tabController.index,
        children: [
          Overview(key: overviewKey, userid: widget.userid),
          CalendarView(key: calendarKey, userid: widget.userid),
          AddView(userid: widget.userid, onSaved: _onTodoSaved),
          DetailView(userid: widget.userid),
          DataView(userid: widget.userid)
        ]
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            color: Colors.grey[300],
            height: 1,
          ),
          Container(
            color: Colors.white,
            height: 80,
            child: TabBar(
              controller: tabController,
              labelColor: Colors.black,
              indicatorColor: Colors.transparent,
              indicatorWeight: 5,
              tabs: [
                Tab(
                  icon: Icon(Icons.view_agenda_outlined),
                ),
                Tab(
                  icon: Icon(Icons.calendar_month_outlined),
                ),
                Tab(
                  child: CenterTab(),
                ),
                Tab(
                  icon: Icon(Icons.search),
                ),
                Tab(
                  icon: Icon(Icons.bar_chart),
                ),
              ]
            ),
          ),
        ],
      ),
    );
  } // build

  // 일정 저장 후 OverView로 돌아가기
  _onTodoSaved() {
    overviewKey.currentState?.loadUserData();
    calendarKey.currentState?.loadUserData();

    tabController.animateTo(0);
  }

} // class