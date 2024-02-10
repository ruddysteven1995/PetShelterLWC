public with sharing class AnimalShelterController {
    
    public static String DOG_API_URL = Animal_Shelter_Settings__c.getOrgDefaults().Dog_Breed_API__c;

    // Call external API and retrieve all the dogs breeds available to be shown in the user interface
    @AuraEnabled(cacheable=true)
    public static List<breedsPicklist> getDogBreedList(){
        List<breedsPicklist> result = new List<breedsPicklist>();
        try {
            HTTP h = new Http();
            HTTPRequest req = new HTTPRequest();
            req.setEndpoint(DOG_API_URL + 'breeds/list/all');
            req.setMethod('GET');

            HTTPResponse res = h.send(req);
            if (res.getStatusCode() == 200) {
                AnimalShelterController.AllBreedListResponse jsonBody = (AnimalShelterController.AllBreedListResponse)Json.deserialize(res.getBody(), AnimalShelterController.AllBreedListResponse.class);
                
                Map<String, List<String>> breeds = jsonBody.message;
                for (String key : breeds.keySet()) {
                    if (!breeds.get(key).isEmpty()) {
                        for (String breed : breeds.get(key)) {
                            breedsPicklist record = new breedsPicklist();
                            record.label = key + ' ' + breed;
                            record.value = key + ' ' + breed;
                            result.add(record);
                        }
                    } else {
                        breedsPicklist record = new breedsPicklist();
                        record.label = key;
                        record.value = key;
                        result.add(record);
                    }
                }
            }
            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // Get the animals list to display in the main page
    @AuraEnabled(cacheable=true)
    public static List<Animal__c> getAnimalsList(){
        try {
            List<Animal__c> result = [
                                        SELECT Id, Name__c, Status__c, Type__c, Age_Range__c, 
                                        Sex__c, Color__c, Size__c, Breed__c, Photo_URL__c, 
                                        (SELECT Id, Observations__c, Special_Observations__c, Presentation__c FROM Animal_Details__r)
                                        FROM Animal__c
                                        ORDER BY Createddate DESC
                                    ];
            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // Get custom settings values
    @AuraEnabled(cacheable=true)
    public static Animal_Shelter_Settings__c getCustomSettings(){
        return Animal_Shelter_Settings__c.getOrgDefaults();
    }

    // Inner class to deserialize the JSON response with all the dogs breed list
    public class AllBreedListResponse {
        public Map<String, List<String>> message;
        public String status;
    }

    // Inner class to retrieve and return picklist values
    public class breedsPicklist {
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}
    }
}