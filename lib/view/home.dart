import 'package:flutter/material.dart';
import 'package:todolist_app/util/center_tab.dart';
import 'package:todolist_app/view/add_view.dart';
import 'package:todolist_app/view/calendar_view.dart';
import 'package:todolist_app/view/data_view.dart';
import 'package:todolist_app/view/detail_view.dart';
import 'package:todolist_app/view/overview.dart';

class Home extends StatefulWidget {
  final String userid;

  const Home({super.key, required this.userid});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin{

  // Property
  late TabController tabController;

  final overviewKey = GlobalKey<OverviewState>();
  final calendarKey = GlobalKey<CalendarViewState>();
  final dataKey = GlobalKey<DataViewState>();

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 5, vsync: this);
    tabController.addListener((){setState(() {});});
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
          DataView(key: dataKey, userid: widget.userid)
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
                  icon: Icon(Icons.looks_one),
                ),
                Tab(
                  icon: Icon(Icons.looks_two),
                ),
                Tab(
                  child: CenterTab(),
                ),
                Tab(
                  icon: Icon(Icons.looks_3),
                ),
                Tab(
                  icon: Icon(Icons.looks_4),
                ),
              ]
            ),
          ),
        ],
      ),
    );
  }

  _onTodoSaved() {
    overviewKey.currentState?.loadUserData();
    calendarKey.currentState?.loadUserData();

    tabController.animateTo(0);
  }

}