public class BRC_MT_PINData{
    
    public Note pinNote {get; set;}
    public c2g__codaPurchaseInvoice__c pin {get; set;}
    public Map<Integer, c2g__codaPurchaseInvoiceLineItem__c> productsMap {get; set;}
    public Map<Integer, c2g__codaPurchaseInvoiceExpenseLineItem__c> expensesMap {get; set;}
    public Boolean useCreatedPin;
    public c2g__codaCashEntry__c sourceCashEntry {get; set;}
    public c2g__codaPurchaseInvoiceExpenseLineItem__c invoiceLink {get; set;}
    
    public boolean showAdditionalData {get; set;}
    public boolean addNote {get; set;}
    
    public Decimal productsNetTotal {get; set;}
    public Decimal expensesNetTotal {get; set;}
    public Decimal productsTaxTotal {get; set;}
    public Decimal expensesTaxTotal {get; set;}
    public Decimal netTotal {get; set;}
    public Decimal taxTotal {get; set;}
    public Decimal invoiceTotal {get; set;}

    private Integer currProductId = 0;
    private Integer currExpenseId = 0;
    
    public Decimal availableValue {get; set;}

    public Boolean getUseCreatedPin(){
        return useCreatedPin;
    }
    
    public void setUseCreatedPin(Boolean value){
        useCreatedPin = value;
        if(useCreatedPin){
            netTotal = 0;
            taxTotal = 0;
            invoiceTotal = 0;
        }else{
            calculateTaxes();
        }
    }
    
    public BRC_MT_PINData(c2g__codaCashEntry__c sourceCE){
        sourceCashEntry = sourceCE;
        showAdditionalData = false;
        useCreatedPin = false;
        addNote = false;
        init();
    }
    
    public void init(){
        pin = new c2g__codaPurchaseInvoice__c();
        pin.c2g__Account__c = sourceCashEntry.c2g__Account__c;
        pin.c2g__AccountInvoiceNumber__c = sourceCashEntry.c2g__Reference__c;
        pin.c2g__InvoiceDate__c = sourceCashEntry.c2g__Date__c;
        pin.c2g__DueDate__c = sourceCashEntry.c2g__Date__c;
        pin.c2g__InvoiceCurrency__c = sourceCashEntry.c2g__CashEntryCurrency__c;
        pin.c2g__InvoiceDescription__c = sourceCashEntry.c2g__Description__c;
        pin.c2g__Period__c = sourceCashEntry.c2g__Period__c; 
		productsMap = new Map<Integer, c2g__codaPurchaseInvoiceLineItem__c>();
		expensesMap = new Map<Integer, c2g__codaPurchaseInvoiceExpenseLineItem__c>();
        invoiceLink = new c2g__codaPurchaseInvoiceExpenseLineItem__c();
        pinNote = new Note();
        invoiceTotal = 0;
    }

    public boolean getVisibleProductsLines(){
        return !productsMap.isEmpty();
    }
    
    public boolean getVisibleExpensesLines(){
        return !expensesMap.isEmpty();
    }
    
    public void addProductLine(){
        if(availableValue > 0){
        	productsMap.put(currProductId++, new c2g__codaPurchaseInvoiceLineItem__c(c2g__UnitPrice__c = availableValue));  
            calculateTaxes();
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Can not add line. Invoices summary must be < ' + sourceCashEntry.c2g__Value__c));            
        }       
    }
    
    public void addExpenseLine(){
        if(availableValue > 0){
            expensesMap.put(currExpenseId++, new c2g__codaPurchaseInvoiceExpenseLineItem__c(c2g__NetValue__c = availableValue)); 
            calculateTaxes();            
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Can not add line. Invoices summary must be < ' + sourceCashEntry.c2g__Value__c));            
        }
    }
    
    public void deleteProduct(Integer lineId){
        productsMap.remove(lineId);
        calculateTaxes();
    }
    
    public void deleteExpense(Integer lineId){
        expensesMap.remove(lineId);
        calculateTaxes();
    }
    
    public void calculateTaxes(){
        if(useCreatedPin){
            readInvoiceData();
        }else{
            productsNetTotal = 0;
            expensesNetTotal = 0;
            netTotal = 0;
            productsTaxTotal = 0;
            expensesTaxTotal = 0;
            taxTotal = 0;
            invoiceTotal = 0;
            for(Integer productId : productsMap.keySet()){
                c2g__codaPurchaseInvoiceLineItem__c productLine = productsMap.get(productId);
                Decimal taxRate = BRC_TaxUtil.getTaxRate(productLine.c2g__InputVATCode__c, pin.c2g__InvoiceDate__c);
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
                Decimal taxRate = BRC_TaxUtil.getTaxRate(expenseLine.c2g__InputVATCode__c, pin.c2g__InvoiceDate__c);
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
    }
    
    public Boolean getShowSummary(){
        return invoiceTotal != 0;
    }
    
    public Decimal getSummary(){
        return invoiceTotal;
    }
    
    public void readInvoiceData(){ 
        if(invoiceLink.c2g__PurchaseInvoice__c != null){
            c2g__codaPurchaseInvoice__c choosedPIN = [SELECT ID, c2g__InvoiceTotal__c, c2g__NetTotal__c, c2g__TaxTotal__c 
                                                      FROM c2g__codaPurchaseInvoice__c 
                                                      WHERE Id=:invoiceLink.c2g__PurchaseInvoice__c];
            invoiceTotal = choosedPIN.c2g__InvoiceTotal__c;
            netTotal = choosedPIN.c2g__NetTotal__c;
            taxTotal = choosedPIN.c2g__TaxTotal__c;                   
        }else{
            netTotal = 0;
            taxTotal = 0;
            invoiceTotal = 0;            
        }
    }
    
    public String getInvoiceName(){
        if(useCreatedPin){
            return 'Payable Invoice';
        }else{
            return 'New Payable Invoice';
        }
    }

}