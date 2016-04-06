public class FFC_CreatePINController{
    
    public c2g__codaPurchaseInvoice__c pin {get; set;}
    public Map<Integer, c2g__codaPurchaseInvoiceLineItem__c> productsMap {get; set;}
    public Map<Integer, c2g__codaPurchaseInvoiceExpenseLineItem__c> expensesMap {get; set;}
    
    public Decimal productsNetTotal {get; set;}
    public Decimal expensesNetTotal {get; set;}
    public Decimal productsTaxTotal {get; set;}
    public Decimal expensesTaxTotal {get; set;}
    public Decimal netTotal {get; set;}
    public Decimal taxTotal {get; set;}
    public Decimal invoiceTotal {get; set;}
    
    private String taxId {get; set;}
    
    private Integer currProductId = 0;
    private Integer currExpenseId = 0;
    
    public Integer deleteId {get; set;}
    
    public Boolean attachmentEnable {get; set;}
    
    public Boolean noInitErrors {get; set;}
    
    private ApexPages.StandardController controller;
    private c2g__codaCompany__c company;
    
    public FFC_CreatePINController(ApexPages.StandardController controller){
        this.controller = controller;
    	init();    
    }
    
    public FFC_CreatePINController(){
        init();
    }
    
    private void init(){
        noInitErrors = true;
        invoiceTotal = 0;
        list<String> companies = c2g.CODAAPICompany_2_0.GetCurrentCompanies(null);
        if(companies.size() != 1){
            noInitErrors = false;
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Procedure not available in Multi-Company mode'));
            return;
        }
        Date today = System.today();
        company = [SELECT Id FROM c2g__codaCompany__c WHERE Name=:companies[0]];
        List<c2g__codaPeriod__c> periods = [SELECT Id, Name 
                                            FROM c2g__codaPeriod__c 
                                            WHERE c2g__OwnerCompany__c =:company.Id
                                                AND c2g__StartDate__c <=:today  
                                                AND c2g__EndDate__c >=:today ];
        attachmentEnable = false;
        pin = new c2g__codaPurchaseInvoice__c();
        if(periods.size()>0){
            pin.c2g__Period__c = periods[0].Id;
        }
		productsMap = new Map<Integer, c2g__codaPurchaseInvoiceLineItem__c>();
		expensesMap = new Map<Integer, c2g__codaPurchaseInvoiceExpenseLineItem__c>();	
    }
    
    public boolean getVisibleProductsLines(){
        return !productsMap.isEmpty();
    }
    
    public boolean getVisibleExpensesLines(){
        return !expensesMap.isEmpty();
    }
    
    public void addProductLineAction(){
        productsMap.put(currProductId++, new c2g__codaPurchaseInvoiceLineItem__c(c2g__InputVATCode__c = taxId)); 
    }
    
    public void addExpenseLineAction(){
        expensesMap.put(currExpenseId++, new c2g__codaPurchaseInvoiceExpenseLineItem__c(c2g__InputVATCode__c = taxId)); 
    }
    
    public void deleteProductAction(){
        productsMap.remove(deleteId);
        calculateTaxesAction();
    }
    
    public void deleteExpenseAction(){
        expensesMap.remove(deleteId);
        calculateTaxesAction();
    }
    
    public void changeAccountAction(){
        Account[] accounts = [SELECT Id, Name, c2g__CODAAccountTradingCurrency__c, c2g__CODAInputVATCode__c FROM Account WHERE Id=:pin.c2g__Account__c];
        if (accounts.size() > 0){
            List<c2g__codaAccountingCurrency__c> currList = [SELECT Id From c2g__codaAccountingCurrency__c 
                                           WHERE Name=:accounts[0].c2g__CODAAccountTradingCurrency__c 
                                           AND c2g__OwnerCompany__c=:company.Id];
            if (currList.size() > 0) pin.c2g__InvoiceCurrency__c = currList[0].Id;
            taxId = accounts[0].c2g__CODAInputVATCode__c;
        }
    }
        
    public void calculateTaxesAction(){
        productsNetTotal = 0;
        expensesNetTotal = 0;
        netTotal = 0;
        productsTaxTotal = 0;
        expensesTaxTotal = 0;
        taxTotal = 0;
        invoiceTotal = 0;
        for(Integer productId : productsMap.keySet()){
            c2g__codaPurchaseInvoiceLineItem__c productLine = productsMap.get(productId);
            Decimal taxRate = getTaxRate(productLine.c2g__InputVATCode__c, pin.c2g__InvoiceDate__c);
            if(taxRate != null) {
                Decimal result = taxRate * productLine.c2g__UnitPrice__c / 100;
                productLine.c2g__TaxValue1__c = result.setScale(2, RoundingMode.HALF_UP);
            }else{
                productLine.c2g__TaxValue1__c = null;
            }
            if(productLine.c2g__UnitPrice__c != null) productsNetTotal += productLine.c2g__UnitPrice__c;
            if(productLine.c2g__TaxValue1__c != null) productsTaxTotal += productLine.c2g__TaxValue1__c;
        }
        for(Integer expenseId : expensesMap.keySet()){
            c2g__codaPurchaseInvoiceExpenseLineItem__c expenseLine = expensesMap.get(expenseId);
            Decimal taxRate = getTaxRate(expenseLine.c2g__InputVATCode__c, pin.c2g__InvoiceDate__c);
            if(taxRate != null){
                Decimal result = taxRate * expenseLine.c2g__NetValue__c / 100;
                expenseLine.c2g__TaxValue1__c = result.setScale(2, RoundingMode.HALF_UP);
            }else{
                expenseLine.c2g__TaxValue1__c = null;
            } 
            if(expenseLine.c2g__NetValue__c != null) expensesNetTotal += expenseLine.c2g__NetValue__c;
            if(expenseLine.c2g__TaxValue1__c != null) expensesTaxTotal += expenseLine.c2g__TaxValue1__c;
        }   
        netTotal = productsNetTotal + expensesNetTotal;
        taxTotal = productsTaxTotal + expensesTaxTotal;
        invoiceTotal = netTotal + taxTotal;       
    }
    
    public Boolean getShowSummary(){
        return invoiceTotal != 0;
    }
    
    public Decimal getTaxRate(String taxId, Date targetDate){
        if(taxId == null) return null;
		c2g__codaTaxRate__c[] taxRates = [SELECT Id, c2g__Rate__c FROM c2g__codaTaxRate__c 
                                          WHERE c2g__TaxCode__c=:taxId 
                                          AND c2g__StartDate__c<=:targetDate 
                                          ORDER BY c2g__StartDate__c DESC];
        if(taxRates.size() > 0) return taxRates[0].c2g__Rate__c;
        return null;
    }
    
    public PageReference createPINAction(){
        c2g.CODAAPIPurchaseInvoiceTypes_8_0.PurchaseInvoice pinAPI = new c2g.CODAAPIPurchaseInvoiceTypes_8_0.PurchaseInvoice();
        c2g.CODAAPIPurchaseInvoiceLineItemTypes_8_0.PurchaseInvoiceLineItems pinLineItemsAPI= new c2g.CODAAPIPurchaseInvoiceLineItemTypes_8_0.PurchaseInvoiceLineItems();
        c2g.CODAAPIPurchaseInvoiceExpLineTypes_8_0.PurchaseInvoiceExpenseLineItems pinExpItemsAPI = new c2g.CODAAPIPurchaseInvoiceExpLineTypes_8_0.PurchaseInvoiceExpenseLineItems();
        
        pinAPI.Account = c2g.CODAAPICommon.getRef(pin.c2g__Account__c, null);
        pinAPI.AccountInvoiceNumber = pin.c2g__AccountInvoiceNumber__c;
        pinAPI.Dimension1 = c2g.CODAAPICommon.getRef(pin.c2g__Dimension1__c, null);
        pinAPI.Dimension2 = c2g.CODAAPICommon.getRef(pin.c2g__Dimension2__c, null);
        pinAPI.Dimension3 = c2g.CODAAPICommon.getRef(pin.c2g__Dimension3__c, null);
        pinAPI.Dimension4 = c2g.CODAAPICommon.getRef(pin.c2g__Dimension4__c, null);
        pinAPI.DueDate = pin.c2g__DueDate__c;
        pinAPI.InvoiceDate = pin.c2g__InvoiceDate__c;
        pinAPI.InvoiceCurrency = c2g.CODAAPICommon.getRef(pin.c2g__InvoiceCurrency__c, null);
        pinAPI.InvoiceStatus = c2g.CODAAPIPurchaseInvoiceTypes_8_0.enumInvoiceStatus.InProgress;
        pinAPI.InvoiceDescription = pin.c2g__InvoiceDescription__c;
        pinAPI.Period = c2g.CODAAPICommon.getRef(pin.c2g__Period__c, null);
        pinAPI.Reference1 = pin.c2g__Reference1__c;
        pinAPI.Reference2 = pin.c2g__Reference2__c;
        
        
        pinLineItemsAPI.LineItemList = new List<c2g.CODAAPIPurchaseInvoiceLineItemTypes_8_0.PurchaseInvoiceLineItem>();
        for(Integer lineId : productsMap.keySet()){
            c2g__codaPurchaseInvoiceLineItem__c pinLineItem = productsMap.get(lineId);
        	c2g.CODAAPIPurchaseInvoiceLineItemTypes_8_0.PurchaseInvoiceLineItem pinLineItemAPI= new c2g.CODAAPIPurchaseInvoiceLineItemTypes_8_0.PurchaseInvoiceLineItem();
            pinLineItemAPI.Product = c2g.CODAAPICommon.getRef(pinLineItem.c2g__Product__c, null);
            pinLineItemAPI.Quantity = 1;
            pinLineItemAPI.InputVATCode = c2g.CODAAPICommon.getRef(pinLineItem.c2g__InputVATCode__c, null);               
            pinLineItemAPI.TaxValue1 = pinLineItem.c2g__TaxValue1__c;
            pinLineItemAPI.UnitPrice = pinLineItem.c2g__UnitPrice__c;
        	pinLineItemsAPI.LineItemList.add(pinLineItemAPI);
        }
        
        pinExpItemsAPI.LineItemList = new List<c2g.CODAAPIPurchaseInvoiceExpLineTypes_8_0.PurchaseInvoiceExpenseLineItem>();
        for(Integer lineId : expensesMap.keySet()){
            c2g__codaPurchaseInvoiceExpenseLineItem__c pinExpItem = expensesMap.get(lineId);
	        c2g.CODAAPIPurchaseInvoiceExpLineTypes_8_0.PurchaseInvoiceExpenseLineItem pinExpItemAPI = new c2g.CODAAPIPurchaseInvoiceExpLineTypes_8_0.PurchaseInvoiceExpenseLineItem();
            pinExpItemAPI.GeneralLedgerAccount = c2g.CODAAPICommon.getRef(pinExpItem.c2g__GeneralLedgerAccount__c, null);
            pinExpItemAPI.LineDescription = pinExpItem.c2g__LineDescription__c;
            pinExpItemAPI.InputVATCode = c2g.CODAAPICommon.getRef(pinExpItem.c2g__InputVATCode__c, null);              
            pinExpItemAPI.TaxValue1 = pinExpItem.c2g__TaxValue1__c;
            pinExpItemAPI.NetValue = pinExpItem.c2g__NetValue__c;
            pinExpItemsAPI.LineItemList.add(pinExpItemAPI);
        }
        
        pinAPI.LineItems = pinLineItemsAPI;
        pinAPI.ExpLineItems = pinExpItemsAPI;
        
        System.Savepoint rollbackPoint = Database.setSavepoint();
        try{
			c2g.CODAAPICommon.Reference ref = c2g.CODAAPIPurchaseInvoice_8_0.CreatePurchaseInvoice(null, pinAPI);  
            c2g__codaPurchaseInvoice__c createdPIN = [SELECT Id, Name, c2g__InvoiceCurrency__r.Name FROM c2g__codaPurchaseInvoice__c WHERE Id=:ref.Id];
            createdPIN.Bank__c = pin.Bank__c;
            createdPIN.Contract_number__c = pin.Contract_number__c;
            createdPIN.Addendum_Name__c = pin.Addendum_Name__c;
            createdPIN.CurrencyIsoCode = createdPIN.c2g__InvoiceCurrency__r.Name;
            update createdPIN;
            pin = createdPIN;
            PageReference resPage = new PageReference('/apex/ffc_AddAttachmentsPage');
            resPage.getParameters().put('objId', pin.Id);
            resPage.getParameters().put('objName', pin.Name);
            return resPage;
        }catch(Exception e){
            Database.rollback(rollbackPoint);
		    ApexPages.addMessages(e);
           	
        }
        return null;      
    }
        
    public PageReference cancelAction(){
        return controller.cancel();
    }
    
}