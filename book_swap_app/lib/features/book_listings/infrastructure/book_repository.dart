import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:book_swap_app/features/book_listings/domain/book.dart';
import 'package:book_swap_app/secrets.dart';

class BookRepository {
  final FirebaseFirestore _firestore;
  final CloudinaryPublic _cloudinary;

  BookRepository(this._firestore)
      : _cloudinary = CloudinaryPublic(
    kCloudinaryCloudName,
    kCloudinaryUploadPreset,
    cache: false,
  );

  // Collection reference for cleaner code
  CollectionReference<Map<String, dynamic>> get _booksCollection =>
      _firestore.collection('books');

  /// Uploads an image to Cloudinary and returns the secure URL.
  Future<String> _uploadImage(XFile image) async {
    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          image.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'book_covers',
        ),
      );
      return response.secureUrl;
    } on CloudinaryException catch (e) {
      throw Exception('Image upload failed: ${e.message}');
    } catch (e) {
      throw Exception('Image upload failed: $e');
    }
  }

  /// Creates a new book listing.
  Future<void> postBook(Book book, XFile imageFile) async {
    try {
      // 1. Upload image first
      final imageUrl = await _uploadImage(imageFile);

      // 2. Add image URL to book object
      final bookWithImage = book.copyWith(imageUrl: imageUrl);

      // 3. Save to Firestore
      await _booksCollection.add(bookWithImage.toJson());
    } catch (e) {
      throw Exception('Failed to post book: $e');
    }
  }

  /// READ: Get all available books (for Browse screen)
  Stream<List<Book>> getAvailableBooks() {
    return _booksCollection
        .where('status', isEqualTo: 'Available')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
    });
  }

  /// READ: Get books by a specific owner (for My Listings screen)
  Stream<List<Book>> getBooksByOwner(String ownerId) {
    return _booksCollection
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
    });
  }
}