public class FFC_CEMatchingToolController{
    
    //Constants: ------------------------------------------------------------------
    //private final static String GLA_2_2200_APC = '2-2200 Accounts payable control';
    private final static String GLA_1_2210_STLI = '1-2210 Short term loans issued';
    private final static String GLA_1_1260_LTLI = '1-1260 Long term loans issued';
    private final static String GLA_2_3000_STL = '2-3000 Short term loans';
    private final static String GLA_2_1100_LTLR = '2-1100 Long Term Loans received';
    private final static String[] GLA_ACCOUNTS = new String[]{GLA_1_2210_STLI, GLA_1_1260_LTLI, GLA_2_3000_STL, GLA_2_1100_LTLR};

    private final static String JLI_TYPE_ACC_VENDOR = 'Account - Vendor';
    private final static String JLI_TYPE_ACC_CUSTOMER = 'Account - Customer';
    private final static String JLI_TYPE_GLA = 'General Ledger Account';
    
    private final static String CE_TYPE_PAYMENT = 'Payment';
    private final static String CE_TYPE_PAYMENT_REFUND = 'Payment Refund';
    private final static String CE_TYPE_RECEIPT = 'Receipt';
    private final static String CE_TYPE_REFUND = 'Refund';
    //----------------------------------------------------------------------------
    
    public Integer selectedProcedure {get; set;}    
    public c2g__codaCashEntry__c cashEntry {get; set;}
    public List<c2g__codaCashEntryLineItem__c> cashEntryLineItems {get; set;}
    public Boolean noErrors {get; set;}
    public String paymentType{get{if(cashEntry.c2g__Type__c==CE_TYPE_PAYMENT || cashEntry.c2g__Type__c==CE_TYPE_REFUND){
                        return 'outcoming';
                                  }else{
                                      return 'incoming';
                                    }
                                 }
                             }
    public String paymentSideType{get{if(cashEntry.c2g__Type__c==CE_TYPE_PAYMENT || cashEntry.c2g__Type__c==CE_TYPE_PAYMENT_REFUND){
                        return 'vendor';
                                  }else{
                                      return 'customer';
                                    }
                                 }
                             }
    
    public Boolean paperInvoice {get; set;}
    public Boolean useAnotherCE {get; set;}
    public Boolean useAnotherPIN {get; set;}
    public String loanType {get; set;}
    
    public c2g__codaPurchaseInvoiceLineItem__c anotherPINLine {get; set;}
    
    public c2g__codaPurchaseInvoice__c payableInvoice{get; set;}
    public c2g__codaPurchaseInvoiceLineItem__c payableInvoiceLineItem {get; set;}
    public c2g__codaPurchaseInvoiceExpenseLineItem__c payableInvoiceExpItem {get; set;}
    //public BRC_MT_PINMap pinMap {get; set;}
    
    public c2g__codaJournal__c journal {get; set;}
    public c2g__codaJournalLineItem__c journalLineItem1 {get; set;}
    public c2g__codaJournalLineItem__c journalLineItem2 {get; set;}
    public c2g__codaCreditNote__c creditNote {get; set;}
    public c2g__codaCreditNoteLineItem__c creditNoteLineItem {get; set;}
    public c2g__codaPurchaseCreditNote__c payableCreditNote {get; set;}
    public c2g__codaPurchaseCreditNoteLineItem__c payableCreditNoteLineItem {get; set;}
    public c2g__codaCashEntry__c ce {get; set;} 
    public c2g__codaCashEntryLineItem__c ceLineItem {get; set;} 
    public c2g__codaInvoice__c invoice {get; set;}
    public c2g__codaInvoiceLineItem__c invoiceLineItem {get; set;}
        
    public Map<String, c2g__codaGeneralLedgerAccount__c> glaAccountsMap; 
    
    public List<SelectOption> lineTypeSO {get; set;}
    public Integer lineType {get; set;}
    
    
    private FFC_TransactionHelper thA, thB;
    private Set<c2g__codaExchangeRate__c> exchangeRates;
    private c2g__codaAccountingCurrency__c currB; //document B currency
    private Decimal valueB;
    private Date dateB;
    private c2g.CODAAPICashMatchingTypes_8_0.Item itemA, itemB;
    private c2g.CODAAPICommon.Reference refB;
    private c2g__codaAccountingCurrency__c accCurr;

    public FFC_CurrencyRatesManager crManager {get; set;}

    public Attachment attachment {get; set;}
    
    public FFC_CEMatchingToolController(){
        
    }
    
    public FFC_CEMatchingToolController(ApexPages.StandardController controller){
        attachment = new Attachment();
        anotherPINLine = new c2g__codaPurchaseInvoiceLineItem__c();
        cashEntry = [SELECT 
                    Id, 
                    Name,
                    c2g__Account__c,
                    c2g__Account__r.Name,
                    c2g__Account__r.c2g__CODAAccountTradingCurrency__c,
                    c2g__Account__r.c2g__CODAAccountsPayableControl__c,
                    c2g__Account__r.c2g__CODAAccountsReceivableControl__c,
                    c2g__AccountDimension1__c,
                    c2g__AccountDimension2__c,
                    c2g__AccountDimension3__c,
                    c2g__AccountDimension4__c,
                    c2g__BankAccount__c,
                    c2g__BankAccountCurrency__c,
                    c2g__BankAccountDimension1__c,
                    c2g__BankAccountDimension2__c,
                    c2g__BankAccountDimension3__c,
                    c2g__BankAccountDimension4__c,
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
                    c2g__ChargesGLADimension1__c,
                    c2g__ChargesGLADimension2__c,
                    c2g__ChargesGLADimension3__c,
                    c2g__ChargesGLADimension4__c,
                    c2g__DiscardReason__c,
                    c2g__LineCharges__c,
                    c2g__NetValue__c,
                    c2g__PaymentMethod__c,
                    c2g__PaymentNumber__c,
                    c2g__Period__c,
                    c2g__Reference__c,
                    c2g__Status__c,
                    c2g__TotalCharges__c,
                    c2g__Transaction__r.id,
                    c2g__Transaction__r.c2g__AccountOutstandingTotal__c, 
                    c2g__Transaction__r.c2g__AccountTotal__c, 
                    c2g__Transaction__r.c2g__DocumentTotal__c,                      
                    c2g__Type__c
                  FROM c2g__codaCashEntry__c 
                  WHERE Id=:controller.getId()];         
        //Check current company and Cash Entry owner company
        noErrors = true;
        list<c2g__codaAccountingCurrency__c> accCurrList= [SELECT Id, Name, c2g__Home__c 
                                                           FROM c2g__codaAccountingCurrency__c 
                                                           WHERE Name=: cashEntry.c2g__Account__r.c2g__CODAAccountTradingCurrency__c 
                                                           	     AND c2g__OwnerCompany__c=:cashEntry.c2g__OwnerCompany__c];
        if(accCurrList.size() > 0){
            accCurr = accCurrList[0];
        }else{
            throw new CEMatchingToolException('В эккунте не заполнено или неверно задано поле Account Trading Currency');
        }
        List<String> companies = c2g.CODAAPICompany_2_0.GetCurrentCompanies(null);
        if(companies.size()!=1){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Select one company for perform this operation')); 
            noErrors = false;
            return; 
        }
        if(companies[0] != cashEntry.c2g__OwnerCompany__r.Name){
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Select company: "' + cashEntry.c2g__OwnerCompany__r.Name + '" before for perform this operation'));  
      		noErrors = false;
            return;
        }
        //Check match
        if(cashEntry.c2g__Transaction__c != null){
            c2g__codaTransactionLineItem__c trnLineItem = [SELECT Id, Aged_analysis_category__c 
                                                           FROM c2g__codaTransactionLineItem__c 
                                                           WHERE c2g__Transaction__c =: cashEntry.c2g__Transaction__c
                                                               AND c2g__LineNumber__c=1];
            if(trnLineItem.Aged_analysis_category__c == 'Matched'){
                noErrors = false;
              ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Cash Entry already matched!'));  
          return;
            }            
        }
        if(cashEntry.c2g__Transaction__c != null) thA = new FFC_TransactionHelper(cashEntry.c2g__Transaction__c);
        cashEntryLineItems = [SELECT
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
                              WHERE c2g__CashEntry__c =: cashEntry.Id];
        //init section
        if(cashEntry.c2g__Transaction__c != null){
            thA = new FFC_TransactionHelper(cashEntry.c2g__Transaction__c);
            itemA =  getTrnLineItem(cashEntry.c2g__Transaction__c);            
        }
        crManager  = new FFC_CurrencyRatesManager(cashEntry.c2g__Account__r.c2g__CODAAccountTradingCurrency__c);
        crManager.updateA(thA, cashEntry.c2g__CashEntryCurrency__r.Name, cashEntry.c2g__Value__c, cashEntry.c2g__Date__c);
        lineType = 1;
        lineTypeSO = new List<SelectOption>();
        lineTypeSO.add(new SelectOption('0', 'Product'));
        lineTypeSO.add(new SelectOption('1', 'Expense'));
        paperInvoice = true;
        useAnotherCE = false;
        useAnotherPIN = true;
        loanType = 'short';

        ceLineItem = new c2g__codaCashEntryLineItem__c();
        if(cashEntry.c2g__Type__c == CE_TYPE_PAYMENT || cashEntry.c2g__Type__c == CE_TYPE_RECEIPT){
            selectedProcedure = 2;
        }else if(cashEntry.c2g__Type__c == CE_TYPE_PAYMENT_REFUND){
        selectedProcedure = 3;
        }else {
            selectedProcedure = 8;
        } 
        if(cashEntry.c2g__Description__c != null && cashEntry.c2g__Description__c.contains('Currency Exchange') && 
           (cashEntry.c2g__Type__c == CE_TYPE_PAYMENT || cashEntry.c2g__Type__c == CE_TYPE_PAYMENT_REFUND)){
          selectedProcedure = 6;
            useAnotherCE = true;
            c2g__codaCashEntry__c[] tmpCEs = [SELECT Id FROM c2g__codaCashEntry__c 
                                              WHERE Id!=:cashEntry.Id 
                                              AND c2g__Description__c=:cashEntry.c2g__Description__c
                                              AND c2g__Date__c=:cashEntry.c2g__Date__c];
            if(tmpCEs.size()!=0) ceLineItem.c2g__CashEntry__c = tmpCEs[0].Id;
        }
        initAccounts();
        initEntities();

    }
    
    
    
    public void initEntities(){
        try{
            currB = cashEntry.c2g__CashEntryCurrency__r;
            valueB = cashEntry.c2g__Value__c;
            thB = null;
            dateB = cashEntry.c2g__Date__c;
            if(useAnotherPIN && selectedProcedure == 2 && paperInvoice && paymentType == 'outcoming'){
                checkAnotherPIN(anotherPINLine.c2g__PurchaseInvoice__c);            
            }
            if(useAnotherCE && (selectedProcedure == 6 || selectedProcedure == 7 || selectedProcedure == 9)){
                checkAnotherCE(ceLineItem.c2g__CashEntry__c);
            }
            
            crManager.updateB(thB, currB.Name, valueB, dateB);
            crManager.updateRates();
            
            initJNL();
            initPIN();
            initCE();
            initSCR();
            initPCR();
            initSIN();       
        }catch (exception e){
            ApexPages.addMessages(e);
        }
    }
        
    private void initAccounts(){
        glaAccountsMap  = new Map<String, c2g__codaGeneralLedgerAccount__c>();
        c2g__codaGeneralLedgerAccount__c[] glaAccs = [SELECT Id, Name FROM c2g__codaGeneralLedgerAccount__c WHERE Name IN: GLA_ACCOUNTS];
        for(c2g__codaGeneralLedgerAccount__c gla : glaAccs){
            glaAccountsMap.put(gla.Name, gla);
        }
    }
    
    
    //Action
    public PageReference createAction(){
        String trnBId;
        System.Savepoint rollbackPoint = Database.setSavepoint();
        try{
            
            if(selectedProcedure == 2 && !paperInvoice && paymentType == 'outcoming' ||
               selectedProcedure == 3 ||
               selectedProcedure == 5 ||
               selectedProcedure == 8){
                   refB = createJNL();
               }else if (selectedProcedure == 2 && paperInvoice && paymentType == 'outcoming' && !useAnotherPIN){
                   refB = createPIN();
               }else if (selectedProcedure == 2 && paymentType == 'incoming'){
                   refB = createSIN();
               }else if (selectedProcedure == 9 && paymentType == 'outcoming' && !useAnotherCE){
                   refB = createSCR();
               }else if (selectedProcedure == 10 && paymentType == 'incoming'){
                   refB = createPCR();
               }else if((selectedProcedure == 6 || selectedProcedure == 7) && !useAnotherCE){
                   refB = createCE();
               }
            if(refB != null){
            	prepareRatesAndPost();
                c2g.CODAAPICommon.Reference matchingRef = match(itemA, itemB);
                PageReference pr = new PageReference('/apex/ffc_CEMatchingToolResultPage');
                c2g__codaMatchingReference__c mr = [SELECT Name FROM c2g__codaMatchingReference__c WHERE id =: matchingRef.Id];
                pr.getParameters().put('cshId',cashEntry.Id);
                pr.getParameters().put('cshName',cashEntry.Name);
                pr.getParameters().put('eId', refB.Id);
                pr.getParameters().put('eName',refB.Name);
                pr.getParameters().put('mrId', matchingRef.Id);
                pr.getParameters().put('mrName', mr.Name);
                return pr;
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Undefined Procedure'));
            }            
        }catch(Exception e){
            system.debug('ERROR MESAGE: ' + e.getMessage());
            system.debug('ERROR STACK: ' + e.getStackTraceString() + ' line: ' +  e.getLineNumber());
            Database.rollback(rollbackPoint); 
            ApexPages.addMessages(e);
            return null;
        }
        return null;
    }
           
    private void prepareRatesAndPost(){
         if(thA != null && thB == null){
            crManager.insertRates('B');
            postB();
        }else if(thA == null && thB != null){
            crManager.insertRates('A');
            postSourceCSH();            
        }else if(thA == null && thB == null){
            crManager.insertRates('AB');
            postB();
            postSourceCSH();
        }
        crManager.deleteRates();
    }
        
    private void postB(){
    	if(selectedProcedure == 2 && !paperInvoice && paymentType == 'outcoming' ||
           selectedProcedure == 3 ||
           selectedProcedure == 5 ||
           selectedProcedure == 8){
        	postJNL(refB);
		}else if (selectedProcedure == 2 && paperInvoice && paymentType == 'outcoming'){
        	postPIN(refB);
        }else if (selectedProcedure == 2 && paymentType == 'incoming'){
        	postSIN(refB);
        }else if (selectedProcedure == 9 && paymentType == 'outcoming' && !useAnotherCE){
        	postSCR(refB);
        }else if (selectedProcedure == 10 && paymentType == 'incoming'){
        	postPCR(refB);
        }else if((selectedProcedure == 6 || selectedProcedure == 7) && !useAnotherCE){
        	postCSH(refB);
        }else if((selectedProcedure == 6 || selectedProcedure == 7 || selectedProcedure == 9) && useAnotherCE){
        	postCSH(refB);
        }        
    }
    
    
    //Action
    public PageReference cancelAction(){
        return new PageReference('/' + cashEntry.Id);
    }
    
    private void initSIN(){
        if (selectedProcedure == 2 && paymentType == 'incoming'){
            invoice = new c2g__codaInvoice__c();
            invoiceLineItem = new c2g__codaInvoiceLineItem__c();
            invoice.c2g__Account__c = cashEntry.c2g__Account__c;
            invoice.c2g__CustomerReference__c = cashEntryLineItems[0].c2g__AccountReference__c;
            invoice.c2g__InvoiceDate__c = cashEntry.c2g__Date__c;
            invoice.c2g__DueDate__c = cashEntry.c2g__Date__c;
            invoice.c2g__InvoiceCurrency__c= cashEntry.c2g__CashEntryCurrency__c;
            invoice.c2g__Period__c= cashEntry.c2g__Period__c;
            invoice.c2g__InvoiceDescription__c= cashEntry.c2g__Description__c;
            invoiceLineItem.c2g__Quantity__c = 1;
            invoiceLineItem.c2g__TaxRate1__c = 0;
            invoiceLineItem.c2g__UnitPrice__c = cashEntryLineItems[0].c2g__CashEntryValue__c;              
        }        
    }
    
    private c2g.CODAAPICommon.Reference createSIN(){
        c2g.CODAAPIInvoiceTypes_7_0.Invoice sin = new c2g.CODAAPIInvoiceTypes_7_0.Invoice();
        c2g.CODAAPIInvoiceLineItemTypes_7_0.InvoiceLineItem sinLineItem = new c2g.CODAAPIInvoiceLineItemTypes_7_0.InvoiceLineItem();
        c2g.CODAAPIInvoiceLineItemTypes_7_0.InvoiceLineItems sinLineItems = new c2g.CODAAPIInvoiceLineItemTypes_7_0.InvoiceLineItems();
        
        sin.Account = c2g.CODAAPICommon.getRef(invoice.c2g__Account__c, null);
        sin.CustomerReference = invoice.c2g__CustomerReference__c;
        sin.DueDate = invoice.c2g__DueDate__c;
        sin.InvoiceDate = invoice.c2g__InvoiceDate__c;
        sin.InvoiceCurrency = c2g.CODAAPICommon.getRef(invoice.c2g__InvoiceCurrency__c, null);
        sin.InvoiceStatus = c2g.CODAAPIInvoiceTypes_7_0.enumInvoiceStatus.InProgress;
        sin.InvoiceDescription = invoice.c2g__InvoiceDescription__c;
        sin.Period = c2g.CODAAPICommon.getRef(invoice.c2g__Period__c, null);
        sin.PrintedText1AllowEdit = false;
        sin.PrintedText2AllowEdit = false;
        sin.PrintedText3AllowEdit = false;
        sin.PrintedText4AllowEdit = false;
        sin.PrintedText5AllowEdit = false;
        //sin.Usepartperiods = true;
        
        sinLineItem.Product = c2g.CODAAPICommon.getRef(invoiceLineItem.c2g__Product__c, null);
        sinLineItem.Quantity = invoiceLineItem.c2g__Quantity__c;
        sinLineItem.TaxRate1 = invoiceLineItem.c2g__TaxRate1__c;
        sinLineItem.UnitPrice = cashEntryLineItems[0].c2g__CashEntryValue__c;
        sinLineItem.Usepartperiods = false; //???

        sinLineItems.LineItemList = new List<c2g.CODAAPIInvoiceLineItemTypes_7_0.InvoiceLineItem>();
        sinLineItems.LineItemList.add(sinLineItem);
        
        sin.LineItems = sinLineItems;
        
        currB = getCurrency(invoice.c2g__InvoiceCurrency__c);
        valueB = sinLineItem.UnitPrice;
        dateB = invoice.c2g__InvoiceDate__c;
            
    return c2g.CODAAPISalesInvoice_7_0.CreateInvoice(null, sin);
    }
    
    private void postSIN(c2g.CODAAPICommon.Reference ref){
        c2g.CODAAPISalesInvoice_7_0.PostInvoice(null, ref);
        c2g.CODAAPIInvoiceTypes_7_0.Invoice sin =  c2g.CODAAPISalesInvoice_7_0.GetInvoice(null, ref);
        ref.Name = sin.Name;
        thB = new FFC_TransactionHelper(sin.TransactionRef.Id);
        itemB = getTrnLineItem(sin.TransactionRef.Id);
    }
    
    private void initPIN(){
        if(selectedProcedure == 2 && paperInvoice && paymentType == 'outcoming'){
            //pinMap = new BRC_MT_PINMap(cashEntry);
            payableInvoice = new c2g__codaPurchaseInvoice__c();
            payableInvoiceLineItem = new c2g__codaPurchaseInvoiceLineItem__c();
            payableInvoiceExpItem = new c2g__codaPurchaseInvoiceExpenseLineItem__c();
            
            payableInvoice.c2g__Account__c = cashEntry.c2g__Account__c;
            payableInvoice.c2g__AccountInvoiceNumber__c = cashEntry.c2g__Reference__c;
            payableInvoice.c2g__InvoiceDate__c = cashEntry.c2g__Date__c;
            payableInvoice.c2g__DueDate__c = cashEntry.c2g__Date__c;
            payableInvoice.c2g__InvoiceCurrency__c = cashEntry.c2g__CashEntryCurrency__c;
            payableInvoice.c2g__InvoiceDescription__c = cashEntry.c2g__Description__c;
            payableInvoice.c2g__Period__c = cashEntry.c2g__Period__c; 
            
            payableInvoiceLineItem.c2g__Quantity__c = 1;
            payableInvoiceLineItem.c2g__TaxRate1__c = 0;
            payableInvoiceLineItem.c2g__UnitPrice__c = cashEntryLineItems[0].c2g__CashEntryValue__c;  
            
            payableInvoiceExpItem.c2g__NetValue__c = cashEntryLineItems[0].c2g__CashEntryValue__c;
            payableInvoiceExpItem.c2g__TaxRate1__c = 0;
            payableInvoiceExpItem.c2g__TaxValue1__c = 0;
        }
    }
    
    private c2g.CODAAPICommon.Reference createPIN(){
        c2g.CODAAPIPurchaseInvoiceTypes_8_0.PurchaseInvoice pin = new c2g.CODAAPIPurchaseInvoiceTypes_8_0.PurchaseInvoice();
        
        pin.Account = c2g.CODAAPICommon.getRef(payableInvoice.c2g__Account__c, null);
        pin.AccountInvoiceNumber = payableInvoice.c2g__AccountInvoiceNumber__c;
        pin.DueDate = payableInvoice.c2g__DueDate__c;
        pin.InvoiceDate = payableInvoice.c2g__InvoiceDate__c;
        pin.InvoiceCurrency = c2g.CODAAPICommon.getRef(payableInvoice.c2g__InvoiceCurrency__c, null);
        pin.InvoiceStatus = c2g.CODAAPIPurchaseInvoiceTypes_8_0.enumInvoiceStatus.InProgress;
        pin.InvoiceDescription = payableInvoice.c2g__InvoiceDescription__c;
        pin.Period = c2g.CODAAPICommon.getRef(payableInvoice.c2g__Period__c, null);

        if (lineType == 0){
            //Product Line
          c2g.CODAAPIPurchaseInvoiceLineItemTypes_8_0.PurchaseInvoiceLineItem pinLineItem = 
                new c2g.CODAAPIPurchaseInvoiceLineItemTypes_8_0.PurchaseInvoiceLineItem();
          c2g.CODAAPIPurchaseInvoiceLineItemTypes_8_0.PurchaseInvoiceLineItems pinLineItems = 
                new c2g.CODAAPIPurchaseInvoiceLineItemTypes_8_0.PurchaseInvoiceLineItems();
            pinLineItem.Product = c2g.CODAAPICommon.getRef(payableInvoiceLineItem.c2g__Product__c, null);
            pinLineItem.Quantity = payableInvoiceLineItem.c2g__Quantity__c;
            //pinLineItem.TaxValue1 = payableInvoiceLineItem.c2g__TaxValue1__c;
            pinLineItem.UnitPrice = payableInvoiceLineItem.c2g__UnitPrice__c;
            
            pinLineItems.LineItemList = new List<c2g.CODAAPIPurchaseInvoiceLineItemTypes_8_0.PurchaseInvoiceLineItem>();
            pinLineItems.LineItemList.add(pinLineItem);
            
            pin.LineItems = pinLineItems;
            valueB = payableInvoiceLineItem.c2g__UnitPrice__c;
            
        }else{
          //Expense Line
            c2g.CODAAPIPurchaseInvoiceExpLineTypes_8_0.PurchaseInvoiceExpenseLineItems pinExpItems = 
                new c2g.CODAAPIPurchaseInvoiceExpLineTypes_8_0.PurchaseInvoiceExpenseLineItems();
          c2g.CODAAPIPurchaseInvoiceExpLineTypes_8_0.PurchaseInvoiceExpenseLineItem pinExpItem = 
                new c2g.CODAAPIPurchaseInvoiceExpLineTypes_8_0.PurchaseInvoiceExpenseLineItem();
            pinExpItem.GeneralLedgerAccount = c2g.CODAAPICommon.getRef(payableInvoiceExpItem.c2g__GeneralLedgerAccount__c, null);
            //pinExpItem.LineDescription = payableInvoiceExpItem.c2g__LineDescription__c;
            //pinExpItem.InputVATCode = c2g.CODAAPICommon.getRef(payableInvoiceExpItem.c2g__InputVATCode__c, null);
            //pinExpItem.TaxValue1 = payableInvoiceExpItem.c2g__TaxValue1__c;
            pinExpItem.NetValue = payableInvoiceExpItem.c2g__NetValue__c;
            
            pinExpItems.LineItemList = new List<c2g.CODAAPIPurchaseInvoiceExpLineTypes_8_0.PurchaseInvoiceExpenseLineItem>();
            pinExpItems.LineItemList.add(pinExpItem);
            
            pin.ExpLineItems = pinExpItems;
            valueB = payableInvoiceExpItem.c2g__NetValue__c;
            
        }
        
        currB = getCurrency(payableInvoice.c2g__InvoiceCurrency__c);
        dateB = payableInvoice.c2g__InvoiceDate__c;
    return c2g.CODAAPIPurchaseInvoice_8_0.CreatePurchaseInvoice(null, pin);
    }
    
    private void postPIN(c2g.CODAAPICommon.Reference ref){
        c2g__codaPurchaseInvoice__c p = [SELECT Id FROM c2g__codaPurchaseInvoice__c WHERE Id=:ref.Id];
        p.ffbext__Approved__c = true;
        update p;
        c2g.CODAAPIPurchaseInvoice_8_0.PostPurchaseInvoice(null, ref);
        c2g.CODAAPIPurchaseInvoiceTypes_8_0.PurchaseInvoice pin =  c2g.CODAAPIPurchaseInvoice_8_0.GetPurchaseInvoice(null, ref);
        ref.Name = pin.Name;
        thB = new FFC_TransactionHelper(pin.TransactionRef.Id);
        itemB = getTrnLineItem(pin.TransactionRef.Id);
    }
    
    private void initCE(){
        ce = new c2g__codaCashEntry__c();
        ce.c2g__PaymentMethod__c = 'Electronic';
        ce.c2g__Account__c = cashEntry.c2g__Account__c;
        ce.c2g__Date__c = cashEntry.c2g__Date__c;
        ce.c2g__Period__c = cashEntry.c2g__Period__c;
        if(selectedProcedure == 6){
            if(cashEntry.c2g__Type__c == CE_TYPE_PAYMENT){
            ce.c2g__Description__c = 'Currency Exchange from ' + cashEntry.Name;
            }else{
            ce.c2g__Description__c = 'Currency Exchange to' + cashEntry.Name;
            }
            ce.c2g__Type__c = invertCEType(cashEntry.c2g__Type__c); 
        } else if (selectedProcedure == 7){
            if(cashEntry.c2g__Type__c == CE_TYPE_PAYMENT){
            ce.c2g__Description__c = 'Transfer from ' + cashEntry.Name;
            }else{
            ce.c2g__Description__c = 'Transfer to' + cashEntry.Name;
            }
            //ce.c2g__Description__c = 'Transfer' + cashEntry.Name;
            //ce.c2g__Description__c = cashEntry.c2g__Description__c;
            ce.c2g__Type__c = invertCEType(cashEntry.c2g__Type__c); 
            ce.c2g__CashEntryCurrency__c = cashEntry.c2g__CashEntryCurrency__c;
          
        }
        ceLineItem.c2g__CashEntryValue__c = cashEntryLineItems[0].c2g__CashEntryValue__c;
    }
    
    public c2g.CODAAPICommon.Reference createCE(){
        c2g.CODAAPICashEntryTypes_6_0.CashEntry newCashEntry = new c2g.CODAAPICashEntryTypes_6_0.CashEntry();
        c2g.CODAAPICashEntryLineItemTypes_6_0.CashEntryLineItem newCeli = new c2g.CODAAPICashEntryLineItemTypes_6_0.CashEntryLineItem();
        c2g.CODAAPICashEntryLineItemTypes_6_0.CashEntryLineItems celis = new c2g.CODAAPICashEntryLineItemTypes_6_0.CashEntryLineItems();
    celis.LineItemList = new List<c2g.CODAAPICashEntryLineItemTypes_6_0.CashEntryLineItem>();
        c2g__codaBankAccount__c bAcc = [SELECT  c2g__BankAccountCurrency__c, 
                                            c2g__BankAccountCurrency__r.Name, 
                                              c2g__GeneralLedgerAccount__c 
                                        FROM c2g__codaBankAccount__c 
                         WHERE id=:ce.c2g__BankAccount__c];
        if(selectedProcedure == 6){
            if(bAcc.c2g__BankAccountCurrency__r.Name == cashEntry.c2g__CashEntryCurrency__r.Name){
                throw new CEMatchingToolException('Валюта Bank Account должна быть отличной от ' + cashEntry.c2g__CashEntryCurrency__r.Name);
            }         
            newCashEntry.Account = c2g.CODAAPICommon.getRef(ce.c2g__Account__c, null);
            newCashEntry.BankAccount = c2g.CODAAPICommon.getRef(ce.c2g__BankAccount__c, null);  //M
            newCashEntry.BankAccountCurrency = bAcc.c2g__BankAccountCurrency__r.Name;  //M
            newCashEntry.CashEntryCurrency = c2g.CODAAPICommon.getRef(bAcc.c2g__BankAccountCurrency__c, null);  //M
            newCashEntry.ChargesGLA = c2g.CODAAPICommon.getRef(bAcc.c2g__GeneralLedgerAccount__c, null);
            newCashEntry.DateValue = ce.c2g__Date__c;
            newCashEntry.Description = clip(ce.c2g__Description__c, 255);
            newCashEntry.PaymentMethod = cashEntry.c2g__PaymentMethod__c; //M
            newCashEntry.Period = c2g.CODAAPICommon.getRef(ce.c2g__Period__c, null); //M
            //newCashEntry.Reference = ce.c2g__Reference__c;
            newCashEntry.Status = c2g.CODAAPICashEntryTypes_6_0.enumStatus.InProgress; //M
            newCashEntry.TypeRef = apiCEType(ce.c2g__Type__c);  //M  
            newCashEntry.Value = Math.abs(ceLineItem.c2g__CashEntryValue__c);  //M
            
            //Line Item:
            newCeli.Account = c2g.CODAAPICommon.getRef(ce.c2g__Account__c, null);//M
            newCeli.AccountPaymentMethod = ce.c2g__PaymentMethod__c;
            //newCeli.AccountReference = celi.AccountReference;
            newCeli.BankAccountValue = ceLineItem.c2g__CashEntryValue__c;
            //newCeli.CashEntry = newCashEntry;
            //newCeli.CashEntryCurrency = celi.CashEntryCurrency;
            //newCeli.CashEntryDate = celi.CashEntryDate; //!!!
            newCeli.CashEntryValue = ceLineItem.c2g__CashEntryValue__c; //M
            newCeli.Charges = 0;
            newCeli.LineDescription = ceLineItem.c2g__LineDescription__c;
            //newCeli.OwnerCompany = celi.OwnerCompany;
            celis.LineItemList.add(newCeli);
      newCashEntry.LineItems = celis;            
        }else{
            if(bAcc.c2g__BankAccountCurrency__c != cashEntry.c2g__CashEntryCurrency__c){
                throw new CEMatchingToolException('Неподходящий Bank Account. Валюта Bank Account может быть только ' + cashEntry.c2g__CashEntryCurrency__r.Name);
            }
            newCashEntry.Account = c2g.CODAAPICommon.getRef(cashEntry.c2g__Account__c, null);
            newCashEntry.BankAccount = c2g.CODAAPICommon.getRef(ce.c2g__BankAccount__c, null);  //M
            newCashEntry.BankAccountCurrency = bAcc.c2g__BankAccountCurrency__r.Name;  //M
            newCashEntry.CashEntryCurrency = c2g.CODAAPICommon.getRef(cashEntry.c2g__CashEntryCurrency__c, null);  //M
            //newCashEntry.ChargesAmount = cashEntry.ChargesAmount;
            newCashEntry.ChargesGLA = c2g.CODAAPICommon.getRef(CashEntry.c2g__ChargesGLA__c, null);
            newCashEntry.DateValue = ce.c2g__Date__c;  //M
            String description = 'From: ' + cashEntry.Name + ' '; 
            if(cashEntry.c2g__Description__c != null) description = description + cashEntry.c2g__Description__c;
            newCashEntry.Description = clip(description, 255);
            //newCashEntry.DiscardReason = cashEntry.DiscardReason;
            //newCashEntry.OwnerCompany = cashEntry.OwnerCompany;
            newCashEntry.PaymentMethod = cashEntry.c2g__PaymentMethod__c; //M
            //newCashEntry.PaymentNumber = cashEntry.PaymentNumber;
            newCashEntry.Period = c2g.CODAAPICommon.getRef(cashEntry.c2g__Period__c, null); //M
            newCashEntry.Reference = cashEntry.c2g__Reference__c;
            newCashEntry.Status = c2g.CODAAPICashEntryTypes_6_0.enumStatus.InProgress; //M
            newCashEntry.TypeRef = apiCEType(ce.c2g__Type__c);  //M  invert type
            newCashEntry.Value = cashEntry.c2g__Value__c;  //M
            
            //Copy CLine Items
            celis.LineItemList = new List<c2g.CODAAPICashEntryLineItemTypes_6_0.CashEntryLineItem>();
            for(c2g__codaCashEntryLineItem__c celi : cashEntryLineItems){
                newCeli = new c2g.CODAAPICashEntryLineItemTypes_6_0.CashEntryLineItem();
                newCeli.Account = c2g.CODAAPICommon.getRef(celi.c2g__Account__c, null);//M
                newCeli.AccountPaymentMethod = celi.c2g__AccountPaymentMethod__c;
                //newCeli.AccountReference = celi.AccountReference;
                newCeli.BankAccountValue = celi.c2g__CashEntryValue__c; //M 
                //newCeli.CashEntry = newCashEntry;
                //newCeli.CashEntryCurrency = celi.CashEntryCurrency;
                //newCeli.CashEntryDate = celi.CashEntryDate; //!!!
                newCeli.CashEntryValue = celi.c2g__CashEntryValue__c; //M
                newCeli.Charges = celi.c2g__Charges__c;
                newCeli.LineDescription = celi.c2g__LineDescription__c;
                //newCeli.OwnerCompany = celi.OwnerCompany;
                celis.LineItemList.add(newCeli);
            }
            newCashEntry.LineItems = celis;            
        }
        currB = getCurrency(bAcc.c2g__BankAccountCurrency__c);
        valueB = ceLineItem.c2g__CashEntryValue__c;
        dateB = ce.c2g__Date__c;
            
    	return c2g.CODAAPICashEntry_6_0.CreateCashEntry(null, newCashEntry);
    }
    
    private void postCSH(c2g.CODAAPICommon.Reference ref){
        c2g.CODAAPICashEntry_6_0.PostCashEntry(null, ref);
        c2g.CODAAPICashEntryTypes_6_0.CashEntry csh =  c2g.CODAAPICashEntry_6_0.GetCashEntry(null, ref);
        ref.Name = csh.Name;
        thB = new FFC_TransactionHelper(csh.TransactionRef.Id);
        itemB =  getTrnLineItem(csh.TransactionRef.Id);
    }

    private void initSCR(){
        if(selectedProcedure == 9){
            creditNote = new c2g__codaCreditNote__c();
            creditNoteLineItem = new c2g__codaCreditNoteLineItem__c(); 
            creditNote.c2g__Account__c = cashEntry.c2g__Account__c;
            creditNote.c2g__CustomerReference__c = cashEntryLineItems[0].c2g__AccountReference__c;
            creditNote.c2g__CreditNoteDate__c = cashEntry.c2g__Date__c;
            creditNote.c2g__DueDate__c = cashEntry.c2g__Date__c;
            creditNote.c2g__CreditNoteCurrency__c = cashEntry.c2g__CashEntryCurrency__c;
            creditNote.c2g__CreditNoteDescription__c = cashEntry.c2g__Description__c;
            creditNote.c2g__Period__c = cashEntry.c2g__Period__c;
            
            creditNoteLineItem.c2g__Quantity__c = 1;
            creditNoteLineItem.c2g__TaxRate1__c = 0;
            creditNoteLineItem.c2g__UnitPrice__c = cashEntryLineItems[0].c2g__CashEntryValue__c;            
        }        
    }
    
    private c2g.CODAAPICommon.Reference createSCR(){
        c2g.CODAAPICreditNoteTypes_7_0.CreditNote scr = new c2g.CODAAPICreditNoteTypes_7_0.CreditNote();
        c2g.CODAAPICreditNoteLineItemTypes_7_0.CreditNoteLineItem scrLineItem = new c2g.CODAAPICreditNoteLineItemTypes_7_0.CreditNoteLineItem();
        c2g.CODAAPICreditNoteLineItemTypes_7_0.CreditNoteLineItems scrLineItems = new c2g.CODAAPICreditNoteLineItemTypes_7_0.CreditNoteLineItems();
        
        scr.Account = c2g.CODAAPICommon.getRef(creditNote.c2g__Account__c, null);
        scr.CustomerReference = creditNote.c2g__CustomerReference__c;
        scr.CreditNoteDate = creditNote.c2g__CreditNoteDate__c;
        scr.DueDate = creditNote.c2g__DueDate__c;
        scr.CreditNoteCurrency = c2g.CODAAPICommon.getRef(creditNote.c2g__CreditNoteCurrency__c, null);
        scr.CreditNoteDescription = creditNote.c2g__CreditNoteDescription__c;
        scr.CreditNoteStatus = c2g.CODAAPICreditNoteTypes_7_0.enumCreditNoteStatus.InProgress;
        scr.Period = c2g.CODAAPICommon.getRef(creditNote.c2g__Period__c, null);
        scr.PrintedText1AllowEdit = false;
        scr.PrintedText2AllowEdit = false;
        scr.PrintedText3AllowEdit = false;
        scr.PrintedText4AllowEdit = false;
        scr.PrintedText5AllowEdit = false;
        
        scrLineItem.Product = c2g.CODAAPICommon.getRef(creditNoteLineItem.c2g__Product__c, null);
        scrLineItem.Quantity  = creditNoteLineItem.c2g__Quantity__c;
        scrLineItem.TaxValue1 = creditNoteLineItem.c2g__TaxValue1__c;
        scrLineItem.UnitPrice = creditNoteLineItem.c2g__UnitPrice__c;
        
        scrLineItems.LineItemList = new List<c2g.CODAAPICreditNoteLineItemTypes_7_0.CreditNoteLineItem>();
        scrLineItems.LineItemList.add(scrLineItem);
        
        scr.LineItems = scrLineItems;
        
        currB = getCurrency(creditNote.c2g__CreditNoteCurrency__c);
        valueB = creditNoteLineItem.c2g__UnitPrice__c;
        dateB = creditNote.c2g__CreditNoteDate__c;
    return c2g.CODAAPISalesCreditNote_7_0.CreateCreditNote(null, scr);
    }
    
    private void postSCR(c2g.CODAAPICommon.Reference ref){
        c2g.CODAAPISalesCreditNote_7_0.PostCreditNote(null, ref);
        c2g.CODAAPICreditNoteTypes_7_0.CreditNote scr =  c2g.CODAAPISalesCreditNote_7_0.GetCreditNote(null, ref);
        ref.Name = scr.Name;
        thB = new FFC_TransactionHelper(scr.TransactionRef.Id);
        itemB = getTrnLineItem(scr.TransactionRef.Id);
    }    

    private void initPCR(){
        if(selectedProcedure == 10){
            payableCreditNote = new c2g__codaPurchaseCreditNote__c();
            payableCreditNoteLineItem = new c2g__codaPurchaseCreditNoteLineItem__c();
            payableCreditNote.c2g__Account__c = cashEntry.c2g__Account__c;
            payableCreditNote.c2g__AccountCreditNoteNumber__c = cashEntryLineItems[0].c2g__AccountReference__c;
            payableCreditNote.c2g__CreditNoteDate__c = cashEntry.c2g__Date__c;
            payableCreditNote.c2g__DueDate__c = cashEntry.c2g__Date__c;
            payableCreditNote.c2g__CreditNoteCurrency__c = cashEntry.c2g__CashEntryCurrency__c;
            payableCreditNote.c2g__CreditNoteDescription__c = cashEntry.c2g__Description__c;
            payableCreditNote.c2g__Period__c = cashEntry.c2g__Period__c; 
            
            payableCreditNoteLineItem.c2g__Quantity__c = 1;
            payableCreditNoteLineItem.c2g__TaxRate1__c = 0;
            payableCreditNoteLineItem.c2g__UnitPrice__c = cashEntryLineItems[0].c2g__CashEntryValue__c;            
        }
    }
    
    private c2g.CODAAPICommon.Reference createPCR(){
        c2g.CODAAPIPurchaseCreditNoteTypes_6_0.PurchaseCreditNote  pcr = new c2g.CODAAPIPurchaseCreditNoteTypes_6_0.PurchaseCreditNote();
        c2g.CODAAPIPurchaseCreditNoteLineTypes_6_0.PurchaseCreditNoteLineItem pcrLineItem = new c2g.CODAAPIPurchaseCreditNoteLineTypes_6_0.PurchaseCreditNoteLineItem();
        c2g.CODAAPIPurchaseCreditNoteLineTypes_6_0.PurchaseCreditNoteLineItems pcrLineItems = new c2g.CODAAPIPurchaseCreditNoteLineTypes_6_0.PurchaseCreditNoteLineItems();
        
        pcr.Account = c2g.CODAAPICommon.getRef(payableCreditNote.c2g__Account__c, null);
        pcr.AccountCreditNoteNumber = payableCreditNote.c2g__AccountCreditNoteNumber__c;
        pcr.CreditNoteDate = payableCreditNote.c2g__CreditNoteDate__c;
        pcr.DueDate = payableCreditNote.c2g__DueDate__c;
        pcr.CreditNoteCurrency = c2g.CODAAPICommon.getRef(payableCreditNote.c2g__CreditNoteCurrency__c, null);
        pcr.CreditNoteDescription = payableCreditNote.c2g__CreditNoteDescription__c;
        pcr.CreditNoteStatus = c2g.CODAAPIPurchaseCreditNoteTypes_6_0.enumCreditNoteStatus.InProgress;
        pcr.Period = c2g.CODAAPICommon.getRef(payableCreditNote.c2g__Period__c, null);
        
        pcrLineItem.Product = c2g.CODAAPICommon.getRef(payableCreditNoteLineItem.c2g__Product__c, null);
        pcrLineItem.Quantity  = payableCreditNoteLineItem.c2g__Quantity__c;
        pcrLineItem.TaxValue1 = payableCreditNoteLineItem.c2g__TaxValue1__c;
        pcrLineItem.UnitPrice = payableCreditNoteLineItem.c2g__UnitPrice__c;
        pcrLineItem.EditTaxValue = true;
        
        pcrLineItems.LineItemList = new List<c2g.CODAAPIPurchaseCreditNoteLineTypes_6_0.PurchaseCreditNoteLineItem>();
        pcrLineItems.LineItemList.add(pcrLineItem);
        
        pcr.LineItems = pcrLineItems;
        
        currB = getCurrency(payableCreditNote.c2g__CreditNoteCurrency__c);
        valueB = payableCreditNoteLineItem.c2g__UnitPrice__c;
        dateB = payableCreditNote.c2g__CreditNoteDate__c;
    return c2g.CODAAPIPurchaseCreditNote_6_0.CreatePurchaseCreditNote(null, pcr);
    }
    
    private void postPCR(c2g.CODAAPICommon.Reference ref){
        c2g.CODAAPIPurchaseCreditNote_6_0.PostPurchaseCreditNote(null, ref);
        c2g.CODAAPIPurchaseCreditNoteTypes_6_0.PurchaseCreditNote pcr =  c2g.CODAAPIPurchaseCreditNote_6_0.GetPurchaseCreditNote(null, ref);
        ref.Name = pcr.Name;
        thB = new FFC_TransactionHelper(pcr.TransactionRef.Id);
        itemB = getTrnLineItem(pcr.TransactionRef.Id);
    } 
    
    private String invertCEType(String ceType){
        if(ceType == CE_TYPE_PAYMENT){
            return CE_TYPE_PAYMENT_REFUND;
        }else if(ceType == CE_TYPE_PAYMENT_REFUND){
            return CE_TYPE_PAYMENT;            
        }else if(ceType == CE_TYPE_RECEIPT){
            return CE_TYPE_REFUND;                        
        }else {
            return CE_TYPE_RECEIPT;
        }        
    }
    
    private c2g.CODAAPICashEntryTypes_6_0.enumType apiCEType(String ceType){
        if(ceType == CE_TYPE_PAYMENT_REFUND){
            return c2g.CODAAPICashEntryTypes_6_0.enumType.PaymentRefund;
        }else if(ceType == CE_TYPE_PAYMENT){
            return c2g.CODAAPICashEntryTypes_6_0.enumType.Payment;            
        }else if(ceType == CE_TYPE_PAYMENT_REFUND){
            return c2g.CODAAPICashEntryTypes_6_0.enumType.Refund;                        
        }else {
            return c2g.CODAAPICashEntryTypes_6_0.enumType.Receipt;
        }
  }
    
    private void initJNL(){
        journal = new c2g__codaJournal__c();
        journalLineItem1 = new c2g__codaJournalLineItem__c();
        journalLineItem2 = new c2g__codaJournalLineItem__c();
        journal.c2g__JournalDate__c = cashEntry.c2g__Date__c;
        journal.c2g__JournalCurrency__c = cashEntry.c2g__CashEntryCurrency__c;
        journal.c2g__Period__c = cashEntry.c2g__Period__c;
        journal.c2g__JournalDescription__c = clip(cashEntry.Name + ' ' + cashEntry.c2g__Description__c ,255);
        //Line Items init
        journalLineItem1.c2g__Account__c = cashEntry.c2g__Account__c;
        journalLineItem1.c2g__Value__c = - getCELineItemAccValue();
        journalLineItem2.c2g__Value__c = getCELineItemAccValue();
        if(selectedProcedure == 2 && !paperInvoice && paymentType == 'outcoming'){
            journalLineItem1.c2g__LineType__c = JLI_TYPE_ACC_VENDOR;
            journalLineItem1.c2g__GeneralLedgerAccount__c = cashEntry.c2g__Account__r.c2g__CODAAccountsPayableControl__c;
            journalLineItem2.c2g__LineType__c = JLI_TYPE_GLA;
        }else if(selectedProcedure == 3){
            journalLineItem1.c2g__LineType__c = JLI_TYPE_ACC_CUSTOMER;
            journalLineItem1.c2g__GeneralLedgerAccount__c = cashEntry.c2g__Account__r.c2g__CODAAccountsPayableControl__c;
            journalLineItem2.c2g__LineType__c = JLI_TYPE_GLA;
            if(loanType == 'short'){
                journalLineItem2.c2g__GeneralLedgerAccount__c = glaAccountsMap.get(GLA_1_2210_STLI).Id;                    
            }else{
                journalLineItem2.c2g__GeneralLedgerAccount__c = glaAccountsMap.get(GLA_1_1260_LTLI).Id;                    
            }
        }else if(selectedProcedure == 5){
            journalLineItem1.c2g__LineType__c = JLI_TYPE_ACC_CUSTOMER;
            journalLineItem1.c2g__GeneralLedgerAccount__c = cashEntry.c2g__Account__r.c2g__CODAAccountsPayableControl__c;
            journalLineItem2.c2g__Account__c = cashEntry.c2g__Account__c;
            journalLineItem2.c2g__LineType__c = JLI_TYPE_ACC_CUSTOMER;
        }else if(selectedProcedure == 8){
            journalLineItem1.c2g__LineType__c = JLI_TYPE_ACC_VENDOR;
            journalLineItem1.c2g__GeneralLedgerAccount__c = cashEntry.c2g__Account__r.c2g__CODAAccountsReceivableControl__c;
            journalLineItem2.c2g__Account__c = cashEntry.c2g__Account__c;
            journalLineItem2.c2g__LineType__c = JLI_TYPE_ACC_VENDOR;
            if(loanType == 'short'){
                journalLineItem2.c2g__GeneralLedgerAccount__c = glaAccountsMap.get(GLA_2_3000_STL).Id;                    
            }else{
                journalLineItem2.c2g__GeneralLedgerAccount__c = glaAccountsMap.get(GLA_2_1100_LTLR).Id;                    
            }             
        }
    }
    
    private c2g.CODAAPICommon.Reference createJNL(){
        c2g.CODAAPIJournalTypes_7_0.Journal apiJournal = new c2g.CODAAPIJournalTypes_7_0.Journal();
        c2g.CODAAPIJournalLineItemTypes_7_0.JournalLineItem apiJLI1 = new c2g.CODAAPIJournalLineItemTypes_7_0.JournalLineItem();
        c2g.CODAAPIJournalLineItemTypes_7_0.JournalLineItem apiJLI2 = new c2g.CODAAPIJournalLineItemTypes_7_0.JournalLineItem();
        c2g.CODAAPIJournalLineItemTypes_7_0.JournalLineItems apiJLIList = new c2g.CODAAPIJournalLineItemTypes_7_0.JournalLineItems();
        apiJournal.JournalCurrency = c2g.CODAAPICommon.getRef(journal.c2g__JournalCurrency__c, null);
        apiJournal.Period = c2g.CODAAPICommon.getRef(journal.c2g__Period__c, null);
        apiJournal.JournalDate = journal.c2g__JournalDate__c;
        apiJournal.JournalDescription = journal.c2g__JournalDescription__c;
        apiJournal.JournalStatus = c2g.CODAAPIJournalTypes_7_0.enumJournalStatus.InProgress;
        
        apiJLI1.Account = c2g.CODAAPICommon.getRef(journalLineItem1.c2g__Account__c, null);
        apiJLI1.GeneralLedgerAccount = c2g.CODAAPICommon.getRef(journalLineItem1.c2g__GeneralLedgerAccount__c, null);
        apiJLI1.LineTypeRef = getJLITypeRef(journalLineItem1.c2g__LineType__c);
        apiJLI1.Value = journalLineItem1.c2g__Value__c;
        
        apiJLI2.Account = c2g.CODAAPICommon.getRef(journalLineItem2.c2g__Account__c, null);
        apiJLI2.GeneralLedgerAccount = c2g.CODAAPICommon.getRef(journalLineItem2.c2g__GeneralLedgerAccount__c, null);
        apiJLI2.LineTypeRef = getJLITypeRef(journalLineItem2.c2g__LineType__c);
        apiJLI2.Value = journalLineItem2.c2g__Value__c;
        
        apiJLIList.LineItemList = new List<c2g.CODAAPIJournalLineItemTypes_7_0.JournalLineItem>();
    apiJLIList.LineItemList.add(apiJLI1);        
    apiJLIList.LineItemList.add(apiJLI2); 
        
        apiJournal.LineItems = apiJLIList;
        
        currB = getCurrency(journal.c2g__JournalCurrency__c);
        valueB = journalLineItem1.c2g__Value__c;
        dateB = journal.c2g__JournalDate__c;
    return c2g.CODAAPIJournal_7_0.CreateJournal(null, apiJournal);
    }
    
    private void postJNL(c2g.CODAAPICommon.Reference ref){
        c2g.CODAAPIJournal_7_0.PostJournal(null, ref);
        c2g.CODAAPIJournalTypes_7_0.Journal apiJournal =  c2g.CODAAPIJournal_7_0.GetJournal(null, ref);
        ref.Name = apiJournal.Name;
        thB = new FFC_TransactionHelper(apiJournal.TransactionRef.Id);
        itemB = getTrnLineItem(apiJournal.TransactionRef.Id);
    }
    
    private void postSourceCSH(){
        String trnId;
        c2g__codaTransaction__c trnA;
        if(cashEntry.c2g__Transaction__c == null){
            c2g.CODAAPICommon.Reference cshRef = c2g.CODAAPICommon.getRef(cashEntry.Id, null);
            c2g.CODAAPICashEntry_7_0.PostCashEntry(null, cshRef);
            trnId = [SELECT c2g__Transaction__c FROM c2g__codaCashEntry__c WHERE Id=:cashEntry.Id].c2g__Transaction__c;
        }else{
            trnId = cashEntry.c2g__Transaction__c;           
        }
        thA = new FFC_TransactionHelper(trnId);
        itemA =  getTrnLineItem(trnId);
    }
    
    private c2g.CODAAPICashMatchingTypes_8_0.Item getTrnLineItem(String transactionId){
        
        c2g__codaTransactionLineItem__c trnLineItem = [SELECT Id, c2g__HomeValue__c, c2g__AccountOutstandingValue__c 
                                                       FROM c2g__codaTransactionLineItem__c 
                                                       WHERE c2g__Transaction__c =: transactionId 
                                                            AND c2g__LineNumber__c=1];
        
        c2g.CODAAPICashMatchingTypes_8_0.Item item = new  c2g.CODAAPICashMatchingTypes_8_0.Item();
        item.TransactionLineItem = c2g.CODAAPICommon.getRef(trnLineItem.Id, null);  
        item.Paid = trnLineItem.c2g__AccountOutstandingValue__c;
        return item;
    }
    
    private c2g.CODAAPICommon.Reference match(c2g.CODAAPICashMatchingTypes_8_0.Item itemA, c2g.CODAAPICashMatchingTypes_8_0.Item itemB){
        List<c2g.CODAAPICashMatchingTypes_8_0.Item> items = new List<c2g.CODAAPICashMatchingTypes_8_0.Item>();
        items.add(itemA);
        items.add(itemB);
        c2g.CODAAPICashMatchingTypes_8_0.Configuration config = new c2g.CODAAPICashMatchingTypes_8_0.Configuration();
        config.Account = c2g.CODAAPICommon.getRef(cashEntry.c2g__Account__c, null);
        config.MatchingCurrencyMode = c2g.CODAAPICashMatchingTypes_8_0.enumMatchingCurrencyMode.Account;
        config.MatchingDate = cashEntry.c2g__Date__c;
        config.MatchingPeriod = c2g.CODAAPICommon.getRef(cashEntry.c2g__Period__c, null);
        system.debug('THA ' + thA);
        system.debug('THB ' + thB);
        return c2g.CODAAPICashMatching_8_0.Match(null, config, items, null);
    }
    
    private c2g.CODAAPIJournalLineItemTypes_7_0.enumLineType getJLITypeRef(String strType){
        if(strType == JLI_TYPE_ACC_CUSTOMER){
            return c2g.CODAAPIJournalLineItemTypes_7_0.enumLineType.Account_Customer;
        } else if(strType == JLI_TYPE_ACC_VENDOR){
            return c2g.CODAAPIJournalLineItemTypes_7_0.enumLineType.Account_Vendor;            
        } else if(strType == JLI_TYPE_GLA){
            return c2g.CODAAPIJournalLineItemTypes_7_0.enumLineType.GeneralLedgerAccount;            
        }
        return c2g.CODAAPIJournalLineItemTypes_7_0.enumLineType.GeneralLedgerAccount;         
    }
    
    private Decimal getCELineItemAccValue(){
        Decimal retVal = cashEntryLineItems[0].c2g__CashEntryValue__c;
        if(paymentType == 'incoming'){
            retVal = - retVal;
        }
        return retVal;
    }
    
    private String clip(String str, Integer length){
        if(str == null) return null;
        if(str.length() > length){
            return str.substring(0,length - 1);
        }
        return str;
    }
    
    private void checkAnotherPIN(String anotherPINId){
        if (anotherPINId == null) return; 
        c2g__codaPurchaseInvoice__c anotherPIN = [SELECT 
                                                    Id, Name,
                                                  	c2g__Transaction__c,
                                                    c2g__InvoiceCurrency__c,
                                                    c2g__InvoiceCurrency__r.Name,
                                                    c2g__InvoiceCurrency__r.c2g__Home__c,
                                                    c2g__InvoiceTotal__c,
                                                    c2g__InvoiceDate__c
                                                  FROM c2g__codaPurchaseInvoice__c 
                                                  WHERE Id=: anotherPINId];
        if(anotherPIN.c2g__Transaction__c != null){
        	thB = new FFC_TransactionHelper(anotherPIN.c2g__Transaction__c);            
        	itemB = getTrnLineItem(anotherPIN.c2g__Transaction__c);
        }
        currB =anotherPIN.c2g__InvoiceCurrency__r;
        valueB = anotherPIN.c2g__InvoiceTotal__c;
        dateB = anotherPIN.c2g__InvoiceDate__c;
        refB = c2g.CODAAPICommon.getRef(anotherPINId, null);
        refB.Name = anotherPIN.Name;       
    }
    
    private void checkAnotherCE(String anotherCEId){
        if(anotherCEId == null) return;
        c2g__codaCashEntry__c anotherCE = [SELECT Id, Name,
                                             c2g__CashEntryCurrency__c,
                                             c2g__CashEntryCurrency__r.Name, 
                                             c2g__CashEntryCurrency__r.c2g__Home__c,
                                             c2g__Value__c, 
                                             c2g__Date__c,
                                             c2g__Transaction__c
                                           FROM c2g__codaCashEntry__c WHERE Id=: anotherCEId];
        if(selectedProcedure == 6 && cashEntry.c2g__CashEntryCurrency__r.Name == anotherCE.c2g__CashEntryCurrency__r.Name){
            throw new CEMatchingToolException('Валюта выбранного Cash Entry должна быть отличной от ' + cashEntry.c2g__CashEntryCurrency__r.Name);
        }else if(selectedProcedure != 6 && cashEntry.c2g__CashEntryCurrency__r.Name != anotherCE.c2g__CashEntryCurrency__r.Name){
            throw new CEMatchingToolException('Валюта выбранного Cash Entry должна быть ' + cashEntry.c2g__CashEntryCurrency__r.Name);
        } 
        if(anotherCE.c2g__Transaction__c != null){
        	thB = new FFC_TransactionHelper(anotherCE.c2g__Transaction__c); 
        	itemB = getTrnLineItem(anotherCE.c2g__Transaction__c);            
        }
        currB = anotherCE.c2g__CashEntryCurrency__r;
        valueB = anotherCE.c2g__Value__c;
        dateB = anotherCE.c2g__Date__c;
        refB = c2g.CODAAPICommon.getRef(anotherCEId, null);
        refB.Name = anotherCE.Name;
    }
               
    private c2g__codaAccountingCurrency__c getCurrency(String currId){
        return [SELECT Id, c2g__Home__c, Name FROM c2g__codaAccountingCurrency__c WHERE Id=: currId];
    }
    
    
    public class CEMatchingToolException extends Exception{}

}