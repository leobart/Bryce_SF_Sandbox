public class AttachmentListUpdateController {
    // ApexPages.StandardSetController must be instantiated
    // for standard list controllers
    
    ApexPages.StandardSetController setCon;

    public AttachmentListUpdateController(ApexPages.StandardSetController controller) {
        setCon = controller;
    }
    
    public AttachmentListUpdateController() {
        setCon = null;
    }

    public integer getMySelectedSize() {
        return setCon.getSelected().size();
    }
    public integer getMyRecordsSize() {
        return setCon.getRecords().size();
    }
    
    public PageReference updateMyContracts(){
        List <Contract> tlist=setCon.getSelected();
        for(Contract tob: tlist){
            tob.Attachment_Quantity__c=[SELECT COUNT() FROM Attachment WHERE parentid=:tob.id];
            update tob;
        }
        return null;
    }
    
    public PageReference updateMyAddenda(){
        List <Addendum__c> tlist=setCon.getSelected();
        for(Addendum__c tob: tlist){
            tob.Attachment_Quantity__c=[SELECT COUNT() FROM Attachment WHERE parentid=:tob.id];
            update tob;
        }
        return null;
    }
    
     public PageReference updateMyCashEntries(){
        List <c2g__codaCashEntry__c> tlist=setCon.getSelected();
        for(c2g__codaCashEntry__c tob: tlist){
            tob.Attachment_Quantity__c=[SELECT COUNT() FROM Attachment WHERE parentid=:tob.id];
            update tob;
        }
        return null;
    }
    
    
    public PageReference updateMyInvoices(){
        List <c2g__codaInvoice__c> tlist=setCon.getSelected();
        for(c2g__codaInvoice__c tob: tlist){
            tob.Attachment_Quantity__c=[SELECT COUNT() FROM Attachment WHERE parentid=:tob.id];
            update tob;
        }
        return null;
    }
    
    public PageReference updateMyPInvoices(){
        List <c2g__codaPurchaseInvoice__c> tlist=setCon.getSelected();
        for(c2g__codaPurchaseInvoice__c tob: tlist){
            tob.Attachment_Quantity__c=[SELECT COUNT() FROM Attachment WHERE parentid=:tob.id];
            update tob;
        }
        return null;
    }
    
    public ApexPages.StandardSetController setConInvoice {
        get {
            if(setConInvoice == null) {
                setConInvoice = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [SELECT Id, Name, Attachment_Quantity__c, LastModifiedDate FROM c2g__codaInvoice__c]));
            }
            return setConInvoice;
        }
        set;
    }
    
    public ApexPages.StandardSetController setConPInvoice {
        get {
            if(setConPInvoice == null) {
                setConPInvoice = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [SELECT Id, Name, Attachment_Quantity__c, LastModifiedDate FROM c2g__codaPurchaseInvoice__c]));
            }
            return setConPInvoice;
        }
        set;
    }
    
    public ApexPages.StandardSetController setConPayment {
        get {
            if(setConPayment == null) {
                setConPayment = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [SELECT Id, Name, Attachment_Quantity__c, LastModifiedDate FROM c2g__codaPayment__c]));
            }
            return setConPayment;
        }
        set;
    }
    
    public ApexPages.StandardSetController setConCashEntry {
        get {
            if(setConCashEntry == null) {
                setConCashEntry = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [SELECT Id, Name, Attachment_Quantity__c, LastModifiedDate FROM c2g__codaCashEntry__c LIMIT 10000]));
            }
            return setConCashEntry;
        }
        set;
    }
    
    public ApexPages.StandardSetController setConJournal {
        get {
            if(setConJournal == null) {
                setConJournal = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [SELECT Id, Name, Attachment_Quantity__c, LastModifiedDate FROM c2g__codaJournal__c]));
            }
            return setConJournal;
        }
        set;
    }
    
    public ApexPages.StandardSetController setConCreditNote {
        get {
            if(setConCreditNote == null) {
                setConCreditNote = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [SELECT Id, Name, Attachment_Quantity__c, LastModifiedDate FROM c2g__codaCreditNote__c]));
            }
            return setConCreditNote;
        }
        set;
    }
    
    public ApexPages.StandardSetController setConPCreditNote {
        get {
            if(setConPCreditNote == null) {
                setConPCreditNote = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [SELECT Id, Name, Attachment_Quantity__c, LastModifiedDate FROM c2g__codaPurchaseCreditNote__c]));
            }
            return setConPCreditNote;
        }
        set;
    }
    
    public ApexPages.StandardSetController setConContract {
        get {
            if(setConContract == null) {
                setConContract = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [SELECT Id, Name, Attachment_Quantity__c, LastModifiedDate FROM Contract]));
            }
            return setConContract;
        }
        set;
    }
    
    public ApexPages.StandardSetController setConAddendum {
        get {
            if(setConAddendum == null) {
                setConAddendum = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [SELECT Id, Name, Attachment_Quantity__c, LastModifiedDate FROM Addendum__c]));
            }
            return setConAddendum;
        }
        set;
    }

    // Initialize setCon and return a list of records
    public List<Addendum__c> getAddenda() {
        return (List<Addendum__c>) setConAddendum.getRecords();
    }
    public List<Contract> getContracts() {
        return (List<Contract>) setConContract.getRecords();
    }
    public List<c2g__codaPurchaseInvoice__c> getPurchaseInvoices() {
        return (List<c2g__codaPurchaseInvoice__c>) setConPInvoice.getRecords();
    }
    public List<c2g__codaInvoice__c> getInvoices() {
        return (List<c2g__codaInvoice__c>) setConInvoice.getRecords();
    }
    public List<c2g__codaJournal__c> getJournals() {
        return (List<c2g__codaJournal__c>) setConJournal.getRecords();
    }
    public List<c2g__codaPayment__c> getPayments() {
        return (List<c2g__codaPayment__c>) setConPayment.getRecords();
    }
    public List<c2g__codaCreditNote__c> getCreditNotes() {
        return (List<c2g__codaCreditNote__c>) setConCreditNote.getRecords();
    }
    
    public List<c2g__codaCreditNote__c> getCashEntries() {
        return (List<c2g__codaCreditNote__c>) setConCashEntry.getRecords();
    }
    
    public List<c2g__codaPurchaseCreditNote__c> getPurchaseCreditNotes() {
        return (List<c2g__codaPurchaseCreditNote__c>) setConPCreditNote.getRecords();
    }
    
}