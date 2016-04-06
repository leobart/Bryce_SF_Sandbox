public class BRC_MR_UpdateAutoItems implements Schedulable{
        
    public void execute(SchedulableContext SC) {
        processFuture();
	}  

    @future(callout=true)
    public static void processFuture(){
        process();
    }
    
    public static void process(){
        Date thisMonday = Date.today().toStartOfWeek();
        Date nextMonday = thisMonday.addDays(7);
        Date[] dates = new Date[]{thisMonday, nextMonday};
        List<BRC_MR_Managment_Report_Item__c> items = [SELECT Id, Apex_Class__c, Parameters__c, CurrencyIsoCode 
                                                       FROM BRC_MR_Managment_Report_Item__c 
                                                           WHERE Auto__c = true 
                                                           AND Group__c = false
                                                           AND Active__c = true];
        String[] itemIds = new list<String>();
        for(BRC_MR_Managment_Report_Item__c item : items){
            itemIds.add(item.Id);
        }
        list<BRC_MR_Management_Report_Item_Value__c> values = [SELECT id, Value__c, Managment_Report_Item__c, Date__c 
                                                               FROM BRC_MR_Management_Report_Item_Value__c 
                                                               WHERE Managment_Report_Item__c IN: itemIds AND Date__c IN: dates];

        Map<String, BRC_MR_Management_Report_Item_Value__c> valuesMap = new Map<String, BRC_MR_Management_Report_Item_Value__c>();
        Map<String, BRC_MR_Management_Report_Item_Value__c> oldValuesMap = new Map<String, BRC_MR_Management_Report_Item_Value__c>();
        for(BRC_MR_Management_Report_Item_Value__c value : values){
            if(value.Date__c == thisMonday){
                oldValuesMap.put(value.Managment_Report_Item__c, value);   
            }else{
            	valuesMap.put(value.Managment_Report_Item__c, value);               
            }
        }
        
        String errors = '';
        Integer errorNumber = 1;
        list<BRC_MR_Management_Report_Item_Value__c> valuesForUpdate = new list<BRC_MR_Management_Report_Item_Value__c>();
        list<BRC_MR_Management_Report_Item_Value__c> valuesForInsert = new list<BRC_MR_Management_Report_Item_Value__c>();
        for(BRC_MR_Managment_Report_Item__c item : items){
            try{
                if (item.Apex_Class__c == null) continue;
                Type t = Type.forName(item.Apex_Class__c);
                if(t == null){
                    errors += errorNumber + ') <br/>';
                	errorNumber++;
                    errors += 'ITEM: ' + item + '<br/><br/>';
                    errors += 'CAUSE: Can not find defiend Apex Class: ' + item.Apex_Class__c+ ' <br/><br/><br/>';
                    continue;
                } 
                BRC_MR_Calculator calculator = (BRC_MR_Calculator) t.newInstance();
                BRC_MR_Management_Report_Item_Value__c oldValue = oldValuesMap.get(item.Id);
                Decimal oldDecimalvalue = null;
                if(oldValue != null) oldDecimalValue = oldValue.Value__c;
                Decimal result = calculator.getValue(item.Parameters__c, oldDecimalValue);
                if (result == null) continue;
                BRC_MR_Management_Report_Item_Value__c v = valuesMap.get(item.Id);
                if(v == null){
                    v = new BRC_MR_Management_Report_Item_Value__c();
                    v.Date__c = nextMonday;
                    v.Managment_Report_Item__c = item.Id;
                    v.Active__c = true;
                    v.Auto__c = true;
                    v.currencyISOCode = item.currencyISOCode;   
                    valuesForInsert.add(v);
                }else{
                    valuesForUpdate.add(v);    
                }
                v.Value__c = result;                
            }catch(Exception e){
                errors += errorNumber + ') <br/>';
                errorNumber++;
                errors += 'ITEM: ' + item + '<br/><br/>';
                errors += 'CAUSE: ' + e.getCause() + '   Message: ' + e.getMessage() +  '   Stack Trace: ' +  e.getStackTraceString() + '<br/><br/><br/>';
            }
        }
        if(errors.length() > 0) sendErrorsToAdmin(errors);
        insert valuesForInsert;
        update valuesForUpdate;
    }
    
    private static void sendErrorsToAdmin(String errorsBody){
    	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    	List<String> sendTo = new List<String>();
    	sendTo.add(UserInfo.getUserEmail());
    	mail.setToAddresses(sendTo);
   		mail.setReplyTo(UserInfo.getUserEmail());
    	mail.setSenderDisplayName('Auto Update Items Error');
		mail.setSubject('Errors in Auto Update Items For BRC_MR Module');
    	mail.setHtmlBody(errorsBody);
    	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });         
    }


}