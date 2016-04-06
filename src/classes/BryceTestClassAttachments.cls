@isTest(SeeAllData=true)
private class BryceTestClassAttachments {
    /*static testMethod void myUpdateCrLiLiItTest() {
        // TO DO: implement unit test
     try{
            List<Credit_Line_Line_Item__c> clli=[SELECT id From Credit_Line_Line_Item__c LIMIT 10];
             
            for (Credit_Line_Line_Item__c sit: clli){
        
                update sit;
            }
            
            for (Credit_Line_Line_Item__c sit: clli){
                delete sit;
            }
        } catch (Exception e) {
            System.debug('ERROR:' + e);
        }
        
        
    }   
    */
    static testMethod void myUpdateAttachmentsTest() {
        // TO DO: implement unit test
    try{    
            List<Attachment> atchs = new List<Attachment>(); //Create empty list of attachments
           
            List<String> stypes= new List<String>();
            stypes.add('Contract');
            stypes.add('Addendum__c');
            stypes.add('c2g__codaPurchaseInvoice__c');
            stypes.add('c2g__codaPayment__c');
            stypes.add('c2g__codaInvoice__c');
            stypes.add('c2g__codaCashEntry__c');
            stypes.add('c2g__codaJournal__c');
            stypes.add('c2g__codaCreditNote__c');
            stypes.add('c2g__codaPurchaseCreditNote__c');
            
            for (String sit: stypes){
                List<Attachment> tempAtch=[SELECT Name From Attachment WHERE parent.TYPE=:sit LIMIT 1];
                if (!tempAtch.isEmpty()){
                    atchs.add(tempAtch[0]);
                }
            }
            
            for (Attachment att: atchs){
                String nnam=att.Name;
                att.Name=nnam+'test';
                update att;
            }
            for (Attachment att: atchs){
                delete att;
            }
        } catch (Exception e){
        system.debug('Error: '+e);
        }
    }
}