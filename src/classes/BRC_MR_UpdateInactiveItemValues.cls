public class BRC_MR_UpdateInactiveItemValues  implements Schedulable{
    
    public void execute(SchedulableContext SC){
        Date thisMonday = Date.today().toStartOfWeek();
        Date nextMonday = thisMonday.addDays(7);
        List<BRC_MR_Managment_Report_Item__c> items = [SELECT Id, Apex_Class__c, Parameters__c, CurrencyIsoCode 
                                                       FROM BRC_MR_Managment_Report_Item__c 
                                                       WHERE Group__c = false
                                                         AND Active__c = false];
        String[] itemIds = new list<String>();
        for(BRC_MR_Managment_Report_Item__c item : items){
            itemIds.add(item.Id);
        }
        list<BRC_MR_Management_Report_Item_Value__c> values = [SELECT id, Value__c, Managment_Report_Item__c, Date__c 
                                                               FROM BRC_MR_Management_Report_Item_Value__c 
                                                               WHERE Managment_Report_Item__c IN: itemIds AND Date__c =: nextMonday];

        Map<String, BRC_MR_Management_Report_Item_Value__c> valuesMap = new Map<String, BRC_MR_Management_Report_Item_Value__c>();
        for(BRC_MR_Management_Report_Item_Value__c value : values){
            valuesMap.put(value.Managment_Report_Item__c, value);   
        }
        
        list<BRC_MR_Management_Report_Item_Value__c> valuesForUpdate = new list<BRC_MR_Management_Report_Item_Value__c>();
        list<BRC_MR_Management_Report_Item_Value__c> valuesForInsert = new list<BRC_MR_Management_Report_Item_Value__c>();
        for(BRC_MR_Managment_Report_Item__c item : items){
            BRC_MR_Management_Report_Item_Value__c value = valuesMap.get(item.Id);
            if(value == null){
            	value = new BRC_MR_Management_Report_Item_Value__c();
                value.Date__c = nextMonday;
                value.Managment_Report_Item__c = item.Id;
                value.Active__c = false;
                value.Auto__c = false;
                value.currencyISOCode = item.currencyISOCode;   
                valuesForInsert.add(value);               
            }else{
                valuesForUpdate.add(value);
            }
            value.Value__c = 0;
        }
        insert valuesForInsert;
        update valuesForUpdate;
    }

}