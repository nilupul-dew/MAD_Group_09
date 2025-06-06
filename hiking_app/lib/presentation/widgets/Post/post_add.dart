import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hiking_app/data/firebase_services/Post/post_firebase.dart';
import 'package:hiking_app/data/firebase_services/user/auth_service.dart';
import 'package:hiking_app/domain/models/Post/post_model.dart';
import 'package:hiking_app/presentation/widgets/Post/post_edit_image_preview.dart';
import 'package:image_picker/image_picker.dart';

class AddPostScreen extends StatefulWidget {
  final bool isEditing;
  final Post? post;

  AddPostScreen({super.key, this.isEditing = false, this.post});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? _existingImageUrl;
  final FirebaseForumService _service = FirebaseForumService();

  String _selectedCategory = '🌲 Nature & Outdoor';
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _isLoading = false;
  // User profile data
  String? _profileImageUrl;
  String? _profileName;
  String? _profileId;

  final List<String> _categories = [
    '🌲 Nature & Outdoor',
    '🏄 Adventure',
    '🌊 Water-Based',
    '🌍 Cultural & Historical',
    '🚴 Sports & Activity-Based',
    '🏙️ Urban & Modern',
    '💆 Relaxation & Wellness',
    '🏡 Accommodation Style',
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
    if (widget.isEditing && widget.post != null) {
      _contentController.text = widget.post!.content;
      _selectedCategory = widget.post!.category;
      _tagsController.text = widget.post!.tags.join(', ');
      if (widget.post!.imageUrl != null) {
        _existingImageUrl =
            widget.post!.imageUrl; // You’ll need to handle this in UI
      }
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final compressedBytes = await _service.compressImage(bytes);

        if (compressedBytes != null) {
          setState(() {
            _selectedImageBytes = compressedBytes;
            _selectedImageName = pickedFile.name;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Function to remove the selected image
  void _removeImage() {
    setState(() {
      _selectedImageBytes = null;
      _selectedImageName = null;
      _existingImageUrl = null;
    });
  }

  // Function to parse tags from the input text
  List<String> _parseTags(String tagsText) {
    if (tagsText.trim().isEmpty) return [];

    return tagsText
        .split('#')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  Future<void> _loadUser() async {
    final userData = await AuthService.getUserData();
    if (userData != null) {
      setState(() {
        _profileImageUrl = userData['profileImage'];
        _profileName = userData['displayName'];
        _profileId = userData['uid'];
      });
    }
  }

  // Function to submit the post
  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;

    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Content cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final tags = _parseTags(_tagsController.text);
      final isEditing = widget.isEditing && widget.post != null;

      if (isEditing) {
        final updatedPost = widget.post!.copyWith(
          content: _contentController.text.trim(),
          category: _selectedCategory,
          tags: tags,
          // Do not overwrite imageUrl or timestamp here
        );

        await _service.updatePost(
          updatedPost,
          imageBytes: _selectedImageBytes,
          imageName: _selectedImageName,
        );
      } else {
        final newPost = Post(
          id: '', // Will be generated by Firestore
          userId: _profileId ?? 'user123',
          title: '',
          content: _contentController.text.trim(),
          category: _selectedCategory,
          tags: tags,
          imageUrl: null,
          timestamp: DateTime.now(),
        );

        await _service.addPost(
          newPost,
          imageBytes: _selectedImageBytes,
          imageName: _selectedImageName,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? 'Post updated successfully!'
                  : 'Post added successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error ${widget.isEditing ? "updating" : "adding"} post: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Post'),
        backgroundColor: Colors.deepOrangeAccent,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Display profile name if loaded
              // ignore: unnecessary_null_comparison
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    // 👤 User Avatar
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _profileImageUrl != null &&
                              _profileImageUrl!.isNotEmpty
                          ? NetworkImage(_profileImageUrl!)
                          : null,
                      child:
                          _profileImageUrl == null || _profileImageUrl!.isEmpty
                              ? const Icon(Icons.person, color: Colors.grey)
                              : null,
                    ),

                    SizedBox(width: 8),
                    Text(
                      _profileName ?? 'Anonymous',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              // Content Text Field
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content *',
                  hintText: 'Share your thoughts...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Content is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 20),

              // Tags Text Field
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (optional)',
                  hintText: 'Enter tags separated by commas',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.tag),
                ),
                onChanged: (value) {
                  // Optional: You can add real-time validation or formatting here
                },
              ),

              const SizedBox(height: 20),

              // Image Selection Section
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Image (optional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_selectedImageBytes != null) ...[
                        ImagePreviewWidget(
                          imageWidget: Image.memory(_selectedImageBytes!),
                          imageName: _selectedImageName,
                          onRemove: _removeImage,
                          onChange: _pickImage,
                        ),
                      ] else if (_existingImageUrl != null) ...[
                        ImagePreviewWidget(
                          imageWidget: Image.network(_existingImageUrl!),
                          imageName: 'Existing Image',
                          onRemove: _removeImage,
                          onChange: _pickImage,
                        ),
                      ] else ...[
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.image),
                          label: const Text('Add Image'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text('Posting...'),
                        ],
                      )
                    : Text(
                        widget.isEditing ? 'Update' : 'Post',
                        style: const TextStyle(fontSize: 18),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
