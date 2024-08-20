import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CodePong extends StatefulWidget {
  const CodePong({Key? key}) : super(key: key);

  @override
  State<CodePong> createState() => _CodePongState();
}

class _CodePongState extends State<CodePong> {
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
        .orderBy('Event 2 points', descending: true)
        .limit(12)
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
          "Code Pong",
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
            title: Text(user['name'] ?? '',style: TextStyle(fontSize: 12),),
            trailing: Text('Points: ${user['Event 2 points'] ?? 0}'),
            //trailing: Text('Time: ${user['Event 3 time'] ?? 0}'),
          );
        },
      ),
    );
  }
}
