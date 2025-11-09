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
    kCloudinaryUploadPreset, // Use the upload preset here
    cache: false,
  );

  // Collection reference for books
  CollectionReference<Map<String, dynamic>> get _booksCollection =>
      _firestore.collection('books');

  // Collection reference for swaps
  CollectionReference<Map<String, dynamic>> get _swapsCollection =>
      _firestore.collection('swaps');

  /// Uploads an image to Cloudinary and returns the secure URL.
  Future<String> _uploadImage(XFile image) async {
    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          image.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'book_covers', // Optional: Organize in a folder
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

  /// Deletes a book listing.
  Future<void> deleteBook(String bookId) async {
    try {
      await _booksCollection.doc(bookId).delete();
    } catch (e) {
      throw Exception('Failed to delete book: $e');
    }
  }

  /// Requests a swap for a book.
  /// This performs a batch write to update the book's status
  /// and create a new swap offer document.
  Future<void> requestSwap(Book book, User requester) async {
    if (book.id == null) {
      throw Exception('Book ID is missing.');
    }

    // 1. Create the new SwapOffer object
    final newOffer = SwapOffer(
      bookId: book.id!,
      bookTitle: book.title,
      bookOwnerId: book.ownerId,
      bookOwnerEmail: book.ownerEmail,
      requesterId: requester.uid,
      requesterEmail: requester.email!,
    );

    // 2. Create a batch write
    final batch = _firestore.batch();

    // 3. Operation 1: Update the book's status to Pending
    final bookRef = _booksCollection.doc(book.id);
    batch.update(bookRef, {'status': 'Pending'});

    // 4. Operation 2: Create the new swap offer
    final swapRef = _swapsCollection.doc(); // New empty doc
    batch.set(swapRef, newOffer.toJson());

    // 5. Commit the batch
    try {
      await batch.commit();
    } catch (e) {
      throw Exception('Swap request failed: $e');
    }
  }

  /// READ: Get swap offers *sent* by the current user
  Stream<List<SwapOffer>> getOutgoingSwaps(String userId) {
    return _swapsCollection
        .where('requesterId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => SwapOffer.fromFirestore(doc)).toList());
  }

  /// READ: Get swap offers *received* by the current user
  Stream<List<SwapOffer>> getIncomingSwaps(String userId) {
    return _swapsCollection
        .where('bookOwnerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => SwapOffer.fromFirestore(doc)).toList());
  }

  /// Updates the status of a swap offer (Accept / Reject)
  Future<void> updateSwapStatus(
      String swapId, String bookId, SwapStatus newStatus) async {
    // Create a batch write to update both the swap and the book
    final batch = _firestore.batch();

    // 1. Update the swap offer
    final swapRef = _swapsCollection.doc(swapId);
    batch.update(swapRef, {'status': newStatus.toString().split('.').last});

    // 2. Update the book's status based on the decision
    final bookRef = _booksCollection.doc(bookId);
    if (newStatus == SwapStatus.Accepted) {
      batch.update(bookRef, {'status': 'Swapped'});
    } else if (newStatus == SwapStatus.Rejected) {
      // Put the book back on the market
      batch.update(bookRef, {'status': 'Available'});
    }

    try {
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to update swap status: $e');
    }
  }
}