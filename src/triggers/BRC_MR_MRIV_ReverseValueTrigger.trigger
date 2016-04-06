trigger BRC_MR_MRIV_ReverseValueTrigger on BRC_MR_Management_Report_Item_Value__c (after insert, after update) {
    list<BRC_MR_Management_Report_Item_Value__c> insertValues = new list<BRC_MR_Management_Report_Item_Value__c>();
    list<BRC_MR_Management_Report_Item_Value__c> updateValues = new list<BRC_MR_Management_Report_Item_Value__c>();
    for(BRC_MR_Management_Report_Item_Value__c value : trigger.new){
        if(value.Reversed_Item__c == null) continue;
        BRC_MR_Management_Report_Item_Value__c[] revValues = [SELECT Id
                                                              FROM BRC_MR_Management_Report_Item_Value__c
                                                              WHERE Managment_Report_Item__c =: value.Reversed_Item__c 
                                                              	AND Date__c =: value.Date__c];
        BRC_MR_Management_Report_Item_Value__c revValue;
        if(revValues.size() == 0){
            revValue = new BRC_MR_Management_Report_Item_Value__c(Date__c = value.Date__c, 
                                                                  Managment_Report_Item__c = value.Reversed_Item__c, 
                                                                  Active__c = value.Active__c, 
                                                                  Auto__c = false, 
                                                                  CurrencyIsoCode = value.CurrencyIsoCode);
            insertValues.add(revValue);
        }else{
            revValue = revValues[0];
            updateValues.add(revValue);
        }
        revValue.Value__c = - value.Value__c;
        revValue.CurrencyIsoCode = value.CurrencyIsoCode;
    }
    insert insertValues;
    update updateValues;    
}