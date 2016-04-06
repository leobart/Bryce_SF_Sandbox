trigger CreditLineAmountUpdate on Credit_Line_Line_Item__c (after insert, after update, after delete) {
	if ((trigger.isInsert)||(trigger.isUndelete)||(trigger.isUpdate)){
    	for (Credit_Line_Line_Item__c CLLI : trigger.new){
            Bank__c Papa=[select Group_Credit_Line_Amount__c From Bank__c Where id =:CLLI.Bank__c];
            system.debug(Papa);
	        List<Credit_Line_Line_Item__c> brothers=[select ID, Change_Date__c, AmountAvailable__c from Credit_Line_Line_Item__c where Bank__c=:CLLI.Bank__c ORDER BY Change_Date__c DESC LIMIT 1];
            if (brothers.size()==0){
            	Papa.Group_Credit_Line_Amount__c=0;
                update Papa;
            } else if (brothers[0]!=null){
                Papa.Group_Credit_Line_Amount__c=brothers[0].AmountAvailable__c;
                update Papa;
            }
        }
    } else if (trigger.isDelete){
        for (Credit_Line_Line_Item__c CLLI : trigger.old){
	        Bank__c Papa=[select Group_Credit_Line_Amount__c From Bank__c Where id =:CLLI.Bank__c];
            system.debug(Papa);
	        List<Credit_Line_Line_Item__c> brothers=[select ID, Change_Date__c, AmountAvailable__c from Credit_Line_Line_Item__c where Bank__c=:CLLI.Bank__c ORDER BY Change_Date__c DESC LIMIT 1];
            if (brothers.size()==0){
            	Papa.Group_Credit_Line_Amount__c=0;
                update Papa;
            } else if (brothers[0]!=null){
                Papa.Group_Credit_Line_Amount__c=brothers[0].AmountAvailable__c;
                update Papa;
            }
        }
    }
}