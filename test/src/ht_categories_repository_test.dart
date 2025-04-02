//
// ignore_for_file: prefer_const_constructors, lines_longer_than_80_chars

import 'package:flutter_test/flutter_test.dart';
// Import the actual Category model and exceptions from the client package
import 'package:ht_categories_client/ht_categories_client.dart';
import 'package:ht_categories_repository/ht_categories_repository.dart';
import 'package:mocktail/mocktail.dart';

// Define a mock class using mocktail
class MockHtCategoriesClient extends Mock implements HtCategoriesClient {}

void main() {
  // Use group with the Type for better organization as per System Patterns
  group(HtCategoriesRepository, () {
    // Declare variables needed for tests
    late HtCategoriesClient mockCategoriesClient;
    late HtCategoriesRepository categoriesRepository;

    // Use setUp to initialize objects before each test
    setUp(() {
      // Register fallback values for any types used with any() or capture()
      // For Category, we need a dummy instance.
      registerFallbackValue(Category(id: 'fallback', name: 'Fallback'));

      mockCategoriesClient = MockHtCategoriesClient(); // Use mocktail mock
      categoriesRepository = HtCategoriesRepository(
        categoriesClient: mockCategoriesClient,
      );
    });

    // Use tearDown to reset mocktail after each test
    tearDown(() {
      reset(mockCategoriesClient);
    });

    test('can be instantiated', () {
      // Verify that the instance created in setUp is not null
      expect(categoriesRepository, isNotNull);
    });

    // --- Test delegation for each method ---

    group('getCategories', () {
      test('delegates call to client.getCategories and returns categories',
          () async {
        // Arrange: Stub the client method to return an empty list
        final expectedCategories = <Category>[];
        when(() => mockCategoriesClient.getCategories())
            .thenAnswer((_) async => expectedCategories);

        // Act: Call the repository method
        final actualCategories = await categoriesRepository.getCategories();

        // Assert: Verify the client method was called exactly once and result matches
        expect(actualCategories, equals(expectedCategories));
        verify(() => mockCategoriesClient.getCategories()).called(1);
      });

      test('throws GetCategoriesFailure when client throws Exception',
          () async {
        // Arrange: Stub the client method to throw a generic Exception
        final exception = Exception('Client error');
        when(() => mockCategoriesClient.getCategories()).thenThrow(exception);

        // Act & Assert: Expect the repository to throw the specific failure
        expect(
          () => categoriesRepository.getCategories(),
          throwsA(isA<GetCategoriesFailure>()),
        );
        verify(() => mockCategoriesClient.getCategories()).called(1);
      });
    });

    group('getCategory', () {
      const categoryId = 'test-id';
      // Use the actual Category type from the client package
      final dummyCategory = Category(id: categoryId, name: 'Test Category');

      test(
          'delegates call to client.getCategory with correct id and returns category',
          () async {
        // Arrange: Stub the client method
        when(() => mockCategoriesClient.getCategory(any()))
            .thenAnswer((_) async => dummyCategory);

        // Act: Call the repository method
        final actualCategory =
            await categoriesRepository.getCategory(categoryId);

        // Assert: Verify the client method was called with the correct ID and result matches
        expect(actualCategory, equals(dummyCategory));
        verify(() => mockCategoriesClient.getCategory(categoryId)).called(1);
      });

      test('throws GetCategoryFailure when client throws generic Exception',
          () async {
        // Arrange: Stub the client method to throw a generic Exception
        final exception = Exception('Client error');
        when(() => mockCategoriesClient.getCategory(any()))
            .thenThrow(exception);

        // Act & Assert: Expect the repository to throw the specific failure
        expect(
          () => categoriesRepository.getCategory(categoryId),
          throwsA(isA<GetCategoryFailure>()),
        );
        verify(() => mockCategoriesClient.getCategory(categoryId)).called(1);
      });

      test(
          'rethrows CategoryNotFoundFailure when client throws CategoryNotFoundFailure',
          () async {
        // Arrange: Stub the client method to throw CategoryNotFoundFailure
        final exception = CategoryNotFoundFailure(categoryId, Error());
        when(() => mockCategoriesClient.getCategory(any()))
            .thenThrow(exception);

        // Act & Assert: Expect the repository to rethrow the same failure
        expect(
          () => categoriesRepository.getCategory(categoryId),
          throwsA(isA<CategoryNotFoundFailure>()),
        );
        verify(() => mockCategoriesClient.getCategory(categoryId)).called(1);
      });
    });

    group('createCategory', () {
      const name = 'New Category';
      const description = 'Description';
      const iconUrl = 'url';
      // Use the actual Category type
      final createdCategory = Category(id: 'new-id', name: name);

      test(
          'delegates call to client.createCategory with correct parameters and returns category',
          () async {
        // Arrange: Stub the client method using any(named:) for named params
        when(
          () => mockCategoriesClient.createCategory(
            name: any(named: 'name'),
            description: any(named: 'description'),
            iconUrl: any(named: 'iconUrl'),
          ),
        ).thenAnswer((_) async => createdCategory);

        // Act: Call the repository method
        final actualCategory = await categoriesRepository.createCategory(
          name: name,
          description: description,
          iconUrl: iconUrl,
        );

        // Assert: Verify the client method was called with correct parameters and result matches
        expect(actualCategory, equals(createdCategory));
        verify(
          () => mockCategoriesClient.createCategory(
            name: name,
            description: description,
            iconUrl: iconUrl,
          ),
        ).called(1);
      });

      test('throws CreateCategoryFailure when client throws Exception',
          () async {
        // Arrange: Stub the client method to throw a generic Exception
        final exception = Exception('Client error');
        when(
          () => mockCategoriesClient.createCategory(
            name: any(named: 'name'),
            description: any(named: 'description'),
            iconUrl: any(named: 'iconUrl'),
          ),
        ).thenThrow(exception);

        // Act & Assert: Expect the repository to throw the specific failure
        expect(
          () => categoriesRepository.createCategory(
            name: name,
            description: description,
            iconUrl: iconUrl,
          ),
          throwsA(isA<CreateCategoryFailure>()),
        );
        // Verify with specific values or any() as appropriate
        verify(
          () => mockCategoriesClient.createCategory(
            name: name,
            description: description,
            iconUrl: iconUrl,
          ),
        ).called(1);
      });
    });

    group('updateCategory', () {
      // Use the actual Category type
      final categoryToUpdate = Category(id: 'update-id', name: 'Update Me');
      final updatedCategory = Category(id: 'update-id', name: 'Updated Name');

      test(
          'delegates call to client.updateCategory with correct category and returns updated category',
          () async {
        // Arrange: Stub the client method using any() for the Category object
        when(() => mockCategoriesClient.updateCategory(any()))
            .thenAnswer((_) async => updatedCategory);

        // Act: Call the repository method
        final actualCategory =
            await categoriesRepository.updateCategory(categoryToUpdate);

        // Assert: Verify the client method was called with the correct category and result matches
        expect(actualCategory, equals(updatedCategory));
        verify(() => mockCategoriesClient.updateCategory(categoryToUpdate))
            .called(1);
      });

      test('throws UpdateCategoryFailure when client throws generic Exception',
          () async {
        // Arrange: Stub the client method to throw a generic Exception
        final exception = Exception('Client error');
        when(() => mockCategoriesClient.updateCategory(any()))
            .thenThrow(exception);

        // Act & Assert: Expect the repository to throw the specific failure
        expect(
          () => categoriesRepository.updateCategory(categoryToUpdate),
          throwsA(isA<UpdateCategoryFailure>()),
        );
        verify(() => mockCategoriesClient.updateCategory(categoryToUpdate))
            .called(1);
      });

      test(
          'rethrows CategoryNotFoundFailure when client throws CategoryNotFoundFailure',
          () async {
        // Arrange: Stub the client method to throw CategoryNotFoundFailure
        final exception = CategoryNotFoundFailure(categoryToUpdate.id, Error());
        when(() => mockCategoriesClient.updateCategory(any()))
            .thenThrow(exception);

        // Act & Assert: Expect the repository to rethrow the same failure
        expect(
          () => categoriesRepository.updateCategory(categoryToUpdate),
          throwsA(isA<CategoryNotFoundFailure>()),
        );
        verify(() => mockCategoriesClient.updateCategory(categoryToUpdate))
            .called(1);
      });
    });

    group('deleteCategory', () {
      const categoryId = 'delete-id';

      test('delegates call to client.deleteCategory with correct id', () async {
        // Arrange: Stub the client method (returns void Future)
        when(() => mockCategoriesClient.deleteCategory(any()))
            .thenAnswer((_) async {}); // Use async {} for void Future

        // Act: Call the repository method
        await categoriesRepository.deleteCategory(categoryId);

        // Assert: Verify the client method was called with the correct ID
        verify(() => mockCategoriesClient.deleteCategory(categoryId)).called(1);
      });

      test('throws DeleteCategoryFailure when client throws generic Exception',
          () async {
        // Arrange: Stub the client method to throw a generic Exception
        final exception = Exception('Client error');
        when(() => mockCategoriesClient.deleteCategory(any()))
            .thenThrow(exception);

        // Act & Assert: Expect the repository to throw the specific failure
        expect(
          () => categoriesRepository.deleteCategory(categoryId),
          throwsA(isA<DeleteCategoryFailure>()),
        );
        verify(() => mockCategoriesClient.deleteCategory(categoryId)).called(1);
      });

      test(
          'rethrows CategoryNotFoundFailure when client throws CategoryNotFoundFailure',
          () async {
        // Arrange: Stub the client method to throw CategoryNotFoundFailure
        final exception = CategoryNotFoundFailure(categoryId, Error());
        when(() => mockCategoriesClient.deleteCategory(any()))
            .thenThrow(exception);

        // Act & Assert: Expect the repository to rethrow the same failure
        expect(
          () => categoriesRepository.deleteCategory(categoryId),
          throwsA(isA<CategoryNotFoundFailure>()),
        );
        verify(() => mockCategoriesClient.deleteCategory(categoryId)).called(1);
      });
    });
  });
}
