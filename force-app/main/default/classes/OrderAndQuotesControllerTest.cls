@isTest
public class OrderAndQuotesControllerTest {

    @TestSetup
    static void makeData(){
        // Creating account
        Account act = new Account();
        act.Name = 'Testing Account';
        insert act;

        // Creating Contracts
        Contract cntr = new Contract();
        cntr.Status = 'Draft';
        cntr.StartDate = Date.newInstance(2024, 04, 01);
        cntr.ContractTerm = 5;
        cntr.AccountId = act.Id;
        insert cntr;

        // Creating Orders
        List<Order> toAdd = new List<Order>();
        for (Integer i = 0; i < 10; I++) {
            Order record = new Order();
            record.AccountId = act.Id;
            record.EffectiveDate = Date.newInstance(2024, 04, 02);
            record.Status = 'Draft';
            toAdd.add(record);
        }
        insert toAdd;

        // Creating Opportunity
        Opportunity opp = new Opportunity();
        opp.Name = 'Opp Test';
        opp.StageName = 'Prospecting';
        opp.CloseDate = Date.newInstance(2024, 04, 01);
        opp.AccountId = act.Id;
        insert opp;

        // Creating Opportunity
        Opportunity oppSecond = new Opportunity();
        oppSecond.Name = 'OppSecond Test';
        oppSecond.StageName = 'Need Analysis';
        oppSecond.CloseDate = Date.newInstance(2024, 04, 01);
        oppSecond.AccountId = act.Id;
        insert oppSecond;

        // Creating Quotes
        List<Quote> toAddQ = new List<Quote>();
        for (Integer i = 1; i <= 10; I++) {
            Quote record = new Quote();
            record.OpportunityId = (Math.mod(i, 2) == 0 ? opp.Id : oppSecond.Id);
            record.ExpirationDate = Date.newInstance(2024, 04, 02);
            record.Status = 'Draft';
            record.Name = 'Test Quote' + i;
            toAddQ.add(record);
        }
        insert toAddQ;
    }

    @IsTest
    static void getOrderListByAccountTestPositiveScenario(){
        Account account = [SELECT Id FROM Account LIMIT 1];
        
        List<Order> orders = [SELECT Id FROM Order WHERE AccountId =: account.Id];

        Test.startTest();
        List<Order> result = OrderAndQuotesController.getOrderListByAccount(account.Id, null, null);
        Test.stopTest();

        Assert.areEqual(orders.size(), result.size(), 'Both lists should be equal in size');
    }

    @IsTest
    static void getOrderListByAccountTestNegativeScenario(){
        Account account = [SELECT Id FROM Account LIMIT 1];
    
        
        List<Order> orders = [SELECT Id FROM Order WHERE AccountId =: account.Id];

        Test.startTest();
        try {
            List<Order> result = OrderAndQuotesController.getOrderListByAccount(account.Id, 'Field__C', 'Direction');
        } catch (Exception e) {
            Assert.isNotNull(e);
        }
        Test.stopTest();
    }

    @IsTest
    static void getQuoteListByAccountPositiveScenario(){
        Account account = [SELECT Id FROM Account LIMIT 1];
        String orderBy = 'Status';
        String sortDirection = 'asc';
        
        List<Quote> quotes = [SELECT Id FROM Quote WHERE AccountId =: account.Id];

        Test.startTest();
        List<Quote> result = OrderAndQuotesController.getQuoteListByAccount(account.Id, orderBy, sortDirection);
        Test.stopTest();

        Assert.areEqual(quotes.size(), result.size(), 'Both lists should be equal in size');
    }

    @IsTest
    static void getQuoteListByAccountNegativeScenario(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Minimum Access - Salesforce']; 
        User u = new User(Alias = 'minstd', Email='minstduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing Min', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='minstduser@testorg.com');

        System.runAs(u) {
            Account account = [SELECT Id FROM Account LIMIT 1];
        
            List<Order> orders = [SELECT Id FROM Order WHERE AccountId =: account.Id];

            Test.startTest();
            try {
                List<Quote> result = OrderAndQuotesController.getQuoteListByAccount(account.Id, null, null);
            } catch (Exception e) {
                Assert.isNotNull(e);
            }
            Test.stopTest();
        }
    }
}