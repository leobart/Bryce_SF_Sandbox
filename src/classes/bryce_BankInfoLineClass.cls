public class bryce_BankInfoLineClass {
    private Decimal Available_Funds;
    private Decimal Funds_Blocked;
    private Decimal Total_Funds;
    private string Name;
    private string Company;
    private String Style;
    private String Format;
    private String CurrencyV;
    private bryceForexUpdate Forex;

    public bryce_BankInfoLineClass(Decimal availFunds, Decimal fundsBlocked, Decimal totalFunds, string companyVar, string NameVar, string styleVar){
            Available_Funds=availFunds;
            Funds_Blocked=fundsBlocked;
            Total_Funds=totalFunds;
            Company=companyVar;
            Name=NameVar;
            Style=styleVar;
            Format='USD {0, number, #0,000.00}';
            CurrencyV='USD';
            Forex = new bryceForexUpdate();
    }
    
    public bryce_BankInfoLineClass(Decimal availFunds, Decimal fundsBlocked, Decimal totalFunds, string companyVar, string NameVar, string styleVar, string forVar){
            Available_Funds=availFunds;
            Funds_Blocked=fundsBlocked;
            Total_Funds=totalFunds;
            Company=companyVar;
            Name=NameVar;
            Style=styleVar;
            Format=forVar;
            CurrencyV='USD';
            Forex = new bryceForexUpdate();
    }
    
    public bryce_BankInfoLineClass(Decimal availFunds, Decimal fundsBlocked, Decimal totalFunds, string companyVar, string NameVar, string styleVar, string forVar, String CurVar){
            Available_Funds=availFunds;
            Funds_Blocked=fundsBlocked;
            Total_Funds=totalFunds;
            Company=companyVar;
            Name=NameVar;
            Style=styleVar;
            Format=forVar;
            CurrencyV=CurVar;
            Forex = new bryceForexUpdate();
    }
    
    public bryce_BankInfoLineClass(Bank__c tb){
            Available_Funds=tb.Available_Funds__c;
            Funds_Blocked=tb.Funds_Blocked__c;
            Total_Funds=tb.TotalFunds__c;
            Company='';
            Name=tb.Name;
            Style='background-color: #FFFFCC;  font-weight:Bold';
            Format='USD {0, number, #0,000.00}';
            CurrencyV='USD';
            Forex = new bryceForexUpdate();
    }
    
    public bryce_BankInfoLineClass(Bank__c tb, String cy){
            Available_Funds=tb.Available_Funds__c;
            Funds_Blocked=tb.Funds_Blocked__c;
            Total_Funds=tb.TotalFunds__c;
            Company=cy;
            Name=tb.Name;
            Style='background-color: white';
            Format='USD {0, number, #0,000.00}';
            CurrencyV='USD';
            Forex = new bryceForexUpdate();
    }
    
    public void set(Bank__c tb){
            Available_Funds=tb.Available_Funds__c;
            Funds_Blocked=tb.Funds_Blocked__c;
            Total_Funds=tb.TotalFunds__c;
            Company='';
            Name=tb.Name;
            Style='background-color: #FFFFCC;  font-weight:Bold';
            Format='USD {0, number, #0,000.00}';
    }
    
    public void set(Decimal availFunds, Decimal fundsBlocked, Decimal totalFunds, string companyVar, string NameVar, string styleVar){
            Available_Funds=availFunds;
            Funds_Blocked=fundsBlocked;
            Total_Funds=totalFunds;
            Company=companyVar;
            Name=NameVar;
            Style=styleVar;
            Format='USD {0, number, #0,000.00}';
    }
    
    public void set(Decimal availFunds, Decimal fundsBlocked, Decimal totalFunds, string companyVar, string NameVar, string styleVar, string CurVar){
            Available_Funds=availFunds;
            Funds_Blocked=fundsBlocked;
            Total_Funds=totalFunds;
            Company=companyVar;
            Name=NameVar;
            Style=styleVar;
            Format='USD {0, number, #0,000.00}';
            CurrencyV=CurVar;
    }
    
    public void set(Bank__c tb, String cy){
            Available_Funds=tb.Available_Funds__c;
            Funds_Blocked=tb.Funds_Blocked__c;
            Total_Funds=tb.TotalFunds__c;
            Company=cy;
            Name=tb.Name;   
            Style='background-color: white';
    }
    
    public void setTF(Decimal tff){
            Total_Funds=tff;   
    }
    public void setAF(Decimal tff){
            Available_Funds=tff;   
    }
    
    public void setBF(Decimal tff){
            Funds_Blocked=tff;   
    }
    
    public Decimal getAvailableFunds(){
        return Available_Funds;
    }
    
    public Decimal getBlockedFunds(){
        return Funds_Blocked;
    }
    
    public Decimal getTotalFunds(){
        return Total_Funds;
    }
    
    public String getName(){
        return Name;
    }
    
    public String getCompany(){
        return Company;
    }
    
    public String getStyle(){
        return Style;
    }
    
    public void setStyle(String fcuk){
        Style=fcuk;
    }
    
    public String getFormat(){
        return Format;
    }
    
    public void setFormat(String fcuk){
        Format=fcuk;
    }  
    
    public String getCurrency(){
        return CurrencyV;
    }
    
    public void setCurrency(String fcuk){
        CurrencyV=fcuk;
    }  
    
    public Decimal getAvailableInUSD(){
        IF(CurrencyV=='USD') return Available_Funds;
        Decimal temp=Available_Funds/Forex.getUSDRate(CurrencyV);
        return temp;
    }
    
    public Decimal getBlockedInUSD(){
        IF(CurrencyV=='USD') return Funds_Blocked;
        Decimal temp=Funds_Blocked/Forex.getUSDRate(CurrencyV);
        return temp;
    }
    
    public Decimal getTotalInUSD(){
        IF(CurrencyV=='USD') return Total_Funds;
        Decimal temp=Total_Funds/Forex.getUSDRate(CurrencyV);
        return temp;
    }
    
    
}