@isTest (SeeAllData=true)
private class RietumuBridgeTest {

    //------------------------------- DML Mocks --------------------------------------

    
    virtual class DMLMock1 implements RietumuDMLInterface {
        public virtual Rietumu_EL__c getAllowedLink(String companyName){
            //ticket__c, Company__R.name, Company__R.Id
            return new Rietumu_EL__c(
                            Ticket__c = '12345678', 
                            Company__r = new c2g__codaCompany__c(name = 'SomeCompany', id = 'a0WM0000001TZ7m'));            
        }
        public List<c2g__codaBankAccount__c> getBankAccounts(String companyId){
            return new List<c2g__codaBankAccount__c>{
                new c2g__codaBankAccount__c(name = 'bankAcc', 
                                            id = 'a0HM0000005hacF',
                                            c2g__BankAccountCurrency__c = 'a0WM0000001TZ5m',
                                            c2g__OwnerCompany__c = 'a0WM0000001TA7m',
                                            c2g__GeneralLedgerAccount__c = 'a0WM0000001TQ7m')};         
        }   
        public List<c2g__codaBankAccount__c> getBankAccounts(String companyId, String curr){
            return new List<c2g__codaBankAccount__c>{
                new c2g__codaBankAccount__c(name = 'bankAcc', 
                                            id = 'a0HM0000005hacF',
                                            c2g__BankAccountCurrency__c = 'a0WM0000001TZ5m',
                                            c2g__OwnerCompany__c = 'a0WM0000001TA7m',
                                            c2g__GeneralLedgerAccount__c = 'a0WM0000001TQ7m')};         
        }   
        public c2g__codaBankAccount__c getBankAccount(String bAccId){
            return new c2g__codaBankAccount__c(name = 'bankAcc', 
                                            id = 'a0HM0000005hacF',
                                            c2g__BankAccountCurrency__c = 'a0WM0000001TZ5m',
                                            c2g__OwnerCompany__c = 'a0WM0000001TA7m',
                                            c2g__GeneralLedgerAccount__c = 'a0WM0000001TQ7m');          
        }   
        public String getBankAccountCurrency(String bancAccountId){
            return 'USD';
        }   
        public c2g__codaPeriod__c getPeriod(String companyId, Date pDate){
            return new c2g__codaPeriod__c(id='a1OM00000000pPq');
        }
        
        public Account getAccount(string accountName){
            return new Account(Id = '001M000000Ok6aW');
        }
        
        public Rietumu_Account_Dictionary__c getDictionary(String benName){
            return new Rietumu_Account_Dictionary__c(account__c = 'a0YM0000001TQ9m');
        }
        public c2g__codaCashEntry__c getCashEntry(String refId){
            return new c2g__codaCashEntry__c(Id = 'a0QM0000003SKN4');
        }
        public void insertSObject(SObject o){
            //do nothing
        }
        public List<Rietumu_Transaction__c> getTransactions(String uniqueId){
            return new List<Rietumu_Transaction__c>();
        }   
        public List<Rietumu_Transaction__c> getTransactions(List<String> trnIds){
            return new List<Rietumu_Transaction__c>();
        }   
        
        public c2g__codaGeneralLedgerAccount__c getChargesGLA(String nameGLA){
            return new c2g__codaGeneralLedgerAccount__c(id='a0nE0000000615D');
        }

    }
    
    class DMLMock2 extends DMLMock1{
        public override Rietumu_EL__c getAllowedLink(String companyName){
            return null;            
        }       
    }
    
    //------------------------------- FF API Mocks --------------------------------------
        
    virtual class FFAPIMock1 implements RietumuAPIWrapperInterface{
        public virtual List<String> getCurrentCompanies(){
            return new List<String>{'SomeCompany'};
        }   
        public c2g.CODAAPICommon.Reference createCashEntry(c2g.CODAAPICashEntryTypes_6_0.CashEntry ce){
            c2g.CODAAPICommon.Reference ref = new c2g.CODAAPICommon.Reference();
            ref.Id = 'a0YM0000004TQ9g';
            return ref;
        }           
    }
    
    class FFAPIMock2 extends FFAPIMock1{
        public override List<String> getCurrentCompanies(){
            return new List<String>{'SomeCompany', 'Company2'};
        }           
    }
  
    class FFAPIMock3 extends FFAPIMock1{
        public override List<String> getCurrentCompanies(){
            return new List<String>();
        }           
    }
  
    static testMethod void rietumuTest1() {        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('RietumuTestXML');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'text/xml');
        Test.setMock(HttpCalloutMock.class, mock);
        
        RietumuELController controller = new RietumuELController(new FFAPIMock1(), new DMLMock1());
        controller.setStartDateS(Date.valueOf('2013-08-12').format());
        controller.getStartDateS();
        controller.setEndDateS(Date.valueOf('2013-08-12').format());
        controller.getEndDateS();
        controller.transactionsRequest();
        controller.bAccountId = 'a0HM0000005hacF';
        controller.transactionsRequest();
        controller.selectedTransactionId = 'EQ-20130902-HEAD-@@SC-3299';
        //controller.importTransaction();
        controller.selectedTransactionId = 'EQ-20130902-HEAD-@@SC-3351';
        //controller.updateChargesValue();
        //controller.importTransaction();
        controller.selectedTransactionId = 'EQ-20130902-HEAD-CH01-7265';
        //controller.importTransaction();
        //controller.getReleaseDate();
        //controller.transactionsViewerPage();
        //controller.createCashEntry();
        System.assert(true);
    }
    
    static testMethod void rietumuTest2(){
         RietumuELController controller = new RietumuELController(new FFAPIMock2(), new DMLMock1());    
    }
    
    static testMethod void rietumuTest3(){
         RietumuELController controller = new RietumuELController(new FFAPIMock3(), new DMLMock1());    
    }
    
    static testMethod void rietumuTest4(){
         RietumuELController controller = new RietumuELController(new FFAPIMock1(), new DMLMock2());    
    }
    
    static testMethod void rietumuTest5(){
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('RietumuTestXML2');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'text/xml');
        Test.setMock(HttpCalloutMock.class, mock);
        RietumuELController controller = new RietumuELController();  
        controller.startDate = Date.valueOf('2014-01-01');
        controller.endDate = Date.valueOf('2014-01-31');
        controller.prevMonth();
        controller.nextMonth();
        controller.transactionsRequest();        
    }
    
    static testMethod void rietumuTest6(){
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('RietumuTestXML2');
        mock.setStatusCode(404);
        mock.setHeader('Content-Type', 'text/xml');
        Test.setMock(HttpCalloutMock.class, mock);
        RietumuELController controller = new RietumuELController();  
    }
    
}