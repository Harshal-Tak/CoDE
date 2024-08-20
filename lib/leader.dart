import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code/calcathon.dart';
import 'package:code/codehunt.dart';
import 'package:code/logotrix.dart';
import 'package:flutter/material.dart';
import 'package:code/codepong.dart';
import 'package:code/admad.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Leader extends StatefulWidget {
  const Leader({Key? key}) : super(key: key);

  @override
  State<Leader> createState() => _LeaderState();
}

class _LeaderState extends State<Leader> {
  final events = ['AD MAD','CODE PONG','CODE HUNT','CALC-A-THON','LOGOTRIX'];
  final pages = [AdMad(),CodePong(),CodeHunt(),Calcathon(),Logotrix()];
  bool isLoading = false;
  late String topUser = '';
  late int topPoints = 0;

  @override

  void initState() {
    super.initState();
    getTop();
  }

  void getTop() async{
    setState(() {
      isLoading = true;
    });
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').orderBy('Total points',descending: true).limit(1).get();
    if (querySnapshot.docs.isNotEmpty) {
      final topUserDoc = querySnapshot.docs.first;
      setState((){
        topUser = topUserDoc['name'];
        topPoints = topUserDoc['Total points'];
      });
    }
    setState(() {
      isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.man,color: Colors.white,),
        backgroundColor: Colors.black,
        title: const Text("Points",style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 20)),
      ),
      body: Column(
        children: [
          Container(
            height: 300,
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20),bottomRight: Radius.circular(20))),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(backgroundColor: Colors.black,radius: 40,child: Icon(Icons.laptop_windows_outlined,size: 40,)),
                  const SizedBox(height: 10,),
                  Text(topUser.toString(),style: TextStyle(fontSize: 46,fontWeight: FontWeight.w300,color: Colors.black)),
                  const Divider(thickness: 1,indent: 20,endIndent: 20,),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text("Top Points",style: TextStyle(fontSize: 30,fontWeight: FontWeight.w300,color: Colors.black)),
                        ],
                      ),
                      Column(
                        children: [
                          Text(topPoints.toString(),style: TextStyle(fontSize: 30,fontWeight: FontWeight.w300,color: Colors.black))
                        ],
                      )
                    ],
                  )
                ]
              ),
            ),
          ),
          const SizedBox(height: 10,),
          const Text("Events", style: TextStyle(fontSize: 20,fontWeight: FontWeight.w300,color: Colors.black)),
          Container(
            margin: const EdgeInsets.all(10),
            child: SizedBox(
              height: 300,
              child: ListView.separated(
                shrinkWrap: true,
              itemBuilder: (context,index){
                return ListTile(
                  title: Text("${events[index]}"),
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> pages[index]));
                  },
                );
              },
                  separatorBuilder: (context,index) => const Divider(), itemCount: 5),
            ),
          )
        ],
      )
    );
  }
}
