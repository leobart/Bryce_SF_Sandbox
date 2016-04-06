public class FFC_CashEntryDetailController {
    
    public FFC_CurrencyRatesManager crManager {get; set;}
    public c2g__codaCashEntry__c csh {get; set;}
    public c2g__codaCashEntryLineItem__c cshItem {get; set;}
    
    public void updateRates(){
        String bCurr = [SELECT c2g__BankAccountCurrency__r.Name FROM c2g__codaBankAccount__c WHERE Id =: csh.c2g__BankAccount__c].c2g__BankAccountCurrency__r.Name;
        crManager.updateB(null, bCurr, cshItem.c2g__CashEntryValue__c, csh.c2g__Date__c);
        crManager.updateRates();
    }

}