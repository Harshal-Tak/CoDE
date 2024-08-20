import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CodeHunt extends StatefulWidget {
  const CodeHunt({Key? key}) : super(key: key);

  @override
  State<CodeHunt> createState() => _CodeHuntState();
}

class _CodeHuntState extends State<CodeHunt> {
  List<Map<String, dynamic>> userList = [];
  bool isLoading = false;
  late List<Map<String, dynamic>> topUsers = [];

  @override
  void initState() {
    super.initState();
    getTop();
  }

  void getTop() async {
    setState(() {
      isLoading = true;
    });

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .orderBy('Event 3 points', descending: true)
        .limit(10)
        .get();

    setState(() {
      topUsers = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      isLoading = false;
    });
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.bar_chart, color: Colors.white),
        backgroundColor: Colors.black,
        title: const Text(
          "Code Hunt",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
        itemCount: topUsers.length,
        itemBuilder: (context, index) {
          final user = topUsers[index];
          return ListTile(
            title: Text(user['name'] ?? ''),
            trailing: Text('Points: ${user['Event 3 points'] ?? 0}'),
            //subtitle: Text('Time: ${user['Event 3 time'] ?? 0}'),
          );
        },
      ),
    );
  }
}

