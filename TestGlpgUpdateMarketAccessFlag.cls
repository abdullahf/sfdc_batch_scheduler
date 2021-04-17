@isTest
public class TestGlpgUpdateMarketAccessFlag {
    
    @testSetup static void setup() {
        
        Account hco = new Account(Name='TestHCO_MarketAccess');
        insert hco;      

        List<Account> accts = new List<Account>();
        for(Integer i = 0; i< 200; i++) {
            accts.add(new Account(LastName='TestHCP_MarketAccess_' + i));
        }
        insert accts;
        
        List<Child_Account_vod__c> children = new List<Child_Account_vod__c>();
        
        for(Account h:[select id from Account where LastName like 'TestHCP_MarketAccess_%']) {
            Child_Account_vod__c child = new Child_Account_vod__c(
                Child_Account_vod__c= h.Id,
                Parent_Account_vod__c = hco.Id,
                GLPG_Working_Status_Code__c = 'T',
                GLPG_Working_Status_Label__c = 'Market Access');
            children.add(child);
        }
        insert children;
    }
    
    @isTest static void testUpdateFlags() {
        Test.startTest();
        String queryAccountReset = 'select Id from Account where LastName like \'TestHCP_MarketAccess_%\'';
        String queryAccountUpdate = 'select Child_Account_vod__c from Child_Account_vod__c where Parent_Name_vod__c = \'TestHCO_MarketAccess\'';
        GlpgMarketAccessFlagUpdater batch = new GlpgMarketAccessFlagUpdater(queryAccountReset, queryAccountUpdate);
        Database.executebatch(batch);
        Test.stopTest();
        System.assertEquals(200, [select count() from Account where LastName like 'TestHCP_MarketAccess_%' and Market_access_NWK__c=true]);
    }
    
    @isTest static void testScheduler() {
        Test.startTest();  
        
        String queryAccountReset = 'select Id from Account where LastName like \'TestHCP_MarketAccess_%\'';
        String queryAccountUpdate = 'select Child_Account_vod__c from Child_Account_vod__c where Parent_Name_vod__c = \'TestHCO_MarketAccess\'';
        
        GlpgMarketAccessFlagUpdateScheduler scheduler = new GlpgMarketAccessFlagUpdateScheduler(queryAccountReset, queryAccountUpdate);
        
        String cronExp = '0 0 4 ? * * *'; 
        String jobId = System.schedule('Test Market Access Flag Updater', cronExp, scheduler);  
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                              FROM CronTrigger WHERE id = :jobId];
        
        System.assertEquals(cronExp, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        
        Test.stopTest();
    }
}