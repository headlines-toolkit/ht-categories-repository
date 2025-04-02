# HT Categories Repository

[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

A Dart package providing a repository implementation for managing news categories. This repository acts as an abstraction layer over a `HtCategoriesClient` implementation, handling data fetching, manipulation, and error translation.

## Overview

This package follows the Repository pattern, offering a clean interface for interacting with category data sources. It depends on an instance of `HtCategoriesClient` (from the `ht_categories_client` package) to perform the actual data operations.

Key features:

-   Provides methods for CRUD operations on categories (`getCategories`, `getCategory`, `createCategory`, `updateCategory`, `deleteCategory`).
-   Injectable `HtCategoriesClient` dependency for flexibility.
-   Translates client-level exceptions into specific `CategoryException` subtypes for consistent error handling in the application layer.

## Usage

```dart
import 'package:ht_categories_client/ht_categories_client.dart'; // Assuming you have a client implementation
import 'package:ht_categories_repository/ht_categories_repository.dart';

void main() async {
  // 1. Create an instance of your HtCategoriesClient implementation
  //    (e.g., HtInMemoryCategoriesClient, HtApiCategoriesClient)
  final categoriesClient = YourHtCategoriesClientImplementation();

  // 2. Create the repository instance, injecting the client
  final categoriesRepository = HtCategoriesRepository(
    categoriesClient: categoriesClient,
  );

  try {
    // 3. Use the repository methods
    print('Fetching all categories...');
    final categories = await categoriesRepository.getCategories();
    print('Found ${categories.length} categories.');

    if (categories.isNotEmpty) {
      final firstCategoryId = categories.first.id;
      print('Fetching category with ID: $firstCategoryId...');
      final category = await categoriesRepository.getCategory(firstCategoryId);
      print('Fetched category: ${category.name}');
    }

    // ... other repository operations (create, update, delete)

  } on CategoryException catch (e) {
    print('An error occurred: $e');
    // Handle specific category exceptions (GetCategoriesFailure, CategoryNotFoundFailure, etc.)
  } catch (e) {
    print('An unexpected error occurred: $e');
  }
}

// Placeholder for your actual client implementation
// You'll need to provide a concrete class that extends HtCategoriesClient
// and implements its methods based on your data source (API, local DB, etc.).
// Make sure the Category model used here matches the one defined in ht_categories_client.
class YourHtCategoriesClientImplementation extends HtCategoriesClient {
  final Map<String, Category> _categories = {
    '1': Category(id: '1', name: 'Technology'),
    '2': Category(id: '2', name: 'Sports'),
  };
  int _nextId = 3;

  @override
  Future<Category> createCategory({required String name, String? description, String? iconUrl}) async {
    await Future<void>.delayed(const Duration(milliseconds: 100)); // Simulate network delay
    final newId = _nextId.toString();
    _nextId++;
    final newCategory = Category(
      id: newId,
      name: name,
      description: description,
      iconUrl: iconUrl,
    );
    _categories[newId] = newCategory;
    return newCategory;
  }

  @override
  Future<void> deleteCategory(String id) async {
     await Future<void>.delayed(const Duration(milliseconds: 100)); // Simulate network delay
    if (!_categories.containsKey(id)) {
      throw CategoryNotFoundFailure(id, 'Not found in example client');
    }
    _categories.remove(id);
  }

  @override
  Future<List<Category>> getCategories() async {
    await Future<void>.delayed(const Duration(milliseconds: 100)); // Simulate network delay
    return _categories.values.toList();
  }

  @override
  Future<Category> getCategory(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 100)); // Simulate network delay
    final category = _categories[id];
    if (category == null) {
      throw CategoryNotFoundFailure(id, 'Not found in example client');
    }
    return category;
  }

  @override
  Future<Category> updateCategory(Category category) async {
     await Future<void>.delayed(const Duration(milliseconds: 100)); // Simulate network delay
    if (!_categories.containsKey(category.id)) {
       throw CategoryNotFoundFailure(category.id, 'Not found in example client');
    }
     _categories[category.id] = category;
    return category;
  }
}
```