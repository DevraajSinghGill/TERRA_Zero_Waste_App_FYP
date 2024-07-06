import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:terra_zero_waste_app/controllers/image_controller.dart';
import 'package:terra_zero_waste_app/models/group_task_model.dart';

class GroupCreateTaskScreen extends StatefulWidget {
  final String groupId;
  const GroupCreateTaskScreen({Key? key, required this.groupId})
      : super(key: key);

  @override
  _GroupCreateTaskScreenState createState() => _GroupCreateTaskScreenState();
}

class _GroupCreateTaskScreenState extends State<GroupCreateTaskScreen> {
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();
  bool _isLoading = false;
  String? selectedImage;

  final List<String> predefinedImages = [
    'lib/assets/images/gardening.jpg',
    'lib/assets/images/cleaning.jpg',
    'lib/assets/images/meal_plan.jpg',
    'lib/assets/images/green_vege.jpg',
    'lib/assets/images/carpool.jpg',
  ];

  void _createTask(BuildContext context) async {
    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    GroupTaskModel task = GroupTaskModel(
      taskId: '',
      groupId: widget.groupId,
      taskName: _taskNameController.text,
      description: _descriptionController.text,
      points: int.parse(_pointsController.text),
      imageUrl: selectedImage!,
    );

    await FirebaseFirestore.instance.collection('tasks').add(task.toMap());

    setState(() {
      _isLoading = false;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text('Select an Image:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              CarouselSlider.builder(
                options: CarouselOptions(
                  height: 200,
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.8,
                  enableInfiniteScroll: true,
                  enlargeCenterPage: true,
                  onPageChanged: (index, reason) {
                    setState(() {
                      selectedImage = predefinedImages[index];
                    });
                  },
                ),
                itemCount: predefinedImages.length,
                itemBuilder: (context, index, realIndex) {
                  return Container(
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selectedImage == predefinedImages[index]
                            ? Colors.blue
                            : Colors.grey,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:
                        Image.asset(predefinedImages[index], fit: BoxFit.cover),
                  );
                },
              ),
              SizedBox(height: 20),
              TextField(
                controller: _taskNameController,
                decoration: InputDecoration(labelText: 'Task Name'),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _pointsController,
                decoration: InputDecoration(labelText: 'Points'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () {
                        _createTask(context);
                      },
                      child: Text('Create Task'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
