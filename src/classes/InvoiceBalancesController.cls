public class InvoiceBalancesController {
    public List <SelectOption> companies;  
    public string selectedCompany {get;set;}
    public List<c2g__codaTransaction__c> transactions = new List <c2g__codaTransaction__c>();
    public  Map<String,List<c2g__codaTransaction__c>> transactionsByAccount = new Map <String,List<c2g__codaTransaction__c>>();
    public Decimal total = 0;
    @TestVisible private String userName = UserInfo.getUserID();
    public Map<String,Decimal> totalsByAccount = new Map<String,Decimal>();
    public Map<String,List<c2g__codaTransaction__c>> getTransactionsByAccount(){
            List <c2g__codaTransaction__c> transactions  = new List <c2g__codaTransaction__c>([SELECT c2g__Account__r.Name,c2g__TransactionDate__c, c2g__AccountOutstandingTotal__c, c2g__AccountTotal__c, c2g__DocumentNumber__c, c2g__DocumentReference__c FROM c2g__codaTransaction__c
            WHERE (c2g__DocumentNumber__c LIKE 'SIN%' AND c2g__OwnerCompany__r.Name =: selectedCompany AND c2g__AccountOutstandingTotal__c >0) ORDER BY c2g__TransactionDate__c]);
            for (c2g__codaTransaction__c t : transactions){
                if (transactionsByAccount.containsKey(t.c2g__Account__r.Name)){
                    transactionsByAccount.get(t.c2g__Account__r.Name).add(t);
                }else{
                    transactionsByAccount.put(t.c2g__Account__r.Name,new List<c2g__codaTransaction__c> {t});
                }
            }            
            return transactionsByAccount;
    }
    public Map<String,Decimal> getTotalsByAccount (){
        for (String company : transactionsByAccount.keySet()){
            for (c2g__codaTransaction__c t : transactionsByAccount.get(company)){
            if (totalsByAccount.containsKey(t.c2g__Account__r.Name)){
                 Decimal currentTotal = totalsByAccount.get(t.c2g__Account__r.Name);
                 totalsByAccount.put(t.c2g__Account__r.Name,currentTotal+t.c2g__AccountOutstandingTotal__c);
            }else{
                totalsByAccount.put(t.c2g__Account__r.Name,t.c2g__AccountOutstandingTotal__c);
            }
            }
         }
         return totalsByAccount;
      }
    public String getTotal(){
          for (Decimal i :  totalsByAccount.values()){
              total+= i;
          }
        	String result = total.format();
          return result;
      }
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
      public void up (){
          if (selectedCompany!=''){
              transactions.clear();
              transactionsByAccount.clear();
              totalsByAccount.clear();
              total = 0;
              getTotalsByAccount ();
              getTotal();
          }
      }
    public PageReference openInvoice(){
        String invoiceInternalNumber = System.CurrentPageReference().getParameters().get('invoiceInternalNumber');
        c2g__codaInvoice__c SIN = [SELECT Id FROM c2g__codaInvoice__c WHERE Name =: invoiceInternalNumber];
        PageReference page = new PageReference ('/'+SIN.Id);
        page.setRedirect(true);
        return page;
    }
    
    public PageReference openAccount(){
        String accountName = System.CurrentPageReference().getParameters().get('accountToOpenName');
        Account account = [SELECT Id FROM Account WHERE Name =: accountName];
        PageReference page = new PageReference ('/'+account.Id);
        page.setRedirect(true);
        return page;
    }
}

//<!-- (1) currency,  (2) sort companies -->