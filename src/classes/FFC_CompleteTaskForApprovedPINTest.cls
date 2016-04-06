@isTest (SeeAllData=true)
public class FFC_CompleteTaskForApprovedPINTest{

    public static Bank__c bank = [SELECT Id, Name FROM Bank__c WHERE Name='Rietumu Banka'];
    public static Account acc = [SELECT Id, Name FROM Account WHERE Name='Bank Rietumu'];   

    static private c2g__codaGeneralLedgerAccount__c glaReceivable = [SELECT Id FROM c2g__codaGeneralLedgerAccount__c WHERE Name='1-2200 Accounts receivable control'];
    static private c2g__codaGeneralLedgerAccount__c glaPayable = [SELECT Id FROM c2g__codaGeneralLedgerAccount__c WHERE Name='2-2200 Accounts payable control'];

   
    static testMethod void test1(){       
        c2g__codaPurchaseInvoice__c pin = createPIN();
        
        Task task = new Task(
            WhatId = pin.Id, 
            Type = 'General Task', 
            Subject = 'Test Task', 
            Description = 'Description', 
            ActivityDate = Date.today(), 
            Status = 'Not Started');
        
        insert task;
        
        ApexPAges.StandardController sc = new ApexPages.StandardController(task);
        FFC_CompleteTaskForApprovedPINController controller = new FFC_CompleteTaskForApprovedPINController(sc);
        controller.complete();
    }
    
    static testMethod void test2(){       
        c2g__codaPurchaseInvoice__c pin = createPIN();
        
        Task task = new Task(
            WhatId = pin.Id, 
            Type = 'General Task', 
            Subject = 'Test Task', 
            Description = 'Description', 
            ActivityDate = Date.today(), 
            Status = FFC_CompleteTaskForApprovedPINController.COMPLETE_TASK_VALUE);
        
        insert task;
        
        ApexPAges.StandardController sc = new ApexPages.StandardController(task);
        FFC_CompleteTaskForApprovedPINController controller = new FFC_CompleteTaskForApprovedPINController(sc);
    }
    
    static testMethod void test3(){       
        c2g__codaPurchaseInvoice__c pin = createPIN();
        
        Task task = new Task();
        ApexPAges.StandardController sc = new ApexPages.StandardController(task);
        FFC_CompleteTaskForApprovedPINController controller = new FFC_CompleteTaskForApprovedPINController(sc);
    }
    
    static testMethod void test4(){       
        c2g__codaPurchaseInvoice__c pin = createPIN();
        Account a = new Account(name='TmpAccount', c2g__CODAAccountsPayableControl__c = glaPayable.Id, c2g__CODAAccountsReceivableControl__c = glaReceivable.Id);
        insert a;
        
        Task task = new Task(
            WhatId = a.Id, 
            Type = 'General Task', 
            Subject = 'Test Task', 
            Description = 'Description', 
            ActivityDate = Date.today(), 
            Status = 'Not Started');
        
        insert task;
        
        ApexPAges.StandardController sc = new ApexPages.StandardController(task);
        FFC_CompleteTaskForApprovedPINController controller = new FFC_CompleteTaskForApprovedPINController(sc);
        controller.cancel();
    }
    private static c2g__codaPurchaseInvoice__c createPIN(){
        c2g__codaPurchaseInvoice__c pin = 
            new c2g__codaPurchaseInvoice__c(c2g__AccountInvoiceNumber__c = '11232-3334', 
                                            c2g__InvoiceDate__c = System.today(), 
                                            c2g__DueDate__c = System.today(), 
                                            Bank__c = bank.Id, 
                                            c2g__Account__c = acc.Id); 
        insert pin;
        return pin;
    }
}