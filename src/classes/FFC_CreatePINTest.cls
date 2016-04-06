@isTest (SeeAllData=true)
public class FFC_CreatePINTest{
    
    public static Bank__c bank = [SELECT Id, Name FROM Bank__c WHERE Name='Rietumu Banka'];
    public static Account acc = [SELECT Id, Name FROM Account WHERE Name='Bank Rietumu']; 
    public static Product2 prod = [SELECT Id, Name FROM Product2 WHERE Name='Consultancy service'];
    public static c2g__codaCompany__c comp = [SELECT Id, Name FROM c2g__codaCompany__c WHERE Name='Bryce Company Holding Inc.'];
	public static c2g__codaPeriod__c period = [SELECT Id, Name FROM c2g__codaPeriod__c WHERE Name='2014/005' and c2g__OwnerCompany__c=:comp.Id];
    public static c2g__codaAccountingCurrency__c curr = [SELECT Id, Name FROM c2g__codaAccountingCurrency__c WHERE Name='USD' AND c2g__OwnerCompany__c=:comp.Id];
    
    static testMethod void test1(){
        ApexPAges.StandardController sc = new ApexPages.StandardController(new c2g__codaPurchaseInvoice__c());
        FFC_CreatePINController controller = new FFC_CreatePINController();
        
        c2g__codaPurchaseInvoiceLineItem__c productLine = new c2g__codaPurchaseInvoiceLineItem__c();
        productLine.c2g__Product__c = prod.Id;
        productLine.c2g__UnitPrice__c = 500;
        controller.productsMap.put(0,productLine); 
        
        c2g__codaPurchaseInvoiceExpenseLineItem__c expLine = new c2g__codaPurchaseInvoiceExpenseLineItem__c();
        expLine.c2g__GeneralLedgerAccount__c = [SELECT Id FROM c2g__codaGeneralLedgerAccount__c WHERE Name='6-5300 Consultancy'].Id;
        expLine.c2g__NetValue__c = 500;
        controller.expensesMap.put(0, expLine);
        
        c2g__codaPurchaseInvoice__c pin = controller.pin;
        pin.c2g__Account__c = acc.Id;
        pin.c2g__AccountInvoiceNumber__c = 'wwwwwwwwww';
        pin.c2g__InvoiceCurrency__c = curr.Id;
        pin.c2g__DueDate__c = System.today();
        pin.c2g__InvoiceDate__c = Date.newInstance(2014, 5, 25);
        pin.c2g__Period__c = period.Id;
        
        controller.addExpenseLineAction();
        controller.addProductLineAction();
        
        controller.deleteId = 1;
        
        controller.deleteExpenseAction();
        controller.deleteProductAction();
        
        controller.getVisibleExpensesLines();
        controller.getVisibleProductsLines();
        
        controller.calculateTaxesAction();
        
        controller.createPINAction();       
    }

}