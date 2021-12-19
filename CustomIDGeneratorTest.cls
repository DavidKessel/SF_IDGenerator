@isTest
public with sharing class CustomIDGeneratorTest {

    @isTest
    private static void generateSequenceTest() {
        Test.startTest();
            List<Integer> sequence1 = CustomIDGenerator.generateSequence();
            List<Integer> sequence2 = CustomIDGenerator.generateSequence();
        Test.stopTest();

        System.assertEquals(5, sequence1.size(), 'Unexpected ID length.');
        System.assertEquals(5, sequence2.size(), 'Unexpected ID length.');

        Integer seq1CharValue1 = sequence1[0];
        Integer seq1CharValue2 = sequence1[1];
        Integer seq2CharValue1 = sequence2[0];
        Integer seq2CharValue2 = sequence2[1];
  
        System.assert(
            seq1CharValue1 >= 0 && seq1CharValue2 >= 0
            && seq1CharValue1 <= 26 && seq1CharValue2 <= 26,
            'ID prefix does not represent a letter of the alphabet '
        );
        System.assert(
            seq2CharValue1 >= 0 && seq2CharValue2 >= 0
            && seq2CharValue1 <= 26 && seq2CharValue2 <= 26,
            'ID prefix does not represent a letter of the alphabet '
        );
    }
    
    @isTest
    private static void buildVerificationNumber() {

        List<Integer> sequence1 = new List<Integer> {
            11, 23, 9, 4, 0
        };
        List<Integer> sequence2 = new List<Integer> {
            5, 21, 0, 8, 2
        };

        Test.startTest();
            Integer verifier1 = CustomIDGenerator.buildVerificationNumber(sequence1);
            Integer verifier2 = CustomIDGenerator.buildVerificationNumber(sequence2);
        Test.stopTest();

        System.assertEquals(4, verifier1, 'Unexpected verifier');
        System.assertEquals(5, verifier2, 'Unexpected verifier');
    }

    @isTest
    private static void insertContactsIDTest() {

        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 200; i++) {
            contacts.add(new Contact(
                FirstName = 'Test Contact' + i,
                LastName = 'LastName'
            ));
        }

        Test.startTest();
            insert contacts;
        Test.stopTest();

        List<Contact> result = [SELECT RSD_ID__c FROM Contact WHERE LastName = 'LastName'];
        
        System.assertEquals(contacts.size(), result.size(), 'Unexpected size of Array');

        for (Contact contact : result) {
            System.assert(contact.RSD_ID__c != null, 'RSD_ID was not updated');
            System.assertEquals(6, contact.RSD_ID__c.length(), 'Unexpected ID length for ID: ' + contact.RSD_ID__c);
        }
    }

    @isTest
    public static void updateContactsTest () {

        // Create 1 new contact so that it gets the RSD_ID
        Contact contact = new Contact(
            FirstName = 'Test',
            LastName = 'LastName'
        );
        insert contact;

        // Update the contact information
        Contact existingContact = [SELECT Id, LastName, RSD_ID__c FROM Contact LIMIT 1];
        existingContact.LastName = 'LastNameUpdate';
        String oldId = existingContact.RSD_ID__c;
        
        //verify that the RSD_ID stays unchanged 
        Test.startTest();
            update existingContact;
        Test.stopTest();

        System.assertEquals(
            oldId, [SELECT RSD_ID__c FROM Contact].RSD_ID__c,
            'The RSD_ID should not be updated if it already exists'
        );
    }

    @isTest
    private static void generateIDsDuplicateTest() {

        // Insert first contact so that it gets override ID 'ZZ0008'
        Contact contact1 = new Contact(
            FirstName = 'Test',
            LastName = 'Contact1'
        );
        insert contact1;

        // Insert second contact to see if it gets different ID.
        Contact contact2 = new Contact(
            FirstName = 'Test',
            LastName = 'Contact2'
        );
        insert contact2;

        String overrideId = 'ZZ0008'; //This test ID is set in ContactController class
        List<Contact> result = [SELECT ID FROM Contact WHERE RSD_ID__c = :overrideId];
        System.assertEquals(1, result.size(), 'Unexpected number of records with RSD_ID.');
    }

    @isTest
    private static void bulkUpdateContactsTest () {

        List<Contact> contacts = new List<Contact>();

        for (Integer i = 0; i < 200; i++) {
            contacts.add(new Contact(
                FirstName = 'Test' + i,
                LastName = 'Contact'
            ));
        }

        insert contacts;

        // keep the new RSD_ID in a Map for comparison
        Map<String, Contact> ids = new Map<String, Contact>();
        for (Contact c: [SELECT RSD_ID__c FROM Contact]) {
            ids.put(c.RSD_ID__c, c);
        }

        contacts.clear();

        for (Contact c: [SELECT LastName FROM Contact]) {
            c.LastName = 'Updated Contact';
            contacts.add(c);
        }

        Test.startTest();
            update contacts;
        Test.stopTest();

        List<Contact> updatedContacts = [SELECT RSD_ID__c FROM Contact];

        System.assertEquals(200, updatedContacts.size(), 'Unexpected records size.');

        for (Contact c : updatedContacts) {
            System.assertNotEquals(null, c.RSD_ID__c, 'RSD_ID was not found on contact.');
            System.assert(ids.containsKey(c.RSD_ID__c), 'The RSD_ID has changed after the update');
        }

    }
}