public class FFC_CreateSINController{
    
    public c2g__codaInvoice__c sin {get; set;}
    public Map<Integer, c2g__codaInvoiceLineItem__c> productsMap {get; set;}

    public Integer deleteId {get; set;}   
    public Boolean noInitErrors {get; set;}
    
    public Decimal netTotal {get; set;}
    public Decimal taxTotal {get; set;}
    public Decimal invoiceTotal {get; set;}

    
	private ApexPages.StandardController controller;
    private Integer currProductId = 0;
    private c2g__codaCompany__c company;
    
    public FFC_CreateSINController(ApexPages.StandardController controller){
        this.controller = controller;
        init();
    }
    
    public FFC_CreateSINController(){
        init();
    }
    
    private void init(){
        invoiceTotal = 0;
        noInitErrors = true;
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
        sin = new c2g__codaInvoice__c();
        if(periods.size()>0){
            sin.c2g__Period__c = periods[0].Id;
        }
		productsMap = new Map<Integer, c2g__codaInvoiceLineItem__c>();        
    }
    
    public boolean getVisibleProductsLines(){
        return !productsMap.isEmpty();
    }
    
    public void addProductLineAction(){
        productsMap.put(currProductId++, new c2g__codaInvoiceLineItem__c()); 
    }
    
    public void deleteProductAction(){
        productsMap.remove(deleteId);
        calculateTaxesAction();
    }
    
    public void changeAccountAction(){
        Account[] accounts = [SELECT Id, Name, c2g__CODAAccountTradingCurrency__c FROM Account WHERE Id=:sin.c2g__Account__c];
        if (accounts.size() > 0){
            List<c2g__codaAccountingCurrency__c> currList = [SELECT Id From c2g__codaAccountingCurrency__c 
                                           WHERE Name=:accounts[0].c2g__CODAAccountTradingCurrency__c 
                                           AND c2g__OwnerCompany__c=:company.Id];
            if (currList.size() > 0) sin.c2g__InvoiceCurrency__c = currList[0].Id;
        }
    }
    
    public void calculateTaxesAction(){
        netTotal = 0;
        taxTotal = 0;
        invoiceTotal = 0;
        for(Integer productId : productsMap.keySet()){
            c2g__codaInvoiceLineItem__c productLine = productsMap.get(productId);
            Decimal taxRate = getTaxRate(productLine.c2g__TaxCode1__c, sin.c2g__InvoiceDate__c);
            if(taxRate != null) {
                Decimal result = taxRate * productLine.c2g__UnitPrice__c / 100;
                productLine.c2g__TaxValue1__c = result.setScale(2, RoundingMode.HALF_UP);
            }else{
                productLine.c2g__TaxValue1__c = null;
            }
            if(productLine.c2g__UnitPrice__c != null) netTotal += productLine.c2g__UnitPrice__c;
            if(productLine.c2g__TaxValue1__c != null) taxTotal += productLine.c2g__TaxValue1__c;
        }
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
    public PageReference createSINAction(){
        c2g.CODAAPIInvoiceTypes_7_0.Invoice sinAPI = new c2g.CODAAPIInvoiceTypes_7_0.Invoice();
        
        sinAPI.Account = c2g.CODAAPICommon.getRef(sin.c2g__Account__c, null);
        sinAPI.Opportunity = c2g.CODAAPICommon.getRef(sin.c2g__Opportunity__c, null);
        sinAPI.IncomeSchedule = c2g.CODAAPICommon.getRef(sin.c2g__IncomeSchedule__c, null);
        sinAPI.NumberofJournals = sin.c2g__NumberofJournals__c;
        sinAPI.IncomeScheduleGroup = c2g.CODAAPICommon.getRef(sin.c2g__IncomeScheduleGroup__c, null);
        
        sinAPI.TaxCode1 = c2g.CODAAPICommon.getRef(sin.c2g__TaxCode1__c, null);
        sinAPI.TaxCode2 = c2g.CODAAPICommon.getRef(sin.c2g__TaxCode2__c, null);
        sinAPI.TaxCode3 = c2g.CODAAPICommon.getRef(sin.c2g__TaxCode3__c, null);
        
        sinAPI.Dimension1 = c2g.CODAAPICommon.getRef(sin.c2g__Dimension1__c, null);
        sinAPI.Dimension2 = c2g.CODAAPICommon.getRef(sin.c2g__Dimension2__c, null);
        sinAPI.Dimension3 = c2g.CODAAPICommon.getRef(sin.c2g__Dimension3__c, null);
        sinAPI.Dimension4 = c2g.CODAAPICommon.getRef(sin.c2g__Dimension4__c, null);
        
        sinAPI.CustomerReference = sin.c2g__CustomerReference__c;
        sinAPI.InvoiceCurrency = c2g.CODAAPICommon.getRef(sin.c2g__InvoiceCurrency__c, null);
        sinAPI.DueDate = sin.c2g__DueDate__c;
        sinAPI.InvoiceDate = sin.c2g__InvoiceDate__c;
        sinAPI.InvoiceStatus = c2g.CODAAPIInvoiceTypes_7_0.enumInvoiceStatus.InProgress;
        sinAPI.InvoiceGroup = c2g.CODAAPICommon.getRef(sin.c2g__InvoiceGroup__c, null);
        sinAPI.InvoiceDescription = sin.c2g__InvoiceDescription__c;
        sinAPI.Period = c2g.CODAAPICommon.getRef(sin.c2g__Period__c, null);
        
        sinAPI.PrintedText1AllowEdit = false;
        sinAPI.PrintedText2AllowEdit = false;
        sinAPI.PrintedText3AllowEdit = false;
        sinAPI.PrintedText4AllowEdit = false;
        sinAPI.PrintedText5AllowEdit = false;
        
        c2g.CODAAPIInvoiceLineItemTypes_7_0.InvoiceLineItems sinLineItemsAPI = new c2g.CODAAPIInvoiceLineItemTypes_7_0.InvoiceLineItems();
        sinLineItemsAPI.LineItemList = new List<c2g.CODAAPIInvoiceLineItemTypes_7_0.InvoiceLineItem>();
        for(Integer lineId : productsMap.keySet()){
            c2g__codaInvoiceLineItem__c sinLineItem = productsMap.get(lineId);
        	c2g.CODAAPIInvoiceLineItemTypes_7_0.InvoiceLineItem sinLineItemAPI = new c2g.CODAAPIInvoiceLineItemTypes_7_0.InvoiceLineItem();
            
            sinLineItemAPI.Product = c2g.CODAAPICommon.getRef(sinLineItem.c2g__Product__c, null);
            sinLineItemAPI.Quantity = 1;
            if(sinLineItem.c2g__TaxCode1__c != null){
                sinLineItemAPI.TaxCode1 = c2g.CODAAPICommon.getRef(sinLineItem.c2g__TaxCode1__c, null);
                sinLineItemAPI.TaxValue1 = sinLineItem.c2g__TaxValue1__c;                
            }
            sinLineItemAPI.UnitPrice = sinLineItem.c2g__UnitPrice__c;
            sinLineItemAPI.Usepartperiods = false; //???
            
        	sinLineItemsAPI.LineItemList.add(sinLineItemAPI);
        }
        
        sinAPI.LineItems = sinLineItemsAPI;
        
        System.Savepoint rollbackPoint = Database.setSavepoint();
        try{
			c2g.CODAAPICommon.Reference ref = c2g.CODAAPISalesInvoice_7_0.CreateInvoice(null, sinAPI);  
            c2g__codaInvoice__c createdSIN = [SELECT Id, Name, c2g__InvoiceCurrency__r.Name FROM c2g__codaInvoice__c WHERE Id=:ref.Id];
            createdSIN.Contract_number__c = sin.Contract_number__c;
            createdSIN.Addendum_Name__c = sin.Addendum_Name__c;
            createdSIN.Bank_Account__c = sin.Bank_Account__c;
            createdSIN.PO_Number__c = sin.PO_Number__c;
            createdSIN.CurrencyIsoCode = createdSIN.c2g__InvoiceCurrency__r.Name;
            update createdSIN;
            PageReference resPage = new PageReference('/apex/ffc_AddAttachmentsPage');
            resPage.getParameters().put('objId', createdSIN.Id);
            resPage.getParameters().put('objName', createdSIN.Name);
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