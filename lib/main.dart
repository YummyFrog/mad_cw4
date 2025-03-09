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
                      onPlanReordered: (newPlans) {
                        setState(() {
                          folder.plans = newPlans;
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
  final Function(Map<String, dynamic>) onPlanAdded;
  final Function(List<Map<String, dynamic>>) onPlanReordered;

  const FolderDetailsPage({
    super.key,
    required this.folder,
    required this.onPlanAdded,
    required this.onPlanReordered,
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
                  'completed': false, // Track completion status
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
      body: ReorderableListView.builder(
        itemCount: widget.folder.plans.length,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }
            final plan = widget.folder.plans.removeAt(oldIndex);
            widget.folder.plans.insert(newIndex, plan);
            widget.onPlanReordered(widget.folder.plans); // Notify parent of reorder
          });
        },
        itemBuilder: (context, index) {
          final plan = widget.folder.plans[index];
          return Card(
            key: ValueKey(plan), // Unique key for each item
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(
                plan['destination']!,
                style: TextStyle(
                  decoration: plan['completed'] == true
                      ? TextDecoration.lineThrough // Strikethrough for completed plans
                      : TextDecoration.none,
                ),
              ),
              subtitle: Text('Date: ${plan['date']}'),
              leading: const Icon(Icons.flight_takeoff),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCheckButton(plan), // Check button
                  const SizedBox(width: 8), // Spacing between buttons
                  _buildTrashButton(plan), // Trash button
                  const SizedBox(width: 8), // Spacing between buttons
                  _buildDragHandle(), // Drag handle
                ],
              ),
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

  // Check button to mark a plan as completed
  Widget _buildCheckButton(Map<String, dynamic> plan) {
    return IconButton(
      icon: Icon(
        plan['completed'] == true ? Icons.check_circle : Icons.check_circle_outline,
        color: plan['completed'] == true ? Colors.green : Colors.grey,
      ),
      onPressed: () {
        setState(() {
          plan['completed'] = !(plan['completed'] ?? false); // Toggle completion status
        });
      },
    );
  }

  // Trash button to delete a plan
  Widget _buildTrashButton(Map<String, dynamic> plan) {
    return IconButton(
      icon: const Icon(Icons.delete, color: Colors.red),
      onPressed: () {
        setState(() {
          widget.folder.plans.remove(plan); // Remove the plan from the list
        });
      },
    );
  }

  // Drag handle with a single line
  Widget _buildDragHandle() {
    return GestureDetector(
      onTap: () {}, // Prevent accidental taps
      child: MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: Container(
          width: 40, // Larger hitbox
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[200], // Light background
            borderRadius: BorderRadius.circular(8), // Rounded corners
          ),
          child: const Icon(
            Icons.drag_handle, // Single-line drag handle
            color: Colors.grey, // Neutral color
          ),
        ),
      ),
    );
  }
}

class Folder {
  String name;
  List<Map<String, dynamic>> plans;

  Folder({required this.name, required this.plans});
}