@isTest(SeeAllData=true)
private class BryceTestForexAndBankUpdate {
    
    static testMethod void ForexTest() {
        // TO DO: implement unit test
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('forexxml');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'text/xml');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
            
        bryceForexUpdate bforex= new bryceForexUpdate();
        Map<String,Decimal> curmap=bforex.getRateList();
        Map<String,Decimal> curmap2=bforex.getUsdCrossRates();
        Date dt=bforex.getDate();
        boolean bl=bforex.isError();
        decimal usd=bforex.getUSDRate('EUR');
        decimal ueurr=bforex.getEURRate('USD');
        try{    
           
        } catch (Exception e){
        system.debug('Error: '+e);
        }
    }
    
    static testMethod void BAccountTriggerTest() {
        // TO DO: implement unit test
        List<c2g__codaBankAccount__c> baccountList=[SELECT id, name FROM c2g__codaBankAccount__c WHERE name = 'BCH Rietumu USD'];
        system.debug('BAccountTriggerTest: list:  ' + baccountList);
        update baccountList[0];
        try{    
           
        } catch (Exception e){
        system.debug('Error: '+e);
        }
    }
    
    static testMethod void CreditLineTriggerTest() {
        // TO DO: implement unit test
        List<Credit_Line_Line_Item__c> baccountList=[SELECT id, name FROM Credit_Line_Line_Item__c LIMIT 1];
        update baccountList[0];
        delete baccountList[0];
        
        try{    

        } catch (Exception e){
        system.debug('Error: '+e);
        }
    }
    
}