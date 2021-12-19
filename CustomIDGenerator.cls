public with sharing class CustomIDGenerator {

    private static final string chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    public static Set<String> generatedIDs = new Set<String>();

    public static List<Integer> generateSequence() {

        String randomSequence = '';
        while (randomSequence.length() < 10) {
            randomSequence += String.valueOf(
                Math.abs(Crypto.getRandomInteger())
            );
        }

        List<Integer> Id = new List<Integer>();

        try {
            for (Integer i = 0; i < 5; i++) {

                String digits;
                Integer cipher;
                Boolean isLetter = i < 2 ? true : false;

                if (isLetter) {
                    digits = randomSequence.left(2);
                    cipher = Math.mod(
                        Integer.valueOf(digits), chars.length()
                    );
                    //prevent out of bounds
                    cipher = cipher == 0 ? 26 : cipher;
                }
                else {
                    digits = randomSequence.left(1);
                    cipher = Math.mod(Integer.valueOf(digits), 10);
                }
                randomSequence = randomSequence.right(
                    randomSequence.length() - digits.length()
                );
                Id.add(cipher);
            }
        }
        catch (Exception e) {
            System.debug('ERROR FOR sequence ' + randomSequence + '\n' + e);
        }
        
        return Id;
    }

    public static Integer buildVerificationNumber(List<Integer> sequence) {

        Integer verification = 0;

        for (Integer i = 0; i < sequence.size(); i++) {
            
            Boolean isEven = Math.mod(i, 2) == 0 ? true : false;
            Integer digit = Math.mod(sequence[i], 10);

            if (!isEven) { digit *= 2;}
            verification += digit;
        }
   
        return Math.mod(verification, 10);
    }

    public static List<String> returnDuplicateIDs(List<String> IDs) {

        List<String> duplicates = new List<String>();
        
        for (Contact existingId : [SELECT ID, Name, RSD_ID__c FROM Contact WHERE RSD_ID__c IN :IDs]) {
            duplicates.add(existingId.RSD_ID__c);
        }
        
       return duplicates;
    }

    public static List<String> generateIDs(Integer numOfIdsNeeded) {

        List<String> uniqueIds = new List<String>();

        Integer neededSize = generatedIDs.size() + numOfIdsNeeded;

        while (generatedIDs.size() < neededSize) {
            
            List<Integer> sequence = generateSequence();
            Integer verifier = buildVerificationNumber(sequence);
            sequence.add(verifier);
        
            Integer index1 = sequence.remove(0);
            Integer index2 = sequence.remove(0);
            
            String char1 = chars.substring(index1 - 1, index1);
            String char2 = chars.substring(index2 - 1, index2);
            String rest = String.join(sequence, '');
            String id = char1 + char2 + rest;
        
            generatedIDs.add(id);
        }
        
        uniqueIds.addAll(generatedIDs);
        return uniqueIds;
    }


}