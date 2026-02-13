// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'api.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: HomePage(),
//     );
//   }
// }

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   PlatformFile? pickedFile;

//   String status = "Belum ada proses";
//   bool uploading = false;
//   bool processing = false;

//   String? cmBase64; // gambar confusion matrix (base64) dari backend

//   // ================= PICK FILE =================
//   Future<void> pickFile() async {
//     final res = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['xlsx'],
//       withData: true,
//     );

//     if (res != null && res.files.isNotEmpty) {
//       setState(() {
//         pickedFile = res.files.first;
//         status = "File dipilih: ${pickedFile!.name}";
//       });
//     }
//   }

//   // ================= UPLOAD =================
//   Future<void> upload() async {
//     if (pickedFile == null) {
//       setState(() => status = "Pilih file dulu");
//       return;
//     }

//     setState(() {
//       uploading = true;
//       status = "Uploading...";
//       cmBase64 = null;
//     });

//     try {
//       final result = await Api.uploadXlsx(pickedFile!);
//       setState(() {
//         status = "Upload sukses ✅\nRows: ${result['rows']}\nColumns: ${result['columns']}";
//       });
//     } catch (e) {
//       setState(() => status = "Upload gagal ❌\n$e");
//     } finally {
//       setState(() => uploading = false);
//     }
//   }

//   // ================= PREPROCESS =================
//   Future<void> preprocess() async {
//     setState(() {
//       processing = true;
//       status = "Preprocessing...";
//       cmBase64 = null;
//     });

//     try {
//       final result = await Api.preprocess();

//       if (result["error"] != null) {
//         throw Exception(result["error"]);
//       }

//       setState(() {
//         status =
//             "Preprocess sukses ✅\nRows: ${result['rows']}\nPreview:\n${result['preview_final_text']}";
//       });
//     } catch (e) {
//       setState(() => status = "Preprocess gagal ❌\n$e");
//     } finally {
//       setState(() => processing = false);
//     }
//   }

//   // ================= LABELING =================
//   Future<void> labeling() async {
//     setState(() {
//       processing = true;
//       status = "Labeling...";
//       cmBase64 = null;
//     });

//     try {
//       final result = await Api.label();

//       if (result["error"] != null) {
//         throw Exception(result["error"]);
//       }

//       setState(() {
//         status =
//             "Labeling sukses ✅\nCounts: ${result['label_counts']}\nPreview:\n${result['preview']}";
//       });
//     } catch (e) {
//       setState(() => status = "Labeling gagal ❌\n$e");
//     } finally {
//       setState(() => processing = false);
//     }
//   }

//   // ================= TRAIN SVM =================
//   Future<void> trainSvm() async {
//     setState(() {
//       processing = true;
//       status = "Training SVM...";
//       cmBase64 = null;
//     });

//     try {
//       final result = await Api.train();

//       if (result["error"] != null) {
//         throw Exception(result["error"]);
//       }

//       final acc = result["accuracy"];
//       final report = result["classification_report"];
//       final cm = result["confusion_matrix"];
//       final cmImg = result["confusion_matrix_png_base64"];

//       setState(() {
//         cmBase64 = cmImg;
//         status =
//             "Train selesai ✅\n\nAccuracy: $acc\n\nConfusion Matrix:\n$cm\n\nClassification Report:\n$report";
//       });
//     } catch (e) {
//       setState(() => status = "Train gagal ❌\n$e");
//     } finally {
//       setState(() => processing = false);
//     }
//   }

//   // ================= UI =================
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Sentiment App")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ElevatedButton(
//               onPressed: pickFile,
//               child: const Text("Pick XLSX"),
//             ),
//             const SizedBox(height: 8),

//             ElevatedButton(
//               onPressed: uploading ? null : upload,
//               child: Text(uploading ? "Uploading..." : "Upload to Backend"),
//             ),
//             const SizedBox(height: 8),

//             ElevatedButton(
//               onPressed: processing ? null : preprocess,
//               child: Text(processing ? "Processing..." : "Preprocess"),
//             ),
//             const SizedBox(height: 8),

//             ElevatedButton(
//               onPressed: processing ? null : labeling,
//               child: Text(processing ? "Processing..." : "Labeling"),
//             ),
//             const SizedBox(height: 8),

//             ElevatedButton(
//               onPressed: processing ? null : trainSvm,
//               child: Text(processing ? "Processing..." : "Train SVM"),
//             ),

//             const SizedBox(height: 16),

//             Expanded(
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(status),
//                     const SizedBox(height: 12),
//                     if (cmBase64 != null) ...[
//                       const Text("Confusion Matrix Image:"),
//                       const SizedBox(height: 8),
//                       Image.memory(base64Decode(cmBase64!)),
//                     ]
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'api.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      home: const PipelineApp(),
    );
  }
}

class PipelineApp extends StatefulWidget {
  const PipelineApp({super.key});

  @override
  State<PipelineApp> createState() => _PipelineAppState();
}

class _PipelineAppState extends State<PipelineApp> {
  int index = 0;

  // Shared state antar page
  PlatformFile? pickedFile;

  bool uploading = false;
  bool preprocessing = false;
  bool labeling = false;
  bool training = false;

  // hasil per tahap
  String uploadStatus = "Belum upload";
  String preprocessStatus = "Belum preprocess";
  String labelStatus = "Belum labeling";
  String trainStatus = "Belum training";

  List<String> preprocessPreview = [];
  Map<String, dynamic>? labelCounts;
  List<dynamic> labelPreview = [];

  double? accuracy;
  Map<String, dynamic>? classificationReport;
  List<dynamic>? confusionMatrix;
  String? cmBase64;

  // ========================= ACTIONS =========================
  Future<void> pickXlsx() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );

    if (res != null && res.files.isNotEmpty) {
      setState(() {
        pickedFile = res.files.first;
        uploadStatus = "File dipilih: ${pickedFile!.name}";
      });
    }
  }

  Future<void> doUpload() async {
    if (pickedFile == null) {
      setState(() => uploadStatus = "Pilih file XLSX dulu");
      return;
    }

    setState(() {
      uploading = true;
      uploadStatus = "Uploading...";
      // reset tahap setelahnya biar jelas
      preprocessStatus = "Belum preprocess";
      labelStatus = "Belum labeling";
      trainStatus = "Belum training";
      preprocessPreview = [];
      labelCounts = null;
      labelPreview = [];
      accuracy = null;
      classificationReport = null;
      confusionMatrix = null;
      cmBase64 = null;
    });

    try {
      final result = await Api.uploadXlsx(pickedFile!);
      setState(() {
        uploadStatus =
            "Upload sukses ✅\nRows: ${result['rows']}\nColumns: ${result['columns']}";
      });
    } catch (e) {
      setState(() => uploadStatus = "Upload gagal ❌\n$e");
    } finally {
      setState(() => uploading = false);
    }
  }

  Future<void> doPreprocess() async {
    setState(() {
      preprocessing = true;
      preprocessStatus = "Preprocessing...";
      preprocessPreview = [];
    });

    try {
      final result = await Api.preprocess();
      if (result["error"] != null) throw Exception(result["error"]);

      setState(() {
        preprocessStatus = "Preprocess sukses ✅\nRows: ${result['rows']}";
        preprocessPreview = (result["preview_final_text"] as List)
            .map((e) => e.toString())
            .toList();
      });
    } catch (e) {
      setState(() => preprocessStatus = "Preprocess gagal ❌\n$e");
    } finally {
      setState(() => preprocessing = false);
    }
  }

  Future<void> doLabeling() async {
    setState(() {
      labeling = true;
      labelStatus = "Labeling...";
      labelCounts = null;
      labelPreview = [];
    });

    try {
      final result = await Api.label();
      if (result["error"] != null) throw Exception(result["error"]);

      setState(() {
        labelStatus = "Labeling sukses ✅";
        labelCounts = Map<String, dynamic>.from(result["label_counts"]);
        labelPreview = (result["preview"] as List);
      });
    } catch (e) {
      setState(() => labelStatus = "Labeling gagal ❌\n$e");
    } finally {
      setState(() => labeling = false);
    }
  }

  Future<void> doTrain() async {
    setState(() {
      training = true;
      trainStatus = "Training SVM...";
      accuracy = null;
      classificationReport = null;
      confusionMatrix = null;
      cmBase64 = null;
    });

    try {
      final result = await Api.train();
      if (result["error"] != null) throw Exception(result["error"]);

      setState(() {
        accuracy = (result["accuracy"] as num).toDouble();
        classificationReport = Map<String, dynamic>.from(
          result["classification_report"],
        );
        confusionMatrix = (result["confusion_matrix"] as List);
        cmBase64 = result["confusion_matrix_png_base64"] as String;
        trainStatus = "Training selesai ✅";
      });
    } catch (e) {
      setState(() => trainStatus = "Training gagal ❌\n$e");
    } finally {
      setState(() => training = false);
    }
  }

  // ========================= UI HELPERS =========================
  Widget sectionTitle(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget infoCard({
    required String title,
    required String body,
    IconData? icon,
  }) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[Icon(icon), const SizedBox(width: 8)],
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(body),
          ],
        ),
      ),
    );
  }

  Widget primaryButton({
    required String text,
    required VoidCallback? onPressed,
    required bool loading,
    IconData? icon,
  }) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon ?? Icons.play_arrow),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(loading ? "Processing..." : text),
        ),
      ),
    );
  }

  // ========================= PAGES =========================
  Widget pageUpload() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        sectionTitle("Upload Data (XLSX)", Icons.upload_file),
        const SizedBox(height: 12),

        infoCard(
          title: "File",
          icon: Icons.description,
          body: pickedFile == null
              ? "Belum ada file dipilih"
              : "${pickedFile!.name}\n${pickedFile!.size} bytes",
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: pickXlsx,
                icon: const Icon(Icons.folder_open),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text("Pick XLSX"),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: uploading ? null : doUpload,
                icon: const Icon(Icons.cloud_upload),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(uploading ? "Uploading..." : "Upload"),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),
        infoCard(title: "Status", icon: Icons.info, body: uploadStatus),

        const SizedBox(height: 18),
        const Text(
          "Catatan: setelah upload sukses, lanjut ke tab Preprocess.",
          style: TextStyle(color: Colors.black54),
        ),
      ],
    );
  }

  Widget pagePreprocess() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        sectionTitle("Preprocess", Icons.cleaning_services),
        const SizedBox(height: 12),

        primaryButton(
          text: "Jalankan Preprocess",
          loading: preprocessing,
          icon: Icons.auto_fix_high,
          onPressed: preprocessing ? null : doPreprocess,
        ),

        const SizedBox(height: 12),
        infoCard(title: "Status", icon: Icons.info, body: preprocessStatus),

        const SizedBox(height: 12),
        Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Preview final_text (5 data)",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                if (preprocessPreview.isEmpty)
                  const Text("Belum ada preview")
                else
                  ...preprocessPreview.map(
                    (t) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text("• $t"),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget pageLabeling() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        sectionTitle("Labeling (Lexicon)", Icons.label),
        const SizedBox(height: 12),

        primaryButton(
          text: "Jalankan Labeling",
          loading: labeling,
          icon: Icons.tag,
          onPressed: labeling ? null : doLabeling,
        ),

        const SizedBox(height: 12),
        infoCard(title: "Status", icon: Icons.info, body: labelStatus),

        const SizedBox(height: 12),
        Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Distribusi Label",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                if (labelCounts == null)
                  const Text("Belum ada distribusi")
                else
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _pill("negatif", labelCounts!["negatif"]),
                      _pill("netral", labelCounts!["netral"]),
                      _pill("positif", labelCounts!["positif"]),
                    ],
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),
        Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Preview Label (5 data)",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                if (labelPreview.isEmpty)
                  const Text("Belum ada preview")
                else
                  ...labelPreview.map((row) {
                    final map = Map<String, dynamic>.from(row);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Label: ${map["label"]}",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(map["final_text"].toString()),
                          const Divider(),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _pill(String name, dynamic value) {
    final v = (value == null) ? 0 : value;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.deepPurple.withOpacity(0.1),
        border: Border.all(color: Colors.deepPurple.withOpacity(0.25)),
      ),
      child: Text("$name: $v"),
    );
  }

  Widget pageTrain() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        sectionTitle("Training & Evaluasi (SVM)", Icons.model_training),
        const SizedBox(height: 12),

        primaryButton(
          text: "Train SVM",
          loading: training,
          icon: Icons.play_circle_fill,
          onPressed: training ? null : doTrain,
        ),

        const SizedBox(height: 12),
        infoCard(title: "Status", icon: Icons.info, body: trainStatus),

        const SizedBox(height: 12),
        Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Accuracy",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Text(
                  accuracy == null ? "Belum ada" : accuracy!.toStringAsFixed(4),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),
        Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Confusion Matrix Image",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                if (cmBase64 == null)
                  const Text("Belum ada gambar")
                else
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(base64Decode(cmBase64!)),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),
        infoCard(
          title: "Confusion Matrix (angka)",
          icon: Icons.grid_on,
          body: confusionMatrix == null
              ? "Belum ada"
              : confusionMatrix.toString(),
        ),

        const SizedBox(height: 12),
        Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Classification Report",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                classificationReport == null
                    ? const Text("Belum ada")
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: classificationReportTable(classificationReport!),
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget classificationReportTable(Map<String, dynamic> report) {
    final rows = report.entries
        .where(
          (e) =>
              e.key != "accuracy" &&
              e.key != "macro avg" &&
              e.key != "weighted avg",
        )
        .toList();

    return DataTable(
      columns: const [
        DataColumn(label: Text("Class")),
        DataColumn(label: Text("Precision")),
        DataColumn(label: Text("Recall")),
        DataColumn(label: Text("F1-Score")),
        DataColumn(label: Text("Support")),
      ],
      rows: rows.map((e) {
        final v = Map<String, dynamic>.from(e.value);
        return DataRow(
          cells: [
            DataCell(Text(e.key)),
            DataCell(Text(v["precision"].toStringAsFixed(3))),
            DataCell(Text(v["recall"].toStringAsFixed(3))),
            DataCell(Text(v["f1-score"].toStringAsFixed(3))),
            DataCell(Text(v["support"].toString())),
          ],
        );
      }).toList(),
    );
  }

  // ========================= MAIN BUILD =========================
  @override
  Widget build(BuildContext context) {
    final pages = [pageUpload(), pagePreprocess(), pageLabeling(), pageTrain()];

    return Scaffold(
      body: SafeArea(child: pages[index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.upload_file), label: "Upload"),
          NavigationDestination(
            icon: Icon(Icons.cleaning_services),
            label: "Preprocess",
          ),
          NavigationDestination(icon: Icon(Icons.label), label: "Labeling"),
          NavigationDestination(icon: Icon(Icons.analytics), label: "Train"),
        ],
      ),
    );
  }
}
