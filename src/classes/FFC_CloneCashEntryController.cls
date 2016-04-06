// Clone Cash Entry with invert value
public with sharing class FFC_CloneCashEntryController{
    
    public c2g__codaCashEntry__c cashEntry {get; set;}
    private c2g.CODAAPICashEntryTypes_6_0.CashEntry newCashEntry;   
    public String subject {get; set;}
    public Boolean noErrors {get; set;}
    
    public FFC_CloneCashEntryController(ApexPages.StandardController controller){
        cashEntry = [SELECT 
                    Id, 
                    Name,
                    c2g__Account__c,
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
                    c2g__Transaction__c,
                    c2g__Type__c
                  FROM c2g__codaCashEntry__c 
                  WHERE Id=:controller.getId()]; 
        //Check current company and Cash Entry owner company
        noErrors = true;
        List<String> companies = c2g.CODAAPICompany_2_0.GetCurrentCompanies(null);
        if(companies.size()!=1){
		    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Select one company for perform this operation')); 
            noErrors = false;
            return; 
        }
        if(companies[0] != cashEntry.c2g__OwnerCompany__r.Name){
		    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Select company: "' + cashEntry.c2g__OwnerCompany__r.Name + '" before for perform this operation'));  
			noErrors = false;
        }
    }
    
    public PageReference invertClone(){
        newCashEntry = new c2g.CODAAPICashEntryTypes_6_0.CashEntry();
        //copy fields from cashEntry to newCashEntry
        newCashEntry.Account = c2g.CODAAPICommon.getRef(cashEntry.c2g__Account__c, null);
        //newCashEntry.AccountDimension1 = cashEntry.AccountDimension1;
        //newCashEntry.AccountDimension2 = cashEntry.AccountDimension2;
        //newCashEntry.AccountDimension3 = cashEntry.AccountDimension3;
        //newCashEntry.AccountDimension4 = cashEntry.AccountDimension4;
        newCashEntry.BankAccount = c2g.CODAAPICommon.getRef(cashEntry.c2g__BankAccount__c, null);  //M
        newCashEntry.BankAccountCurrency = cashEntry.c2g__BankAccountCurrency__c;  //M
        //newCashEntry.BankAccountDimension1 = cashEntry.BankAccountDimension1;
        //newCashEntry.BankAccountDimension2 = cashEntry.BankAccountDimension2;
        //newCashEntry.BankAccountDimension3 = cashEntry.BankAccountDimension3;
        //newCashEntry.BankAccountDimension4 = cashEntry.BankAccountDimension4;
        //newCashEntry.BankAccountValue = cashEntry.BankAccountValue;
        newCashEntry.CashEntryCurrency = c2g.CODAAPICommon.getRef(cashEntry.c2g__CashEntryCurrency__c, null);  //M
        //newCashEntry.ChargesAmount = cashEntry.ChargesAmount;
        newCashEntry.ChargesGLA = c2g.CODAAPICommon.getRef(CashEntry.c2g__ChargesGLA__c, null);
        //newCashEntry.ChargesGLADimension1 = cashEntry.ChargesGLADimension1;
        //newCashEntry.ChargesGLADimension2 = cashEntry.ChargesGLADimension2;
        //newCashEntry.ChargesGLADimension3 = cashEntry.ChargesGLADimension3;
        //newCashEntry.ChargesGLADimension4 = cashEntry.ChargesGLADimension4;
        newCashEntry.DateValue = cashEntry.c2g__Date__c;  //M
		String description = 'Inverted from ' + cashEntry.Name; 
        if(cashEntry.c2g__Description__c != null) description = description + ' ' + cashEntry.c2g__Description__c;
        if(description.length()>255){
            description = description.substring(0,254);
        }
        newCashEntry.Description =  description;
        //newCashEntry.DiscardReason = cashEntry.DiscardReason;
        //newCashEntry.OwnerCompany = cashEntry.OwnerCompany;
        newCashEntry.PaymentMethod = cashEntry.c2g__PaymentMethod__c; //M
        //newCashEntry.PaymentNumber = cashEntry.PaymentNumber;
        newCashEntry.Period = c2g.CODAAPICommon.getRef(cashEntry.c2g__Period__c, null); //M
        newCashEntry.Reference = cashEntry.c2g__Reference__c;
        newCashEntry.Status = c2g.CODAAPICashEntryTypes_6_0.enumStatus.InProgress; //M
        newCashEntry.TypeRef = invertType(cashEntry.c2g__Type__c);  //M  invert type
        newCashEntry.Value = cashEntry.c2g__Value__c;  //M
        
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
            newCeli.Account = c2g.CODAAPICommon.getRef(celi.c2g__Account__c, null);//M
            //newCeli.AccountDimension1 = celi.AccountDimension1; 
            //newCeli.AccountDimension2 = celi.AccountDimension2;
            //newCeli.AccountDimension3 = celi.AccountDimension3;
            //newCeli.AccountDimension4 = celi.AccountDimension4;
            newCeli.AccountPaymentMethod = celi.c2g__AccountPaymentMethod__c;
            //newCeli.AccountReference = celi.AccountReference;
            newCeli.BankAccountValue = celi.c2g__BankAccountValue__c;
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
        //Insert newCashEntry into DB
        System.Savepoint createCashEntryPoint = Database.setSavepoint();
		c2g.CODAAPICommon.Reference ref;
        try{
			ref = c2g.CODAAPICashEntry_6_0.CreateCashEntry(null, newCashEntry);
		}catch (exception e){
		    // Rollback database if error 
		    Database.rollback(createCashEntryPoint);
		    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Error: ' + e.getMessage() + '. Cash entry not created!'));
            return cancelPage();
		}   
        return new PageReference('/' + ref.Id);
    }
    
    public PageReference cancelPage(){
        return new PageReference('/' + cashEntry.Id);
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

}