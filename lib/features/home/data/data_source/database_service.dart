import 'package:intl/intl.dart' show DateFormat;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:test_geolocator_android/features/home/data/address.dart';
import 'package:test_geolocator_android/features/home/data/address_file.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'order_tracking.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      // onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE address_files(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL
      )
    ''');
    await db.execute('''
    CREATE TABLE addresses (
      id TEXT PRIMARY KEY,
      file_id INTEGER REFERENCES address_files(id) ON DELETE SET NULL,
      order_id TEXT,
      building_number TEXT,
      street TEXT,
      district TEXT,
      postal_code TEXT,
      city TEXT,
      is_done INTEGER NOT NULL DEFAULT 0 CHECK(is_done IN (0, 1)),
      region TEXT,
      country TEXT,
      full_address TEXT,
      lat REAL,
      lng REAL,
      status TEXT NOT NULL DEFAULT 'pending' CHECK(status IN ('pending', 'delivered', 'cancelled')),
      scan_timestamp INTEGER,  
      FOREIGN KEY (file_id) REFERENCES address_files (id)
    )
''');

    // إنشاء فهارس للحقول الشائعة الاستخدام
    await db.execute(
      'CREATE INDEX idx_addresses_file_id ON addresses(file_id)',
    );
    await db.execute('CREATE INDEX idx_addresses_status ON addresses(status)');
    await db.execute(
      'CREATE INDEX idx_addresses_coords ON addresses(lat, lng)',
    );
    // YLhxb-wpzxb43HoX92qfCP6
    // في ملف database_helper.dart
  }

  Future<bool> canAddFileToday() async {
    final db = await database;
    final today = DateFormat.yMMMMd('ar').format(DateTime.now());

    final result = await db.query(
      'address_files',
      where: 'name = ?',
      whereArgs: [today],
    );

    return result.isEmpty;
  }

  // Address File operations
  Future<int> createAddressFile(AddressFile file) async {
    final db = await database;
    if (!await canAddFileToday()) {
      throw Exception('❗ تم إضافة ملف اليوم مسبقاً');
    }

    return await db.insert('address_files', file.toMap());
  }

  Future<Map<String, dynamic>?> getTodayFile() async {
    final db = await this.database;
    final today = DateFormat.yMMMMd('ar').format(DateTime.now());

    final result = await db.query(
      'address_files',
      where: 'name = ?',
      whereArgs: [today],
    );

    return result.isNotEmpty ? result.first : null;
  }

  Future<List<AddressFile>> getAllAddressFiles() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'address_files',
      orderBy: 'date DESC',
    );
    return await Future.wait(
      maps.map((map) async {
        final file = AddressFile.fromMap(map);
        final addresses = await getAddressesForFile(file.id!);
        return file.copyWith(addresses: addresses);
      }),
    );
  }

  Future<AddressFile?> getAddressFile(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'address_files',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    final file = AddressFile.fromMap(maps.first);
    final addresses = await getAddressesForFile(id);
    return file.copyWith(addresses: addresses);
  }

  // Address operations
  Future<void> insertAddress(Address addresses) async {
    final db = await database;
    if (addresses.fileId == null) {
      final fileId = await getOrCreateTodayFile();
      addresses = addresses.copyWith(fileId: fileId);
    }
    await db.insert(
      'addresses',
      addresses.toMap(),
      conflictAlgorithm:
          ConflictAlgorithm.replace, // يستبدل البيانات إذا كان ID موجوداً
    );
  }

  Future<List<Address>> getAddressesForFile(int fileId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'addresses',
      where: 'file_id = ?',
      whereArgs: [fileId],
    );

    return List.generate(maps.length, (i) => Address.fromMap(maps[i]));
  }

  Future<Address?> getAddressById(String id) async {
    final db = await database;
    final maps = await db.query('addresses', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Address(
        isDone: maps.first['isDone'] == 1 ? true : false,
        fileId: maps.first['file_id'] as int,
        buildingNumber: maps.first['building_number'] as String,
        street: maps.first['street'] as String,
        district: maps.first['district'] as String,
        postalCode: maps.first['postal_code'] as String,
        city: maps.first['city'] as String,
        region: maps.first['region'] as String,
        country: maps.first['country'] as String,
        fullAddress: maps.first['full_address'] as String,
        lat: maps.first['lat'] as double,
        lng: maps.first['lng'] as double,
        status: maps.first['status'] as String,
        scanTimestamp: DateTime.fromMillisecondsSinceEpoch(
          (maps.first['scan_timestamp'] as int) * 1000,
        ),
        id: maps.first['id'] as String,
        orderId: maps.first['order_id'] as String,
      );
    }
    return null;
  }

  Future<List<Address>> getAddressesByFileId(int fileId) async {
    final db = await database;
    final maps = await db.query(
      'addresses',
      where: 'file_id = ?',
      whereArgs: [fileId],
      orderBy: 'scan_timestamp ASC',
    );

    return List.generate(maps.length, (i) {
      return Address(
        fileId: fileId,
        id: maps[i]['id'] as String,
        isDone: maps[i]['isDone'] == 1 ? true : false,
        buildingNumber: maps[i]['building_number'] as String,
        street: maps[i]['street'] as String,
        district: maps[i]['district'] as String,
        postalCode: maps[i]['postal_code'] as String,
        city: maps[i]['city'] as String,
        region: maps[i]['region'] as String,
        country: maps[i]['country'] as String,
        fullAddress: maps[i]['full_address'] as String,
        lat: maps[i]['lat'] as double,
        lng: maps[i]['lng'] as double,
        status: maps[i]['status'] as String,
        scanTimestamp: DateTime.fromMillisecondsSinceEpoch(
          (maps[i]['scan_timestamp'] as int) * 1000,
        ),

        orderId: maps[i]['order_id'] as String,
      );
    });
  }

  Future<void> deleteAddress(int id) async {
    final db = await database;
    await db.delete('addresses', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markAddressAsDone(int id) async {
    final db = await database;
    await db.update(
      'addresses',
      {'isDone': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAddressFile(int id) async {
    final db = await database;
    await db.delete('address_files', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getOrCreateTodayFile({DateTime? date}) async {
    final db = await database;

    final formattedDate = DateFormat.yMMMMd(
      'ar',
    ).format(date ?? DateTime.now());

    // التحقق من وجود ملف اليوم
    final existingFile = await db.query(
      'address_files',
      where: 'name = ?',
      whereArgs: [formattedDate],
      limit: 1,
    );

    // إذا كان الملف موجوداً، أرجع الـ ID
    if (existingFile.isNotEmpty) {
      return existingFile.first['id'] as int;
    }

    // إذا لم يكن موجوداً، أنشئ ملفاً جديداً
    final newFileId = await db.insert('address_files', <String, dynamic>{
      'name': formattedDate,
      'date': (date ?? DateTime.now()).toIso8601String().toString(),
    });

    return newFileId;
  }

  Future<void> updateAddress(Address address) async {
    final db = await database;
    await db.update(
      'addresses',
      where: 'id = ?',
      whereArgs: [address.id],
      address.toMap(),
    );
  }
}
