// Import necessary packages
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Users extends StatefulWidget {
  const Users({Key? key}) : super(key: key);

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  List<Map<String, dynamic>> userList = [];
  bool isLoading = false;
  String? selectedDepartment;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _points1Controller = TextEditingController();
  final TextEditingController _points2Controller = TextEditingController();
  final TextEditingController _points3Controller = TextEditingController();
  final TextEditingController _points4Controller = TextEditingController();
  final TextEditingController _points5Controller = TextEditingController();
  final TextEditingController _guessController = TextEditingController();
  final TextEditingController _correctController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _time2Controller = TextEditingController();

  final List<String> departments = ['AIDS', 'AIML', 'COMP', 'ECE', 'ELEC', 'ENTC', 'IT', 'MECH']; // Your department options

  String? selectedUserId;

  @override
  void initState() {
    super.initState();
    createUsersCollectionIfNotExists();
    getUsersList();
  }

  void createUsersCollectionIfNotExists() async {
    bool usersCollectionExists = false;
    await _firestore.collection('users').limit(1).get().then((querySnapshot) {
      usersCollectionExists = querySnapshot.docs.isNotEmpty;
    }).catchError((error) {
      print("Error checking for 'users' collection: $error");
    });

    if (!usersCollectionExists) {
      await _firestore.collection('users').doc('placeholder').set({'placeholder': 'data'}).then((_) {
        print("'users' collection created successfully");
      }).catchError((error) {
        print("Error creating 'users' collection: $error");
      });
    }
  }

  void getUsersList() async {
    setState(() {
      isLoading = true;
    });

    QuerySnapshot querySnapshot = await _firestore.collection('users').get();

    setState(() {
      userList = querySnapshot.docs.map((doc) => {...(doc.data() as Map<String, dynamic>), 'id': doc.id}).toList();
      isLoading = false;
    });
  }

  void addUser() async {
    // Check if the name is already taken
    bool isNameTaken = userList.any((user) => user['name'] == _nameController.text);

    if (isNameTaken) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Name Already Exists'),
            content: Text('The name "${_nameController.text}" is already taken. Please choose a different name.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return; // Exit the method
    }

    // Proceed with adding the user if the name is not taken
    int totalPoints = _calculateTotalPoints();

    await _firestore.collection('users').add({
      'name': _nameController.text,
      'department': selectedDepartment ?? '',
      'Event 1 points': int.tryParse(_points1Controller.text) ?? 0,
      'Event 2 points': int.tryParse(_points2Controller.text) ?? 0,
      'Event 3 points': int.tryParse(_points3Controller.text) ?? 0,
      'Event 4 points': int.tryParse(_points4Controller.text) ?? 0,
      'Event 5 points': int.tryParse(_points5Controller.text) ?? 0,
      'Event 5 guesses': int.tryParse(_guessController.text)??0,
      'Event 4 correct': int.tryParse(_correctController.text) ?? 0,
      'Event 4 time': int.tryParse(_timeController.text) ?? 0,
      'Event 3 time': int.tryParse(_time2Controller.text)??0,
      'Total points': totalPoints,
    });

    _clearTextFields();
    Navigator.pop(context);

    getUsersList();// Close the bottom sheet after adding user
  }

  void updateUser() async {
    int totalPoints = _calculateTotalPoints();

    await _firestore.collection('users').doc(selectedUserId).update({
      'name': _nameController.text,
      'department': selectedDepartment, // Set department here
      'Event 1 points': int.tryParse(_points1Controller.text) ?? 0,
      'Event 2 points': int.tryParse(_points2Controller.text) ?? 0,
      'Event 3 points': int.tryParse(_points3Controller.text) ?? 0,
      'Event 4 points': int.tryParse(_points4Controller.text) ?? 0,
      'Event 5 points': int.tryParse(_points5Controller.text) ?? 0,
      'Event 5 guesses': int.tryParse(_guessController.text) ?? 0,
      'Event 4 correct': int.tryParse(_correctController.text) ?? 0,
      'Event 4 time': int.tryParse(_timeController.text) ?? 0,
      'Event 3 time': int.tryParse(_time2Controller.text) ?? 0,
      'Total points': totalPoints,
    });

    _clearTextFields();
    Navigator.pop(context);
    getUsersList();// Close the bottom sheet after updating user
  }

  void deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
    getUsersList();
  }

  int _calculateTotalPoints() {
    int total = 0;
    total += int.tryParse(_points1Controller.text) ?? 0;
    total += int.tryParse(_points2Controller.text) ?? 0;
    total += int.tryParse(_points3Controller.text) ?? 0;
    total += int.tryParse(_points4Controller.text) ?? 0;
    total += int.tryParse(_points5Controller.text) ?? 0;
    return total;
  }

  void updatePointsForAllUsers() async {
    // Iterate through each user
    for (var user in userList) {
      print("hii");
      num totalEventPoints = 0;
      totalEventPoints += user['Event 1 points'] ?? 0;
      totalEventPoints += user['Event 2 points'] ?? 0;
      totalEventPoints += user['Event 3 points'] ?? 0;
      totalEventPoints += user['Event 4 points'] ?? 0;
      totalEventPoints += user['Event 5 points'] ?? 0;
      print('$totalEventPoints');
      await _firestore.collection('users').doc(user['id']).update({
        'Event 1 points': user['Event 1 points'],
        'Event 2 points': user['Event 2 points'],
        'Event 3 points': user['Event 3 points'],
        'Event 4 points': user['Event 4 points'],
        'Event 5 points': user['Event 5 points'],
        'Event 5 guesses': user['Event 5 guesses'],
        'Event 4 correct': user['Event 4 correct'],
        'Event 4 time': user['Event 4 time'],
        'Event 3 time': user['Event 3 time'],
        'Total points': totalEventPoints,
      });
    }

    // Refresh user list after updating all users
    getUsersList();
  }

  void _clearTextFields() {
    _nameController.clear();
    _points1Controller.clear();
    _points2Controller.clear();
    _points3Controller.clear();
    _points4Controller.clear();
    _points5Controller.clear();
    _guessController.clear();
    _correctController.clear();
    _timeController.clear();
    _time2Controller.clear();
    selectedUserId = null;
    selectedDepartment = null; // Clear selected department
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: Icon(Icons.person, color: Colors.white),
        title: Text(
          'Participants',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300, color: Colors.white),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          SizedBox(height: size.height / 20),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: userList.length,
              itemBuilder: (context, index) {
                final user = userList[index];
                return Dismissible(
                  key: Key(user['id'].toString()),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Confirm"),
                          content: Text("Are you sure you want to delete ${user['name']}?"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text("DELETE"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text("CANCEL"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) {
                    deleteUser(user['id']);
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    title: Text(user['name'] ?? ''),
                    subtitle: Text(user['department'] ?? ''),
                    trailing: Text('${user['Total points'] ?? ''} Total'),
                    onTap: () {
                      setState(() {
                        selectedUserId = user['id'];
                        _nameController.text = user['name'] ?? '';
                        _points1Controller.text = '${user['Event 1 points'] ?? 0}';
                        _points2Controller.text = '${user['Event 2 points'] ?? 0}';
                        _points3Controller.text = '${user['Event 3 points'] ?? 0}';
                        _points4Controller.text = '${user['Event 4 points'] ?? 0}';
                        _points5Controller.text = '${user['Event 5 points'] ?? 0}';
                        _guessController.text = '${user['Event 5 guesses'] ?? 0}';
                        _correctController.text = '${user['Event 4 correct'] ?? 0}';
                        _timeController.text = '${user['Event 4 time'] ?? 0}';
                        _time2Controller.text = '${user['Event 3 time'] ?? 0}';
                        selectedDepartment = user['department'];
                      });
                    },
                  ),
                );
              },
            ),

          ),
          ElevatedButton(
            onPressed: updatePointsForAllUsers,
            child: Text('Update Points for All Users'),)
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: 'Name'),
                      ),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Department'),
                        value: selectedDepartment,
                        onChanged: (value) {
                          setState(() {
                            selectedDepartment = value;
                          });
                        },
                        items: departments.map((department) {
                          return DropdownMenuItem<String>(
                            value: department,
                            child: Text(department),
                          );
                        }).toList(),
                      ),
                      TextField(
                        controller: _points1Controller,
                        decoration: InputDecoration(labelText: 'AD MAD'),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: _points2Controller,
                        decoration: InputDecoration(labelText: 'CODE PONG'),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: _points3Controller,
                        decoration: InputDecoration(labelText: 'CODE HUNT'),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: _points4Controller,
                        decoration: InputDecoration(labelText: 'CALCATHON'),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: _points5Controller,
                        decoration: InputDecoration(labelText: 'LOGOTRIX'),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: _guessController,
                        decoration: InputDecoration(labelText: 'Logo Guesses'),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: _correctController,
                        decoration: InputDecoration(labelText: 'Calcathon Correct'),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: _timeController,
                        decoration: InputDecoration(labelText: 'Calcathon Time'),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: _time2Controller,
                        decoration: InputDecoration(labelText: 'Code Hunt Time'),
                        keyboardType: TextInputType.number,
                      ),
                      ElevatedButton(
                        onPressed: selectedUserId != null ? updateUser : addUser,
                        child: Text(selectedUserId != null ? 'Update User' : 'Add User'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
