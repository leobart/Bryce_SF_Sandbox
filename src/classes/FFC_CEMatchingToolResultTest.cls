@isTest (SeeAllData=true)
public class FFC_CEMatchingToolResultTest{
    
    static private c2g__codaGeneralLedgerAccount__c glaReceivable = [SELECT Id FROM c2g__codaGeneralLedgerAccount__c WHERE Name='1-2200 Accounts receivable control'];
    static private c2g__codaGeneralLedgerAccount__c glaPayable = [SELECT Id FROM c2g__codaGeneralLedgerAccount__c WHERE Name='2-2200 Accounts payable control'];

    static testMethod void test1(){
        Account acc = new Account(Name='Acc1', c2g__CODAAccountsPayableControl__c = glaPayable.Id, c2g__CODAAccountsReceivableControl__c = glaReceivable.Id);
        insert acc;
        System.currentPageReference().getParameters().put('eId', acc.Id);
        System.currentPageReference().getParameters().put('eName', acc.Name);
        FFC_CEMatchingToolResultController controller = new FFC_CEMatchingToolResultController();
        controller.getShowAttachmentTable();
        controller.addAttachmentAction();
    }

}