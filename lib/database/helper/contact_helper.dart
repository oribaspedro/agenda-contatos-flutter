import 'package:agendacontatos/database/model/contact_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ContactHelper {
  static final ContactHelper _instance = ContactHelper.internal();
  factory ContactHelper() => _instance;
  ContactHelper.internal();

  Database? _db;

  Future<Database> get db async {
    if(_db != null) {
      return _db!;
    } else {
      _db = await initDb();
      return _db!;
    }
  }

  Future<Database> initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, "contactsDB.db");

    return await openDatabase(path, version: 1,
      onCreate: (Database db, int newVersion) async {
        await db.execute(
          "CREATE TABLE $contactTable("
          "$idColumn INTEGER PRIMARY KEY, "
          "$nameColumn TEXT, "
          "$emailColumn TEXT, "
          "$phoneColumn TEXT, "
          "$imgColumn TEXT"
          ", $cepColumn TEXT, $streetColumn TEXT, $numberColumn TEXT, "
          "$complementColumn TEXT, $neighborhoodColumn TEXT, $cityColumn TEXT, $stateColumn TEXT)"
        );
      },
    );
  }

  Future<Contact> saveContact (Contact contact) async {
    Database dbContact = await db;
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }

  Future<Contact?> getContact (int id) async {
    Database dbContact = await db;
    List<Map<String, dynamic>> maps = await dbContact.query(
      contactTable,
      columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
      where: "$idColumn = ?",
      whereArgs: [id],
    );
    if(maps.isNotEmpty) {
      return Contact.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Contact>> getAllContacts() async {
    Database dbContact = await db;
    List<Map<String, dynamic>> listMap = await dbContact.query(contactTable);
    List<Contact> listContact = [];
    for(Map<String, dynamic> m in listMap) {
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

  Future<int> deleteContact(int id) async {
    Database dbContact = await db;
    return await dbContact.delete(
      contactTable,
      where: "$idColumn = ?",
      whereArgs: [id],
    );
  }

  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db;
    return await dbContact.update(
      contactTable,
      contact.toMap(),
      where: "$idColumn = ?",
      whereArgs: [contact.id],
    );
  }
}