//
// ignore_for_file: prefer_const_constructors, lines_longer_than_80_chars

import 'package:ht_categories_client/ht_categories_client.dart';
import 'package:ht_categories_repository/ht_categories_repository.dart';
import 'package:ht_shared/ht_shared.dart'; // Import PaginatedResponse
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Define a mock class using mocktail
class MockHtCategoriesClient extends Mock implements HtCategoriesClient {}

void main() {
  // Use group with the Type for better organization as per System Patterns
  group(HtCategoriesRepository, () {
    // Declare variables needed for tests
    late HtCategoriesClient mockCategoriesClient;
    late HtCategoriesRepository categoriesRepository;
    // Removed duplicate declaration

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
      // Define sample pagination parameters
      const limit = 10;
      const startAfterId = 'last-category-id';
      // Define sample categories
      final sampleCategories = List.generate(
        limit,
        (i) => Category(id: 'cat-$i', name: 'Category $i'),
      );
      // Expected response when limit is met
      final expectedResponseFull = PaginatedResponse<Category>(
        items: sampleCategories,
        cursor: sampleCategories.last.id, // Cursor is the last item's ID
        hasMore: true, // hasMore is true because items returned == limit
      );
      // Expected response when fewer items than limit are returned
      final sampleCategoriesPartial = sampleCategories.sublist(0, 5);
      final expectedResponsePartial = PaginatedResponse<Category>(
        items: sampleCategoriesPartial,
        cursor: sampleCategoriesPartial.last.id, // Cursor is the last item's ID
        hasMore: false, // hasMore is false because items returned < limit
      );
      // Expected response when no limit is provided
      final expectedResponseNoLimit = PaginatedResponse<Category>(
        items: sampleCategories,
        cursor: sampleCategories.last.id, // Cursor is the last item's ID
        hasMore: false, // hasMore is false because no limit was specified
      );
      // Expected response when client returns empty list
      final expectedResponseEmpty = PaginatedResponse<Category>(
        items: const [],
        cursor: null, // Cursor is null when list is empty
        hasMore: false, // hasMore is false
      );

      test(
        'delegates call to client.getCategories with limit and returns PaginatedResponse with hasMore=true and correct cursor when limit is met',
        () async {
          // Arrange: Stub the client method to return a list
          when(
            () => mockCategoriesClient.getCategories(
              limit: any(named: 'limit'),
              startAfterId: any(named: 'startAfterId'),
            ),
          ).thenAnswer((_) async => sampleCategories);

          // Act: Call the repository method
          final actualResponse = await categoriesRepository.getCategories(
            limit: limit,
            startAfterId: startAfterId,
          );

          // Assert: Verify the client method was called with correct params and result matches
          expect(actualResponse, equals(expectedResponseFull));
          verify(
            () => mockCategoriesClient.getCategories(
              limit: limit,
              startAfterId: startAfterId,
            ),
          ).called(1);
        },
      );

      test(
        'delegates call to client.getCategories with limit and returns PaginatedResponse with hasMore=false and correct cursor when fewer items than limit are returned',
        () async {
          // Arrange: Stub the client method to return a partial list
          when(
            () => mockCategoriesClient.getCategories(
              limit: any(named: 'limit'),
              startAfterId: any(named: 'startAfterId'),
            ),
          ).thenAnswer((_) async => sampleCategoriesPartial);

          // Act: Call the repository method
          final actualResponse = await categoriesRepository.getCategories(
            limit: limit, // Requesting 10
            startAfterId: startAfterId,
          );

          // Assert: Verify the client method was called and result matches partial response
          expect(actualResponse, equals(expectedResponsePartial));
          verify(
            () => mockCategoriesClient.getCategories(
              limit: limit,
              startAfterId: startAfterId,
            ),
          ).called(1);
        },
      );

      test(
        'delegates call to client.getCategories without limit and returns PaginatedResponse with hasMore=false and correct cursor',
        () async {
          // Arrange: Stub the client method to return a list
          when(
            () => mockCategoriesClient.getCategories(
              startAfterId: any(named: 'startAfterId'),
            ),
          ).thenAnswer((_) async => sampleCategories);

          // Act: Call the repository method without limit
          final actualResponse = await categoriesRepository.getCategories(
            startAfterId: startAfterId,
          );

          // Assert: Verify the client method was called and result matches no-limit response
          expect(actualResponse, equals(expectedResponseNoLimit));
          verify(
            () =>
                mockCategoriesClient.getCategories(startAfterId: startAfterId),
          ).called(1);
        },
      );

      test(
        'returns PaginatedResponse with empty list, null cursor, and hasMore=false when client returns empty list',
        () async {
          // Arrange: Stub the client method to return an empty list
          when(
            () => mockCategoriesClient.getCategories(),
          ).thenAnswer((_) async => []);

          // Act: Call the repository method
          final actualResponse = await categoriesRepository.getCategories();

          // Assert: Verify the result matches the empty response
          expect(actualResponse, equals(expectedResponseEmpty));
          verify(() => mockCategoriesClient.getCategories()).called(1);
        },
      );

      test(
        'throws GetCategoriesFailure when client throws Exception',
        () async {
          // Arrange: Stub the client method to throw a generic Exception
          final exception = Exception('Client error');
          when(
            () => mockCategoriesClient.getCategories(
              limit: any(named: 'limit'),
              startAfterId: any(named: 'startAfterId'),
            ),
          ).thenThrow(exception);

          // Act & Assert: Expect the repository to throw the specific failure
          expect(
            () => categoriesRepository.getCategories(
              limit: limit,
              startAfterId: startAfterId,
            ),
            throwsA(isA<GetCategoriesFailure>()),
          );
          verify(
            () => mockCategoriesClient.getCategories(
              limit: limit,
              startAfterId: startAfterId,
            ),
          ).called(1);
        },
      );
    });

    group('getCategory', () {
      const categoryId = 'test-id';
      // Use the actual Category type from the client package
      final dummyCategory = Category(id: categoryId, name: 'Test Category');
      // No longer need expectedResponse for PaginatedResponse

      test(
        'delegates call to client.getCategory with correct id and returns Category', // Updated description
        () async {
          // Arrange: Stub the client method to return a Category
          when(
            () => mockCategoriesClient.getCategory(any()),
          ).thenAnswer((_) async => dummyCategory);

          // Act: Call the repository method
          final actualResponse = await categoriesRepository.getCategory(
            categoryId,
          );

          // Assert: Verify the client method was called with the correct ID and result matches
          expect(
            actualResponse,
            equals(dummyCategory),
          ); // Expect Category directly
          verify(() => mockCategoriesClient.getCategory(categoryId)).called(1);
        },
      );

      test(
        'throws GetCategoryFailure when client throws generic Exception',
        () async {
          // Arrange: Stub the client method to throw a generic Exception
          final exception = Exception('Client error');
          when(
            () => mockCategoriesClient.getCategory(any()),
          ).thenThrow(exception);

          // Act & Assert: Expect the repository to throw the specific failure
          expect(
            () => categoriesRepository.getCategory(categoryId),
            throwsA(isA<GetCategoryFailure>()),
          );
          verify(() => mockCategoriesClient.getCategory(categoryId)).called(1);
        },
      );

      test(
        'rethrows CategoryNotFoundFailure when client throws CategoryNotFoundFailure',
        () async {
          // Arrange: Stub the client method to throw CategoryNotFoundFailure
          final exception = CategoryNotFoundFailure(categoryId, Error());
          when(
            () => mockCategoriesClient.getCategory(any()),
          ).thenThrow(exception);

          // Act & Assert: Expect the repository to rethrow the same failure
          expect(
            () => categoriesRepository.getCategory(categoryId),
            throwsA(isA<CategoryNotFoundFailure>()),
          );
          verify(() => mockCategoriesClient.getCategory(categoryId)).called(1);
        },
      );
    });

    group('createCategory', () {
      const name = 'New Category';
      const description = 'Description';
      const iconUrl = 'url';
      // Use the actual Category type
      final createdCategory = Category(id: 'new-id', name: name);
      // No longer need expectedResponse for PaginatedResponse

      test(
        'delegates call to client.createCategory with correct parameters and returns Category', // Updated description
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
          final actualResponse = await categoriesRepository.createCategory(
            name: name,
            description: description,
            iconUrl: iconUrl,
          );

          // Assert: Verify the client method was called with correct parameters and result matches
          expect(
            actualResponse,
            equals(createdCategory),
          ); // Expect Category directly
          verify(
            () => mockCategoriesClient.createCategory(
              name: name,
              description: description,
              iconUrl: iconUrl,
            ),
          ).called(1);
        },
      );

      test(
        'throws CreateCategoryFailure when client throws Exception',
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
        },
      );
    });

    group('updateCategory', () {
      // Use the actual Category type
      final categoryToUpdate = Category(id: 'update-id', name: 'Update Me');
      final updatedCategory = Category(id: 'update-id', name: 'Updated Name');
      // No longer need expectedResponse for PaginatedResponse

      test(
        'delegates call to client.updateCategory with correct category and returns Category', // Updated description
        () async {
          // Arrange: Stub the client method using any() for the Category object
          when(
            () => mockCategoriesClient.updateCategory(any()),
          ).thenAnswer((_) async => updatedCategory);

          // Act: Call the repository method
          final actualResponse = await categoriesRepository.updateCategory(
            categoryToUpdate,
          );

          // Assert: Verify the client method was called with the correct category and result matches
          expect(
            actualResponse,
            equals(updatedCategory),
          ); // Expect Category directly
          verify(
            () => mockCategoriesClient.updateCategory(categoryToUpdate),
          ).called(1);
        },
      );

      test(
        'throws UpdateCategoryFailure when client throws generic Exception',
        () async {
          // Arrange: Stub the client method to throw a generic Exception
          final exception = Exception('Client error');
          when(
            () => mockCategoriesClient.updateCategory(any()),
          ).thenThrow(exception);

          // Act & Assert: Expect the repository to throw the specific failure
          expect(
            () => categoriesRepository.updateCategory(categoryToUpdate),
            throwsA(isA<UpdateCategoryFailure>()),
          );
          verify(
            () => mockCategoriesClient.updateCategory(categoryToUpdate),
          ).called(1);
        },
      );

      test(
        'rethrows CategoryNotFoundFailure when client throws CategoryNotFoundFailure',
        () async {
          // Arrange: Stub the client method to throw CategoryNotFoundFailure
          final exception = CategoryNotFoundFailure(
            categoryToUpdate.id,
            Error(),
          );
          when(
            () => mockCategoriesClient.updateCategory(any()),
          ).thenThrow(exception);

          // Act & Assert: Expect the repository to rethrow the same failure
          expect(
            () => categoriesRepository.updateCategory(categoryToUpdate),
            throwsA(isA<CategoryNotFoundFailure>()),
          );
          verify(
            () => mockCategoriesClient.updateCategory(categoryToUpdate),
          ).called(1);
        },
      );
    });

    group('deleteCategory', () {
      const categoryId = 'delete-id';

      test('delegates call to client.deleteCategory with correct id', () async {
        // Arrange: Stub the client method (returns void Future)
        when(
          () => mockCategoriesClient.deleteCategory(any()),
        ).thenAnswer((_) async {}); // Use async {} for void Future

        // Act: Call the repository method
        await categoriesRepository.deleteCategory(categoryId);

        // Assert: Verify the client method was called with the correct ID
        verify(() => mockCategoriesClient.deleteCategory(categoryId)).called(1);
      });

      test(
        'throws DeleteCategoryFailure when client throws generic Exception',
        () async {
          // Arrange: Stub the client method to throw a generic Exception
          final exception = Exception('Client error');
          when(
            () => mockCategoriesClient.deleteCategory(any()),
          ).thenThrow(exception);

          // Act & Assert: Expect the repository to throw the specific failure
          expect(
            () => categoriesRepository.deleteCategory(categoryId),
            throwsA(isA<DeleteCategoryFailure>()),
          );
          verify(
            () => mockCategoriesClient.deleteCategory(categoryId),
          ).called(1);
        },
      );

      test(
        'rethrows CategoryNotFoundFailure when client throws CategoryNotFoundFailure',
        () async {
          // Arrange: Stub the client method to throw CategoryNotFoundFailure
          final exception = CategoryNotFoundFailure(categoryId, Error());
          when(
            () => mockCategoriesClient.deleteCategory(any()),
          ).thenThrow(exception);

          // Act & Assert: Expect the repository to rethrow the same failure
          expect(
            () => categoriesRepository.deleteCategory(categoryId),
            throwsA(isA<CategoryNotFoundFailure>()),
          );
          verify(
            () => mockCategoriesClient.deleteCategory(categoryId),
          ).called(1);
        },
      );
    });
  });
}
