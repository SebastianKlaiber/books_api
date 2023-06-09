import 'package:mongo_dart/mongo_dart.dart';
import '../config/config.dart';

class MongoService {
  MongoService();

  bool _initialized = false;
  Db? _database;

  bool get isInitialized => _initialized;

  Db get database {
    assert(_database == null, 'MongoDB is not initialized');
    return _database!;
  }

  Future<void> initializeMongo() async {
    print(isInitialized);
    if (!_initialized) {
      _database = await Db.create(Config.mongoDBUrl);
      _initialized = true;
    }
  }

  Future<void> open() async {
    await _database?.open();
  }

  Future<void> close() async {
    await _database?.close();
  }
}
