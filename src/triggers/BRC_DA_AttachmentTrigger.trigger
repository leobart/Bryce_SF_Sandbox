//
//			Disable delete, update and insert attachments for BRC_DA_Document_For_Approval__c
//			Author: Leonid Bartenev lbartenev@bryce.ch
//			

trigger BRC_DA_AttachmentTrigger on Attachment (after insert, before update, before delete) {
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            for(Attachment att : trigger.new){
                if (att.parentId.getSobjectType() == BRC_DA_Document_For_Approval__c.SobjectType){
                    BRC_DA_Document_For_Approval__c dfa = [SELECT Id, Locked__c FROM BRC_DA_Document_For_Approval__c WHERE Id=:att.parentId ];
                    if(dfa.Locked__c){
                        att.addError('Operation not allowed. Object Locked');                
                    }else if(!att.Name.contains('final')){
                        att.addError('Operation disabled');                        
                    }              
                }
            }           
        }
    }else{
        if(Trigger.isDelete){
            for(Attachment att : trigger.old){
                if (att.parentId.getSobjectType() == BRC_DA_Document_For_Approval__c.SobjectType){
                	att.addError('Operation Delete Attachment disabled for this object');                
                }
            }                       
        }else if(Trigger.isUpdate){
            for(Attachment att : trigger.new){
                if (att.parentId.getSobjectType() == BRC_DA_Document_For_Approval__c.SobjectType){
                    String[] strs = att.Name.split('_');
                    Boolean opAvailable = false;
                    if(strs.size() > 0){
                        if(strs[0].substring(0,1) == 'v') opAvailable = true;
                    }
                	if(!opAvailable) att.addError('Operation Update Attachment disabled for this object');                
                }
            }                                   
        }
    }
}