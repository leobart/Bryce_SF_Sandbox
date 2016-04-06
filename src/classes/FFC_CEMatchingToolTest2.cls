@isTest (SeeAllData=true)
public class FFC_CEMatchingToolTest2{
    
    private static String companyId = [SELECT Id FROM c2g__codaCompany__c WHERE Name = 'Bryce Company Holding Inc.'][0].Id; 
    private static String bancAccId = [SELECT Id FROM c2g__codaBankAccount__c WHERE Name = 'BCH Rietumu USD'][0].Id; 
    private static String bancAccIdEUR = [SELECT Id FROM c2g__codaBankAccount__c WHERE Name = 'BCH Rietumu EUR'][0].Id; 
    private static String bancAccIdGBP = [SELECT Id FROM c2g__codaBankAccount__c WHERE Name = 'BCH Rietumu GBP'][0].Id; 
    private static String accId = [SELECT Id FROM Account WHERE Name='Bank Rietumu'][0].Id;
    private static String currId = [SELECT Id FROM c2g__codaAccountingCurrency__c WHERE c2g__OwnerCompany__c=:companyId AND Name='USD'][0].id;
    private static String currIdEUR = [SELECT Id FROM c2g__codaAccountingCurrency__c WHERE c2g__OwnerCompany__c=:companyId AND Name='EUR'][0].id;
    private static String currIdGBP = [SELECT Id FROM c2g__codaAccountingCurrency__c WHERE c2g__OwnerCompany__c=:companyId AND Name='GBP'][0].id;
    private static String chargesGLAId = [SELECT Id FROM c2g__codaGeneralLedgerAccount__c WHERE Name='6-1200 Bank Charges for payments'][0].Id;
    private static String periodId = [SELECT Id FROM c2g__codaPeriod__c WHERE c2g__OwnerCompany__c=:companyId AND Name='2014/008'][0].Id;
    
    private static String paymentCEId;
    private static String paymentRefundCEId;
    private static String refundCEId;
    private static String receiptCEId;
    
    private static Decimal value = 120;
    private static Decimal charge = 2;

    
    static{
        paymentCEId = createPaymentCE();
        paymentRefundCEId = createPaymentRefundCE();
        refundCEId = createRefundCE();
        receiptCEId = createReceiptCE();
    }
    
    static testMethod void paymentMatchingTest2(){
        String ceId = createPaymentCE();
        c2g__codaCashEntry__c ce = [SELECT Id FROM c2g__codaCashEntry__c WHERE id =: ceId];
        ApexPAges.StandardController sc = new ApexPages.StandardController(ce);
        Test.startTest();
        FFC_CEMatchingToolController mtController = new FFC_CEMatchingToolController(sc);
        //Оплата  за поставку/услугу, Оплата расходов
        mtController.selectedProcedure = 2;
        mtController.paperInvoice = true;
        mtController.initEntities();
        mtController.lineType = 0;
        mtController.useAnotherPIN = false;
        Product2 p = [SELECT Id FROM Product2 WHERE Name='Consultancy service'];
        mtController.payableInvoice.c2g__AccountInvoiceNumber__c = 'qwertyui1234567';
        mtController.payableInvoiceLineItem.c2g__Product__c = p.Id;
        PageReference resultPR = mtController.createAction();
        Test.stopTest();
        System.debug('Messages: ' + ApexPages.getMessages());
        System.assert(resultPR != null, 'Result page can not be null.');
    }  
    
    
    static testMethod void paymentMatchingTest6(){
        String ceId = paymentCEId;
        c2g__codaCashEntry__c ce = [SELECT Id FROM c2g__codaCashEntry__c WHERE id =: ceId];
        ApexPAges.StandardController sc = new ApexPages.StandardController(ce);
        Test.startTest();
        FFC_CEMatchingToolController mtController = new FFC_CEMatchingToolController(sc);
        //Конвертация валюты - списание
        mtController.selectedProcedure = 6;
        mtController.initEntities();
        mtController.ce.c2g__BankAccount__c = [SELECT Id FROM c2g__codaBankAccount__c WHERE Name = 'BCH Rietumu EUR'][0].Id;
        mtController.ceLineItem.c2g__CashEntryValue__c = value - 10;
        FFC_CashEntryDetailController cedController = new FFC_CashEntryDetailController();
        cedController.crManager = mtController.crManager;
        cedController.csh = mtController.ce;
        cedController.cshItem = mtController.ceLineItem;
        cedController.updateRates();
        system.debug('crManager ' +  mtController.crManager);
        PageReference resultPR = mtController.createAction();
        System.debug('Messages: ' + ApexPages.getMessages());
        System.assert(resultPR != null, 'Result page can not be null.');
        Test.stopTest();
    }
    
      
    static testMethod void paymentMatchingTest6_anotherCE(){
        String ceId = paymentCEId;
        String anotherCEId = createCE(c2g.CODAAPICashEntryTypes_6_0.enumType.PaymentRefund, value - 10, bancAccIdEUR, currIdEUR);
        c2g__codaCashEntry__c ce = [SELECT Id FROM c2g__codaCashEntry__c WHERE id =: ceId];
        ApexPAges.StandardController sc = new ApexPages.StandardController(ce);
        Test.startTest();
        FFC_CEMatchingToolController mtController = new FFC_CEMatchingToolController(sc);
        //Конвертация валюты - списание
        mtController.selectedProcedure = 6;
        mtController.useAnotherCE = true;
        mtController.ceLineItem.c2g__CashEntry__c = anotherCEId;
        mtController.initEntities();
        PageReference resultPR = mtController.createAction();
        System.debug('Messages: ' + ApexPages.getMessages());
        System.assert(resultPR != null, 'Result page can not be null.');
        Test.stopTest();
    }
    
    static testMethod void pmtMatchingTest6_CE_EUR_CE_GBP(){
        String ceId = createCE(c2g.CODAAPICashEntryTypes_6_0.enumType.Payment, 100, bancAccIdEUR, currIdEUR);
        String anotherCEId = createCE(c2g.CODAAPICashEntryTypes_6_0.enumType.PaymentRefund, 130, bancAccIdGBP, currIdGBP);
        c2g__codaCashEntry__c ce = [SELECT Id FROM c2g__codaCashEntry__c WHERE id =: ceId];
        ApexPAges.StandardController sc = new ApexPages.StandardController(ce);
        Test.startTest();
        FFC_CEMatchingToolController mtController = new FFC_CEMatchingToolController(sc);
        //Конвертация валюты - списание
        mtController.selectedProcedure = 6;
        mtController.useAnotherCE = true;
        mtController.ceLineItem.c2g__CashEntry__c = anotherCEId;
        mtController.initEntities();
        FFC_CurrencyRatesManager.RateLine rline =  mtController.crManager.ratesMap.get('EUR');
        rLine.rate.c2g__Rate__c = 1.2222;
        FFC_CurrencyRatesController crController = new FFC_CurrencyRatesController();
        crController.crManager = mtController.crManager;
        crController.getShowRatesComponent();
        crController.recalculateRates();
        PageReference resultPR = mtController.createAction();
        System.debug('Messages: ' + ApexPages.getMessages());
        System.assert(resultPR != null, 'Result page can not be null.');
        Test.stopTest();
    }
    
    static testMethod void pmtMatchingTest6_pstCE_EUR_CE_GBP(){
        String ceId = createCE(c2g.CODAAPICashEntryTypes_6_0.enumType.Payment, 100, bancAccIdEUR, currIdEUR);
        postCSH(ceId);
        String anotherCEId = createCE(c2g.CODAAPICashEntryTypes_6_0.enumType.PaymentRefund, 130, bancAccIdGBP, currIdGBP);
        c2g__codaCashEntry__c ce = [SELECT Id FROM c2g__codaCashEntry__c WHERE id =: ceId];
        ApexPAges.StandardController sc = new ApexPages.StandardController(ce);
        Test.startTest();
        FFC_CEMatchingToolController mtController = new FFC_CEMatchingToolController(sc);
        //Конвертация валюты - списание
        mtController.selectedProcedure = 6;
        mtController.useAnotherCE = true;
        mtController.ceLineItem.c2g__CashEntry__c = anotherCEId;
        mtController.initEntities();
        PageReference resultPR = mtController.createAction();
        System.debug('Messages: ' + ApexPages.getMessages());
        System.assert(resultPR != null, 'Result page can not be null.');
        Test.stopTest();
    } 
    
     static testMethod void pmtMatchingTest6_CE_EUR_pstCE_GBP(){
        String ceId = createCE(c2g.CODAAPICashEntryTypes_6_0.enumType.Payment, 100, bancAccIdEUR, currIdEUR);
        String anotherCEId = createCE(c2g.CODAAPICashEntryTypes_6_0.enumType.PaymentRefund, 130, bancAccIdGBP, currIdGBP);
        postCSH(anotherCEId);
        c2g__codaCashEntry__c ce = [SELECT Id FROM c2g__codaCashEntry__c WHERE id =: ceId];
        ApexPAges.StandardController sc = new ApexPages.StandardController(ce);
        Test.startTest();
        FFC_CEMatchingToolController mtController = new FFC_CEMatchingToolController(sc);
        //Конвертация валюты - списание
        mtController.selectedProcedure = 6;
        mtController.useAnotherCE = true;
        mtController.ceLineItem.c2g__CashEntry__c = anotherCEId;
        mtController.initEntities();
        PageReference resultPR = mtController.createAction();
        System.debug('Messages: ' + ApexPages.getMessages());
        System.assert(resultPR != null, 'Result page can not be null.');
        Test.stopTest();
    }
    
      
    
    static testMethod void paymentRefundMatchingTest3(){
        String ceId = paymentRefundCEId;
        c2g__codaCashEntry__c ce = [SELECT Id FROM c2g__codaCashEntry__c WHERE id =: ceId];
        ApexPAges.StandardController sc = new ApexPages.StandardController(ce);
        Test.startTest();
        FFC_CEMatchingToolController mtController = new FFC_CEMatchingToolController(sc);
        //Конвертация валюты - зачисление
        mtController.selectedProcedure = 6;
        mtController.initEntities();
        mtController.ce.c2g__BankAccount__c = [SELECT Id FROM c2g__codaBankAccount__c WHERE Name = 'BCH Rietumu EUR'][0].Id;
        mtController.ceLineItem.c2g__CashEntryValue__c = 2500;
        FFC_CashEntryDetailController cedController = new FFC_CashEntryDetailController();
        cedController.crManager = mtController.crManager;
        cedController.csh = mtController.ce;
        cedController.cshItem = mtController.ceLineItem;
        cedController.updateRates();
        PageReference resultPR = mtController.createAction();
        System.debug('Messages: ' + ApexPages.getMessages());
        System.assert(resultPR != null, 'Result page can not be null.');
        Test.stopTest();
    }
    
    
    //---------------------------------------------------------------------------------------------------------------------------------------    
    
    
    private static void postCSH(String cshId){
        c2g.CODAAPICashEntry_6_0.PostCashEntry(null, c2g.CODAAPICommon.getRef(cshId, null));
    }
    
    private static String createCE(c2g.CODAAPICashEntryTypes_6_0.enumType ceType){
        return createCE(ceType, value, bancAccId, currId);
    }
    
    private static String createCE(c2g.CODAAPICashEntryTypes_6_0.enumType ceType, Decimal volumeParam, String bankAccIdParam, String currIdParam){
		//Init CashEntryLineItem with API
		c2g.CODAAPICashEntryLineItemTypes_6_0.CashEntryLineItem celi = new c2g.CODAAPICashEntryLineItemTypes_6_0.CashEntryLineItem();
		celi.Account = c2g.CODAAPICommon.getRef(accId, null);
		celi.Charges = charge;
		celi.CashEntryValue = volumeParam;
		celi.BankAccountValue = volumeParam;
        celi.AccountPaymentMethod = 'Electronic';
		c2g.CODAAPICashEntryLineItemTypes_6_0.CashEntryLineItems celis = new c2g.CODAAPICashEntryLineItemTypes_6_0.CashEntryLineItems();
		celis.LineItemList = new List<c2g.CODAAPICashEntryLineItemTypes_6_0.CashEntryLineItem>();
		celis.LineItemList.add(celi);
        
		//Init CashEntry with API
		c2g.CODAAPICashEntryTypes_6_0.CashEntry ce = new c2g.CODAAPICashEntryTypes_6_0.CashEntry();
		ce.BankAccount = c2g.CODAAPICommon.getRef(bankAccIdParam, null);
		//ce.BankAccountCurrency = trnCur;
		ce.CashEntryCurrency = c2g.CODAAPICommon.getRef(currIdParam, null);
		ce.DateValue = Date.valueOf('2014-08-12');
		ce.PaymentMethod = 'Electronic';
		ce.Period = c2g.CODAAPICommon.getRef(periodId, null); 
		ce.Status = c2g.CODAAPICashEntryTypes_6_0.enumStatus.InProgress;
		ce.TypeRef = ceType;   	
		ce.LineItems = celis;
		ce.Description = 'xxx';
        ce.ChargesGLA = c2g.CODAAPICommon.getRef(chargesGLAId, null);
        
        return c2g.CODAAPICashEntry_6_0.CreateCashEntry(null, ce).Id;
        
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