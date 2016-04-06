@isTest (SeeAllData=true)
public class RietumuELCreateCEControllerTest{
    
    private static String companyId = [SELECT Id FROM c2g__codaCompany__c WHERE Name = 'Bryce Company Holding Inc.'][0].Id; 
    private static String bancAccId; 

    static testMethod void createCETest(){
        bancAccId = [SELECT Id FROM c2g__codaBankAccount__c WHERE Name = 'BCH Rietumu USD'][0].Id;
        List<Rietumu_Transaction__c> rTrns = [SELECT ID FROM Rietumu_Transaction__c WHERE Name='EQ-20140130-HEAD-CH01-205'];
        if(rTrns.size() != 0) delete rTrns;
        String paramsStr = 'trnId=EQ-20140130-HEAD-CH01-205&bAccId='+ bancAccId +'&companyId='+ companyId +'&companyName=Bryce%20Company%20Holding%20Inc.&trnDate=2014-01-30%2000:00:00&trnCur=USD&benName=Bank%20Rietumu&cshType=Payment&trnAmount=-10.0&trndesc=Additional%20charges%20OUR%20for%20payment&chargeValue=0&details=IVID12029901396%2010000.00%20USD';
        initParams(paramsStr);
        RietumuELCreateCEController controller = new RietumuELCreateCEController(); 
        controller.createAndMatchAction();
        controller.updateChargesValue();
        system.debug('Messages: ' + ApexPages.getMessages());
        System.assertNotEquals('', controller.cashEntryId);
        //check already exists
        initParams(paramsStr);
        controller = new RietumuELCreateCEController(); 
        controller.createCashEntry();        
    }
    
    static testMethod void createCEWithChargeTest(){
        bancAccId = [SELECT Id FROM c2g__codaBankAccount__c WHERE Name = 'BCH Rietumu EUR'][0].Id;
        List<Rietumu_Transaction__c> rTrns = [SELECT ID FROM Rietumu_Transaction__c WHERE Name='EQ-20140115-HEAD-CH01-2505'];
        if(rTrns.size() != 0) delete rTrns;
        String paramsStr = 'trnId=EQ-20140115-HEAD-CH01-2505&bAccId=' + bancAccId + '&companyId=' + companyId + '&companyName=Bryce%20Company%20Holding%20Inc.&trnDate=2014-01-15%2000:00:00&trnCur=EUR&benName=Gramaro%20Accounting%20Services%20LTD&cshType=Payment&trnAmount=-600.0&trndesc=External%20payment&chargeValue=-15.0&details=Payment%20under%20Invoice%20687/13%20dd%2009/%2010/13&chargeTrnId=EQ-20140115-HEAD-@@SC-1177';
        initParams(paramsStr);
        RietumuELCreateCEController controller = new RietumuELCreateCEController(); 
        controller.createAndMatchAction();
        controller.updateChargesValue();
        system.debug('Messages: ' + ApexPages.getMessages());
        System.assertNotEquals('', controller.cashEntryId);
    }
    
    static testMethod void createCEUnefinedBAccTest(){
        String paramsStr = 'trnId=EQ-20140130-HEAD-CH01-205&bAccId=undefined&companyId='+ companyId +'&companyName=Bryce%20Company%20Holding%20Inc.&trnDate=2014-01-30%2000:00:00&trnCur=USD&benName=Bank%20Rietumu&cshType=Payment&trnAmount=-10.0&trndesc=Additional%20charges%20OUR%20for%20payment&chargeValue=0&details=IVID12029901396%2010000.00%20USD';
        initParams(paramsStr);
        RietumuELCreateCEController controller = new RietumuELCreateCEController(); 
        system.debug('Messages: ' + ApexPages.getMessages());
    }
       
    private static void initParams(String paramsStr){
        paramsStr = EncodingUtil.urlDecode(paramsStr, 'UTF-8');
        List<String> params = paramsStr.split('&');       
        Test.setCurrentPageReference(new PageReference('Page.rietumuCreateCEPage'));         
        for(String s : params){
            List<String> paramPair = s.split('=');
         	System.currentPageReference().getParameters().put(paramPair[0], paramPair[1]);        
        }
    }
}