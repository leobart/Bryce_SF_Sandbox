public class tabbedAccountExtension{
    private List <String> companies {get{
          List <String> companies = new List <String>();
          String userName = UserInfo.getName();
          List <c2g__codaUserCompany__c> userCompanies = [SELECT  c2g__Company__r.Name FROM c2g__codaUserCompany__c WHERE c2g__User__r.Name = :userName ];
          for (c2g__codaUserCompany__c c : userCompanies){
                  companies.add(c.c2g__Company__r.Name);
          }
          return companies;
    }}
    public final Account acct{get;set;}
    public Boolean isAdmin;
    public List<Attachment> accountAttachments{get;set;}
    public Integer counter {get;set;}
    public Integer counterInvoices {get;set;}
    public Integer list_size {get;set;}
    public integer total_size_contracts{get;private set;}
    public integer total_size_SINs{get;set;}
    public Integer AddendaQty;
    public List<contractsAndAddendum> contractsAndAddendumsList {set;}
    public Map<String,Boolean> hasAttachment {get;set;}
    public Map<String,String> attachmentMap  {get;set;}
    public Map<String,Boolean> hasAddendum {get;set;}
    public Map<String,Boolean> SINhasAttachment {get;set;}
    public Map<String,String> SINattachmentMap  {get;set;}
    public List<c2g__codaInvoice__c> sin {get{
        List<c2g__codaInvoice__c> salesinvoices= new List<c2g__codaInvoice__c>();
        salesinvoices = [SELECT Name,
                ID, 
                c2g__CustomerReference__c,
                c2g__InvoiceCurrency__c,
                c2g__InvoiceDate__c,
                c2g__InvoiceStatus__c,
                c2g__InvoiceTotal__c,
                c2g__OutstandingValue__c,c2g__InvoiceDescription__c,
                (SELECT ID, c2g__Product__r.Name FROM c2g__InvoiceLineItems__r)
                FROM c2g__codaInvoice__c 
                WHERE c2g__Account__r.ID =:acct.ID
                ORDER BY c2g__CustomerReference__c, c2g__InvoiceDate__c
                LIMIT :list_size
                OFFSET :counterInvoices
                ];
        for (c2g__codaInvoice__c inv: salesinvoices){
            SINhasAttachment.put(inv.ID,False);
        }
        List<Attachment> attachments = [Select ID, parentID From Attachment Where ParentID =:SINhasAttachment.keySet()];
        for (Attachment att: attachments){
            SINattachmentMap.put(att.parentID, att.ID);
            SINhasAttachment.put(att.parentID, True);
        }
        return salesinvoices;
        }}
    

    
    
    public Boolean SINDisabledNext;
    public Boolean SINDisabledBack;
    public Boolean getIsAdmin(){
        String i = UserInfo.getUserRoleId();
        UserRole ur = [SELECT Name FROM UserRole WHERE ID =:i];
        if (ur.Name == 'FF System Head'){
            return True;
        }else{
            return False;
        }
    }
    public List<Contract> AccountContracts{get{
        List<Contract> AccountContracts = [ SELECT  ID,Name, ContractNumber, Our_company__r.Name, StartDate, EndDate, (SELECT Name,ID,Addendum_date__c,Contract_Number__r.ID FROM Addenda__r) FROM Contract WHERE (Account.Name =:acct.Name AND Our_company__r.Name IN:companies) ORDER BY Our_company__r.Name,StartDate,Name LIMIT :list_size OFFSET:counter];
        total_size_contracts = [ SELECT  count() FROM Contract WHERE Account.Name =:acct.Name];
        return AccountContracts;
    }}
    public PageReference Beginnning(){ // clicked 'to the beginning'
        counter = 0;
        return null;
    }
    public PageReference Back10(){ // clicked '10 contracts back'
        counter -= list_size;
        return null;
    }
    public PageReference End(){
        counter = total_size_contracts - math.mod(total_size_contracts,list_size);
        return null;
    }
    public PageReference Next10(){ // clicked '10 contracts forward'
        counter +=list_size;
        return null;
    }
    public Boolean getDisabledBack(){ // at the begining
        if (counter>0) {
        return True;}else{ return False;}
    }
    public Boolean getDisabledNext(){ // at the end
        if ((counter+list_size)<total_size_contracts){
         return True;}
         else{ return False;}
    }
    
    //Controller constructor
    public tabbedAccountExtension(ApexPages.StandardController stController){
        this.acct = (Account)stController.getRecord();
        attachmentMap = new Map<String,String>();
        hasAttachment = new Map<String,Boolean>();
        hasAddendum = new Map<String,Boolean>();
        SINattachmentMap = new Map<String,String>();
        SINhasAttachment = new Map<String,Boolean>();
        accountAttachments = [Select ID, Name From Attachment Where ParentID =:acct.ID];     
        counter = 0;
        list_size= 10;
        counterInvoices = 0;        
        total_size_SINs = [SELECT count() FROM c2g__codaInvoice__c WHERE c2g__Account__r.ID =:acct.ID];

        }
        
     
     
     public List<contractsAndAddendum> getcontractsAndAddendumsList(){
        List<contractsAndAddendum> contractsAndAddendumsList = new List<contractsAndAddendum>();
        List<String> contractsAndAddendaIDs = new List<String>();
        for (Contract c: AccountContracts){
            contractsAndAddendaIDs.add(c.ID);
            contractsAndAddendumsList.add(new contractsAndAddendum(c,c));
            hasAttachment.put(c.ID,False);
            hasAddendum.put(c.ID,False);
            for (Addendum__c a: c.Addenda__r){
                contractsAndAddendaIDs.add(a.ID);
                contractsAndAddendumsList.add(new contractsAndAddendum(a,c));
                hasAttachment.put(a.ID,False);
                hasAddendum.put(c.ID,True);
            }
        }
        List<Attachment> attachments = [Select ID, parentID From Attachment Where ParentID IN:contractsAndAddendaIDs];
        for (Attachment a: attachments){
           attachmentMap.put(a.parentID,a.ID);
           hasAttachment.put(a.parentID,True);
        }
       return contractsAndAddendumsList;
    }
    public PageReference openContract(){
        String contractN = System.CurrentPageReference().getParameters().get('contractNumber');
        PageReference page = new PageReference ('/'+contractN);
        page.setRedirect(true);
        return page;   
    }
    public PageReference viewAttachedContract(){
        String contractID = System.CurrentPageReference().getParameters().get('contractToView');
        PageReference page = new pageReference('/servlet/servlet.FileDownload?file='+contractID);
        return page;
              
    }
    public class contractsAndAddendum{
        public String ID{get;set;}
        public String Name{get;set;}
        public String objectType{get;set;}
        Public String ourCompany{get;set;}
        public Date startDate{get;set;}
        public DateTime EndDate;
        public String contractID{get;set;}
        public contractsAndAddendum(sObject obj, Contract obj2){
            ID = String.ValueOf(obj.get('ID'));
            Name = String.valueof(obj.get('Name'));
            ourCompany = obj2.Our_company__r.Name;
            if (obj.getSObjectType() == Contract.sObjectType){
                objectType = 'Contract';
                contractID = String.valueof(obj.get('ID'));
                startDate = Date.valueOf(obj.get('StartDate'));
            }else{
                objectType = 'Addendum';
                contractID = obj2.ID;
                startDate = Date.valueOf(obj.get('Addendum_date__c'));
            }
        }
    }
    
   public PageReference SINBegining(){ // clicked 'to the'
        counterInvoices = 0;
        return null;
    }
    public PageReference previousSINvoicePage(){ // clicked '10 SINs back'
        counterInvoices -= list_size;
        return null;
    }
    public PageReference SINEnd(){
        counterInvoices = total_size_SINs - math.mod(total_size_SINs,list_size);
        return null;
    }
    public PageReference nextSINPage(){ // clicked '10 SINs forward'
        counterInvoices +=list_size;
        return null;
    }
    public Boolean getSINDisabledBack(){ // at the begining
        if (counterInvoices>0) {
        return true;}
        else{ return false;}
    }
    public Boolean getSINDisabledNext(){ // at the end
        if ((counterInvoices+list_size)<total_size_SINs){
         return true;}
         else{ return false;}
    }

}