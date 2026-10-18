import 'package:flutter/material.dart';
import 'package:flutter_sqlite_project/database/local/db-helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    LocalDatabase db = LocalDatabase.getInstance;
    print(db);
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> data = [];
  var titlecontroller = TextEditingController();
  var contentcontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
    getdata();
  }

  void getdata() async {
    data = await LocalDatabase.getInstance.fetchData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Database Practice")),
      body: data.isNotEmpty
          ? ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Text(
                    data[index][LocalDatabase.COLUMN_NOTE_SNO].toString(),
                  ),
                  title: Text(data[index][LocalDatabase.COLUMN_NOTE_TITLE]),
                  subtitle: Text(
                    data[index][LocalDatabase.COLUMN_NOTE_CONTENT],
                  ),
                  trailing: SizedBox(
                    width: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            titlecontroller.text =
                                data[index][LocalDatabase.COLUMN_NOTE_TITLE];
                            contentcontroller.text =
                                data[index][LocalDatabase.COLUMN_NOTE_CONTENT];
                            showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              builder: (context) {
                                return getBottomStyleSheet(
                                  is_update: true,
                                  s_no:
                                      data[index][LocalDatabase
                                          .COLUMN_NOTE_SNO],
                                );
                              },
                            );
                          },
                          child: Icon(Icons.edit),
                        ), //wrap these widgets and on their tap perform desired operations
                        InkWell(
                          onTap: () async {
                            await LocalDatabase.getInstance.deletedata(
                              id: data[index][LocalDatabase.COLUMN_NOTE_SNO],
                            );
                            getdata();
                          },
                          child: Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ),
                ); //notes will be displayed
              },
            )
          : Center(child: Text("No Data")),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          titlecontroller.clear();
          contentcontroller.clear();
          await showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (context) {
              return getBottomStyleSheet(is_update: false, s_no: -1);
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget getBottomStyleSheet({bool is_update = false, int s_no = 0}) {
    return Container(
      height: 300,
      color: Colors.greenAccent,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 8.0,
            right: 8,
            top: 8,
            bottom: MediaQuery.of(context).viewInsets.bottom + 8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                is_update ? "Update Note" : "Add Note",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextField(
                controller: titlecontroller,
                decoration: InputDecoration(
                  hintText: "Title",
                  label: Text("Title"),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(width: 2, color: Colors.black),
                  ),
                ),
              ),
              SizedBox(height: 5),
              TextField(
                controller: contentcontroller,
                decoration: InputDecoration(
                  hintText: "Content",
                  label: Text("Content"),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(width: 2, color: Colors.black),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final title = titlecontroller.text.trim();
                        final content = contentcontroller.text.trim();
                        if (title.isEmpty || content.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Please fill title and content"),
                            ),
                          );
                        } else {
                          is_update
                              ? await LocalDatabase.getInstance.updatedata(
                                  id: s_no,
                                  title: titlecontroller.text,
                                  content: contentcontroller.text,
                                )
                              : await LocalDatabase.getInstance.adddata(
                                  title: titlecontroller.text,
                                  content: contentcontroller.text,
                                );
                          getdata();
                          Navigator.pop(context);
                        }
                      },
                      child: Text(is_update ? "Update" : "Add"),
                    ),
                  ),
                  SizedBox(width: 5),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Cancel"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
