global class GlpgMarketAccessFlagUpdater implements Database.Batchable<sObject>, Database.Stateful {
    
    // SELECT Id, Market_access_NWK__c FROM Account WHERE IsDeleted = false AND Market_access_NWK__c = true
    private String queryAccountReset;
    
    // SELECT Child_Account_vod__c FROM Child_Account_vod__c WHERE IsDeleted = false AND GLPG_Working_Status_Code__c = 'T'    
    private String queryAccountUpdate;
    
    global GlpgMarketAccessFlagUpdater(String pQueryAccountReset, String pQueryAccountUpdate) {
        queryAccountReset = pQueryAccountReset;
        queryAccountUpdate = pQueryAccountUpdate;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {        
        return Database.getQueryLocator(queryAccountReset);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        if(scope.size() > 0) {
            for(sObject sObj : scope) {
            	Account acc = (Account)sObj;
                acc.Market_access_NWK__c = false;
        	}        
            update scope;
        } 
    }
    
    global void finish(Database.BatchableContext BC) {
        GlpgMarketAcceesFlagProcessor batch = new GlpgMarketAcceesFlagProcessor(queryAccountUpdate);
        Database.executeBatch(batch, 200);
    }
}