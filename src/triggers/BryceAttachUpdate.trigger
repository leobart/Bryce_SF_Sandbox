trigger BryceAttachUpdate on Attachment (after delete, after insert, after undelete, after update) {
                if ((trigger.isInsert)||(trigger.isUndelete)||(trigger.isUpdate)){
                    for (Attachment attch : trigger.new){
                        ID papid=attch.parentid;
                        Schema.SObjectType mytoken = papid.getSObjectType();
                        Schema.DescribeSObjectResult dr = mytoken.getDescribe();
                        String typeName=dr.getName();
                        system.debug(typeName);
                        
                        Integer atq=[select COUNT() FROM Attachment WHERE parentid=:papid];
                        
                   
                        if (typeName == 'Contract') {
                                        Contract papaObj=[SELECT ID, Attachment_Quantity__c From Contract where ID=:papid];
                                        papaObj.Attachment_Quantity__c=atq;
                                        update papaObj;
                        } else if (typeName == 'Addendum__c') {
                                        Addendum__c papaObj=[SELECT ID, Attachment_Quantity__c From Addendum__c where ID=:papid];
                                        papaObj.Attachment_Quantity__c=atq;
                                        update papaObj;
                        } else if (typeName == 'c2g__codaPurchaseInvoice__c') {
                                        c2g__codaPurchaseInvoice__c papaObj=[SELECT ID, Attachment_Quantity__c From c2g__codaPurchaseInvoice__c where ID=:papid];
                                        papaObj.Attachment_Quantity__c=atq;
                                        update papaObj;
                        } else if (typeName == 'c2g__codaPayment__c') {
                                        c2g__codaPayment__c papaObj=[SELECT ID, Attachment_Quantity__c From c2g__codaPayment__c where ID=:papid];
                                        papaObj.Attachment_Quantity__c=atq;
                                        update papaObj;
                        } else if (typeName == 'c2g__codaInvoice__c') {
                                        c2g__codaInvoice__c papaObj=[SELECT ID, Attachment_Quantity__c From c2g__codaInvoice__c where ID=:papid];
                                        papaObj.Attachment_Quantity__c=atq;
                                        update papaObj;
                        } else if (typeName == 'c2g__codaCashEntry__c') {
                                        c2g__codaCashEntry__c papaObj=[SELECT ID, Attachment_Quantity__c From c2g__codaCashEntry__c where ID=:papid];
                                        papaObj.Attachment_Quantity__c=atq;
                                        update papaObj;
                        } else if (typeName == 'c2g__codaJournal__c') {
                                        c2g__codaJournal__c papaObj=[SELECT ID, Attachment_Quantity__c From c2g__codaJournal__c where ID=:papid];
                                        papaObj.Attachment_Quantity__c=atq;
                                        update papaObj;
                        } else if (typeName == 'c2g__codaCreditNote__c') {
                                        c2g__codaCreditNote__c papaObj=[SELECT ID, Attachment_Quantity__c From c2g__codaCreditNote__c where ID=:papid];
                                        papaObj.Attachment_Quantity__c=atq;
                                        update papaObj;
                        } else if (typeName == 'c2g__codaPurchaseCreditNote__c') {
                                        c2g__codaPurchaseCreditNote__c papaObj=[SELECT ID, Attachment_Quantity__c From c2g__codaPurchaseCreditNote__c where ID=:papid];
                                        papaObj.Attachment_Quantity__c=atq;
                                        update papaObj;
                        } else if (typeName == 'BRC_DA_Document_For_Approval__c'){
                                      	BRC_DA_Document_For_Approval__c papaObj=[SELECT ID, Attachment_Quantity__c From BRC_DA_Document_For_Approval__c where ID=:papid];
                                        papaObj.Attachment_Quantity__c=atq;
                            			update papaObj;
                        } else system.debug('No id here found');
                        
                       
                    }
                } else if (trigger.isDelete){
                    for (Attachment attch : trigger.old){
                        ID papid=attch.parentid;
                        Schema.SObjectType mytoken = papid.getSObjectType();
                        Schema.DescribeSObjectResult dr = mytoken.getDescribe();
                        String typeName=dr.getName();
                        system.debug(typeName);
                        
                        Integer atq=[select COUNT() FROM Attachment WHERE parentid=:papid];
                        
                   
                        if (typeName == 'Contract') {
                                        Contract papaObj=[SELECT ID, Attachment_Quantity__c From Contract where ID=:papid];
                                        papaObj.Attachment_Quantity__c=atq;
                                        update papaObj;
                        } else if (typeName == 'Addendum__c') {
                                        Addendum__c papaObj=[SELECT ID, Attachment_Quantity__c From Addendum__c where ID=:papid];
                                        papaObj.Attachment_Quantity__c=atq;
                                        update papaObj;
                        } else if (typeName == 'c2g__codaPurchaseInvoice__c') {
                                        c2g__codaPurchaseInvoice__c papaObj=[SELECT ID, Attachment_Quantity__c From c2g__codaPurchaseInvoice__c where ID=:papid];
                                        papaObj.Attachment_Quantity__c=atq;
                                        update papaObj;
                        } else if (typeName == 'c2g__codaPayment__c') {
                                        c2g__codaPayment__c papaObj=[SELECT ID, Attachment_Quantity__c From c2g__codaPayment__c where ID=:papid];
                                        papaObj.Attachment_Quantity__c=atq;
                                        update papaObj;
                        } else if (typeName == 'c2g__codaInvoice__c') {
                                        c2g__codaInvoice__c papaObj=[SELECT ID, Attachment_Quantity__c From c2g__codaInvoice__c where ID=:papid];
                                        papaObj.Attachment_Quantity__c=atq;
                                        update papaObj;
                        } else if (typeName == 'c2g__codaCashEntry__c') {
                                        c2g__codaCashEntry__c papaObj=[SELECT ID, Attachment_Quantity__c From c2g__codaCashEntry__c where ID=:papid];
                                        papaObj.Attachment_Quantity__c=atq;
                                        update papaObj;
                        } else if (typeName == 'c2g__codaJournal__c') {
                                        c2g__codaJournal__c papaObj=[SELECT ID, Attachment_Quantity__c From c2g__codaJournal__c where ID=:papid];
                                        papaObj.Attachment_Quantity__c=atq;
                                        update papaObj;
                        } else if (typeName == 'c2g__codaCreditNote__c') {
                                        c2g__codaCreditNote__c papaObj=[SELECT ID, Attachment_Quantity__c From c2g__codaCreditNote__c where ID=:papid];
                                        papaObj.Attachment_Quantity__c=atq;
                                        update papaObj;
                        } else if (typeName == 'c2g__codaPurchaseCreditNote__c') {
                                        c2g__codaPurchaseCreditNote__c papaObj=[SELECT ID, Attachment_Quantity__c From c2g__codaPurchaseCreditNote__c where ID=:papid];
                                        papaObj.Attachment_Quantity__c=atq;
                                        update papaObj;
                        }  else if (typeName == 'BRC_DA_Document_For_Approval__c'){
                                      	BRC_DA_Document_For_Approval__c papaObj=[SELECT ID, Attachment_Quantity__c From BRC_DA_Document_For_Approval__c where ID=:papid];
                                        papaObj.Attachment_Quantity__c=atq;
                            			update papaObj;
                        } else system.debug('No id here found');
                        
                    }
                } 
}