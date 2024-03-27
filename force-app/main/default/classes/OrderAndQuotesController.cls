public with sharing class OrderAndQuotesController {

    /**
     * @description This method will retrieve all the Order records for a specified Account. 
     * It will also sort the records according the orderBy and direction fields
     * @param accountId to look for the orders related
     * @param orderBy if is empty it will take a default value of OrderNumber
     * @param direction if is empty it will take a default value of ASC
     * @return  List or Order records
     */
    @AuraEnabled(cacheable=true)
    public static List<Order> getOrderListByAccount(String accountId, String orderBy, String direction) {
        try {
            if (String.isEmpty(orderBy)){
                orderBy = 'OrderNumber';
            }

            if (String.isEmpty(direction)){
                direction = 'DESC';
            }

            // Added String.escapeSingleQuotes to avoid SOQl injection
            String query = 'SELECT Id, OrderNumber, Status, Account.Name FROM Order';
            query += ' WHERE AccountId = :accountId WITH SECURITY_ENFORCED';
            query += ' ORDER BY ' + String.escapeSingleQuotes(orderBy) + ' ' + String.escapeSingleQuotes(direction);
            query += ' LIMIT 10000';
            return Database.query(query);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description This method will retrieve all the Quote records for a specified Account. 
     * It will also sort the records according the orderBy and direction fields
     * @param accountId to look for the quotes related
     * @param orderBy if is empty it will take a default value of QuoteNumber
     * @param direction if is empty it will take a default value of ASC
     * @return  List or Quote records
     */
    @AuraEnabled(cacheable=true)
    public static List<Quote> getQuoteListByAccount(String accountId, String orderBy, String direction) {
        try {
            if (String.isEmpty(orderBy)){
                orderBy = 'QuoteNumber';
            }

            if (String.isEmpty(direction)){
                direction = 'DESC';
            }
            
            // Added String.escapeSingleQuotes to avoid SOQl injection
            String query = 'SELECT Id, QuoteNumber, Status, Account.Name FROM Quote';
            query += ' WHERE AccountId = :accountId WITH SECURITY_ENFORCED';
            query += ' ORDER BY ' + String.escapeSingleQuotes(orderBy) + ' ' + String.escapeSingleQuotes(direction) ;
            query += ' LIMIT 10000';
            return Database.query(query);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}