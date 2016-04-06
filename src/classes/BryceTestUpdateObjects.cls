@isTest(SeeAllData=true)
private class BryceTestUpdateObjects {
    
    static testMethod void myTest1() {
        // TO DO: implement unit test
        try{    
            AttachmentListUpdateController MyCon = new AttachmentListUpdateController();
            MyCon.getMySelectedSize();
                
        } catch (Exception e){
        system.debug('Error: '+e);
        }
    }
    
    static testMethod void myTest2() {
        // TO DO: implement unit test
        try{    
            AttachmentListUpdateController MyCon = new AttachmentListUpdateController();
            MyCon.getMyRecordsSize();
        } catch (Exception e){
        system.debug('Error: '+e);
        }
    }
    static testMethod void myTest3() {
        // TO DO: implement unit test
        try{    
            AttachmentListUpdateController MyCon = new AttachmentListUpdateController();
            MyCon.updateMyContracts();
        } catch (Exception e){
        system.debug('Error: '+e);
        }
    }
    static testMethod void myTest4() {
        // TO DO: implement unit test
        try{    
            AttachmentListUpdateController MyCon = new AttachmentListUpdateController();
            MyCon.updateMyAddenda();
        } catch (Exception e){
        system.debug('Error: '+e);
        }
    }
    static testMethod void myTest5() {
        // TO DO: implement unit test
        try{    
            AttachmentListUpdateController MyCon = new AttachmentListUpdateController();
            MyCon.updateMyInvoices();
        } catch (Exception e){
        system.debug('Error: '+e);
        }
    }
    static testMethod void myTest6() {
        // TO DO: implement unit test
        try{    
            AttachmentListUpdateController MyCon = new AttachmentListUpdateController();
            MyCon.updateMyPInvoices();
        } catch (Exception e){
        system.debug('Error: '+e);
        }
    }
    static testMethod void myTest7() {
        // TO DO: implement unit test
        try{    
            AttachmentListUpdateController MyCon = new AttachmentListUpdateController();
           MyCon.getAddenda();
        } catch (Exception e){
        system.debug('Error: '+e);
        }
    }
    static testMethod void myTest8() {
        // TO DO: implement unit test
        try{    
            AttachmentListUpdateController MyCon = new AttachmentListUpdateController();
            MyCon.getContracts();
        } catch (Exception e){
        system.debug('Error: '+e);
        }
    }
    static testMethod void myTest9() {
        // TO DO: implement unit test
        try{    
            AttachmentListUpdateController MyCon = new AttachmentListUpdateController();
            MyCon.getPurchaseCreditNotes();
        } catch (Exception e){
        system.debug('Error: '+e);
        }
    }
    static testMethod void myTest10() {
        // TO DO: implement unit test
        try{    
            AttachmentListUpdateController MyCon = new AttachmentListUpdateController();
            MyCon.getPurchaseInvoices();
        } catch (Exception e){
        system.debug('Error: '+e);
        }
    }
    static testMethod void myTest11() {
        // TO DO: implement unit test
        try{    
            AttachmentListUpdateController MyCon = new AttachmentListUpdateController();
            MyCon.getInvoices();
        } catch (Exception e){
        system.debug('Error: '+e);
        }
    }
    static testMethod void myTest12() {
        // TO DO: implement unit test
        try{    
            AttachmentListUpdateController MyCon = new AttachmentListUpdateController();
            MyCon.getJournals();
        } catch (Exception e){
        system.debug('Error: '+e);
        }
    }
    static testMethod void myTest13() {
        // TO DO: implement unit test
        try{    
            AttachmentListUpdateController MyCon = new AttachmentListUpdateController();
            MyCon.getPayments();
        } catch (Exception e){
        system.debug('Error: '+e);
        }
    }
    static testMethod void myTest14() {
        // TO DO: implement unit test
        try{    
            AttachmentListUpdateController MyCon = new AttachmentListUpdateController();
            MyCon.getCreditNotes();
            
            
        } catch (Exception e){
        system.debug('Error: '+e);
        }
    }
    static testMethod void myTest15() {
        // TO DO: implement unit test
        try{    
            AttachmentListUpdateController MyCon = new AttachmentListUpdateController();
            MyCon.getCashEntries();
        } catch (Exception e){
        system.debug('Error: '+e);
        }
    }
    
}