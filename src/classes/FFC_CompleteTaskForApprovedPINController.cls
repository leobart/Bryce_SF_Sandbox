public class FFC_CompleteTaskForApprovedPINController{
    
    public c2g__codaPurchaseInvoice__c pin {get; set;}
    public List<c2g__codaCashEntry__c> cashEntries {get; set;}
    public Boolean emptyCashEntries {get; set;}
    public Boolean noInitErrors {get; set;}
    public Task t{get; set;}
    public String errorMessage;
    
    public static String COMPLETE_TASK_VALUE = [SELECT MasterLabel FROM TaskStatus WHERE isClosed=true].MasterLabel;
    
    public FFC_CompleteTaskForApprovedPINController(ApexPages.StandardController controller){
        noInitErrors = true;
        emptyCashEntries = false;
        String taskId = controller.getId();
		if(taskId == null){
			errorMessage = 'Task not defined in request.';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, errorMessage));
			noInitErrors = false;
            return;
        }	
        t = [SELECT Id, WhatId, Status FROM Task WHERE Id=:taskId];
        if(t.Status == COMPLETE_TASK_VALUE){
			errorMessage = 'Task already completed.';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, errorMessage));
			noInitErrors = false;
            return;            
        }
		String objId = t.WhatId;
        c2g__codaPurchaseInvoice__c[] pins = [SELECT Id, Name,
                                                        c2g__AccountInvoiceNumber__c
                                               FROM c2g__codaPurchaseInvoice__c 
                                               WHERE Id=:objId];
        if(pins.size() == 0){
            errorMessage = 'Payable Invoice Id mismatch';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, errorMessage));
            noInitErrors = false;
            return;                
        } 
        pin = pins[0];
        cashEntries = [SELECT Id, Name FROM c2g__codaCashEntry__c WHERE c2g__Reference__c =: pin.c2g__AccountInvoiceNumber__c]; 
        emptyCashEntries = (cashEntries.size() == 0);
        if(emptyCashEntries){
            errorMessage = 'Cash Entries not created for Payable Invoice. Can not complete task!';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, errorMessage));
            noInitErrors = false;            
        }
    }
    
    public PageReference complete(){
        if(cashEntries.size() == 0){
            errorMessage = 'Can not complete task, Cash Entries not created for Payable Invoice';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, errorMessage));
            return null;                            
        }
        String s = '';
        for(c2g__codaCashEntry__c ce : cashEntries){
            s = s + ce.Name + ', ';
        }
        s = s.substring(0, s.length()-2);
        s = 'Created Cash Entries: ' + s;
        t.Description ='Task completed automatically. ' + s; 
        t.Status = COMPLETE_TASK_VALUE;
        update t;

    	return new PageReference('/home/home.jsp'); 
    }

    public PageReference cancel(){
    	return new PageReference('/'+t.Id); 
    }
}