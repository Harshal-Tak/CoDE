import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Calcathon extends StatefulWidget {
  const Calcathon({Key? key}) : super(key: key);

  @override
  State<Calcathon> createState() => _CalcathonState();
}

class _CalcathonState extends State<Calcathon> {
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
        .orderBy('Event 4 correct', descending: true)
        .limit(10)
        .get();


    setState(() {
      topUsers =
          querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
      isLoading = false;
    });

    // Get the names of top 3 users after updating points
    List<String> topUserNames = topUsers.take(3).map((user) => user['name'] as String).toList();

// Update Event 4 points for top 3 users
    for (int i = 0; i < topUsers.length && i < 3; i++) {
      final user = topUsers[i];
      final userName = user['name'];
      if (userName != null) {
        // Update Event 4 points for the user
        await FirebaseFirestore.instance.collection('users').where('name', isEqualTo: userName).limit(1).get().then((querySnapshot) {
          querySnapshot.docs.forEach((doc) async {
            int points = i == 0 ? 24 : (i == 1 ? 16 : 8);
            await doc.reference.update({'Event 4 points': points});
          });
        });
      }
    }

// Set Event 4 points to 0 for users not in top 3
    QuerySnapshot allUsersQuerySnapshot = await FirebaseFirestore.instance.collection('users').get();
    List<DocumentSnapshot> allUsersDocs = allUsersQuerySnapshot.docs;

    for (final userDoc in allUsersDocs) {
      final userName = userDoc['name'];
      if (userName != null && !topUserNames.contains(userName)) {
        // Set Event 4 points to 0 for users not in top 3
        await userDoc.reference.update({'Event 4 points': 0});
      }
    }
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.bar_chart, color: Colors.white),
        backgroundColor: Colors.black,
        title: const Text(
          "Calcathon",
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
            //subtitle: Text('Answers: ${user['Event 4 correct'] ?? 0}, Time: ${user['Event 4 time'] ?? 0}'),
            trailing: Text('Points: ${user['Event 4 points'] ?? 0}'),
          );
        },
      ),
    );
  }
}
