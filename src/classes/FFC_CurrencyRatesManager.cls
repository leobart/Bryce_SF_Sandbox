public class FFC_CurrencyRatesManager {

    private static Map<String, Boolean> currencyInevtionMap = new Map<String, Boolean>{'EUR' => true, 'GBP' => true};
    
    public class RateLine{
        
        public c2g__codaExchangeRate__c rate {get; set;} 
        public Boolean editable {get; set;}
        public String name {get; set;}
        public String rateName {get; set;}
        private FFC_CurrencyRatesManager crManager;
        private RateLine targetRate;
        
        public RateLine(FFC_CurrencyRatesManager crManager, String name, Boolean editable, String rateName, Decimal rateValue, Rateline tRate){ 
            this.crManager = crManager;
            this.rate = new c2g__codaExchangeRate__c(c2g__Rate__c = rateValue);
            this.editable = editable;
            this.name = name;
            this.rateName = rateName;
            this.targetRate = tRate;
            invertRate();
            updateRateByTargetRate();
        }
        
        public void updateRateByTargetRate(){
            if(targetRate != null){
                if(crManager.constantSide == 'A'){
                	this.rate.c2g__Rate__c = (crManager.valueB * targetRate.getRateValue()).divide(crManager.valueA, 9);  
                    invertRate();
                }else if (crManager.constantSide == 'B'){                  
                	this.rate.c2g__Rate__c = (crManager.valueA * targetRate.getRateValue()).divide(crManager.valueB, 9); 
                    invertRate();
                }        	
            }
        }
        
        public String getFullRateName(){
            if(isInverted()){
                return rateName + '/' + crManager.homeCurr;
            }
            return crManager.homeCurr + '/' + rateName;
        }
        
        public boolean isInverted(){
            Boolean inverted = currencyInevtionMap.get(rateName);
            if(inverted != null) return inverted;
            return false;
        }
        
        public void invertRate(){
            if(rate.c2g__Rate__c == 0) return;
            Decimal d = 1;
            if(isInverted()){
                rate.c2g__Rate__c = d.divide(rate.c2g__Rate__c, 9);
            }
        }
        
        //Return salesforce rate value in format (home_curr/not_home_curr)
        public Decimal getRateValue(){
            Decimal d = 1;
            if(isInverted()){
                return d.divide(rate.c2g__Rate__c, 9);
            }
            return rate.c2g__Rate__c;
        }
    }
    
    public Map<String, RateLine> ratesMap {get; set;}
    
    public String companyId {get; set;}
    public String homeCurr {get; set;}
    public String accCurr {get; set;}
    public String docACurr {get; set;}
    public String docBCurr {get; set;}
    public Decimal valueA {get; set;}
    public Decimal valueB {get; set;}
    public FFC_TransactionHelper thA {get; set;}
    public FFC_TransactionHelper thB {get; set;}
    public Date dateA {get; set;}
    public Date dateB {get; set;}
    
    private Map<String, c2g__codaExchangeRate__c> exchangeRatesMap;
    private String constantSide;
    
    public FFC_CurrencyRatesManager(String accCurr){
        ratesMap = new Map<String, RateLine>();
        this.accCurr = accCurr;
        String companyName = c2g.CODAAPICompany_2_0.GetCurrentCompanies(null)[0];
        companyId = [SELECT Id FROM c2g__codaCompany__c WHERE Name=:companyName][0].Id;
        homeCurr = getHomeCurrency();
    }
    
    public void updateA(FFC_TransactionHelper thA, String docACurr, Decimal valueA, Date dateA){
        this.docACurr = docACurr;
        this.thA = thA;                        
        this.valueA = valueA;
        this.dateA = dateA;
    }
    
    public void updateB(FFC_TransactionHelper thB, String docBCurr, Decimal valueB, Date dateB){
        this.docBCurr = docBCurr;
        this.thB = thB;                        
        this.valueB = valueB;
        this.dateB = dateB;
    }
    
    public void updateRates(){
                                
        ratesMap = new Map<String, RateLine>();
        RateLine rLine, targetRateLine;
        constantSide = 'AB';
        if(thA == null && thB == null){ 
            constantSide = 'A';
            if(accCurr != homeCurr){
                ratesMap.put(accCurr, new RateLine(this, 'Account Currency', true, accCurr, getRateFromTable(accCurr, dateA), null));
            }
            if(docACurr != docBCurr){
                targetRateLine = ratesMap.get(docACurr);
                if(targetRateLine == null){
                    if(docACurr != homeCurr){
                        if(docBCurr != homeCurr){
                            targetRateLine = new RateLine(this, 'Document Currency A', true, docACurr, getRateFromTable(docACurr, dateA), null);
                        }else{
                            targetRateLine = new RateLine(this, 'Document Currency A', false, docACurr, valueA.divide(valueB, 9), null);
                        }
                        ratesMap.put(docACurr, targetRateLine);
                    }              
                }else{
                    targetRateLine.Name = targetRateLine.Name + ', Document Currency A';
                    if(docBCurr == homeCurr){
                        targetRateLine.editable = false;
                        targetRateLine.rate.c2g__Rate__c = valueA.divide(valueB, 9);
                    }
                }
                rLine = ratesMap.get(docBCurr);
                if(rline == null){ 
                    if(docBCurr != homeCurr){
                        if(docACurr != homeCurr){
                            rLine = new RateLine(this, 'Document Currency B', false, docBCurr, 0, targetRateLine);
                        }else{
                            rLine = new RateLine(this, 'Document Currency B', false, docBCurr, valueB.divide(valueA, 9), null);
                        }
                        ratesMap.put(docBCurr, rline);
                    }
                    
                }else{
                    rLine.Name = rLine.Name + ', Document Currency B';
                    rLine.editable = false;
                    if(docACurr != homeCurr){
                        rLine.targetRate = targetRateLine;
                        rLine.updateRateByTargetRate();                       
                    }else{
                        rLine.rate.c2g__Rate__c = valueB.divide(valueA, 9);
                    }
                }               
            }else{
                rLine = ratesMap.get(docACurr);
                if(rLine == null){
                    if(docACurr != homeCurr) ratesMap.put(docACurr, new RateLine(this, 'Document Currency A & B', true, docACurr, getRateFromTable(docACurr, dateA), null));
                }else{
                    rLine.Name = rLine.Name + ', Document Currency A & B';
                }              
            }
            //1----------------------------------------------------------------------------------------------------------------------------------------
        }else if(thA != null && thB == null){
            constantSide = 'A';
            if(accCurr != homeCurr){
                ratesMap.put(accCurr, new RateLine(this, 'Account Currency', false, accCurr, thA.accCurrRate, null));
            }
            if(docACurr != docBCurr){
                targetRateLine = ratesMap.get(docACurr);
                if(targetRateLine == null){
                    if(docACurr != homeCurr) {
                        targetRateLine = new RateLine(this, 'Document Currency A', false, docACurr, thA.docCurrRate, null);
                        ratesMap.put(docACurr, targetRateLine);
                    }                  
                }else{
                    targetRateLine.Name = targetRateLine.Name + ', Document Currency A';
                }
                rLine = ratesMap.get(docBCurr);
                if(rline == null){
                    if(docBCurr != homeCurr){
                        if(docACurr != homeCurr){
                            ratesMap.put(docBCurr, new RateLine(this, 'Document Currency B', false, docBCurr, 0, targetRateLine));
                        }else{
                            ratesMap.put(docBCurr, new RateLine(this, 'Document Currency B', false, docBCurr, valueB.divide(valueA, 9), null));
                        }
                    } 
                }else{
                    rLine.Name = rLine.Name + ', Document Currency B';
                    rLine.editable = false;
                    rLine.targetRate = targetRateLine;
                    rLine.updateRateByTargetRate();
                }               
            }else{
                rLine = ratesMap.get(docACurr);
                if(rLine == null){
                    if(docACurr != homeCurr) ratesMap.put(docACurr, new RateLine(this,'Document Currency A & B', false, docACurr, thA.docCurrRate, null));
                }else{
                    rLine.Name = rLine.Name + ', Document Currency A & B';
                }              
            }           
            //2----------------------------------------------------------------------------------------------------------------------------------------
        }else if(thA == null && thB != null){
            constantSide = 'B';
            if(accCurr != homeCurr){
                ratesMap.put(accCurr, new RateLine(this, 'Account Currency', false, accCurr, thB.accCurrRate, null));
            }
            if(docACurr != docBCurr){
                targetRateLine = ratesMap.get(docBCurr);
                if(targetRateLine == null){
                    if(docBCurr != homeCurr){
                        targetRateLine = new RateLine(this, 'Document Currency B', false, docBCurr, thB.docCurrRate, null);
                        ratesMap.put(docBCurr, targetRateLine);
                    }                  
                }else{
                    targetRateLine.Name = targetRateLine.Name + ', Document Currency B';
                }
                rLine = ratesMap.get(docACurr);
                if(rline == null){
                    if(docACurr != homeCurr){
                        if(docBCurr != homeCurr){
                            ratesMap.put(docACurr, new RateLine(this, 'Document Currency A', false, docACurr, 0, targetRateLine));
                        }else{
                            ratesMap.put(docACurr, new RateLine(this, 'Document Currency A', false, docACurr, valueA.divide(valueB, 9), null));
                        }
                    }
                    
                }else{
                    rLine.Name = rLine.Name + ', Document Currency A';
                    rLine.editable = false;
                    rLine.targetRate = targetRateLine;
                    rLine.updateRateByTargetRate();
                }               
            }else{
                rLine = ratesMap.get(docACurr);
                if(rLine == null){
                    system.debug('thB: ' + thb);
                    if(docACurr != homeCurr) ratesMap.put(docBCurr, new RateLine(this, 'Document Currency A & B', false, docBCurr, thB.docCurrRate, null));
                }else{
                    rLine.Name = rLine.Name + ', Document Currency A & B';
                }              
            }           
        }
    }
    
    public boolean getShowCurrencyRatesBlock(){
        return ratesMap.size() > 0;
    }
    
    public void recalculateRates(){
        //recalculate dependency rates
        for(String isoCode : ratesMap.keyset()){
            RateLine rLine = ratesMap.get(isoCode);
            rLine.updateRateByTargetRate();
        }
    }
    
    
    private String getHomeCurrency(){
    	c2g__codaAccountingCurrency__c[] cList = [SELECT Id, Name 
                                             FROM c2g__codaAccountingCurrency__c 
                                             WHERE c2g__OwnerCompany__c =: companyId AND c2g__Home__c =: true]; 
		return cList[0].Name;    
    }
    
    public void insertRates(String side){
        exchangeRatesMap = new Map<String, c2g__codaExchangeRate__c>();
        for(RateLine rl : ratesMap.values()){
            if(side.containsIgnoreCase('A')){
            	createRate(rl.rateName, rl.getRateValue(), dateA);    
            }
            if(side.containsIgnoreCase('B')){
                createRate(rl.rateName, rl.getRateValue(), dateB); 
            }      
        }                            
    }
        
    public void deleteRates(){
        delete exchangeRatesMap.values();               
    }
    
    private c2g__codaAccountingCurrency__c getCurr(String isoCode){
        return [SELECT Id, Name FROM c2g__codaAccountingCurrency__c 
                WHERE c2g__OwnerCompany__c =: companyId 
                AND Name=:isoCode][0];
    }
    
    private void createRate(String currIsoCode, Decimal rateValue, Date rateDate){
        c2g__codaAccountingCurrency__c curr = getCurr(currIsoCode);
        c2g__codaExchangeRate__c exchangeRate = getRate(curr.Id, rateDate);
        if (exchangeRatesMap.get(currIsoCode + rateDate) != null) return;
        if(exchangeRate == null){
           exchangeRate = new c2g__codaExchangeRate__c(c2g__ExchangeRateCurrency__c = curr.Id,
                                                        c2g__Rate__c = rateValue,
                                                        c2g__StartDate__c = rateDate);
            system.debug('insert R: ' + exchangeRate);
          insert exchangeRate; 
          system.debug('finish insert R' + exchangeRate);

        }else{
            exchangeRate.c2g__Rate__c = rateValue;
            system.debug('update R: ' + exchangeRate);
            update exchangeRate;
            system.debug('finish update R' + exchangeRate);
        }
		exchangeRatesMap.put(currIsoCode + rateDate, exchangeRate);        
        
    }
    
    private c2g__codaExchangeRate__c getRate(String currId, Date rateDate){
    	c2g__codaExchangeRate__c[] erList = [SELECT Id, c2g__Rate__c, c2g__StartDate__c 
                                             FROM c2g__codaExchangeRate__c 
                                             WHERE c2g__StartDate__c =: rateDate AND c2g__ExchangeRateCurrency__c =: currId];
		if(erList.size() > 0) return erList[0];
        return null;
    }
    
    
    private Decimal getRateFromTable(String isoCode, Date rateDate){
    	c2g__codaExchangeRate__c[] erList = [SELECT Id, c2g__Rate__c, c2g__StartDate__c 
                                             FROM c2g__codaExchangeRate__c 
                                             WHERE c2g__StartDate__c <=: rateDate 
                                               AND c2g__OwnerCompany__c =: companyId AND c2g__ExchangeRateCurrency__r.Name=:isoCode
                                             ORDER BY c2g__StartDate__c DESC]; 
		if(erList.size() > 0) return erList[0].c2g__Rate__c;
        return 1;        
    }
    
}