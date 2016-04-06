@isTest
public class BRC_DA_AttachmentTriggerTest {
    
    static testMethod void test(){
        BRC_DA_Document_For_Approval__c dfa = new BRC_DA_Document_For_Approval__c(Description__c='some desc', Reference_Number__c='111111');
        insert dfa;
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
       	Attachment att = new Attachment(Name='Some Name', parentId=dfa.Id, body=bodyBlob);
        try{
        	insert att;    
            system.assert(false, 'Test must throw exception');
        }catch (Exception e){}
        att.Name = 'final_some Name';
        insert att;
        try{
            delete att;
            system.assert(false, 'Test must throw exception');           
        }catch (Exception e){}
        try{
            update att;
            system.assert(false, 'Test must throw exception');   
        }catch(Exception e){}
    }

}