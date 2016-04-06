public class BRC_CR_RateConverter {
    public Date rateDate;
    private map<String, Decimal> ratesMap;
    public map<String, String> ratesTable {get; set;}
    
    public BRC_CR_RateConverter(Date rateDate){
        this.rateDate = rateDate;
        ratesMap = new map<String, Decimal>();
        ratesTable  = new map<String, String>();
        list<BRC_CR_Currency_Rate__c> rates = [SELECT Id, Rate__c, currencyIsoCode FROM BRC_CR_Currency_Rate__c WHERE Date__c=: rateDate];
        for(BRC_CR_Currency_Rate__c r : rates){
            ratesMap.put(r.currencyIsoCode, r.Rate__c);
            if(r.currencyIsoCode == 'RUR' || r.currencyIsoCode == 'BYR'){
                ratesTable.put('USD/' + r.currencyIsoCode, (1/r.Rate__c).setScale(2).format());
            }else{
                ratesTable.put(r.currencyIsoCode + '/USD', r.Rate__c.setScale(4).format());                
            }
        }
        ratesMap.put('USD', 1);
    }
    
    
    public Decimal convertValue(String sourceCurr, String destCurrency, Decimal value){
        Decimal sourceToUsdConvertRate  = ratesMap.get(sourceCurr);
        if(sourceToUsdConvertRate == null) return null;
        Decimal sourceToUSD = value * sourceToUsdConvertRate;
        Decimal fromUsdToDestRate = ratesMap.get(destCurrency);
        if(fromUsdToDestRate == null) return null;
        Decimal retVal = sourceToUSD / fromUsdToDestRate;
        return retVal;
    }
    
}