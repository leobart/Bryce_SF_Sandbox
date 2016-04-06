@isTest
public class BRC_DA_AddDocumentControllerTest {
    static testMethod void test(){
        BRC_DA_Document_For_Approval__c dfa = new BRC_DA_Document_For_Approval__c(Description__c='some desc', Reference_Number__c='111111');
        insert dfa;
        BRC_DA_AddDocumentController controller = new BRC_DA_AddDocumentController(new ApexPages.StandardController(dfa));
        controller.attachment.Name='someName';
        // Null Body
        controller.addAttachmentAction();
 		// With Body       
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        controller.attachment.body = bodyBlob;
        controller.addAttachmentAction();
        // With 1 attachment before
        controller = new BRC_DA_AddDocumentController(new ApexPages.StandardController(dfa));
        controller.attachment.Name='someName';
        controller.attachment.body = bodyBlob;
        controller.addAttachmentAction();
        // With 2 attachment before
        controller = new BRC_DA_AddDocumentController(new ApexPages.StandardController(dfa));
        controller.attachment.Name='someName';
        controller.attachment.body = bodyBlob;
        controller.addAttachmentAction();
        
        controller.cancelAddDocumentAction();
        
        
    }
}