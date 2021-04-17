global class GlpgMarketAcceesFlagProcessor implements Database.Batchable<sObject>, Database.Stateful {
    
    // SELECT Child_Account_vod__c FROM Child_Account_vod__c WHERE IsDeleted = false AND GLPG_Working_Status_Code__c = 'T'    
    private String queryAccountUpdate;
    
    global GlpgMarketAcceesFlagProcessor(String pQueryAccountUpdate) {
        queryAccountUpdate = pQueryAccountUpdate;
    }    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {        
        return Database.getQueryLocator(queryAccountUpdate);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        if(scope.size() > 0) {
            List<Id> uniqueAccountIds = new List<Id>();        
        
            for(sObject sObj : scope) {
                Child_Account_vod__c acc = (Child_Account_vod__c)sObj;
                
                if(!uniqueAccountIds.contains(acc.Child_Account_vod__c)) {
                    uniqueAccountIds.add(acc.Child_Account_vod__c);
                }
            }
            
            List<Account> accountsForUpdate = new List<Account>();
        
            for(Account hcp : [SELECT Id, Market_access_NWK__c FROM Account WHERE Id IN :uniqueAccountIds]) {
                hcp.Market_access_NWK__c = true;
                accountsForUpdate.add(hcp);
            }
            
            update accountsForUpdate;
        }  
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}