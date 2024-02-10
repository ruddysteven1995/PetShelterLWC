@isTest
public class AnimalShelterControllerTest {
    
    public static String IMG_URL = 'http://www.test.com.images';
    public static String API_URL = 'http://www.api.com/api';

    @TestSetup
    static void makeData(){
        String IMG_URL = 'http://www.test.com.images';
        String API_URL = 'http://www.api.com/api';

        Animal_Shelter_Settings__c record = new Animal_Shelter_Settings__c();
        record.Default_Image_Url__c = IMG_URL;
        record.Dog_Breed_API__c = API_URL;
        insert record;
    }
    
    @IsTest
    static void getAnimalsListDogsTest(){
        List<Animal__c> toAdd = new List<Animal__c>();
        for (Integer i = 0; i < 10; I++) {
            Animal__c record = new Animal__c();
            record.Name__c = 'Animal Name ' + i;
            record.Status__c = 'Created';
            record.Sex__c = 'Male';
            record.Type__c = 'Dog';
            toAdd.add(record);
        }
        insert toAdd;
        
        Test.startTest();
        List<Animal__c> result = AnimalShelterController.getAnimalsList();
        Test.stopTest();

        Assert.areEqual(toAdd.size(), result.size(), 'Both lists should be equal in size');
    }

    @IsTest
    static void getAnimalsListCatsTest(){
        List<Animal__c> toAdd = new List<Animal__c>();
        for (Integer i = 0; i < 10; I++) {
            Animal__c record = new Animal__c();
            record.Name__c = 'Animal Name ' + i;
            record.Status__c = 'Created';
            record.Sex__c = 'Male';
            record.Type__c = 'Cat';
            record.Breed__c = 'Persian';
            toAdd.add(record);
        }
        insert toAdd;
        
        Test.startTest();
        List<Animal__c> result = AnimalShelterController.getAnimalsList();
        Test.stopTest();

        String imgURL = 'http://www.test.com.images';
        String apiURL = 'http://www.api.com/api';

        Assert.areEqual(toAdd.size(), result.size(), 'Both lists should be equal in size');
        for (Integer i = 0; i < 10; I++) {
            Assert.areEqual(IMG_URL, result.get(i).Photo_URL__c, 'The photo url should be the same for both');
        }
    }

    @IsTest
    static void getCustomSettingsTest(){
        String imgURL = 'http://www.test.com.images';
        String apiURL = 'http://www.api.com/api';

        Test.startTest();
        Animal_Shelter_Settings__c result = AnimalShelterController.getCustomSettings();
        Test.stopTest();

        Animal_Shelter_Settings__c toTest = Animal_Shelter_Settings__c.getOrgDefaults();

        Assert.areEqual(imgURL, result.Default_Image_Url__c, 'The values should be same');
        Assert.areEqual(apiURL, result.Dog_Breed_API__c, 'The values should be same');
    }

    @IsTest
    static void getDogBreedListTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpForDogBreedsList());
        List<AnimalShelterController.breedsPicklist> result = AnimalShelterController.getDogBreedList();
        Test.stopTest();
        
        Assert.areEqual(6, result.size(), 'The size of the result should be 6');
    }

    @IsTest
    static void testQueueableJob(){
        List<Animal__c> toAdd = new List<Animal__c>();
        for (Integer i = 0; i < 10; I++) {
            Animal__c record = new Animal__c();
            record.Name__c = 'Animal Nam e' + i;
            record.Status__c = 'Created';
            record.Sex__c = 'Male';
            record.Type__c = 'Dog';
            record.Breed__c = 'beagle';
            toAdd.add(record);
        }
        insert toAdd;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpForDogPhotos());
        System.enqueueJob(new GetDogPhotosQueue(toAdd), 0);
        Test.stopTest();

        List<Animal__c> result = [SELECT Id, Photo_URL__c FROM Animal__c LIMIT 1];

        Assert.areEqual('https://image.com/url', result.get(0).Photo_URL__c, 'The photo url for the records should be the same');        
    }
}