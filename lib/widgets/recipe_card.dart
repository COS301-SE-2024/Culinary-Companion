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
//   Map<int, bool> _ingredientChecked = {};

//   void _onHover(bool hovering) {
//     setState(() {
//       _hovered = hovering;
//     });
//   }

//   void _showRecipeDetails() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Container(
//             width: MediaQuery.of(context).size.width * 0.8,
//             height: MediaQuery.of(context).size.height * 0.8,
//             padding: EdgeInsets.all(20),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       widget.name,
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.close),
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 10),
//                 Expanded(
//                   child: Scrollbar(
//                     thumbVisibility: true,
//                     child: SingleChildScrollView(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(widget.description),
//                           SizedBox(height: 10),
//                           Row(
//                             children: [
//                               Text('Prep Time: ${widget.prepTime} mins'),
//                               SizedBox(width: 10),
//                               Text('Cook Time: ${widget.cookTime} mins'),
//                               SizedBox(width: 10),
//                               Text(
//                                   'Total Time: ${widget.prepTime + widget.cookTime} mins'),
//                             ],
//                           ),
//                           SizedBox(height: 10),
//                           Text('Cuisine: ${widget.cuisine}'),
//                           Text('Spice Level: ${widget.spiceLevel}'),
//                           Text('Course: ${widget.course}'),
//                           Text('Servings: ${widget.servings}'),
//                           Text('Keywords: ${widget.keyWords.join(', ')}'),
//                           SizedBox(height: 20),
//                           Text('Ingredients:',
//                               style: TextStyle(fontWeight: FontWeight.bold)),
//                           SizedBox(height: 10),
//                           ...widget.ingredients.asMap().entries.map((entry) {
//                             int idx = entry.key;
//                             Map<String, dynamic> ingredient = entry.value;
//                             return CheckboxListTile(
//                               title: Text(
//                                   '${ingredient['quantity']} ${ingredient['unit']} ${ingredient['ingredient']}'),
//                               value: _ingredientChecked[idx] ?? false,
//                               onChanged: (bool? value) {
//                                 setState(() {
//                                   _ingredientChecked[idx] = value ?? false;
//                                 });
//                               },
//                             );
//                           }).toList(),
//                           SizedBox(height: 20),
//                           Text('Steps:',
//                               style: TextStyle(fontWeight: FontWeight.bold)),
//                           SizedBox(height: 10),
//                           ...widget.steps.map((step) => Text(step)).toList(),
//                           SizedBox(height: 20),
//                           Text('Appliances:',
//                               style: TextStyle(fontWeight: FontWeight.bold)),
//                           SizedBox(height: 10),
//                           ...widget.appliances
//                               .map((appliance) => Text(appliance))
//                               .toList(),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double fontSizeTitle = screenWidth * 0.02;
//     double fontSizeDescription = screenWidth * 0.01;

//     return GestureDetector(
//       onTap: _showRecipeDetails,
//       child: MouseRegion(
//         onEnter: (_) => _onHover(true),
//         onExit: (_) => _onHover(false),
//         child: Stack(
//           children: [
//             Positioned.fill(
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(10),
//                 child: Image.asset(
//                   widget.imagePath,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             if (_hovered)
//               Positioned.fill(
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Color.fromARGB(255, 103, 128, 96).withOpacity(0.8),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               ),
//             if (_hovered)
//               Positioned.fill(
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         widget.name,
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: fontSizeTitle,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       SizedBox(height: 8),
//                       Text(
//                         widget.description,
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: fontSizeDescription,
//                         ),
//                       ),
//                       SizedBox(height: 16),
//                       Row(
//                         children: [
//                           Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Prep Time:',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: fontSizeDescription,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               SizedBox(height: 4),
//                               Text(
//                                 '${widget.prepTime} mins',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: fontSizeDescription,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(width: 10), // Add spacing between elements
//                           Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Cook Time:',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: fontSizeDescription,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               SizedBox(height: 4),
//                               Text(
//                                 '${widget.cookTime} mins',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: fontSizeDescription,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(width: 10), // Add spacing between elements
//                           Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Total Time:',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: fontSizeDescription,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               SizedBox(height: 4),
//                               Text(
//                                 '${widget.prepTime + widget.cookTime} mins',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: fontSizeDescription,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                       Text(
//                         'Cuisine: ${widget.cuisine}',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: fontSizeDescription,
//                         ),
//                       ),
//                       Text(
//                         'Spice Level: ${widget.spiceLevel}',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: fontSizeDescription,
//                         ),
//                       ),
//                       Text(
//                         'Course: ${widget.course}',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: fontSizeDescription,
//                         ),
//                       ),
//                       Text(
//                         'Servings: ${widget.servings}',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: fontSizeDescription,
//                         ),
//                       ),
//                       Text(
//                         'Keywords: ${widget.keyWords.join(', ')}',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: fontSizeDescription,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//           ],
//         ),
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
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            final double screenWidth = MediaQuery.of(context).size.width;
            final bool showImage =
                screenWidth > 1359; // Adjust the threshold as needed

            return Dialog(
              backgroundColor: Color.fromARGB(
                  255, 25, 58, 48), // Change background color to green
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.01),
              ),
              child: Container(
                width: screenWidth * 0.6, // Set width to 60% of screen width
                height: MediaQuery.of(context).size.height *
                    0.8, // Set height to 80% of screen height
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height *
                      0.04, // Adjust top padding to 4% of screen height
                  left: screenWidth *
                      0.05, // Adjust left padding to 5% of screen width
                  right: screenWidth *
                      0.05, // Adjust right padding to 5% of screen width
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: screenWidth *
                              0.4, // Adjust text width to 40% of screen width
                          child: Text(
                            widget.name,
                            style: TextStyle(
                              fontSize: screenWidth *
                                  0.02, // Adjust font size to 2% of screen width
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          iconSize: screenWidth *
                              0.02, // Adjust icon size to 2% of screen width
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height *
                            0.01), // Adjust height to 1% of screen height
                    Expanded(
                      child: SingleChildScrollView(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.description),
                                  SizedBox(
                                      height: MediaQuery.of(context)
                                              .size
                                              .height *
                                          0.01), // Adjust height to 1% of screen height
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Prep Time:',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text('${widget.prepTime} mins'),
                                        ],
                                      ),
                                      SizedBox(
                                        width: screenWidth *
                                            0.02, // 2% of screen width
                                      ),
                                      VerticalDivider(
                                        color: Colors
                                            .black, // Customize the color as needed
                                        thickness:
                                            1, // Customize the thickness as needed
                                        width: 1,
                                      ),
                                      SizedBox(
                                        width: screenWidth *
                                            0.02, // 2% of screen width
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Cook Time:',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text('${widget.cookTime} mins'),
                                        ],
                                      ),
                                      SizedBox(
                                        width: screenWidth *
                                            0.02, // 2% of screen width
                                      ),
                                      VerticalDivider(
                                        color: Colors
                                            .black, // Customize the color as needed
                                        thickness:
                                            1, // Customize the thickness as needed
                                        width: 1,
                                      ),
                                      SizedBox(
                                        width: screenWidth *
                                            0.02, // 2% of screen width
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Total Time:',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                              '${widget.prepTime + widget.cookTime} mins'),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height: MediaQuery.of(context)
                                              .size
                                              .height *
                                          0.01), // Adjust height to 1% of screen height
                                  Text('Cuisine: ${widget.cuisine}'),
                                  Text('Spice Level: ${widget.spiceLevel}'),
                                  Text('Course: ${widget.course}'),
                                  Text('Servings: ${widget.servings}'),
                                  Text(
                                      'Keywords: ${widget.keyWords.join(', ')}'),
                                  SizedBox(
                                      height: MediaQuery.of(context)
                                              .size
                                              .height *
                                          0.02), // Adjust height to 2% of screen height
                                  Text('Ingredients:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(
                                      height: MediaQuery.of(context)
                                              .size
                                              .height *
                                          0.01), // Adjust height to 1% of screen height
                                  ...widget.ingredients
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    int idx = entry.key;
                                    Map<String, dynamic> ingredient =
                                        entry.value;
                                    return CheckableItem(
                                      title:
                                          '${ingredient['quantity']} ${ingredient['measurementunit']} ${ingredient['name']}',
                                      isChecked:
                                          _ingredientChecked[idx] ?? false,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          _ingredientChecked[idx] =
                                              value ?? false;
                                        });
                                      },
                                    );
                                  }),
                                  SizedBox(
                                      height: MediaQuery.of(context)
                                              .size
                                              .height *
                                          0.02), // Adjust height to 2% of screen height
                                  Text('Appliances:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(
                                      height: MediaQuery.of(context)
                                              .size
                                              .height *
                                          0.01), // Adjust height to 1% of screen height
                                  ...widget.appliances
                                      .map((appliance) => Text(appliance))
                                      ,
                                  SizedBox(
                                      height: MediaQuery.of(context)
                                              .size
                                              .height *
                                          0.02), // Adjust height to 2% of screen height
                                  Text('Instructions:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(
                                      height: MediaQuery.of(context)
                                              .size
                                              .height *
                                          0.01), // Adjust height to 1% of screen height
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: widget.steps
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      int index = entry.key;
                                      String step = entry.value;
                                      return Padding(
                                        padding: EdgeInsets.only(
                                            bottom: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.01), // Add some spacing between steps
                                        child: Text('${index + 1}. $step'),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                            if (showImage) ...[
                              SizedBox(
                                  width: screenWidth *
                                      0.05), // 5% of screen width for spacing
                              Container(
                                width: screenWidth *
                                    0.2, // 20% of screen width for the image
                                height: MediaQuery.of(context).size.height *
                                    0.5, // 50% of screen height for the image
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(screenWidth *
                                      0.005), // 0.5% of screen width for rounded corners
                                  image: DecorationImage(
                                    image: NetworkImage(widget.imagePath),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // void _showRecipeDetails() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return StatefulBuilder(
  //         builder: (BuildContext context, StateSetter setState) {
  //           return Dialog(
  //             backgroundColor: Color.fromARGB(
  //                 255, 25, 58, 48), // Change background color to green
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(
  //                   MediaQuery.of(context).size.width * 0.01),
  //             ),
  //             child: Container(
  //               width: MediaQuery.of(context).size.width *
  //                   0.6, // Set width to 60% of screen width
  //               height: MediaQuery.of(context).size.height *
  //                   0.8, // Set height to 80% of screen height
  //               padding: EdgeInsets.only(
  //                 top: MediaQuery.of(context).size.height *
  //                     0.04, // Adjust top padding to 4% of screen height
  //                 left: MediaQuery.of(context).size.width *
  //                     0.05, // Adjust left padding to 5% of screen width
  //                 right: MediaQuery.of(context).size.width *
  //                     0.05, // Adjust right padding to 5% of screen width
  //               ),
  //               child: Column(
  //                 children: [
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Container(
  //                         width: MediaQuery.of(context).size.width *
  //                             0.4, // Adjust text width to 40% of screen width
  //                         child: Text(
  //                           widget.name,
  //                           style: TextStyle(
  //                             fontSize: MediaQuery.of(context).size.width *
  //                                 0.02, // Adjust font size to 2% of screen width
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                           maxLines: 2,
  //                           overflow: TextOverflow.ellipsis,
  //                         ),
  //                       ),
  //                       IconButton(
  //                         icon: Icon(Icons.close),
  //                         iconSize: MediaQuery.of(context).size.width *
  //                             0.02, // Adjust icon size to 2% of screen width
  //                         onPressed: () {
  //                           Navigator.of(context).pop();
  //                         },
  //                       ),
  //                     ],
  //                   ),
  //                   SizedBox(
  //                       height: MediaQuery.of(context).size.height *
  //                           0.01), // Adjust height to 1% of screen height
  //                   Row(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Expanded(
  //                         child: Scrollbar(
  //                           // thumbVisibility: true,
  //                           child: SingleChildScrollView(
  //                             child: Column(
  //                               crossAxisAlignment: CrossAxisAlignment.start,
  //                               children: [
  //                                 Text(widget.description),
  //                                 SizedBox(
  //                                     height: MediaQuery.of(context)
  //                                             .size
  //                                             .height *
  //                                         0.01), // Adjust height to 1% of screen height
  //                                 Row(
  //                                   children: [
  //                                     Column(
  //                                       crossAxisAlignment:
  //                                           CrossAxisAlignment.center,
  //                                       children: [
  //                                         Text(
  //                                           'Prep Time:',
  //                                           style: TextStyle(
  //                                               fontWeight: FontWeight.bold),
  //                                         ),
  //                                         Text('${widget.prepTime} mins'),
  //                                       ],
  //                                     ),
  //                                     SizedBox(
  //                                       width:
  //                                           MediaQuery.of(context).size.width *
  //                                               0.02, // 2% of screen width
  //                                     ),
  //                                     VerticalDivider(
  //                                       color: Colors
  //                                           .black, // Customize the color as needed
  //                                       thickness:
  //                                           1, // Customize the thickness as needed
  //                                       width: 1,
  //                                     ),
  //                                     SizedBox(
  //                                       width:
  //                                           MediaQuery.of(context).size.width *
  //                                               0.02, // 2% of screen width
  //                                     ),
  //                                     Column(
  //                                       crossAxisAlignment:
  //                                           CrossAxisAlignment.center,
  //                                       children: [
  //                                         Text(
  //                                           'Cook Time:',
  //                                           style: TextStyle(
  //                                               fontWeight: FontWeight.bold),
  //                                         ),
  //                                         Text('${widget.cookTime} mins'),
  //                                       ],
  //                                     ),
  //                                     SizedBox(
  //                                       width:
  //                                           MediaQuery.of(context).size.width *
  //                                               0.02, // 2% of screen width
  //                                     ),
  //                                     VerticalDivider(
  //                                       color: Colors
  //                                           .black, // Customize the color as needed
  //                                       thickness:
  //                                           1, // Customize the thickness as needed
  //                                       width: 1,
  //                                     ),
  //                                     SizedBox(
  //                                       width:
  //                                           MediaQuery.of(context).size.width *
  //                                               0.02, // 2% of screen width
  //                                     ),
  //                                     Column(
  //                                       crossAxisAlignment:
  //                                           CrossAxisAlignment.center,
  //                                       children: [
  //                                         Text(
  //                                           'Total Time:',
  //                                           style: TextStyle(
  //                                               fontWeight: FontWeight.bold),
  //                                         ),
  //                                         Text(
  //                                             '${widget.prepTime + widget.cookTime} mins'),
  //                                       ],
  //                                     ),
  //                                   ],
  //                                 ),
  //                                 SizedBox(
  //                                     height: MediaQuery.of(context)
  //                                             .size
  //                                             .height *
  //                                         0.01), // Adjust height to 1% of screen height
  //                                 Text('Cuisine: ${widget.cuisine}'),
  //                                 Text('Spice Level: ${widget.spiceLevel}'),
  //                                 Text('Course: ${widget.course}'),
  //                                 Text('Servings: ${widget.servings}'),
  //                                 Text(
  //                                     'Keywords: ${widget.keyWords.join(', ')}'),
  //                                 SizedBox(
  //                                     height: MediaQuery.of(context)
  //                                             .size
  //                                             .height *
  //                                         0.02), // Adjust height to 2% of screen height
  //                                 Text('Ingredients:',
  //                                     style: TextStyle(
  //                                         fontWeight: FontWeight.bold)),
  //                                 SizedBox(
  //                                     height: MediaQuery.of(context)
  //                                             .size
  //                                             .height *
  //                                         0.01), // Adjust height to 1% of screen height
  //                                 ...widget.ingredients
  //                                     .asMap()
  //                                     .entries
  //                                     .map((entry) {
  //                                   int idx = entry.key;
  //                                   Map<String, dynamic> ingredient =
  //                                       entry.value;
  //                                   return CheckableItem(
  //                                     title:
  //                                         '${ingredient['quantity']} ${ingredient['unit']} ${ingredient['ingredient']}',
  //                                     isChecked:
  //                                         _ingredientChecked[idx] ?? false,
  //                                     onChanged: (bool? value) {
  //                                       setState(() {
  //                                         _ingredientChecked[idx] =
  //                                             value ?? false;
  //                                       });
  //                                     },
  //                                   );
  //                                 }).toList(),
  //                                 SizedBox(
  //                                     height: MediaQuery.of(context)
  //                                             .size
  //                                             .height *
  //                                         0.02), // Adjust height to 2% of screen height
  //                                 Text('Appliances:',
  //                                     style: TextStyle(
  //                                         fontWeight: FontWeight.bold)),
  //                                 SizedBox(
  //                                     height: MediaQuery.of(context)
  //                                             .size
  //                                             .height *
  //                                         0.01), // Adjust height to 1% of screen height
  //                                 ...widget.appliances
  //                                     .map((appliance) => Text(appliance))
  //                                     .toList(),
  //                                 SizedBox(
  //                                     height: MediaQuery.of(context)
  //                                             .size
  //                                             .height *
  //                                         0.02), // Adjust height to 2% of screen height
  //                                 Text('Instructions:',
  //                                     style: TextStyle(
  //                                         fontWeight: FontWeight.bold)),
  //                                 SizedBox(
  //                                     height: MediaQuery.of(context)
  //                                             .size
  //                                             .height *
  //                                         0.01), // Adjust height to 1% of screen height
  //                                 Column(
  //                                   crossAxisAlignment:
  //                                       CrossAxisAlignment.start,
  //                                   children: widget.steps
  //                                       .asMap()
  //                                       .entries
  //                                       .map((entry) {
  //                                     int index = entry.key;
  //                                     String step = entry.value;
  //                                     return Padding(
  //                                       padding: EdgeInsets.only(
  //                                           bottom: MediaQuery.of(context)
  //                                                   .size
  //                                                   .height *
  //                                               0.01), // Add some spacing between steps
  //                                       child: Text('${index + 1}. $step'),
  //                                     );
  //                                   }).toList(),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                       SizedBox(
  //                           width: MediaQuery.of(context).size.width *
  //                               0.05), // 5% of screen width for spacing
  //                       Container(
  //                         width: MediaQuery.of(context).size.width *
  //                             0.2, // 20% of screen width for the image
  //                         height: MediaQuery.of(context).size.height *
  //                             0.5, // 30% of screen height for the image
  //                         decoration: BoxDecoration(
  //                           borderRadius: BorderRadius.circular(MediaQuery.of(
  //                                       context)
  //                                   .size
  //                                   .width *
  //                               0.005), // 2% of screen width for rounded corners
  //                           image: DecorationImage(
  //                             image: NetworkImage(widget.imagePath),
  //                             fit: BoxFit.cover,
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

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
                child: Image.network(
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

class CheckableItem extends StatefulWidget {
  final String title;
  final bool isChecked;
  final ValueChanged<bool?> onChanged;

  CheckableItem({
    required this.title,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  _CheckableItemState createState() => _CheckableItemState();
}

class _CheckableItemState extends State<CheckableItem> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: widget.isChecked,
          onChanged: widget.onChanged,
          activeColor: Color(0XFFDC945F),
          checkColor: Colors.white,
        ),
        Text(widget.title),
      ],
    );
  }
}
