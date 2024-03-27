@isTest
public class SalesforceAPIIntegrationTest {    

    // Test success scenario
    @IsTest
    static void upsertContactTestCreateScenario(){
        
        Test.setMock(HttpCalloutMock.class, new MockHttpForSalesforceAPIIntegration(201));

        SalesforceAPIIntegration.ContactRequestObject cntReqBody = new SalesforceAPIIntegration.ContactRequestObject();
        cntReqBody.emailAddress = 'test.api@mail.com';
        cntReqBody.commerceCloudId = '000001';
        cntReqBody.phoneNumber = '+3179785475';
        cntReqBody.name = 'Test API';

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = Url.getOrgDomainUrl().toExternalForm() + '/services/apexrest/PenfieldAPI';
        req.httpMethod = 'PUT';
        req.addHeader('Content-Type', 'application/json');
        req.requestBody = Blob.valueOf(JSON.serialize(cntReqBody));
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        SalesforceAPIIntegration.upsertContact();
        Test.stopTest();

        Contact cnt = [SELECT Id, Name, Email, phone, Commerce_Cloud_Id__c, Opt_In__c FROM Contact LIMIT 1];

        Assert.areEqual(201, res.statusCode, 'The status code of the response must be 201');
        Assert.areEqual(cnt.Name, cntReqBody.name, 'Both values should be the same');
        Assert.areEqual(cnt.Email, cntReqBody.emailAddress, 'Both values should be the same');
        Assert.areEqual(cnt.phone, cntReqBody.phoneNumber, 'Both values should be the same');
        Assert.areEqual(cnt.Commerce_Cloud_Id__c, cntReqBody.commerceCloudId, 'Both values should be the same');
        Assert.areEqual(cnt.Opt_In__c, true, 'Both values should be the same');
    }

    // Test success scenario but with a different User profile 
    @IsTest
    static void upsertContactTestUpdateScenario(){
        
        Test.setMock(HttpCalloutMock.class, new MockHttpForSalesforceAPIIntegration(201));

        Profile p = [SELECT Id FROM Profile WHERE Name='Minimum Access - Salesforce']; 
        User u = new User(Alias = 'minstd', Email='minstduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing Min', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='minstduser@testorg.com');
        insert u;
            
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Penfield_API_Integration'];

            insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
        System.runAs(u) {
            Contact firstContact = new Contact();
            firstContact.Email = 'test.api@mail.com'; 
            firstContact.Commerce_Cloud_Id__c = '000001';
            firstContact.Phone = '+31612345678';
            firstContact.LastName = 'Test API';
            insert firstContact;
    
            SalesforceAPIIntegration.ContactRequestObject cntReqBody = new SalesforceAPIIntegration.ContactRequestObject();
            cntReqBody.emailAddress = 'test.api+150@mail.com';
            cntReqBody.commerceCloudId = '000001';
            cntReqBody.phoneNumber = '+31600000000';
            cntReqBody.name = 'Test API';
    
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = Url.getOrgDomainUrl().toExternalForm() + '/services/apexrest/PenfieldAPI';
            req.httpMethod = 'PUT';
            req.addHeader('Content-Type', 'application/json');
            req.requestBody = Blob.valueOf(JSON.serialize(cntReqBody));
            RestContext.request = req;
            RestContext.response = res;
    
            Test.startTest();
            SalesforceAPIIntegration.upsertContact();
            Test.stopTest();
    
            Contact cnt = [SELECT Id, Name, Email, phone, Commerce_Cloud_Id__c, Opt_In__c FROM Contact LIMIT 1];
    
            Assert.areEqual(201, res.statusCode, 'The status code of the response must be 201');
            Assert.areEqual(cnt.Name, cntReqBody.name, 'Both values should be the same');
            Assert.areEqual(cnt.Email, cntReqBody.emailAddress, 'Both values should be the same');
            Assert.areEqual(cnt.phone, cntReqBody.phoneNumber, 'Both values should be the same');
            Assert.areEqual(cnt.Commerce_Cloud_Id__c, cntReqBody.commerceCloudId, 'Both values should be the same');
            Assert.areEqual(cnt.Opt_In__c, true, 'Both values should be the same');
        }
    }

    // Test failed scenario when a contact with the same Commerce Cloud Id exists before sending the request
    @IsTest
    static void upsertContactTestNegativeScenario(){
        Test.setMock(HttpCalloutMock.class, new MockHttpForSalesforceAPIIntegration(500));
        Profile p = [SELECT Id FROM Profile WHERE Name='Minimum Access - Salesforce']; 
        User u = new User(Alias = 'minstd', Email='minstduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing Min', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='minstduser@testorg.com');
        insert u;

        System.runAs(u) {

            Contact firstContact = new Contact();
            firstContact.Email = 'test.api@mail.com'; 
            firstContact.Commerce_Cloud_Id__c = '000001';
            firstContact.Phone = '+31612345678';
            firstContact.LastName = 'Test API';
            insert firstContact;
    
            SalesforceAPIIntegration.ContactRequestObject cntReqBody = new SalesforceAPIIntegration.ContactRequestObject();
            cntReqBody.emailAddress = 'test.api+150@mail.com';
            cntReqBody.commerceCloudId = '000001';
            cntReqBody.phoneNumber = '+31600000000';
            cntReqBody.name = 'Test API';
    
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = Url.getOrgDomainUrl().toExternalForm() + '/services/apexrest/PenfieldAPI';
            req.httpMethod = 'PUT';
            req.addHeader('Content-Type', 'application/json');
            req.requestBody = Blob.valueOf(JSON.serialize(cntReqBody));
            RestContext.request = req;
            RestContext.response = res;
    
            Test.startTest();
            SalesforceAPIIntegration.upsertContact();
            Test.stopTest();
    
            Contact cnt = [SELECT Id, Name, Email, phone, Commerce_Cloud_Id__c, Opt_In__c FROM Contact LIMIT 1];
    
            Assert.areEqual(500, res.statusCode, 'The status code of the response must be 500');
            Assert.areEqual(cnt.Email, firstContact.Email, 'Both values should be the same');
            Assert.areEqual(cnt.phone, firstContact.Phone, 'Both values should be the same');
            Assert.areEqual(cnt.Opt_In__c, false, 'Both values should be the same');
        }
    }

    // Test failed scenario when Commerce Cloud Id is not sent on the request
    @IsTest
    static void upsertContactTestNegativeScenario2(){
        Test.setMock(HttpCalloutMock.class, new MockHttpForSalesforceAPIIntegration(400));

        SalesforceAPIIntegration.ContactRequestObject cntReqBody = new SalesforceAPIIntegration.ContactRequestObject();
        cntReqBody.emailAddress = 'test.api@mail.com';
        cntReqBody.phoneNumber = '+31600000000';
        cntReqBody.name = 'Test API';

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = Url.getOrgDomainUrl().toExternalForm() + '/services/apexrest/PenfieldAPI';
        req.httpMethod = 'PUT';
        req.addHeader('Content-Type', 'application/json');
        req.requestBody = Blob.valueOf(JSON.serialize(cntReqBody));
        RestContext.request = req;
        RestContext.response = res;

        try {
            Test.startTest();
            SalesforceAPIIntegration.upsertContact();
            Test.stopTest();
        } catch (Exception e) {
            Assert.areEqual(400, res.statusCode, 'The status code of the response must be 400');
        }
    }

    // Test success scenario
    @IsTest
    static void insertOrderAndOrderLineItemsTestPositive(){

        Test.setMock(HttpCalloutMock.class, new MockHttpForSalesforceAPIIntegration(200));
        Integer lineItemsAmount = 500;
        Decimal totalAmounCounter = 0;
        // Creating Order line items
        List<SalesforceAPIIntegration.OrderLineItemRequestObject> lineItemsReqBody = new List<SalesforceAPIIntegration.OrderLineItemRequestObject>();
        for  (Integer i = 1; i <= lineItemsAmount ; i++) {
            SalesforceAPIIntegration.OrderLineItemRequestObject lineItem = new SalesforceAPIIntegration.OrderLineItemRequestObject();
            lineItem.productName = 'Product ' + i;
            lineItem.productSize = 'Medium';
            lineItem.productColor = 'Yellow';
            lineItem.productPrice = 10 * i;
            totalAmounCounter += lineItem.productPrice;
            lineItemsReqBody.add(lineItem);
        }

        // Creatig Order
        SalesforceAPIIntegration.OrderAndLineItemsRequestObject reqBody = new SalesforceAPIIntegration.OrderAndLineItemsRequestObject();
        SalesforceAPIIntegration.OrderRequestObject orderReqBody = new SalesforceAPIIntegration.OrderRequestObject();
        orderReqBody.commerceCloudId = '00001';
        orderReqBody.shipmentDate = Date.newInstance(2024, 04, 10);
        orderReqBody.orderDate = Date.today();
        orderReqBody.lineItems = lineItemsReqBody;

        reqBody.order = orderReqBody;

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = Url.getOrgDomainUrl().toExternalForm() + '/services/apexrest/PenfieldAPI';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        req.requestBody = Blob.valueOf(JSON.serialize(reqBody));
        RestContext.request = req;
        RestContext.response = res;
    
        Test.startTest();
        SalesforceAPIIntegration.insertOrderAndOrderLineItems();
        Test.stopTest();
        
        Order_Request__c order = [SELECT Id, Commerce_Cloud_Id__c, Shipment_Date__c, Order_Date__c, Total_Amount__c FROM Order_Request__c LIMIT 1];
    
        Assert.areEqual(200, res.statusCode, 'The status code of the response must be 200');
        Assert.areEqual(orderReqBody.commerceCloudId, order.Commerce_Cloud_Id__c, 'Both values should be the same');
        Assert.areEqual(orderReqBody.shipmentDate, order.Shipment_Date__c, 'Both values should be the same');
        Assert.areEqual(orderReqBody.orderDate, order.Order_Date__c, 'Both values should be the same');
        Assert.areEqual(lineItemsAmount, orderReqBody.lineItems.size(), 'Both values should be the same');
        Assert.areEqual(totalAmounCounter, order.Total_Amount__c, 'Both values should be the same');

        List<Order_Line_Item__c> lineItemsSOQL = [SELECT Id, Name, Product_Size__c, Product_Color__c, Product_Price__c FROM Order_Line_Item__c];

        for  (Integer i = 0; i < orderReqBody.lineItems.size() ; i++) {
            for (Integer j = 0; j < lineItemsSOQL.size() ; j++) {
                if (orderReqBody.lineItems[i].productName == lineItemsSOQL[j].Name) {
                    Assert.areEqual(orderReqBody.lineItems[i].productSize, lineItemsSOQL[j].Product_Size__c, 'Both values should be the same');
                    Assert.areEqual(orderReqBody.lineItems[i].productColor, lineItemsSOQL[j].Product_Color__c, 'Both values should be the same');
                    Assert.areEqual(orderReqBody.lineItems[i].productPrice, lineItemsSOQL[j].Product_Price__c, 'Both values should be the same');
                }
            }
        }
    }

    // Test failed scenario when a User profile has no access to the ORder Request Object
    @IsTest
    static void insertOrderAndOrderLineItemsTestNegative1(){

        Test.setMock(HttpCalloutMock.class, new MockHttpForSalesforceAPIIntegration(500));

        Profile p = [SELECT Id FROM Profile WHERE Name='Minimum Access - Salesforce']; 
        User u = new User(Alias = 'minstd', Email='minstduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing Min', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='minstduser@testorg.com');
        insert u;

        System.runAs(u) {
            Decimal totalAmounCounter = 0;
    
            // Creatig Order
            SalesforceAPIIntegration.OrderAndLineItemsRequestObject reqBody = new SalesforceAPIIntegration.OrderAndLineItemsRequestObject();
            SalesforceAPIIntegration.OrderRequestObject orderReqBody = new SalesforceAPIIntegration.OrderRequestObject();
            orderReqBody.commerceCloudId = '00001';
            orderReqBody.shipmentDate = Date.newInstance(2024, 04, 10);
            orderReqBody.orderDate = Date.today();
            orderReqBody.lineItems = null;

            reqBody.order = orderReqBody;
    
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = Url.getOrgDomainUrl().toExternalForm() + '/services/apexrest/PenfieldAPI';
            req.httpMethod = 'POST';
            req.addHeader('Content-Type', 'application/json');
            req.requestBody = Blob.valueOf(JSON.serialize(reqBody));
            RestContext.request = req;
            RestContext.response = res;
        
            Test.startTest();
            SalesforceAPIIntegration.insertOrderAndOrderLineItems();
            Test.stopTest();
            
            Assert.areEqual(500, res.statusCode, 'The status code of the response must be 500');
        }
    }  

    // Test failed scenario when the contactId field is from a non existing contact
    @IsTest
    static void insertOrderAndOrderLineItemsTestNegative2(){

        Test.setMock(HttpCalloutMock.class, new MockHttpForSalesforceAPIIntegration(400));

        // Creatig Order
        SalesforceAPIIntegration.OrderAndLineItemsRequestObject reqBody = new SalesforceAPIIntegration.OrderAndLineItemsRequestObject();
        SalesforceAPIIntegration.OrderRequestObject orderReqBody = new SalesforceAPIIntegration.OrderRequestObject();
        orderReqBody.commerceCloudId = '00001';
        orderReqBody.shipmentDate = Date.newInstance(2024, 04, 10);
        orderReqBody.orderDate = Date.today();
        orderReqBody.lineItems = null;
        orderReqBody.contactId = '000001';

        reqBody.order = orderReqBody;

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = Url.getOrgDomainUrl().toExternalForm() + '/services/apexrest/PenfieldAPITest';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        req.requestBody = Blob.valueOf(JSON.serialize(reqBody));
        RestContext.request = req;
        RestContext.response = res;
    
        Test.startTest();
        SalesforceAPIIntegration.insertOrderAndOrderLineItems();
        Test.stopTest();
        
        Assert.areEqual(400, res.statusCode, 'The status code of the response must be 400');
    } 
}