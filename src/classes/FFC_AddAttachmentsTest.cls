@isTest (SeeAllData=true)
public class FFC_AddAttachmentsTest{
    
    static private c2g__codaGeneralLedgerAccount__c glaReceivable = [SELECT Id FROM c2g__codaGeneralLedgerAccount__c WHERE Name='1-2200 Accounts receivable control'];
    static private c2g__codaGeneralLedgerAccount__c glaPayable = [SELECT Id FROM c2g__codaGeneralLedgerAccount__c WHERE Name='2-2200 Accounts payable control'];
    
    static testMethod void test1(){
        Account acc = new Account(Name='Acc1', c2g__CODAAccountsPayableControl__c = glaPayable.Id, c2g__CODAAccountsReceivableControl__c = glaReceivable.Id);
        insert acc;
        ApexPages.currentPage().getParameters().put('objId', acc.Id);
        ApexPages.currentPage().getParameters().put('objName', acc.Name);
        ApexPAges.StandardController sc = new ApexPages.StandardController(acc);
        FFC_AddAttachmentsController controller = new FFC_AddAttachmentsController(sc);
        controller.addAttachmentAction();
        controller.attachment.Body = Blob.valueOf('test');
        controller.attachment.Name = 'testFile';
        controller.addAttachmentAction();
        controller.skipAttachmentAction();
    }

}