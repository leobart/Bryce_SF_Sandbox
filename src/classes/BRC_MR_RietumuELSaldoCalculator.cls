public class BRC_MR_RietumuELSaldoCalculator implements BRC_MR_Calculator {
    
    public Decimal getValue(String parameters, Decimal oldValue){
        String[] params = parameters.split('/');
        String rietumuELId = params[0];
        Rietumu_EL__c rel;
        if(rietumuELId == 'test'){
            rel = new Rietumu_EL__c(Ticket__c = 'xxxxx');
        }else{
 	        rel = [SELECT Id, Ticket__c FROM Rietumu_EL__c WHERE Id=:rietumuELId];   
        }
        String curr = params[1];
		String rietumuURL = Rietumu_Bridge_Settings__c.getInstance().Rietumu_URL__c;
		String proxyURL = Rietumu_Bridge_Settings__c.getInstance().Rietumu_Proxy_URL__c;
        if(rietumuELId == 'test'){
            rietumuURL = 'xxxx';
            proxyURL = 'xxxxx';
        }
        DateTime limitDate = DateTime.valueOf('2010-01-01 00:00:00');
        DateTime endDate = System.today();
        DateTime startDate = endDate;
        String rietumuId = Rietumu_Bridge_Settings__c.getInstance().Rietumu_Id__c;
        String password = Rietumu_Bridge_Settings__c.getInstance().Password__c;    
        list<Rietumutransaction> transactions = new list<Rietumutransaction>();
        Integer i = 0;
        while(startDate > limitDate && transactions.size()==0 && i < 40){
            startDate = startDate.addDays(-50);
        	transactions = BRC_RTM_EnterpriseLink.getTransactions(rietumuURL, proxyURL, startDate, endDate, rel.Ticket__c, rietumuId, password, curr, 'EN');            
            if(transactions.size() == 0 && oldValue != null) return oldValue;
            i++;
        }
        if(transactions.size() == 0) return null;
        RietumuTransaction trn = transactions.get(transactions.size() - 1);
        return trn.saldo;
	}
	   
   

}