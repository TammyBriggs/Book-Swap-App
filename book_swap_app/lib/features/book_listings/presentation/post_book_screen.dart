import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:book_swap_app/core/constants/colors.dart';
import 'package:book_swap_app/features/auth/application/auth_providers.dart';
import 'package:book_swap_app/features/book_listings/domain/book.dart';
import 'package:book_swap_app/features/book_listings/application/book_providers.dart';

class PostBookScreen extends ConsumerStatefulWidget {
  final Book? bookToEdit;

  const PostBookScreen({super.key, this.bookToEdit});

  @override
  ConsumerState<PostBookScreen> createState() => _PostBookScreenState();
}

class _PostBookScreenState extends ConsumerState<PostBookScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late BookCondition _selectedCondition;
  XFile? _selectedImage;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  bool get _isEditing => widget.bookToEdit != null;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.bookToEdit?.title ?? '');
    _authorController =
        TextEditingController(text: widget.bookToEdit?.author ?? '');
    _selectedCondition = widget.bookToEdit?.condition ?? BookCondition.used;
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (!_isEditing && _selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image')),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final user = ref.read(firebaseAuthProvider).currentUser!;
        final repository = ref.read(bookRepositoryProvider);

        if (_isEditing) {
          final updatedBook = widget.bookToEdit!.copyWith(
            title: _titleController.text.trim(),
            author: _authorController.text.trim(),
            condition: _selectedCondition,
          );
          await repository.updateBook(updatedBook, _selectedImage);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Book updated successfully!')),
            );
          }
        } else {
          final newBook = Book(
            title: _titleController.text.trim(),
            author: _authorController.text.trim(),
            condition: _selectedCondition,
            imageUrl: '',
            ownerId: user.uid,
            ownerEmail: user.email!,
          );
          await repository.postBook(newBook, _selectedImage!);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Book posted successfully!')),
            );
          }
        }

        if (mounted) {
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Book' : 'Post a Book'),
        backgroundColor: kBackgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                    image: _selectedImage != null
                        ? DecorationImage(
                      image: FileImage(File(_selectedImage!.path)),
                      fit: BoxFit.cover,
                    )
                        : (_isEditing && widget.bookToEdit!.imageUrl.isNotEmpty)
                        ? DecorationImage(
                      image:
                      NetworkImage(widget.bookToEdit!.imageUrl),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: (_selectedImage == null &&
                      (!_isEditing || widget.bookToEdit!.imageUrl.isEmpty))
                      ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt,
                          size: 50, color: Colors.white54),
                      SizedBox(height: 8),
                      Text('Tap to add cover photo',
                          style: TextStyle(color: Colors.white54)),
                    ],
                  )
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Book Title',
                  filled: true,
                  fillColor: kPrimaryColor,
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val!.isEmpty ? 'Enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'Author',
                  filled: true,
                  fillColor: kPrimaryColor,
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val!.isEmpty ? 'Enter an author' : null,
              ),
              const SizedBox(height: 24),
              const Text('Condition', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<BookCondition>(
                    value: _selectedCondition,
                    dropdownColor: kPrimaryColor,
                    isExpanded: true,
                    items: BookCondition.values.map((BookCondition condition) {
                      String displayText;
                      if (condition == BookCondition.brandNew) {
                        displayText = 'New';
                      } else if (condition == BookCondition.likeNew) {
                        displayText = 'Like New';
                      } else {
                        displayText = condition.toString().split('.').last[0].toUpperCase() +
                            condition.toString().split('.').last.substring(1);
                      }

                      return DropdownMenuItem<BookCondition>(
                        value: condition,
                        child: Text(
                          displayText,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (BookCondition? newValue) {
                      if (newValue != null) {
                        setState(() => _selectedCondition = newValue);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kSecondaryColor,
                  foregroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: Text(_isEditing ? 'Update Book' : 'Post Book'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}