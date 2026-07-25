import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'card_model.dart';

class FriendCollectionScreen extends StatefulWidget {
  const FriendCollectionScreen({super.key, required this.friendUsername});
  final String friendUsername;

  @override
  State<FriendCollectionScreen> createState() => _FriendCollectionScreenState();
}

class _FriendCollectionScreenState extends State<FriendCollectionScreen> {
  bool _isLoading = true;
  bool _isPrivate = false;
  String _friendProfileIcon = 'album';
  String _friendImageUrl = '';
  
  late final List<MJCardItem> _friendChecklist = _generateFriendChecklist();

  List<MJCardItem> _generateFriendChecklist() {
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

  @override
  void initState() {
    super.initState();
    _fetchFriendData();
  }

  Future<void> _fetchFriendData() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: widget.friendUsername)
          .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        final privacy = data['privacySetting'] ?? 'friends';

        if (privacy == 'private') {
          setState(() {
            _isPrivate = true;
            _isLoading = false;
          });
          return;
        }

        setState(() {
          _friendProfileIcon = data['profileIcon'] ?? 'album';
          _friendImageUrl = data['profileImageBase64'] ?? '';
        });

        final collectedData = data['collectedCards'] as Map<String, dynamic>?;
        if (collectedData != null) {
          setState(() {
            for (var card in _friendChecklist) {
              if (collectedData.containsKey(card.cardNumber.toString())) {
                var cardData = collectedData[card.cardNumber.toString()];
                if (cardData is Map) {
                  card.variations = Map<String, bool>.from(cardData['variations'] ?? {});
                  card.serialNumbers = Map<String, String>.from(cardData['serialNumbers'] ?? {});
                  card.notes = cardData['notes'] ?? '';
                } else if (cardData is bool) {
                  if (card.variations.isNotEmpty) {
                    card.variations[card.variations.keys.first] = cardData;
                  }
                }
              }
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading friend collection: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openFriendCardDetailModal(MJCardItem card) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
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
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(color: Colors.grey),
                const Text('Friend Owned Variations & Serial Numbers:', style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 10),
                ...card.variations.keys.map((variationName) {
                  bool isChecked = card.variations[variationName] ?? false;
                  String serial = card.serialNumbers[variationName] ?? '';

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(variationName, style: const TextStyle(fontSize: 14)),
                    trailing: Text(
                      isChecked ? (serial.isNotEmpty ? 'Owned ($serial)' : 'Owned') : 'Missing',
                      style: TextStyle(
                        color: isChecked ? Colors.amber : Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                }),
                if (card.notes.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text('Notes: ${card.notes}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(backgroundColor: const Color(0xFF161616)),
        body: const Center(child: CircularProgressIndicator(color: Colors.amber)),
      );
    }

    if (_isPrivate) {
      return Scaffold(
        appBar: AppBar(
          title: Text("${widget.friendUsername}'s Collection", style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF161616),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 60, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                "${widget.friendUsername}'s collection is private.",
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    int collectedCount = _friendChecklist.where((card) => card.isCollected).length;
    double progressPercent = _friendChecklist.isEmpty ? 0.0 : collectedCount / _friendChecklist.length;

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.friendUsername}'s Collection", style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF161616),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF181818),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.amber.shade900,
                  backgroundImage: _friendImageUrl.isNotEmpty
                      ? NetworkImage(_friendImageUrl)
                      : null,
                  child: _friendImageUrl.isEmpty
                      ? Icon(
                          _friendProfileIcon == 'star'
                              ? Icons.star
                              : _friendProfileIcon == 'music_note'
                                  ? Icons.music_note
                                  : Icons.album,
                          size: 30,
                          color: Colors.amber,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.friendUsername, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(
                        'Progress: $collectedCount / ${_friendChecklist.length} (${(progressPercent * 100).toStringAsFixed(0)}%)',
                        style: const TextStyle(color: Colors.amber, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
              ),
              itemCount: _friendChecklist.length,
              itemBuilder: (context, index) {
                final card = _friendChecklist[index];
                return GestureDetector(
                  onTap: () => _openFriendCardDetailModal(card),
                  child: Container(
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