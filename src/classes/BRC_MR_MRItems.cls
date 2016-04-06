public with sharing class BRC_MR_MRItems {
    
    public List<BRC_MR_Managment_Report_Item__c> items {get; set;}
    
    public BRC_MR_MRItems(){
        items = [SELECT Id, Parent_Item__r.Id, Title__c, Group__c, OwnerId, CreatedDate, Active__c, Auto__c, 
                 		Sort_Order__c, Long__c, Owner__r.User__r.Name, Reference_Id__c, currencyISOCode, Reversed_Item__c, Dependent__c
                 FROM BRC_MR_Managment_Report_Item__c];        
    }
    
    public List<BRC_MR_Managment_Report_Item__c> getChidrenItems(String parentId){
        List<BRC_MR_Managment_Report_Item__c> childrenItems = new List<BRC_MR_Managment_Report_Item__c>();
        for(BRC_MR_Managment_Report_Item__c i : items){
            if(i.Parent_Item__r.id == parentId){
                childrenItems.add(i);
            }
        }
        return childrenItems;
    }
    
    public BRC_MR_Managment_Report_Item__c getRoot(){
        for(BRC_MR_Managment_Report_Item__c i : items){
            if(i.Title__c == 'Root') return i;
        }
        return null;
    }
    
    public List<BRC_MR_Managment_Report_Item__c> getItemsByReferenceId(String refId){
        List<BRC_MR_Managment_Report_Item__c> retItems = new List<BRC_MR_Managment_Report_Item__c>();
        for(BRC_MR_Managment_Report_Item__c i : items){
            if(i.Reference_Id__c == refId) retItems.add(i);
        }
        return retItems;        
    }
}