public class RietumuELCreateCEController{

    public static final String CHARGES_GLA_ACC_NAME ='6-1200 Bank Charges for payments';    

    public c2g__codaCashEntry__c cashEntry {get; set;}
    public String benName {get; set;}
    public Boolean noInitErrors {get; set;}
    public RietumuTransaction.Value value {get; set;}
    public String trnId {get; set;}
    public String trnCur {get; set;}
    public String chargeTrnId {get; set;}
    public String errorMessage;
    
    public String cashEntryId {get; set;}
    
    public Boolean addRate {get; set;}
    public Integer rateOrValue {get; set;}
    public c2g__codaExchangeRate__c rate {get; set;}
    public List<SelectOption> rateOrValueSO {get; set;}
    public Boolean showAddRate {get; set;}
	
    private RietumuDMLInterface rDML;
	private RietumuAPIWrapperInterface ffAPI; 
    
    public RietumuELCreateCEController(){
        rDML = new RietumuDML();
        ffAPI = new RietumuFFAPIWrapper();
        addRate = false;
        rate = new c2g__codaExchangeRate__c();
        trnId = ApexPages.currentPage().getParameters().get('trnId');
        chargeTrnId = ApexPages.currentPage().getParameters().get('chargeTrnId');
        //if(chargeTrnId == '') chargeTrnId = null; 
        String bAccId = ApexPages.currentPage().getParameters().get('bAccId');
        String companyId = ApexPages.currentPage().getParameters().get('companyId');
        String companyName = ApexPages.currentPage().getParameters().get('companyName');
        Date trnDate = Date.valueOf(ApexPages.currentPage().getParameters().get('trnDate'));
        benName = ApexPages.currentPage().getParameters().get('benName');
        String cshType = ApexPages.currentPage().getParameters().get('cshType');
        Decimal trnAmount = Decimal.valueOf(ApexPages.currentPage().getParameters().get('trnAmount'));
        Decimal chargeValue = Decimal.valueOf(ApexPages.currentPage().getParameters().get('chargeValue'));
        String details = ApexPages.currentPage().getParameters().get('details');
        String trndesc = ApexPages.currentPage().getParameters().get('trnDesc');
        trnCur = ApexPages.currentPage().getParameters().get('trnCur');
        noInitErrors = true;
        value = new RietumuTransaction.Value(trnAmount, chargeValue, trndesc);
		try{
			c2g__codaBankAccount__c bankAccount = rDML.getBankAccount(bAccId);
			if(bankAccount == null){
				errorMessage = 'Can not find Bank Account for transaction currency. Check Bank Accounts for company: ' + companyName;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, errorMessage));
				noInitErrors = false;
            }	
            //Check that cash entry already created:
            List<Rietumu_Transaction__c> lt = rDML.getTransactions(trnId);
            if(lt.size()!=0){
                errorMessage = 'Cash Entry already created for this transaction!';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, errorMessage));
                noInitErrors = false;
            }
            // Create Cash Entry 
			cashEntry = new c2g__codaCashEntry__c();
			cashEntry.c2g__BankAccount__c = bankAccount.Id;
			cashEntry.c2g__CashEntryCurrency__c = bankAccount.c2g__BankAccountCurrency__c;
			cashEntry.c2g__Date__c = trnDate; 
			cashEntry.c2g__PaymentMethod__c = 'Electronic';
			c2g__codaPeriod__c period = rDML.getPeriod(companyId, trnDate);
			if(period == null){
				errorMessage = 'Can not find period for transaction date (' + trnDate.format() + ' owmer companyId: ' + bankAccount.c2g__OwnerCompany__c + ')';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, errorMessage));
				noInitErrors = false;
			}
			Account acc = rDML.getAccount(benName);
			if(acc != null){
				cashEntry.c2g__Account__c = acc.Id; 
			}
			cashEntry.c2g__Period__c = period.Id;
			cashEntry.c2g__Type__c = cshType;   
			cashEntry.c2g__Value__c = Math.abs(trnAmount);
			cashEntry.c2g__TotalCharges__c = value.getChargeValue();
            if(trnDesc != '') cashEntry.c2g__Description__c = '(Type: ' + trndesc + ')';
			if(details != '')cashEntry.c2g__Description__c = cashEntry.c2g__Description__c  + ' ' + details;
			cashEntry.c2g__ChargesGLA__c = bankAccount.c2g__GeneralLedgerAccount__c;
			cashEntry.c2g__OwnerCompany__c = bankAccount.c2g__OwnerCompany__c; 
            c2g__codaGeneralLedgerAccount__c chargesGLA = rDML.getChargesGLA(CHARGES_GLA_ACC_NAME);
            if (chargesGLA != null) CashEntry.c2g__ChargesGLA__c = chargesGLA.Id;
			cashEntry.c2g__NetValue__c = cashEntry.c2g__Value__c - cashEntry.c2g__TotalCharges__c;
			Rietumu_Account_Dictionary__c dict = rDML.getDictionary(benName);
			if (dict != null){
				cashEntry.c2g__Account__c = dict.account__c;					
			}			
        
            c2g__codaAccountingCurrency__c usedCurrency = [SELECT Id, c2g__Home__c, Name 
                                                           FROM c2g__codaAccountingCurrency__c 
                                                           WHERE Id=:cashEntry.c2g__CashEntryCurrency__c];
            showAddRate = !usedCurrency.c2g__Home__c;
            if(showAddRate){  
                c2g__codaAccountingCurrency__c homeCurrency = [SELECT Id, Name 
                                                               FROM c2g__codaAccountingCurrency__c 
                                                               WHERE c2g__OwnerCompany__c=:cashEntry.c2g__OwnerCompany__c AND c2g__Home__c = true];
                rateOrValue = 1;
                rateOrValueSO = new List<SelectOption>();
                rateOrValueSO.add(new SelectOption('0', 'Rate ' + usedCurrency.Name + '/' + homeCurrency.Name));
                rateOrValueSO.add(new SelectOption('1', 'Value in ' + homeCurrency.Name));
                rate.c2g__StartDate__c = cashEntry.c2g__Date__c; 

            }

		}catch(Exception e){
            ApexPages.addMessages(e);
            noInitErrors = false;
		}  
    }
    
    //Action function
    public PageReference createAndMatchAction(){
        createCashEntry();
        if(cashEntryId != ''){
            return new PageReference('/apex/ffc_CEMatchingToolPage?Id='+cashEntryId);
        }else{
            return null;
        }
    }
    
	//Action function
    public void createCashEntry(){
        cashEntryId = '';
        
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
        
		//Init CashEntry with API
		c2g.CODAAPICashEntryTypes_6_0.CashEntry ce = new c2g.CODAAPICashEntryTypes_6_0.CashEntry();
		ce.BankAccount = c2g.CODAAPICommon.getRef(cashEntry.c2g__BankAccount__c, null);
		ce.BankAccountCurrency = trnCur;
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
		
		//Inserting to DB with API	
        //Save point for rollback:
		System.Savepoint createCashEntryPoint = Database.setSavepoint();
		try{
            //Check that cash entry already created:
            List<Rietumu_Transaction__c> lt = rDML.getTransactions(trnId);
            if(lt.size()!=0){
                errorMessage = 'Cash Entry already created for this transaction!';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, errorMessage));
                return;
            }
			c2g.CODAAPICommon.Reference ref = ffAPI.createCashEntry(ce);
			system.debug('Created cashentry: ' + ref);
			c2g__codaCashEntry__c nCe = rDML.getCashEntry(ref.Id);
			if(nCe != null){
                                
				Rietumu_Transaction__c rTrn = new Rietumu_Transaction__c();
				rTrn.name = trnId;
				rTrn.Cash_Entry__c = nCe.Id;
                rTrn.Unique_Id__c = trnId;
				rDML.insertSObject(rTrn);
				if (chargeTrnId != null && chargeTrnId != ''){
					rTrn = new Rietumu_Transaction__c();
					rTrn.name = chargeTrnId;
                    rTrn.Unique_Id__c = chargeTrnId; 
					rTrn.Cash_Entry__c = nCe.Id;
					rDML.insertSObject(rTrn);					
				}
				Rietumu_Account_Dictionary__c dict = rDML.getDictionary(benName);			
				if (dict == null){
					dict = new Rietumu_Account_Dictionary__c();
					dict.benname__c = benName;
					dict.account__c = cashEntry.c2g__Account__c;
					rDML.insertSObject(dict);
				}
                cashEntryId = nCe.Id;
			}else{
                // Rollback database if Cashentry not created  
                Database.rollback(createCashEntryPoint);
                errorMessage = 'Cash entry not created. Undefined reason!';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, errorMessage));
                return;
			}
		}catch (exception e){
		    // Rollback database if error 
		    Database.rollback(createCashEntryPoint);
		    errorMessage = 'Error: ' + e.getMessage() + '. Cash entry not created!';
		    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, errorMessage));
		}
	}
    
	//Action function
    public void updateChargesValue(){
		cashEntry.c2g__TotalCharges__c = value.getChargeValue(cashEntry.c2g__Type__c);
		cashEntry.c2g__NetValue__c = cashEntry.c2g__Value__c - cashEntry.c2g__TotalCharges__c;
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