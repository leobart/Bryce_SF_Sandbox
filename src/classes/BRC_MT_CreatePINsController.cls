// Uses in component brc_mt_createPINs 
public class BRC_MT_CreatePINsController{
    
    public BRC_MT_PINMap pinMap {get; set;}
    public Integer invoiceId {get; set;}
    public Integer lineId {get; set;}
    
    public BRC_MT_CreatePINsController(){
        
    }
    
    public void addPINAction(){
        pinMap.addInvoice();
    }
    
    public void addProductLineAction(){
        BRC_MT_PINData pinData = pinMap.invoicesMap.get(invoiceId);
        pinData.addProductLine();
        pinMap.calcBalance();
    }
    
    public void addExpenseLineAction(){
        BRC_MT_PINData pinData = pinMap.invoicesMap.get(invoiceId);
        pinData.addExpenseLine();
        pinMap.calcBalance();
    }
    
    public void calculateTaxesAction(){
        BRC_MT_PINData pinData = pinMap.invoicesMap.get(invoiceId);
        pinData.calculateTaxes();
        pinMap.calcBalance(); 
    }
    
    public void deleteInvoiceAction(){
       pinMap.invoicesMap.remove(invoiceId);
        
    }
    
    public void deleteProductAction(){
        BRC_MT_PINData pinData = pinMap.invoicesMap.get(invoiceId);
        pinData.deleteProduct(lineId);
        pinMap.calcBalance();               
    }
    
    public void deleteExpenseAction(){
        BRC_MT_PINData pinData = pinMap.invoicesMap.get(invoiceId);
        pinData.deleteExpense(lineId);
        pinMap.calcBalance();               
    }
    
    public void readChoosedInvoiceData(){
        BRC_MT_PINData pinData = pinMap.invoicesMap.get(invoiceId);
        pinData.readInvoiceData();
        pinMap.calcBalance();        
    }

}