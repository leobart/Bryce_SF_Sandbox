public class FFC_TransactionHelper {
    
    //private c2g__codaTransaction__c trn;
    public c2g__codaTransactionLineItem__c trnAccLine;
    public Decimal accCurrRate;
    public Decimal docCurrRate;
    public String homeCurrId;
    public String accCurrId;
    public String docCurrId;
    
    public FFC_TransactionHelper(String transactionId){
        /*trn = [SELECT 
               Id 
               FROM c2g__codaTransaction__c 
               WHERE Id=:transactionId];*/
        trnAccLine = [SELECT 
                      Id,
                      c2g__AccountCurrency__c,
                      c2g__AccountValue__c,
                      c2g__DocumentCurrency__c,
                      c2g__DocumentValue__c,
                      c2g__HomeCurrency__c,
                      c2g__HomeValue__c
                     FROM c2g__codaTransactionLineItem__c
                     WHERE c2g__Transaction__c=:transactionId AND c2g__LineType__c='Account'][0];
        accCurrRate = trnAccLine.c2g__AccountValue__c.divide(trnAccLine.c2g__HomeValue__c, 9);
        docCurrRate = trnAccLine.c2g__DocumentValue__c.divide(trnAccLine.c2g__HomeValue__c, 9);
        homeCurrId = trnAccLine.c2g__HomeCurrency__c;
        accCurrId = trnAccLine.c2g__AccountCurrency__c;
        docCurrId = trnAccLine.c2g__DocumentCurrency__c;
    }
    

}