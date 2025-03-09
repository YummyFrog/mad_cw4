import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _createFolder,
            tooltip: 'Create Folder',
            child: const Icon(Icons.create_new_folder),
          ),
          const SizedBox(height: 16), // Spacing between buttons
          FloatingActionButton(
            onPressed: () {
              // Navigate to the calendar screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CalendarScreen(folders: folders),
                ),
              );
            },
            tooltip: 'View Calendar',
            child: const Icon(Icons.calendar_today),
          ),
        ],
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
  void _addTravelPlan(BuildContext context) async {
    TextEditingController destinationController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    DateTime? selectedDate;

    // Show date picker
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Default to today's date
      firstDate: DateTime(2023), // Earliest allowed date
      lastDate: DateTime(2025, 12, 31), // Latest allowed date
    );

    if (date == null) return; // User canceled date selection

    selectedDate = date;

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
                controller: descriptionController,
                decoration: const InputDecoration(hintText: 'Enter description'),
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
                  'id': DateTime.now().millisecondsSinceEpoch.toString(), // Unique ID
                  'destination': destinationController.text,
                  'date': selectedDate!.toIso8601String(), // Store date as ISO string
                  'description': descriptionController.text,
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
          return Dismissible(
            key: ValueKey(plan['id']), // Unique key for each item
            background: Container(
              color: Colors.green,
              alignment: Alignment.centerLeft,
              child: const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Icon(Icons.check, color: Colors.white),
              ),
            ),
            secondaryBackground: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              child: const Padding(
                padding: EdgeInsets.only(right: 20),
                child: Icon(Icons.delete, color: Colors.white),
              ),
            ),
            onDismissed: (direction) {
              setState(() {
                widget.folder.plans.removeAt(index);
              });
            },
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                // Swipe to mark as completed
                setState(() {
                  plan['completed'] = true;
                });
                return false; // Do not dismiss
              } else {
                // Swipe to delete
                return true; // Dismiss
              }
            },
            child: GestureDetector(
              onLongPress: () {
                _editPlan(context, plan);
              },
              onDoubleTap: () {
                setState(() {
                  widget.folder.plans.removeAt(index);
                });
              },
              child: Card(
                key: ValueKey(plan['id']), // Unique key for each item
                margin: const EdgeInsets.all(8.0),
                color: plan['completed'] == true ? Colors.green[100] : Colors.blue[100],
                child: ListTile(
                  title: Text(
                    plan['destination']!,
                    style: TextStyle(
                      decoration: plan['completed'] == true
                          ? TextDecoration.lineThrough // Strikethrough for completed plans
                          : TextDecoration.none,
                    ),
                  ),
                  subtitle: Text('Date: ${plan['date']}\nDescription: ${plan['description']}'),
                  leading: const Icon(Icons.flight_takeoff),
                  trailing: _buildDragHandle(), // Drag handle
                ),
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

  // Edit plan details
  void _editPlan(BuildContext context, Map<String, dynamic> plan) async {
    TextEditingController destinationController = TextEditingController(text: plan['destination']);
    TextEditingController descriptionController = TextEditingController(text: plan['description']);
    DateTime? selectedDate = DateTime.tryParse(plan['date']);

    // Show date picker
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(), // Default to the plan's date or today's date
      firstDate: DateTime(2023), // Earliest allowed date
      lastDate: DateTime(2025, 12, 31), // Latest allowed date
    );

    if (date == null) return; // User canceled date selection

    selectedDate = date;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: destinationController,
                decoration: const InputDecoration(hintText: 'Enter destination'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(hintText: 'Enter description'),
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
                setState(() {
                  plan['destination'] = destinationController.text;
                  plan['date'] = selectedDate!.toIso8601String(); // Update date
                  plan['description'] = descriptionController.text;
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
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

class CalendarScreen extends StatelessWidget {
  final List<Folder> folders;

  const CalendarScreen({super.key, required this.folders});

  @override
  Widget build(BuildContext context) {
    // Combine all plans from all folders
    final allPlans = folders.expand((folder) => folder.plans).toList();

    // Group plans by date
    final Map<DateTime, List<Map<String, dynamic>>> events = {};
    for (final plan in allPlans) {
      final date = DateTime.parse(plan['date']).toUtc();
      if (events[date] == null) {
        events[date] = [];
      }
      events[date]!.add(plan);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: TableCalendar(
        firstDay: DateTime.utc(2023, 1, 1), // Start of the calendar range
        lastDay: DateTime.utc(2025, 12, 31), // End of the calendar range
        focusedDay: DateTime.now(), // Default to today's date
        eventLoader: (date) {
          return events[date] ?? [];
        },
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isNotEmpty) {
              return Positioned(
                right: 1,
                bottom: 1,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${events.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              );
            }
            return null;
          },
        ),
        onDaySelected: (selectedDay, focusedDay) {
          final plansForDay = events[selectedDay] ?? [];
          if (plansForDay.isNotEmpty) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Plans for ${selectedDay.toLocal()}'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: plansForDay.map((plan) {
                      return ListTile(
                        title: Text(plan['destination']!),
                        subtitle: Text('Description: ${plan['description']}'),
                      );
                    }).toList(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Close'),
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}

class Folder {
  String name;
  List<Map<String, dynamic>> plans;

  Folder({required this.name, required this.plans});
}