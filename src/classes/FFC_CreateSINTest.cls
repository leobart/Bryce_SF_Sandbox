@isTest (SeeAllData=true)
public class FFC_CreateSINTest{
    
    public static Bank__c bank = [SELECT Id, Name FROM Bank__c WHERE Name='Rietumu Banka'];
    public static Account acc = [SELECT Id, Name FROM Account WHERE Name='Bank Rietumu']; 
    public static Product2 prod = [SELECT Id, Name FROM Product2 WHERE Name='Consultancy service'];
    public static c2g__codaCompany__c comp = [SELECT Id, Name FROM c2g__codaCompany__c WHERE Name='Bryce Company Holding Inc.'];
	public static c2g__codaPeriod__c period = [SELECT Id, Name FROM c2g__codaPeriod__c WHERE Name='2014/005' and c2g__OwnerCompany__c=:comp.Id];
    public static c2g__codaAccountingCurrency__c curr = [SELECT Id, Name FROM c2g__codaAccountingCurrency__c WHERE Name='USD' AND c2g__OwnerCompany__c=:comp.Id];
    
    static testMethod void test1(){
        ApexPAges.StandardController sc = new ApexPages.StandardController(new c2g__codaInvoice__c());
        FFC_CreateSINController controller = new FFC_CreateSINController();
        
        c2g__codaInvoiceLineItem__c productLine = new c2g__codaInvoiceLineItem__c();
        productLine.c2g__Product__c = prod.Id;
        productLine.c2g__UnitPrice__c = 500;
        controller.productsMap.put(0,productLine); 
        
       
        c2g__codaInvoice__c sin = controller.sin;
        sin.c2g__Account__c = acc.Id;
        sin.c2g__CustomerReference__c = 'wwwwwwwwww';
        sin.c2g__InvoiceCurrency__c = curr.Id;
        sin.c2g__DueDate__c = System.today();
        sin.c2g__InvoiceDate__c = Date.newInstance(2014, 5, 25);
        sin.c2g__Period__c = period.Id;
        
        controller.addProductLineAction();       
        controller.deleteId = 1;       
        controller.deleteProductAction();
        
        controller.getVisibleProductsLines();
        controller.calculateTaxesAction();
        controller.createSINAction();       
    }

}