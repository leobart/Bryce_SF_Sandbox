public class FFC_CEMatchingToolResultController{
    
    public Attachment attachment {get; set;} 
    public List<Attachment> attList {get; set;}
    public String entityName {get; set;}
    public String entityId {get; set;}

    public FFC_CEMatchingToolResultController(){
        entityId = ApexPages.currentPage().getParameters().get('eId');
        entityName = ApexPages.currentPage().getParameters().get('eName');
        attachment = new Attachment(); 
        updateAttList();
    }
    
    public boolean getShowAttachmentTable(){
        return attList.Size() > 0;
    }
    
    public void addAttachmentAction(){
        try{
            attachment.ParentId = entityId;
            insert attachment;  
            updateAttList();
        }catch(Exception e){
		    ApexPages.addMessages(e);           	
        }
    }
    
    private void updateAttList(){
        attList = [SELECT Id, Name From Attachment WHERE ParentId=:entityId];        
    }
            
}