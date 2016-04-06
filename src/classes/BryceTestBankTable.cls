@isTest(SeeAllData=true)
private class BryceTestBankTable {
    
    static testMethod void TableTest() {
        // TO DO: implement unit test
       
       StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('forexxml');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'text/xml');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
          bryce_BankListController Bcon = new bryce_BankListController();
        Bcon.getBanks();
        Bcon.getTotalBlocked();
        Bcon.getTotalAvailible();
        Bcon.pdf();
        Bcon.getTotal();
        try{    
           
        } catch (Exception e){
        system.debug('Error: '+e);
        }
    }
    
    static testMethod void InfoLineTest() {
        // TO DO: implement unit test
       StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('forexxml');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'text/xml');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
       
        // Set the mock callout mode
        bryce_BankInfoLineClass BIC;
        List<Bank__c> blist=[SELECT id,name ,Available_Funds__c, Funds_Blocked__c, TotalFunds__c FROM Bank__c LIMIT 1];
        Bank__c temp=blist[0];
        BIC= new bryce_BankInfoLineClass(temp);
        BIC= new bryce_BankInfoLineClass(temp,'');
        BIC.set(temp);
        BIC.set(temp,'');
        BIC.set(1111.22,1111.22,1111.22,'','','');
        BIC.set(1111.22,1111.22,1111.22,'','','','');
        
        BIC.setAF(111.222);
        BIC.setTF(111.222);
        BIC.setBF(111.222);
        BIC.setCurrency('USD');
        BIC.getTotalInUSD();
        BIC.getBlockedInUSD();
        BIC.getAvailableInUSD();
        BIC.getName();
        BIC.getCompany();
        BIC.setFormat('ff');
        BIC.getFormat();
        BIC.getCurrency();
        BIC.setCurrency('GBP');
        BIC.getTotalInUSD();
        BIC.getBlockedInUSD();
        BIC.getAvailableInUSD();
        
        BIC.getStyle();
        BIC.setStyle('ff');
                
        
        
        try{    
           
        } catch (Exception e){
        system.debug('Error: '+e);
        }
    }
    
    
}