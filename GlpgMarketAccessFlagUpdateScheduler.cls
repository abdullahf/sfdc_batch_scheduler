global class GlpgMarketAccessFlagUpdateScheduler implements Schedulable {
    
    private String accountsToBeReset = 'SELECT Id, Market_access_NWK__c FROM Account WHERE IsDeleted = false AND Market_access_NWK__c = true';
    private String accountsToBeUpdated = 'SELECT Child_Account_vod__c FROM Child_Account_vod__c WHERE IsDeleted = false AND GLPG_Working_Status_Code__c = \'T\'';
    
    global GlpgMarketAccessFlagUpdateScheduler() {
        
    }
    
    global GlpgMarketAccessFlagUpdateScheduler(String pAccountsToBeReset, String pAccountsToBeUpdated) {
        if(String.isNotBlank(pAccountsToBeReset) && String.isNotBlank(pAccountsToBeUpdated)) {
            accountsToBeReset = pAccountsToBeReset;
        	accountsToBeUpdated = pAccountsToBeUpdated;
        }        
    }    
    
    global void execute(SchedulableContext ctx) {        
      	GlpgMarketAccessFlagUpdater batch = new GlpgMarketAccessFlagUpdater(accountsToBeReset, accountsToBeUpdated);
      	Database.executebatch(batch, 200);
    }
}