// Helenic Bank statement for some period, account number and currency.
// This class initialased with data as a string. This string must contain all statement data.
// Author Leonid Bartenev barteneff@gmail.com

public class BRC_HB_Statement {
    
    public String datesInterval {get; set;}
    public String bankAccountNumber {get; set;}
    public String currencyCode {get; set;}
    public c2g__codaBankAccount__c bankAccount {get; set;}
    
    public List<BRC_HB_TransactionLine> transactions {get; set;}
    public Map<String, BRC_HB_TransactionLine> transactionsMap {get; set;}
    
    public class BRC_HB_Exception extends Exception{}
    
    public BRC_HB_Statement(String data){
        String[] rows = data.split('\n');
        transactions = new List<BRC_HB_TransactionLine>();
        for(String row : rows){
            row = row.trim();
            if(row.length() > 0){
                transactions.add(new BRC_HB_TransactionLine(row));
            }
        }
        if(transactions.size() > 0){
            datesInterval = transactions[0].datesInterval;
            bankAccountNumber = transactions[0].bankAccountNumber;
            currencyCode = transactions[0].currencyCode;
        }
        
        c2g__codaBankAccount__c[] bankAccList = [SELECT Id, Name, c2g__OwnerCompany__r.Id, c2g__OwnerCompany__r.Name 
                                                 FROM c2g__codaBankAccount__c 
                                                 WHERE c2g__AccountNumber__c =: bankAccountNumber];
        if(bankAccList.size() > 0) bankAccount = bankAccList[0];
		prepareTransactions();
    } 
    
    private void prepareTransactions(){
        transactionsMap = new Map<String, BRC_HB_TransactionLine>();
        List<BRC_HB_TransactionLine> trnList = new List<BRC_HB_TransactionLine>();
        for(BRC_HB_TransactionLine tline : transactions){
            BRC_HB_TransactionLine tLineFromMap = transactionsMap.get(tLine.uniqueId);
            if(tLineFromMap != null){
                tLineFromMap.charge = tLine.value;
                tLineFromMap.debit += tLine.debit; 
                tLineFromMap.balance = tLine.balance;
            }else{
                tLine.bankAccount = bankAccount;
                transactionsMap.put(tLine.uniqueId, tLine);
                trnList.add(tLine);
            }
        }
        transactions = trnList;
        loadCashEntriesForTrn();
    }
    
    public void loadCashEntriesForTrn(){
        Set<String> uniqueIds = transactionsMap.keySet();
        Rietumu_Transaction__c[] bankTrnList = [SELECT 
                                            	Cash_Entry__c, 
                                             	Cash_Entry__r.Id,
                                             	Cash_Entry__r.Name,
                                             	Cash_Entry__r.c2g__Transaction__r.c2g__AccountOutstandingTotal__c,
                                            	Unique_Id__c 
                                            FROM Rietumu_Transaction__c 
                                            WHERE Unique_Id__c IN: uniqueIds];
        for(Rietumu_Transaction__c bankTrn : bankTrnList){
            BRC_HB_TransactionLine tLine =  transactionsMap.get(bankTrn.Unique_Id__c);
            tLine.cashEntry = bankTrn.Cash_Entry__r;
        }
        
    }
}