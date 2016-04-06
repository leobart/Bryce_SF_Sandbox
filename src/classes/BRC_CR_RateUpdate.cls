public class BRC_CR_RateUpdate implements Schedulable{
    
    // URL: https://developer.yahoo.com/yql/console/?q=show%20tables&env=store://datatables.org/alltableswithkeys#h=select+*+from+yahoo.finance.xchange+where+pair+in+(%22RUBUSD%22%2C+%22USDBYR%22%2C+%22CHFUSD%22%2C+%22EURUSD%22%2C+%22GBPUSD%22)
    private static String url = 'http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.xchange%20where%20pair%20in%20(%22RUBUSD%22%2C%20%22USDBYR%22%2C%20%22CHFUSD%22%2C%20%22EURUSD%22%2C%20%22GBPUSD%22)&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys';
    private static list<CurrencyRate> currRates;
    
    public class CurrencyRate{
        
        public String currencyIsoCode {get; set;}
        public Decimal rate {get; set;}
        
        public CurrencyRate(String isoCode, Decimal rate){
            this.currencyIsoCode = isoCode;
            this.rate = rate;
        }
    }
    
    
    
    public void execute(SchedulableContext SC) {
        process();
	}      
    
    @future(callout=true) 
    public static void process(){
        getRates();
        updateInDB();        
    }
    
    //For testing
    public static void process(Date currDate){
        getRates();
        updateInDB(currDate);                
    }
    
    private static void getRates(){
        httpRequest req = new HttpRequest();
     	req.setEndpoint(url);
    	req.setMethod('GET');
	    req.setTimeout(120000);
	    Http http = new Http();
	    try{
		    HTTPResponse res = http.send(req);
            //body = res.getBody();
		    if (res.getStatusCode() != 200){
		    	return;
		    }	
		    parseXMLResponse(res.getBodyDocument());	    	
	    }catch(CalloutException e){
            system.debug('ERROR: ' + e);
	    }	    	    
    }
    
    private static void parseXMLResponse(Dom.Document doc){
        currRates = new list<CurrencyRate>();
		Dom.Xmlnode root = doc.getRootElement();
		String nameSpace = root.getNamespace();
        Dom.Xmlnode ratesNode = doc.getRootElement().getChildElement('results', nameSpace);
	    for(Dom.Xmlnode rateNode : ratesNode.getChildElements()){
            String rateId = rateNode.getAttribute('id', nameSpace);
            String isoCode;
            Decimal rate = Decimal.valueOf(rateNode.getChildElement('Rate', nameSpace).getText());
            if(rateId =='USDBYR'){
                isoCode = 'BYR';
                rate = 1 / rate;
            }else {
                isoCode = rateId.substring(0, 3);
            }
            if(isoCode == 'RUB') isoCode = 'RUR';
            CurrencyRate cRate = new CurrencyRate(isoCode, rate);
		    currRates.add(cRate);									
	    }
        
    }
    
    private static void updateInDB(){
        updateInDB(Date.today());
    }
    
    private static void updateInDB(Date currDate){
        Date nextMonday = currDate.toStartOfWeek().addDays(7);
        Date[] dates = new Date[]{currDate, nextMonday};
        list<BRC_CR_Currency_Rate__c> crList = new  list<BRC_CR_Currency_Rate__c>();
        list<BRC_CR_Currency_Rate__c> crUpdateList = new  list<BRC_CR_Currency_Rate__c>();
        list<BRC_CR_Currency_Rate__c> crInsertList = new  list<BRC_CR_Currency_Rate__c>();
        crList = [SELECT Id, Rate__c, CurrencyIsoCode, Date__c FROM BRC_CR_Currency_Rate__c WHERE Date__c IN:dates ]; 
        for(CurrencyRate cr : currRates){
            BRC_CR_Currency_Rate__c currDayCR = findCurrRate(crList, cr.currencyIsoCode, currDate);
            if(currDayCR == null){
                currDayCR = new BRC_CR_Currency_Rate__c();
                crInsertList.add(currDayCR);
            } else{
                crUpdateList.add(currDayCR);
            }
            currDayCR.currencyIsoCode = cr.currencyIsoCode;
            currDayCR.Date__c = currDate;
            currDayCR.Rate__c = cr.rate;
            
            BRC_CR_Currency_Rate__c nextMondayCR = findCurrRate(crList, cr.currencyIsoCode, nextMonday);
            if(nextMondayCR == null){
                nextMondayCR = new BRC_CR_Currency_Rate__c();
                crInsertList.add(nextMondayCR);
            } else{
                crUpdateList.add(nextMondayCR);
            }
            nextMondayCR.currencyIsoCode = cr.currencyIsoCode;
            nextMondayCR.Date__c = nextMonday;
            nextMondayCR.Rate__c = cr.rate;
        }
        insert crInsertList;
        update crUpdateList;
    }
    
    private static BRC_CR_Currency_Rate__c findCurrRate(list<BRC_CR_Currency_Rate__c> rates, String isoCode, Date d){
        for(BRC_CR_Currency_Rate__c cr : rates){
            if(cr.Date__c == d && cr.CurrencyIsoCode == isoCode){
                return cr;
            }            
        }
        return null;
    }

}