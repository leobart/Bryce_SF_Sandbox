public class FFC_CancelTransactionController {
    
    public String transactionType {get; set;}
    public String objectId {get; set;}
    public String objectName {get; set;}
    public Account objectAccount {get; set;}
    public String objectPeriodId {get; set;}
    public Date objectDate {get; set;}
    public c2g__codaAccountingCurrency__c objectCurrency {get; set;}
    public c2g__codaTransaction__c  objectTransaction{get; set;}
    public boolean cancelAvailable {get; set;}
    public boolean cancelComplete {get; set;}
    public String cancelDescription {get; set;}
    
    private c2g__codaCashEntry__c cashEntry {get; set;}
    private c2g__codaPurchaseInvoice__c pin {get; set;}
    private c2g__codaPurchaseCreditNote__c pcr {get; set;}
    private c2g__codaInvoice__c sin {get; set;}
    private c2g__codaCreditNote__c scr {get; set;}
    
    private c2g.CODAAPICommon.Reference ref;
    private Decimal oldRate;
    private c2g__codaExchangeRate__c accountExchRate;
    private c2g__codaExchangeRate__c documentExchRate;
    private FFC_TransactionHelper trnHelper;
    private PageReference resultPage;
    
    public FFC_CancelTransactionController(){
        cancelAvailable = true;
        transactionType = ApexPages.currentPage().getParameters().get('type');
        objectId = ApexPages.currentPage().getParameters().get('id');
        
        if(transactionType == 'PIN'){
           getPIN(); 
        }else if(transactionType == 'PCR'){
            
        }else if(transactionType == 'SIN'){
            
        }else if(transactionType == 'SCR'){
            
        }else{
            getCE();
        }
        if(objectTransaction == null){
            cancelAvailable = false;
		    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Объект ' + cashEntry.Name + ' не прошел процедуру Post, вы можете изменить его или отменить с помощью кнопки Discard. Процедура "Отмена Транзакции" доступна только для объектов со статусом Complete.')); 
        }else if(objectTransaction.c2g__AccountTotal__c != objectTransaction.c2g__AccountOutstandingTotal__c){
            cancelAvailable = false;            
		    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Объект ' + cashEntry.Name + ' уже связан с другими объектами через Cash Matching. Сделайте сначала Undo Cash Matching для этого объекта')); 
        }
        trnHelper = new FFC_TransactionHelper(objectTransaction.Id);
    }
    
    //---------------------------------------------------------------------------------------------------------------------------------------
    // ACTIONS:
    //---------------------------------------------------------------------------------------------------------------------------------------
    
    public PageReference cencelTransactionAction(){
        resultPage = new PageReference('/apex/ffc_cancelTransactionResult'); 
        cancelComplete = true;
        System.Savepoint savePointState = Database.setSavepoint();
        try{
            prepareRate();
            c2g.CODAAPICashMatchingTypes_7_0.Item itemA = getTrnLineItemForMatch(objectTransaction.Id);
            c2g.CODAAPICashMatchingTypes_7_0.Item itemB;
            if(transactionType == 'PIN'){
                itemB = createItemBForPIN();
            }else if(transactionType == 'PCR'){
                
            }else if(transactionType == 'SIN'){
                
            }else if(transactionType == 'SCR'){
                
            }else{
                itemB = createItemBForCE();
            } 
            c2g.CODAAPICommon.Reference matchingRef = match(itemA, itemB);
            deleteRate();
		    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Создан и связан противоположный по знаку объект: ' + ref.Name)); 
        }catch (Exception e){
		    Database.rollback(savePointState);
		    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Error: ' + e.getMessage()));
		    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Отмена транзакции не выполнена'));
            System.debug(e.getStackTraceString());
            cancelComplete = false;
        }
        return resultPage;
    }
    
    public PageReference cancelAction(){
        return new PageReference('/'+objectId);
    }
    
    public PageReference cashMatchingAction(){
        return new PageReference('/apex/c2g__cashmatching?accountid=' + objectAccount.Id);
    }
    
    
    //---------------------------------------------------------------------------------------------------------------------------------------
    // CE Processing:
    //---------------------------------------------------------------------------------------------------------------------------------------
    
    private void getCE(){
        cashEntry = [SELECT 
                    Id, 
                    Name,
                    c2g__Account__c,
                    c2g__Account__r.Name,
                    c2g__Account__r.c2g__CODAAccountsPayableControl__c,
                    c2g__Account__r.c2g__CODAAccountsReceivableControl__c,
                    c2g__BankAccount__c,
                    c2g__BankAccountCurrency__c,
                    c2g__BankAccountValue__c,
                    c2g__ChargesAmount__c,
                    c2g__CashEntryCurrency__c,
                    c2g__CashEntryCurrency__r.Name, 
                    c2g__CashEntryCurrency__r.c2g__Home__c, 
                    c2g__Value__c,
                    c2g__ChargesGLA__c,
                    c2g__OwnerCompany__c,
                    c2g__OwnerCompany__r.Name,
                    c2g__Date__c,
                    c2g__Description__c,
                    c2g__DiscardReason__c,
                    c2g__LineCharges__c,
                    c2g__NetValue__c,
                    c2g__PaymentMethod__c,
                    c2g__PaymentNumber__c,
                    c2g__Period__c,
                    c2g__Reference__c,
                    c2g__Status__c,
                    c2g__TotalCharges__c,
                    c2g__Type__c,
                    c2g__Transaction__r.id,
                    c2g__Transaction__r.c2g__AccountOutstandingTotal__c, 
                    c2g__Transaction__r.c2g__AccountTotal__c, 
                    c2g__Transaction__r.c2g__DocumentTotal__c 
                  FROM c2g__codaCashEntry__c 
                  WHERE Id=:objectId];  
        objectTransaction = cashEntry.c2g__Transaction__r;
        objectName = cashEntry.Name;
        objectAccount = cashEntry.c2g__Account__r;
        objectPeriodId = cashEntry.c2g__Period__c;
        objectCurrency = cashEntry.c2g__CashEntryCurrency__r;
        objectDate = cashEntry.c2g__Date__c;
    }
    
    private c2g.CODAAPICashMatchingTypes_7_0.Item createItemBForCE(){
        c2g.CODAAPICashEntryTypes_6_0.CashEntry newCashEntry = new c2g.CODAAPICashEntryTypes_6_0.CashEntry();
        newCashEntry.Account = c2g.CODAAPICommon.getRef(cashEntry.c2g__Account__c, null);
        newCashEntry.BankAccount = c2g.CODAAPICommon.getRef(cashEntry.c2g__BankAccount__c, null); 
        newCashEntry.BankAccountCurrency = cashEntry.c2g__BankAccountCurrency__c;  
        newCashEntry.CashEntryCurrency = c2g.CODAAPICommon.getRef(cashEntry.c2g__CashEntryCurrency__c, null);  
        newCashEntry.ChargesGLA = c2g.CODAAPICommon.getRef(CashEntry.c2g__ChargesGLA__c, null);
        newCashEntry.DateValue = cashEntry.c2g__Date__c;  
		String description = 'Cancel: ' + cashEntry.Name + ' Cause: ' + cancelDescription; 
        if(description.length()>255){
            description = description.substring(0,254);
        }
        newCashEntry.Description =  description;
        newCashEntry.PaymentMethod = cashEntry.c2g__PaymentMethod__c;
        newCashEntry.Period = c2g.CODAAPICommon.getRef(cashEntry.c2g__Period__c, null); 
        newCashEntry.Reference = cashEntry.c2g__Reference__c;
        newCashEntry.Status = c2g.CODAAPICashEntryTypes_6_0.enumStatus.InProgress; 
        newCashEntry.TypeRef = invertType(cashEntry.c2g__Type__c);
        newCashEntry.Value = cashEntry.c2g__Value__c;  
        
        //Copy CE Line Items
        List<c2g__codaCashEntryLineItem__c> ceLineItems = [SELECT
                                                               c2g__Account__c,
                                                               c2g__AccountPaymentMethod__c,
                                                               c2g__AccountReference__c,
                                                               c2g__BankAccountValue__c,
                                                               c2g__CashEntryValue__c,
                                                               c2g__OwnerCompany__c,
                                                               c2g__ExternalId__c,
                                                               c2g__PaymentCurrency__c,
                                                               c2g__PaymentValue__c,
                                                               c2g__Charges__c,
                                                               c2g__LineDescription__c,
                                                               c2g__LineNumber__c,
                                                               c2g__NetValue__c,
                                                               c2g__UnitOfWork__c
                                                           FROM c2g__codaCashEntryLineItem__c
                                                           WHERE c2g__CashEntry__c =: cashEntry.Id
                                                          ];
        c2g.CODAAPICashEntryLineItemTypes_6_0.CashEntryLineItems celis = new c2g.CODAAPICashEntryLineItemTypes_6_0.CashEntryLineItems();
		celis.LineItemList = new List<c2g.CODAAPICashEntryLineItemTypes_6_0.CashEntryLineItem>();
        for(c2g__codaCashEntryLineItem__c celi : ceLineItems){
            c2g.CODAAPICashEntryLineItemTypes_6_0.CashEntryLineItem newCeli = new c2g.CODAAPICashEntryLineItemTypes_6_0.CashEntryLineItem();
            newCeli.Account = c2g.CODAAPICommon.getRef(celi.c2g__Account__c, null);
            newCeli.AccountPaymentMethod = celi.c2g__AccountPaymentMethod__c;
            newCeli.BankAccountValue = celi.c2g__BankAccountValue__c;
            newCeli.CashEntryValue = celi.c2g__CashEntryValue__c;
            newCeli.Charges = celi.c2g__Charges__c;
            newCeli.LineDescription = celi.c2g__LineDescription__c;
            celis.LineItemList.add(newCeli);
        }
        newCashEntry.LineItems = celis;
        //Insert newCashEntry into DB
		ref = c2g.CODAAPICashEntry_6_0.CreateCashEntry(null, newCashEntry);
        //Post    
        c2g.CODAAPICashEntry_6_0.PostCashEntry(null, ref);
        c2g.CODAAPICashEntryTypes_6_0.CashEntry csh =  c2g.CODAAPICashEntry_6_0.GetCashEntry(null, ref);
        ref.Name = csh.Name;
        return  getTrnLineItemForMatch (csh.TransactionRef.Id); 
    }
    
    //---------------------------------------------------------------------------------------------------------------------------------------
    // PIN Processing:
    //---------------------------------------------------------------------------------------------------------------------------------------

    private void getPIN(){
        pin = [SELECT 
               		Id,
               		Name,
                    c2g__Account__c,
                    c2g__Account__r.Name,
                    c2g__Period__c,
               		c2g__InvoiceCurrency__c,
                    c2g__InvoiceCurrency__r.Name, 
                    c2g__InvoiceCurrency__r.c2g__Home__c, 
               		c2g__InvoiceDate__c,
                    c2g__DueDate__c,
               		c2g__AccountInvoiceNumber__c,
                    c2g__Transaction__r.id,
                    c2g__Transaction__r.c2g__AccountOutstandingTotal__c, 
                    c2g__Transaction__r.c2g__AccountTotal__c, 
                    c2g__Transaction__r.c2g__DocumentTotal__c 
              FROM c2g__codaPurchaseInvoice__c
              WHERE Id=:objectId];
        objectTransaction = pin.c2g__Transaction__r;
        objectName = pin.Name;
        objectAccount = pin.c2g__Account__r;
        objectPeriodId = pin.c2g__Period__c;
        objectCurrency = pin.c2g__InvoiceCurrency__r;
        objectDate = pin.c2g__InvoiceDate__c;
    }
    
    private c2g.CODAAPICashMatchingTypes_7_0.Item createItemBForPIN(){
        c2g.CODAAPIPurchaseCreditNoteTypes_6_0.PurchaseCreditNote  pcr = new c2g.CODAAPIPurchaseCreditNoteTypes_6_0.PurchaseCreditNote();
        
        pcr.Account = c2g.CODAAPICommon.getRef(pin.c2g__Account__c, null);
        pcr.AccountCreditNoteNumber = 'PIN_CNL_' + pin.c2g__AccountInvoiceNumber__c;
        pcr.CreditNoteDate = pin.c2g__InvoiceDate__c;
        pcr.DueDate = pin.c2g__DueDate__c;
        pcr.CreditNoteCurrency = c2g.CODAAPICommon.getRef(pin.c2g__InvoiceCurrency__c, null);
        pcr.CreditNoteDescription = 'Cancel ' + pin.Name + ' Cause: ' + cancelDescription;
        pcr.CreditNoteStatus = c2g.CODAAPIPurchaseCreditNoteTypes_6_0.enumCreditNoteStatus.InProgress;
        pcr.Period = c2g.CODAAPICommon.getRef(pin.c2g__Period__c, null);
        
        list<c2g__codaPurchaseInvoiceLineItem__c> prodLineItems = [SELECT Id,
                                                                        c2g__Product__c,
                                                                        c2g__InputVATCode__c,
                                                                        c2g__Quantity__c,
                                                                        c2g__TaxValue1__c,
                                                                        c2g__UnitPrice__c
                                                                    FROM c2g__codaPurchaseInvoiceLineItem__c 
                                                                    WHERE c2g__PurchaseInvoice__c=:pin.Id];
        c2g.CODAAPIPurchaseCreditNoteLineTypes_6_0.PurchaseCreditNoteLineItems pcrLineItems = new c2g.CODAAPIPurchaseCreditNoteLineTypes_6_0.PurchaseCreditNoteLineItems();
        pcrLineItems.LineItemList = new List<c2g.CODAAPIPurchaseCreditNoteLineTypes_6_0.PurchaseCreditNoteLineItem>();
        for( c2g__codaPurchaseInvoiceLineItem__c prodItem : prodLineItems){
        	c2g.CODAAPIPurchaseCreditNoteLineTypes_6_0.PurchaseCreditNoteLineItem pcrLineItem = new c2g.CODAAPIPurchaseCreditNoteLineTypes_6_0.PurchaseCreditNoteLineItem();
            pcrLineItem.Product = c2g.CODAAPICommon.getRef(prodItem.c2g__Product__c, null);
            pcrLineItem.InputVATCode = c2g.CODAAPICommon.getRef(prodItem.c2g__InputVATCode__c, null);
            pcrLineItem.Quantity  = prodItem.c2g__Quantity__c;
            pcrLineItem.TaxValue1 = prodItem.c2g__TaxValue1__c;
            pcrLineItem.UnitPrice = prodItem.c2g__UnitPrice__c;
            pcrLineItem.EditTaxValue = true;
        	pcrLineItems.LineItemList.add(pcrLineItem);           
        }      
        pcr.LineItems = pcrLineItems;
        
        
        list<c2g__codaPurchaseInvoiceExpenseLineItem__c> expLineItems = [SELECT Id,
                                                                            c2g__GeneralLedgerAccount__c,
                                                                            c2g__InputVATCode__c,
                                                                            c2g__TaxValue1__c,
                                                                            c2g__NetValue__c
                                                                         FROM c2g__codaPurchaseInvoiceExpenseLineItem__c 
                                                                         WHERE c2g__PurchaseInvoice__c=:pin.Id];
        c2g.CODAAPIPurchaseCreditNoteExLineTypes_6_0.PurchaseCreditNoteExpLineItems pcrExpLineItems = new c2g.CODAAPIPurchaseCreditNoteExLineTypes_6_0.PurchaseCreditNoteExpLineItems();
	    pcrExpLineItems.LineItemList = new List <c2g.CODAAPIPurchaseCreditNoteExLineTypes_6_0.PurchaseCreditNoteExpLineItem>();
        for(c2g__codaPurchaseInvoiceExpenseLineItem__c expItem : expLineItems){
        	c2g.CODAAPIPurchaseCreditNoteExLineTypes_6_0.PurchaseCreditNoteExpLineItem pcrExpLineItem = new c2g.CODAAPIPurchaseCreditNoteExLineTypes_6_0.PurchaseCreditNoteExpLineItem();
            pcrExpLineItem.GeneralLedgerAccount = c2g.CODAAPICommon.getRef(expItem.c2g__GeneralLedgerAccount__c, null);
            pcrExpLineItem.InputVATCode = c2g.CODAAPICommon.getRef(expItem.c2g__InputVATCode__c, null);
            pcrExpLineItem.NetValue = expItem.c2g__NetValue__c;
            pcrExpLineItem.TaxValue1 = expItem.c2g__TaxValue1__c;
            pcrExpLineItem.EditTaxValue = false;
            pcrExpLineItems.LineItemList.add(pcrExpLineItem);
        }
        pcr.ExpLineItems = pcrExpLineItems;
        
        ref = c2g.CODAAPIPurchaseCreditNote_6_0.CreatePurchaseCreditNote(null, pcr);
        c2g.CODAAPIPurchaseCreditNote_6_0.PostPurchaseCreditNote(null, ref);
        c2g.CODAAPIPurchaseCreditNoteTypes_6_0.PurchaseCreditNote pcn = c2g.CODAAPIPurchaseCreditNote_6_0.GetPurchaseCreditNote(null, ref);
        
        ref.Name = pcn.Name;
        return  getTrnLineItemForMatch (pcn.TransactionRef.Id);         
    }
    
    
    //----------------------------------------------------------------------------------------------------------------------------------------------------    
    //----------------------------------------------------------------------------------------------------------------------------------------------------    
    //----------------------------------------------------------------------------------------------------------------------------------------------------
    
    private c2g.CODAAPICashMatchingTypes_7_0.Item getTrnLineItemForMatch(String transactionId){        
        c2g__codaTransactionLineItem__c trnLineItem = [SELECT Id, c2g__HomeValue__c, c2g__AccountOutstandingValue__c 
                                                       FROM c2g__codaTransactionLineItem__c 
                                                       WHERE c2g__Transaction__c =: transactionId 
                                                            AND c2g__LineType__c='Account'];
        
        c2g.CODAAPICashMatchingTypes_7_0.Item item = new  c2g.CODAAPICashMatchingTypes_7_0.Item();
        item.TransactionLineItem = c2g.CODAAPICommon.getRef(trnLineItem.Id, null);	
        item.Paid = trnLineItem.c2g__AccountOutstandingValue__c;
        return item;
    }

    private c2g.CODAAPICommon.Reference match(c2g.CODAAPICashMatchingTypes_7_0.Item itemA, c2g.CODAAPICashMatchingTypes_7_0.Item itemB){
        List<c2g.CODAAPICashMatchingTypes_7_0.Item> items = new List<c2g.CODAAPICashMatchingTypes_7_0.Item>();
        items.add(itemA);
        items.add(itemB);
        c2g.CODAAPICashMatchingTypes_7_0.Configuration config = new c2g.CODAAPICashMatchingTypes_7_0.Configuration();
        config.Account = c2g.CODAAPICommon.getRef(objectAccount.Id, null);
        config.MatchingCurrencyMode = c2g.CODAAPICashMatchingTypes_7_0.enumMatchingCurrencyMode.Account;
        config.MatchingDate = Date.today();
        config.MatchingPeriod = c2g.CODAAPICommon.getRef(objectPeriodId, null);
        return c2g.CODAAPICashMatching_7_0.Match(null, config, items, null);
    }
    
    private c2g.CODAAPICashEntryTypes_6_0.enumType invertType(String ceType){
        if(ceType == 'Payment'){
            return c2g.CODAAPICashEntryTypes_6_0.enumType.PaymentRefund;
        }else if(ceType == 'Payment Refund'){
            return c2g.CODAAPICashEntryTypes_6_0.enumType.Payment;            
        }else if(ceType == 'Receipt'){
            return c2g.CODAAPICashEntryTypes_6_0.enumType.Refund;                        
        }else {
            return c2g.CODAAPICashEntryTypes_6_0.enumType.Receipt;
        }
	}
    
    private void prepareRate(){
        accountExchRate = null;
        documentExchRate = null;
        if(trnHelper.accCurrId != trnHelper.homeCurrId){
            accountExchRate = getRate(trnHelper.accCurrId);
            if(accountExchRate == null){
                accountExchRate =  new c2g__codaExchangeRate__c(c2g__ExchangeRateCurrency__c = trnHelper.accCurrId,
                                                        c2g__Rate__c = trnHelper.accCurrRate,
                                                        c2g__StartDate__c = objectDate);
                insert accountExchRate;
            }else{
                accountExchRate.c2g__Rate__c = trnHelper.accCurrRate;
                update accountExchRate;
            }
        }
        
        if(trnHelper.docCurrId != trnHelper.homeCurrId && trnHelper.docCurrId != trnHelper.accCurrId){
            documentExchRate = getRate(trnHelper.docCurrId);
            if(documentExchRate == null){
                documentExchRate =  new c2g__codaExchangeRate__c(c2g__ExchangeRateCurrency__c = trnHelper.docCurrId,
                                                        c2g__Rate__c = trnHelper.docCurrRate,
                                                        c2g__StartDate__c = objectDate);
                insert documentExchRate;
            }else{
                documentExchRate.c2g__Rate__c = trnHelper.docCurrRate;
                update documentExchRate;
            }
        }
        
    }
    
    private c2g__codaExchangeRate__c getRate(String currId){
    	c2g__codaExchangeRate__c[] erList = [SELECT Id, c2g__Rate__c, c2g__StartDate__c 
                                             FROM c2g__codaExchangeRate__c 
                                             WHERE c2g__StartDate__c =: objectDate 
                                               AND c2g__ExchangeRateCurrency__c =: currId]; 
		if(erList.size() > 0) return erList[0];
        return null;
    }

    private void deleteRate(){
        if(accountExchRate != null) delete accountExchRate;
        if(documentExchRate != null) delete documentExchRate;
    }
}