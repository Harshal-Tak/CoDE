import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Logotrix extends StatefulWidget {
  const Logotrix({Key? key}) : super(key: key);

  @override
  State<Logotrix> createState() => _LogotrixState();
}

class _LogotrixState extends State<Logotrix> {
  List<Map<String, dynamic>> userList = [];
  bool isLoading = false;
  late List<Map<String, dynamic>> topUsers = [];

  @override
  void initState(){
    super.initState();
    getTop();
  }

  void getTop() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .orderBy('Event 5 guesses', descending: true)
        .limit(10)
        .get();

    setState(() {
      topUsers = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      isLoading = false;
    });

    // Assign points to top 10 users from 10 to 1
    for (int i = 0; i < topUsers.length; i++) {
      final user = topUsers[i];

      // Calculate points based on position
      int points = 10 - i;

      // Update Event 5 points for the user
      await FirebaseFirestore.instance.collection('users').where('name', isEqualTo: user['name']).limit(1).get().then((querySnapshot) {
        querySnapshot.docs.forEach((doc) async {
          await doc.reference.update({'Event 5 points': points});
        });
      });
    }

    // Update Event 5 points to 0 for users not in top 10
    QuerySnapshot allUsersQuerySnapshot = await FirebaseFirestore.instance.collection('users').get();
    List<DocumentSnapshot> allUsersDocs = allUsersQuerySnapshot.docs;

    for (final userDoc in allUsersDocs) {
      final userData = userDoc.data() as Map<String, dynamic>;

      // Check if the user is not in the top 10
      if (!topUsers.any((user) => user['name'] == userData['name'])) {
        // Set Event 5 points to 0
        await userDoc.reference.update({'Event 5 points': 0});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(
      leading: const Icon(Icons.bar_chart,color: Colors.white,),
      backgroundColor: Colors.black,
      title: const Text("Logotrix",style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 20)),
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
            //subtitle: Text('Guesses: ${user['Event 5 guesses'] ?? 0}'),
            trailing: Text('Points: ${user['Event 5 points'] ?? 0}'),
          );
        },
      ),
    );
  }
}
