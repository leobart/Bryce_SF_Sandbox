@isTest (SeeAllData=true)
public class BRC_Post_Test {
    
    private static String companyId = [SELECT Id FROM c2g__codaCompany__c WHERE Name = 'Bryce Company Holding Inc.'][0].Id; 
    private static String bancAccId = [SELECT Id FROM c2g__codaBankAccount__c WHERE Name = 'BCH Rietumu USD'][0].Id; 
    private static String accId = [SELECT Id FROM Account WHERE Name='Bank Rietumu'][0].Id;
    private static String currId = [SELECT Id FROM c2g__codaAccountingCurrency__c WHERE c2g__OwnerCompany__c=:companyId AND Name='USD'][0].id;
    private static String chargesGLAId = [SELECT Id FROM c2g__codaGeneralLedgerAccount__c WHERE Name='6-1200 Bank Charges for payments'][0].Id;
    private static String periodId = [SELECT Id FROM c2g__codaPeriod__c WHERE c2g__OwnerCompany__c=:companyId AND Name='2014/008'][0].Id;

   
    private static c2g.CODAAPICommon.Reference cshRef; 
    private static c2g.CODAAPICommon.Reference pinRef; 
    
    static{
        cshRef = createCE();
        pinRef = createPIN();        
    }
    
    static testmethod void test1(){
        c2g.CODAAPICashEntry_7_0.PostCashEntry(null, cshRef);
        c2g.CODAAPIPurchaseInvoice_9_0.PostPurchaseInvoice(null, pinRef);
        
    }
    
    static testmethod void test2(){
        c2g.CODAAPICashEntry_6_0.PostCashEntry(null, cshRef);
    }
    
    static testmethod void test3(){
        c2g.CODAAPIPurchaseInvoice_8_0.PostPurchaseInvoice(null, pinRef);
    }
    
    static testmethod void test4(){
        c2g.CODAAPIPurchaseInvoice_8_0.PostPurchaseInvoice(null, pinRef);
        c2g.CODAAPICashEntry_6_0.PostCashEntry(null, cshRef);        
    }
    
    
    private static c2g.CODAAPICommon.Reference createCE(){
        //Init CashEntryLineItem with API
        c2g.CODAAPICashEntryLineItemTypes_6_0.CashEntryLineItem celi = new c2g.CODAAPICashEntryLineItemTypes_6_0.CashEntryLineItem();
        celi.Account = c2g.CODAAPICommon.getRef(accId, null);
        celi.Charges = 0;
        celi.CashEntryValue = 5;
        celi.BankAccountValue = 5;
        celi.AccountPaymentMethod = 'Electronic';
        c2g.CODAAPICashEntryLineItemTypes_6_0.CashEntryLineItems celis = new c2g.CODAAPICashEntryLineItemTypes_6_0.CashEntryLineItems();
        celis.LineItemList = new List<c2g.CODAAPICashEntryLineItemTypes_6_0.CashEntryLineItem>();
        celis.LineItemList.add(celi);
        
        //Init CashEntry with API
        c2g.CODAAPICashEntryTypes_6_0.CashEntry ce = new c2g.CODAAPICashEntryTypes_6_0.CashEntry();
        ce.BankAccount = c2g.CODAAPICommon.getRef(bancAccId, null);
        ce.CashEntryCurrency = c2g.CODAAPICommon.getRef(currId, null);
        ce.DateValue = Date.valueOf('2014-08-12');
        ce.PaymentMethod = 'Electronic';
        ce.Period = c2g.CODAAPICommon.getRef(periodId, null); 
        ce.Status = c2g.CODAAPICashEntryTypes_6_0.enumStatus.InProgress;
        ce.TypeRef = c2g.CODAAPICashEntryTypes_6_0.enumType.Payment;    
        ce.LineItems = celis;
        ce.Description = 'xxx';
        //ce.ChargesGLA = c2g.CODAAPICommon.getRef(chargesGLAId, null);
        
        return c2g.CODAAPICashEntry_6_0.CreateCashEntry(null, ce);        
    }
    
    private static c2g.CODAAPICommon.Reference createPIN(){
        c2g.CODAAPIPurchaseInvoiceTypes_8_0.PurchaseInvoice pin = new c2g.CODAAPIPurchaseInvoiceTypes_8_0.PurchaseInvoice();
        
        pin.Account = c2g.CODAAPICommon.getRef(accId, null);
        pin.AccountInvoiceNumber ='1234567qqwertt';
        pin.DueDate = Date.valueOf('2014-08-12');
        pin.InvoiceDate = Date.valueOf('2014-08-12');
        pin.InvoiceCurrency = c2g.CODAAPICommon.getRef(currId, null);
        pin.InvoiceStatus = c2g.CODAAPIPurchaseInvoiceTypes_8_0.enumInvoiceStatus.InProgress;
        pin.InvoiceDescription = 'xxx';
        pin.Period = c2g.CODAAPICommon.getRef(periodId, null);

          //Expense Line
          c2g.CODAAPIPurchaseInvoiceExpLineTypes_8_0.PurchaseInvoiceExpenseLineItems pinExpItems = 
                new c2g.CODAAPIPurchaseInvoiceExpLineTypes_8_0.PurchaseInvoiceExpenseLineItems();
          c2g.CODAAPIPurchaseInvoiceExpLineTypes_8_0.PurchaseInvoiceExpenseLineItem pinExpItem = 
                new c2g.CODAAPIPurchaseInvoiceExpLineTypes_8_0.PurchaseInvoiceExpenseLineItem();
          pinExpItem.GeneralLedgerAccount = c2g.CODAAPICommon.getRef(chargesGLAId, null);
          pinExpItem.NetValue = 5;          
          pinExpItems.LineItemList = new List<c2g.CODAAPIPurchaseInvoiceExpLineTypes_8_0.PurchaseInvoiceExpenseLineItem>();
          pinExpItems.LineItemList.add(pinExpItem);         
        
        pin.ExpLineItems = pinExpItems;            
        
        return c2g.CODAAPIPurchaseInvoice_8_0.CreatePurchaseInvoice(null, pin);
        
    }
}