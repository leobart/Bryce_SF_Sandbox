public class BRC_MT_PINMap{
    
    public Map<Integer, BRC_MT_PINData> invoicesMap {get; set;}
	public c2g__codaCashEntry__c sourceCashEntry {get; set;}  
    public Decimal balance {get; set;}
    public Decimal invoicesSummary {get; set;}
   
    private Integer currInvoiceId = 1;
    
    public BRC_MT_PINMap(c2g__codaCashEntry__c sourceCE){
        sourceCashEntry = sourceCE;
        balance = sourceCashEntry.c2g__Value__c;
        invoicesMap = new Map<Integer, BRC_MT_PINData>();
        addInvoice();
    }
    
    public void addInvoice(){
        if(balance > 0){
        	BRC_MT_PINData pinData = new BRC_MT_PINData(sourceCashEntry);
            invoicesMap.put(currInvoiceId++, pinData);
            pinData.availableValue = balance;
            pinData.addExpenseLine();
            balance = 0;
            pinData.availableValue = balance;
            invoicesSummary = sourceCashEntry.c2g__Value__c;
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Can not add invoice. Invoices summary must be < ' + sourceCashEntry.c2g__Value__c));
        }
    }
    
    public void calcBalance(){
        invoicesSummary = 0;
        for(Integer i : invoicesMap.keySet()){
			BRC_MT_PINData pinData = invoicesMap.get(i);
            //pinData.calculateTaxesAction();
            invoicesSummary += pinData.invoiceTotal;
        }
        balance = sourceCashEntry.c2g__Value__c - invoicesSummary;
        for(Integer i : invoicesMap.keySet()){
			BRC_MT_PINData pinData = invoicesMap.get(i);
            pinData.availableValue = balance;
        }
         if(balance != 0){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Balance must be = 0 (Summary value of all invoices must be equal source CashEntry Value = ' + sourceCashEntry.c2g__Value__c + ')'));            
        }
   }
    
    public Boolean getShowDeleteInvoice(){
        return invoicesMap.size() > 1;
    }

}