import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScoreBoard extends StatefulWidget {
  const ScoreBoard({Key? key}) : super(key: key);

  @override
  State<ScoreBoard> createState() => _ScoreBoardState();
}

class _ScoreBoardState extends State<ScoreBoard> {
  late List<Map<String,dynamic>> userList;
  @override
  void initState(){
    super.initState();
    getUsersList();
  }

  void getUsersList() async{
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').get();
    setState(() {
      userList = querySnapshot.docs.map((doc) => {...(doc.data() as Map<String, dynamic>),'id':doc.id}).toList();
    });
  }

  Map<String,int> calculateTotalPoints() {
    Map<String,int> departmentPoints = {};
    userList.forEach((user)
    {
      String department = user['department'];
      int points = user['Total points']??0;
      departmentPoints[department] = (departmentPoints[department]??0) + points;
    });
    return departmentPoints;
  }
  @override
  Widget build(BuildContext context) {
    Map<String,int> departmentPoints = calculateTotalPoints();

    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.bar_chart,color: Colors.white,),
        backgroundColor: Colors.black,
        title: const Text("Score Board",style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 20)),
    ),
      body: departmentPoints.isNotEmpty ? BarChart(
        BarChartData(
          backgroundColor: Colors.black87,
          gridData: FlGridData(show: false),
          alignment: BarChartAlignment.spaceAround,
          maxY: departmentPoints.values.reduce((value,element)=>value > element ? value: element).toDouble()+10,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Text(departmentPoints.keys.toList()[value.toInt()]),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value,meta) => Text(value.toInt().toString()),
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: Colors.black,width: 2),
              left: BorderSide(color:Colors.black,width: 2),
            ),
          ),
          barGroups: departmentPoints.entries.map((entry) {
            return BarChartGroupData(
              x: departmentPoints.keys.toList().indexOf(entry.key).toInt(),
              barRods: [
                BarChartRodData(toY: entry.value.toDouble(), width: 30,gradient: LinearGradient(colors:[Colors.white,Colors.green],begin: Alignment.centerLeft,end:Alignment.centerRight)),
              ],
            );
          }).toList(),
        ),
      )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
