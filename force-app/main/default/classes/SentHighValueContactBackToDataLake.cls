public class SentHighValueContactBackToDataLake implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable{
    
    public List<Order_Request__c> start(Database.BatchableContext bc) {
        // Retrieving the Orders that has a total amount voer 500
        List<Order_Request__c> orders = [   SELECT Id, Contact__c 
                                            FROM Order_Request__c 
                                            WHERE CreatedDate = LAST_90_DAYS AND Total_Amount__c >= 500
                                            LIMIT 50000];
        return orders;
    }   
    
    public void execute(Database.BatchableContext bc, List<Order_Request__c> scope) {
        try {
            Set<String> contactstoSend = new Set<String>();
            // Retrieving only the Contact Id of the Orders that match the criteria
            for (Order_Request__c record : scope) {
                contactstoSend.add(record.Contact__c);
            }
            
            if (!contactstoSend.isEmpty()) {
                List<String> contactExternalIds = new List<String>();
                for (Contact record : [SELECT Id, Commerce_Cloud_Id__c FROM Contact WHERE Id IN: contactstoSend LIMIT 50000]) {
                    contactExternalIds.add(record.Commerce_Cloud_Id__c);
                }
                
                // Send Contact Id's to Data lake
                if (!Test.isRunningTest()) {
                    HTTP h = new Http();
                    HTTPRequest req = new HTTPRequest();
                    req.setEndpoint('www.endpoint.com');
                    req.setMethod('POST');
                    req.setBody(JSON.serialize(contactExternalIds));
            
                    HTTPResponse res = h.send(req);
                    if (res.getStatusCode() == 200) {
                        //
                    }
                }
            }
        } catch (Exception e) {
            String errorDescription = 'Error: ' + e.getmessage() + ', Line: ' + e.getLineNumber() + ', Stack Trace: ' + e.getStackTraceString();
            if (!Test.isRunningTest()) {
                Messaging.Singleemailmessage mail = new Messaging.Singleemailmessage();
                mail.setToAddresses(new String[] {'ruddyrgr@gmail.com'});
                mail.setSubject('Error from Batch Job SentHighValueContactBackToDataLake, ' + Date.today());
                mail.setPlainTextBody(errorDescription);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
    }    
    
    public void finish(Database.BatchableContext BC) {
        // 
    }    
    
    public void execute(SchedulableContext SC) {
        Database.executebatch(new SentHighValueContactBackToDataLake());
    }
}