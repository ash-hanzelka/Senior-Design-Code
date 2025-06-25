import 'package:flutter/material.dart';

class PlantsScreen extends StatefulWidget {
  const PlantsScreen({super.key});

  @override
  _PlantsScreenState createState() => _PlantsScreenState();
}

class Plant {
  final String name;
  final String scientificName;
  final String soilMoisture;
  final String temperature;
  final String humidity;
  final String lighting;

  Plant({
    required this.name,
    required this.scientificName,
    required this.soilMoisture,
    required this.temperature,
    required this.humidity,
    required this.lighting,
  });
}

final List<Plant> plantLibrary = [
  Plant(
    name: 'Snake Plant',
    scientificName: 'Sansevieria trifasciata',
    soilMoisture: 'Low (Let soil dry out completely between waterings)',
    temperature: '60–85°F (15–29°C)',
    humidity: 'Low to moderate',
    lighting: 'Indirect light to partial shade',
  ),
  Plant(
    name: 'Peace Lily',
    scientificName: 'Spathiphyllum wallisii',
    soilMoisture: 'Moderate (Keep soil lightly moist)',
    temperature: '65–80°F (18–27°C)',
    humidity: 'High',
    lighting: 'Bright, indirect light',
  ),
  Plant(
    name: 'Spider Plant',
    scientificName: 'Chlorophytum comosum',
    soilMoisture: 'Moderate (Water when top inch is dry)',
    temperature: '65–75°F (18–24°C)',
    humidity: 'Moderate to high',
    lighting: 'Bright, indirect sunlight',
  ),
];

class _PlantsScreenState extends State<PlantsScreen> {
  String _soilType = 'Normal';
  String _soilMoisture = 'Moist';
  double _waterNeeds = 0.5;
  final RangeValues _temperatureRange = RangeValues(65, 80);

  void _showAddPlantDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Add Plant',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(icon: Icon(Icons.edit), onPressed: () {}),
                          IconButton(
                            icon: Icon(Icons.bookmark_border),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),

                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Common Name *',
                      hintText: 'Enter common name',
                    ),
                  ),
                  SizedBox(height: 15),

                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Scientific Name (Optional)',
                      hintText: 'Enter scientific name',
                    ),
                  ),
                  SizedBox(height: 15),

                  InkWell(
                    onTap: () {},
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                          SizedBox(height: 10),
                          Text('Tap to upload a photo'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  Text(
                    'Soil Type',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      _buildSoilTypeOption('Acidic'),
                      SizedBox(width: 10),
                      _buildSoilTypeOption('Normal'),
                      SizedBox(width: 10),
                      _buildSoilTypeOption('Basic'),
                    ],
                  ),
                  SizedBox(height: 20),

                  Text(
                    'Soil Moisture',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      _buildSoilMoistureOption('Wet'),
                      SizedBox(width: 10),
                      _buildSoilMoistureOption('Moist'),
                      SizedBox(width: 10),
                      _buildSoilMoistureOption('Dry'),
                    ],
                  ),
                  SizedBox(height: 20),

                  Text(
                    'Water Needs',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: _waterNeeds,
                    onChanged: (value) {
                      setState(() {
                        _waterNeeds = value;
                      });
                    },
                    activeColor: Color(0xFF408661),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text('Low'), Text('Medium'), Text('High')],
                  ),
                  SizedBox(height: 20),

                  Text(
                    'Temperature Range',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Min °F',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text('to'),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Max °F',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF408661),
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Add Plant', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSoilTypeOption(String type) {
    bool isSelected = _soilType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _soilType = type;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Color(0xFF408661) : Colors.grey[300]!,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
            color:
                isSelected ? Color(0xFF408661).withOpacity(0.1) : Colors.white,
          ),
          child: Center(
            child: Text(
              type,
              style: TextStyle(
                color: isSelected ? Color(0xFF408661) : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSoilMoistureOption(String moisture) {
    bool isSelected = _soilMoisture == moisture;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _soilMoisture = moisture;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Color(0xFF408661) : Colors.grey[300]!,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
            color:
                isSelected ? Color(0xFF408661).withOpacity(0.1) : Colors.white,
          ),
          child: Center(
            child: Text(
              moisture,
              style: TextStyle(
                color: isSelected ? Color(0xFF408661) : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Plants'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Your plant library!',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),

            // Plant list would go here
            // ListView.builder(
            //   shrinkWrap: true,
            //   physics: NeverScrollableScrollPhysics(),
            //   itemCount: 3,
            //   itemBuilder: (context, index) {
            //     return ListTile(
            //       leading: CircleAvatar(
            //         backgroundColor: Colors.green[100],
            //         child: Icon(Icons.eco, color: Color(0xFF408661)),
            //       ),
            //       title: Text('Plant ${index + 1}'),
            //       subtitle: Text('Healthy condition'),
            //     );
            //   },
            // ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: plantLibrary.length,
              itemBuilder: (context, index) {
                final plant = plantLibrary[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green[100],
                    child: Icon(Icons.eco, color: Color(0xFF408661)),
                  ),
                  title: Text(plant.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Scientific Name: ${plant.scientificName}'),
                      Text('Soil Moisture: ${plant.soilMoisture}'),
                      Text('Temperature: ${plant.temperature}'),
                      Text('Humidity: ${plant.humidity}'),
                      Text('Lighting: ${plant.lighting}'),
                    ],
                  ),
                  isThreeLine: true,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF408661),
        onPressed: _showAddPlantDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
