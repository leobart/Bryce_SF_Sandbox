public class BankBalancesController{
	public List <SelectOption> companies;  
    public string selectedCompany {get;set;}
    public List <SelectOption> allBankAccounts;
    public string selectedBankAccount {get;set;}
    public List <bankTransaction> bankTransactions{get{
        List <c2g__codaTransactionLineItem__c> transactions = [SELECT  
                                                   c2g__Account__r.Name, 
                                                   c2g__Transaction__r.c2g__TransactionDate__c, 
                                                   c2g__Transaction__r.c2g__DocumentDescription__c, 
                                                   c2g__DocumentValue__c 
                                                   FROM c2g__codaTransactionLineItem__c
                                                  WHERE (c2g__Transaction__r.c2g__TransactionDate__c >=: fromDate AND c2g__Transaction__r.c2g__TransactionDate__c <=:toDate)
                                                  ];
        
    	
        return bankTransactions;
    }set;}
    public Date fromDate {get;set;}
    public Date toDate {get;set;}
    public Map <Date,Decimal> dataSet {get{
        Map <Date,Decimal> dataSet = new Map <Date, Decimal>();
        return dataSet;
    }set;}
    
    public class bankTransaction{
        public String Name {get;set;}
        public String account {get;set;}
        public Date Trdate {get;set;}
        public String description {get;set;}
        public Decimal trValue {get;set;} 
        public Decimal balance {get;set;}
        public bankTransaction (c2g__codaTransactionLineItem__c tli, Decimal prevBalance) {
            account = tli.c2g__Transaction__r.c2g__Account__r.Name;
            Trdate = tli.c2g__Transaction__r.c2g__TransactionDate__c;
            description = tli.c2g__Transaction__r.c2g__DocumentDescription__c;
        	trValue = tli.c2g__DocumentValue__c;
        	balance = prevBalance + trValue;
        }
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
    
    public List<SelectOption> getallBankAccounts(){
       	List <SelectOption> allBankAccounts = new List <SelectOption>();
        if (selectedCompany <> Null){
        	List <c2g__codaBankAccount__c> bankAccounts = [SELECT Name FROM c2g__codaBankAccount__c WHERE c2g__OwnerCompany__r.Name =: selectedCompany];  	
            for (c2g__codaBankAccount__c ba : bankAccounts){
                SelectOption option = new SelectOption(ba.Name,ba.Name);
            	allBankAccounts.add(option);
            }
        }
        return allBankAccounts;
    }
}