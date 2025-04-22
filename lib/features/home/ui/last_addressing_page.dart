import 'package:flutter/material.dart';

class LastAddressingPage extends StatelessWidget {
  const LastAddressingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Card(
                child: SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('------------'),
                      SizedBox(
                        height: 10,
                      ),
                      Text('---------------'),
                      Text('-----------------------'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                child: SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('------------'),
                      SizedBox(
                        height: 10,
                      ),
                      Text('---------------'),
                      Text('-----------------------'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                child: SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('------------'),
                      SizedBox(
                        height: 10,
                      ),
                      Text('---------------'),
                      Text('-----------------------'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                child: SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('------------'),
                      SizedBox(
                        height: 10,
                      ),
                      Text('---------------'),
                      Text('-----------------------'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'العنوان الاخير',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
