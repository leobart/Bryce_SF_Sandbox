//
//          Set Complete Document Request when approved DFA
//          Author: Leonid Bartenev lbartenev@bryce.ch
//          
trigger BRC_DA_DFA_Trigger on BRC_DA_Document_For_Approval__c (before insert, before update) {
    List<BRC_DA_Document_For_Approval__c> docsOldList = (List<BRC_DA_Document_For_Approval__c>)trigger.old;
    List<BRC_DA_Document_For_Approval__c> docsNewList = (List<BRC_DA_Document_For_Approval__c>)trigger.new;
    if(Trigger.isUpdate){
        Integer listSize = docsOldList.size();
        for(Integer i=0; i<listSize; i++){
            BRC_DA_Document_For_Approval__c oldValue = docsOldList[i];
            BRC_DA_Document_For_Approval__c newValue = docsNewList[i];
            if(!oldValue.Approved__c && newValue.Approved__c && newValue.Document_Request__c!= null){
                BRC_DR_Document_Request__c dr = [SELECT Id FROM BRC_DR_Document_Request__c WHERE Id=:newValue.Document_Request__c];
                dr.Status__c = 'Complete';
                dr.Complete_Date__c = Date.today();
                update dr;
            }
        }       
    }
    
    for(BRC_DA_Document_For_Approval__c newValue : docsNewList){
        if(newValue.Document_Request__c != null){
            BRC_DR_Document_Request__c dr = [SELECT Id, Package__c FROM BRC_DR_Document_Request__c WHERE Id=:newValue.Document_Request__c];
            newValue.Package__c = dr.Package__c;
        }
    }
    
}