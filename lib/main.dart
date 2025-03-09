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
  // List to hold folders
  final List<Folder> folders = [];

  // Function to show a dialog to create a new folder
  void _createFolder() {
    TextEditingController folderNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Folder'),
          content: TextField(
            controller: folderNameController,
            decoration: const InputDecoration(hintText: 'Enter folder name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  folders.add(Folder(name: folderNameController.text, plans: []));
                });
                Navigator.pop(context);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Plans'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: folders.length,
        itemBuilder: (context, index) {
          final folder = folders[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(folder.name),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                // Navigate to the folder's travel plans page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FolderDetailsPage(
                      folder: folder,
                      onPlanAdded: (plan) {
                        setState(() {
                          folder.plans.add(plan);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createFolder,
        tooltip: 'Create Folder',
        child: const Icon(Icons.create_new_folder),
      ),
    );
  }
}

class FolderDetailsPage extends StatefulWidget {
  final Folder folder;
  final Function(Map<String, String>) onPlanAdded;

  const FolderDetailsPage({
    super.key,
    required this.folder,
    required this.onPlanAdded,
  });

  @override
  State<FolderDetailsPage> createState() => _FolderDetailsPageState();
}

class _FolderDetailsPageState extends State<FolderDetailsPage> {
  // Function to show a dialog to add a new travel plan
  void _addTravelPlan(BuildContext context) {
    TextEditingController destinationController = TextEditingController();
    TextEditingController dateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Travel Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: destinationController,
                decoration: const InputDecoration(hintText: 'Enter destination'),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(hintText: 'Enter date (e.g., 2023-12-01)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final plan = {
                  'destination': destinationController.text,
                  'date': dateController.text,
                  'description': 'Travel plan to ${destinationController.text} on ${dateController.text}',
                };
                widget.onPlanAdded(plan);
                setState(() {}); // Force rebuild to show the new plan
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: widget.folder.plans.length,
        itemBuilder: (context, index) {
          final plan = widget.folder.plans[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(plan['destination']!),
              subtitle: Text('Date: ${plan['date']}'),
              leading: const Icon(Icons.flight_takeoff),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTravelPlan(context),
        tooltip: 'Add Travel Plan',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Folder {
  String name;
  List<Map<String, String>> plans;

  Folder({required this.name, required this.plans});
}