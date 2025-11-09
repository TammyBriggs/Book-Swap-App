# BookSwap App 📚

A mobile marketplace for students to list textbooks and initiate swap offers.
Built with Flutter, Firebase (Auth, Firestore), and Cloudinary.

##  Features
Authentication

Secure Email/Password sign-up, login, and logout

Enforced email verification

Book Listings (CRUD)

Create: Post new books with details and a cover image (uploaded to Cloudinary)

Read: Browse all available books in a real-time feed

Update: Edit your own existing listings

Delete: Remove your listings from the marketplace

Swap System

Real-time swap requests

Accept/Reject offers with instant status updates

Books are automatically marked as “Pending” or “Swapped”

Real-time Chat

Automatic chat creation upon swap request

Live messaging between swappers

State Management

Built using Riverpod for a reactive and testable architecture

## Tech Stack

Frontend: Flutter (Dart)

Backend: Firebase (Authentication, Cloud Firestore)

Storage: Cloudinary (for image hosting)

State Management: Flutter Riverpod

Navigation: go_router

## Getting Started
Prerequisites

Flutter SDK installed

Android Studio or VS Code configured

A Firebase project

A Cloudinary account (free tier)

Installation
1. Clone the repository
   git clone https://github.com/YOUR_USERNAME/Book-Swap-App.git
   cd book_swap_app

2. Install dependencies
   flutter pub get

## Firebase Setup

Create a new Firebase project.

Enable Authentication (Email/Password).

Enable Cloud Firestore (start in Test Mode).

Run the following command and select your Firebase project:

flutterfire configure

## Cloudinary Setup

Create a free account at cloudinary.com
.

Go to Settings → Upload → Add upload preset.

Set Signing Mode to Unsigned.

Create a file named lib/secrets.dart (this file is gitignored for security):

const String kCloudinaryCloudName = 'YOUR_CLOUD_NAME';
const String kCloudinaryUploadPreset = 'YOUR_UNSIGNED_PRESET_NAME';

## Run the App
flutter run

## Project Structure

The app follows a feature-first clean architecture:

lib/
├── core/                   # Shared code (constants, widgets, router)
├── features/
│   ├── auth/               # Authentication feature
│   │   ├── application/    # Riverpod providers
│   │   ├── domain/         # User models & exceptions
│   │   ├── infrastructure/ # AuthRepository (Firebase Auth)
│   │   └── presentation/   # UI Screens (Login, Signup, Verify)
│   │
│   ├── book_listings/      # Books & Swaps feature
│   │   ├── application/    # Book & Swap providers
│   │   ├── domain/         # Book & SwapOffer models
│   │   ├── infrastructure/ # BookRepository (Firestore + Cloudinary)
│   │   └── presentation/   # UI Screens (Browse, MyListings, PostBook)
│   │
│   ├── chat/               # Chat feature
│   │   ├── application/    # Chat providers
│   │   ├── domain/         # ChatMessage & ChatMetadata models
│   │   ├── infrastructure/ # ChatRepository (Firestore)
│   │   └── presentation/   # UI Screens (ChatScreen, ChatsOverview)

## Contributing

Fork the repository

Create a new branch (feature/your-feature-name)

Commit your changes

Open a Pull Request
