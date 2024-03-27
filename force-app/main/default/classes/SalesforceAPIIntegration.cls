@RestResource(urlMapping='/PenfieldAPI/*')
global with sharing class SalesforceAPIIntegration {

    /**
     * @description POST request will insert Order and their respective Order line items and it will relate to each other
     */
    @HttpPost
    global static void insertOrderAndOrderLineItems() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try {
            OrderAndLineItemsRequestObject reqObject = (OrderAndLineItemsRequestObject)JSON.deserializeStrict(req.requestbody.tostring(), OrderAndLineItemsRequestObject.class);

            // Mapping request data into Order object
            Order_Request__c order = new Order_Request__c();
            order.Commerce_Cloud_Id__c = reqObject.order.commerceCloudId; 
            order.Shipment_Date__c = reqObject.order.shipmentDate; 
            order.Order_Date__c = reqObject.order.orderDate;  
            order.Contact__c = reqObject.order.contactId;  

            // Checking Create access to the object
            if (Schema.sObjectType.Order_Request__c.isCreateable()) {
                insert order;

                List<Order_Line_Item__c> lineItemsToInsert = new List<Order_Line_Item__c>();
                if (reqObject.order.lineItems != null && !reqObject.order.lineItems.isEmpty()) {
                    for (OrderLineItemRequestObject record : reqObject.order.lineItems) {

                        // Mapping request data into Order line item object
                        Order_Line_Item__c lineItem = new Order_Line_Item__c();
                        lineItem.Order__c = order.Id;
                        lineItem.Name = record.productName;
                        lineItem.Product_Size__c = record.productSize;
                        lineItem.Product_Color__c = record.productColor;
                        lineItem.Product_Price__c = record.productPrice;
                        lineItemsToInsert.add(lineItem);
                    }
                }

                // Checking Create access to the object
                if (Schema.sObjectType.Order_Line_Item__c.isCreateable()) {
                    insert lineItemsToInsert;
                }

                OrderAndLineItemsResponseObject response = new OrderAndLineItemsResponseObject();
                response.order = order;
                response.lineItems = lineItemsToInsert;
        
                buildResponse(res, 200, JSON.serialize(response));
            } else {
                buildResponse(res, 500, JSON.serialize(buildErrorResponse(500, 'User does not have permissions to create the Orders.')));
            }
        } catch (Exception e) {
            String errorDescription = 'Error: ' + e.getmessage() + ', Line: ' + e.getLineNumber() + ', Stack Trace: ' + e.getStackTraceString();
            buildResponse(res, 400, JSON.serialize(buildErrorResponse(400, errorDescription)));
        }
    }

    /**
     * @description PUT request will upsert a contact based on the Commerce Cloud Id provided
     */
    @HttpPut
    global static void upsertContact() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try {
            ContactRequestObject reqObject = (ContactRequestObject)JSON.deserializeStrict(req.requestbody.tostring(), ContactRequestObject.class);
            
            // Mapping request data into contact object
            Contact toUpsert = new Contact();
            toUpsert.Email = reqObject.emailAddress; 
            toUpsert.Commerce_Cloud_Id__c = reqObject.commerceCloudId; 
            toUpsert.Phone = reqObject.phoneNumber; 
            toUpsert.LastName = reqObject.name; 
            toUpsert.Opt_In__c = true; 
            
            // Checking Create and Update access to the object
            if (Schema.sObjectType.Contact.isCreateable() && Schema.sObjectType.Contact.isUpdateable()) {
                upsert toUpsert Commerce_Cloud_Id__c;
                buildResponse(res, 201, JSON.serialize(toUpsert));
            } else{
                buildResponse(res, 500, 'User does not have permissions to create the Contact');
            }
        } catch (Exception e) {
            String errorDescription = 'Error: ' + e.getmessage() + ', Line: ' + e.getLineNumber() + ', Stack Trace: ' + e.getStackTraceString();
            buildResponse(res, 400, JSON.serialize(buildErrorResponse(400, errorDescription)));
        }
    }

    /**
     * @description This method will help to build a Response
     * @param res type RestResponse
     * @param statusCode type Integer
     * @param message type String
     */
    private static RestResponse buildResponse(RestResponse res, Integer statusCode, String message) {
        res.addHeader('Content-Type', 'application/json');
        res.statusCode = statusCode;
        res.responseBody = Blob.valueOf(message);

        return res;
    }

    /**
     * @description This method will help to build an Error Response
     * @param statusCode type Integer
     * @param errorDescription type String
     */
    private static ErrorResponseWrapper buildErrorResponse(Integer statusCode, String errorDescription) {
        return new ErrorResponseWrapper(statusCode, errorDescription);
    }

    /**
     * Inner class to serialize the Request Contact object
    */
    public class ContactRequestObject {
        public String emailAddress;
        public String commerceCloudId;
        public String phoneNumber;
        public String name;
    }

    /**
     * Inner class to serialize the request for Order and Line Items Request objects
    */
    public class OrderAndLineItemsRequestObject {
        public OrderRequestObject order;
    }

    /**
     * Inner class to serialize the Request Order object
    */
    public class OrderRequestObject {
        public String commerceCloudId;
        public Date shipmentDate;
        public Date orderDate;
        public String contactId;
        public List<OrderLineItemRequestObject> lineItems;
    }

    /**
     * Inner class to serialize the Request Order Line Item object
    */
    public class OrderLineItemRequestObject {
        public String orderId;
        public String productName;
        public String productSize;
        public String productColor;
        public Decimal productPrice;
    }

    /**
     * Inner class to serialize the Response Order and Line Item objects
    */
    public class OrderAndLineItemsResponseObject {
        public Order_Request__c order;
        public List<Order_Line_Item__c> lineItems;
    }

    /**
     * Inner class used to wrapp the Error response details
    */
    public class ErrorResponseWrapper {
        public Integer statusCode;
        public String description;
        
        public ErrorResponseWrapper(Integer statusCode, String description) {
            this.statusCode = statusCode;
            this.description = description;
        }
    }
}