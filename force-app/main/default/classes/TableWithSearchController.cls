public with sharing class TableWithSearchController {
    
    @AuraEnabled(cacheable=true)
    public static List<Order> getAllOrders(){
        try {
            return [SELECT Id, Name, TotalAmount, Status, PoNumber, OrderReferenceNumber FROM Order WITH SECURITY_ENFORCED LIMIT 10000];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Order> getAllOrdersLargeVolumeOfData(String searchValue){
        try {
            if (String.isEmpty(searchValue)) {
                return [SELECT Id, Name, TotalAmount, Status, PoNumber, OrderReferenceNumber FROM Order WITH SECURITY_ENFORCED LIMIT 10000];
            } else {
                List<list<SObject>> ordersList = new List<List<SObject>>();
                ordersList = [FIND :searchValue IN ALL FIELDS RETURNING Order(Id, OrderNumber, Name, TotalAmount, Status, PONumber, OrderReferenceNumber)];
                return (Order[])ordersList[0];
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}