import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:book_swap_app/features/book_listings/domain/book.dart';
import 'package:book_swap_app/features/book_listings/domain/swap_offer.dart';
import 'package:book_swap_app/secrets.dart'; // Import your secrets

class BookRepository {
  final FirebaseFirestore _firestore;
  final CloudinaryPublic _cloudinary;

  BookRepository(this._firestore)
      : _cloudinary = CloudinaryPublic(
    kCloudinaryCloudName,
    kCloudinaryUploadPreset, // Ensure this is correct in secrets.dart
    cache: false,
  );

  // Collection reference for books
  CollectionReference<Map<String, dynamic>> get _booksCollection =>
      _firestore.collection('books');

  // Collection reference for swaps
  CollectionReference<Map<String, dynamic>> get _swapsCollection =>
      _firestore.collection('swaps');

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

  Future<void> postBook(Book book, XFile imageFile) async {
    try {
      final imageUrl = await _uploadImage(imageFile);
      final bookWithImage = book.copyWith(imageUrl: imageUrl);
      await _booksCollection.add(bookWithImage.toJson());
    } catch (e) {
      throw Exception('Failed to post book: $e');
    }
  }

  Stream<List<Book>> getAvailableBooks() {
    return _booksCollection
        .where('status', isEqualTo: 'Available')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
    });
  }

  Stream<List<Book>> getBooksByOwner(String ownerId) {
    return _booksCollection
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
    });
  }

  /// Updates an existing book listing.
  Future<void> updateBook(Book book, XFile? newImageFile) async {
    if (book.id == null) throw Exception('Cannot update book without an ID');

    try {
      String imageUrl = book.imageUrl;
      if (newImageFile != null) {
        // If a new image was selected, upload it
        imageUrl = await _uploadImage(newImageFile);
      }

      final updatedBook = book.copyWith(imageUrl: imageUrl);
      // We use set with merge to be safe, or just update
      await _booksCollection.doc(book.id).update(updatedBook.toJson());
    } catch (e) {
      throw Exception('Failed to update book: $e');
    }
  }

  Future<void> deleteBook(String bookId) async {
    try {
      await _booksCollection.doc(bookId).delete();
    } catch (e) {
      throw Exception('Failed to delete book: $e');
    }
  }

  /// Requests a swap AND initializes a chat.
  Future<void> requestSwap(Book book, User requester) async {
    if (book.id == null) throw Exception('Book ID is missing.');

    final newOffer = SwapOffer(
      bookId: book.id!,
      bookTitle: book.title,
      bookOwnerId: book.ownerId,
      bookOwnerEmail: book.ownerEmail,
      requesterId: requester.uid,
      requesterEmail: requester.email!,
    );

    final batch = _firestore.batch();

    // 1. Update book status
    final bookRef = _booksCollection.doc(book.id);
    batch.update(bookRef, {'status': 'Pending'});

    // 2. Create swap offer
    final swapRef = _swapsCollection.doc();
    batch.set(swapRef, newOffer.toJson());

    // 3. Initialize chat (same ID as swap offer for easy linking)
    final chatRef = _firestore.collection('chats').doc(swapRef.id);
    batch.set(chatRef, {
      'bookTitle': book.title,
      'participantIds': [requester.uid, book.ownerId],
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageText': '${requester.email} requested a swap!',
    });

    try {
      await batch.commit();
    } catch (e) {
      throw Exception('Swap request failed: $e');
    }
  }

  /// Offers I MADE (I am the requester)
  Stream<List<SwapOffer>> getOutgoingSwaps(String userId) {
    return _swapsCollection
        .where('requesterId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => SwapOffer.fromFirestore(doc)).toList());
  }

  /// Offers I RECEIVED (I am the book owner)
  Stream<List<SwapOffer>> getIncomingSwaps(String userId) {
    return _swapsCollection
        .where('bookOwnerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => SwapOffer.fromFirestore(doc)).toList());
  }

  Future<void> updateSwapStatus(
      String swapId, String bookId, SwapStatus newStatus) async {
    final batch = _firestore.batch();
    final swapRef = _swapsCollection.doc(swapId);
    batch.update(swapRef, {'status': newStatus.toString().split('.').last});

    final bookRef = _booksCollection.doc(bookId);
    if (newStatus == SwapStatus.Accepted) {
      batch.update(bookRef, {'status': 'Swapped'});
    } else if (newStatus == SwapStatus.Rejected) {
      batch.update(bookRef, {'status': 'Available'});
    }

    try {
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to update swap status: $e');
    }
  }
}