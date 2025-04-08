//
// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';

import 'package:ht_categories_client/ht_categories_client.dart';
import 'package:ht_shared/ht_shared.dart';

/// {@template ht_categories_repository}
/// A repository that manages category data operations by interacting
/// with an underlying [HtCategoriesClient].
///
/// This repository acts as an intermediary between the business logic layer
/// (e.g., BLoCs) and the data access layer ([HtCategoriesClient]), ensuring
/// that data operations are handled consistently and potential errors from the
/// client are translated into specific, domain-relevant [CategoryException] types.
/// {@endtemplate}
class HtCategoriesRepository {
  /// {@macro ht_categories_repository}
  ///
  /// Requires an instance of [HtCategoriesClient] to perform data operations.
  const HtCategoriesRepository({required HtCategoriesClient categoriesClient})
    : _categoriesClient = categoriesClient;

  final HtCategoriesClient _categoriesClient;

  /// Fetches a paginated list of available news categories.
  ///
  /// Delegates the call to the underlying [_categoriesClient].
  /// Optionally accepts a [limit] to control the number of categories returned
  /// per page and a [startAfterId] to fetch the next page starting after the
  /// category with the specified ID.
  ///
  /// Returns a [PaginatedResponse] containing a list of [Category] objects
  /// for the requested page, along with pagination details.
  ///
  /// Throws a [GetCategoriesFailure] if an unexpected error occurs during fetching.
  Future<PaginatedResponse<Category>> getCategories({
    int? limit,
    String? startAfterId,
  }) async {
    try {
      // Fetch categories from the client
      final categoryList = await _categoriesClient.getCategories(
        limit: limit,
        startAfterId: startAfterId,
      );

      // Determine if there are more items to fetch
      // Assumes 'hasMore' is true if the number of items returned equals the limit
      // and a limit was specified. Otherwise, assumes false.
      final hasMore = limit != null && categoryList.length == limit;

      // Determine the cursor for the next page
      // Uses the ID of the last item in the list as the cursor.
      final cursor = categoryList.isNotEmpty ? categoryList.last.id : null;

      return PaginatedResponse(
        items: categoryList,
        cursor: cursor,
        hasMore: hasMore,
      );
    } on Exception catch (e, st) {
      // Catch any generic Exception from the client that isn't already
      // a specific CategoryException subtype handled by the client itself.
      // If the client throws specific subtypes, they might be caught here
      // or rethrown depending on the client's contract. Assuming a generic
      // catch here for robustness unless the client guarantees specific types.
      throw GetCategoriesFailure(e, st);
    }
  }

  /// Fetches a single news category by its unique [id].
  ///
  /// Delegates the call to the underlying [_categoriesClient].
  ///
  /// Returns the [Category] object if found.
  ///
  /// Throws a [GetCategoryFailure] if an unexpected error occurs (other than not found).
  /// Throws a [CategoryNotFoundFailure] if no category with the given [id] exists,
  /// assuming the client throws this specific exception type.
  Future<Category> getCategory(String id) async {
    try {
      final category = await _categoriesClient.getCategory(id);
      return category;
    } on CategoryNotFoundFailure {
      // Re-throw specific known failures directly if the client throws them.
      rethrow;
    } on Exception catch (e, st) {
      // Catch any other generic Exception from the client.
      throw GetCategoryFailure(e, st);
    }
  }

  /// Creates a new news category with the provided details.
  ///
  /// Delegates the call to the underlying [_categoriesClient].
  ///
  /// Takes the required [name] and optional [description] and [iconUrl].
  /// Returns the newly created [Category] object.
  ///
  /// Throws a [CreateCategoryFailure] if an unexpected error occurs during creation.
  Future<Category> createCategory({
    required String name,
    String? description,
    String? iconUrl,
  }) async {
    try {
      final category = await _categoriesClient.createCategory(
        name: name,
        description: description,
        iconUrl: iconUrl,
      );
      return category;
    } on Exception catch (e, st) {
      // Catch any generic Exception from the client.
      throw CreateCategoryFailure(e, st);
    }
  }

  /// Updates an existing news category identified by its [Category.id].
  ///
  /// Delegates the call to the underlying [_categoriesClient].
  ///
  /// The [category] object must contain the [Category.id] to update,
  /// along with the new values for the fields to be modified.
  /// Returns the updated [Category] object.
  ///
  /// Throws an [UpdateCategoryFailure] if an unexpected error occurs during the update
  /// (other than not found).
  /// Throws a [CategoryNotFoundFailure] if no category with the given `category.id` exists,
  /// assuming the client throws this specific exception type.
  Future<Category> updateCategory(Category category) async {
    try {
      final updatedCategory = await _categoriesClient.updateCategory(category);
      return updatedCategory;
    } on CategoryNotFoundFailure {
      // Re-throw specific known failures directly if the client throws them.
      rethrow;
    } on Exception catch (e, st) {
      // Catch any other generic Exception from the client.
      throw UpdateCategoryFailure(e, st);
    }
  }

  /// Deletes a news category by its unique [id].
  ///
  /// Delegates the call to the underlying [_categoriesClient].
  ///
  /// Returns normally if the deletion is successful.
  ///
  /// Throws a [DeleteCategoryFailure] if an unexpected error occurs during deletion
  /// (other than not found).
  /// Throws a [CategoryNotFoundFailure] if no category with the given [id] exists,
  /// assuming the client throws this specific exception type.
  Future<void> deleteCategory(String id) async {
    try {
      await _categoriesClient.deleteCategory(id);
    } on CategoryNotFoundFailure {
      // Re-throw specific known failures directly if the client throws them.
      rethrow;
    } on Exception catch (e, st) {
      // Catch any other generic Exception from the client.
      throw DeleteCategoryFailure(e, st);
    }
  }
}
