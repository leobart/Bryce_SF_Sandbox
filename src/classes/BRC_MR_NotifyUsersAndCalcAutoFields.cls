public class BRC_MR_NotifyUsersAndCalcAutoFields implements Schedulable{
    
    public void execute(SchedulableContext SC) {
        process();
	}  
    
    public void process(){
		List<AggregateResult> leafItemsAR = [SELECT Owner__r.User__c userId FROM BRC_MR_Managment_Report_Item__c WHERE Group__c = false group by Owner__r.User__c];
        Set<String> userIds = new Set<String>();
        for(AggregateResult ar : leafItemsAR){
            userIds.add((String)ar.get('userId'));
        }
        Date mondayDate = Date.today().toStartofWeek();
        for(String userId : userIds){
            List<BRC_MR_Managment_Report_Item__c> items = [SELECT Id FROM BRC_MR_Managment_Report_Item__c 
                                                           WHERE Owner__r.User__c =: userId 
                                                           AND Auto__c = false 
                                                           AND Group__c = false
                                                           AND Active__c = true];
            Set<String> itemIds = new Set<String>();
            for(BRC_MR_Managment_Report_Item__c item : items){
                itemIds.add(item.Id);	                
            }
            List<BRC_MR_Management_Report_Item_Value__c> values = [SELECT Id FROM BRC_MR_Management_Report_Item_Value__c
                                                                   WHERE Date__c =: mondayDate AND Managment_Report_Item__c IN: itemIds];
            if(items.size() != values.size()){
                Id templateId = [select id, name from EmailTemplate where developername = 'BRC_MR_NotifyReportDataUpdate'].id;
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(userId);
                mail.setTemplateId(templateId);
                mail.setBccSender(false);
                mail.setUseSignature(false);
                //mail.setReplyTo('recruiting@acme.com');
                mail.setSenderDisplayName('Weekly Update');
                mail.setSaveAsActivity(false); 
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });              
            }          
        }           
    }
}