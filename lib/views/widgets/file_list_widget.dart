import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class FileListWidget extends StatelessWidget {
  final List<String> fileUrls;
  const FileListWidget({required this.fileUrls, super.key});

  @override
  Widget build(BuildContext context) {
    if (fileUrls.isEmpty) {
      return Text("No document", style: Theme.of(context).textTheme.bodySmall);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Uploaded Files:', style: Theme.of(context).textTheme.bodySmall),
        ...fileUrls.map((fileUrl) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: InkWell(
                onTap: () async {
                  final uri = Uri.parse(fileUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Text(
                  fileUrl.split('/').last,
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ))
      ],
    );
  }
}
