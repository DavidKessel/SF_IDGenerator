public without sharing class ContactController {

    public static void updateWithId(List<Contact> records, Map<Id, Contact> oldRecords) {
        
        // First generate enough unique IDs for all records
        List<String> Ids = new List<String>();
        Set<String> uniqueIds = new Set<String>();

        Integer iterations = 0;
        Integer numOfIDsNeeded = records.size();

        do {
            List<String> newIds = CustomIDGenerator.generateIDs(numOfIDsNeeded);
            uniqueIds.addAll(newIds);
            
            overrideIDWhenTest(newIds, uniqueIds); // only for testing

            List<String> duplicates = CustomIDGenerator.returnDuplicateIDs(newIds);
            uniqueIds.removeAll(duplicates);

            numOfIDsNeeded = duplicates.size();
            iterations++;
        }
        while (uniqueIds.size() < records.size());

        System.debug('>>>> ContactController >>>> updateWithID >>>> TOTAL ITERATIONS: ' + iterations);
        Ids.addAll(uniqueIds); 

        for (Integer i = 0; i < records.size(); i++) { 

            Boolean isUpdate = oldRecords != null ? true : false;
            ID salesforceID = records[i].Id;
            
            if (isUpdate && oldRecords.containsKey(salesforceID)) {
                if (String.isNotBlank(oldRecords.get(salesforceID).RSD_ID__c)) {
                    records[i].RSD_ID__c = oldRecords.get(salesforceID).RSD_ID__c;
                }
            }
            else {
                records[i].RSD_ID__c = Ids[i];
            }
        }
    }


    // Method overrwrites the random Ids so that we get duplicates
    private static void overrideIDWhenTest(List<String> newIds, Set<String> uniqueIds) {
        if (Test.isRunningTest() && newIds.size() < 3) {
            System.debug('>>>> ContactController >>>> Setting ID override');
            uniqueIds.remove(newIds[0]);
            newIds[0] = 'ZZ0008';
            uniqueIds.add(newIds[0]);
        }
    }
}