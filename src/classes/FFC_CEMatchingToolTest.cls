@isTest (SeeAllData=true)
public class FFC_CEMatchingToolTest{
    
    private static String companyId = [SELECT Id FROM c2g__codaCompany__c WHERE Name = 'Bryce Company Holding Inc.'][0].Id; 
    private static String bancAccId = [SELECT Id FROM c2g__codaBankAccount__c WHERE Name = 'BCH Rietumu USD'][0].Id; 
    private static String accId = [SELECT Id FROM Account WHERE Name='Bank Rietumu'][0].Id;
    private static String currId = [SELECT Id FROM c2g__codaAccountingCurrency__c WHERE c2g__OwnerCompany__c=:companyId AND Name='USD'][0].id;
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
    
    /*static testMethod void paymentMatchingTest2(){
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
        Product2 p = [SELECT Id FROM Product2 WHERE Name='Consultancy service'];
        mtController.payableInvoice.c2g__AccountInvoiceNumber__c = 'qwertyui1234567';
        mtController.payableInvoiceLineItem.c2g__Product__c = p.Id;
        PageReference resultPR = mtController.createAction();
        Test.stopTest();
        System.debug('Messages: ' + ApexPages.getMessages());
        System.assert(resultPR != null, 'Result page can not be null.');
    } */  
    
    static testMethod void paymentMatchingTest3(){
        String ceId = paymentCEId;
        c2g__codaCashEntry__c ce = [SELECT Id FROM c2g__codaCashEntry__c WHERE id =: ceId];
        ApexPAges.StandardController sc = new ApexPages.StandardController(ce);
        Test.startTest();
        FFC_CEMatchingToolController mtController = new FFC_CEMatchingToolController(sc);
        //Выданный займ - выдача, краткосрочный
        mtController.selectedProcedure = 3;
        mtController.loanType = 'short';
        mtController.initEntities();
        PageReference resultPR = mtController.createAction();
        System.debug('Messages: ' + ApexPages.getMessages());
        System.assert(resultPR != null, 'Result page can not be null.');
        Test.stopTest();
    }
        
    static testMethod void paymentMatchingTest5(){
        String ceId = paymentCEId;
        c2g__codaCashEntry__c ce = [SELECT Id FROM c2g__codaCashEntry__c WHERE id =: ceId];
        ApexPAges.StandardController sc = new ApexPages.StandardController(ce);
        Test.startTest();
        FFC_CEMatchingToolController mtController = new FFC_CEMatchingToolController(sc);
        //Депонирование Cash Margin
        mtController.selectedProcedure = 5;
        mtController.initEntities();
        mtController.journalLineItem2.c2g__GeneralLedgerAccount__c = [SELECT Id FROM c2g__codaGeneralLedgerAccount__c WHERE Name='1-2700 Cash margin BNPP'][0].Id;
        PageReference resultPR = mtController.createAction();
        System.debug('Messages: ' + ApexPages.getMessages());
        System.assert(resultPR != null, 'Result page can not be null.');
        Test.stopTest();
    }    
    
    /*static testMethod void paymentMatchingTest6(){
        String ceId = paymentCEId;
        c2g__codaCashEntry__c ce = [SELECT Id FROM c2g__codaCashEntry__c WHERE id =: ceId];
        ApexPAges.StandardController sc = new ApexPages.StandardController(ce);
        Test.startTest();
        FFC_CEMatchingToolController mtController = new FFC_CEMatchingToolController(sc);
        //Конвертация валюты - списание
        mtController.selectedProcedure = 6;
        mtController.initEntities();
        mtController.ce.c2g__BankAccount__c = [SELECT Id FROM c2g__codaBankAccount__c WHERE Name = 'BCH Rietumu EUR'][0].Id;
        mtController.ceLineItem.c2g__CashEntryValue__c = 2500;
        PageReference resultPR = mtController.createAction();
        System.debug('Messages: ' + ApexPages.getMessages());
        System.assert(resultPR != null, 'Result page can not be null.');
        Test.stopTest();
    }*/
    
    static testMethod void paymentMatchingTest7(){
        String ceId = paymentCEId;
        c2g__codaCashEntry__c ce = [SELECT Id FROM c2g__codaCashEntry__c WHERE id =: ceId];
        ApexPAges.StandardController sc = new ApexPages.StandardController(ce);
        Test.startTest();
        FFC_CEMatchingToolController mtController = new FFC_CEMatchingToolController(sc);
        //Перевод между счетами - списание
        mtController.selectedProcedure = 7;
        mtController.initEntities();
        mtController.ce.c2g__BankAccount__c = [SELECT Id FROM c2g__codaBankAccount__c WHERE Name = 'BCH BNPP USD'][0].Id;
        mtController.ceLineItem.c2g__CashEntryValue__c = value;
        PageReference resultPR = mtController.createAction();
        System.debug('Messages: ' + ApexPages.getMessages());
        System.assert(resultPR != null, 'Result page can not be null.');
        Test.stopTest();
    }
    
    static testMethod void paymentMatchingTest8(){
        String ceId = paymentCEId;
        c2g__codaCashEntry__c ce = [SELECT Id FROM c2g__codaCashEntry__c WHERE id =: ceId];
        ApexPAges.StandardController sc = new ApexPages.StandardController(ce);
        Test.startTest();
        FFC_CEMatchingToolController mtController = new FFC_CEMatchingToolController(sc);
        //Перевод между счетами - списание
        mtController.selectedProcedure = 7;
        mtController.initEntities();
        mtController.ce.c2g__BankAccount__c = [SELECT Id FROM c2g__codaBankAccount__c WHERE Name = 'BCH Rietumu EUR'][0].Id;
        mtController.ceLineItem.c2g__CashEntryValue__c = 2500;
        PageReference resultPR = mtController.createAction();
        System.debug('Messages: ' + ApexPages.getMessages());
        System.assert(resultPR == null, 'Result page must be null');
        Test.stopTest();
    }

    static testMethod void receiptMatchingTest1(){
        String ceId = receiptCEId;
        c2g__codaCashEntry__c ce = [SELECT Id FROM c2g__codaCashEntry__c WHERE id =: ceId];
        ApexPAges.StandardController sc = new ApexPages.StandardController(ce);
        Test.startTest();
        FFC_CEMatchingToolController mtController = new FFC_CEMatchingToolController(sc);
        //Получение оплаты за поставку/услугу
        mtController.selectedProcedure = 2;
        mtController.initEntities();
        mtController.invoice.c2g__CustomerReference__c = '1234567890qwertyu';
        mtController.invoiceLineItem.c2g__Product__c = [SELECT Id FROM Product2 WHERE Name='Consultancy service'][0].Id;
        PageReference resultPR = mtController.createAction();
        System.debug('Messages: ' + ApexPages.getMessages());
        System.assert(resultPR != null, 'Result page can not be null.');
        Test.stopTest();
    }
    
    static testMethod void receiptMatchingTest2(){
        String ceId = receiptCEId;
        c2g__codaCashEntry__c ce = [SELECT Id FROM c2g__codaCashEntry__c WHERE id =: ceId];
        ApexPAges.StandardController sc = new ApexPages.StandardController(ce);
        Test.startTest();
        FFC_CEMatchingToolController mtController = new FFC_CEMatchingToolController(sc);
        //Полученный займ - получение
        mtController.selectedProcedure = 8;
        mtController.loanType = 'short';
        mtController.initEntities();
        PageReference resultPR = mtController.createAction();
        System.debug('Messages: ' + ApexPages.getMessages());
        System.assert(resultPR != null, 'Result page can not be null.');
        Test.stopTest();
    }
      
    static testMethod void refundMatchingTest1(){
        String ceId = refundCEId;
        c2g__codaCashEntry__c ce = [SELECT Id FROM c2g__codaCashEntry__c WHERE id =: ceId];
        ApexPAges.StandardController sc = new ApexPages.StandardController(ce);
        Test.startTest();
        FFC_CEMatchingToolController mtController = new FFC_CEMatchingToolController(sc);
        //Возврат клиенту
        mtController.selectedProcedure = 9;
        mtController.useAnotherCE = false;
        mtController.initEntities();
        mtController.creditNote.c2g__CustomerReference__c = '1q2w3e4r5t6y7u8i9o0p';
        mtController.creditNoteLineItem.c2g__Product__c = [SELECT Id FROM Product2 WHERE Name='Consultancy service'][0].Id;
        PageReference resultPR = mtController.createAction();
        System.debug('Messages: ' + ApexPages.getMessages());
        System.assert(resultPR != null, 'Result page can not be null.');
        Test.stopTest();
    }
    
    static testMethod void refundMatchingTest2(){
        String ceId = refundCEId;
        c2g__codaCashEntry__c ce = [SELECT Id FROM c2g__codaCashEntry__c WHERE id =: ceId];
        ApexPAges.StandardController sc = new ApexPages.StandardController(ce);
        Test.startTest();
        FFC_CEMatchingToolController mtController = new FFC_CEMatchingToolController(sc);
        //Полученный займ - возврат
        mtController.selectedProcedure = 8;
        mtController.loanType = 'short';
        mtController.initEntities();
        PageReference resultPR = mtController.createAction();
        System.debug('Messages: ' + ApexPages.getMessages());
        System.assert(resultPR != null, 'Result page can not be null.');
        Test.stopTest();
    }
            
    static testMethod void paymentRefundMatchingTest1(){
        String ceId = paymentRefundCEId;
        c2g__codaCashEntry__c ce = [SELECT Id FROM c2g__codaCashEntry__c WHERE id =: ceId];
        ApexPAges.StandardController sc = new ApexPages.StandardController(ce);
        Test.startTest();
        FFC_CEMatchingToolController mtController = new FFC_CEMatchingToolController(sc);
        //Возврат клиенту
        mtController.selectedProcedure = 10;
        mtController.initEntities();
        mtController.payableCreditNote.c2g__AccountCreditNoteNumber__c = '1q2w3e4r5t6y7u8i9o0p';
        mtController.payableCreditNoteLineItem.c2g__Product__c = [SELECT Id FROM Product2 WHERE Name='Consultancy service'][0].Id;
        PageReference resultPR = mtController.createAction();
        System.debug('Messages: ' + ApexPages.getMessages());
        System.assert(resultPR != null, 'Result page can not be null.');
        Test.stopTest();
    }
    
    static testMethod void paymentRefundMatchingTest2(){
        String ceId = paymentRefundCEId;
        c2g__codaCashEntry__c ce = [SELECT Id FROM c2g__codaCashEntry__c WHERE id =: ceId];
        ApexPAges.StandardController sc = new ApexPages.StandardController(ce);
        Test.startTest();
        FFC_CEMatchingToolController mtController = new FFC_CEMatchingToolController(sc);
        //Возврат Cash Margin
        mtController.selectedProcedure = 5;
        mtController.initEntities();
        mtController.journalLineItem2.c2g__GeneralLedgerAccount__c = [SELECT Id FROM c2g__codaGeneralLedgerAccount__c WHERE Name='1-2700 Cash margin BNPP'][0].Id;
        PageReference resultPR = mtController.createAction();
        System.debug('Messages: ' + ApexPages.getMessages());
        System.assert(resultPR != null, 'Result page can not be null.');
        Test.stopTest();
    }
    
    /*static testMethod void paymentRefundMatchingTest3(){
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
        PageReference resultPR = mtController.createAction();
        System.debug('Messages: ' + ApexPages.getMessages());
        System.assert(resultPR != null, 'Result page can not be null.');
        Test.stopTest();
    }*/
    
    static testMethod void paymentRefundMatchingTest4(){
        String ceId = paymentRefundCEId;
        c2g__codaCashEntry__c ce = [SELECT Id FROM c2g__codaCashEntry__c WHERE id =: ceId];
        ApexPAges.StandardController sc = new ApexPages.StandardController(ce);
        Test.startTest();
        FFC_CEMatchingToolController mtController = new FFC_CEMatchingToolController(sc);
        //Перевод между счетами - списание
        mtController.selectedProcedure = 7;
        mtController.initEntities();
        mtController.ce.c2g__BankAccount__c = [SELECT Id FROM c2g__codaBankAccount__c WHERE Name = 'BCH BNPP USD'][0].Id;
        mtController.ceLineItem.c2g__CashEntryValue__c = value;
        PageReference resultPR = mtController.createAction();
        System.debug('Messages: ' + ApexPages.getMessages());
        System.assert(resultPR != null, 'Result page can not be null.');
        Test.stopTest();
    }
    
    static testMethod void paymentRefundMatchingTest5(){
        String ceId = paymentRefundCEId;
        c2g__codaCashEntry__c ce = [SELECT Id FROM c2g__codaCashEntry__c WHERE id =: ceId];
        ApexPAges.StandardController sc = new ApexPages.StandardController(ce);
        Test.startTest();
        FFC_CEMatchingToolController mtController = new FFC_CEMatchingToolController(sc);
        //Выданный займ  - возврат
        mtController.selectedProcedure = 3;
        mtController.loanType = 'short';
        mtController.initEntities();
        PageReference resultPR = mtController.createAction();
        System.debug('Messages: ' + ApexPages.getMessages());
        System.assert(resultPR != null, 'Result page can not be null.');
        Test.stopTest();
    }
    
    //---------------------------------------------------------------------------------------------------------------------------------------    
    
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
		//ce.Value = Math.abs(cashEntry.c2g__Value__c);
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