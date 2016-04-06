public class CCDragAndDropController{
    public List<Attachment> objectAttachments{get{return [Select ID, Name From Attachment Where ParentID =:currentObjectID];}set;}
    public String currentObjectID {get;set;}
    public String errorMessage {get;set;}
    public void refreshAttachments(){
        objectAttachments = [Select ID, Name From Attachment Where ParentID =:currentObjectID];
    }
    public PageReference viewAttachment(){
        String attachmentID = System.CurrentPageReference().getParameters().get('attachmentToView');
        PageReference page = new pageReference('/servlet/servlet.FileDownload?file='+attachmentID);
        return page;
    }
    @RemoteAction
    public static Boolean handleUpload(String acct,String fileName,String file){
        Attachment newAttachment = new Attachment();
        newAttachment.parentID = acct;
        newAttachment.Name = fileName;
        Blob body;
        body = Blob.valueof(file);
        newAttachment.Body = body;
        newAttachment.IsPrivate = False;
        insert newAttachment;
        return True;
    }
    @RemoteAction
    public static Boolean deleteAttachment(String attachmentID){
        List <Attachment> attachment = [Select ID from Attachment where ID =:attachmentID];
        try{
            delete attachment.get(0);
            return True;
        }catch (DmlException e){
            
            return false;
        }
    }
}