import 'dart:async';
import 'package:ecom_task/screens/order_screen/model/order_model.dart';
import 'package:ecom_task/screens/product_view/model/product_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ProductDatabase {
  static final ProductDatabase instance = ProductDatabase._init();
  static Database? _database;

  ProductDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('products.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
  CREATE TABLE products (
    id INTEGER PRIMARY KEY,
    title TEXT,
    price REAL,
    description TEXT,
    category TEXT,
    image TEXT,
    rate REAL,
    count INTEGER,
    isLiked INTEGER DEFAULT 0,
    cartQuantity INTEGER DEFAULT 0
  )
''');


    await db.execute('''
      CREATE TABLE cart (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER,
        title TEXT,
        price REAL,
        quantity INTEGER,
        image TEXT
      )
    ''');

    await db.execute('''
CREATE TABLE orders (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  cartItems TEXT, 
  totalAmount REAL,
  cardNumber TEXT,
  cardHolder TEXT,
  dateTime TEXT
)

  ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add isLiked column if upgrading from version 1 to 2
      await db.execute('ALTER TABLE products ADD COLUMN isLiked INTEGER DEFAULT 0');

      // Create cart table on upgrade to version 2
      await db.execute('''
        CREATE TABLE cart (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          productId INTEGER,
          title TEXT,
          price REAL,
          quantity INTEGER,
          image TEXT
        )
      ''');
      await db.execute('''
    CREATE TABLE orders (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      price REAL,
      image TEXT,
      quantity INTEGER,
      totalAmount REAL,
      cardNumber TEXT,
      cardHolder TEXT,
      dateTime TEXT
    )
  ''');
    }
  }

  Future<void> insertProducts(List<ProductModel> products) async {
    final db = await instance.database;

    for (var product in products) {
      await db.insert(
        'products',
        {
          'id': product.id,
          'title': product.title,
          'price': product.price,
          'description': product.description,
          'category': product.category,
          'image': product.image,
          'rate': product.rating.rate,
          'count': product.rating.count,
          'isLiked': product.isLiked ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<ProductModel>> getAllProducts() async {
    final db = await instance.database;

    final result = await db.query('products');
    return result.map((json) {
      return ProductModel(
        id: json['id'] as int,
        title: json['title'] as String,
        price: (json['price'] as num).toDouble(),
        description: json['description'] as String,
        category: json['category'] as String,
        image: json['image'] as String,
        cartQuantity: (json['cartQuantity'] ?? 0) as int,
        rating: Rating(
          rate: (json['rate'] as num).toDouble(),
          count: json['count'] as int,
        ),
        isLiked: (json['isLiked'] ?? 0) == 1,
      );
    }).toList();
  }

  Future<void> updateProductLike(int id, bool isLiked) async {
    final db = await instance.database;

    await db.update(
      'products',
      {'isLiked': isLiked ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearProducts() async {
    final db = await instance.database;
    await db.delete('products');
  }


  Future<void> addOrUpdateCartItem(ProductModel product) async {
    final db = await instance.database;

    final existing = await db.query(
      'cart',
      where: 'productId = ?',
      whereArgs: [product.id],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      final currentQuantity = existing.first['quantity'] as int;
      await db.update(
        'cart',
        {'quantity': currentQuantity + 1},
        where: 'productId = ?',
        whereArgs: [product.id],
      );
    } else {
      await db.insert('cart', {
        'productId': product.id,
        'title': product.title,
        'price': product.price,
        'quantity': 1,
        'image': product.image,
      });
    }
  }

  Future<List<Map<String, dynamic>>> getAllCartItems() async {
    final db = await instance.database;
    return await db.query('cart');
  }

  Future<void> updateCartItemQuantity(int productId, int quantity) async {
    final db = await instance.database;

    if (quantity <= 0) {
      // Remove item if quantity zero or less
      await db.delete('cart', where: 'productId = ?', whereArgs: [productId]);
    } else {
      // Update quantity
      await db.update(
        'cart',
        {'quantity': quantity},
        where: 'productId = ?',
        whereArgs: [productId],
      );
    }
  }

  Future<void> removeCartItem(int productId) async {
    final db = await instance.database;
    await db.delete('cart', where: 'productId = ?', whereArgs: [productId]);
  }
  Future<void> addOrder(OrderModel order) async {
    final db = await instance.database;
    await db.insert('orders', order.toJson());
  }

  Future<List<OrderModel>> getAllOrders() async {
    final db = await instance.database;
    final result = await db.query('orders');
    return result.map((e) => OrderModel.fromJson(e)).toList();
  }


  Future<void> clearCart() async {
    final db = await instance.database;
    await db.delete('cart');
  }


  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
