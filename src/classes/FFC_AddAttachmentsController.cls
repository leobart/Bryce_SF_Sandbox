public class FFC_AddAttachmentsController{
    
    public Attachment attachment {get; set;}
    public String objId {get; set;}
    public String objName {get; set;}
    
    public FFC_AddAttachmentsController(ApexPages.StandardController controller){
        attachment = new Attachment();
        objId = ApexPages.currentPage().getParameters().get('objId');
        objName = ApexPages.currentPage().getParameters().get('objName');
    }
    
    public PageReference addAttachmentAction(){
        try{
            attachment.ParentId = objId;
            if(attachment.Body == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Choose file before press Add button'));   
                return null;
            }
            insert attachment;  
            return new PageReference('/' + objId);  
        }catch(Exception e){
		    ApexPages.addMessages(e);           	
        }
        return null;
    }
    
    public PageReference skipAttachmentAction(){
    	return new PageReference('/' + objId);          
    }
    
}