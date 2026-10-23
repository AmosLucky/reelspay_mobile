import 'package:flutter/material.dart';

class Introduction extends StatefulWidget {
  const Introduction({super.key});

  @override
  State<Introduction> createState() => _IntroductionState();
}

class _IntroductionState extends State<Introduction> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('Introduction page'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){},
        child: Icon(Icons.add),
        ),

      body: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('data'),
            Icon(Icons.home),
            Container(
              height: 200,
              width: 300,
              color: Colors.red,
              child: Row(
                children: [
                  Icon(Icons.favorite),
                  Icon(Icons.favorite),
                  Icon(Icons.favorite),
                  Icon(Icons.favorite),
                ],
              ),
            ),
            MaterialButton(
              onPressed: () {},
              color: Colors.blueAccent,
              child: Text('Click me'),
            ),

            Container(
              height: 100,
              width: 100,
              color: Colors.yellow,
              margin: EdgeInsets.only(top: 20),
            ),

            Container(
              color: Colors.purple,
              margin: EdgeInsets.only(top: 20),
              padding: EdgeInsets.symmetric(vertical: 10),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround ,
                children: [
              
                  Icon(Icons.home),
                  Icon(Icons.contact_emergency),
                  Icon(Icons.favorite),
                  Icon(Icons.menu),
                   Icon(Icons.face),
              
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
