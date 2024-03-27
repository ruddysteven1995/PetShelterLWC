@isTest
global class MockHttpForSalesforceAPIIntegration implements HttpCalloutMock {
    
    Integer statusCodeParam;
    global MockHttpForSalesforceAPIIntegration (Integer statusCodeParam) {
        this.statusCodeParam = statusCodeParam;
    }
    
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();  
        res.setHeader('Content-Type', 'application/json');
        if (req.getMethod() == 'PUT') {
            switch on this.statusCodeParam {
                when 500 {
                    res.setBody('{"statusCode":500,"description":"User does not have permissions to create the Contact"}');
                    res.setStatusCode(this.statusCodeParam);
                }
                when 400 {
                    res.setBody('{"statusCode":400,"description":"An Error occurred while creating the record"}');
                    res.setStatusCode(this.statusCodeParam);
                }
                when 201 {
                    res.setBody('{"attributes":{"type":"Contact","url":"/services/data/v60.0/sobjects/Contact/0000000123"},"Email":"test+10@gmail.com","Commerce_Cloud_Id__c":"00001","Phone":"+59179713251","LastName":"Steven","Opt_In__c":true,"Id":"0000000123"}');
                    res.setStatusCode(this.statusCodeParam);
                }
            }
        }
        
        if (req.getMethod() == 'POST') {
            switch on this.statusCodeParam {
                when 500 {
                    res.setBody('{"statusCode":500,"description":"User does not have permissions to create the record"}');
                    res.setStatusCode(this.statusCodeParam);
                }
                when 400 {
                    res.setBody('{"statusCode":400,"description":"An Error occurred while creating the record"}');
                    res.setStatusCode(this.statusCodeParam);
                }
                when 200 {
                    res.setBody('{"order":{"attributes":{"type":"Order_Request__c","url":"/services/data/v60.0/sobjects/Order_Request__c/a04Hs00002CyIYmIAN"},"Commerce_Cloud_Id__c":"0005","Shipment_Date__c":"2024-04-05","Order_Date__c":"2024-04-01","Total_Amount__c":181,"Id":"a04Hs00002CyIYmIAN"},"lineItems":[{"attributes":{"type":"Order_Line_Item__c","url":"/services/data/v60.0/sobjects/Order_Line_Item__c/a03Hs000011SZUOIA4"},"Order__c":"a04Hs00002CyIYmIAN","Name":"Product 6","Product_Size__c":"large","Product_Color__c":"brown","Product_Price__c":1,"Id":"a03Hs000011SZUOIA4"},{"attributes":{"type":"Order_Line_Item__c","url":"/services/data/v60.0/sobjects/Order_Line_Item__c/a03Hs000011SZUPIA4"},"Order__c":"a04Hs00002CyIYmIAN","Name":"Product 7","Product_Size__c":"small","Product_Color__c":"white","Product_Price__c":180,"Id":"a03Hs000011SZUPIA4"}]}');
                    res.setStatusCode(this.statusCodeParam);
                }
            }
        }

        return res;
    }
}