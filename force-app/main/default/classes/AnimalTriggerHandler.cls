public with sharing class AnimalTriggerHandler {
    
    public static void OnAfterInsert() {
        List<Animal__c> newRecords = [SELECT Id, Name__c, Type__c, Breed__c, Photo_URL__c FROM Animal__c WHERE Id IN :Trigger.New];
        
        addDogPhotos(newRecords);
        insertDetailRecords();    
    }

    // Trigger handler to call out API in order to retrieve and insert the photo url for the Animal
    private static void addDogPhotos(List<Animal__c> newRecords){
        try {
            List<Animal__c> toAddPhoto = new List<Animal__c>();
            List<Animal__c> toUpdate = new List<Animal__c>();
            for (Animal__c record : newRecords) {
                if (record.Type__c == 'Dog' && !String.isEmpty(record.Breed__c)) {
                    toAddPhoto.add(record);
                } else if (!String.isEmpty(record.Type__c)) {
                    record.Photo_URL__c = AnimalShelterController.getCustomSettings().Default_Image_Url__c;
                    toUpdate.add(record);
                }
            }
        
            if (!toUpdate.isEmpty()) {
                update toUpdate;
            }

            if (!toAddPhoto.isEmpty()) {
                System.enqueueJob(new GetDogPhotosQueue(toAddPhoto), 0);
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static void insertDetailRecords() {
        List<Animal_Detail__c> newDetailsToInsert = new List<Animal_Detail__c>();
        Set <Id> recordIds = Trigger.NewMap.keySet();
        List<Animal_Detail__c> existingDetailItems = [SELECT Id, Animal_Id__c FROM Animal_Detail__c WHERE Animal_Id__c IN :recordIds];
        
        if (!existingDetailItems.isEmpty()) {
            for (Animal_Detail__c itemRecord : existingDetailItems) {
                recordIds.remove(itemRecord.Animal_Id__c);
            }
        }
        if (existingDetailItems.isEmpty() || recordIds.size() > 0) {
            for (Id recordId : recordIds) {
                Animal_Detail__c record = new Animal_Detail__c();
                record.Animal_Id__c = recordId;
                newDetailsToInsert.add(record);
            }
        }

        if (!newDetailsToInsert.isEmpty()) {
            insert newDetailsToInsert;
        }
    }
}