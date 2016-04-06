public class bryceForexUpdate{
    private Date curDate;
    private Map<String,Decimal> currenciesMap;
    private Map<String,Decimal> crossMap;
    
    private List<String> RateList;
    private boolean downloaded=false;
    private boolean error=false;
           
   
    public bryceForexUpdate(){
        curDate=Date.Today();
        currenciesMap=new Map<String,Decimal>();
        crossMap=new Map<String,Decimal>();
        downloaded=false;
        error=false;
        
            
    }
    
    
    private void parseCube(XmlStreamReader reader){
        String res=reader.getAttributeValue(null, 'time');
        if (res!=NULL) {
            curDate=Date.valueOf(res+' 00:00:00');
        } else {
            String cur=reader.getAttributeValue(null, 'currency');
            String rat=reader.getAttributeValue(null, 'rate');
            if ((cur==NULL)||(rat==NULL)) {
                error=true;
                return;
            }
            CurrenciesMap.put(cur,Decimal.valueOf(rat));
        }
    }
    
    
    private void download() {
        if(!downloaded){
            HTTP http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://www.ecb.int/stats/eurofxref/eurofxref-daily.xml');
            req.setMethod('GET');
            HttpResponse res = http.send(req);            
            String LNAME='';
            String LATTR='';
            String SATTR='';
            // Log the XML content
            System.debug(res.getBody());
            
            // Generate the HTTP response as an XML stream
            XmlStreamReader reader = res.getXmlStreamReader();
            
            // Read through the XML
            while(reader.hasNext()) {
              System.debug('Event Type:' + reader.getEventType());
              if (reader.getEventType() == XmlTag.START_ELEMENT) {
                  if('Cube'==reader.getLocalName()){
                      parseCube(reader);
                  }
              }
              reader.next();
            }
            createCross();
            downloaded=true;
        }  
    }
    
    private void createCross() {
        for (string CIC:currenciesMap.keySet()){
            Decimal temp=currenciesMap.get(CIC)/currenciesMap.get('USD');
            temp=temp*10000.0;
            temp=temp.round();
            temp=temp/10000.0;
            crossMap.put(CIC,temp);
        }
        Decimal temp=1.0/currenciesMap.get('USD');
        temp=temp*10000.0;
        temp=temp.round();
        temp=temp/10000.0;
        crossMap.put('EUR',temp);
        crossMap.remove('USD');
    }
    
    public Decimal getEURRate(String CurISOCode){
        download();
        return currenciesMap.get(CurISOCode);
    }
    
    public Decimal getUSDRate(String CurISOCode){
        download();
        return crossMap.get(CurISOCode);
    }
    
    public Map<String,Decimal> getRateList(){
        download();
        return currenciesMap;
    }
    
    public Map<String, Decimal> getUsdCrossRates(){
        download();
        return crossMap;
    }
    
    public Date getDate(){
        download();
        return curDate;
    }
    
    public boolean isError(){
        return error;
    }
}