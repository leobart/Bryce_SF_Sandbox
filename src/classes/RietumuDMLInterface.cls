public virtual interface RietumuDMLInterface {
	
	Rietumu_EL__c getAllowedLink(String companyName);
	List<c2g__codaBankAccount__c> getBankAccounts(String companyId);
	List<c2g__codaBankAccount__c> getBankAccounts(String companyId, String curr);
	c2g__codaBankAccount__c getBankAccount(String companyAccId);
	String getBankAccountCurrency(String bancAccountId);
	c2g__codaPeriod__c getPeriod(String companyId, Date pdate);
	Account getAccount(string accountName);
	Rietumu_Account_Dictionary__c getDictionary(String benName);
	c2g__codaCashEntry__c getCashEntry(String Id);
	void insertSObject(SObject o);
	List<Rietumu_Transaction__c> getTransactions(String uniqueId);
	List<Rietumu_Transaction__c> getTransactions(List<String> trnIds);
    c2g__codaGeneralLedgerAccount__c getChargesGLA(String name);
	
}