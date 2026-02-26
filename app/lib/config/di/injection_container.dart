import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:recipe_planner/core/database/app_database.dart';
import 'package:recipe_planner/core/network/api_client.dart';
import 'package:recipe_planner/core/network/network_info.dart';
import 'package:recipe_planner/core/sync/sync_dao.dart';
import 'package:recipe_planner/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:recipe_planner/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:recipe_planner/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:recipe_planner/features/auth/domain/repositories/auth_repository.dart';
import 'package:recipe_planner/features/auth/domain/usecases/get_current_user.dart';
import 'package:recipe_planner/features/auth/domain/usecases/login.dart';
import 'package:recipe_planner/features/auth/domain/usecases/logout.dart';
import 'package:recipe_planner/features/auth/domain/usecases/register.dart';
import 'package:recipe_planner/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:recipe_planner/features/home/data/datasources/home_local_datasource.dart';
import 'package:recipe_planner/features/home/data/datasources/home_remote_datasource.dart';
import 'package:recipe_planner/features/home/data/repositories/home_repository_impl.dart';
import 'package:recipe_planner/features/home/domain/repositories/home_repository.dart';
import 'package:recipe_planner/features/home/domain/usecases/get_next_meal_slot.dart';
import 'package:recipe_planner/features/home/domain/usecases/get_tags.dart';
import 'package:recipe_planner/features/home/domain/usecases/get_trending_recipes.dart';
import 'package:recipe_planner/features/home/domain/usecases/search_recipes.dart' as uc_search;
import 'package:recipe_planner/features/home/presentation/bloc/home_bloc.dart';
import 'package:recipe_planner/features/planner/data/datasources/planner_local_datasource.dart';
import 'package:recipe_planner/features/planner/data/datasources/planner_remote_datasource.dart';
import 'package:recipe_planner/features/planner/data/repositories/planner_repository_impl.dart';
import 'package:recipe_planner/features/planner/domain/repositories/planner_repository.dart';
import 'package:recipe_planner/features/planner/domain/usecases/add_meal_slot.dart';
import 'package:recipe_planner/features/planner/domain/usecases/create_meal_plan.dart';
import 'package:recipe_planner/features/planner/domain/usecases/get_week_meal_plans.dart';
import 'package:recipe_planner/features/planner/domain/usecases/remove_meal_slot.dart';
import 'package:recipe_planner/features/planner/domain/usecases/update_meal_slot.dart';
import 'package:recipe_planner/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:recipe_planner/features/recipe_detail/data/datasources/recipe_detail_local_datasource.dart';
import 'package:recipe_planner/features/recipe_detail/data/datasources/recipe_detail_remote_datasource.dart';
import 'package:recipe_planner/features/recipe_detail/data/repositories/recipe_detail_repository_impl.dart';
import 'package:recipe_planner/features/recipe_detail/domain/repositories/recipe_detail_repository.dart';
import 'package:recipe_planner/features/recipe_detail/domain/usecases/get_recipe_detail.dart';
import 'package:recipe_planner/features/recipe_detail/domain/usecases/save_recipe.dart';
import 'package:recipe_planner/features/recipe_detail/domain/usecases/unsave_recipe.dart';
import 'package:recipe_planner/features/recipe_detail/presentation/bloc/recipe_detail_bloc.dart';
import 'package:recipe_planner/features/grocery/data/datasources/grocery_local_datasource.dart';
import 'package:recipe_planner/features/grocery/data/datasources/grocery_remote_datasource.dart';
import 'package:recipe_planner/features/grocery/data/repositories/grocery_repository_impl.dart';
import 'package:recipe_planner/features/grocery/domain/repositories/grocery_repository.dart';
import 'package:recipe_planner/features/grocery/domain/usecases/add_manual_grocery_item.dart';
import 'package:recipe_planner/features/grocery/domain/usecases/clear_completed_items.dart';
import 'package:recipe_planner/features/grocery/domain/usecases/delete_grocery_item.dart';
import 'package:recipe_planner/features/grocery/domain/usecases/get_grocery_list.dart';
import 'package:recipe_planner/features/grocery/domain/usecases/toggle_grocery_item_check.dart';
import 'package:recipe_planner/features/grocery/presentation/bloc/grocery_bloc.dart';
import 'package:recipe_planner/features/cookbook/data/datasources/cookbook_local_datasource.dart';
import 'package:recipe_planner/features/cookbook/data/datasources/cookbook_remote_datasource.dart';
import 'package:recipe_planner/features/cookbook/data/repositories/cookbook_repository_impl.dart';
import 'package:recipe_planner/features/cookbook/domain/repositories/cookbook_repository.dart';
import 'package:recipe_planner/features/cookbook/domain/usecases/cookbook_save_recipe.dart';
import 'package:recipe_planner/features/cookbook/domain/usecases/cookbook_unsave_recipe.dart';
import 'package:recipe_planner/features/cookbook/domain/usecases/get_saved_recipes.dart';
import 'package:recipe_planner/features/cookbook/presentation/bloc/cookbook_bloc.dart';

final sl = GetIt.instance;

/// Initialize all dependency injection registrations.
Future<void> initDI() async {
  // ============================================================
  // Core
  // ============================================================

  // Database
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // Network
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectivity: sl()),
  );

  // API Client
  sl.registerLazySingleton<ApiClient>(() => ApiClient());

  // ============================================================
  // Features
  // ============================================================
  _initAuth();
  _initHome();
  _initRecipeDetail();
  _initPlanner();
  _initGrocery();
  _initCookbook();
}

/// Register Auth feature dependencies.
void _initAuth() {
  // SyncDao
  sl.registerLazySingleton<SyncDao>(() => SyncDao(sl<AppDatabase>()));

  // BLoC
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      getCurrentUser: sl(),
      login: sl(),
      register: sl(),
      logout: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => Login(sl()));
  sl.registerLazySingleton(() => Register(sl()));
  sl.registerLazySingleton(() => Logout(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      syncDao: sl(),
      apiClient: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(),
  );
}

/// Register Home feature dependencies.
void _initHome() {
  // BLoC
  sl.registerFactory<HomeBloc>(
    () => HomeBloc(
      searchRecipes: sl(),
      getTrendingRecipes: sl(),
      getTags: sl(),
      getNextMealSlot: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => uc_search.SearchRecipes(sl()));
  sl.registerLazySingleton(() => GetTrendingRecipes(sl()));
  sl.registerLazySingleton(() => GetTags(sl()));
  sl.registerLazySingleton(() => GetNextMealSlot(sl()));

  // Repository
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<HomeLocalDataSource>(
    () => HomeLocalDataSourceImpl(database: sl()),
  );
}

/// Register Recipe Detail feature dependencies.
void _initRecipeDetail() {
  // BLoC
  sl.registerFactory<RecipeDetailBloc>(
    () => RecipeDetailBloc(
      getRecipeDetail: sl(),
      saveRecipe: sl(),
      unsaveRecipe: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetRecipeDetail(sl()));
  sl.registerLazySingleton(() => SaveRecipe(sl()));
  sl.registerLazySingleton(() => UnsaveRecipe(sl()));

  // Repository
  sl.registerLazySingleton<RecipeDetailRepository>(
    () => RecipeDetailRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<RecipeDetailRemoteDataSource>(
    () => RecipeDetailRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<RecipeDetailLocalDataSource>(
    () => RecipeDetailLocalDataSourceImpl(database: sl()),
  );
}

/// Register Planner feature dependencies.
void _initPlanner() {
  // BLoC
  sl.registerFactory<PlannerBloc>(
    () => PlannerBloc(
      getWeekMealPlans: sl(),
      createMealPlan: sl(),
      addMealSlot: sl(),
      updateMealSlot: sl(),
      removeMealSlot: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetWeekMealPlans(sl()));
  sl.registerLazySingleton(() => CreateMealPlan(sl()));
  sl.registerLazySingleton(() => AddMealSlot(sl()));
  sl.registerLazySingleton(() => UpdateMealSlot(sl()));
  sl.registerLazySingleton(() => RemoveMealSlot(sl()));

  // Repository
  sl.registerLazySingleton<PlannerRepository>(
    () => PlannerRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<PlannerRemoteDataSource>(
    () => PlannerRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<PlannerLocalDataSource>(
    () => PlannerLocalDataSourceImpl(database: sl()),
  );
}

/// Register Grocery feature dependencies.
void _initGrocery() {
  // BLoC
  sl.registerFactory<GroceryBloc>(
    () => GroceryBloc(
      getGroceryList: sl(),
      addManualGroceryItem: sl(),
      toggleGroceryItemCheck: sl(),
      deleteGroceryItem: sl(),
      clearCompletedItems: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetGroceryList(sl()));
  sl.registerLazySingleton(() => AddManualGroceryItem(sl()));
  sl.registerLazySingleton(() => ToggleGroceryItemCheck(sl()));
  sl.registerLazySingleton(() => DeleteGroceryItem(sl()));
  sl.registerLazySingleton(() => ClearCompletedItems(sl()));

  // Repository
  sl.registerLazySingleton<GroceryRepository>(
    () => GroceryRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<GroceryRemoteDataSource>(
    () => GroceryRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<GroceryLocalDataSource>(
    () => GroceryLocalDataSourceImpl(database: sl()),
  );
}

/// Register Cookbook feature dependencies.
void _initCookbook() {
  // BLoC
  sl.registerFactory<CookbookBloc>(
    () => CookbookBloc(
      getSavedRecipes: sl(),
      cookbookSaveRecipe: sl(),
      cookbookUnsaveRecipe: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetSavedRecipes(sl()));
  sl.registerLazySingleton(() => CookbookSaveRecipe(sl()));
  sl.registerLazySingleton(() => CookbookUnsaveRecipe(sl()));

  // Repository
  sl.registerLazySingleton<CookbookRepository>(
    () => CookbookRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<CookbookRemoteDataSource>(
    () => CookbookRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<CookbookLocalDataSource>(
    () => CookbookLocalDataSourceImpl(database: sl()),
  );
}
