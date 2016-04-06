@isTest (SeeAllData=true)
public class FFC_CreateCEForPINTest{
    
    public static Bank__c bank = [SELECT Id, Name FROM Bank__c WHERE Name='Rietumu Banka'];
    public static Account acc = [SELECT Id, Name FROM Account WHERE Name='Bank Rietumu'];   

    
    static testMethod void test1(){       
        c2g__codaPurchaseInvoice__c pin = 
            new c2g__codaPurchaseInvoice__c(c2g__AccountInvoiceNumber__c = '11232-3334', 
                                            c2g__InvoiceDate__c = System.today(), 
                                            c2g__DueDate__c = System.today(), 
                                            Bank__c = bank.Id, 
                                            c2g__Account__c = acc.Id); 
        insert pin;
        
        Task task = new Task(
            WhatId = pin.Id, 
            Type = 'General Task', 
            Subject = 'Test Task', 
            Description = 'Description', 
            ActivityDate = Date.today(), 
            Status = 'Not Started');
        
        insert task;
        
        ApexPAges.StandardController sc = new ApexPages.StandardController(task);
        FFC_CreateCEForPINController controller = new FFC_CreateCEForPINController(sc);
        controller.createCashEntry();
    }
}