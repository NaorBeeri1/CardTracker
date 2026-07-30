# Flutter Project Full State Export
Project Path: `C:\Users\Naor\mj_card_tracker`

## 1. Project Directory Structure & Source Code
- **[DIR]** mj_card_tracker/
  - **[FILE]** .flutter-plugins-dependencies
  - **[FILE]** .gitignore
  - **[FILE]** .metadata
  - **[FILE]** README.md
    ```md
    # mj_card_tracker
    
    A new Flutter project.
    
    ## Getting Started
    
    This project is a starting point for a Flutter application.
    
    A few resources to get you started if this is your first Flutter project:
    
    - [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
    - [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
    - [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)
    
    For help getting started with Flutter development, view the
    [online documentation](https://docs.flutter.dev/), which offers tutorials,
    samples, guidance on mobile development, and a full API reference.
    ```
  - **[FILE]** analysis_options.yaml
    ```yaml
    # This file configures the analyzer, which statically analyzes Dart code to
    # check for errors, warnings, and lints.
    #
    # The issues identified by the analyzer are surfaced in the UI of Dart-enabled
    # IDEs (https://dart.dev/tools#ides-and-editors). The analyzer can also be
    # invoked from the command line by running `flutter analyze`.
    
    # The following line activates a set of recommended lints for Flutter apps,
    # packages, and plugins designed to encourage good coding practices.
    include: package:flutter_lints/flutter.yaml
    
    linter:
      # The lint rules applied to this project can be customized in the
      # section below to disable rules from the `package:flutter_lints/flutter.yaml`
      # included above or to enable additional rules. A list of all available lints
      # and their documentation is published at https://dart.dev/lints.
      #
      # Instead of disabling a lint rule for the entire project in the
      # section below, it can also be suppressed for a single line of code
      # or a specific dart file by using the `// ignore: name_of_lint` and
      # `// ignore_for_file: name_of_lint` syntax on the line or in the file
      # producing the lint.
      rules:
        # avoid_print: false  # Uncomment to disable the `avoid_print` rule
        # prefer_single_quotes: true  # Uncomment to enable the `prefer_single_quotes` rule
    
    # Additional information about this file can be found at
    # https://dart.dev/guides/language/analysis-options
    ```
  - **[FILE]** export_project.py
  - **[FILE]** mj_card_tracker.iml
  - **[FILE]** my_project_files.json
    ```json
    {
      "lib\\account_screen.dart": "import 'dart:io';\nimport 'package:flutter/material.dart';\nimport 'package:firebase_auth/firebase_auth.dart';\nimport 'package:cloud_firestore/cloud_firestore.dart';\nimport 'package:firebase_storage/firebase_storage.dart';\nimport 'package:image_picker/image_picker.dart';\nimport 'friend_collection_screen.dart';\n\nclass AccountScreen extends StatefulWidget {\n  const AccountScreen({super.key});\n\n  @override\n  State<AccountScreen> createState() => _AccountScreenState();\n}\n\nclass _AccountScreenState extends State<AccountScreen> {\n  final User? user = FirebaseAuth.instance.currentUser;\n  final _usernameController = TextEditingController();\n  final _friendController = TextEditingController();\n\n  bool _isLoading = true;\n  bool _isSaving = false;\n  String _statusMessage = '';\n  String _friendStatusMessage = '';\n  List<dynamic> _friendsList = [];\n  List<dynamic> _incomingRequests = [];\n  String _profileIcon = 'album';\n  String _profileImageUrl = '';\n  String _privacySetting = 'friends';\n\n  @override\n  void initState() {\n    super.initState();\n    _fetchUserData();\n  }\n\n  Future<void> _fetchUserData() async {\n    if (user == null) return;\n    try {\n      final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();\n      if (doc.exists && doc.data() != null) {\n        final data = doc.data()!;\n        setState(() {\n          _usernameController.text = data['username'] ?? '';\n          _friendsList = data['friends'] ?? [];\n          _incomingRequests = data['incomingRequests'] ?? [];\n          _profileIcon = data['profileIcon'] ?? 'album';\n          _profileImageUrl = data['profileImageBase64'] ?? '';\n          _privacySetting = data['privacySetting'] ?? 'friends';\n        });\n      }\n    } catch (e) {\n      debugPrint(\"Error fetching profile: $e\");\n    } finally {\n      setState(() {\n        _isLoading = false;\n      });\n    }\n  }\n\n  bool _isSafeImage(XFile file) {\n    final name = file.name.toLowerCase();\n    if (name.contains('nsfw') || name.contains('adult') || name.contains('explicit')) {\n      return false;\n    }\n    return true;\n  }\n\n  Future<void> _pickAndUploadImage() async {\n    final ImagePicker picker = ImagePicker();\n    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);\n\n    if (image == null) return;\n\n    if (!_isSafeImage(image)) {\n      if (!mounted) return;\n      ScaffoldMessenger.of(context).showSnackBar(\n        const SnackBar(content: Text('Image flagged by safety filter. Please choose another image.')),\n      );\n      return;\n    }\n\n    try {\n      setState(() => _isLoading = true);\n\n      final storageRef = FirebaseStorage.instance\n          .ref()\n          .child('profile_images')\n          .child('${user!.uid}.jpg');\n\n      File file = File(image.path);\n      await storageRef.putFile(file);\n      String downloadUrl = await storageRef.getDownloadURL();\n\n      setState(() {\n        _profileImageUrl = downloadUrl;\n        _profileIcon = '';\n      });\n\n      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({\n        'profileImageBase64': downloadUrl,\n        'profileIcon': '',\n      }, SetOptions(merge: true));\n\n      if (!mounted) return;\n      ScaffoldMessenger.of(context).showSnackBar(\n        const SnackBar(content: Text('Profile picture updated successfully!')),\n      );\n    } catch (e) {\n      debugPrint(\"Error uploading image: $e\");\n    } finally {\n      setState(() => _isLoading = false);\n    }\n  }\n\n  Future<void> _updateUsername() async {\n    final newUsername = _usernameController.text.trim();\n    if (newUsername.isEmpty) {\n      setState(() => _statusMessage = 'Username cannot be empty.');\n      return;\n    }\n\n    setState(() {\n      _isSaving = true;\n      _statusMessage = '';\n    });\n\n    try {\n      final query = await FirebaseFirestore.instance\n          .collection('users')\n          .where('username', isEqualTo: newUsername)\n          .get();\n\n      if (query.docs.isNotEmpty && query.docs.first.id != user!.uid) {\n        setState(() {\n          _statusMessage = 'Username is already taken!';\n          _isSaving = false;\n        });\n        return;\n      }\n\n      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({\n        'username': newUsername,\n      }, SetOptions(merge: true));\n\n      setState(() {\n        _statusMessage = 'Username updated successfully!';\n        _isSaving = false;\n      });\n    } catch (e) {\n      setState(() {\n        _statusMessage = 'Error updating username: $e';\n        _isSaving = false;\n      });\n    }\n  }\n\n  Future<void> _updatePrivacy(String? value) async {\n    if (value == null) return;\n    setState(() {\n      _privacySetting = value;\n    });\n    try {\n      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({\n        'privacySetting': value,\n      }, SetOptions(merge: true));\n    } catch (e) {\n      debugPrint(\"Error updating privacy: $e\");\n    }\n  }\n\n  Future<void> _sendFriendRequest() async {\n    final targetUsername = _friendController.text.trim();\n    if (targetUsername.isEmpty) return;\n\n    final currentDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();\n    final currentUsername = currentDoc.data()?['username'] ?? '';\n\n    if (targetUsername == currentUsername) {\n      setState(() => _friendStatusMessage = \"You can't add yourself!\");\n      return;\n    }\n\n    if (_friendsList.contains(targetUsername)) {\n      setState(() => _friendStatusMessage = 'Already in your friends list!');\n      return;\n    }\n\n    setState(() {\n      _friendStatusMessage = '';\n    });\n\n    try {\n      final query = await FirebaseFirestore.instance\n          .collection('users')\n          .where('username', isEqualTo: targetUsername)\n          .get();\n\n      if (query.docs.isEmpty) {\n        setState(() => _friendStatusMessage = 'User not found!');\n        return;\n      }\n\n      final targetDoc = query.docs.first;\n      List<dynamic> targetRequests = targetDoc.data()['incomingRequests'] ?? [];\n\n      if (targetRequests.contains(currentUsername)) {\n        setState(() => _friendStatusMessage = 'Friend request already sent!');\n        return;\n      }\n\n      targetRequests.add(currentUsername);\n\n      await targetDoc.reference.set({\n        'incomingRequests': targetRequests,\n      }, SetOptions(merge: true));\n\n      _friendController.clear();\n      setState(() {\n        _friendStatusMessage = 'Friend request sent successfully!';\n      });\n    } catch (e) {\n      setState(() => _friendStatusMessage = 'Error sending request: $e');\n    }\n  }\n\n  Future<void> _acceptFriendRequest(String senderUsername) async {\n    try {\n      final query = await FirebaseFirestore.instance\n          .collection('users')\n          .where('username', isEqualTo: senderUsername)\n          .get();\n\n      if (query.docs.isNotEmpty) {\n        final senderDoc = query.docs.first;\n        List<dynamic> senderFriends = senderDoc.data()['friends'] ?? [];\n        \n        final currentDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();\n        final currentUsername = currentDoc.data()?['username'] ?? '';\n\n        if (!senderFriends.contains(currentUsername)) {\n          senderFriends.add(currentUsername);\n          await senderDoc.reference.set({'friends': senderFriends}, SetOptions(merge: true));\n        }\n\n        if (!_friendsList.contains(senderUsername)) {\n          _friendsList.add(senderUsername);\n        }\n      }\n\n      _incomingRequests.remove(senderUsername);\n\n      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({\n        'friends': _friendsList,\n        'incomingRequests': _incomingRequests,\n      }, SetOptions(merge: true));\n\n      setState(() {});\n    } catch (e) {\n      debugPrint(\"Error accepting request: $e\");\n    }\n  }\n\n  Future<void> _declineFriendRequest(String senderUsername) async {\n    setState(() {\n      _incomingRequests.remove(senderUsername);\n    });\n\n    try {\n      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({\n        'incomingRequests': _incomingRequests,\n      }, SetOptions(merge: true));\n    } catch (e) {\n      debugPrint(\"Error declining request: $e\");\n    }\n  }\n\n  Future<void> _updateProfileIcon(String iconName) async {\n    setState(() {\n      _profileIcon = iconName;\n      _profileImageUrl = '';\n    });\n    try {\n      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({\n        'profileIcon': iconName,\n        'profileImageBase64': '',\n      }, SetOptions(merge: true));\n    } catch (e) {\n      debugPrint(\"Error updating icon: $e\");\n    }\n  }\n\n  Future<void> _deleteAccount() async {\n    showDialog(\n      context: context,\n      builder: (context) => AlertDialog(\n        backgroundColor: const Color(0xFF1E1E1E),\n        title: const Text('Delete Account', style: TextStyle(color: Colors.redAccent)),\n        content: const Text('Are you sure you want to delete your account? All your collection data and profile info will be permanently removed.'),\n        actions: [\n          TextButton(\n            child: const Text('Cancel', style: TextStyle(color: Colors.white)),\n            onPressed: () => Navigator.pop(context),\n          ),\n          TextButton(\n            child: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),\n            onPressed: () async {\n              Navigator.pop(context);\n              try {\n                setState(() => _isLoading = true);\n                await FirebaseFirestore.instance.collection('users').doc(user!.uid).delete();\n                await user!.delete();\n              } catch (e) {\n                debugPrint(\"Error deleting account: $e\");\n                if (!mounted) return;\n                ScaffoldMessenger.of(context).showSnackBar(\n                  const SnackBar(content: Text('Please log out and log back in before deleting your account for security reasons.')),\n                );\n                setState(() => _isLoading = false);\n              }\n            },\n          ),\n        ],\n      ),\n    );\n  }\n\n  @override\n  Widget build(BuildContext context) {\n    return Scaffold(\n      appBar: AppBar(\n        title: const Text('Account Settings', style: TextStyle(fontWeight: FontWeight.bold)),\n        backgroundColor: const Color(0xFF161616),\n        centerTitle: true,\n      ),\n      body: _isLoading\n          ? const Center(child: CircularProgressIndicator(color: Colors.amber))\n          : SingleChildScrollView(\n              padding: const EdgeInsets.all(20.0),\n              child: Column(\n                crossAxisAlignment: CrossAxisAlignment.start,\n                children: [\n                  Center(\n                    child: Column(\n                      children: [\n                        CircleAvatar(\n                          radius: 50,\n                          backgroundColor: Colors.amber.shade900,\n                          backgroundImage: _profileImageUrl.isNotEmpty\n                              ? NetworkImage(_profileImageUrl)\n                              : null,\n                          child: _profileImageUrl.isEmpty\n                              ? Icon(\n                                  _profileIcon == 'star'\n                                      ? Icons.star\n                                      : _profileIcon == 'music_note'\n                                          ? Icons.music_note\n                                          : Icons.album,\n                                  size: 50,\n                                  color: Colors.amber,\n                                )\n                              : null,\n                        ),\n                        const SizedBox(height: 12),\n                        ElevatedButton.icon(\n                          style: ElevatedButton.styleFrom(\n                            backgroundColor: const Color(0xFF2C2C2C),\n                            foregroundColor: Colors.white,\n                          ),\n                          onPressed: _pickAndUploadImage,\n                          icon: const Icon(Icons.photo_library, color: Colors.amber),\n                          label: const Text('Upload from Gallery'),\n                        ),\n                        const SizedBox(height: 8),\n                        const Text('Or choose preset icon:', style: TextStyle(color: Colors.grey, fontSize: 12)),\n                        Row(\n                          mainAxisAlignment: MainAxisAlignment.center,\n                          children: [\n                            IconButton(\n                              icon: const Icon(Icons.album),\n                              color: _profileIcon == 'album' && _profileImageUrl.isEmpty ? Colors.amber : Colors.grey,\n                              onPressed: () => _updateProfileIcon('album'),\n                            ),\n                            IconButton(\n                              icon: const Icon(Icons.star),\n                              color: _profileIcon == 'star' && _profileImageUrl.isEmpty ? Colors.amber : Colors.grey,\n                              onPressed: () => _updateProfileIcon('star'),\n                            ),\n                            IconButton(\n                              icon: const Icon(Icons.music_note),\n                              color: _profileIcon == 'music_note' && _profileImageUrl.isEmpty ? Colors.amber : Colors.grey,\n                              onPressed: () => _updateProfileIcon('music_note'),\n                            ),\n                          ],\n                        ),\n                      ],\n                    ),\n                  ),\n                  const Divider(height: 40, color: Color(0xFF2C2C2C)),\n                  \n                  const Text('Collection Privacy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber)),\n                  const SizedBox(height: 8),\n                  Container(\n                    padding: const EdgeInsets.symmetric(horizontal: 12),\n                    decoration: BoxDecoration(\n                      color: const Color(0xFF1A1A1A),\n                      borderRadius: BorderRadius.circular(10),\n                    ),\n                    child: DropdownButtonHideUnderline(\n                      child: DropdownButton<String>(\n                        value: _privacySetting,\n                        dropdownColor: const Color(0xFF1A1A1A),\n                        isExpanded: true,\n                        items: const [\n                          DropdownMenuItem(value: 'friends', child: Text('Friends Only')),\n                          DropdownMenuItem(value: 'public', child: Text('Public (Anyone)')),\n                          DropdownMenuItem(value: 'private', child: Text('Private (Only Me)')),\n                        ],\n                        onChanged: _updatePrivacy,\n                      ),\n                    ),\n                  ),\n                  const Divider(height: 40, color: Color(0xFF2C2C2C)),\n\n                  const Text('Collector Username', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber)),\n                  const SizedBox(height: 8),\n                  TextField(\n                    controller: _usernameController,\n                    decoration: InputDecoration(\n                      hintText: 'Enter unique username',\n                      filled: true,\n                      fillColor: const Color(0xFF1A1A1A),\n                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),\n                    ),\n                  ),\n                  const SizedBox(height: 12),\n                  SizedBox(\n                    width: double.infinity,\n                    child: ElevatedButton(\n                      style: ElevatedButton.styleFrom(\n                        backgroundColor: Colors.amber,\n                        foregroundColor: Colors.black,\n                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),\n                      ),\n                      onPressed: _isSaving ? null : _updateUsername,\n                      child: _isSaving\n                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))\n                          : const Text('Check Availability & Save Username', style: TextStyle(fontWeight: FontWeight.bold)),\n                    ),\n                  ),\n                  if (_statusMessage.isNotEmpty) ...[\n                    const SizedBox(height: 8),\n                    Text(_statusMessage, style: TextStyle(color: _statusMessage.contains('successfully') ? Colors.green : Colors.red, fontSize: 13)),\n                  ],\n                  const Divider(height: 40, color: Color(0xFF2C2C2C)),\n                  \n                  const Text('Add Collector Friend', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber)),\n                  const SizedBox(height: 8),\n                  Row(\n                    children: [\n                      Expanded(\n                        child: TextField(\n                          controller: _friendController,\n                          decoration: InputDecoration(\n                            hintText: \"Friend's username...\",\n                            filled: true,\n                            fillColor: const Color(0xFF1A1A1A),\n                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),\n                          ),\n                        ),\n                      ),\n                      const SizedBox(width: 10),\n                      ElevatedButton(\n                        style: ElevatedButton.styleFrom(\n                          backgroundColor: Colors.amber,\n                          foregroundColor: Colors.black,\n                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),\n                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),\n                        ),\n                        onPressed: _sendFriendRequest,\n                        child: const Text('Send', style: TextStyle(fontWeight: FontWeight.bold)),\n                      ),\n                    ],\n                  ),\n                  if (_friendStatusMessage.isNotEmpty) ...[\n                    const SizedBox(height: 6),\n                    Text(_friendStatusMessage, style: TextStyle(color: _friendStatusMessage.contains('success') ? Colors.green : Colors.red, fontSize: 12)),\n                  ],\n\n                  if (_incomingRequests.isNotEmpty) ...[\n                    const SizedBox(height: 20),\n                    const Text('Incoming Friend Requests', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.amberAccent)),\n                    const SizedBox(height: 6),\n                    ListView.builder(\n                      shrinkWrap: true,\n                      physics: const NeverScrollableScrollPhysics(),\n                      itemCount: _incomingRequests.length,\n                      itemBuilder: (context, index) {\n                        final sender = _incomingRequests[index];\n                        return Card(\n                          color: const Color(0xFF1A1A1A),\n                          margin: const EdgeInsets.symmetric(vertical: 4),\n                          child: ListTile(\n                            leading: const Icon(Icons.person_add, color: Colors.amber),\n                            title: Text(sender, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),\n                            trailing: Row(\n                              mainAxisSize: MainAxisSize.min,\n                              children: [\n                                IconButton(\n                                  icon: const Icon(Icons.check, color: Colors.green),\n                                  onPressed: () => _acceptFriendRequest(sender),\n                                ),\n                                IconButton(\n                                  icon: const Icon(Icons.close, color: Colors.redAccent),\n                                  onPressed: () => _declineFriendRequest(sender),\n                                ),\n                              ],\n                            ),\n                          ),\n                        );\n                      },\n                    ),\n                  ],\n\n                  const SizedBox(height: 20),\n                  const Text('Collector Friends (Tap to view collection)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber)),\n                  const SizedBox(height: 8),\n                  _friendsList.isEmpty\n                      ? const Text('No collector friends added yet.', style: TextStyle(color: Colors.grey, fontSize: 13))\n                      : ListView.builder(\n                          shrinkWrap: true,\n                          physics: const NeverScrollableScrollPhysics(),\n                          itemCount: _friendsList.length,\n                          itemBuilder: (context, index) {\n                            final friendName = _friendsList[index];\n                            return Card(\n                              color: const Color(0xFF1A1A1A),\n                              margin: const EdgeInsets.symmetric(vertical: 4),\n                              child: ListTile(\n                                leading: const Icon(Icons.person, color: Colors.amber),\n                                title: Text(friendName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),\n                                trailing: IconButton(\n                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),\n                                  onPressed: () async {\n                                    setState(() {\n                                      _friendsList.removeAt(index);\n                                    });\n                                    await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({\n                                      'friends': _friendsList,\n                                    }, SetOptions(merge: true));\n                                  },\n                                ),\n                                onTap: () {\n                                  Navigator.push(\n                                    context,\n                                    MaterialPageRoute(\n                                      builder: (context) => FriendCollectionScreen(friendUsername: friendName),\n                                    ),\n                                  );\n                                },\n                              ),\n                            );\n                          },\n                        ),\n\n                  const Divider(height: 50, color: Color(0xFF2C2C2C)),\n                  \n                  SizedBox(\n                    width: double.infinity,\n                    child: OutlinedButton.icon(\n                      style: OutlinedButton.styleFrom(\n                        foregroundColor: Colors.redAccent,\n                        side: const BorderSide(color: Colors.redAccent),\n                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),\n                        padding: const EdgeInsets.symmetric(vertical: 12),\n                      ),\n                      onPressed: _deleteAccount,\n                      icon: const Icon(Icons.delete_forever),\n                      label: const Text('Delete Account & Data', style: TextStyle(fontWeight: FontWeight.bold)),\n                    ),\n                  ),\n                ],\n              ),\n            ),\n    );\n  }\n}",
      "lib\\auth_screen.dart": "import 'package:flutter/material.dart';\nimport 'package:firebase_auth/firebase_auth.dart';\nimport 'package:cloud_firestore/cloud_firestore.dart';\nimport 'main.dart';\n\nclass AuthScreen extends StatefulWidget {\n  const AuthScreen({super.key});\n\n  @override\n  State<AuthScreen> createState() => _AuthScreenState();\n}\n\nclass _AuthScreenState extends State<AuthScreen> {\n  final _emailController = TextEditingController();\n  final _passwordController = TextEditingController();\n  final _usernameController = TextEditingController();\n\n  bool _isLogin = true;\n  bool _isLoading = false;\n  String _errorMessage = '';\n\n  bool _validatePassword(String password) {\n    if (password.length < 6) {\n      setState(() => _errorMessage = 'Password must be at least 6 characters long.');\n      return false;\n    }\n    return true;\n  }\n\n  Future<void> _submitAuthForm() async {\n    final email = _emailController.text.trim();\n    final password = _passwordController.text.trim();\n    final username = _usernameController.text.trim();\n\n    if (email.isEmpty || password.isEmpty || (!_isLogin && username.isEmpty)) {\n      setState(() => _errorMessage = 'Please fill in all fields.');\n      return;\n    }\n\n    if (!_isLogin && !_validatePassword(password)) {\n      return;\n    }\n\n    if (!_isLogin && username.length < 3) {\n      setState(() => _errorMessage = 'Username must be at least 3 characters.');\n      return;\n    }\n\n    setState(() {\n      _isLoading = true;\n      _errorMessage = '';\n    });\n\n    try {\n      if (_isLogin) {\n        UserCredential userCred = await FirebaseAuth.instance.signInWithEmailAndPassword(\n          email: email,\n          password: password,\n        );\n\n        final userDoc = await FirebaseFirestore.instance.collection('users').doc(userCred.user!.uid).get();\n        if (!userDoc.exists || userDoc.data()?['username'] == null || (userDoc.data()?['username'] as String).isEmpty) {\n          await FirebaseFirestore.instance.collection('users').doc(userCred.user!.uid).set({\n            'username': email.split('@')[0],\n            'email': email,\n            'profileIcon': 'album',\n            'profileImageBase64': '',\n            'friends': [],\n          }, SetOptions(merge: true));\n        }\n      } else {\n        final query = await FirebaseFirestore.instance\n            .collection('users')\n            .where('username', isEqualTo: username)\n            .get();\n\n        if (query.docs.isNotEmpty) {\n          setState(() {\n            _errorMessage = 'Username is already taken. Choose another.';\n            _isLoading = false;\n          });\n          return;\n        }\n\n        UserCredential userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(\n          email: email,\n          password: password,\n        );\n\n        await FirebaseFirestore.instance.collection('users').doc(userCred.user!.uid).set({\n          'username': username,\n          'email': email,\n          'profileIcon': 'album',\n          'profileImageBase64': '',\n          'friends': [],\n          'createdAt': FieldValue.serverTimestamp(),\n        }, SetOptions(merge: true));\n      }\n\n      if (!mounted) return;\n      Navigator.pushReplacement(\n        context,\n        MaterialPageRoute(builder: (context) => const AlbumScreen()),\n      );\n    } on FirebaseAuthException catch (error) {\n      setState(() {\n        _errorMessage = error.message ?? 'An authentication error occurred.';\n        _isLoading = false;\n      });\n    } catch (error) {\n      setState(() {\n        _errorMessage = error.toString();\n        _isLoading = false;\n      });\n    }\n  }\n\n  @override\n  Widget build(BuildContext context) {\n    return Scaffold(\n      body: Center(\n        child: Padding(\n          padding: const EdgeInsets.all(24.0),\n          child: SingleChildScrollView(\n            child: Column(\n              mainAxisAlignment: MainAxisAlignment.center,\n              children: [\n                const Icon(Icons.album, size: 80, color: Colors.amber),\n                const SizedBox(height: 16),\n                Text(\n                  _isLogin ? 'MJ Card Tracker' : 'Create Account',\n                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),\n                ),\n                const SizedBox(height: 32),\n                if (!_isLogin) ...[\n                  TextField(\n                    controller: _usernameController,\n                    decoration: InputDecoration(\n                      labelText: 'Username',\n                      filled: true,\n                      fillColor: const Color(0xFF1E1E1E),\n                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),\n                    ),\n                  ),\n                  const SizedBox(height: 16),\n                ],\n                TextField(\n                  controller: _emailController,\n                  decoration: InputDecoration(\n                    labelText: 'Email',\n                    filled: true,\n                    fillColor: const Color(0xFF1E1E1E),\n                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),\n                  ),\n                ),\n                const SizedBox(height: 16),\n                TextField(\n                  controller: _passwordController,\n                  obscureText: true,\n                  decoration: InputDecoration(\n                    labelText: 'Password (min 6 chars)',\n                    filled: true,\n                    fillColor: const Color(0xFF1E1E1E),\n                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),\n                  ),\n                ),\n                const SizedBox(height: 20),\n                if (_errorMessage.isNotEmpty)\n                  Text(_errorMessage, style: const TextStyle(color: Colors.red, fontSize: 12), textAlign: TextAlign.center),\n                const SizedBox(height: 20),\n                _isLoading\n                    ? const CircularProgressIndicator(color: Colors.amber)\n                    : ElevatedButton(\n                        style: ElevatedButton.styleFrom(\n                          backgroundColor: Colors.amber,\n                          foregroundColor: Colors.black,\n                          minimumSize: const Size.fromHeight(50),\n                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),\n                        ),\n                        onPressed: _submitAuthForm,\n                        child: Text(_isLogin ? 'Login' : 'Sign Up', style: const TextStyle(fontWeight: FontWeight.bold)),\n                      ),\n                TextButton(\n                  onPressed: () {\n                    setState(() {\n                      _isLogin = !_isLogin;\n                      _errorMessage = '';\n                    });\n                  },\n                  child: Text(\n                    _isLogin ? 'Create a new account' : 'I already have an account',\n                    style: const TextStyle(color: Colors.amber),\n                  ),\n                ),\n              ],\n            ),\n          ),\n        ),\n      ),\n    );\n  }\n}",
      "lib\\card_model.dart": "class MJCardItem {\n  final int cardNumber;\n  final String cardName;\n  final String cardType;\n  \n  // A map to store whether each specific variation is checked (e.g., {'Base': true, 'Red /87': false})\n  Map<String, bool> variations;\n\n  // A map to store the specific serial number entered for numbered parallels (e.g., {'Red /87': '42/87'})\n  Map<String, String> serialNumbers;\n\n  String notes;\n\n  MJCardItem({\n    required this.cardNumber,\n    required this.cardName,\n    required this.cardType,\n    Map<String, bool>? variations,\n    Map<String, String>? serialNumbers,\n    this.notes = '',\n  })  : variations = variations ?? {},\n        serialNumbers = serialNumbers ?? {};\n\n  // Helper getter to check if any variation of this card is collected\n  bool get isCollected => variations.values.contains(true);\n\n  // Convert to JSON/Map if you are saving to Firebase or local storage later\n  Map<String, dynamic> toJson() => {\n        'cardNumber': cardNumber,\n        'cardName': cardName,\n        'cardType': cardType,\n        'variations': variations,\n        'serialNumbers': serialNumbers,\n        'notes': notes,\n      };\n\n  // Create from JSON/Map\n  factory MJCardItem.fromJson(Map<String, dynamic> json) {\n    return MJCardItem(\n      cardNumber: json['cardNumber'] ?? 0,\n      cardName: json['cardName'] ?? '',\n      cardType: json['cardType'] ?? '',\n      variations: Map<String, bool>.from(json['variations'] ?? {}),\n      serialNumbers: Map<String, String>.from(json['serialNumbers'] ?? {}),\n      notes: json['notes'] ?? '',\n    );\n  }\n}",
      "lib\\firebase_options.dart": "import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;\nimport 'package:flutter/foundation.dart'\n    show defaultTargetPlatform, kIsWeb, TargetPlatform;\n\nclass DefaultFirebaseOptions {\n  static FirebaseOptions get currentPlatform {\n    if (kIsWeb) {\n      throw UnsupportedError(\n        'DefaultFirebaseOptions have not been configured for web.',\n      );\n    }\n    switch (defaultTargetPlatform) {\n      case TargetPlatform.android:\n        return android;\n      case TargetPlatform.iOS:\n        throw UnsupportedError(\n          'DefaultFirebaseOptions have not been configured for iOS.',\n        );\n      case TargetPlatform.macOS:\n        throw UnsupportedError(\n          'DefaultFirebaseOptions have not been configured for macOS.',\n        );\n      case TargetPlatform.windows:\n        throw UnsupportedError(\n          'DefaultFirebaseOptions have not been configured for windows.',\n        );\n      case TargetPlatform.linux:\n        throw UnsupportedError(\n          'DefaultFirebaseOptions have not been configured for Linux.',\n        );\n      default:\n        throw UnsupportedError(\n          'DefaultFirebaseOptions are not supported for this platform.',\n        );\n    }\n  }\n\n  static const FirebaseOptions android = FirebaseOptions(\n    apiKey: 'AIzaSyBfmLYUUtwHTInPFDdP9FmP_n2UfvHvYys',\n    appId: '1:1036077654913:android:541c4321f9a4230300fe80',\n    messagingSenderId: '1036077654913',\n    projectId: 'mj-card-tracker',\n  );\n}",
      "lib\\friend_collection_screen.dart": "import 'package:flutter/material.dart';\nimport 'package:cloud_firestore/cloud_firestore.dart';\nimport 'card_model.dart';\n\nclass FriendCollectionScreen extends StatefulWidget {\n  const FriendCollectionScreen({super.key, required this.friendUsername});\n  final String friendUsername;\n\n  @override\n  State<FriendCollectionScreen> createState() => _FriendCollectionScreenState();\n}\n\nclass _FriendCollectionScreenState extends State<FriendCollectionScreen> {\n  bool _isLoading = true;\n  bool _isPrivate = false;\n  String _friendProfileIcon = 'album';\n  String _friendImageUrl = '';\n  \n  late final List<MJCardItem> _friendChecklist = _generateFriendChecklist();\n\n  List<MJCardItem> _generateFriendChecklist() {\n    List<MJCardItem> list = [];\n    for (int num = 1; num <= 300; num++) {\n      String name = 'Michael Jackson';\n      String type = 'Base Set';\n      List<String> allowedVariations = [];\n\n      if (num >= 1 && num <= 31) {\n        type = 'Base Set';\n        name = 'Michael Jackson - Base #$num';\n        allowedVariations = ['Base', 'W. Foil', 'Sil. BG', 'BAD BG', 'Red /87', 'Gold /17', 'Plat /15', 'Sig. /07', 'Dia. /01', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl'];\n      } else if (num >= 32 && num <= 56) {\n        type = 'Spotlight Base';\n        name = 'Michael Jackson - Spotlight Base #$num';\n        allowedVariations = ['Base', 'Foil', 'Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'Plat /15', 'Sig. /07', 'Dia. /01', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl'];\n      } else if (num >= 57 && num <= 85) {\n        type = 'Shortprint';\n        name = 'Michael Jackson - Base Shortprint #$num';\n        allowedVariations = ['Base', 'White Foil', 'Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'White /17', 'Blue /17', 'Plat. /15', 'Black Vinyl', 'Blue Vinyl', 'Red Vinyl'];\n      } else if (num >= 86 && num <= 103) {\n        type = 'Throwback';\n        name = 'Michael Jackson - Base Throwback #$num';\n        allowedVariations = ['Base', 'Foil', 'Red /87', 'Gold /17', 'Black /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Black Vinyl'];\n      } else if (num >= 104 && num <= 123) {\n        type = 'VIP Pass';\n        name = 'Michael Jackson - Base VIP Pass #$num';\n        allowedVariations = ['Base', 'White Foil', 'Black Base', 'Black Foil', 'Red /87', 'Gold /17', 'White /17', 'Black /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Black Vinyl', 'White Vinyl'];\n      } else if (num >= 124 && num <= 154) {\n        type = 'SignaGraph';\n        name = 'Michael Jackson - Laser SignaGraph #$num';\n        allowedVariations = ['Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'Blue /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Blue Vinyl'];\n      } else if (num >= 155 && num <= 174) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 1 Post Card #$num';\n        allowedVariations = ['Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'Blue /17', 'Black', 'Gold Vinyl', 'Red Vinyl', 'Blue Vinyl', 'Black Vinyl'];\n      } else if (num >= 175 && num <= 202) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 2 Poster #$num';\n        allowedVariations = ['Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'Blue /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Blue Vinyl'];\n      } else if (num >= 203 && num <= 234) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 3 Gallery #$num';\n        allowedVariations = ['Base', 'White Foil', 'Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'White /17', 'Blue /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Blue Vinyl', 'White Vinyl'];\n      } else if (num >= 235 && num <= 244) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 4 Drip #$num';\n        allowedVariations = ['Base', 'White Foil', 'Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'White /17', 'Blue /17', 'Plat. /15', 'Black Vinyl', 'Blue Vinyl', 'Red Vinyl'];\n      } else if (num >= 245 && num <= 252) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 5 Fire! #$num';\n        allowedVariations = ['Base', 'Foil', 'Red /87', 'Gold /17', 'Black /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Black Vinyl'];\n      } else if (num == 253) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 6 Ticket Stub Die Cut #253';\n        allowedVariations = ['Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'Blue /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Blue Vinyl', 'Plat. Vinyl'];\n      } else if (num == 254) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 7 Headlines #254';\n        allowedVariations = ['Base', 'Foil', 'Black Base', 'Black Foil', 'Red /87', 'Gold /17', 'White /17', 'Black /17', 'Plat. /15', 'Red Vinyl', 'Gold Vinyl', 'Plat. Vinyl', 'White Vinyl', 'Black Vinyl'];\n      } else if (num == 255) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 8 King of Pop Die Cut #255';\n        allowedVariations = ['Base', 'Foil', 'Red /87', 'Gold /17', 'Black /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Black Vinyl'];\n      } else if (num == 256) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 9 Now Presenting #256';\n        allowedVariations = ['Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'Blue /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Blue Vinyl', 'Plat. Vinyl'];\n      } else if (num == 257) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 10 Retro #257';\n        allowedVariations = ['Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'Blue /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Blue Vinyl', 'Plat. Vinyl'];\n      } else if (num == 258) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 11 Canvas #258';\n        allowedVariations = ['Base', 'Foil', 'Red /87', 'Gold /17', 'White /17', 'Plat. /15', 'Red Vinyl', 'Gold Vinyl', 'Plat. Vinyl', 'White Vinyl'];\n      } else if (num == 259) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 12 BAD World Tour Logo #259';\n        allowedVariations = ['Base', 'Foil', 'Red /87', 'Gold /17', 'Black /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Black Vinyl'];\n      } else if (num == 260) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 13 Confetti #260';\n        allowedVariations = ['Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'Blue /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Blue Vinyl', 'Plat. Vinyl'];\n      } else if (num >= 261 && num <= 270) {\n        type = 'Relic Memorabilia';\n        name = 'Michael Jackson - Relic Tour Jacket Memorabilia #$num';\n        allowedVariations = ['Base', 'Foil', 'Red /87', 'Gold /17', 'Black /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Black Vinyl'];\n      } else if (num >= 271 && num <= 281) {\n        type = 'Relic Memorabilia';\n        name = 'Michael Jackson - Relic Poster Memorabilia #$num';\n        allowedVariations = ['Base', 'Foil', 'Red /87', 'Gold /17', 'Black /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Black Vinyl'];\n      } else if (num >= 282 && num <= 285) {\n        type = 'Relic Memorabilia';\n        name = 'Michael Jackson - Relic Ticket Stub Memorabilia #$num';\n        allowedVariations = ['Base', 'Foil', 'Red /87', 'Gold /17', 'Black /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Black Vinyl'];\n      } else if (num == 286) {\n        type = 'Relic Memorabilia';\n        name = 'Michael Jackson - Relic Private Collection Memorabilia #286';\n        allowedVariations = ['Black /87', 'Red /87', 'Gold /17', 'Plat. /15', 'Red Vinyl', 'Gold Vinyl', 'Plat. Vinyl', 'Black Vinyl'];\n      } else if (num >= 287 && num <= 290) {\n        type = 'Cut Autograph';\n        name = 'Michael Jackson - Cut Autograph #$num';\n        allowedVariations = ['Base'];\n      } else if (num >= 291 && num <= 292) {\n        type = 'Cut Autograph';\n        name = 'Michael Jackson - Memorabilia Cut Autograph #$num';\n        allowedVariations = ['Base'];\n      } else if (num >= 293 && num <= 296) {\n        type = 'Gemstone Relic';\n        name = num == 293 ? 'Michael Jackson - Real Ruby Memorabilia #293' : (num == 294 ? 'Michael Jackson - Real Emerald Memorabilia #294' : (num == 295 ? 'Michael Jackson - Real Sapphire Memorabilia #295' : 'Michael Jackson - Real Diamond Memorabilia #296'));\n        allowedVariations = ['Base /10'];\n      } else if (num >= 297 && num <= 300) {\n        type = 'Precious Metal Relic';\n        name = num == 297 ? 'Michael Jackson - Real Silver Memorabilia #297' : (num == 298 ? 'Michael Jackson - Real Gold Memorabilia #298' : (num == 299 ? 'Michael Jackson - Real Platinum Memorabilia #299' : 'Michael Jackson - Real Pearl Memorabilia #300'));\n        allowedVariations = ['Base /10'];\n      }\n\n      Map<String, bool> initialVars = {for (var v in allowedVariations) v: false};\n      list.add(MJCardItem(\n        cardNumber: num,\n        cardName: name,\n        cardType: type,\n        variations: initialVars,\n      ));\n    }\n    return list;\n  }\n\n  @override\n  void initState() {\n    super.initState();\n    _fetchFriendData();\n  }\n\n  Future<void> _fetchFriendData() async {\n    try {\n      final query = await FirebaseFirestore.instance\n          .collection('users')\n          .where('username', isEqualTo: widget.friendUsername)\n          .get();\n\n      if (query.docs.isNotEmpty) {\n        final data = query.docs.first.data();\n        final privacy = data['privacySetting'] ?? 'friends';\n\n        if (privacy == 'private') {\n          setState(() {\n            _isPrivate = true;\n            _isLoading = false;\n          });\n          return;\n        }\n\n        setState(() {\n          _friendProfileIcon = data['profileIcon'] ?? 'album';\n          _friendImageUrl = data['profileImageBase64'] ?? '';\n        });\n\n        final collectedData = data['collectedCards'] as Map<String, dynamic>?;\n        if (collectedData != null) {\n          setState(() {\n            for (var card in _friendChecklist) {\n              if (collectedData.containsKey(card.cardNumber.toString())) {\n                var cardData = collectedData[card.cardNumber.toString()];\n                if (cardData is Map) {\n                  card.variations = Map<String, bool>.from(cardData['variations'] ?? {});\n                  card.serialNumbers = Map<String, String>.from(cardData['serialNumbers'] ?? {});\n                  card.notes = cardData['notes'] ?? '';\n                } else if (cardData is bool) {\n                  if (card.variations.isNotEmpty) {\n                    card.variations[card.variations.keys.first] = cardData;\n                  }\n                }\n              }\n            }\n          });\n        }\n      }\n    } catch (e) {\n      debugPrint(\"Error loading friend collection: $e\");\n    } finally {\n      setState(() {\n        _isLoading = false;\n      });\n    }\n  }\n\n  void _openFriendCardDetailModal(MJCardItem card) {\n    showModalBottomSheet(\n      context: context,\n      isScrollControlled: true,\n      backgroundColor: const Color(0xFF1E1E1E),\n      shape: const RoundedRectangleBorder(\n        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),\n      ),\n      builder: (context) {\n        return Padding(\n          padding: const EdgeInsets.all(20.0),\n          child: SingleChildScrollView(\n            child: Column(\n              mainAxisSize: MainAxisSize.min,\n              crossAxisAlignment: CrossAxisAlignment.start,\n              children: [\n                Row(\n                  mainAxisAlignment: MainAxisAlignment.spaceBetween,\n                  children: [\n                    Text(\n                      '#${card.cardNumber} - ${card.cardName}',\n                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber),\n                    ),\n                    IconButton(\n                      icon: const Icon(Icons.close, color: Colors.white),\n                      onPressed: () => Navigator.pop(context),\n                    ),\n                  ],\n                ),\n                const Divider(color: Colors.grey),\n                const Text('Friend Owned Variations & Serial Numbers:', style: TextStyle(color: Colors.grey, fontSize: 13)),\n                const SizedBox(height: 10),\n                ...card.variations.keys.map((variationName) {\n                  bool isChecked = card.variations[variationName] ?? false;\n                  String serial = card.serialNumbers[variationName] ?? '';\n\n                  return ListTile(\n                    contentPadding: EdgeInsets.zero,\n                    title: Text(variationName, style: const TextStyle(fontSize: 14)),\n                    trailing: Text(\n                      isChecked ? (serial.isNotEmpty ? 'Owned ($serial)' : 'Owned') : 'Missing',\n                      style: TextStyle(\n                        color: isChecked ? Colors.amber : Colors.grey.shade600,\n                        fontWeight: FontWeight.bold,\n                        fontSize: 12,\n                      ),\n                    ),\n                  );\n                }),\n                if (card.notes.isNotEmpty) ...[\n                  const SizedBox(height: 10),\n                  Text('Notes: ${card.notes}', style: const TextStyle(color: Colors.white70, fontSize: 13)),\n                ],\n              ],\n            ),\n          ),\n        );\n      },\n    );\n  }\n\n  @override\n  Widget build(BuildContext context) {\n    if (_isLoading) {\n      return Scaffold(\n        appBar: AppBar(backgroundColor: const Color(0xFF161616)),\n        body: const Center(child: CircularProgressIndicator(color: Colors.amber)),\n      );\n    }\n\n    if (_isPrivate) {\n      return Scaffold(\n        appBar: AppBar(\n          title: Text(\"${widget.friendUsername}'s Collection\", style: const TextStyle(fontWeight: FontWeight.bold)),\n          backgroundColor: const Color(0xFF161616),\n        ),\n        body: Center(\n          child: Column(\n            mainAxisAlignment: MainAxisAlignment.center,\n            children: [\n              const Icon(Icons.lock_outline, size: 60, color: Colors.grey),\n              const SizedBox(height: 16),\n              Text(\n                \"${widget.friendUsername}'s collection is private.\",\n                style: const TextStyle(color: Colors.grey, fontSize: 16),\n              ),\n            ],\n          ),\n        ),\n      );\n    }\n\n    int collectedCount = _friendChecklist.where((card) => card.isCollected).length;\n    double progressPercent = _friendChecklist.isEmpty ? 0.0 : collectedCount / _friendChecklist.length;\n\n    return Scaffold(\n      appBar: AppBar(\n        title: Text(\"${widget.friendUsername}'s Collection\", style: const TextStyle(fontWeight: FontWeight.bold)),\n        backgroundColor: const Color(0xFF161616),\n        centerTitle: true,\n      ),\n      body: Column(\n        children: [\n          Container(\n            padding: const EdgeInsets.all(16),\n            color: const Color(0xFF181818),\n            child: Row(\n              children: [\n                CircleAvatar(\n                  radius: 30,\n                  backgroundColor: Colors.amber.shade900,\n                  backgroundImage: _friendImageUrl.isNotEmpty\n                      ? NetworkImage(_friendImageUrl)\n                      : null,\n                  child: _friendImageUrl.isEmpty\n                      ? Icon(\n                          _friendProfileIcon == 'star'\n                              ? Icons.star\n                              : _friendProfileIcon == 'music_note'\n                                  ? Icons.music_note\n                                  : Icons.album,\n                          size: 30,\n                          color: Colors.amber,\n                        )\n                      : null,\n                ),\n                const SizedBox(width: 16),\n                Expanded(\n                  child: Column(\n                    crossAxisAlignment: CrossAxisAlignment.start,\n                    children: [\n                      Text(widget.friendUsername, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),\n                      const SizedBox(height: 4),\n                      Text(\n                        'Progress: $collectedCount / ${_friendChecklist.length} (${(progressPercent * 100).toStringAsFixed(0)}%)',\n                        style: const TextStyle(color: Colors.amber, fontSize: 13),\n                      ),\n                    ],\n                  ),\n                ),\n              ],\n            ),\n          ),\n          Expanded(\n            child: GridView.builder(\n              padding: const EdgeInsets.all(12.0),\n              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(\n                crossAxisCount: 2,\n                childAspectRatio: 0.72,\n                crossAxisSpacing: 12.0,\n                mainAxisSpacing: 12.0,\n              ),\n              itemCount: _friendChecklist.length,\n              itemBuilder: (context, index) {\n                final card = _friendChecklist[index];\n                return GestureDetector(\n                  onTap: () => _openFriendCardDetailModal(card),\n                  child: Container(\n                    decoration: BoxDecoration(\n                      color: card.isCollected ? const Color(0xFF221E12) : const Color(0xFF1A1A1A),\n                      borderRadius: BorderRadius.circular(14.0),\n                      border: Border.all(\n                        color: card.isCollected ? Colors.amber.shade600 : Colors.grey.shade800,\n                        width: card.isCollected ? 2.0 : 1.0,\n                      ),\n                    ),\n                    child: Padding(\n                      padding: const EdgeInsets.all(10.0),\n                      child: Column(\n                        mainAxisAlignment: MainAxisAlignment.center,\n                        children: [\n                          Row(\n                            mainAxisAlignment: MainAxisAlignment.spaceBetween,\n                            children: [\n                              Text(\n                                '#${card.cardNumber}',\n                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 13),\n                              ),\n                              Icon(\n                                card.isCollected ? Icons.check_circle : Icons.radio_button_unchecked,\n                                color: card.isCollected ? Colors.amber : Colors.grey.shade700,\n                                size: 20,\n                              ),\n                            ],\n                          ),\n                          const Spacer(),\n                          Icon(\n                            card.isCollected ? Icons.album : Icons.lock_outline,\n                            size: 42,\n                            color: card.isCollected ? Colors.amber : Colors.grey.shade700,\n                          ),\n                          const Spacer(),\n                          Text(\n                            card.cardName,\n                            textAlign: TextAlign.center,\n                            maxLines: 2,\n                            overflow: TextOverflow.ellipsis,\n                            style: TextStyle(\n                              fontWeight: FontWeight.bold,\n                              fontSize: 13,\n                              color: card.isCollected ? Colors.white : Colors.grey.shade400,\n                            ),\n                          ),\n                          const SizedBox(height: 4),\n                          Text(\n                            card.cardType,\n                            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),\n                          ),\n                          const SizedBox(height: 8),\n                          Container(\n                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),\n                            decoration: BoxDecoration(\n                              color: card.isCollected ? Colors.amber : Colors.grey.shade800,\n                              borderRadius: BorderRadius.circular(6),\n                            ),\n                            child: Text(\n                              card.isCollected ? 'OWNED' : 'MISSING',\n                              style: TextStyle(\n                                fontSize: 9,\n                                fontWeight: FontWeight.bold,\n                                color: card.isCollected ? Colors.black : Colors.white,\n                              ),\n                            ),\n                          ),\n                        ],\n                      ),\n                    ),\n                  ),\n                );\n              },\n            ),\n          ),\n        ],\n      ),\n    );\n  }\n}",
      "lib\\main.dart": "import 'package:flutter/material.dart';\nimport 'package:firebase_core/firebase_core.dart';\nimport 'package:firebase_auth/firebase_auth.dart';\nimport 'package:cloud_firestore/cloud_firestore.dart';\nimport 'firebase_options.dart';\nimport 'auth_screen.dart';\nimport 'card_model.dart';\nimport 'account_screen.dart';\n\nvoid main() async {\n  WidgetsFlutterBinding.ensureInitialized();\n  await Firebase.initializeApp(\n    options: DefaultFirebaseOptions.currentPlatform,\n  );\n  runTheApp();\n}\n\nvoid runTheApp() {\n  runApp(const MJCardTrackerApp());\n}\n\nclass MJCardTrackerApp extends StatelessWidget {\n  const MJCardTrackerApp({super.key});\n\n  @override\n  Widget build(BuildContext context) {\n    return MaterialApp(\n      debugShowCheckedModeBanner: false,\n      title: 'MJ Card Tracker',\n      theme: ThemeData(\n        brightness: Brightness.dark,\n        primarySwatch: Colors.amber,\n        scaffoldBackgroundColor: const Color(0xFF121212),\n        cardColor: const Color(0xFF1E1E1E),\n        colorScheme: const ColorScheme.dark(\n          primary: Colors.amber,\n          secondary: Colors.amberAccent,\n        ),\n      ),\n      home: StreamBuilder<User?>(\n        stream: FirebaseAuth.instance.authStateChanges(),\n        builder: (context, snapshot) {\n          if (snapshot.connectionState == ConnectionState.waiting) {\n            return const Scaffold(\n              body: Center(\n                child: CircularProgressIndicator(color: Colors.amber),\n              ),\n            );\n          }\n          if (snapshot.hasData) {\n            return const AlbumScreen();\n          }\n          return const AuthScreen();\n        },\n      ),\n    );\n  }\n}\n\nclass AlbumScreen extends StatefulWidget {\n  const AlbumScreen({super.key});\n\n  @override\n  State<AlbumScreen> createState() => _AlbumScreenState();\n}\n\nclass _AlbumScreenState extends State<AlbumScreen> {\n  final User? user = FirebaseAuth.instance.currentUser;\n  \n  late final List<MJCardItem> _masterChecklist = _generateMasterChecklist();\n\n  List<MJCardItem> _generateMasterChecklist() {\n    List<MJCardItem> list = [];\n\n    for (int num = 1; num <= 300; num++) {\n      String name = 'Michael Jackson';\n      String type = 'Base Set';\n      List<String> allowedVariations = [];\n\n      if (num >= 1 && num <= 31) {\n        type = 'Base Set';\n        name = 'Michael Jackson - Base #$num';\n        allowedVariations = ['Base', 'W. Foil', 'Sil. BG', 'BAD BG', 'Red /87', 'Gold /17', 'Plat /15', 'Sig. /07', 'Dia. /01', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl'];\n      } else if (num >= 32 && num <= 56) {\n        type = 'Spotlight Base';\n        name = 'Michael Jackson - Spotlight Base #$num';\n        allowedVariations = ['Base', 'Foil', 'Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'Plat /15', 'Sig. /07', 'Dia. /01', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl'];\n      } else if (num >= 57 && num <= 85) {\n        type = 'Shortprint';\n        name = 'Michael Jackson - Base Shortprint #$num';\n        allowedVariations = ['Base', 'White Foil', 'Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'White /17', 'Blue /17', 'Plat. /15', 'Black Vinyl', 'Blue Vinyl', 'Red Vinyl'];\n      } else if (num >= 86 && num <= 103) {\n        type = 'Throwback';\n        name = 'Michael Jackson - Base Throwback #$num';\n        allowedVariations = ['Base', 'Foil', 'Red /87', 'Gold /17', 'Black /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Black Vinyl'];\n      } else if (num >= 104 && num <= 123) {\n        type = 'VIP Pass';\n        name = 'Michael Jackson - Base VIP Pass #$num';\n        allowedVariations = ['Base', 'White Foil', 'Black Base', 'Black Foil', 'Red /87', 'Gold /17', 'White /17', 'Black /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Black Vinyl', 'White Vinyl'];\n      } else if (num >= 124 && num <= 154) {\n        type = 'SignaGraph';\n        name = 'Michael Jackson - Laser SignaGraph #$num';\n        allowedVariations = ['Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'Blue /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Blue Vinyl'];\n      } else if (num >= 155 && num <= 174) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 1 Post Card #$num';\n        allowedVariations = ['Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'Blue /17', 'Black', 'Gold Vinyl', 'Red Vinyl', 'Blue Vinyl', 'Black Vinyl'];\n      } else if (num >= 175 && num <= 202) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 2 Poster #$num';\n        allowedVariations = ['Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'Blue /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Blue Vinyl'];\n      } else if (num >= 203 && num <= 234) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 3 Gallery #$num';\n        allowedVariations = ['Base', 'White Foil', 'Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'White /17', 'Blue /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Blue Vinyl', 'White Vinyl'];\n      } else if (num >= 235 && num <= 244) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 4 Drip #$num';\n        allowedVariations = ['Base', 'White Foil', 'Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'White /17', 'Blue /17', 'Plat. /15', 'Black Vinyl', 'Blue Vinyl', 'Red Vinyl'];\n      } else if (num >= 245 && num <= 252) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 5 Fire! #$num';\n        allowedVariations = ['Base', 'Foil', 'Red /87', 'Gold /17', 'Black /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Black Vinyl'];\n      } else if (num == 253) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 6 Ticket Stub Die Cut #253';\n        allowedVariations = ['Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'Blue /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Blue Vinyl', 'Plat. Vinyl'];\n      } else if (num == 254) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 7 Headlines #254';\n        allowedVariations = ['Base', 'Foil', 'Black Base', 'Black Foil', 'Red /87', 'Gold /17', 'White /17', 'Black /17', 'Plat. /15', 'Red Vinyl', 'Gold Vinyl', 'Plat. Vinyl', 'White Vinyl', 'Black Vinyl'];\n      } else if (num == 255) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 8 King of Pop Die Cut #255';\n        allowedVariations = ['Base', 'Foil', 'Red /87', 'Gold /17', 'Black /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Black Vinyl'];\n      } else if (num == 256) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 9 Now Presenting #256';\n        allowedVariations = ['Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'Blue /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Blue Vinyl', 'Plat. Vinyl'];\n      } else if (num == 257) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 10 Retro #257';\n        allowedVariations = ['Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'Blue /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Blue Vinyl', 'Plat. Vinyl'];\n      } else if (num == 258) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 11 Canvas #258';\n        allowedVariations = ['Base', 'Foil', 'Red /87', 'Gold /17', 'White /17', 'Plat. /15', 'Red Vinyl', 'Gold Vinyl', 'Plat. Vinyl', 'White Vinyl'];\n      } else if (num == 259) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 12 BAD World Tour Logo #259';\n        allowedVariations = ['Base', 'Foil', 'Red /87', 'Gold /17', 'Black /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Black Vinyl'];\n      } else if (num == 260) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 13 Confetti #260';\n        allowedVariations = ['Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'Blue /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Blue Vinyl', 'Plat. Vinyl'];\n      } else if (num >= 261 && num <= 270) {\n        type = 'Relic Memorabilia';\n        name = 'Michael Jackson - Relic Tour Jacket Memorabilia #$num';\n        allowedVariations = ['Base', 'Foil', 'Red /87', 'Gold /17', 'Black /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Black Vinyl'];\n      } else if (num >= 271 && num <= 281) {\n        type = 'Relic Memorabilia';\n        name = 'Michael Jackson - Relic Poster Memorabilia #$num';\n        allowedVariations = ['Base', 'Foil', 'Red /87', 'Gold /17', 'Black /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Black Vinyl'];\n      } else if (num >= 282 && num <= 285) {\n        type = 'Relic Memorabilia';\n        name = 'Michael Jackson - Relic Ticket Stub Memorabilia #$num';\n        allowedVariations = ['Base', 'Foil', 'Red /87', 'Gold /17', 'Black /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Black Vinyl'];\n      } else if (num == 286) {\n        type = 'Relic Memorabilia';\n        name = 'Michael Jackson - Relic Private Collection Memorabilia #286';\n        allowedVariations = ['Black /87', 'Red /87', 'Gold /17', 'Plat. /15', 'Red Vinyl', 'Gold Vinyl', 'Plat. Vinyl', 'Black Vinyl'];\n      } else if (num >= 287 && num <= 290) {\n        type = 'Cut Autograph';\n        name = 'Michael Jackson - Cut Autograph #$num';\n        allowedVariations = ['Base'];\n      } else if (num >= 291 && num <= 292) {\n        type = 'Cut Autograph';\n        name = 'Michael Jackson - Memorabilia Cut Autograph #$num';\n        allowedVariations = ['Base'];\n      } else if (num >= 293 && num <= 296) {\n        type = 'Gemstone Relic';\n        name = num == 293 ? 'Michael Jackson - Real Ruby Memorabilia #293' : (num == 294 ? 'Michael Jackson - Real Emerald Memorabilia #294' : (num == 295 ? 'Michael Jackson - Real Sapphire Memorabilia #295' : 'Michael Jackson - Real Diamond Memorabilia #296'));\n        allowedVariations = ['Base /10'];\n      } else if (num >= 297 && num <= 300) {\n        type = 'Precious Metal Relic';\n        name = num == 297 ? 'Michael Jackson - Real Silver Memorabilia #297' : (num == 298 ? 'Michael Jackson - Real Gold Memorabilia #298' : (num == 299 ? 'Michael Jackson - Real Platinum Memorabilia #299' : 'Michael Jackson - Real Pearl Memorabilia #300'));\n        allowedVariations = ['Base /10'];\n      }\n\n      Map<String, bool> initialVars = {for (var v in allowedVariations) v: false};\n      list.add(MJCardItem(\n        cardNumber: num,\n        cardName: name,\n        cardType: type,\n        variations: initialVars,\n      ));\n    }\n    return list;\n  }\n\n  String _searchQuery = '';\n  String _selectedCategory = 'All';\n  bool _isLoading = true;\n\n  final List<String> _categories = [\n    'All', \n    'Base Set', \n    'Spotlight Base', \n    'Shortprint', \n    'Throwback', \n    'VIP Pass', \n    'SignaGraph', \n    'Inserts', \n    'Relic Memorabilia', \n    'Cut Autograph', \n    'Gemstone Relic'\n  ];\n\n  @override\n  void initState() {\n    super.initState();\n    _loadUserCollection();\n  }\n\n  Future<void> _loadUserCollection() async {\n    if (user == null) return;\n    try {\n      final docRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);\n      final docSnap = await docRef.get();\n\n      if (docSnap.exists && docSnap.data() != null) {\n        final rawData = docSnap.data()!['collectedCards'];\n        if (rawData is Map) {\n          setState(() {\n            for (var card in _masterChecklist) {\n              final cardKey = card.cardNumber.toString();\n              if (rawData.containsKey(cardKey)) {\n                var cardData = rawData[cardKey];\n                if (cardData is Map) {\n                  try {\n                    card.variations = Map<String, bool>.from(\n                      (cardData['variations'] as Map?)?.map((k, v) => MapEntry(k.toString(), v == true)) ?? {}\n                    );\n                    card.serialNumbers = Map<String, String>.from(\n                      (cardData['serialNumbers'] as Map?)?.map((k, v) => MapEntry(k.toString(), v?.toString() ?? '')) ?? {}\n                    );\n                    card.notes = cardData['notes']?.toString() ?? '';\n                  } catch (e) {\n                    debugPrint(\"Error parsing map data for card $cardKey: $e\");\n                  }\n                } else if (cardData is bool && card.variations.isNotEmpty) {\n                  String firstKey = card.variations.keys.first;\n                  card.variations[firstKey] = cardData;\n                }\n              }\n            }\n          });\n        }\n      }\n    } catch (e) {\n      debugPrint(\"Error loading collection: $e\");\n    } finally {\n      setState(() {\n        _isLoading = false;\n      });\n    }\n  }\n\n  Future<void> _saveCollectionToFirebase() async {\n    if (user == null) return;\n    try {\n      Map<String, dynamic> updateData = {};\n      for (var item in _masterChecklist) {\n        updateData[item.cardNumber.toString()] = item.toJson();\n      }\n\n      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({\n        'collectedCards': updateData,\n        'lastUpdated': FieldValue.serverTimestamp(),\n      }, SetOptions(merge: true));\n    } catch (e) {\n      debugPrint(\"Error saving collection: $e\");\n    }\n  }\n\n  void _openCardDetailModal(MJCardItem card) {\n    Map<String, TextEditingController> controllers = {};\n    for (var entry in card.serialNumbers.entries) {\n      controllers[entry.key] = TextEditingController(text: entry.value);\n    }\n    \n    final notesController = TextEditingController(text: card.notes);\n\n    showModalBottomSheet(\n      context: context,\n      isScrollControlled: true,\n      backgroundColor: const Color(0xFF1E1E1E),\n      shape: const RoundedRectangleBorder(\n        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),\n      ),\n      builder: (context) {\n        return StatefulBuilder(\n          builder: (BuildContext context, StateSetter setModalState) {\n            return Padding(\n              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),\n              child: SingleChildScrollView(\n                child: Column(\n                  mainAxisSize: MainAxisSize.min,\n                  crossAxisAlignment: CrossAxisAlignment.start,\n                  children: [\n                    Row(\n                      mainAxisAlignment: MainAxisAlignment.spaceBetween,\n                      children: [\n                        Text(\n                          '#${card.cardNumber} - ${card.cardName}',\n                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber),\n                        ),\n                        IconButton(\n                          icon: const Icon(Icons.close, color: Colors.white),\n                          onPressed: () => Navigator.pop(context),\n                        ),\n                      ],\n                    ),\n                    const Divider(color: Colors.grey),\n                    const Text('Select Variations Owned & Enter Serial Numbers:', style: TextStyle(color: Colors.grey, fontSize: 13)),\n                    const SizedBox(height: 10),\n                    ...card.variations.keys.map((variationName) {\n                      bool isChecked = card.variations[variationName] ?? false;\n                      bool isNumbered = variationName.contains('/') || variationName.contains('/10');\n\n                      if (isNumbered && isChecked && !controllers.containsKey(variationName)) {\n                        controllers[variationName] = TextEditingController(text: card.serialNumbers[variationName] ?? '');\n                      }\n\n                      return Column(\n                        crossAxisAlignment: CrossAxisAlignment.start,\n                        children: [\n                          CheckboxListTile(\n                            title: Text(variationName, style: const TextStyle(fontSize: 14)),\n                            value: isChecked,\n                            activeColor: Colors.amber,\n                            checkColor: Colors.black,\n                            contentPadding: EdgeInsets.zero,\n                            onChanged: (bool? value) {\n                              setModalState(() {\n                                setState(() {\n                                  card.variations[variationName] = value ?? false;\n                                  if (!(value ?? false)) {\n                                    card.serialNumbers.remove(variationName);\n                                    controllers.remove(variationName);\n                                  } else {\n                                    if (!controllers.containsKey(variationName)) {\n                                      controllers[variationName] = TextEditingController();\n                                    }\n                                  }\n                                });\n                              });\n                              _saveCollectionToFirebase();\n                            },\n                          ),\n                          if (isChecked && isNumbered)\n                            Padding(\n                              padding: const EdgeInsets.only(left: 16, bottom: 8),\n                              child: TextField(\n                                controller: controllers[variationName],\n                                decoration: InputDecoration(\n                                  labelText: 'Enter Serial Number (e.g. 12/87)',\n                                  labelStyle: const TextStyle(fontSize: 12, color: Colors.amber),\n                                  filled: true,\n                                  fillColor: const Color(0xFF141414),\n                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),\n                                  isDense: true,\n                                ),\n                                onChanged: (val) {\n                                  card.serialNumbers[variationName] = val;\n                                  _saveCollectionToFirebase();\n                                },\n                              ),\n                            ),\n                        ],\n                      );\n                    }),\n                    const SizedBox(height: 10),\n                    TextField(\n                      controller: notesController,\n                      decoration: InputDecoration(\n                        labelText: 'Notes (Condition, Grade, etc.)',\n                        labelStyle: const TextStyle(color: Colors.grey),\n                        filled: true,\n                        fillColor: const Color(0xFF141414),\n                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),\n                      ),\n                      onChanged: (val) {\n                        card.notes = val;\n                        _saveCollectionToFirebase();\n                      },\n                    ),\n                  ],\n                ),\n              ),\n            );\n          },\n        );\n      },\n    );\n  }\n\n  @override\n  Widget build(BuildContext context) {\n    if (_isLoading) {\n      return const Scaffold(\n        body: Center(child: CircularProgressIndicator(color: Colors.amber)),\n      );\n    }\n\n    List<MJCardItem> filteredList = _masterChecklist.where((card) {\n      final matchesSearch = card.cardName.toLowerCase().contains(_searchQuery.toLowerCase()) ||\n          card.cardNumber.toString().contains(_searchQuery) ||\n          card.cardType.toLowerCase().contains(_searchQuery.toLowerCase());\n      \n      final matchesCategory = _selectedCategory == 'All' || card.cardType == _selectedCategory;\n\n      return matchesSearch && matchesCategory;\n    }).toList();\n\n    int collectedCount = _masterChecklist.where((card) => card.isCollected).length;\n    double progressPercent = _masterChecklist.isEmpty ? 0.0 : collectedCount / _masterChecklist.length;\n\n    return Scaffold(\n      appBar: AppBar(\n        title: const Text('Bad World Tour Tracker', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),\n        centerTitle: true,\n        backgroundColor: const Color(0xFF161616),\n        elevation: 0,\n        actions: [\n          IconButton(\n            icon: const Icon(Icons.person_outline, color: Colors.amber),\n            onPressed: () {\n              Navigator.push(\n                context,\n                MaterialPageRoute(builder: (context) => const AccountScreen()),\n              );\n            },\n          ),\n          IconButton(\n            icon: const Icon(Icons.logout, color: Colors.amber),\n            onPressed: () async {\n              await FirebaseAuth.instance.signOut();\n            },\n          ),\n        ],\n      ),\n      body: Column(\n        children: [\n          Container(\n            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),\n            decoration: const BoxDecoration(\n              color: Color(0xFF181818),\n              border: Border(bottom: BorderSide(color: Color(0xFF2C2C2C))),\n            ),\n            child: Column(\n              children: [\n                Row(\n                  mainAxisAlignment: MainAxisAlignment.spaceBetween,\n                  children: [\n                    const Text(\n                      'Collection Progress',\n                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),\n                    ),\n                    Text(\n                      '$collectedCount / ${_masterChecklist.length} (${(progressPercent * 100).toStringAsFixed(0)}%)',\n                      style: const TextStyle(\n                        fontSize: 14,\n                        fontWeight: FontWeight.bold,\n                        color: Colors.amber,\n                      ),\n                    ),\n                  ],\n                ),\n                const SizedBox(height: 10),\n                ClipRRect(\n                  borderRadius: BorderRadius.circular(10),\n                  child: LinearProgressIndicator(\n                    value: progressPercent,\n                    minHeight: 8,\n                    backgroundColor: const Color(0xFF2C2C2C),\n                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),\n                  ),\n                ),\n              ],\n            ),\n          ),\n          Padding(\n            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),\n            child: TextField(\n              onChanged: (value) => setState(() => _searchQuery = value),\n              decoration: InputDecoration(\n                hintText: 'Search by card #, name, or set type...',\n                hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),\n                prefixIcon: const Icon(Icons.search, color: Colors.amber),\n                filled: true,\n                fillColor: const Color(0xFF1A1A1A),\n                contentPadding: const EdgeInsets.symmetric(vertical: 0),\n                border: OutlineInputBorder(\n                  borderRadius: BorderRadius.circular(12.0),\n                  borderSide: BorderSide.none,\n                ),\n              ),\n            ),\n          ),\n          SizedBox(\n            height: 50,\n            child: ListView.builder(\n              scrollDirection: Axis.horizontal,\n              padding: const EdgeInsets.symmetric(horizontal: 12),\n              itemCount: _categories.length,\n              itemBuilder: (context, index) {\n                final category = _categories[index];\n                final isSelected = _selectedCategory == category;\n                return Padding(\n                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),\n                  child: ChoiceChip(\n                    label: Text(category),\n                    selected: isSelected,\n                    selectedColor: Colors.amber,\n                    backgroundColor: const Color(0xFF1E1E1E),\n                    labelStyle: TextStyle(\n                      color: isSelected ? Colors.black : Colors.white70,\n                      fontWeight: FontWeight.bold,\n                      fontSize: 12,\n                    ),\n                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),\n                    onSelected: (selected) {\n                      setState(() {\n                        _selectedCategory = category;\n                      });\n                    },\n                  ),\n                );\n              },\n            ),\n          ),\n          Expanded(\n            child: filteredList.isEmpty\n                ? Center(\n                    child: Text(\n                      'No cards found',\n                      style: TextStyle(color: Colors.grey.shade600, fontSize: 16),\n                    ),\n                  )\n                : GridView.builder(\n                    padding: const EdgeInsets.all(12.0),\n                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(\n                      crossAxisCount: 2,\n                      childAspectRatio: 0.72,\n                      crossAxisSpacing: 12.0,\n                      mainAxisSpacing: 12.0,\n                    ),\n                    itemCount: filteredList.length,\n                    itemBuilder: (context, index) {\n                      final card = filteredList[index];\n                      return GestureDetector(\n                        onTap: () => _openCardDetailModal(card),\n                        child: AnimatedContainer(\n                          duration: const Duration(milliseconds: 250),\n                          decoration: BoxDecoration(\n                            color: card.isCollected ? const Color(0xFF221E12) : const Color(0xFF1A1A1A),\n                            borderRadius: BorderRadius.circular(14.0),\n                            border: Border.all(\n                              color: card.isCollected ? Colors.amber.shade600 : Colors.grey.shade800,\n                              width: card.isCollected ? 2.0 : 1.0,\n                            ),\n                          ),\n                          child: Padding(\n                            padding: const EdgeInsets.all(10.0),\n                            child: Column(\n                              mainAxisAlignment: MainAxisAlignment.center,\n                              children: [\n                                Row(\n                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,\n                                  children: [\n                                    Text(\n                                      '#${card.cardNumber}',\n                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 13),\n                                    ),\n                                    Icon(\n                                      card.isCollected ? Icons.check_circle : Icons.radio_button_unchecked,\n                                      color: card.isCollected ? Colors.amber : Colors.grey.shade700,\n                                      size: 20,\n                                    ),\n                                  ],\n                                ),\n                                const Spacer(),\n                                Icon(\n                                  card.isCollected ? Icons.album : Icons.lock_outline,\n                                  size: 42,\n                                  color: card.isCollected ? Colors.amber : Colors.grey.shade700,\n                                ),\n                                const Spacer(),\n                                Text(\n                                  card.cardName,\n                                  textAlign: TextAlign.center,\n                                  maxLines: 2,\n                                  overflow: TextOverflow.ellipsis,\n                                  style: TextStyle(\n                                    fontWeight: FontWeight.bold,\n                                    fontSize: 13,\n                                    color: card.isCollected ? Colors.white : Colors.grey.shade400,\n                                  ),\n                                ),\n                                const SizedBox(height: 4),\n                                Text(\n                                  card.cardType,\n                                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),\n                                ),\n                                const SizedBox(height: 8),\n                                Container(\n                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),\n                                  decoration: BoxDecoration(\n                                    color: card.isCollected ? Colors.amber : Colors.grey.shade800,\n                                    borderRadius: BorderRadius.circular(6),\n                                  ),\n                                  child: Text(\n                                    card.isCollected ? 'OWNED' : 'MISSING',\n                                    style: TextStyle(\n                                      fontSize: 9,\n                                      fontWeight: FontWeight.bold,\n                                      color: card.isCollected ? Colors.black : Colors.white,\n                                    ),\n                                  ),\n                                ),\n                              ],\n                            ),\n                          ),\n                        ),\n                      );\n                    },\n                  ),\n          ),\n        ],\n      ),\n    );\n  }\n}",
      "lib\\username_setup_screen.dart": "import 'package:flutter/material.dart';\nimport 'package:firebase_auth/firebase_auth.dart';\nimport 'package:cloud_firestore/cloud_firestore.dart';\nimport 'main.dart';\n\nclass UsernameSetupScreen extends StatefulWidget {\n  const UsernameSetupScreen({super.key, required this.user});\n  final User user;\n\n  @override\n  State<UsernameSetupScreen> createState() => _UsernameSetupScreenState();\n}\n\nclass _UsernameSetupScreenState extends State<UsernameSetupScreen> {\n  final _usernameController = TextEditingController();\n  bool _isLoading = false;\n  String _errorMessage = '';\n\n  Future<void> _saveUsernameAndProceed() async {\n    final username = _usernameController.text.trim();\n    if (username.length < 3) {\n      setState(() => _errorMessage = 'Username must be at least 3 characters.');\n      return;\n    }\n\n    setState(() {\n      _isLoading = true;\n      _errorMessage = '';\n    });\n\n    try {\n      // Check availability in database\n      final query = await FirebaseFirestore.instance\n          .collection('users')\n          .where('username', isEqualTo: username)\n          .get();\n\n      if (query.docs.isNotEmpty) {\n        setState(() {\n          _errorMessage = 'Username is already taken. Choose another.';\n          _isLoading = false;\n        });\n        return;\n      }\n\n      // Save user profile data\n      await FirebaseFirestore.instance.collection('users').doc(widget.user.uid).set({\n        'username': username,\n        'email': widget.user.email,\n        'profileIcon': 'album',\n        'profileImageBase64': '',\n        'friends': [],\n        'createdAt': FieldValue.serverTimestamp(),\n      }, SetOptions(merge: true));\n\n      if (!mounted) return;\n      Navigator.pushReplacement(\n        context,\n        MaterialPageRoute(builder: (context) => const AlbumScreen()),\n      );\n    } catch (e) {\n      setState(() {\n        _errorMessage = 'Error saving username: $e';\n        _isLoading = false;\n      });\n    }\n  }\n\n  @override\n  Widget build(BuildContext context) {\n    return Scaffold(\n      body: Padding(\n        padding: const EdgeInsets.all(24.0),\n        child: Center(\n          child: SingleChildScrollView(\n            child: Column(\n              mainAxisAlignment: MainAxisAlignment.center,\n              children: [\n                const Icon(Icons.person_add, size: 70, color: Colors.amber),\n                const SizedBox(height: 16),\n                const Text(\n                  'Choose Your Collector Username',\n                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),\n                  textAlign: TextAlign.center,\n                ),\n                const SizedBox(height: 8),\n                const Text(\n                  'This is how other collectors will find you.',\n                  style: TextStyle(color: Colors.grey, fontSize: 13),\n                  textAlign: TextAlign.center,\n                ),\n                const SizedBox(height: 32),\n                TextField(\n                  controller: _usernameController,\n                  decoration: InputDecoration(\n                    labelText: 'Username',\n                    filled: true,\n                    fillColor: const Color(0xFF1E1E1E),\n                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),\n                  ),\n                ),\n                const SizedBox(height: 16),\n                if (_errorMessage.isNotEmpty)\n                  Text(_errorMessage, style: const TextStyle(color: Colors.red, fontSize: 12), textAlign: TextAlign.center),\n                const SizedBox(height: 20),\n                _isLoading\n                    ? const CircularProgressIndicator(color: Colors.amber)\n                    : ElevatedButton(\n                        style: ElevatedButton.styleFrom(\n                          backgroundColor: Colors.amber,\n                          foregroundColor: Colors.black,\n                          minimumSize: const Size.fromHeight(50),\n                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),\n                        ),\n                        onPressed: _saveUsernameAndProceed,\n                        child: const Text('Start Collecting', style: TextStyle(fontWeight: FontWeight.bold)),\n                      ),\n              ],\n            ),\n          ),\n        ),\n      ),\n    );\n  }\n}",
      "pubspec.yaml": "name: mj_card_tracker\ndescription: \"Keepsake: MJ Card Collector app.\"\npublish_to: 'none'\n\nversion: 1.0.0+1\n\nenvironment:\n  sdk: ^3.12.0\n\ndependencies:\n  flutter:\n    sdk: flutter\n  firebase_core: ^3.6.0\n  firebase_auth: ^5.3.1\n  cloud_firestore: ^5.4.4\n  firebase_storage: ^12.3.0\n  image_picker: ^1.1.2\n\ndev_dependencies:\n  flutter_test:\n    sdk: flutter\n  flutter_lints: ^5.0.0\n  flutter_launcher_icons: \"^0.14.4\"\n\nflutter_launcher_icons:\n  image_path: \"assets/LOGOPNG.png\"\n  android: true\n  ios: true\n\nflutter:\n  uses-material-design: true\n\n  assets:\n    - assets/"
    }
    ```
  - **[FILE]** project_dump.json
    ```json
    {
      "analysis_options.yaml": "# This file configures the analyzer, which statically analyzes Dart code to\n# check for errors, warnings, and lints.\n#\n# The issues identified by the analyzer are surfaced in the UI of Dart-enabled\n# IDEs (https://dart.dev/tools#ides-and-editors). The analyzer can also be\n# invoked from the command line by running `flutter analyze`.\n\n# The following line activates a set of recommended lints for Flutter apps,\n# packages, and plugins designed to encourage good coding practices.\ninclude: package:flutter_lints/flutter.yaml\n\nlinter:\n  # The lint rules applied to this project can be customized in the\n  # section below to disable rules from the `package:flutter_lints/flutter.yaml`\n  # included above or to enable additional rules. A list of all available lints\n  # and their documentation is published at https://dart.dev/lints.\n  #\n  # Instead of disabling a lint rule for the entire project in the\n  # section below, it can also be suppressed for a single line of code\n  # or a specific dart file by using the `// ignore: name_of_lint` and\n  # `// ignore_for_file: name_of_lint` syntax on the line or in the file\n  # producing the lint.\n  rules:\n    # avoid_print: false  # Uncomment to disable the `avoid_print` rule\n    # prefer_single_quotes: true  # Uncomment to enable the `prefer_single_quotes` rule\n\n# Additional information about this file can be found at\n# https://dart.dev/guides/language/analysis-options\n",
      "pubspec.yaml": "name: mj_card_tracker\ndescription: \"Keepsake: MJ Card Collector app.\"\npublish_to: 'none'\n\nversion: 1.0.0+1\n\nenvironment:\n  sdk: ^3.12.0\n\ndependencies:\n  flutter:\n    sdk: flutter\n  firebase_core: ^3.6.0\n  firebase_auth: ^5.3.1\n  cloud_firestore: ^5.4.4\n  firebase_storage: ^12.3.0\n  image_picker: ^1.1.2\n\ndev_dependencies:\n  flutter_test:\n    sdk: flutter\n  flutter_lints: ^5.0.0\n  flutter_launcher_icons: \"^0.14.4\"\n\nflutter_launcher_icons:\n  image_path: \"assets/LOGOPNG.png\"\n  android: true\n  ios: true\n\nflutter:\n  uses-material-design: true\n\n  assets:\n    - assets/",
      "lib\\account_screen.dart": "import 'dart:io';\nimport 'package:flutter/material.dart';\nimport 'package:firebase_auth/firebase_auth.dart';\nimport 'package:cloud_firestore/cloud_firestore.dart';\nimport 'package:firebase_storage/firebase_storage.dart';\nimport 'package:image_picker/image_picker.dart';\nimport 'friend_collection_screen.dart';\n\nclass AccountScreen extends StatefulWidget {\n  const AccountScreen({super.key});\n\n  @override\n  State<AccountScreen> createState() => _AccountScreenState();\n}\n\nclass _AccountScreenState extends State<AccountScreen> {\n  final User? user = FirebaseAuth.instance.currentUser;\n  final _usernameController = TextEditingController();\n  final _friendController = TextEditingController();\n\n  bool _isLoading = true;\n  bool _isSaving = false;\n  String _statusMessage = '';\n  String _friendStatusMessage = '';\n  List<dynamic> _friendsList = [];\n  List<dynamic> _incomingRequests = [];\n  String _profileIcon = 'album';\n  String _profileImageUrl = '';\n  String _privacySetting = 'friends';\n\n  @override\n  void initState() {\n    super.initState();\n    _fetchUserData();\n  }\n\n  Future<void> _fetchUserData() async {\n    if (user == null) return;\n    try {\n      final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();\n      if (doc.exists && doc.data() != null) {\n        final data = doc.data()!;\n        setState(() {\n          _usernameController.text = data['username'] ?? '';\n          _friendsList = data['friends'] ?? [];\n          _incomingRequests = data['incomingRequests'] ?? [];\n          _profileIcon = data['profileIcon'] ?? 'album';\n          _profileImageUrl = data['profileImageBase64'] ?? '';\n          _privacySetting = data['privacySetting'] ?? 'friends';\n        });\n      }\n    } catch (e) {\n      debugPrint(\"Error fetching profile: $e\");\n    } finally {\n      setState(() {\n        _isLoading = false;\n      });\n    }\n  }\n\n  bool _isSafeImage(XFile file) {\n    final name = file.name.toLowerCase();\n    if (name.contains('nsfw') || name.contains('adult') || name.contains('explicit')) {\n      return false;\n    }\n    return true;\n  }\n\n  Future<void> _pickAndUploadImage() async {\n    final ImagePicker picker = ImagePicker();\n    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);\n\n    if (image == null) return;\n\n    if (!_isSafeImage(image)) {\n      if (!mounted) return;\n      ScaffoldMessenger.of(context).showSnackBar(\n        const SnackBar(content: Text('Image flagged by safety filter. Please choose another image.')),\n      );\n      return;\n    }\n\n    try {\n      setState(() => _isLoading = true);\n\n      final storageRef = FirebaseStorage.instance\n          .ref()\n          .child('profile_images')\n          .child('${user!.uid}.jpg');\n\n      File file = File(image.path);\n      await storageRef.putFile(file);\n      String downloadUrl = await storageRef.getDownloadURL();\n\n      setState(() {\n        _profileImageUrl = downloadUrl;\n        _profileIcon = '';\n      });\n\n      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({\n        'profileImageBase64': downloadUrl,\n        'profileIcon': '',\n      }, SetOptions(merge: true));\n\n      if (!mounted) return;\n      ScaffoldMessenger.of(context).showSnackBar(\n        const SnackBar(content: Text('Profile picture updated successfully!')),\n      );\n    } catch (e) {\n      debugPrint(\"Error uploading image: $e\");\n    } finally {\n      setState(() => _isLoading = false);\n    }\n  }\n\n  Future<void> _updateUsername() async {\n    final newUsername = _usernameController.text.trim();\n    if (newUsername.isEmpty) {\n      setState(() => _statusMessage = 'Username cannot be empty.');\n      return;\n    }\n\n    setState(() {\n      _isSaving = true;\n      _statusMessage = '';\n    });\n\n    try {\n      final query = await FirebaseFirestore.instance\n          .collection('users')\n          .where('username', isEqualTo: newUsername)\n          .get();\n\n      if (query.docs.isNotEmpty && query.docs.first.id != user!.uid) {\n        setState(() {\n          _statusMessage = 'Username is already taken!';\n          _isSaving = false;\n        });\n        return;\n      }\n\n      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({\n        'username': newUsername,\n      }, SetOptions(merge: true));\n\n      setState(() {\n        _statusMessage = 'Username updated successfully!';\n        _isSaving = false;\n      });\n    } catch (e) {\n      setState(() {\n        _statusMessage = 'Error updating username: $e';\n        _isSaving = false;\n      });\n    }\n  }\n\n  Future<void> _updatePrivacy(String? value) async {\n    if (value == null) return;\n    setState(() {\n      _privacySetting = value;\n    });\n    try {\n      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({\n        'privacySetting': value,\n      }, SetOptions(merge: true));\n    } catch (e) {\n      debugPrint(\"Error updating privacy: $e\");\n    }\n  }\n\n  Future<void> _sendFriendRequest() async {\n    final targetUsername = _friendController.text.trim();\n    if (targetUsername.isEmpty) return;\n\n    final currentDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();\n    final currentUsername = currentDoc.data()?['username'] ?? '';\n\n    if (targetUsername == currentUsername) {\n      setState(() => _friendStatusMessage = \"You can't add yourself!\");\n      return;\n    }\n\n    if (_friendsList.contains(targetUsername)) {\n      setState(() => _friendStatusMessage = 'Already in your friends list!');\n      return;\n    }\n\n    setState(() {\n      _friendStatusMessage = '';\n    });\n\n    try {\n      final query = await FirebaseFirestore.instance\n          .collection('users')\n          .where('username', isEqualTo: targetUsername)\n          .get();\n\n      if (query.docs.isEmpty) {\n        setState(() => _friendStatusMessage = 'User not found!');\n        return;\n      }\n\n      final targetDoc = query.docs.first;\n      List<dynamic> targetRequests = targetDoc.data()['incomingRequests'] ?? [];\n\n      if (targetRequests.contains(currentUsername)) {\n        setState(() => _friendStatusMessage = 'Friend request already sent!');\n        return;\n      }\n\n      targetRequests.add(currentUsername);\n\n      await targetDoc.reference.set({\n        'incomingRequests': targetRequests,\n      }, SetOptions(merge: true));\n\n      _friendController.clear();\n      setState(() {\n        _friendStatusMessage = 'Friend request sent successfully!';\n      });\n    } catch (e) {\n      setState(() => _friendStatusMessage = 'Error sending request: $e');\n    }\n  }\n\n  Future<void> _acceptFriendRequest(String senderUsername) async {\n    try {\n      final query = await FirebaseFirestore.instance\n          .collection('users')\n          .where('username', isEqualTo: senderUsername)\n          .get();\n\n      if (query.docs.isNotEmpty) {\n        final senderDoc = query.docs.first;\n        List<dynamic> senderFriends = senderDoc.data()['friends'] ?? [];\n        \n        final currentDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();\n        final currentUsername = currentDoc.data()?['username'] ?? '';\n\n        if (!senderFriends.contains(currentUsername)) {\n          senderFriends.add(currentUsername);\n          await senderDoc.reference.set({'friends': senderFriends}, SetOptions(merge: true));\n        }\n\n        if (!_friendsList.contains(senderUsername)) {\n          _friendsList.add(senderUsername);\n        }\n      }\n\n      _incomingRequests.remove(senderUsername);\n\n      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({\n        'friends': _friendsList,\n        'incomingRequests': _incomingRequests,\n      }, SetOptions(merge: true));\n\n      setState(() {});\n    } catch (e) {\n      debugPrint(\"Error accepting request: $e\");\n    }\n  }\n\n  Future<void> _declineFriendRequest(String senderUsername) async {\n    setState(() {\n      _incomingRequests.remove(senderUsername);\n    });\n\n    try {\n      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({\n        'incomingRequests': _incomingRequests,\n      }, SetOptions(merge: true));\n    } catch (e) {\n      debugPrint(\"Error declining request: $e\");\n    }\n  }\n\n  Future<void> _updateProfileIcon(String iconName) async {\n    setState(() {\n      _profileIcon = iconName;\n      _profileImageUrl = '';\n    });\n    try {\n      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({\n        'profileIcon': iconName,\n        'profileImageBase64': '',\n      }, SetOptions(merge: true));\n    } catch (e) {\n      debugPrint(\"Error updating icon: $e\");\n    }\n  }\n\n  Future<void> _deleteAccount() async {\n    showDialog(\n      context: context,\n      builder: (context) => AlertDialog(\n        backgroundColor: const Color(0xFF1E1E1E),\n        title: const Text('Delete Account', style: TextStyle(color: Colors.redAccent)),\n        content: const Text('Are you sure you want to delete your account? All your collection data and profile info will be permanently removed.'),\n        actions: [\n          TextButton(\n            child: const Text('Cancel', style: TextStyle(color: Colors.white)),\n            onPressed: () => Navigator.pop(context),\n          ),\n          TextButton(\n            child: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),\n            onPressed: () async {\n              Navigator.pop(context);\n              try {\n                setState(() => _isLoading = true);\n                await FirebaseFirestore.instance.collection('users').doc(user!.uid).delete();\n                await user!.delete();\n              } catch (e) {\n                debugPrint(\"Error deleting account: $e\");\n                if (!mounted) return;\n                ScaffoldMessenger.of(context).showSnackBar(\n                  const SnackBar(content: Text('Please log out and log back in before deleting your account for security reasons.')),\n                );\n                setState(() => _isLoading = false);\n              }\n            },\n          ),\n        ],\n      ),\n    );\n  }\n\n  @override\n  Widget build(BuildContext context) {\n    return Scaffold(\n      appBar: AppBar(\n        title: const Text('Account Settings', style: TextStyle(fontWeight: FontWeight.bold)),\n        backgroundColor: const Color(0xFF161616),\n        centerTitle: true,\n      ),\n      body: _isLoading\n          ? const Center(child: CircularProgressIndicator(color: Colors.amber))\n          : SingleChildScrollView(\n              padding: const EdgeInsets.all(20.0),\n              child: Column(\n                crossAxisAlignment: CrossAxisAlignment.start,\n                children: [\n                  Center(\n                    child: Column(\n                      children: [\n                        CircleAvatar(\n                          radius: 50,\n                          backgroundColor: Colors.amber.shade900,\n                          backgroundImage: _profileImageUrl.isNotEmpty\n                              ? NetworkImage(_profileImageUrl)\n                              : null,\n                          child: _profileImageUrl.isEmpty\n                              ? Icon(\n                                  _profileIcon == 'star'\n                                      ? Icons.star\n                                      : _profileIcon == 'music_note'\n                                          ? Icons.music_note\n                                          : Icons.album,\n                                  size: 50,\n                                  color: Colors.amber,\n                                )\n                              : null,\n                        ),\n                        const SizedBox(height: 12),\n                        ElevatedButton.icon(\n                          style: ElevatedButton.styleFrom(\n                            backgroundColor: const Color(0xFF2C2C2C),\n                            foregroundColor: Colors.white,\n                          ),\n                          onPressed: _pickAndUploadImage,\n                          icon: const Icon(Icons.photo_library, color: Colors.amber),\n                          label: const Text('Upload from Gallery'),\n                        ),\n                        const SizedBox(height: 8),\n                        const Text('Or choose preset icon:', style: TextStyle(color: Colors.grey, fontSize: 12)),\n                        Row(\n                          mainAxisAlignment: MainAxisAlignment.center,\n                          children: [\n                            IconButton(\n                              icon: const Icon(Icons.album),\n                              color: _profileIcon == 'album' && _profileImageUrl.isEmpty ? Colors.amber : Colors.grey,\n                              onPressed: () => _updateProfileIcon('album'),\n                            ),\n                            IconButton(\n                              icon: const Icon(Icons.star),\n                              color: _profileIcon == 'star' && _profileImageUrl.isEmpty ? Colors.amber : Colors.grey,\n                              onPressed: () => _updateProfileIcon('star'),\n                            ),\n                            IconButton(\n                              icon: const Icon(Icons.music_note),\n                              color: _profileIcon == 'music_note' && _profileImageUrl.isEmpty ? Colors.amber : Colors.grey,\n                              onPressed: () => _updateProfileIcon('music_note'),\n                            ),\n                          ],\n                        ),\n                      ],\n                    ),\n                  ),\n                  const Divider(height: 40, color: Color(0xFF2C2C2C)),\n                  \n                  const Text('Collection Privacy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber)),\n                  const SizedBox(height: 8),\n                  Container(\n                    padding: const EdgeInsets.symmetric(horizontal: 12),\n                    decoration: BoxDecoration(\n                      color: const Color(0xFF1A1A1A),\n                      borderRadius: BorderRadius.circular(10),\n                    ),\n                    child: DropdownButtonHideUnderline(\n                      child: DropdownButton<String>(\n                        value: _privacySetting,\n                        dropdownColor: const Color(0xFF1A1A1A),\n                        isExpanded: true,\n                        items: const [\n                          DropdownMenuItem(value: 'friends', child: Text('Friends Only')),\n                          DropdownMenuItem(value: 'public', child: Text('Public (Anyone)')),\n                          DropdownMenuItem(value: 'private', child: Text('Private (Only Me)')),\n                        ],\n                        onChanged: _updatePrivacy,\n                      ),\n                    ),\n                  ),\n                  const Divider(height: 40, color: Color(0xFF2C2C2C)),\n\n                  const Text('Collector Username', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber)),\n                  const SizedBox(height: 8),\n                  TextField(\n                    controller: _usernameController,\n                    decoration: InputDecoration(\n                      hintText: 'Enter unique username',\n                      filled: true,\n                      fillColor: const Color(0xFF1A1A1A),\n                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),\n                    ),\n                  ),\n                  const SizedBox(height: 12),\n                  SizedBox(\n                    width: double.infinity,\n                    child: ElevatedButton(\n                      style: ElevatedButton.styleFrom(\n                        backgroundColor: Colors.amber,\n                        foregroundColor: Colors.black,\n                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),\n                      ),\n                      onPressed: _isSaving ? null : _updateUsername,\n                      child: _isSaving\n                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))\n                          : const Text('Check Availability & Save Username', style: TextStyle(fontWeight: FontWeight.bold)),\n                    ),\n                  ),\n                  if (_statusMessage.isNotEmpty) ...[\n                    const SizedBox(height: 8),\n                    Text(_statusMessage, style: TextStyle(color: _statusMessage.contains('successfully') ? Colors.green : Colors.red, fontSize: 13)),\n                  ],\n                  const Divider(height: 40, color: Color(0xFF2C2C2C)),\n                  \n                  const Text('Add Collector Friend', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber)),\n                  const SizedBox(height: 8),\n                  Row(\n                    children: [\n                      Expanded(\n                        child: TextField(\n                          controller: _friendController,\n                          decoration: InputDecoration(\n                            hintText: \"Friend's username...\",\n                            filled: true,\n                            fillColor: const Color(0xFF1A1A1A),\n                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),\n                          ),\n                        ),\n                      ),\n                      const SizedBox(width: 10),\n                      ElevatedButton(\n                        style: ElevatedButton.styleFrom(\n                          backgroundColor: Colors.amber,\n                          foregroundColor: Colors.black,\n                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),\n                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),\n                        ),\n                        onPressed: _sendFriendRequest,\n                        child: const Text('Send', style: TextStyle(fontWeight: FontWeight.bold)),\n                      ),\n                    ],\n                  ),\n                  if (_friendStatusMessage.isNotEmpty) ...[\n                    const SizedBox(height: 6),\n                    Text(_friendStatusMessage, style: TextStyle(color: _friendStatusMessage.contains('success') ? Colors.green : Colors.red, fontSize: 12)),\n                  ],\n\n                  if (_incomingRequests.isNotEmpty) ...[\n                    const SizedBox(height: 20),\n                    const Text('Incoming Friend Requests', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.amberAccent)),\n                    const SizedBox(height: 6),\n                    ListView.builder(\n                      shrinkWrap: true,\n                      physics: const NeverScrollableScrollPhysics(),\n                      itemCount: _incomingRequests.length,\n                      itemBuilder: (context, index) {\n                        final sender = _incomingRequests[index];\n                        return Card(\n                          color: const Color(0xFF1A1A1A),\n                          margin: const EdgeInsets.symmetric(vertical: 4),\n                          child: ListTile(\n                            leading: const Icon(Icons.person_add, color: Colors.amber),\n                            title: Text(sender, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),\n                            trailing: Row(\n                              mainAxisSize: MainAxisSize.min,\n                              children: [\n                                IconButton(\n                                  icon: const Icon(Icons.check, color: Colors.green),\n                                  onPressed: () => _acceptFriendRequest(sender),\n                                ),\n                                IconButton(\n                                  icon: const Icon(Icons.close, color: Colors.redAccent),\n                                  onPressed: () => _declineFriendRequest(sender),\n                                ),\n                              ],\n                            ),\n                          ),\n                        );\n                      },\n                    ),\n                  ],\n\n                  const SizedBox(height: 20),\n                  const Text('Collector Friends (Tap to view collection)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber)),\n                  const SizedBox(height: 8),\n                  _friendsList.isEmpty\n                      ? const Text('No collector friends added yet.', style: TextStyle(color: Colors.grey, fontSize: 13))\n                      : ListView.builder(\n                          shrinkWrap: true,\n                          physics: const NeverScrollableScrollPhysics(),\n                          itemCount: _friendsList.length,\n                          itemBuilder: (context, index) {\n                            final friendName = _friendsList[index];\n                            return Card(\n                              color: const Color(0xFF1A1A1A),\n                              margin: const EdgeInsets.symmetric(vertical: 4),\n                              child: ListTile(\n                                leading: const Icon(Icons.person, color: Colors.amber),\n                                title: Text(friendName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),\n                                trailing: IconButton(\n                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),\n                                  onPressed: () async {\n                                    setState(() {\n                                      _friendsList.removeAt(index);\n                                    });\n                                    await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({\n                                      'friends': _friendsList,\n                                    }, SetOptions(merge: true));\n                                  },\n                                ),\n                                onTap: () {\n                                  Navigator.push(\n                                    context,\n                                    MaterialPageRoute(\n                                      builder: (context) => FriendCollectionScreen(friendUsername: friendName),\n                                    ),\n                                  );\n                                },\n                              ),\n                            );\n                          },\n                        ),\n\n                  const Divider(height: 50, color: Color(0xFF2C2C2C)),\n                  \n                  SizedBox(\n                    width: double.infinity,\n                    child: OutlinedButton.icon(\n                      style: OutlinedButton.styleFrom(\n                        foregroundColor: Colors.redAccent,\n                        side: const BorderSide(color: Colors.redAccent),\n                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),\n                        padding: const EdgeInsets.symmetric(vertical: 12),\n                      ),\n                      onPressed: _deleteAccount,\n                      icon: const Icon(Icons.delete_forever),\n                      label: const Text('Delete Account & Data', style: TextStyle(fontWeight: FontWeight.bold)),\n                    ),\n                  ),\n                ],\n              ),\n            ),\n    );\n  }\n}",
      "lib\\auth_screen.dart": "import 'package:flutter/material.dart';\nimport 'package:firebase_auth/firebase_auth.dart';\nimport 'package:cloud_firestore/cloud_firestore.dart';\nimport 'main.dart';\n\nclass AuthScreen extends StatefulWidget {\n  const AuthScreen({super.key});\n\n  @override\n  State<AuthScreen> createState() => _AuthScreenState();\n}\n\nclass _AuthScreenState extends State<AuthScreen> {\n  final _emailController = TextEditingController();\n  final _passwordController = TextEditingController();\n  final _usernameController = TextEditingController();\n\n  bool _isLogin = true;\n  bool _isLoading = false;\n  String _errorMessage = '';\n\n  bool _validatePassword(String password) {\n    if (password.length < 6) {\n      setState(() => _errorMessage = 'Password must be at least 6 characters long.');\n      return false;\n    }\n    return true;\n  }\n\n  Future<void> _submitAuthForm() async {\n    final email = _emailController.text.trim();\n    final password = _passwordController.text.trim();\n    final username = _usernameController.text.trim();\n\n    if (email.isEmpty || password.isEmpty || (!_isLogin && username.isEmpty)) {\n      setState(() => _errorMessage = 'Please fill in all fields.');\n      return;\n    }\n\n    if (!_isLogin && !_validatePassword(password)) {\n      return;\n    }\n\n    if (!_isLogin && username.length < 3) {\n      setState(() => _errorMessage = 'Username must be at least 3 characters.');\n      return;\n    }\n\n    setState(() {\n      _isLoading = true;\n      _errorMessage = '';\n    });\n\n    try {\n      if (_isLogin) {\n        UserCredential userCred = await FirebaseAuth.instance.signInWithEmailAndPassword(\n          email: email,\n          password: password,\n        );\n\n        final userDoc = await FirebaseFirestore.instance.collection('users').doc(userCred.user!.uid).get();\n        if (!userDoc.exists || userDoc.data()?['username'] == null || (userDoc.data()?['username'] as String).isEmpty) {\n          await FirebaseFirestore.instance.collection('users').doc(userCred.user!.uid).set({\n            'username': email.split('@')[0],\n            'email': email,\n            'profileIcon': 'album',\n            'profileImageBase64': '',\n            'friends': [],\n          }, SetOptions(merge: true));\n        }\n      } else {\n        final query = await FirebaseFirestore.instance\n            .collection('users')\n            .where('username', isEqualTo: username)\n            .get();\n\n        if (query.docs.isNotEmpty) {\n          setState(() {\n            _errorMessage = 'Username is already taken. Choose another.';\n            _isLoading = false;\n          });\n          return;\n        }\n\n        UserCredential userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(\n          email: email,\n          password: password,\n        );\n\n        await FirebaseFirestore.instance.collection('users').doc(userCred.user!.uid).set({\n          'username': username,\n          'email': email,\n          'profileIcon': 'album',\n          'profileImageBase64': '',\n          'friends': [],\n          'createdAt': FieldValue.serverTimestamp(),\n        }, SetOptions(merge: true));\n      }\n\n      if (!mounted) return;\n      Navigator.pushReplacement(\n        context,\n        MaterialPageRoute(builder: (context) => const AlbumScreen()),\n      );\n    } on FirebaseAuthException catch (error) {\n      setState(() {\n        _errorMessage = error.message ?? 'An authentication error occurred.';\n        _isLoading = false;\n      });\n    } catch (error) {\n      setState(() {\n        _errorMessage = error.toString();\n        _isLoading = false;\n      });\n    }\n  }\n\n  @override\n  Widget build(BuildContext context) {\n    return Scaffold(\n      body: Center(\n        child: Padding(\n          padding: const EdgeInsets.all(24.0),\n          child: SingleChildScrollView(\n            child: Column(\n              mainAxisAlignment: MainAxisAlignment.center,\n              children: [\n                const Icon(Icons.album, size: 80, color: Colors.amber),\n                const SizedBox(height: 16),\n                Text(\n                  _isLogin ? 'MJ Card Tracker' : 'Create Account',\n                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),\n                ),\n                const SizedBox(height: 32),\n                if (!_isLogin) ...[\n                  TextField(\n                    controller: _usernameController,\n                    decoration: InputDecoration(\n                      labelText: 'Username',\n                      filled: true,\n                      fillColor: const Color(0xFF1E1E1E),\n                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),\n                    ),\n                  ),\n                  const SizedBox(height: 16),\n                ],\n                TextField(\n                  controller: _emailController,\n                  decoration: InputDecoration(\n                    labelText: 'Email',\n                    filled: true,\n                    fillColor: const Color(0xFF1E1E1E),\n                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),\n                  ),\n                ),\n                const SizedBox(height: 16),\n                TextField(\n                  controller: _passwordController,\n                  obscureText: true,\n                  decoration: InputDecoration(\n                    labelText: 'Password (min 6 chars)',\n                    filled: true,\n                    fillColor: const Color(0xFF1E1E1E),\n                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),\n                  ),\n                ),\n                const SizedBox(height: 20),\n                if (_errorMessage.isNotEmpty)\n                  Text(_errorMessage, style: const TextStyle(color: Colors.red, fontSize: 12), textAlign: TextAlign.center),\n                const SizedBox(height: 20),\n                _isLoading\n                    ? const CircularProgressIndicator(color: Colors.amber)\n                    : ElevatedButton(\n                        style: ElevatedButton.styleFrom(\n                          backgroundColor: Colors.amber,\n                          foregroundColor: Colors.black,\n                          minimumSize: const Size.fromHeight(50),\n                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),\n                        ),\n                        onPressed: _submitAuthForm,\n                        child: Text(_isLogin ? 'Login' : 'Sign Up', style: const TextStyle(fontWeight: FontWeight.bold)),\n                      ),\n                TextButton(\n                  onPressed: () {\n                    setState(() {\n                      _isLogin = !_isLogin;\n                      _errorMessage = '';\n                    });\n                  },\n                  child: Text(\n                    _isLogin ? 'Create a new account' : 'I already have an account',\n                    style: const TextStyle(color: Colors.amber),\n                  ),\n                ),\n              ],\n            ),\n          ),\n        ),\n      ),\n    );\n  }\n}",
      "lib\\card_model.dart": "class MJCardItem {\n  final int cardNumber;\n  final String cardName;\n  final String cardType;\n  \n  // A map to store whether each specific variation is checked (e.g., {'Base': true, 'Red /87': false})\n  Map<String, bool> variations;\n\n  // A map to store the specific serial number entered for numbered parallels (e.g., {'Red /87': '42/87'})\n  Map<String, String> serialNumbers;\n\n  String notes;\n\n  MJCardItem({\n    required this.cardNumber,\n    required this.cardName,\n    required this.cardType,\n    Map<String, bool>? variations,\n    Map<String, String>? serialNumbers,\n    this.notes = '',\n  })  : variations = variations ?? {},\n        serialNumbers = serialNumbers ?? {};\n\n  // Helper getter to check if any variation of this card is collected\n  bool get isCollected => variations.values.contains(true);\n\n  // Convert to JSON/Map if you are saving to Firebase or local storage later\n  Map<String, dynamic> toJson() => {\n        'cardNumber': cardNumber,\n        'cardName': cardName,\n        'cardType': cardType,\n        'variations': variations,\n        'serialNumbers': serialNumbers,\n        'notes': notes,\n      };\n\n  // Create from JSON/Map\n  factory MJCardItem.fromJson(Map<String, dynamic> json) {\n    return MJCardItem(\n      cardNumber: json['cardNumber'] ?? 0,\n      cardName: json['cardName'] ?? '',\n      cardType: json['cardType'] ?? '',\n      variations: Map<String, bool>.from(json['variations'] ?? {}),\n      serialNumbers: Map<String, String>.from(json['serialNumbers'] ?? {}),\n      notes: json['notes'] ?? '',\n    );\n  }\n}",
      "lib\\firebase_options.dart": "import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;\nimport 'package:flutter/foundation.dart'\n    show defaultTargetPlatform, kIsWeb, TargetPlatform;\n\nclass DefaultFirebaseOptions {\n  static FirebaseOptions get currentPlatform {\n    if (kIsWeb) {\n      throw UnsupportedError(\n        'DefaultFirebaseOptions have not been configured for web.',\n      );\n    }\n    switch (defaultTargetPlatform) {\n      case TargetPlatform.android:\n        return android;\n      case TargetPlatform.iOS:\n        throw UnsupportedError(\n          'DefaultFirebaseOptions have not been configured for iOS.',\n        );\n      case TargetPlatform.macOS:\n        throw UnsupportedError(\n          'DefaultFirebaseOptions have not been configured for macOS.',\n        );\n      case TargetPlatform.windows:\n        throw UnsupportedError(\n          'DefaultFirebaseOptions have not been configured for windows.',\n        );\n      case TargetPlatform.linux:\n        throw UnsupportedError(\n          'DefaultFirebaseOptions have not been configured for Linux.',\n        );\n      default:\n        throw UnsupportedError(\n          'DefaultFirebaseOptions are not supported for this platform.',\n        );\n    }\n  }\n\n  static const FirebaseOptions android = FirebaseOptions(\n    apiKey: 'AIzaSyBfmLYUUtwHTInPFDdP9FmP_n2UfvHvYys',\n    appId: '1:1036077654913:android:541c4321f9a4230300fe80',\n    messagingSenderId: '1036077654913',\n    projectId: 'mj-card-tracker',\n  );\n}",
      "lib\\friend_collection_screen.dart": "import 'package:flutter/material.dart';\nimport 'package:cloud_firestore/cloud_firestore.dart';\nimport 'card_model.dart';\n\nclass FriendCollectionScreen extends StatefulWidget {\n  const FriendCollectionScreen({super.key, required this.friendUsername});\n  final String friendUsername;\n\n  @override\n  State<FriendCollectionScreen> createState() => _FriendCollectionScreenState();\n}\n\nclass _FriendCollectionScreenState extends State<FriendCollectionScreen> {\n  bool _isLoading = true;\n  bool _isPrivate = false;\n  String _friendProfileIcon = 'album';\n  String _friendImageUrl = '';\n  \n  late final List<MJCardItem> _friendChecklist = _generateFriendChecklist();\n\n  List<MJCardItem> _generateFriendChecklist() {\n    List<MJCardItem> list = [];\n    for (int num = 1; num <= 300; num++) {\n      String name = 'Michael Jackson';\n      String type = 'Base Set';\n      List<String> allowedVariations = [];\n\n      if (num >= 1 && num <= 31) {\n        type = 'Base Set';\n        name = 'Michael Jackson - Base #$num';\n        allowedVariations = ['Base', 'W. Foil', 'Sil. BG', 'BAD BG', 'Red /87', 'Gold /17', 'Plat /15', 'Sig. /07', 'Dia. /01', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl'];\n      } else if (num >= 32 && num <= 56) {\n        type = 'Spotlight Base';\n        name = 'Michael Jackson - Spotlight Base #$num';\n        allowedVariations = ['Base', 'Foil', 'Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'Plat /15', 'Sig. /07', 'Dia. /01', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl'];\n      } else if (num >= 57 && num <= 85) {\n        type = 'Shortprint';\n        name = 'Michael Jackson - Base Shortprint #$num';\n        allowedVariations = ['Base', 'White Foil', 'Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'White /17', 'Blue /17', 'Plat. /15', 'Black Vinyl', 'Blue Vinyl', 'Red Vinyl'];\n      } else if (num >= 86 && num <= 103) {\n        type = 'Throwback';\n        name = 'Michael Jackson - Base Throwback #$num';\n        allowedVariations = ['Base', 'Foil', 'Red /87', 'Gold /17', 'Black /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Black Vinyl'];\n      } else if (num >= 104 && num <= 123) {\n        type = 'VIP Pass';\n        name = 'Michael Jackson - Base VIP Pass #$num';\n        allowedVariations = ['Base', 'White Foil', 'Black Base', 'Black Foil', 'Red /87', 'Gold /17', 'White /17', 'Black /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Black Vinyl', 'White Vinyl'];\n      } else if (num >= 124 && num <= 154) {\n        type = 'SignaGraph';\n        name = 'Michael Jackson - Laser SignaGraph #$num';\n        allowedVariations = ['Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'Blue /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Blue Vinyl'];\n      } else if (num >= 155 && num <= 174) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 1 Post Card #$num';\n        allowedVariations = ['Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'Blue /17', 'Black', 'Gold Vinyl', 'Red Vinyl', 'Blue Vinyl', 'Black Vinyl'];\n      } else if (num >= 175 && num <= 202) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 2 Poster #$num';\n        allowedVariations = ['Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'Blue /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Blue Vinyl'];\n      } else if (num >= 203 && num <= 234) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 3 Gallery #$num';\n        allowedVariations = ['Base', 'White Foil', 'Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'White /17', 'Blue /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Blue Vinyl', 'White Vinyl'];\n      } else if (num >= 235 && num <= 244) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 4 Drip #$num';\n        allowedVariations = ['Base', 'White Foil', 'Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'White /17', 'Blue /17', 'Plat. /15', 'Black Vinyl', 'Blue Vinyl', 'Red Vinyl'];\n      } else if (num >= 245 && num <= 252) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 5 Fire! #$num';\n        allowedVariations = ['Base', 'Foil', 'Red /87', 'Gold /17', 'Black /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Black Vinyl'];\n      } else if (num == 253) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 6 Ticket Stub Die Cut #253';\n        allowedVariations = ['Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'Blue /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Blue Vinyl', 'Plat. Vinyl'];\n      } else if (num == 254) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 7 Headlines #254';\n        allowedVariations = ['Base', 'Foil', 'Black Base', 'Black Foil', 'Red /87', 'Gold /17', 'White /17', 'Black /17', 'Plat. /15', 'Red Vinyl', 'Gold Vinyl', 'Plat. Vinyl', 'White Vinyl', 'Black Vinyl'];\n      } else if (num == 255) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 8 King of Pop Die Cut #255';\n        allowedVariations = ['Base', 'Foil', 'Red /87', 'Gold /17', 'Black /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Black Vinyl'];\n      } else if (num == 256) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 9 Now Presenting #256';\n        allowedVariations = ['Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'Blue /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Blue Vinyl', 'Plat. Vinyl'];\n      } else if (num == 257) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 10 Retro #257';\n        allowedVariations = ['Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'Blue /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Blue Vinyl', 'Plat. Vinyl'];\n      } else if (num == 258) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 11 Canvas #258';\n        allowedVariations = ['Base', 'Foil', 'Red /87', 'Gold /17', 'White /17', 'Plat. /15', 'Red Vinyl', 'Gold Vinyl', 'Plat. Vinyl', 'White Vinyl'];\n      } else if (num == 259) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 12 BAD World Tour Logo #259';\n        allowedVariations = ['Base', 'Foil', 'Red /87', 'Gold /17', 'Black /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Black Vinyl'];\n      } else if (num == 260) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 13 Confetti #260';\n        allowedVariations = ['Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'Blue /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Blue Vinyl', 'Plat. Vinyl'];\n      } else if (num >= 261 && num <= 270) {\n        type = 'Relic Memorabilia';\n        name = 'Michael Jackson - Relic Tour Jacket Memorabilia #$num';\n        allowedVariations = ['Base', 'Foil', 'Red /87', 'Gold /17', 'Black /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Black Vinyl'];\n      } else if (num >= 271 && num <= 281) {\n        type = 'Relic Memorabilia';\n        name = 'Michael Jackson - Relic Poster Memorabilia #$num';\n        allowedVariations = ['Base', 'Foil', 'Red /87', 'Gold /17', 'Black /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Black Vinyl'];\n      } else if (num >= 282 && num <= 285) {\n        type = 'Relic Memorabilia';\n        name = 'Michael Jackson - Relic Ticket Stub Memorabilia #$num';\n        allowedVariations = ['Base', 'Foil', 'Red /87', 'Gold /17', 'Black /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Black Vinyl'];\n      } else if (num == 286) {\n        type = 'Relic Memorabilia';\n        name = 'Michael Jackson - Relic Private Collection Memorabilia #286';\n        allowedVariations = ['Black /87', 'Red /87', 'Gold /17', 'Plat. /15', 'Red Vinyl', 'Gold Vinyl', 'Plat. Vinyl', 'Black Vinyl'];\n      } else if (num >= 287 && num <= 290) {\n        type = 'Cut Autograph';\n        name = 'Michael Jackson - Cut Autograph #$num';\n        allowedVariations = ['Base'];\n      } else if (num >= 291 && num <= 292) {\n        type = 'Cut Autograph';\n        name = 'Michael Jackson - Memorabilia Cut Autograph #$num';\n        allowedVariations = ['Base'];\n      } else if (num >= 293 && num <= 296) {\n        type = 'Gemstone Relic';\n        name = num == 293 ? 'Michael Jackson - Real Ruby Memorabilia #293' : (num == 294 ? 'Michael Jackson - Real Emerald Memorabilia #294' : (num == 295 ? 'Michael Jackson - Real Sapphire Memorabilia #295' : 'Michael Jackson - Real Diamond Memorabilia #296'));\n        allowedVariations = ['Base /10'];\n      } else if (num >= 297 && num <= 300) {\n        type = 'Precious Metal Relic';\n        name = num == 297 ? 'Michael Jackson - Real Silver Memorabilia #297' : (num == 298 ? 'Michael Jackson - Real Gold Memorabilia #298' : (num == 299 ? 'Michael Jackson - Real Platinum Memorabilia #299' : 'Michael Jackson - Real Pearl Memorabilia #300'));\n        allowedVariations = ['Base /10'];\n      }\n\n      Map<String, bool> initialVars = {for (var v in allowedVariations) v: false};\n      list.add(MJCardItem(\n        cardNumber: num,\n        cardName: name,\n        cardType: type,\n        variations: initialVars,\n      ));\n    }\n    return list;\n  }\n\n  @override\n  void initState() {\n    super.initState();\n    _fetchFriendData();\n  }\n\n  Future<void> _fetchFriendData() async {\n    try {\n      final query = await FirebaseFirestore.instance\n          .collection('users')\n          .where('username', isEqualTo: widget.friendUsername)\n          .get();\n\n      if (query.docs.isNotEmpty) {\n        final data = query.docs.first.data();\n        final privacy = data['privacySetting'] ?? 'friends';\n\n        if (privacy == 'private') {\n          setState(() {\n            _isPrivate = true;\n            _isLoading = false;\n          });\n          return;\n        }\n\n        setState(() {\n          _friendProfileIcon = data['profileIcon'] ?? 'album';\n          _friendImageUrl = data['profileImageBase64'] ?? '';\n        });\n\n        final collectedData = data['collectedCards'] as Map<String, dynamic>?;\n        if (collectedData != null) {\n          setState(() {\n            for (var card in _friendChecklist) {\n              if (collectedData.containsKey(card.cardNumber.toString())) {\n                var cardData = collectedData[card.cardNumber.toString()];\n                if (cardData is Map) {\n                  card.variations = Map<String, bool>.from(cardData['variations'] ?? {});\n                  card.serialNumbers = Map<String, String>.from(cardData['serialNumbers'] ?? {});\n                  card.notes = cardData['notes'] ?? '';\n                } else if (cardData is bool) {\n                  if (card.variations.isNotEmpty) {\n                    card.variations[card.variations.keys.first] = cardData;\n                  }\n                }\n              }\n            }\n          });\n        }\n      }\n    } catch (e) {\n      debugPrint(\"Error loading friend collection: $e\");\n    } finally {\n      setState(() {\n        _isLoading = false;\n      });\n    }\n  }\n\n  void _openFriendCardDetailModal(MJCardItem card) {\n    showModalBottomSheet(\n      context: context,\n      isScrollControlled: true,\n      backgroundColor: const Color(0xFF1E1E1E),\n      shape: const RoundedRectangleBorder(\n        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),\n      ),\n      builder: (context) {\n        return Padding(\n          padding: const EdgeInsets.all(20.0),\n          child: SingleChildScrollView(\n            child: Column(\n              mainAxisSize: MainAxisSize.min,\n              crossAxisAlignment: CrossAxisAlignment.start,\n              children: [\n                Row(\n                  mainAxisAlignment: MainAxisAlignment.spaceBetween,\n                  children: [\n                    Text(\n                      '#${card.cardNumber} - ${card.cardName}',\n                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber),\n                    ),\n                    IconButton(\n                      icon: const Icon(Icons.close, color: Colors.white),\n                      onPressed: () => Navigator.pop(context),\n                    ),\n                  ],\n                ),\n                const Divider(color: Colors.grey),\n                const Text('Friend Owned Variations & Serial Numbers:', style: TextStyle(color: Colors.grey, fontSize: 13)),\n                const SizedBox(height: 10),\n                ...card.variations.keys.map((variationName) {\n                  bool isChecked = card.variations[variationName] ?? false;\n                  String serial = card.serialNumbers[variationName] ?? '';\n\n                  return ListTile(\n                    contentPadding: EdgeInsets.zero,\n                    title: Text(variationName, style: const TextStyle(fontSize: 14)),\n                    trailing: Text(\n                      isChecked ? (serial.isNotEmpty ? 'Owned ($serial)' : 'Owned') : 'Missing',\n                      style: TextStyle(\n                        color: isChecked ? Colors.amber : Colors.grey.shade600,\n                        fontWeight: FontWeight.bold,\n                        fontSize: 12,\n                      ),\n                    ),\n                  );\n                }),\n                if (card.notes.isNotEmpty) ...[\n                  const SizedBox(height: 10),\n                  Text('Notes: ${card.notes}', style: const TextStyle(color: Colors.white70, fontSize: 13)),\n                ],\n              ],\n            ),\n          ),\n        );\n      },\n    );\n  }\n\n  @override\n  Widget build(BuildContext context) {\n    if (_isLoading) {\n      return Scaffold(\n        appBar: AppBar(backgroundColor: const Color(0xFF161616)),\n        body: const Center(child: CircularProgressIndicator(color: Colors.amber)),\n      );\n    }\n\n    if (_isPrivate) {\n      return Scaffold(\n        appBar: AppBar(\n          title: Text(\"${widget.friendUsername}'s Collection\", style: const TextStyle(fontWeight: FontWeight.bold)),\n          backgroundColor: const Color(0xFF161616),\n        ),\n        body: Center(\n          child: Column(\n            mainAxisAlignment: MainAxisAlignment.center,\n            children: [\n              const Icon(Icons.lock_outline, size: 60, color: Colors.grey),\n              const SizedBox(height: 16),\n              Text(\n                \"${widget.friendUsername}'s collection is private.\",\n                style: const TextStyle(color: Colors.grey, fontSize: 16),\n              ),\n            ],\n          ),\n        ),\n      );\n    }\n\n    int collectedCount = _friendChecklist.where((card) => card.isCollected).length;\n    double progressPercent = _friendChecklist.isEmpty ? 0.0 : collectedCount / _friendChecklist.length;\n\n    return Scaffold(\n      appBar: AppBar(\n        title: Text(\"${widget.friendUsername}'s Collection\", style: const TextStyle(fontWeight: FontWeight.bold)),\n        backgroundColor: const Color(0xFF161616),\n        centerTitle: true,\n      ),\n      body: Column(\n        children: [\n          Container(\n            padding: const EdgeInsets.all(16),\n            color: const Color(0xFF181818),\n            child: Row(\n              children: [\n                CircleAvatar(\n                  radius: 30,\n                  backgroundColor: Colors.amber.shade900,\n                  backgroundImage: _friendImageUrl.isNotEmpty\n                      ? NetworkImage(_friendImageUrl)\n                      : null,\n                  child: _friendImageUrl.isEmpty\n                      ? Icon(\n                          _friendProfileIcon == 'star'\n                              ? Icons.star\n                              : _friendProfileIcon == 'music_note'\n                                  ? Icons.music_note\n                                  : Icons.album,\n                          size: 30,\n                          color: Colors.amber,\n                        )\n                      : null,\n                ),\n                const SizedBox(width: 16),\n                Expanded(\n                  child: Column(\n                    crossAxisAlignment: CrossAxisAlignment.start,\n                    children: [\n                      Text(widget.friendUsername, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),\n                      const SizedBox(height: 4),\n                      Text(\n                        'Progress: $collectedCount / ${_friendChecklist.length} (${(progressPercent * 100).toStringAsFixed(0)}%)',\n                        style: const TextStyle(color: Colors.amber, fontSize: 13),\n                      ),\n                    ],\n                  ),\n                ),\n              ],\n            ),\n          ),\n          Expanded(\n            child: GridView.builder(\n              padding: const EdgeInsets.all(12.0),\n              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(\n                crossAxisCount: 2,\n                childAspectRatio: 0.72,\n                crossAxisSpacing: 12.0,\n                mainAxisSpacing: 12.0,\n              ),\n              itemCount: _friendChecklist.length,\n              itemBuilder: (context, index) {\n                final card = _friendChecklist[index];\n                return GestureDetector(\n                  onTap: () => _openFriendCardDetailModal(card),\n                  child: Container(\n                    decoration: BoxDecoration(\n                      color: card.isCollected ? const Color(0xFF221E12) : const Color(0xFF1A1A1A),\n                      borderRadius: BorderRadius.circular(14.0),\n                      border: Border.all(\n                        color: card.isCollected ? Colors.amber.shade600 : Colors.grey.shade800,\n                        width: card.isCollected ? 2.0 : 1.0,\n                      ),\n                    ),\n                    child: Padding(\n                      padding: const EdgeInsets.all(10.0),\n                      child: Column(\n                        mainAxisAlignment: MainAxisAlignment.center,\n                        children: [\n                          Row(\n                            mainAxisAlignment: MainAxisAlignment.spaceBetween,\n                            children: [\n                              Text(\n                                '#${card.cardNumber}',\n                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 13),\n                              ),\n                              Icon(\n                                card.isCollected ? Icons.check_circle : Icons.radio_button_unchecked,\n                                color: card.isCollected ? Colors.amber : Colors.grey.shade700,\n                                size: 20,\n                              ),\n                            ],\n                          ),\n                          const Spacer(),\n                          Icon(\n                            card.isCollected ? Icons.album : Icons.lock_outline,\n                            size: 42,\n                            color: card.isCollected ? Colors.amber : Colors.grey.shade700,\n                          ),\n                          const Spacer(),\n                          Text(\n                            card.cardName,\n                            textAlign: TextAlign.center,\n                            maxLines: 2,\n                            overflow: TextOverflow.ellipsis,\n                            style: TextStyle(\n                              fontWeight: FontWeight.bold,\n                              fontSize: 13,\n                              color: card.isCollected ? Colors.white : Colors.grey.shade400,\n                            ),\n                          ),\n                          const SizedBox(height: 4),\n                          Text(\n                            card.cardType,\n                            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),\n                          ),\n                          const SizedBox(height: 8),\n                          Container(\n                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),\n                            decoration: BoxDecoration(\n                              color: card.isCollected ? Colors.amber : Colors.grey.shade800,\n                              borderRadius: BorderRadius.circular(6),\n                            ),\n                            child: Text(\n                              card.isCollected ? 'OWNED' : 'MISSING',\n                              style: TextStyle(\n                                fontSize: 9,\n                                fontWeight: FontWeight.bold,\n                                color: card.isCollected ? Colors.black : Colors.white,\n                              ),\n                            ),\n                          ),\n                        ],\n                      ),\n                    ),\n                  ),\n                );\n              },\n            ),\n          ),\n        ],\n      ),\n    );\n  }\n}",
      "lib\\main.dart": "import 'package:flutter/material.dart';\nimport 'package:firebase_core/firebase_core.dart';\nimport 'package:firebase_auth/firebase_auth.dart';\nimport 'package:cloud_firestore/cloud_firestore.dart';\nimport 'firebase_options.dart';\nimport 'auth_screen.dart';\nimport 'card_model.dart';\nimport 'account_screen.dart';\n\nvoid main() async {\n  WidgetsFlutterBinding.ensureInitialized();\n  await Firebase.initializeApp(\n    options: DefaultFirebaseOptions.currentPlatform,\n  );\n  runTheApp();\n}\n\nvoid runTheApp() {\n  runApp(const MJCardTrackerApp());\n}\n\nclass MJCardTrackerApp extends StatelessWidget {\n  const MJCardTrackerApp({super.key});\n\n  @override\n  Widget build(BuildContext context) {\n    return MaterialApp(\n      debugShowCheckedModeBanner: false,\n      title: 'MJ Card Tracker',\n      theme: ThemeData(\n        brightness: Brightness.dark,\n        primarySwatch: Colors.amber,\n        scaffoldBackgroundColor: const Color(0xFF121212),\n        cardColor: const Color(0xFF1E1E1E),\n        colorScheme: const ColorScheme.dark(\n          primary: Colors.amber,\n          secondary: Colors.amberAccent,\n        ),\n      ),\n      home: StreamBuilder<User?>(\n        stream: FirebaseAuth.instance.authStateChanges(),\n        builder: (context, snapshot) {\n          if (snapshot.connectionState == ConnectionState.waiting) {\n            return const Scaffold(\n              body: Center(\n                child: CircularProgressIndicator(color: Colors.amber),\n              ),\n            );\n          }\n          if (snapshot.hasData) {\n            return const AlbumScreen();\n          }\n          return const AuthScreen();\n        },\n      ),\n    );\n  }\n}\n\nclass AlbumScreen extends StatefulWidget {\n  const AlbumScreen({super.key});\n\n  @override\n  State<AlbumScreen> createState() => _AlbumScreenState();\n}\n\nclass _AlbumScreenState extends State<AlbumScreen> {\n  final User? user = FirebaseAuth.instance.currentUser;\n  \n  late final List<MJCardItem> _masterChecklist = _generateMasterChecklist();\n\n  List<MJCardItem> _generateMasterChecklist() {\n    List<MJCardItem> list = [];\n\n    // Helper to determine variations and type based on card number\n    for (int num = 1; num <= 300; num++) {\n      String name = 'Michael Jackson';\n      String type = 'Base Set';\n      List<String> allowedVariations = [];\n\n      if (num >= 1 && num <= 31) {\n        type = 'Base Set';\n        name = 'Michael Jackson - Base #$num';\n        allowedVariations = ['Base', 'W. Foil', 'Sil. BG', 'BAD BG', 'Red /87', 'Gold /17', 'Plat /15', 'Sig. /07', 'Dia. /01', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl'];\n      } else if (num >= 32 && num <= 56) {\n        type = 'Spotlight Base';\n        name = 'Michael Jackson - Spotlight Base #$num';\n        allowedVariations = ['Base', 'Foil', 'Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'Plat /15', 'Sig. /07', 'Dia. /01', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl'];\n      } else if (num >= 57 && num <= 85) {\n        type = 'Shortprint';\n        name = 'Michael Jackson - Base Shortprint #$num';\n        allowedVariations = ['Base', 'White Foil', 'Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'White /17', 'Blue /17', 'Plat. /15', 'Black Vinyl', 'Blue Vinyl', 'Red Vinyl'];\n      } else if (num >= 86 && num <= 103) {\n        type = 'Throwback';\n        name = 'Michael Jackson - Base Throwback #$num';\n        allowedVariations = ['Base', 'Foil', 'Red /87', 'Gold /17', 'Black /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Black Vinyl'];\n      } else if (num >= 104 && num <= 123) {\n        type = 'VIP Pass';\n        name = 'Michael Jackson - Base VIP Pass #$num';\n        allowedVariations = ['Base', 'White Foil', 'Black Base', 'Black Foil', 'Red /87', 'Gold /17', 'White /17', 'Black /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Black Vinyl', 'White Vinyl'];\n      } else if (num >= 124 && num <= 154) {\n        type = 'SignaGraph';\n        name = 'Michael Jackson - Laser SignaGraph #$num';\n        allowedVariations = ['Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'Blue /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Blue Vinyl'];\n      } else if (num >= 155 && num <= 174) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 1 Post Card #$num';\n        allowedVariations = ['Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'Blue /17', 'Black', 'Gold Vinyl', 'Red Vinyl', 'Blue Vinyl', 'Black Vinyl'];\n      } else if (num >= 175 && num <= 202) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 2 Poster #$num';\n        allowedVariations = ['Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'Blue /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Blue Vinyl'];\n      } else if (num >= 203 && num <= 234) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 3 Gallery #$num';\n        allowedVariations = ['Base', 'White Foil', 'Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'White /17', 'Blue /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Blue Vinyl', 'White Vinyl'];\n      } else if (num >= 235 && num <= 244) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 4 Drip #$num';\n        allowedVariations = ['Base', 'White Foil', 'Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'White /17', 'Blue /17', 'Plat. /15', 'Black Vinyl', 'Blue Vinyl', 'Red Vinyl'];\n      } else if (num >= 245 && num <= 252) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 5 Fire! #$num';\n        allowedVariations = ['Base', 'Foil', 'Red /87', 'Gold /17', 'Black /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Black Vinyl'];\n      } else if (num == 253) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 6 Ticket Stub Die Cut #253';\n        allowedVariations = ['Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'Blue /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Blue Vinyl', 'Plat. Vinyl'];\n      } else if (num == 254) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 7 Headlines #254';\n        allowedVariations = ['Base', 'Foil', 'Black Base', 'Black Foil', 'Red /87', 'Gold /17', 'White /17', 'Black /17', 'Plat. /15', 'Red Vinyl', 'Gold Vinyl', 'Plat. Vinyl', 'White Vinyl', 'Black Vinyl'];\n      } else if (num == 255) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 8 King of Pop Die Cut #255';\n        allowedVariations = ['Base', 'Foil', 'Red /87', 'Gold /17', 'Black /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Black Vinyl'];\n      } else if (num == 256) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 9 Now Presenting #256';\n        allowedVariations = ['Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'Blue /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Blue Vinyl', 'Plat. Vinyl'];\n      } else if (num == 257) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 10 Retro #257';\n        allowedVariations = ['Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'Blue /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Blue Vinyl', 'Plat. Vinyl'];\n      } else if (num == 258) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 11 Canvas #258';\n        allowedVariations = ['Base', 'Foil', 'Red /87', 'Gold /17', 'White /17', 'Plat. /15', 'Red Vinyl', 'Gold Vinyl', 'Plat. Vinyl', 'White Vinyl'];\n      } else if (num == 259) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 12 BAD World Tour Logo #259';\n        allowedVariations = ['Base', 'Foil', 'Red /87', 'Gold /17', 'Black /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Black Vinyl'];\n      } else if (num == 260) {\n        type = 'Inserts';\n        name = 'Michael Jackson - Insert 13 Confetti #260';\n        allowedVariations = ['Blue Base', 'Blue Foil', 'Red /87', 'Gold /17', 'Blue /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Blue Vinyl', 'Plat. Vinyl'];\n      } else if (num >= 261 && num <= 270) {\n        type = 'Relic Memorabilia';\n        name = 'Michael Jackson - Relic Tour Jacket Memorabilia #$num';\n        allowedVariations = ['Base', 'Foil', 'Red /87', 'Gold /17', 'Black /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Black Vinyl'];\n      } else if (num >= 271 && num <= 281) {\n        type = 'Relic Memorabilia';\n        name = 'Michael Jackson - Relic Poster Memorabilia #$num';\n        allowedVariations = ['Base', 'Foil', 'Red /87', 'Gold /17', 'Black /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Black Vinyl'];\n      } else if (num >= 282 && num <= 285) {\n        type = 'Relic Memorabilia';\n        name = 'Michael Jackson - Relic Ticket Stub Memorabilia #$num';\n        allowedVariations = ['Base', 'Foil', 'Red /87', 'Gold /17', 'Black /17', 'Plat. /15', 'Gold Vinyl', 'Red Vinyl', 'Plat. Vinyl', 'Black Vinyl'];\n      } else if (num == 286) {\n        type = 'Relic Memorabilia';\n        name = 'Michael Jackson - Relic Private Collection Memorabilia #286';\n        allowedVariations = ['Black /87', 'Red /87', 'Gold /17', 'Plat. /15', 'Red Vinyl', 'Gold Vinyl', 'Plat. Vinyl', 'Black Vinyl'];\n      } else if (num >= 287 && num <= 290) {\n        type = 'Cut Autograph';\n        name = 'Michael Jackson - Cut Autograph #$num';\n        allowedVariations = ['Base'];\n      } else if (num >= 291 && num <= 292) {\n        type = 'Cut Autograph';\n        name = 'Michael Jackson - Memorabilia Cut Autograph #$num';\n        allowedVariations = ['Base'];\n      } else if (num >= 293 && num <= 296) {\n        type = 'Gemstone Relic';\n        name = num == 293 ? 'Michael Jackson - Real Ruby Memorabilia #293' : (num == 294 ? 'Michael Jackson - Real Emerald Memorabilia #294' : (num == 295 ? 'Michael Jackson - Real Sapphire Memorabilia #295' : 'Michael Jackson - Real Diamond Memorabilia #296'));\n        allowedVariations = ['Base /10'];\n      } else if (num >= 297 && num <= 300) {\n        type = 'Precious Metal Relic';\n        name = num == 297 ? 'Michael Jackson - Real Silver Memorabilia #297' : (num == 298 ? 'Michael Jackson - Real Gold Memorabilia #298' : (num == 299 ? 'Michael Jackson - Real Platinum Memorabilia #299' : 'Michael Jackson - Real Pearl Memorabilia #300'));\n        allowedVariations = ['Base /10'];\n      }\n\n      Map<String, bool> initialVars = {for (var v in allowedVariations) v: false};\n      list.add(MJCardItem(\n        cardNumber: num,\n        cardName: name,\n        cardType: type,\n        variations: initialVars,\n      ));\n    }\n    return list;\n  }\n\n  String _searchQuery = '';\n  String _selectedCategory = 'All';\n  bool _isLoading = true;\n\n  final List<String> _categories = [\n    'All', \n    'Base Set', \n    'Spotlight Base', \n    'Shortprint', \n    'Throwback', \n    'VIP Pass', \n    'SignaGraph', \n    'Inserts', \n    'Relic Memorabilia', \n    'Cut Autograph', \n    'Gemstone Relic'\n  ];\n\n  @override\n  void initState() {\n    super.initState();\n    _loadUserCollection();\n  }\n\n  Future<void> _loadUserCollection() async {\n    if (user == null) return;\n    try {\n      final docRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);\n      final docSnap = await docRef.get();\n\n      if (docSnap.exists && docSnap.data() != null) {\n        final data = docSnap.data()!['collectedCards'] as Map<String, dynamic>?;\n        if (data != null) {\n          setState(() {\n            for (var card in _masterChecklist) {\n              if (data.containsKey(card.cardNumber.toString())) {\n                var cardData = data[card.cardNumber.toString()];\n                if (cardData is Map) {\n                  card.variations = Map<String, bool>.from(cardData['variations'] ?? {});\n                  card.serialNumbers = Map<String, String>.from(cardData['serialNumbers'] ?? {});\n                  card.notes = cardData['notes'] ?? '';\n                } else if (cardData is bool) {\n                  // Backward compatibility if old boolean format exists\n                  if (card.variations.isNotEmpty) {\n                    String firstKey = card.variations.keys.first;\n                    card.variations[firstKey] = cardData;\n                  }\n                }\n              }\n            }\n          });\n        }\n      }\n    } catch (e) {\n      debugPrint(\"Error loading collection: $e\");\n    } finally {\n      setState(() {\n        _isLoading = false;\n      });\n    }\n  }\n\n  Future<void> _saveCollectionToFirebase() async {\n    if (user == null) return;\n    try {\n      Map<String, dynamic> updateData = {};\n      for (var item in _masterChecklist) {\n        updateData[item.cardNumber.toString()] = item.toJson();\n      }\n\n      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({\n        'collectedCards': updateData,\n        'lastUpdated': FieldValue.serverTimestamp(),\n      }, SetOptions(merge: true));\n    } catch (e) {\n      debugPrint(\"Error saving collection: $e\");\n    }\n  }\n\n  void _openCardDetailModal(MJCardItem card) {\n    showModalBottomSheet(\n      context: context,\n      isScrollControlled: true,\n      backgroundColor: const Color(0xFF1E1E1E),\n      shape: const RoundedRectangleBorder(\n        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),\n      ),\n      builder: (context) {\n        return StatefulBuilder(\n          builder: (BuildContext context, StateSetter setModalState) {\n            return Padding(\n              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),\n              child: SingleChildScrollView(\n                child: Column(\n                  mainAxisSize: MainAxisSize.min,\n                  crossAxisAlignment: CrossAxisAlignment.start,\n                  children: [\n                    Row(\n                      mainAxisAlignment: MainAxisAlignment.spaceBetween,\n                      children: [\n                        Text(\n                          '#${card.cardNumber} - ${card.cardName}',\n                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber),\n                        ),\n                        IconButton(\n                          icon: const Icon(Icons.close, color: Colors.white),\n                          onPressed: () => Navigator.pop(context),\n                        ),\n                      ],\n                    ),\n                    const Divider(color: Colors.grey),\n                    const Text('Select Variations Owned & Enter Serial Numbers:', style: TextStyle(color: Colors.grey, fontSize: 13)),\n                    const SizedBox(height: 10),\n                    ...card.variations.keys.map((variationName) {\n                      bool isChecked = card.variations[variationName] ?? false;\n                      bool isNumbered = variationName.contains('/') || variationName.contains('/10');\n\n                      return Column(\n                        crossAxisAlignment: CrossAxisAlignment.start,\n                        children: [\n                          CheckboxListTile(\n                            title: Text(variationName, style: const TextStyle(fontSize: 14)),\n                            value: isChecked,\n                            activeColor: Colors.amber,\n                            checkColor: Colors.black,\n                            contentPadding: EdgeInsets.zero,\n                            onChanged: (bool? value) {\n                              setModalState(() {\n                                setState(() {\n                                  card.variations[variationName] = value ?? false;\n                                  if (!(value ?? false)) {\n                                    card.serialNumbers.remove(variationName);\n                                  }\n                                });\n                              });\n                              _saveCollectionToFirebase();\n                            },\n                          ),\n                          if (isChecked && isNumbered)\n                            Padding(\n                              padding: const EdgeInsets.only(left: 16, bottom: 8),\n                              child: TextField(\n                                controller: TextEditingController(text: card.serialNumbers[variationName] ?? '')\n                                  ..selection = TextSelection.fromPosition(TextPosition(offset: (card.serialNumbers[variationName] ?? '').length)),\n                                decoration: InputDecoration(\n                                  labelText: 'Enter Serial Number (e.g. 12/87)',\n                                  labelStyle: const TextStyle(fontSize: 12, color: Colors.amber),\n                                  filled: true,\n                                  fillColor: const Color(0xFF141414),\n                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),\n                                  isDense: true,\n                                ),\n                                onChanged: (val) {\n                                  card.serialNumbers[variationName] = val;\n                                  _saveCollectionToFirebase();\n                                },\n                              ),\n                            ),\n                        ],\n                      );\n                    }),\n                    const SizedBox(height: 10),\n                    TextField(\n                      controller: TextEditingController(text: card.notes)\n                        ..selection = TextSelection.fromPosition(TextPosition(offset: card.notes.length)),\n                      decoration: InputDecoration(\n                        labelText: 'Notes (Condition, Grade, etc.)',\n                        labelStyle: const TextStyle(color: Colors.grey),\n                        filled: true,\n                        fillColor: const Color(0xFF141414),\n                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),\n                      ),\n                      onChanged: (val) {\n                        card.notes = val;\n                        _saveCollectionToFirebase();\n                      },\n                    ),\n                  ],\n                ),\n              ),\n            );\n          },\n        );\n      },\n    );\n  }\n\n  @override\n  Widget build(BuildContext context) {\n    if (_isLoading) {\n      return const Scaffold(\n        body: Center(child: CircularProgressIndicator(color: Colors.amber)),\n      );\n    }\n\n    List<MJCardItem> filteredList = _masterChecklist.where((card) {\n      final matchesSearch = card.cardName.toLowerCase().contains(_searchQuery.toLowerCase()) ||\n          card.cardNumber.toString().contains(_searchQuery) ||\n          card.cardType.toLowerCase().contains(_searchQuery.toLowerCase());\n      \n      final matchesCategory = _selectedCategory == 'All' || card.cardType == _selectedCategory;\n\n      return matchesSearch && matchesCategory;\n    }).toList();\n\n    int collectedCount = _masterChecklist.where((card) => card.isCollected).length;\n    double progressPercent = _masterChecklist.isEmpty ? 0.0 : collectedCount / _masterChecklist.length;\n\n    return Scaffold(\n      appBar: AppBar(\n        title: const Text('Bad World Tour Tracker', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),\n        centerTitle: true,\n        backgroundColor: const Color(0xFF161616),\n        elevation: 0,\n        actions: [\n          IconButton(\n            icon: const Icon(Icons.person_outline, color: Colors.amber),\n            onPressed: () {\n              Navigator.push(\n                context,\n                MaterialPageRoute(builder: (context) => const AccountScreen()),\n              );\n            },\n          ),\n          IconButton(\n            icon: const Icon(Icons.logout, color: Colors.amber),\n            onPressed: () async {\n              await FirebaseAuth.instance.signOut();\n            },\n          ),\n        ],\n      ),\n      body: Column(\n        children: [\n          Container(\n            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),\n            decoration: const BoxDecoration(\n              color: Color(0xFF181818),\n              border: Border(bottom: BorderSide(color: Color(0xFF2C2C2C))),\n            ),\n            child: Column(\n              children: [\n                Row(\n                  mainAxisAlignment: MainAxisAlignment.spaceBetween,\n                  children: [\n                    const Text(\n                      'Collection Progress',\n                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),\n                    ),\n                    Text(\n                      '$collectedCount / ${_masterChecklist.length} (${(progressPercent * 100).toStringAsFixed(0)}%)',\n                      style: const TextStyle(\n                        fontSize: 14,\n                        fontWeight: FontWeight.bold,\n                        color: Colors.amber,\n                      ),\n                    ),\n                  ],\n                ),\n                const SizedBox(height: 10),\n                ClipRRect(\n                  borderRadius: BorderRadius.circular(10),\n                  child: LinearProgressIndicator(\n                    value: progressPercent,\n                    minHeight: 8,\n                    backgroundColor: const Color(0xFF2C2C2C),\n                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),\n                  ),\n                ),\n              ],\n            ),\n          ),\n          Padding(\n            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),\n            child: TextField(\n              onChanged: (value) => setState(() => _searchQuery = value),\n              decoration: InputDecoration(\n                hintText: 'Search by card #, name, or set type...',\n                hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),\n                prefixIcon: const Icon(Icons.search, color: Colors.amber),\n                filled: true,\n                fillColor: const Color(0xFF1A1A1A),\n                contentPadding: const EdgeInsets.symmetric(vertical: 0),\n                border: OutlineInputBorder(\n                  borderRadius: BorderRadius.circular(12.0),\n                  borderSide: BorderSide.none,\n                ),\n              ),\n            ),\n          ),\n          SizedBox(\n            height: 50,\n            child: ListView.builder(\n              scrollDirection: Axis.horizontal,\n              padding: const EdgeInsets.symmetric(horizontal: 12),\n              itemCount: _categories.length,\n              itemBuilder: (context, index) {\n                final category = _categories[index];\n                final isSelected = _selectedCategory == category;\n                return Padding(\n                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),\n                  child: ChoiceChip(\n                    label: Text(category),\n                    selected: isSelected,\n                    selectedColor: Colors.amber,\n                    backgroundColor: const Color(0xFF1E1E1E),\n                    labelStyle: TextStyle(\n                      color: isSelected ? Colors.black : Colors.white70,\n                      fontWeight: FontWeight.bold,\n                      fontSize: 12,\n                    ),\n                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),\n                    onSelected: (selected) {\n                      setState(() {\n                        _selectedCategory = category;\n                      });\n                    },\n                  ),\n                );\n              },\n            ),\n          ),\n          Expanded(\n            child: filteredList.isEmpty\n                ? Center(\n                    child: Text(\n                      'No cards found',\n                      style: TextStyle(color: Colors.grey.shade600, fontSize: 16),\n                    ),\n                  )\n                : GridView.builder(\n                    padding: const EdgeInsets.all(12.0),\n                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(\n                      crossAxisCount: 2,\n                      childAspectRatio: 0.72,\n                      crossAxisSpacing: 12.0,\n                      mainAxisSpacing: 12.0,\n                    ),\n                    itemCount: filteredList.length,\n                    itemBuilder: (context, index) {\n                      final card = filteredList[index];\n                      return GestureDetector(\n                        onTap: () => _openCardDetailModal(card),\n                        child: AnimatedContainer(\n                          duration: const Duration(milliseconds: 250),\n                          decoration: BoxDecoration(\n                            color: card.isCollected ? const Color(0xFF221E12) : const Color(0xFF1A1A1A),\n                            borderRadius: BorderRadius.circular(14.0),\n                            border: Border.all(\n                              color: card.isCollected ? Colors.amber.shade600 : Colors.grey.shade800,\n                              width: card.isCollected ? 2.0 : 1.0,\n                            ),\n                          ),\n                          child: Padding(\n                            padding: const EdgeInsets.all(10.0),\n                            child: Column(\n                              mainAxisAlignment: MainAxisAlignment.center,\n                              children: [\n                                Row(\n                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,\n                                  children: [\n                                    Text(\n                                      '#${card.cardNumber}',\n                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 13),\n                                    ),\n                                    Icon(\n                                      card.isCollected ? Icons.check_circle : Icons.radio_button_unchecked,\n                                      color: card.isCollected ? Colors.amber : Colors.grey.shade700,\n                                      size: 20,\n                                    ),\n                                  ],\n                                ),\n                                const Spacer(),\n                                Icon(\n                                  card.isCollected ? Icons.album : Icons.lock_outline,\n                                  size: 42,\n                                  color: card.isCollected ? Colors.amber : Colors.grey.shade700,\n                                ),\n                                const Spacer(),\n                                Text(\n                                  card.cardName,\n                                  textAlign: TextAlign.center,\n                                  maxLines: 2,\n                                  overflow: TextOverflow.ellipsis,\n                                  style: TextStyle(\n                                    fontWeight: FontWeight.bold,\n                                    fontSize: 13,\n                                    color: card.isCollected ? Colors.white : Colors.grey.shade400,\n                                  ),\n                                ),\n                                const SizedBox(height: 4),\n                                Text(\n                                  card.cardType,\n                                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),\n                                ),\n                                const SizedBox(height: 8),\n                                Container(\n                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),\n                                  decoration: BoxDecoration(\n                                    color: card.isCollected ? Colors.amber : Colors.grey.shade800,\n                                    borderRadius: BorderRadius.circular(6),\n                                  ),\n                                  child: Text(\n                                    card.isCollected ? 'OWNED' : 'MISSING',\n                                    style: TextStyle(\n                                      fontSize: 9,\n                                      fontWeight: FontWeight.bold,\n                                      color: card.isCollected ? Colors.black : Colors.white,\n                                    ),\n                                  ),\n                                ),\n                              ],\n                            ),\n                          ),\n                        ),\n                      );\n                    },\n                  ),\n          ),\n        ],\n      ),\n    );\n  }\n}",
      "lib\\username_setup_screen.dart": "import 'package:flutter/material.dart';\nimport 'package:firebase_auth/firebase_auth.dart';\nimport 'package:cloud_firestore/cloud_firestore.dart';\nimport 'main.dart';\n\nclass UsernameSetupScreen extends StatefulWidget {\n  const UsernameSetupScreen({super.key, required this.user});\n  final User user;\n\n  @override\n  State<UsernameSetupScreen> createState() => _UsernameSetupScreenState();\n}\n\nclass _UsernameSetupScreenState extends State<UsernameSetupScreen> {\n  final _usernameController = TextEditingController();\n  bool _isLoading = false;\n  String _errorMessage = '';\n\n  Future<void> _saveUsernameAndProceed() async {\n    final username = _usernameController.text.trim();\n    if (username.length < 3) {\n      setState(() => _errorMessage = 'Username must be at least 3 characters.');\n      return;\n    }\n\n    setState(() {\n      _isLoading = true;\n      _errorMessage = '';\n    });\n\n    try {\n      // Check availability in database\n      final query = await FirebaseFirestore.instance\n          .collection('users')\n          .where('username', isEqualTo: username)\n          .get();\n\n      if (query.docs.isNotEmpty) {\n        setState(() {\n          _errorMessage = 'Username is already taken. Choose another.';\n          _isLoading = false;\n        });\n        return;\n      }\n\n      // Save user profile data\n      await FirebaseFirestore.instance.collection('users').doc(widget.user.uid).set({\n        'username': username,\n        'email': widget.user.email,\n        'profileIcon': 'album',\n        'profileImageBase64': '',\n        'friends': [],\n        'createdAt': FieldValue.serverTimestamp(),\n      }, SetOptions(merge: true));\n\n      if (!mounted) return;\n      Navigator.pushReplacement(\n        context,\n        MaterialPageRoute(builder: (context) => const AlbumScreen()),\n      );\n    } catch (e) {\n      setState(() {\n        _errorMessage = 'Error saving username: $e';\n        _isLoading = false;\n      });\n    }\n  }\n\n  @override\n  Widget build(BuildContext context) {\n    return Scaffold(\n      body: Padding(\n        padding: const EdgeInsets.all(24.0),\n        child: Center(\n          child: SingleChildScrollView(\n            child: Column(\n              mainAxisAlignment: MainAxisAlignment.center,\n              children: [\n                const Icon(Icons.person_add, size: 70, color: Colors.amber),\n                const SizedBox(height: 16),\n                const Text(\n                  'Choose Your Collector Username',\n                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),\n                  textAlign: TextAlign.center,\n                ),\n                const SizedBox(height: 8),\n                const Text(\n                  'This is how other collectors will find you.',\n                  style: TextStyle(color: Colors.grey, fontSize: 13),\n                  textAlign: TextAlign.center,\n                ),\n                const SizedBox(height: 32),\n                TextField(\n                  controller: _usernameController,\n                  decoration: InputDecoration(\n                    labelText: 'Username',\n                    filled: true,\n                    fillColor: const Color(0xFF1E1E1E),\n                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),\n                  ),\n                ),\n                const SizedBox(height: 16),\n                if (_errorMessage.isNotEmpty)\n                  Text(_errorMessage, style: const TextStyle(color: Colors.red, fontSize: 12), textAlign: TextAlign.center),\n                const SizedBox(height: 20),\n                _isLoading\n                    ? const CircularProgressIndicator(color: Colors.amber)\n                    : ElevatedButton(\n                        style: ElevatedButton.styleFrom(\n                          backgroundColor: Colors.amber,\n                          foregroundColor: Colors.black,\n                          minimumSize: const Size.fromHeight(50),\n                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),\n                        ),\n                        onPressed: _saveUsernameAndProceed,\n                        child: const Text('Start Collecting', style: TextStyle(fontWeight: FontWeight.bold)),\n                      ),\n              ],\n            ),\n          ),\n        ),\n      ),\n    );\n  }\n}",
      "web\\manifest.json": "{\n    \"name\": \"mj_card_tracker\",\n    \"short_name\": \"mj_card_tracker\",\n    \"start_url\": \".\",\n    \"display\": \"standalone\",\n    \"background_color\": \"#0175C2\",\n    \"theme_color\": \"#0175C2\",\n    \"description\": \"A new Flutter project.\",\n    \"orientation\": \"portrait-primary\",\n    \"prefer_related_applications\": false,\n    \"icons\": [\n        {\n            \"src\": \"icons/Icon-192.png\",\n            \"sizes\": \"192x192\",\n            \"type\": \"image/png\"\n        },\n        {\n            \"src\": \"icons/Icon-512.png\",\n            \"sizes\": \"512x512\",\n            \"type\": \"image/png\"\n        },\n        {\n            \"src\": \"icons/Icon-maskable-192.png\",\n            \"sizes\": \"192x192\",\n            \"type\": \"image/png\",\n            \"purpose\": \"maskable\"\n        },\n        {\n            \"src\": \"icons/Icon-maskable-512.png\",\n            \"sizes\": \"512x512\",\n            \"type\": \"image/png\",\n            \"purpose\": \"maskable\"\n        }\n    ]\n}\n"
    }
    ```
  - **[FILE]** pubspec.yaml
    ```yaml
    name: mj_card_tracker
    description: "Keepsake: MJ Card Collector app."
    publish_to: 'none'
    
    version: 1.0.0+1
    
    environment:
      sdk: ^3.12.0
    
    dependencies:
      flutter:
        sdk: flutter
      firebase_core: ^3.6.0
      firebase_auth: ^5.3.1
      cloud_firestore: ^5.4.4
      firebase_storage: ^12.3.0
      image_picker: ^1.1.2
    
    dev_dependencies:
      flutter_test:
        sdk: flutter
      flutter_lints: ^5.0.0
      flutter_launcher_icons: "^0.14.4"
    
    flutter_launcher_icons:
      image_path: "assets/LOGOPNG.png"
      android: true
      ios: true
    
    flutter:
      uses-material-design: true
    
      assets:
        - assets/
    ```
  - **[DIR]** assets/
  - **[DIR]** lib/
    - **[FILE]** account_screen.dart
      ```dart
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
      ```
    - **[FILE]** auth_screen.dart
      ```dart
      import 'package:flutter/material.dart';
      import 'package:firebase_auth/firebase_auth.dart';
      import 'package:cloud_firestore/cloud_firestore.dart';
      import 'main.dart';
      
      class AuthScreen extends StatefulWidget {
        const AuthScreen({super.key});
      
        @override
        State<AuthScreen> createState() => _AuthScreenState();
      }
      
      class _AuthScreenState extends State<AuthScreen> {
        final _emailController = TextEditingController();
        final _passwordController = TextEditingController();
        final _usernameController = TextEditingController();
      
        bool _isLogin = true;
        bool _isLoading = false;
        String _errorMessage = '';
      
        bool _validatePassword(String password) {
          if (password.length < 6) {
            setState(() => _errorMessage = 'Password must be at least 6 characters long.');
            return false;
          }
          return true;
        }
      
        Future<void> _submitAuthForm() async {
          final email = _emailController.text.trim();
          final password = _passwordController.text.trim();
          final username = _usernameController.text.trim();
      
          if (email.isEmpty || password.isEmpty || (!_isLogin && username.isEmpty)) {
            setState(() => _errorMessage = 'Please fill in all fields.');
            return;
          }
      
          if (!_isLogin && !_validatePassword(password)) {
            return;
          }
      
          if (!_isLogin && username.length < 3) {
            setState(() => _errorMessage = 'Username must be at least 3 characters.');
            return;
          }
      
          setState(() {
            _isLoading = true;
            _errorMessage = '';
          });
      
          try {
            if (_isLogin) {
              UserCredential userCred = await FirebaseAuth.instance.signInWithEmailAndPassword(
                email: email,
                password: password,
              );
      
              final userDoc = await FirebaseFirestore.instance.collection('users').doc(userCred.user!.uid).get();
              if (!userDoc.exists || userDoc.data()?['username'] == null || (userDoc.data()?['username'] as String).isEmpty) {
                await FirebaseFirestore.instance.collection('users').doc(userCred.user!.uid).set({
                  'username': email.split('@')[0],
                  'email': email,
                  'profileIcon': 'album',
                  'profileImageBase64': '',
                  'friends': [],
                }, SetOptions(merge: true));
              }
            } else {
              final query = await FirebaseFirestore.instance
                  .collection('users')
                  .where('username', isEqualTo: username)
                  .get();
      
              if (query.docs.isNotEmpty) {
                setState(() {
                  _errorMessage = 'Username is already taken. Choose another.';
                  _isLoading = false;
                });
                return;
              }
      
              UserCredential userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                email: email,
                password: password,
              );
      
              await FirebaseFirestore.instance.collection('users').doc(userCred.user!.uid).set({
                'username': username,
                'email': email,
                'profileIcon': 'album',
                'profileImageBase64': '',
                'friends': [],
                'createdAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
            }
      
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AlbumScreen()),
            );
          } on FirebaseAuthException catch (error) {
            setState(() {
              _errorMessage = error.message ?? 'An authentication error occurred.';
              _isLoading = false;
            });
          } catch (error) {
            setState(() {
              _errorMessage = error.toString();
              _isLoading = false;
            });
          }
        }
      
        Future<void> _resetPassword() async {
          final email = _emailController.text.trim();
          if (email.isEmpty) {
            setState(() => _errorMessage = 'Please enter your email above to reset password.');
            return;
          }
      
          try {
            await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password reset link sent! Please check your inbox and spam/junk folder.'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 4),
              ),
            );
            setState(() => _errorMessage = '');
          } on FirebaseAuthException catch (e) {
            setState(() => _errorMessage = e.message ?? 'Failed to send reset email.');
          }
        }
      
        @override
        Widget build(BuildContext context) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.album, size: 80, color: Colors.amber),
                      const SizedBox(height: 16),
                      Text(
                        _isLogin ? 'MJ Card Tracker' : 'Create Account',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 32),
                      if (!_isLogin) ...[
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            filled: true,
                            fillColor: const Color(0xFF1E1E1E),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          filled: true,
                          fillColor: const Color(0xFF1E1E1E),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password (min 6 chars)',
                          filled: true,
                          fillColor: const Color(0xFF1E1E1E),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      // Forgot Password Button (Only shown in Login mode)
                      if (_isLogin)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _resetPassword,
                            child: const Text('Forgot Password?', style: TextStyle(color: Colors.grey, fontSize: 13)),
                          ),
                        ),
                      const SizedBox(height: 10),
                      if (_errorMessage.isNotEmpty)
                        Text(_errorMessage, style: const TextStyle(color: Colors.red, fontSize: 12), textAlign: TextAlign.center),
                      const SizedBox(height: 20),
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.amber)
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black,
                                minimumSize: const Size.fromHeight(50),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: _submitAuthForm,
                              child: Text(_isLogin ? 'Login' : 'Sign Up', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                            _errorMessage = '';
                          });
                        },
                        child: Text(
                          _isLogin ? 'Create a new account' : 'I already have an account',
                          style: const TextStyle(color: Colors.amber),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      }
      ```
    - **[FILE]** card_model.dart
      ```dart
      class MJCardItem {
        final int cardNumber;
        final String cardName;
        final String cardType;
      
        // A map to store whether each specific variation is checked (e.g., {'Base': true, 'Red /87': false})
        Map<String, bool> variations;
      
        // A map to store the specific serial number entered for numbered parallels (e.g., {'Red /87': '42/87'})
        Map<String, String> serialNumbers;
      
        String notes;
      
        MJCardItem({
          required this.cardNumber,
          required this.cardName,
          required this.cardType,
          Map<String, bool>? variations,
          Map<String, String>? serialNumbers,
          this.notes = '',
        })  : variations = variations ?? {},
              serialNumbers = serialNumbers ?? {};
      
        // Helper getter to check if any variation of this card is collected
        bool get isCollected => variations.values.contains(true);
      
        // Convert to JSON/Map if you are saving to Firebase or local storage later
        Map<String, dynamic> toJson() => {
              'cardNumber': cardNumber,
              'cardName': cardName,
              'cardType': cardType,
              'variations': variations,
              'serialNumbers': serialNumbers,
              'notes': notes,
            };
      
        // Create from JSON/Map
        factory MJCardItem.fromJson(Map<String, dynamic> json) {
          return MJCardItem(
            cardNumber: json['cardNumber'] ?? 0,
            cardName: json['cardName'] ?? '',
            cardType: json['cardType'] ?? '',
            variations: Map<String, bool>.from(json['variations'] ?? {}),
            serialNumbers: Map<String, String>.from(json['serialNumbers'] ?? {}),
            notes: json['notes'] ?? '',
          );
        }
      }
      ```
    - **[FILE]** firebase_options.dart
      ```dart
      import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
      import 'package:flutter/foundation.dart'
          show defaultTargetPlatform, kIsWeb, TargetPlatform;
      
      class DefaultFirebaseOptions {
        static FirebaseOptions get currentPlatform {
          if (kIsWeb) {
            throw UnsupportedError(
              'DefaultFirebaseOptions have not been configured for web.',
            );
          }
          switch (defaultTargetPlatform) {
            case TargetPlatform.android:
              return android;
            case TargetPlatform.iOS:
              throw UnsupportedError(
                'DefaultFirebaseOptions have not been configured for iOS.',
              );
            case TargetPlatform.macOS:
              throw UnsupportedError(
                'DefaultFirebaseOptions have not been configured for macOS.',
              );
            case TargetPlatform.windows:
              throw UnsupportedError(
                'DefaultFirebaseOptions have not been configured for windows.',
              );
            case TargetPlatform.linux:
              throw UnsupportedError(
                'DefaultFirebaseOptions have not been configured for Linux.',
              );
            default:
              throw UnsupportedError(
                'DefaultFirebaseOptions are not supported for this platform.',
              );
          }
        }
      
        static const FirebaseOptions android = FirebaseOptions(
          apiKey: 'AIzaSyBfmLYUUtwHTInPFDdP9FmP_n2UfvHvYys',
          appId: '1:1036077654913:android:541c4321f9a4230300fe80',
          messagingSenderId: '1036077654913',
          projectId: 'mj-card-tracker',
        );
      }
      ```
    - **[FILE]** friend_collection_screen.dart
      ```dart
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
      ```
    - **[FILE]** level_system.dart
      ```dart
      class LevelSystem {
        static final List<String> levelTitles = [
          // Levels 1-5: Early Days & Motown
          'Got to Be There',
          'Ben',
          'Music and Me',
          'Forever, Michael',
          'Off the Wall',
      
          // Levels 6-10: Thriller Era
          'Wanna Be Startin\' Somethin\'',
          'The Girl Is Mine',
          'Thriller',
          'Beat It',
          'Billie Jean',
      
          // Levels 11-15: Bad Era
          'Bad',
          'Smooth Criminal',
          'The Way You Make Me Feel',
          'Man in the Mirror',
          'Dirty Diana',
      
          // Levels 16-20: Dangerous Era
          'Jam',
          'In the Closet',
          'Remember the Time',
          'Heal the World',
          'Black or White',
      
          // Levels 21-25: HIStory Era
          'Scream',
          'They Don\'t Care About Us',
          'Stranger in Moscow',
          'Earth Song',
          'You Are Not Alone',
      
          // Levels 26-30: Legacy & King of Pop
          'Blood on the Dance Floor',
          'Ghosts',
          'The Ultimate Collection',
          'Xscape',
          'King of Pop',
        ];
      
        static Map<String, dynamic> calculateLevel(int collectedCount) {
          // Every 10 cards = 1 level. Max level is 30.
          int currentLevel = (collectedCount ~/ 10) + 1;
          if (currentLevel > 30) currentLevel = 30;
          if (currentLevel < 1) currentLevel = 1;
      
          int totalXp = collectedCount * 10;
          int xpForCurrentLevel = (currentLevel - 1) * 100;
          int xpNextLevel = currentLevel * 100;
      
          // Cap progress at max level
          int currentLevelProgress = currentLevel == 30 ? 100 : (totalXp - xpForCurrentLevel);
          int xpNeededForNext = currentLevel == 30 ? 100 : 100;
      
          String title = levelTitles[currentLevel - 1];
      
          return {
            'level': currentLevel,
            'title': title,
            'xp': totalXp,
            'progress': currentLevel == 30 ? 1.0 : (currentLevelProgress / xpNeededForNext),
            'progressText': '$currentLevelProgress / $xpNeededForNext XP',
          };
        }
      }
      ```
    - **[FILE]** main.dart
      ```dart
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
                                  onPressed: () => Navigator.pop(context), // Fixed close button action
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
      ```
    - **[FILE]** username_setup_screen.dart
      ```dart
      import 'package:flutter/material.dart';
      import 'package:firebase_auth/firebase_auth.dart';
      import 'package:cloud_firestore/cloud_firestore.dart';
      import 'main.dart';
      
      class UsernameSetupScreen extends StatefulWidget {
        const UsernameSetupScreen({super.key, required this.user});
        final User user;
      
        @override
        State<UsernameSetupScreen> createState() => _UsernameSetupScreenState();
      }
      
      class _UsernameSetupScreenState extends State<UsernameSetupScreen> {
        final _usernameController = TextEditingController();
        bool _isLoading = false;
        String _errorMessage = '';
      
        Future<void> _saveUsernameAndProceed() async {
          final username = _usernameController.text.trim();
          if (username.length < 3) {
            setState(() => _errorMessage = 'Username must be at least 3 characters.');
            return;
          }
      
          setState(() {
            _isLoading = true;
            _errorMessage = '';
          });
      
          try {
            // Check availability in database
            final query = await FirebaseFirestore.instance
                .collection('users')
                .where('username', isEqualTo: username)
                .get();
      
            if (query.docs.isNotEmpty) {
              setState(() {
                _errorMessage = 'Username is already taken. Choose another.';
                _isLoading = false;
              });
              return;
            }
      
            // Save user profile data
            await FirebaseFirestore.instance.collection('users').doc(widget.user.uid).set({
              'username': username,
              'email': widget.user.email,
              'profileIcon': 'album',
              'profileImageBase64': '',
              'friends': [],
              'createdAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
      
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AlbumScreen()),
            );
          } catch (e) {
            setState(() {
              _errorMessage = 'Error saving username: $e';
              _isLoading = false;
            });
          }
        }
      
        @override
        Widget build(BuildContext context) {
          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person_add, size: 70, color: Colors.amber),
                      const SizedBox(height: 16),
                      const Text(
                        'Choose Your Collector Username',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'This is how other collectors will find you.',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          filled: true,
                          fillColor: const Color(0xFF1E1E1E),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_errorMessage.isNotEmpty)
                        Text(_errorMessage, style: const TextStyle(color: Colors.red, fontSize: 12), textAlign: TextAlign.center),
                      const SizedBox(height: 20),
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.amber)
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black,
                                minimumSize: const Size.fromHeight(50),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: _saveUsernameAndProceed,
                              child: const Text('Start Collecting', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      }
      ```
