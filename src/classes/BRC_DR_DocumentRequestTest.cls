@isTest
public class BRC_DR_DocumentRequestTest {

    static testMethod void test(){
        BRC_DR_Pattern__c p = new BRC_DR_Pattern__c(Name='Pattern name');
        insert p;
        BRC_DRP_Line_Item__c line1 = new BRC_DRP_Line_Item__c(Document_Request_Pattern__c=p.id, Type__c='Price', Line_Number__c=1); 
        insert line1;
        BRC_DRP_Line_Item__c line2 = new BRC_DRP_Line_Item__c(Document_Request_Pattern__c=p.id, Type__c='Number', Line_Number__c=2); 
        insert line2;
        Test.startTest();
        //BRC_DR_Document_Request__c req = new BRC_DR_Document_Request__c(Document_Request_Pattern__c=p.id, Due_Date__c=Date.today(), Department__c = 'Geneva', Status__c='Init');
        ApexPAges.StandardController sc = new ApexPages.StandardController(new BRC_DR_Document_Request__c());
        BRC_DR_DocumentRequestController controller = new BRC_DR_DocumentRequestController(sc);
        controller.dr.Document_Request_Pattern__c = p.Id;
        controller.dr.Department__c = 'Geneva';
        controller.dr.Status__c = 'Init';
        controller.dr.Due_Date__c = Date.today();
        
        controller.prepareRquestLines();
        controller.saveAction();
        controller.updateAction();
        controller.discardAction();
        controller.cancelAction();
        
        sc = new ApexPages.StandardController(controller.dr);
        controller = new BRC_DR_DocumentRequestController(sc);
        
        controller.dr.Approved__c = true;
        update controller.dr;
        
        BRC_DA_Document_For_Approval__c dfa = new BRC_DA_Document_For_Approval__c(Reference_Number__c = '11111111', Document_Request__c=controller.dr.Id, Approved__c = false);
        insert dfa;
        dfa.Approved__c = true;
        update dfa;
    }
}