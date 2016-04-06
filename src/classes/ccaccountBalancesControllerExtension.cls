public class ccaccountBalancesControllerExtension{
    public String accountID{get;set;}
    public String accountName {get;set;}
    public Map<String,Decimal> QueryResults;
    public Decimal TotalBalance {get;set;}
    public Integer er {get;set;}
    public String erm{get;set;}
    public String cur {get;private set;}
    public Map<String,Decimal> getQueryResults(){
        er = 0;
        try{
            Map<String,Decimal> QueryResults = new Map<String,Decimal>();
            List<String> companiesNames = c2g.CODAAPICompany_2_0.GetCurrentCompanies(null);
            if (companiesNames.size()>0){
                for (String cn:companiesNames){
                    QueryResults.put(cn,0);
                }
            }
            List<c2g__codaTransactionLineItem__c> tli = [Select c2g__AccountCurrency__r.Name, c2g__AccountOutstandingValue__c, c2g__OwnerCompany__r.Name From c2g__codaTransactionLineItem__c WHERE (c2g__Account__r.ID =:accountID AND c2g__AccountOutstandingValue__c!=0 AND c2g__LineType__c='Account' AND c2g__OwnerCompany__r.Name IN:companiesNames)];
            TotalBalance = 0;
            Decimal ct = 0;
            if (companiesNames.size()>0){
            if (tli.size()>0){
                cur = tli[0].c2g__AccountCurrency__r.Name;
                for (c2g__codaTransactionLineItem__c tl: tli){
                    ct = QueryResults.get(tl.c2g__OwnerCompany__r.Name);
                    QueryResults.put(tl.c2g__OwnerCompany__r.Name,ct+tl.c2g__AccountOutstandingValue__c);
                    TotalBalance += tl.c2g__AccountOutstandingValue__c;
                }  
            }}
            return QueryResults;
        }catch (Exception e){
            er = e.getLineNumber();
            erm = e.getMessage();
            return QueryResults;
        }
    }
    
    public PageReference openReportWithAccount(){
        String company = System.currentPageReference().getParameters().get('Company');
        return new PageReference ('/00OE0000001cBwL?pv0='+accountName+'&pv1='+company);
    }
}