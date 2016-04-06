// 
// 		Add attachment for object BRC_DA_Document_For_Approval
// 		new attachment with prefix 'final', other attachments with prefix: 'v0', 'v1', 'v2' e.t.c
// 		Author: Leonid Bartenev lbartenev@bryce.ch
// 
public class BRC_DA_AddDocumentController {
    public Attachment attachment {get; set;}
    public String objId {get; set;}
    public String objName {get; set;}
    private Attachment[] docAttachments;
    private Attachment[] finalAttachments;
    public String addAttachmentName{get; set;}    
    
    public BRC_DA_AddDocumentController(ApexPages.StandardController controller){
        attachment = new Attachment();
        BRC_DA_Document_For_Approval__c doc = [SELECT Id, Name FROM BRC_DA_Document_For_Approval__c WHERE Id=:controller.getId()];
        objId = doc.Id;
        objName = doc.Name;
        docAttachments = [SELECT Id, Name FROM Attachment WHERE parentId=:objId AND (NOT Name LIKE 'final_%') ORDER BY Name DESC];
        finalAttachments = [SELECT Id, Name FROM Attachment WHERE parentId=:objId AND Name LIKE 'final_%'];
        if(docAttachments.size() + finalAttachments.size() == 0){
            addAttachmentName = 'Create New Document';
        }else{
            addAttachmentName = 'Change Document';
        }
    }
    
    
    public PageReference addAttachmentAction(){
        try{
            attachment.ParentId = objId;
            if(attachment.Body == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Choose file before press Add button'));   
                return null;
            }
            String indStr;
            if(docAttachments.size() != 0){
                String[] words = docAttachments[0].Name.split('_');
                if(words.size() > 0){
                    Integer ind = Integer.valueOf(WORDS[0].subString(1));
                    ind++;
                    indStr = 'v' + ind;                    
                } 
            }else{
                indStr = 'v0';
            }
            if(finalAttachments.size() != 0){
                String subName = finalAttachments[0].name.subString(6);
                finalAttachments[0].Name = indStr + '_' + subName;
                update finalAttachments;
            }
            attachment.Name = 'final_' + attachment.Name;
            insert attachment;  
            attachment.Name = 'final_' + attachment.Name;
            return new PageReference('/' + objId);  
        }catch(Exception e){
		    ApexPages.addMessages(e);           	
        }
        return null;
    }
    
    public PageReference cancelAddDocumentAction(){
    	return new PageReference('/' + objId);          
    }

}