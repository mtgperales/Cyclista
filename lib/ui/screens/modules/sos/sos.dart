import 'package:contacts_service/contacts_service.dart';
import 'package:cyclista/ui/screens/sign_in.dart';
import 'package:cyclista/util/state_widget.dart';
import 'package:flutter/material.dart';
import 'package:cyclista/models/state.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/cupertino.dart';
import 'contactsPage.dart';
import 'smsButton.dart';
import 'phoneButton.dart';

class SOSScreen extends StatefulWidget {
  SOSScreenState createState() => SOSScreenState();
}

class SOSScreenState extends State<SOSScreen> {
  StateModel appState;
  Iterable<Contact> _contacts;

  @override
  void initState() {
    getContacts();
    super.initState();
  }

  Future<void> getContacts() async {
    //We already have permissions for contact when we get to this page, so we
    // are now just retrieving it
    final Iterable<Contact> contacts = await ContactsService.getContacts();
    setState(() {
      _contacts = contacts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: (Text('Contacts')),
      ),
      body: _contacts != null
          //Build a list view of all contacts, displaying their avatar and
          // display name
          ? ListView.builder(
              itemCount: _contacts?.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
                Contact contact = _contacts?.elementAt(index);
                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 18),
                  leading: (contact.avatar != null && contact.avatar.isNotEmpty)
                      ? CircleAvatar(
                          backgroundImage: MemoryImage(contact.avatar),
                        )
                      : CircleAvatar(
                          child: Text(contact.initials()),
                          backgroundColor: Theme.of(context).accentColor,
                        ),
                  title: Text(contact.displayName ?? ''),
                  //This can be further expanded to showing contacts detail
                  // onPressed().
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      PhoneButton(phoneNumbers: contact.phones),
                      SmsButton(phoneNumbers: contact.phones)
                    ],
                  ),
                );
              },
            )
          : Center(child: const CircularProgressIndicator()),
    );
  }

  //Check contacts permission
  Future<PermissionStatus> _getPermission() async {
    final PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.denied) {
      final Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.contacts].request();
      return permissionStatus[Permission.contacts] ??
          PermissionStatus.undetermined;
    } else {
      return permission;
    }
  }
}
