import 'package:yamata_launcher/services/files_system_service.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

Database? db;
initDb() async {
  if (db == null) {
    DatabaseFactory dbFactory = databaseFactoryIo;
    db = await dbFactory.openDatabase(FileSystemService.databaseFilePath);
    print("Database initialized at ${FileSystemService.databaseFilePath}");
  }
}
