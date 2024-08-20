import 'package:code/score.dart';
import 'package:code/users.dart';
import 'package:flutter/material.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'leader.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CoDE App',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        pageTransitionsTheme: const PageTransitionsTheme(builders:{TargetPlatform.android: ZoomPageTransitionsBuilder(),}),
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(height: 80),
            const CircleAvatar(
              radius: 100,
              //foregroundImage: AssetImage('CoDE.png'),
              child: Text('NEURON',style:TextStyle(color: Colors.black,fontSize: 40,fontWeight: FontWeight.w400)),
            ),
            const Text(
              '2.0',
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 30,color:Colors.white,),
            ),
            const SizedBox(height: 50),
            Container(
              width: 200,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyHomePage()),
                  );
                }, child: const Text("START",style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
            const Text("By Team CoDE",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold, color: Colors.white),),
          ]
        )
      )
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentPageIndex = 0;

  void _setBottomBarIndex(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SnakeNavigationBar.color(
        behaviour: SnakeBarBehaviour.floating,
        snakeShape: SnakeShape.rectangle,
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        snakeViewColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        currentIndex: _currentPageIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Score'),
        ],
        onTap: _setBottomBarIndex,
      ),
      body: _getPage(_currentPageIndex),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
    case 0:
    return Leader();
    case 1:
    return Users();
    case 2:
    return ScoreBoard();
    default:
    return Leader(); // Or any default widget
    }
  }
}
