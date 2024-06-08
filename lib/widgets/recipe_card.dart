// import 'package:flutter/material.dart';

// class RecipeCard extends StatefulWidget {
//   final String name;
//   final String description;
//   final String imagePath;
//   final int prepTime;
//   final int cookTime;
//   final String cuisine;
//   final int spiceLevel;
//   final String course;
//   final int servings;
//   final List<String> keyWords;
//   final List<String> steps;
//   final List<String> appliances;
//   final List<Map<String, dynamic>> ingredients;

//   RecipeCard({
//     required this.name,
//     required this.description,
//     required this.imagePath,
//     required this.prepTime,
//     required this.cookTime,
//     required this.cuisine,
//     required this.spiceLevel,
//     required this.course,
//     required this.servings,
//     required this.keyWords,
//     required this.steps,
//     required this.appliances,
//     required this.ingredients,
//   });

//   @override
//   _RecipeCardState createState() => _RecipeCardState();
// }

// class _RecipeCardState extends State<RecipeCard> {
//   bool _hovered = false;

//   void _onHover(bool hovering) {
//     setState(() {
//       _hovered = hovering;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double fontSizeTitle = screenWidth * 0.02;
//     double fontSizeDescription = screenWidth * 0.01;

//     return MouseRegion(
//       onEnter: (_) => _onHover(true),
//       onExit: (_) => _onHover(false),
//       child: Stack(
//         children: [
//           Positioned.fill(
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(10),
//               child: Image.asset(
//                 widget.imagePath,
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           if (_hovered)
//             Positioned.fill(
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Color.fromARGB(255, 103, 128, 96).withOpacity(0.8),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),
//           if (_hovered)
//             Positioned.fill(
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       widget.name,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: fontSizeTitle,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       widget.description,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: fontSizeDescription,
//                       ),
//                     ),
//                     SizedBox(height: 16),
//                     Row(
//                       children: [
//                         Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Prep Time:',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: fontSizeDescription,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             SizedBox(height: 4),
//                             Text(
//                               '${widget.prepTime} mins',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: fontSizeDescription,
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(width: 10), // Add spacing between elements
//                         Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Cook Time:',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: fontSizeDescription,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             SizedBox(height: 4),
//                             Text(
//                               '${widget.cookTime} mins',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: fontSizeDescription,
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(width: 10), // Add spacing between elements
//                         Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Total Time:',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: fontSizeDescription,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             SizedBox(height: 4),
//                             Text(
//                               '${widget.prepTime + widget.cookTime} mins',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: fontSizeDescription,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                     Text(
//                       'Cuisine: ${widget.cuisine}',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: fontSizeDescription,
//                       ),
//                     ),
//                     Text(
//                       'Spice Level: ${widget.spiceLevel}',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: fontSizeDescription,
//                       ),
//                     ),
//                     Text(
//                       'Course: ${widget.course}',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: fontSizeDescription,
//                       ),
//                     ),
//                     Text(
//                       'Servings: ${widget.servings}',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: fontSizeDescription,
//                       ),
//                     ),
//                     Text(
//                       'Keywords: ${widget.keyWords.join(', ')}',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: fontSizeDescription,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

class RecipeCard extends StatefulWidget {
  final String name;
  final String description;
  final String imagePath;
  final int prepTime;
  final int cookTime;
  final String cuisine;
  final int spiceLevel;
  final String course;
  final int servings;
  final List<String> keyWords;
  final List<String> steps;
  final List<String> appliances;
  final List<Map<String, dynamic>> ingredients;

  RecipeCard({
    required this.name,
    required this.description,
    required this.imagePath,
    required this.prepTime,
    required this.cookTime,
    required this.cuisine,
    required this.spiceLevel,
    required this.course,
    required this.servings,
    required this.keyWords,
    required this.steps,
    required this.appliances,
    required this.ingredients,
  });

  @override
  _RecipeCardState createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  bool _hovered = false;
  Map<int, bool> _ingredientChecked = {};

  void _onHover(bool hovering) {
    setState(() {
      _hovered = hovering;
    });
  }

  void _showRecipeDetails() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.description),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Text('Prep Time: ${widget.prepTime} mins'),
                              SizedBox(width: 10),
                              Text('Cook Time: ${widget.cookTime} mins'),
                              SizedBox(width: 10),
                              Text('Total Time: ${widget.prepTime + widget.cookTime} mins'),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text('Cuisine: ${widget.cuisine}'),
                          Text('Spice Level: ${widget.spiceLevel}'),
                          Text('Course: ${widget.course}'),
                          Text('Servings: ${widget.servings}'),
                          Text('Keywords: ${widget.keyWords.join(', ')}'),
                          SizedBox(height: 20),
                          Text('Ingredients:', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          ...widget.ingredients.asMap().entries.map((entry) {
                            int idx = entry.key;
                            Map<String, dynamic> ingredient = entry.value;
                            return CheckboxListTile(
                              title: Text('${ingredient['quantity']} ${ingredient['unit']} ${ingredient['ingredient']}'),
                              value: _ingredientChecked[idx] ?? false,
                              onChanged: (bool? value) {
                                setState(() {
                                  _ingredientChecked[idx] = value ?? false;
                                });
                              },
                            );
                          }).toList(),
                          SizedBox(height: 20),
                          Text('Steps:', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          ...widget.steps.map((step) => Text(step)).toList(),
                          SizedBox(height: 20),
                          Text('Appliances:', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          ...widget.appliances.map((appliance) => Text(appliance)).toList(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSizeTitle = screenWidth * 0.02;
    double fontSizeDescription = screenWidth * 0.01;

    return GestureDetector(
      onTap: _showRecipeDetails,
      child: MouseRegion(
        onEnter: (_) => _onHover(true),
        onExit: (_) => _onHover(false),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  widget.imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            if (_hovered)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 103, 128, 96).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            if (_hovered)
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSizeTitle,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        widget.description,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSizeDescription,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Prep Time:',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: fontSizeDescription,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${widget.prepTime} mins',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: fontSizeDescription,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 10), // Add spacing between elements
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cook Time:',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: fontSizeDescription,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${widget.cookTime} mins',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: fontSizeDescription,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 10), // Add spacing between elements
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Time:',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: fontSizeDescription,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${widget.prepTime + widget.cookTime} mins',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: fontSizeDescription,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        'Cuisine: ${widget.cuisine}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSizeDescription,
                        ),
                      ),
                      Text(
                        'Spice Level: ${widget.spiceLevel}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSizeDescription,
                        ),
                      ),
                      Text(
                        'Course: ${widget.course}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSizeDescription,
                        ),
                      ),
                      Text(
                        'Servings: ${widget.servings}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSizeDescription,
                        ),
                      ),
                      Text(
                        'Keywords: ${widget.keyWords.join(', ')}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSizeDescription,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

