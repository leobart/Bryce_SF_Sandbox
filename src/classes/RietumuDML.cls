public with sharing class RietumuDML implements RietumuDMLInterface{
	
	public	Rietumu_EL__c getAllowedLink(String companyName){
		List<Rietumu_EL__c> els = 
			[SELECT ticket__c, Company__R.name, Company__R.Id, Rietumu_Password__c, Rietumu_Id__c 
				FROM Rietumu_EL__c 
				WHERE Company__R.name =:companyName];
		if(els.size() != 0) return els[0];		
		return null;
	}
	
	public List<c2g__codaBankAccount__c> getBankAccounts(String companyId){
		return [SELECT id, 
					   name, 
					   c2g__BankAccountCurrency__c, 
					   c2g__BankAccountCurrency__r.Name, 
			           c2g__OwnerCompany__c, 
			           c2g__GeneralLedgerAccount__c 
					FROM c2g__codaBankAccount__c 
        			WHERE c2g__OwnerCompany__c=:companyId
        				AND c2g__BankName__c='Rietumu Banka']; 
	}
	
	public List<c2g__codaBankAccount__c> getBankAccounts(String companyId, String curr){
		return [SELECT Id, Name , 
			              		 c2g__BankAccountCurrency__c, 
			            		 c2g__OwnerCompany__c, 
			             		 c2g__GeneralLedgerAccount__c 
						        FROM c2g__codaBankAccount__c 
						        WHERE c2g__OwnerCompany__c=:companyId
					        	  AND c2g__BankAccountCurrency__r.Name=:curr];	
	}
    
    public c2g__codaBankAccount__c getBankAccount(String bAccId){
        List<c2g__codaBankAccount__c> l = [SELECT Id, Name , 
                                                     c2g__BankAccountCurrency__c, 
                                                     c2g__OwnerCompany__c, 
                                                     c2g__GeneralLedgerAccount__c 
                                            FROM c2g__codaBankAccount__c 
                                            WHERE id=:bAccId];
        if(l.size()>0) return l[0];
        return null;
    }
	
	public String getBankAccountCurrency(String bancAccountId){
		return [SELECT c2g__BankAccountCurrency__r.Name FROM c2g__codaBankAccount__c 
			       WHERE id=:bancAccountId][0].c2g__BankAccountCurrency__r.Name;
	}
		
	public c2g__codaPeriod__c getPeriod(String companyId, Date pDate){
		List<c2g__codaPeriod__c> periods = [SELECT Id, Name 
		 FROM c2g__codaPeriod__c 
		 WHERE c2g__OwnerCompany__c =:companyId
		 	AND c2g__StartDate__c <=:pDate 
		 	AND c2g__EndDate__c >=:pDate ORDER BY c2g__PeriodNumber__c DESC];
		if(periods.size() != 0) return periods[0];
		return null;
	}
	
	public Account getAccount(string accountName){
		List<Account> accounts = [SELECT Id FROM Account WHERE Name=:accountName];
		if(accounts.size() != 0) return accounts[0];
		return null;
	}
	
	public Rietumu_Account_Dictionary__c getDictionary(String benName){
		List<Rietumu_Account_Dictionary__c> dicts = 
			[SELECT account__c 
			 FROM Rietumu_Account_Dictionary__c 
			 WHERE benname__c=:benName];
		if(dicts.size() != 0) return dicts[0];
		return null;
	}
	
	public c2g__codaCashEntry__c getCashEntry(String refId){
		List<c2g__codaCashEntry__c> l = [SELECT Id, Name FROM c2g__codaCashEntry__c WHERE Id=:refId];
		if (l.size() != 0) return l[0];
		return null;
	}
	public void insertSObject(SObject o){
		insert o;
	}
	public List<Rietumu_Transaction__c> getTransactions(String uniqueId){
		return [SELECT Id, name, Cash_Entry__r.Id, Cash_Entry__r.Name FROM Rietumu_Transaction__c WHERE name=:uniqueId];
	}
	public List<Rietumu_Transaction__c> getTransactions(List<String> trnIds){
		return [SELECT Id, name, Cash_Entry__r.Id, Cash_Entry__r.Name FROM Rietumu_Transaction__c WHERE name IN: trnIds];
	}
    
    public c2g__codaGeneralLedgerAccount__c getChargesGLA(String nameGLA){
        List<c2g__codaGeneralLedgerAccount__c> l = [SELECT Id FROM c2g__codaGeneralLedgerAccount__c WHERE name=:nameGLA];
        if(l.size() > 0) return l[0];
        return null;
    }
	

}