import 'package:flutter_test/flutter_test.dart';
import 'package:flauncher/database.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/flauncher_channel.dart';
import 'package:mockito/mockito.dart';
import 'package:flauncher/models/app.dart';
import 'package:flauncher/models/category.dart';
import 'package:drift/drift.dart';

import '../mocks.mocks.dart';

void main() {
  late FLauncherDatabase database;
  late MockFLauncherChannel mockChannel;
  late AppsService appsService;

  setUp(() async {
    database = FLauncherDatabase.inMemory();
    mockChannel = MockFLauncherChannel();

    // Minimal mock for getApplications to avoid crash in _refreshState
    when(mockChannel.getApplications()).thenAnswer((_) async => []);

    appsService = AppsService(mockChannel, database);
    // Wait for initialization
    while (!appsService.initialized) {
      await Future.delayed(Duration(milliseconds: 10));
    }
  });

  tearDown(() async {
    await database.close();
  });

  test('Test addAllToCategory functionality', () async {
    const int numApps = 10;
    int categoryId = await appsService.addCategory("Test Category",
        shouldNotifyListeners: false);
    Category category =
        appsService.categories.firstWhere((c) => c.id == categoryId);

    List<App> appsToAdd = List.generate(
        numApps,
        (i) => App(
              packageName: 'com.example.app$i',
              name: 'App $i',
              version: '1.0.0',
              hidden: false,
            ));

    await database.persistApps(appsToAdd.map((app) => AppsCompanion(
          packageName: Value(app.packageName),
          name: Value(app.name),
          version: Value(app.version),
        )));

    await appsService.addAllToCategory(appsToAdd, category);

    expect(category.applications.length, numApps);
    for (int i = 0; i < numApps; i++) {
      expect(appsToAdd[i].categoryOrders[category.id], i);
      expect(category.applications[i].packageName, appsToAdd[i].packageName);
    }

    final dbAppsCategories = await database.getAppsCategories();
    expect(dbAppsCategories.length, numApps);
  });

  test('refreshState repairs missing AppsCategories rows in database',
      () async {
    when(mockChannel.getApplications()).thenAnswer((_) async => [
          {
            'packageName': 'com.example.app0',
            'name': 'App 0',
            'version': '1.0.0',
            'sideloaded': false
          },
          {
            'packageName': 'com.example.app1',
            'name': 'App 1',
            'version': '1.0.0',
            'sideloaded': false
          },
        ]);
    when(mockChannel.getApplicationIcon(any))
        .thenAnswer((_) async => Uint8List(0));
    when(mockChannel.getApplicationBanner(any))
        .thenAnswer((_) async => Uint8List(0));

    await database.persistApps([
      const AppsCompanion(
        packageName: Value('com.example.app0'),
        name: Value('App 0'),
        version: Value('1.0.0'),
      ),
      const AppsCompanion(
        packageName: Value('com.example.app1'),
        name: Value('App 1'),
        version: Value('1.0.0'),
      ),
    ]);

    final tvCategoryId =
        appsService.categories.firstWhere((c) => c.name == 'TV Apps').id;
    await database.insertAppsCategories([
      AppsCategoriesCompanion.insert(
        categoryId: tvCategoryId,
        appPackageName: 'com.example.app0',
        order: 0,
      ),
      AppsCategoriesCompanion.insert(
        categoryId: tvCategoryId,
        appPackageName: 'com.example.app1',
        order: 1,
      ),
    ]);
    await appsService.refreshState();

    var tvApps = appsService.categories.firstWhere((c) => c.name == 'TV Apps');
    expect(tvApps.applications.length, 2);

    await database.deleteAppCategory(tvCategoryId, 'com.example.app1');
    await appsService.refreshState();

    final repairedCategories = await database.getAppsCategories();
    final repaired = repairedCategories
        .where((row) => row.appPackageName == 'com.example.app1')
        .toList();
    expect(repaired.length, 1);
    expect(repaired.first.order, 1);

    final refreshedTvApps =
        appsService.categories.firstWhere((c) => c.name == 'TV Apps');
    expect(refreshedTvApps.applications.length, 2);
    expect(refreshedTvApps.applications[0].packageName, 'com.example.app0');
    expect(refreshedTvApps.applications[1].packageName, 'com.example.app1');
  });

  test('Test addCategory sets correct order', () async {
    int catId1 =
        await appsService.addCategory("Cat 1", shouldNotifyListeners: false);
    int catId2 =
        await appsService.addCategory("Cat 2", shouldNotifyListeners: false);

    Category cat1 = appsService.categories.firstWhere((c) => c.id == catId1);
    Category cat2 = appsService.categories.firstWhere((c) => c.id == catId2);

    expect(cat1.order, 3);
    expect(cat2.order, 4);
  });
}
