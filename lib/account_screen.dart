import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'friend_collection_screen.dart';
import 'card_model.dart';
import 'level_system.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final _usernameController = TextEditingController();
  final _friendController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditingUsername = false;
  String _statusMessage = '';
  String _friendStatusMessage = '';
  List<dynamic> _friendsList = [];
  List<dynamic> _incomingRequests = [];
  
  // Cache to store friend level stats {username: {'level': int, 'title': String}}
  final Map<String, Map<String, dynamic>> _friendStats = {};

  String _profileIcon = 'album';
  String _profileImageUrl = '';
  String _privacySetting = 'friends';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        setState(() {
          _usernameController.text = data['username'] ?? '';
          _friendsList = data['friends'] ?? [];
          _incomingRequests = data['incomingRequests'] ?? [];
          _profileIcon = data['profileIcon'] ?? 'album';
          _profileImageUrl = data['profileImageBase64'] ?? '';
          _privacySetting = data['privacySetting'] ?? 'friends';
        });
        
        // Fetch stats for each friend
        for (var friendName in _friendsList) {
          _fetchFriendStats(friendName);
        }
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchFriendStats(String friendUsername) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: friendUsername)
          .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        final privacy = data['privacySetting'] ?? 'friends';

        if (privacy == 'private') {
          setState(() {
            _friendStats[friendUsername] = {'isPrivate': true};
          });
          return;
        }

        int collectedCount = 0;
        final collectedData = data['collectedCards'] as Map<String, dynamic>?;
        if (collectedData != null) {
          // Count how many cards have at least one variation collected
          collectedData.forEach((key, cardData) {
            if (cardData is Map) {
              final variations = cardData['variations'] as Map?;
              if (variations != null && variations.values.contains(true)) {
                collectedCount++;
              }
            } else if (cardData is bool && cardData == true) {
              collectedCount++;
            }
          });
        }

        final levelData = LevelSystem.calculateLevel(collectedCount);
        setState(() {
          _friendStats[friendUsername] = {
            'isPrivate': false,
            'level': levelData['level'],
            'title': levelData['title'],
            'collectedCount': collectedCount,
          };
        });
      }
    } catch (e) {
      debugPrint("Error loading friend stats for $friendUsername: $e");
    }
  }

  bool _isSafeImage(XFile file) {
    final name = file.name.toLowerCase();
    if (name.contains('nsfw') || name.contains('adult') || name.contains('explicit')) {
      return false;
    }
    return true;
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (image == null) return;

    if (!_isSafeImage(image)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image flagged by safety filter. Please choose another image.')),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${user!.uid}.jpg');

      File file = File(image.path);
      await storageRef.putFile(file);
      String downloadUrl = await storageRef.getDownloadURL();

      setState(() {
        _profileImageUrl = downloadUrl;
        _profileIcon = '';
      });

      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'profileImageBase64': downloadUrl,
        'profileIcon': '',
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated successfully!')),
      );
    } catch (e) {
      debugPrint("Error uploading image: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleUsernameButtonPress() async {
    if (!_isEditingUsername) {
      setState(() {
        _isEditingUsername = true;
        _statusMessage = '';
      });
    } else {
      final newUsername = _usernameController.text.trim();
      if (newUsername.isEmpty) {
        setState(() => _statusMessage = 'Username cannot be empty.');
        return;
      }

      setState(() {
        _isSaving = true;
        _statusMessage = '';
      });

      try {
        final query = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: newUsername)
            .get();

        if (query.docs.isNotEmpty && query.docs.first.id != user!.uid) {
          setState(() {
            _statusMessage = 'Username is already taken!';
            _isSaving = false;
          });
          return;
        }

        await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
          'username': newUsername,
        }, SetOptions(merge: true));

        setState(() {
          _statusMessage = 'Username updated successfully!';
          _isSaving = false;
          _isEditingUsername = false;
        });
      } catch (e) {
        setState(() {
          _statusMessage = 'Error updating username: $e';
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _updatePrivacy(String? value) async {
    if (value == null) return;
    setState(() {
      _privacySetting = value;
    });
    try {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'privacySetting': value,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error updating privacy: $e");
    }
  }

  Future<void> _sendFriendRequest() async {
    final targetUsername = _friendController.text.trim();
    if (targetUsername.isEmpty) return;

    final currentDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    final currentUsername = currentDoc.data()?['username'] ?? '';

    if (targetUsername == currentUsername) {
      setState(() => _friendStatusMessage = "You can't add yourself!");
      return;
    }

    if (_friendsList.contains(targetUsername)) {
      setState(() => _friendStatusMessage = 'Already in your friends list!');
      return;
    }

    setState(() {
      _friendStatusMessage = '';
    });

    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: targetUsername)
          .get();

      if (query.docs.isEmpty) {
        setState(() => _friendStatusMessage = 'User not found!');
        return;
      }

      final targetDoc = query.docs.first;
      List<dynamic> targetRequests = targetDoc.data()['incomingRequests'] ?? [];

      if (targetRequests.contains(currentUsername)) {
        setState(() => _friendStatusMessage = 'Friend request already sent!');
        return;
      }

      targetRequests.add(currentUsername);

      await targetDoc.reference.set({
        'incomingRequests': targetRequests,
      }, SetOptions(merge: true));

      _friendController.clear();
      setState(() {
        _friendStatusMessage = 'Friend request sent successfully!';
      });
    } catch (e) {
      setState(() => _friendStatusMessage = 'Error sending request: $e');
    }
  }

  Future<void> _acceptFriendRequest(String senderUsername) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: senderUsername)
          .get();

      if (query.docs.isNotEmpty) {
        final senderDoc = query.docs.first;
        List<dynamic> senderFriends = senderDoc.data()['friends'] ?? [];
        
        final currentDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
        final currentUsername = currentDoc.data()?['username'] ?? '';

        if (!senderFriends.contains(currentUsername)) {
          senderFriends.add(currentUsername);
          await senderDoc.reference.set({'friends': senderFriends}, SetOptions(merge: true));
        }

        if (!_friendsList.contains(senderUsername)) {
          _friendsList.add(senderUsername);
        }
      }

      _incomingRequests.remove(senderUsername);

      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'friends': _friendsList,
        'incomingRequests': _incomingRequests,
      }, SetOptions(merge: true));

      _fetchFriendStats(senderUsername);
      setState(() {});
    } catch (e) {
      debugPrint("Error accepting request: $e");
    }
  }

  Future<void> _declineFriendRequest(String senderUsername) async {
    setState(() {
      _incomingRequests.remove(senderUsername);
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'incomingRequests': _incomingRequests,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error declining request: $e");
    }
  }

  Future<void> _updateProfileIcon(String iconName) async {
    setState(() {
      _profileIcon = iconName;
      _profileImageUrl = '';
    });
    try {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'profileIcon': iconName,
        'profileImageBase64': '',
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error updating icon: $e");
    }
  }

  Future<void> _deleteAccount() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Delete Account', style: TextStyle(color: Colors.redAccent)),
        content: const Text('Are you sure you want to delete your account? All your collection data and profile info will be permanently removed.'),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onPressed: () async {
              Navigator.pop(context);
              try {
                setState(() => _isLoading = true);
                await FirebaseFirestore.instance.collection('users').doc(user!.uid).delete();
                await user!.delete();
              } catch (e) {
                debugPrint("Error deleting account: $e");
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please log out and log back in before deleting your account for security reasons.')),
                );
                setState(() => _isLoading = false);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF161616),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.amber.shade900,
                          backgroundImage: _profileImageUrl.isNotEmpty
                              ? NetworkImage(_profileImageUrl)
                              : null,
                          child: _profileImageUrl.isEmpty
                              ? Icon(
                                  _profileIcon == 'star'
                                      ? Icons.star
                                      : _profileIcon == 'music_note'
                                          ? Icons.music_note
                                          : Icons.album,
                                  size: 50,
                                  color: Colors.amber,
                                )
                              : null,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2C2C2C),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _pickAndUploadImage,
                          icon: const Icon(Icons.photo_library, color: Colors.amber),
                          label: const Text('Upload from Gallery'),
                        ),
                        const SizedBox(height: 8),
                        const Text('Or choose preset icon:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.album),
                              color: _profileIcon == 'album' && _profileImageUrl.isEmpty ? Colors.amber : Colors.grey,
                              onPressed: () => _updateProfileIcon('album'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.star),
                              color: _profileIcon == 'star' && _profileImageUrl.isEmpty ? Colors.amber : Colors.grey,
                              onPressed: () => _updateProfileIcon('star'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.music_note),
                              color: _profileIcon == 'music_note' && _profileImageUrl.isEmpty ? Colors.amber : Colors.grey,
                              onPressed: () => _updateProfileIcon('music_note'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 40, color: Color(0xFF2C2C2C)),
                  
                  const Text('Collection Privacy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _privacySetting,
                        dropdownColor: const Color(0xFF1A1A1A),
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: 'friends', child: Text('Friends Only')),
                          DropdownMenuItem(value: 'public', child: Text('Public (Anyone)')),
                          DropdownMenuItem(value: 'private', child: Text('Private (Only Me)')),
                        ],
                        onChanged: _updatePrivacy,
                      ),
                    ),
                  ),
                  const Divider(height: 40, color: Color(0xFF2C2C2C)),

                  const Text('Collector Username', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _usernameController,
                    enabled: _isEditingUsername,
                    decoration: InputDecoration(
                      hintText: 'Enter unique username',
                      filled: true,
                      fillColor: const Color(0xFF1A1A1A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _isSaving ? null : _handleUsernameButtonPress,
                      child: _isSaving
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                          : Text(
                              _isEditingUsername ? 'Save' : 'Change Username',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  if (_statusMessage.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(_statusMessage, style: TextStyle(color: _statusMessage.contains('successfully') ? Colors.green : Colors.red, fontSize: 13)),
                  ],
                  const Divider(height: 40, color: Color(0xFF2C2C2C)),
                  
                  const Text('Add Collector Friend', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _friendController,
                          decoration: InputDecoration(
                            hintText: "Friend's username...",
                            filled: true,
                            fillColor: const Color(0xFF1A1A1A),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        onPressed: _sendFriendRequest,
                        child: const Text('Send', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  if (_friendStatusMessage.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(_friendStatusMessage, style: TextStyle(color: _friendStatusMessage.contains('success') ? Colors.green : Colors.red, fontSize: 12)),
                  ],

                  if (_incomingRequests.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text('Incoming Friend Requests', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.amberAccent)),
                    const SizedBox(height: 6),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _incomingRequests.length,
                      itemBuilder: (context, index) {
                        final sender = _incomingRequests[index];
                        return Card(
                          color: const Color(0xFF1A1A1A),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: const Icon(Icons.person_add, color: Colors.amber),
                            title: Text(sender, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check, color: Colors.green),
                                  onPressed: () => _acceptFriendRequest(sender),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.redAccent),
                                  onPressed: () => _declineFriendRequest(sender),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 20),
                  const Text('Collector Friends (Tap to view collection)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber)),
                  const SizedBox(height: 8),
                  _friendsList.isEmpty
                      ? const Text('No collector friends added yet.', style: TextStyle(color: Colors.grey, fontSize: 13))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _friendsList.length,
                          itemBuilder: (context, index) {
                            final friendName = _friendsList[index];
                            final stats = _friendStats[friendName];
                            
                            String subtitleText = 'Loading level...';
                            if (stats != null) {
                              if (stats['isPrivate'] == true) {
                                subtitleText = 'Private Collection';
                              } else {
                                subtitleText = 'Lvl ${stats['level']} • ${stats['title']}';
                              }
                            }

                            return Card(
                              color: const Color(0xFF1A1A1A),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                leading: const Icon(Icons.person, color: Colors.amber),
                                title: Text(friendName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                subtitle: Text(subtitleText, style: const TextStyle(color: Colors.amberAccent, fontSize: 12)),
                                trailing: IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                                  onPressed: () async {
                                    setState(() {
                                      _friendsList.removeAt(index);
                                      _friendStats.remove(friendName);
                                    });
                                    await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
                                      'friends': _friendsList,
                                    }, SetOptions(merge: true));
                                  },
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FriendCollectionScreen(friendUsername: friendName),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),

                  const Divider(height: 50, color: Color(0xFF2C2C2C)),
                  
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _deleteAccount,
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('Delete Account & Data', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}