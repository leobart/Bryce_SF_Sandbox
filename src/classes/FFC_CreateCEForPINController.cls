public class FFC_CreateCEForPINController{

    public static final String CHARGES_GLA_ACC_NAME ='6-1200 Bank Charges for payments';    

    public c2g__codaCashEntry__c cashEntry {get; set;}
    private Task t;
    public List<c2g__codaBankAccount__c> bankAccounts {get; set;}
    public Bank__c bank;
    public Boolean noInitErrors {get; set;}
    public String errorMessage;    
    public String cashEntryId {get; set;}
	    
    public FFC_CreateCEForPINController(ApexPages.StandardController controller){
        noInitErrors = true;
        cashEntry = new c2g__codaCashEntry__c();
        String taskId = controller.getId();
        t = [SELECT Id, WhatId, Status FROM Task WHERE Id=:taskId];       
        if(t.Status == FFC_CompleteTaskForApprovedPINController.COMPLETE_TASK_VALUE){
			errorMessage = 'Task already completed. Can not create Cash Entry';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, errorMessage));
			noInitErrors = false;
            return;            
        }
		String objId = t.WhatId;
		try{
        	c2g__codaPurchaseInvoice__c[] pins = [SELECT Id, Name,
                                               			c2g__Account__c,
                                               			c2g__Period__c,
                                               			c2g__InvoiceTotal__c,
                                               			c2g__InvoiceCurrency__c,
                                               			c2g__InvoiceCurrency__r.Name,
                                               			c2g__OwnerCompany__c,
                                                        c2g__AccountInvoiceNumber__c,
                                                        Bank__c,
                                                        c2g__OwnerCompany__r.Name
                                               FROM c2g__codaPurchaseInvoice__c 
                                               WHERE Id=:objId];
            if(pins.size() == 0){
                errorMessage = 'Payable Invoice Id mismatch';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, errorMessage));
                noInitErrors = false;
                return;                
            }
            c2g__codaPurchaseInvoice__c pin = pins[0];
            
            List<String> companies = c2g.CODAAPICompany_2_0.GetCurrentCompanies(null);
            if((companies.size() == 1 && companies[0] != pin.c2g__OwnerCompany__r.Name) || companies.size() != 1){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Select company: "' + pin.c2g__OwnerCompany__r.Name + '" before for perform this operation'));  
                noInitErrors = false;
                return;
            }

            if(pin.Bank__c == null){
                errorMessage = 'Bank field not defined in Payable Invoice';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, errorMessage));
                noInitErrors = false;
                return;                
            }
            bank = [SELECT Id, Name FROM Bank__c WHERE id=:pin.Bank__c];
            bankAccounts = [SELECT Id, Name, c2g__BankAccountCurrency__c FROM c2g__codaBankAccount__c WHERE Bank__c =: pin.Bank__c];
            c2g__codaBankAccount__c defBankAcc;
            for(c2g__codaBankAccount__c bAcc : bankAccounts){
                if(bAcc.c2g__BankAccountCurrency__c == pin.c2g__InvoiceCurrency__c){
                    defBankAcc = bAcc;
                    break;
                }
            }
            if(defBankAcc == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, 'Can not find bank account'));
            }else{
				cashEntry.c2g__BankAccount__c = defBankAcc.Id;               
            }
			//Inint CE
			cashEntry.c2g__Date__c = System.today(); 
			cashEntry.c2g__PaymentMethod__c = 'Electronic';

            cashEntry.c2g__Account__c = pin.c2g__Account__c; 
			cashEntry.c2g__Period__c = pin.c2g__Period__c;
			cashEntry.c2g__Type__c = 'Payment';   
			cashEntry.c2g__Value__c = pin.c2g__InvoiceTotal__c;
			cashEntry.c2g__TotalCharges__c = 0;
			cashEntry.c2g__Description__c = 'Created from: ' + pin.Name;
			cashEntry.c2g__OwnerCompany__c = pin.c2g__OwnerCompany__c; 
            c2g__codaGeneralLedgerAccount__c chargesGLA = [SELECT Id FROM c2g__codaGeneralLedgerAccount__c WHERE name=:CHARGES_GLA_ACC_NAME];   
            if (chargesGLA != null) CashEntry.c2g__ChargesGLA__c = chargesGLA.Id;
            cashEntry.c2g__Reference__c = pin.c2g__AccountInvoiceNumber__c;
		}catch(Exception e){
            ApexPages.addMessages(e);
            noInitErrors = false;
		}  
    }
    
    
	//Action function
    public void createCashEntry(){
        cashEntryId = '';
        //Chek bank account
        Boolean f = false;
        c2g__codaBankAccount__c defBankAcc;
        for(c2g__codaBankAccount__c bAcc : bankAccounts){
            if(cashEntry.c2g__BankAccount__c == bAcc.Id){
                defBankAcc = bAcc;
                f = true;
                break;
            }            
        }
        if(!f){
		    errorMessage = 'Error: Bank Account mismatch. You can use Bank Accounts for Bank: ' + bank.Name;
		    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, errorMessage));
            return;
        }
        cashEntry.c2g__CashEntryCurrency__c = defBankAcc.c2g__BankAccountCurrency__c;
		//Init CashEntryLineItem with API
		c2g.CODAAPICashEntryLineItemTypes_6_0.CashEntryLineItem celi = new c2g.CODAAPICashEntryLineItemTypes_6_0.CashEntryLineItem();
		celi.Account = c2g.CODAAPICommon.getRef(cashEntry.c2g__Account__c, null);
		celi.Charges = cashEntry.c2g__TotalCharges__c;
		celi.CashEntryValue = cashEntry.c2g__Value__c;
		celi.BankAccountValue = cashEntry.c2g__Value__c;
        celi.AccountPaymentMethod = cashEntry.c2g__PaymentMethod__c;
		c2g.CODAAPICashEntryLineItemTypes_6_0.CashEntryLineItems celis = new c2g.CODAAPICashEntryLineItemTypes_6_0.CashEntryLineItems();
		celis.LineItemList = new List<c2g.CODAAPICashEntryLineItemTypes_6_0.CashEntryLineItem>();
		celis.LineItemList.add(celi);
        
		//Init CashEntry wiBCH Rietumu USDth API
		c2g.CODAAPICashEntryTypes_6_0.CashEntry ce = new c2g.CODAAPICashEntryTypes_6_0.CashEntry();
		ce.BankAccount = c2g.CODAAPICommon.getRef(cashEntry.c2g__BankAccount__c, null);
		ce.BankAccountCurrency = cashEntry.c2g__CashEntryCurrency__r.Name;
		ce.CashEntryCurrency = c2g.CODAAPICommon.getRef(cashEntry.c2g__CashEntryCurrency__c, null);
		ce.DateValue = cashEntry.c2g__Date__c;
		ce.PaymentMethod = cashEntry.c2g__PaymentMethod__c;
		ce.Period = c2g.CODAAPICommon.getRef(cashEntry.c2g__Period__c, null); 
		ce.Status = c2g.CODAAPICashEntryTypes_6_0.enumStatus.InProgress;
		ce.TypeRef = getAPITypeRef(cashEntry.c2g__Type__c);   	
		ce.Value = Math.abs(cashEntry.c2g__Value__c);
		ce.LineItems = celis;
		ce.Description = cashEntry.c2g__Description__c;
        ce.ChargesGLA = c2g.CODAAPICommon.getRef(CashEntry.c2g__ChargesGLA__c, null);
        ce.Reference = cashEntry.c2g__Reference__c;
		
        //Save point for rollback:
		System.Savepoint createCashEntryPoint = Database.setSavepoint();
		try{
			c2g.CODAAPICommon.Reference ref = c2g.CODAAPICashEntry_6_0.CreateCashEntry(null, ce);
            c2g__codaCashEntry__c nc = [SELECT Id, Name FROM c2g__codaCashEntry__c WHERE Id=:ref.Id];
            cashEntryId = ref.Id;
		}catch (exception e){
		    // Rollback database if error 
		    Database.rollback(createCashEntryPoint);
		    errorMessage = 'Error: ' + e.getMessage() + '. Cash entry not created!';
		    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, errorMessage));
		}
	}
    
	private c2g.CODAAPICashEntryTypes_6_0.enumType getAPITypeRef(String val){
        val.remove(' ');
		for (c2g.CODAAPICashEntryTypes_6_0.enumType typeRef: c2g.CODAAPICashEntryTypes_6_0.enumType.values()) {
   	 		if (typeRef.name() == val) {
   	 			return typeRef;
    		}
		}	
		return c2g.CODAAPICashEntryTypes_6_0.enumType.PaymentRefund;
	}

}