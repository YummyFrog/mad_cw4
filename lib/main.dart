import 'package:flutter/material.dart';

void main() {
  runApp(const TravelPlansApp());
}

class TravelPlansApp extends StatelessWidget {
  const TravelPlansApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Plans',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TravelPlansHomePage(),
    );
  }
}

class TravelPlansHomePage extends StatefulWidget {
  const TravelPlansHomePage({super.key});

  @override
  State<TravelPlansHomePage> createState() => _TravelPlansHomePageState();
}

class _TravelPlansHomePageState extends State<TravelPlansHomePage> {
  final List<Map<String, String>> travelPlans = [
    {
      'destination': 'Paris',
      'date': '2023-12-01',
      'description': 'visit'
    },
    {
      'destination': 'Tokyo',
      'date': '2024-01-15',
      'description': 'visit'
    },
    {
      'destination': 'New York',
      'date': '2024-03-10',
      'description': 'visit'
    },
    {
      'destination': 'Sydney',
      'date': '2024-05-20',
      'description': 'visit.'
    },
    {
      'destination': 'Cape Town',
      'date': '2024-07-05',
      'description': 'visit.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Plans'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: travelPlans.length,
        itemBuilder: (context, index) {
          final plan = travelPlans[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(plan['destination']!),
              subtitle: Text('${plan['date']}\n${plan['description']}'),
              leading: const Icon(Icons.flight_takeoff),
              onTap: () {
              },
            ),
          );
        },
      ),
    );
  }
}