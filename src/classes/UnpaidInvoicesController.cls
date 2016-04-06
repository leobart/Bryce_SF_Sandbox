public class UnpaidInvoicesController{
    public List <SelectOption> companies;     
    public string selectedCompany {get;set;}
    public List<c2g__codaInvoice__c> invoices = new List <c2g__codaInvoice__c>();
    public  Map<String,List<cInvoice >> invoicesByAccount {get;set;}
    public Map<String,Decimal> total = new Map<String,Decimal>();
    @TestVisible private String userName = UserInfo.getUserID();
    public Map<String,Map<String,Decimal>> totalsByAccount = new Map<String,Map<String,Decimal>>();
    public String eMessage {get;set;}
    public Boolean showCashManager {get;set;}
    public Boolean selectAll {get;set;}
    // list of invoices groupped by account
    public Map<String,List<cInvoice >> updateInvoicesByAccount(){
        Map<String,List<cInvoice >> invoicesByAccount = new Map <String,List<cInvoice >>();    
        List <c2g__codaInvoice__c> invoices  = new List <c2g__codaInvoice__c>([SELECT c2g__Account__r.Name,c2g__InvoiceStatus__c,c2g__InvoiceDate__c, c2g__OutstandingValue__c, c2g__InvoiceTotal__c, Name, c2g__CustomerReference__c,c2g__InvoiceCurrency__r.Name FROM c2g__codaInvoice__c
            WHERE (c2g__OwnerCompany__r.Name =: selectedCompany AND c2g__PaymentStatus__c!= 'Paid' AND (c2g__InvoiceStatus__c = 'In Progress' OR c2g__InvoiceStatus__c='Complete') AND c2g__InvoiceTotal__c != 0) ORDER BY c2g__InvoiceDate__c]);
        for (c2g__codaInvoice__c i : invoices){
             if (invoicesByAccount.size()==0){
                 invoicesByAccount.put(i.c2g__Account__r.Name,new List<cInvoice > ());
                 invoicesByAccount.get(i.c2g__Account__r.Name).add(new cInvoice(i));
             }else{
                 if (invoicesByAccount.containsKey(i.c2g__Account__r.Name)){
                     invoicesByAccount.get(i.c2g__Account__r.Name).add(new cInvoice(i));
                 }else{
                     invoicesByAccount.put(i.c2g__Account__r.Name,new List<cInvoice > ());
                     invoicesByAccount.get(i.c2g__Account__r.Name).add(new cInvoice(i));
                 }
             }
        }            
        return invoicesByAccount;
    }
    //wrapper class for invoice. Add "Selected" option
    public class cInvoice {
        public c2g__codaInvoice__c inv {get;set;}
        public Boolean selected {get;set;}
        public cInvoice(c2g__codaInvoice__c i){
            inv = i;
            selected = false;
        }
    }
    // totals outstanding groupped by account
    public Map<String,Map<String,Decimal>> getTotalsByAccount (){
        if (invoicesByAccount.size()>0){
        for (String company : invoicesByAccount.keySet()){
            for (cInvoice i : invoicesByAccount.get(company)){
                if (totalsByAccount.containsKey(i.inv.c2g__Account__r.Name)){ // есть ли итого по компании?
                    if (totalsByAccount.get(i.inv.c2g__Account__r.Name).containsKey(i.inv.c2g__InvoiceCurrency__r.Name) == False){ // есть ли  валюта в списке?
                        totalsByAccount.get(i.inv.c2g__Account__r.Name).put(i.inv.c2g__InvoiceCurrency__r.Name,0);
                    }
                    Decimal currentTotal = totalsByAccount.get(i.inv.c2g__Account__r.Name).get(i.inv.c2g__InvoiceCurrency__r.Name);
                    if (i.inv.c2g__InvoiceStatus__c == 'Complete'){
                       totalsByAccount.get(i.inv.c2g__Account__r.Name).put(i.inv.c2g__InvoiceCurrency__r.Name,currentTotal+i.inv.c2g__OutstandingValue__c);
                    }else{
                       totalsByAccount.get(i.inv.c2g__Account__r.Name).put(i.inv.c2g__InvoiceCurrency__r.Name,currentTotal+i.inv.c2g__InvoiceTotal__c);
                    }   
                }else{
                    if (i.inv.c2g__InvoiceStatus__c == 'Complete'){
                            Map <String,Decimal> ci= new Map<String,Decimal>();
                            ci.put(i.inv.c2g__InvoiceCurrency__r.Name,i.inv.c2g__OutstandingValue__c);
                             totalsByAccount.put(i.inv.c2g__Account__r.Name,ci);
                    }else{
                           Map <String,Decimal> ci= new Map<String,Decimal>();
                            ci.put(i.inv.c2g__InvoiceCurrency__r.Name,i.inv.c2g__InvoiceTotal__c);
                            totalsByAccount.put(i.inv.c2g__Account__r.Name,ci);
                    }  
                }       
            }
        }
        }
     return totalsByAccount;
    }
    // total for all the invoices filtered
    public Map<String,Decimal> getTotal(){
          if (totalsByAccount.size()>0){
          for (String comp : totalsByAccount.keySet()){
              for (String cur :  totalsByAccount.get(comp).keySet()){
                  if (total.containsKey(cur)){
                      total.put(cur,total.get(cur)+totalsByAccount.get(comp).get(cur));
                  }else{
                      total.put(cur,totalsByAccount.get(comp).get(cur));
                  }
              }
          }
          }
          //String result = total.format();
          return total;
      }
    //list of user companies
      public List<SelectOption> getCompanies(){
          List <SelectOption> companies = new List <SelectOption>();
          String userName = UserInfo.getName();
          List <c2g__codaUserCompany__c> userCompanies = [SELECT  c2g__Company__r.Name FROM c2g__codaUserCompany__c WHERE c2g__User__r.Name = :userName ];
          for (c2g__codaUserCompany__c c : userCompanies){
                  SelectOption option = new SelectOption(c.c2g__Company__r.Name,c.c2g__Company__r.Name);
                  companies.add(option);
          }
          return companies;
      }
    //updating list of invoices from a new company
      public void up (){
          try{
          if (selectedCompany!=''){
              //invoices.clear();
              //invoicesByAccount.clear();
              //totalsByAccount.clear();
              //total.clear();
              updateInvoicesByAccount();
              getTotalsByAccount ();
              getTotal();
          }
          }catch (Exception e){
              eMessage = e.getMessage();
          }
      }
    // opening clicked invoice
    public PageReference openInvoice(){
        String invoiceInternalNumber = System.CurrentPageReference().getParameters().get('invoiceInternalNumber');
        c2g__codaInvoice__c SIN = [SELECT Id FROM c2g__codaInvoice__c WHERE Name =: invoiceInternalNumber];
        PageReference page = new PageReference ('/'+SIN.Id);
        page.setRedirect(true);
        return page;
    }
    // opening clicked account
    public PageReference openAccount(){
        String accountName = System.CurrentPageReference().getParameters().get('accountToOpenName');
        Account account = [SELECT Id FROM Account WHERE Name =: accountName];
        PageReference page = new PageReference ('/'+account.Id);
        page.setRedirect(true);
        return page;
    }
    
    public void getCashForSelectedInvoices(){
        showCashManager = True;
        List <c2g__codaInvoice__c> selectedInvoices = new List <c2g__codaInvoice__c>();
        for (String comp : invoicesByAccount.keySet()){
            for (cInvoice cInv: invoicesByAccount.get(comp)){
         //    if (cInv.selected == true){
          //      selectedInvoices.add(cInv.inv);
          //   }
            }
        }
        //up();
     //   return null;
    }
    public void toggleSelectAllInvoices(){
        
        String accName = System.CurrentPageReference().getParameters().get('accName');
        Boolean f = invoicesByAccount.get(accName).get(0).selected;
        for (cInvoice i: invoicesByAccount.get(accName)){
            if (f == True){
               i.selected = False;
            }else{
                i.selected = True;
            }
        }
    }
    class proFormaCashEntry{
        Date d ;
        String account;
        String bankAccount;
        Decimal total;
        String cur;
        Decimal charge;
    }
}