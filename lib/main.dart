import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'auth_screen.dart';
import 'card_model.dart';
import 'account_screen.dart';
import 'level_system.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runTheApp();
}

void runTheApp() {
  runApp(const MJCardTrackerApp());
}

class MJCardTrackerApp extends StatelessWidget {
  const MJCardTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MJ Card Tracker',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.amber,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        colorScheme: const ColorScheme.dark(
          primary: Colors.amber,
          secondary: Colors.amberAccent,
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Colors.amber),
              ),
            );
          }
          if (snapshot.hasData) {
            return const AlbumScreen();
          }
          return const AuthScreen();
        },
      ),
    );
  }
}

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({super.key});

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  
  late final List<MJCardItem> _masterChecklist = _generateMasterChecklist();

  List<MJCardItem> _generateMasterChecklist() {
    List<MJCardItem> list = [];

    for (int num = 1; num <= 300; num++) {
      String name = 'Michael Jackson';
      String type = 'Base Set';
      List<String> allowedVariations = [];

      if (num >= 1 && num <= 31) {
        type = 'Base Set';
        name = 'Michael Jackson - Base #$num';
        allowedVariations = ['Base', 'W. Foil', 'Sil. BG', 'BAD BG', 'Red /87', 'Gold /17', 'Plat /15', 'Sig. /07', 'Dia. /01', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl'];
      } else if (num >= 32 && num <= 56) {
        type = 'Spotlight Base';
        name = 'Michael Jackson - Spotlight Base #$num';
        allowedVariations = ['Base', 'Foil', 'Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'Plat /15', 'Sig. /07', 'Dia. /01', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl'];
      } else if (num >= 57 && num <= 85) {
        type = 'Shortprint';
        name = 'Michael Jackson - Base Shortprint #$num';
        allowedVariations = ['Base', 'White Foil', 'Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'White /17', 'Blue /17', 'Plat. /15', 'Black Vinyl', 'Blue Vinyl', 'Red Vinyl'];
      } else if (num >= 86 && num <= 103) {
        type = 'Throwback';
        name = 'Michael Jackson - Base Throwback #$num';
        allowedVariations = ['Base', 'Foil', 'Red /87', 'Gold /17', 'Black /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Black Vinyl'];
      } else if (num >= 104 && num <= 123) {
        type = 'VIP Pass';
        name = 'Michael Jackson - Base VIP Pass #$num';
        allowedVariations = ['Base', 'White Foil', 'Black Base', 'Black Foil', 'Red /87', 'Gold /17', 'White /17', 'Black /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Black Vinyl', 'White Vinyl'];
      } else if (num >= 124 && num <= 154) {
        type = 'SignaGraph';
        name = 'Michael Jackson - Laser SignaGraph #$num';
        allowedVariations = ['Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'Blue /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Blue Vinyl'];
      } else if (num >= 155 && num <= 174) {
        type = 'Inserts';
        name = 'Michael Jackson - Insert 1 Post Card #$num';
        allowedVariations = ['Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'Blue /17', 'Black', 'Gold Vinyl', 'Red Vinyl', 'Blue Vinyl', 'Black Vinyl'];
      } else if (num >= 175 && num <= 202) {
        type = 'Inserts';
        name = 'Michael Jackson - Insert 2 Poster #$num';
        allowedVariations = ['Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'Blue /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Blue Vinyl'];
      } else if (num >= 203 && num <= 234) {
        type = 'Inserts';
        name = 'Michael Jackson - Insert 3 Gallery #$num';
        allowedVariations = ['Base', 'White Foil', 'Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'White /17', 'Blue /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Blue Vinyl', 'White Vinyl'];
      } else if (num >= 235 && num <= 244) {
        type = 'Inserts';
        name = 'Michael Jackson - Insert 4 Drip #$num';
        allowedVariations = ['Base', 'White Foil', 'Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'White /17', 'Blue /17', 'Plat. /15', 'Black Vinyl', 'Blue Vinyl', 'Red Vinyl'];
      } else if (num >= 245 && num <= 252) {
        type = 'Inserts';
        name = 'Michael Jackson - Insert 5 Fire! #$num';
        allowedVariations = ['Base', 'Foil', 'Red /87', 'Gold /17', 'Black /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Black Vinyl'];
      } else if (num == 253) {
        type = 'Inserts';
        name = 'Michael Jackson - Insert 6 Ticket Stub Die Cut #253';
        allowedVariations = ['Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'Blue /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Blue Vinyl', 'Plat. Vinyl'];
      } else if (num == 254) {
        type = 'Inserts';
        name = 'Michael Jackson - Insert 7 Headlines #254';
        allowedVariations = ['Base', 'Foil', 'Black Base', 'Black Foil', 'Red /87', 'Gold /17', 'White /17', 'Black /17', 'Plat. /15', 'Red Vinyl', 'Gold Vinyl', 'Plat. Vinyl', 'White Vinyl', 'Black Vinyl'];
      } else if (num == 255) {
        type = 'Inserts';
        name = 'Michael Jackson - Insert 8 King of Pop Die Cut #255';
        allowedVariations = ['Base', 'Foil', 'Red /87', 'Gold /17', 'Black /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Black Vinyl'];
      } else if (num == 256) {
        type = 'Inserts';
        name = 'Michael Jackson - Insert 9 Now Presenting #256';
        allowedVariations = ['Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'Blue /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Blue Vinyl', 'Plat. Vinyl'];
      } else if (num == 257) {
        type = 'Inserts';
        name = 'Michael Jackson - Insert 10 Retro #257';
        allowedVariations = ['Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'Blue /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Blue Vinyl', 'Plat. Vinyl'];
      } else if (num == 258) {
        type = 'Inserts';
        name = 'Michael Jackson - Insert 11 Canvas #258';
        allowedVariations = ['Base', 'Foil', 'Red /87', 'Gold /17', 'White /17', 'Plat. /15', 'Red Vinyl', 'Gold Vinyl', 'Plat. Vinyl', 'White Vinyl'];
      } else if (num == 259) {
        type = 'Inserts';
        name = 'Michael Jackson - Insert 12 BAD World Tour Logo #259';
        allowedVariations = ['Base', 'Foil', 'Red /87', 'Gold /17', 'Black /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Black Vinyl'];
      } else if (num == 260) {
        type = 'Inserts';
        name = 'Michael Jackson - Insert 13 Confetti #260';
        allowedVariations = ['Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'Blue /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Blue Vinyl', 'Plat. Vinyl'];
      } else if (num >= 261 && num <= 270) {
        type = 'Relic Memorabilia';
        name = 'Michael Jackson - Relic Tour Jacket Memorabilia #$num';
        allowedVariations = ['Base', 'Foil', 'Red /87', 'Gold /17', 'Black /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Black Vinyl'];
      } else if (num >= 271 && num <= 281) {
        type = 'Relic Memorabilia';
        name = 'Michael Jackson - Relic Poster Memorabilia #$num';
        allowedVariations = ['Base', 'Foil', 'Red /87', 'Gold /17', 'Black /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Black Vinyl'];
      } else if (num >= 282 && num <= 285) {
        type = 'Relic Memorabilia';
        name = 'Michael Jackson - Relic Ticket Stub Memorabilia #$num';
        allowedVariations = ['Base', 'Foil', 'Red /87', 'Gold /17', 'Black /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Black Vinyl'];
      } else if (num == 286) {
        type = 'Relic Memorabilia';
        name = 'Michael Jackson - Relic Private Collection Memorabilia #286';
        allowedVariations = ['Black /87', 'Red /87', 'Gold /17', 'Plat. /15', 'Red Vinyl', 'Gold Vinyl', 'Plat. Vinyl', 'Black Vinyl'];
      } else if (num >= 287 && num <= 290) {
        type = 'Cut Autograph';
        name = 'Michael Jackson - Cut Autograph #$num';
        allowedVariations = ['Base'];
      } else if (num >= 291 && num <= 292) {
        type = 'Cut Autograph';
        name = 'Michael Jackson - Memorabilia Cut Autograph #$num';
        allowedVariations = ['Base'];
      } else if (num >= 293 && num <= 296) {
        type = 'Gemstone Relic';
        name = num == 293 ? 'Michael Jackson - Real Ruby Memorabilia #293' : (num == 294 ? 'Michael Jackson - Real Emerald Memorabilia #294' : (num == 295 ? 'Michael Jackson - Real Sapphire Memorabilia #295' : 'Michael Jackson - Real Diamond Memorabilia #296'));
        allowedVariations = ['Base /10'];
      } else if (num >= 297 && num <= 300) {
        type = 'Precious Metal Relic';
        name = num == 297 ? 'Michael Jackson - Real Silver Memorabilia #297' : (num == 298 ? 'Michael Jackson - Real Gold Memorabilia #298' : (num == 299 ? 'Michael Jackson - Real Platinum Memorabilia #299' : 'Michael Jackson - Real Pearl Memorabilia #300'));
        allowedVariations = ['Base /10'];
      }

      Map<String, bool> initialVars = {for (var v in allowedVariations) v: false};
      list.add(MJCardItem(
        cardNumber: num,
        cardName: name,
        cardType: type,
        variations: initialVars,
      ));
    }
    return list;
  }

  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _showOnlyMyCollection = false;
  bool _isLoading = true;

  final List<String> _categories = [
    'All',
    'Base Set',
    'Spotlight Base',
    'Shortprint',
    'Throwback',
    'VIP Pass',
    'SignaGraph',
    'Inserts',
    'Relic Memorabilia',
    'Cut Autograph',
    'Gemstone Relic'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserCollection();
  }

  Future<void> _loadUserCollection() async {
    if (user == null) return;
    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);
      final docSnap = await docRef.get();

      if (docSnap.exists && docSnap.data() != null) {
        final rawData = docSnap.data()!['collectedCards'];
        if (rawData is Map) {
          setState(() {
            for (var card in _masterChecklist) {
              final cardKey = card.cardNumber.toString();
              if (rawData.containsKey(cardKey)) {
                var cardData = rawData[cardKey];
                if (cardData is Map) {
                  try {
                    card.variations = Map<String, bool>.from(
                      (cardData['variations'] as Map?)?.map((k, v) => MapEntry(k.toString(), v == true)) ?? {}
                    );
                    card.serialNumbers = Map<String, String>.from(
                      (cardData['serialNumbers'] as Map?)?.map((k, v) => MapEntry(k.toString(), v?.toString() ?? '')) ?? {}
                    );
                    card.notes = cardData['notes']?.toString() ?? '';
                  } catch (e) {
                    debugPrint("Error parsing map data for card $cardKey: $e");
                  }
                } else if (cardData is bool && card.variations.isNotEmpty) {
                  String firstKey = card.variations.keys.first;
                  card.variations[firstKey] = cardData;
                }
              }
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading collection: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveCollectionToFirebase() async {
    if (user == null) return;
    try {
      Map<String, dynamic> updateData = {};
      for (var item in _masterChecklist) {
        updateData[item.cardNumber.toString()] = item.toJson();
      }

      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'collectedCards': updateData,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error saving collection: $e");
    }
  }

  void _openCardDetailModal(MJCardItem card) {
    Map<String, bool> tempVariations = Map.from(card.variations);
    Map<String, String> tempSerialNumbers = Map.from(card.serialNumbers);
    String tempNotes = card.notes;
    bool hasChanges = false;

    Map<String, TextEditingController> controllers = {};
    for (var entry in tempSerialNumbers.entries) {
      controllers[entry.key] = TextEditingController(text: entry.value);
    }

    final notesController = TextEditingController(text: tempNotes);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return PopScope(
          canPop: false,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {

              bool isMutualExclusiveConflict(String targetVar) {
                if (targetVar.contains('Red')) {
                  for (var key in tempVariations.keys) {
                    if (key != targetVar && key.contains('Gold') && (tempVariations[key] ?? false)) {
                      return true;
                    }
                  }
                }
                if (targetVar.contains('Gold')) {
                  for (var key in tempVariations.keys) {
                    if (key != targetVar && key.contains('Red') && (tempVariations[key] ?? false)) {
                      return true;
                    }
                  }
                }
                return false;
              }

              bool validateNumberedVariations() {
                for (var entry in tempVariations.entries) {
                  String varName = entry.key;
                  bool isChecked = entry.value;
                  bool isNumbered = varName.contains('/') || varName.contains('/10');

                  if (isChecked && isNumbered) {
                    String serialVal = tempSerialNumbers[varName]?.trim() ?? '';
                    if (serialVal.isEmpty) {
                      return false;
                    }
                  }
                }
                return true;
              }

              return Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '#${card.cardNumber} - ${card.cardName}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.grey),
                      const Text('Select Variations Owned & Enter Serial Numbers:', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 10),
                      ...tempVariations.keys.map((variationName) {
                        bool isChecked = tempVariations[variationName] ?? false;
                        bool isNumbered = variationName.contains('/') || variationName.contains('/10');

                        if (isNumbered && isChecked && !controllers.containsKey(variationName)) {
                          controllers[variationName] = TextEditingController(text: tempSerialNumbers[variationName] ?? '');
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CheckboxListTile(
                              title: Text(variationName, style: const TextStyle(fontSize: 14)),
                              value: isChecked,
                              activeColor: Colors.amber,
                              checkColor: Colors.black,
                              contentPadding: EdgeInsets.zero,
                              onChanged: (bool? value) {
                                if (value == true && isMutualExclusiveConflict(variationName)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Conflict: Cannot select Red and Gold variants simultaneously!'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  return;
                                }

                                setModalState(() {
                                  tempVariations[variationName] = value ?? false;
                                  hasChanges = true;
                                  if (!(value ?? false)) {
                                    tempSerialNumbers.remove(variationName);
                                    controllers.remove(variationName);
                                  } else {
                                    if (!controllers.containsKey(variationName)) {
                                      controllers[variationName] = TextEditingController();
                                    }
                                  }
                                });
                              },
                            ),
                            if (isChecked && isNumbered)
                              Padding(
                                padding: const EdgeInsets.only(left: 16, bottom: 8),
                                child: TextField(
                                  controller: controllers[variationName],
                                  decoration: InputDecoration(
                                    labelText: 'Enter Serial Number (e.g. 12/87) *Required',
                                    labelStyle: const TextStyle(fontSize: 12, color: Colors.amber),
                                    filled: true,
                                    fillColor: const Color(0xFF141414),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    isDense: true,
                                  ),
                                  onChanged: (val) {
                                    setModalState(() {
                                      tempSerialNumbers[variationName] = val;
                                      hasChanges = true;
                                    });
                                  },
                                ),
                              ),
                          ],
                        );
                      }),
                      const SizedBox(height: 10),
                      TextField(
                        controller: notesController,
                        decoration: InputDecoration(
                          labelText: 'Notes (Condition, Grade, etc.)',
                          labelStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFF141414),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onChanged: (val) {
                          setModalState(() {
                            tempNotes = val;
                            hasChanges = true;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      if (hasChanges)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              if (!validateNumberedVariations()) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please fill out the serial number for all selected numbered variations!'),
                                    backgroundColor: Colors.redAccent,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }

                              setState(() {
                                card.variations = Map.from(tempVariations);
                                card.serialNumbers = Map.from(tempSerialNumbers);
                                card.notes = tempNotes;
                              });
                              _saveCollectionToFirebase();
                              Navigator.pop(context);
                            },
                            child: const Text('Apply Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.amber)),
      );
    }

    List<MJCardItem> filteredList = _masterChecklist.where((card) {
      final matchesSearch = card.cardName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          card.cardNumber.toString().contains(_searchQuery) ||
          card.cardType.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == 'All' || card.cardType == _selectedCategory;
      final matchesCollectionFilter = !_showOnlyMyCollection || card.isCollected;

      return matchesSearch && matchesCategory && matchesCollectionFilter;
    }).toList();

    int collectedCount = _masterChecklist.where((card) => card.isCollected).length;
    double progressPercent = _masterChecklist.isEmpty ? 0.0 : collectedCount / _masterChecklist.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bad World Tour Tracker', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        centerTitle: true,
        backgroundColor: const Color(0xFF161616),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.amber),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.amber),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: const BoxDecoration(
              color: Color(0xFF181818),
              border: Border(bottom: BorderSide(color: Color(0xFF2C2C2C))),
            ),
            child: Column(
              children: [
                Builder(
                  builder: (context) {
                    final levelData = LevelSystem.calculateLevel(collectedCount);
                    return Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF221E12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade700, width: 1),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.amber,
                            child: Text(
                              '${levelData['level']}',
                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Collector Rank', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                Text(
                                  levelData['title'],
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Lvl ${levelData['level']}/30',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Collection Progress',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),
                    ),
                    Text(
                      '$collectedCount / ${_masterChecklist.length} (${(progressPercent * 100).toStringAsFixed(0)}%)',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progressPercent,
                    minHeight: 8,
                    backgroundColor: const Color(0xFF2C2C2C),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _showOnlyMyCollection ? Colors.amber : Colors.amber.shade800,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      setState(() {
                        _showOnlyMyCollection = !_showOnlyMyCollection;
                      });
                    },
                    icon: Icon(_showOnlyMyCollection ? Icons.list_alt : Icons.collections_bookmark, color: Colors.black),
                    label: Text(
                      _showOnlyMyCollection ? 'Show Master Checklist' : 'Open My Collection',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search by card #, name, or set type...',
                hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.amber),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    selectedColor: Colors.amber,
                    backgroundColor: const Color(0xFF1E1E1E),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Text(
                      _showOnlyMyCollection ? 'No collected cards yet' : 'No cards found',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 12.0,
                      mainAxisSpacing: 12.0,
                    ),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final card = filteredList[index];
                      return GestureDetector(
                        onTap: () => _openCardDetailModal(card),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          decoration: BoxDecoration(
                            color: card.isCollected ? const Color(0xFF221E12) : const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(14.0),
                            border: Border.all(
                              color: card.isCollected ? Colors.amber.shade600 : Colors.grey.shade800,
                              width: card.isCollected ? 2.0 : 1.0,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '#${card.cardNumber}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 13),
                                    ),
                                    Icon(
                                      card.isCollected ? Icons.check_circle : Icons.radio_button_unchecked,
                                      color: card.isCollected ? Colors.amber : Colors.grey.shade700,
                                      size: 20,
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Icon(
                                  card.isCollected ? Icons.album : Icons.lock_outline,
                                  size: 42,
                                  color: card.isCollected ? Colors.amber : Colors.grey.shade700,
                                ),
                                const Spacer(),
                                Text(
                                  card.cardName,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: card.isCollected ? Colors.white : Colors.grey.shade400,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  card.cardType,
                                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: card.isCollected ? Colors.amber : Colors.grey.shade800,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    card.isCollected ? 'OWNED' : 'MISSING',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: card.isCollected ? Colors.black : Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}