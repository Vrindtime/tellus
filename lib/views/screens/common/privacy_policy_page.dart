import 'package:flutter/material.dart';

class _TitleAndContent extends StatelessWidget {
  final String title;
  final String content;

  const _TitleAndContent({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge, // Use theme style
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium, // Use theme style
          ),
        ],
      ),
    );
  }
}

//Custom List Item
class _ListItem extends StatelessWidget {
  final String text;

  const _ListItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '•  ', // Bullet point
            style: TextStyle(fontSize: 16),
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium, // Use theme style
            ),
          ),
        ],
      ),
    );
  }
}

// Replace _LinkTextSpan with IconButton for links
// class _LinkTextSpan extends StatelessWidget {
//   final String text;
//   final String url;

//   const _LinkTextSpan({required this.text, required this.url});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Text(
//           text,
//           style: Theme.of(context).textTheme.bodyMedium, // Use theme style
//         ),
//         IconButton(
//           icon: const Icon(Icons.link, color: Colors.blue),
//           onPressed: () {
//             // Replace _launchURL with Navigator or URL launcher logic
//             // Example: launch(url);
//           },
//         ),
//       ],
//     );
//   }
// }

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Privacy Policy',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
        elevation: 1,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Last updated: March 25, 2025',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              Text(
                'This Privacy Policy describes Our policies and procedures on the collection, use and disclosure of Your information when You use the Service and tells You about Your privacy rights and how the law protects You.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 30),
              Text(
                'Interpretation and Definitions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              const _TitleAndContent(
                title: 'Interpretation',
                content:
                'The words of which the initial letter is capitalized have meanings defined under the following conditions. The following definitions shall have the same meaning regardless of whether they appear in singular or in plural.',
              ),
              const _TitleAndContent(
                title: 'Definitions',
                content: 'For the purposes of this Privacy Policy:',
              ),
              const SizedBox(height: 10),
              const _ListItem(
                text:
                'Account means a unique account created for You to access our Service or parts of our Service.',
              ),
              const _ListItem(
                text:
                'Affiliate means an entity that controls, is controlled by or is under common control with a party, where \"control\" means ownership of 50% or more of the shares, equity interest or other securities entitled to vote for election of directors or other managing authority.',
              ),
              const _ListItem(
                text:
                'Application refers to Tellus, the software program provided by the Company.',
              ),
              const _ListItem(
                text:
                'Company (referred to as either \"the Company\", \"We\", \"Us\" or \"Our\" in this Agreement) refers to Tellus Group, Tellus group Arafa building, first floor, Erumapetty Post Kariyannur, Thrissur Kerala, Pin:680584.',
              ),
              const _ListItem(
                text: 'Country refers to: Kerala,  India',
              ),
              const _ListItem(
                text:
                'Device means any device that can access the Service such as a computer, a cellphone or a digital tablet.',
              ),
              const _ListItem(
                text:
                'Personal Data is any information that relates to an identified or identifiable individual.',
              ),
              const _ListItem(
                text: 'Service refers to the Application.',
              ),
              const _ListItem(
                text:
                'Service Provider means any natural or legal person who processes the data on behalf of the Company. It refers to third-party companies or individuals employed by the Company to facilitate the Service, to provide the Service on behalf of the Company, to perform services related to the Service or to assist the Company in analyzing how the Service is used.',
              ),
              const _ListItem(
                text:
                'Usage Data refers to data collected automatically, either generated by the use of the Service or from the Service infrastructure itself (for example, the duration of a page visit).',
              ),
              const _ListItem(
                text:
                'You means the individual accessing or using the Service, or the company, or other legal entity on behalf of which such individual is accessing or using the Service, as applicable.',
              ),
              const SizedBox(height: 30),
              Text(
                'Collecting and Using Your Personal Data',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              _TitleAndContent(
                title: 'Types of Data Collected',
                content: '',
              ),
              const SizedBox(height: 10),
              _TitleAndContent(
                title: 'Personal Data',
                content:
                'While using Our Service, We may ask You to provide Us with certain personally identifiable information that can be used to contact or identify You. Personally identifiable information may include, but is not limited to:',
              ),
              const SizedBox(height: 10),
              const _ListItem(text: 'First name and last name'),
              const _ListItem(text: 'Phone number'),
              const _ListItem(text: 'Address, State, Province, ZIP/Postal code, City'),
              const _ListItem(text: 'Usage Data'),
              const SizedBox(height: 20),
              _TitleAndContent(
                title: 'Usage Data',
                content: 'Usage Data is collected automatically when using the Service.',
              ),
              const SizedBox(height: 10),
              Text(
                'Usage Data may include information such as Your Device\'s Internet Protocol address (e.g. IP address), browser type, browser version, the pages of our Service that You visit, the time and date of Your visit, the time spent on those pages, unique device identifiers and other diagnostic data.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Text(
                'When You access the Service by or through a mobile device, We may collect certain information automatically, including, but not limited to, the type of mobile device You use, Your mobile device unique ID, the IP address of Your mobile device, Your mobile operating system, the type of mobile Internet browser You use, unique device identifiers and other diagnostic data.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Text(
                'We may also collect information that Your browser sends whenever You visit our Service or when You access the Service by or through a mobile device.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              _TitleAndContent(
                title: 'Information Collected while Using the Application',
                content:
                'While using Our Application, in order to provide features of Our Application, We may collect, with Your prior permission:',
              ),
              const SizedBox(height: 10),
              const _ListItem(
                text: 'Pictures and other information from your Device\'s camera and photo library',
              ),
              const SizedBox(height: 20),
              Text(
                'We use this information to provide features of Our Service, to improve and customize Our Service. The information may be uploaded to the Company\'s servers and/or a Service Provider\'s server or it may be simply stored on Your device.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Text(
                'You can enable or disable access to this information at any time, through Your Device settings.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 30),
              _TitleAndContent(
                title: 'Use of Your Personal Data',
                content: 'The Company may use Personal Data for the following purposes:',
              ),
              const SizedBox(height: 10),
              const _ListItem(
                text: 'To provide and maintain our Service, including to monitor the usage of our Service.',
              ),
              const _ListItem(
                text:
                'To manage Your Account: to manage Your registration as a user of the Service. The Personal Data You provide can give You access to different functionalities of the Service that are available to You as a registered user.',
              ),
              const _ListItem(
                text:
                'For the performance of a contract: the development, compliance and undertaking of the purchase contract for the products, items or services You have purchased or of any other contract with Us through the Service.',
              ),
              const _ListItem(
                text:
                'To contact You: To contact You by email, telephone calls, SMS, or other equivalent forms of electronic communication, such as a mobile application\'s push notifications regarding updates or informative communications related to the functionalities, products or contracted services, including the security updates, when necessary or reasonable for their implementation.',
              ),
              const _ListItem(
                text:
                'To provide You with news, special offers and general information about other goods, services and events which we offer that are similar to those that you have already purchased or enquired about unless You have opted not to receive such information.',
              ),
              const _ListItem(
                text: 'To manage Your requests: To attend and manage Your requests to Us.',
              ),
              const _ListItem(
                text:
                'For business transfers: We may use Your information to evaluate or conduct a merger, divestiture, restructuring, reorganization, dissolution, or other sale or transfer of some or all of Our assets, whether as a going concern or as part of bankruptcy, liquidation, or similar proceeding, in which Personal Data held by Us about our Service users is among the assets transferred.',
              ),
              const _ListItem(
                text:
                'For other purposes: We may use Your information for other purposes, such as data analysis, identifying usage trends, determining the effectiveness of our promotional campaigns and to evaluate and improve our Service, products, services, marketing and your experience.',
              ),
              const SizedBox(height: 20),
              Text(
                'We may share Your personal information in the following situations:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 10),
              const _ListItem(
                text:
                'With Service Providers: We may share Your personal information with Service Providers to monitor and analyze the use of our Service,  to contact You.',
              ),
              const _ListItem(
                text:
                'For business transfers: We may share or transfer Your personal information in connection with, or during negotiations of, any merger, sale of Company assets, financing, or acquisition of all or a portion of Our business to another company.',
              ),
              const _ListItem(
                text:
                'With Affiliates: We may share Your information with Our affiliates, in which case we will require those affiliates to honor this Privacy Policy. Affiliates include Our parent company and any other subsidiaries, joint venture partners or other companies that We control or that are under common control with Us.',
              ),
              const _ListItem(
                text:
                'With business partners: We may share Your information with Our business partners to offer You certain products, services or promotions.',
              ),
              const _ListItem(
                text:
                'With other users: when You share personal information or otherwise interact in the public areas with other users, such information may be viewed by all users and may be publicly distributed outside.',
              ),
              const _ListItem(
                text: 'With Your consent: We may disclose Your personal information for any other purpose with Your consent.',
              ),
              const SizedBox(height: 30),
              _TitleAndContent(
                title: 'Retention of Your Personal Data',
                content:
                'The Company will retain Your Personal Data only for as long as is necessary for the purposes set out in this Privacy Policy. We will retain and use Your Personal Data to the extent necessary to comply with our legal obligations (for example, if we are required to retain your data to comply with applicable laws), resolve disputes, and enforce our legal agreements and policies.',
              ),
              const SizedBox(height: 20),
              Text(
                'The Company will also retain Usage Data for internal analysis purposes. Usage Data is generally retained for a shorter period of time, except when this data is used to strengthen the security or to improve the functionality of Our Service, or We are legally obligated to retain this data for longer time periods.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 30),
              _TitleAndContent(
                title: 'Transfer of Your Personal Data',
                content:
                'Your information, including Personal Data, is processed at the Company\'s operating offices and in any other places where the parties involved in the processing are located. It means that this information may be transferred to — and maintained on — computers located outside of Your state, province, country or other governmental jurisdiction where the data protection laws may differ than those from Your jurisdiction.',
              ),
              const SizedBox(height: 20),
              Text(
                'Your consent to this Privacy Policy followed by Your submission of such information represents Your agreement to that transfer.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Text(
                'The Company will take all steps reasonably necessary to ensure that Your data is treated securely and in accordance with this Privacy Policy and no transfer of Your Personal Data will take place to an organization or a country unless there are adequate controls in place including the security of Your data and other personal information.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 30),
              _TitleAndContent(
                title: 'Delete Your Personal Data',
                content:
                'You have the right to delete or request that We assist in deleting the Personal Data that We have collected about You.',
              ),
              const SizedBox(height: 20),
              Text(
                'Our Service may give You the ability to delete certain information about You from within the Service.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Text(
                'You may update, amend, or delete Your information at any time by signing in to Your Account, if you have one, and visiting the account settings section that allows you to manage Your personal information. You may also contact Us to request access to, correct, or delete any personal information that You have provided to Us.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Text(
                'Please note, however, that We may need to retain certain information when we have a legal obligation or lawful basis to do so.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 30),
              _TitleAndContent(
                title: 'Disclosure of Your Personal Data',
                content: '',
              ),
              const SizedBox(height: 20),
              _TitleAndContent(
                title: 'Business Transactions',
                content:
                'If the Company is involved in a merger, acquisition or asset sale, Your Personal Data may be transferred. We will provide notice before Your Personal Data is transferred and becomes subject to a different Privacy Policy.',
              ),
              const SizedBox(height: 20),
              _TitleAndContent(
                title: 'Law enforcement',
                content:
                'Under certain circumstances, the Company may be required to disclose Your Personal Data if required to do so by law or in response to valid requests by public authorities (e.g. a court or a government agency).',
              ),
              const SizedBox(height: 20),
              _TitleAndContent(
                title: 'Other legal requirements',
                content:
                'The Company may disclose Your Personal Data in the good faith belief that such action is necessary to:',
              ),
              const SizedBox(height: 10),
              const _ListItem(text: 'Comply with a legal obligation'),
              const _ListItem(text: 'Protect and defend the rights or property of the Company'),
              const _ListItem(text: 'Prevent or investigate possible wrongdoing in connection with the Service'),
              const _ListItem(
                text: 'Protect the personal safety of Users of the Service or the public',
              ),
              const _ListItem(text: 'Protect against legal liability'),
              const SizedBox(height: 30),
              _TitleAndContent(
                title: 'Security of Your Personal Data',
                content:
                'The security of Your Personal Data is important to Us, but remember that no method of transmission over the Internet, or method of electronic storage is 100% secure. While We strive to use commercially acceptable means to protect Your Personal Data, We cannot guarantee its absolute security.',
              ),
              const SizedBox(height: 30),
              _TitleAndContent(
                title: 'Children\'s Privacy',
                content:
                'Our Service does not address anyone under the age of 13. We do not knowingly collect personally identifiable information from anyone under the age of 13. If You are a parent or guardian and You are aware that Your child has provided Us with Personal Data, please contact Us. If We become aware that We have collected Personal Data from anyone under the age of 13 without verification of parental consent, We take steps to remove that information from Our servers.',
              ),
              const SizedBox(height: 20),
              Text(
                'If We need to rely on consent as a legal basis for processing Your information and Your country requires consent from a parent, We may require Your parent\'s consent before We collect and use that information.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 30),
              _TitleAndContent(
                title: 'Links to Other Websites',
                content:
                'Our Service may contain links to other websites that are not operated by Us. If You click on a third party link, You will be directed to that third party\'s site. We strongly advise You to review the Privacy Policy of every site You visit.',
              ),
              const SizedBox(height: 20),
              Text(
                'We have no control over and assume no responsibility for the content, privacy policies or practices of any third party sites or services.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 30),
              _TitleAndContent(
                title: 'Changes to this Privacy Policy',
                content:
                'We may update Our Privacy Policy from time to time. We will notify You of any changes by posting the new Privacy Policy on this page.',
              ),
              const SizedBox(height: 20),
              Text(
                'We will let You know via email and/or a prominent notice on Our Service, prior to the change becoming effective and update the \"Last updated\" date at the top of this Privacy Policy.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Text(
                'You are advised to review this Privacy Policy periodically for any changes. Changes to this Privacy Policy are effective when they are posted on this page.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 30),
              _TitleAndContent(
                title: 'Contact Us',
                content: 'If you have any questions about this Privacy Policy, You can contact us:',
              ),
              const SizedBox(height: 10),
              // Email and Website Links
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    const Text("•  Email: ", style: TextStyle(fontSize: 16)),
                    InkWell(
                      onTap: () {
                        // Replace _launchURL with Navigator or URL launcher logic
                        // Example: launch('mailto:info@tellusgroup.in');
                      },
                      child: Text(
                        'info@tellusgroup.in',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    const Text("•  Website: ", style: TextStyle(fontSize: 16)),
                    InkWell(
                      onTap: () {
                        // Replace _launchURL with Navigator or URL launcher logic
                        // Example: launch('https://tellusgroup.in/');
                      },
                      child: Text(
                        'https://tellusgroup.in/',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    const Text("•  Phone: ", style: TextStyle(fontSize: 16)),
                    Text(
                      '+91 9846 65 56 66',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _TitleAndContent(
                title: 'Data Uploaded to the Internet',
                content:
                    'Our Application may upload certain data to the internet to provide features of the Service. This may include, but is not limited to, user-generated content, diagnostic data, and other information necessary for the functionality of the Service. We ensure that such data is transmitted securely and is used only for the purposes described in this Privacy Policy.',
              ),
              const SizedBox(height: 20),
              Text(
                'We may use third-party services to facilitate the upload and storage of this data. These services are required to adhere to strict data protection standards to ensure the security and privacy of your information.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
