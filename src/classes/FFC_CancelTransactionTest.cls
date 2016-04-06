@isTest (SeeAllData=true)
public class FFC_CancelTransactionTest {
    
    private static String companyId = [SELECT Id FROM c2g__codaCompany__c WHERE Name = 'Bryce Company Holding Inc.'][0].Id; 
    private static String bancAccId = [SELECT Id FROM c2g__codaBankAccount__c WHERE Name = 'BCH Rietumu USD'][0].Id; 
    private static String accId = [SELECT Id FROM Account WHERE Name='Bank Rietumu'][0].Id;
    private static String currId = [SELECT Id FROM c2g__codaAccountingCurrency__c WHERE c2g__OwnerCompany__c=:companyId AND Name='USD'][0].id;
    private static String chargesGLAId = [SELECT Id FROM c2g__codaGeneralLedgerAccount__c WHERE Name='6-1200 Bank Charges for payments'][0].Id;
    private static String expGLAId = [SELECT Id FROM c2g__codaGeneralLedgerAccount__c WHERE Name='6-5300 Consultancy'][0].Id;
    private static String prodId = [SELECT Id FROM Product2 WHERE Name='Consultancy service'][0].Id;
    private static String periodId = [SELECT Id FROM c2g__codaPeriod__c WHERE c2g__OwnerCompany__c=:companyId AND Name='2014/008'][0].Id;
        
    private static Decimal value = 120;
    private static Decimal charge = 2;

    private static String paymentCEId = createPaymentCE();    
    private static String pinId = createPIN();
    
    //----------------------------------------------------------------------------------------------
    static testMethod void test1CECancel(){
        Test.setCurrentPageReference(new PageReference('Page.ffc_CanceTransaction'));
        System.currentPageReference().getParameters().put('id', paymentCEId);
        System.currentPageReference().getParameters().put('type', 'CE');
        FFC_CancelTransactionController controller = new FFC_CancelTransactionController();
        controller.cencelTransactionAction();
        controller.cancelAction();
        controller.cashMatchingAction();
    }
    
    
    static testMethod void test2PINCancel(){
        Test.setCurrentPageReference(new PageReference('Page.ffc_CanceTransaction'));
        System.currentPageReference().getParameters().put('id', pinId);
        System.currentPageReference().getParameters().put('type', 'PIN');
        Test.startTest();
        FFC_CancelTransactionController controller = new FFC_CancelTransactionController();
        controller.cencelTransactionAction();
        Test.stopTest();        
    }
    
    
    
    //----------------------------------------------------------------------------------------------
    
    private static String createPIN(){
        c2g.CODAAPIPurchaseInvoiceTypes_8_0.PurchaseInvoice pinAPI = new c2g.CODAAPIPurchaseInvoiceTypes_8_0.PurchaseInvoice();
        c2g.CODAAPIPurchaseInvoiceLineItemTypes_8_0.PurchaseInvoiceLineItems pinLineItemsAPI= new c2g.CODAAPIPurchaseInvoiceLineItemTypes_8_0.PurchaseInvoiceLineItems();
        c2g.CODAAPIPurchaseInvoiceExpLineTypes_8_0.PurchaseInvoiceExpenseLineItems pinExpItemsAPI = new c2g.CODAAPIPurchaseInvoiceExpLineTypes_8_0.PurchaseInvoiceExpenseLineItems();
        
        pinAPI.Account = c2g.CODAAPICommon.getRef(accId, null);
        pinAPI.AccountInvoiceNumber = 'xxxxx12345654312';
        pinAPI.DueDate = Date.valueOf('2014-08-12');
        pinAPI.InvoiceDate = Date.valueOf('2014-08-12');
        pinAPI.InvoiceCurrency = c2g.CODAAPICommon.getRef(currId, null);
        pinAPI.InvoiceStatus = c2g.CODAAPIPurchaseInvoiceTypes_8_0.enumInvoiceStatus.InProgress;
        pinAPI.InvoiceDescription = 'desc';
        pinAPI.Period = c2g.CODAAPICommon.getRef(periodId, null);
        
        
        pinLineItemsAPI.LineItemList = new List<c2g.CODAAPIPurchaseInvoiceLineItemTypes_8_0.PurchaseInvoiceLineItem>();
        c2g.CODAAPIPurchaseInvoiceLineItemTypes_8_0.PurchaseInvoiceLineItem pinLineItemAPI= new c2g.CODAAPIPurchaseInvoiceLineItemTypes_8_0.PurchaseInvoiceLineItem();
        pinLineItemAPI.Product = c2g.CODAAPICommon.getRef(prodId, null);
        pinLineItemAPI.Quantity = 1;
        pinLineItemAPI.InputVATCode = c2g.CODAAPICommon.getRef(null, null);               
        pinLineItemAPI.TaxValue1 = null;
        pinLineItemAPI.UnitPrice = 100;
        pinLineItemsAPI.LineItemList.add(pinLineItemAPI);
        
        pinExpItemsAPI.LineItemList = new List<c2g.CODAAPIPurchaseInvoiceExpLineTypes_8_0.PurchaseInvoiceExpenseLineItem>();
	    c2g.CODAAPIPurchaseInvoiceExpLineTypes_8_0.PurchaseInvoiceExpenseLineItem pinExpItemAPI = new c2g.CODAAPIPurchaseInvoiceExpLineTypes_8_0.PurchaseInvoiceExpenseLineItem();
        pinExpItemAPI.GeneralLedgerAccount = c2g.CODAAPICommon.getRef(expGLAId, null);
        pinExpItemAPI.LineDescription = 'desc';
        pinExpItemAPI.InputVATCode = c2g.CODAAPICommon.getRef(null, null);              
        pinExpItemAPI.TaxValue1 = null;
        pinExpItemAPI.NetValue = 200;
        pinExpItemsAPI.LineItemList.add(pinExpItemAPI);
        
        pinAPI.LineItems = pinLineItemsAPI;
        pinAPI.ExpLineItems = pinExpItemsAPI;
        
		c2g.CODAAPICommon.Reference ref = c2g.CODAAPIPurchaseInvoice_8_0.CreatePurchaseInvoice(null, pinAPI); 
        c2g.CODAAPIPurchaseInvoice_8_0.PostPurchaseInvoice(null, ref);      
        return ref.id;       
    }
    
    private static String createCE(c2g.CODAAPICashEntryTypes_6_0.enumType ceType){
		//Init CashEntryLineItem with API
		c2g.CODAAPICashEntryLineItemTypes_6_0.CashEntryLineItem celi = new c2g.CODAAPICashEntryLineItemTypes_6_0.CashEntryLineItem();
		celi.Account = c2g.CODAAPICommon.getRef(accId, null);
		celi.Charges = charge;
		celi.CashEntryValue = value;
		celi.BankAccountValue = value;
        celi.AccountPaymentMethod = 'Electronic';
		c2g.CODAAPICashEntryLineItemTypes_6_0.CashEntryLineItems celis = new c2g.CODAAPICashEntryLineItemTypes_6_0.CashEntryLineItems();
		celis.LineItemList = new List<c2g.CODAAPICashEntryLineItemTypes_6_0.CashEntryLineItem>();
		celis.LineItemList.add(celi);
        
		//Init CashEntry with API
		c2g.CODAAPICashEntryTypes_6_0.CashEntry ce = new c2g.CODAAPICashEntryTypes_6_0.CashEntry();
		ce.BankAccount = c2g.CODAAPICommon.getRef(bancAccId, null);
		//ce.BankAccountCurrency = trnCur;
		ce.CashEntryCurrency = c2g.CODAAPICommon.getRef(currId, null);
		ce.DateValue = Date.valueOf('2014-08-12');
		ce.PaymentMethod = 'Electronic';
		ce.Period = c2g.CODAAPICommon.getRef(periodId, null); 
		ce.Status = c2g.CODAAPICashEntryTypes_6_0.enumStatus.InProgress;
		ce.TypeRef = ceType;   	
		ce.Value = value;
		ce.LineItems = celis;
		ce.Description = 'xxx';
        ce.ChargesGLA = c2g.CODAAPICommon.getRef(chargesGLAId, null);
        c2g.CODAAPICommon.Reference cshRef = c2g.CODAAPICashEntry_6_0.CreateCashEntry(null, ce);
        c2g.CODAAPICashEntry_6_0.PostCashEntry(null, cshRef);
        return cshRef.Id;        
    }
    
    private static String createPaymentCE(){
        return createCE(c2g.CODAAPICashEntryTypes_6_0.enumType.Payment);
    }

    private static String createPaymentRefundCE(){
        return createCE(c2g.CODAAPICashEntryTypes_6_0.enumType.PaymentRefund);
    }

    private static String createReceiptCE(){
        return createCE(c2g.CODAAPICashEntryTypes_6_0.enumType.Receipt);
    }
    
    private static String createRefundCE(){
        return createCE(c2g.CODAAPICashEntryTypes_6_0.enumType.Refund);
    }

}