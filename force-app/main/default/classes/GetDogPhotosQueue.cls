public with sharing class GetDogPhotosQueue implements Queueable, Database.AllowsCallouts {

    public static String DOG_API_URL = Animal_Shelter_Settings__c.getOrgDefaults().Dog_Breed_API__c;

    // List of Animals that should be update
    List<Animal__c> toUpdate = new List<Animal__c>();
    public GetDogPhotosQueue(List<Animal__c> toUpdate){
        this.toUpdate = toUpdate;
    }
    
    public void execute(QueueableContext context) {
        List<Animal__c> newRecordsToUpdate = new List<Animal__c>();
        Integer count = 1;
        for(Integer i = 0; i < toUpdate.size(); i++) {
            // Avoiding hitting limits
            if (count <= 99) {
                Animal__c currentRecord = toUpdate.get(i);
                String breed = (currentRecord.Breed__c.replaceAll(' ', '/')).toLowerCase();
                HTTP h = new Http();
                HTTPRequest req = new HTTPRequest();
                req.setEndpoint(DOG_API_URL + 'breed/' + breed + '/images/random');
                req.setMethod('GET');
    
                HTTPResponse res = h.send(req);
                if (res.getStatusCode() == 200) {
                    Map<String, Object> bodyResponse = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                    String message = (String)bodyResponse.get('message');
                    currentRecord.Photo_URL__c = message;
                    newRecordsToUpdate.add(currentRecord);
                } else {
                    system.debug('Error in request');
                    system.debug(res.getBody());
                }
            } else {
                break;
            }
            count++;
        }
        update newRecordsToUpdate;
        if (count > 99) {
            for(Integer i = 0; i < 99; i++) {
                toUpdate.remove(0);
            }
            System.enqueueJob(new GetDogPhotosQueue(toUpdate), 0);
        }
    }
}