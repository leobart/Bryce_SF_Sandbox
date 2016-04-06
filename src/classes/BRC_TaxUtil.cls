public class BRC_TaxUtil{
    
    public static Decimal getTaxRate(String taxId, Date targetDate){
        if(taxId == null) return null;
		c2g__codaTaxRate__c[] taxRates = [SELECT Id, c2g__Rate__c FROM c2g__codaTaxRate__c 
                                          WHERE c2g__TaxCode__c=:taxId 
                                          AND c2g__StartDate__c<=:targetDate 
                                          ORDER BY c2g__StartDate__c DESC];
        if(taxRates.size() > 0) return taxRates[0].c2g__Rate__c;
        return null;
    }
    
}