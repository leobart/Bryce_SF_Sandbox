public with sharing class RietumuELController {
	
    // Constants
    public static final String CHARGES_GLA_ACC_NAME ='6-1200 Bank Charges for payments';    
	//public static final String SSL_CERTIFICATE = 'RietumuBridgeClientCertificate';
	
	//Variables
    public String companyName {get;set;}
	public List<SelectOption> rELinks {get; set;}
	public String linkId {get; set;}
	public List<SelectOption> bAccounts {get; set;}
	public String bAccountId {get; set;}
	public String lang {get; set;}
	public String curr {get; set;}
	public String errorMessage {get; set;}
	public Boolean userAllowed {get; set;}	
	public List<RietumuTransaction> transactionList {get; set;}
	public String selectedTransactionId {get; set;}
	public Integer transactionsCount {get; set;}
	public Decimal netVal {get; set;}
    public String cashEntryId {get; set;}	
	public c2g__codaCashEntry__c cashEntry {get; set;}
    public Date releaseDate {get; set;}
    
    public String updatedTrnId {get; set;}
    public String updatedChargeTrnId {get; set;}
    
    public String body {get; set;}
	
	private RietumuDMLInterface rDML;
	private RietumuAPIWrapperInterface ffAPI; 
	private String companyId;
	private String ticket;	
    private String startDateS;
    private String EndDateS;
    private Rietumu_EL__c link;
    public DateTime startDate;
    public DateTime endDate;
	
    private Map<String, c2g__codaBankAccount__c> bAccCurrencyMap;
	
	public RietumuELController(){
		ffAPI = new RietumuFFAPIWrapper();
		rDML = new RietumuDML();
		init();
	}
	
	public RietumuELController(RietumuAPIWrapperInterface ffAPI, RietumuDMLInterface rDML){
		this.ffAPI = ffAPI;
		this.rDML = rDML;
		init();
	}
	private void init(){
        releaseDate = Date.valueOf(Rietumu_Bridge_Settings__c.getInstance().Release_Date__c);
        cashEntryId = '';
		userAllowed = false;
        lang = 'EN';
		transactionsCount = 0;
		rELinks = new List<SelectOption>(); 
		bAccounts = new List<SelectOption>();
		List<String> currCompamies = ffAPI.getCurrentCompanies();
        if(currCompamies.size() > 1) {
        	errorMessage = 'This utility does not work in multi-company mode. Please select one company. See: Select Company Tab.';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, errorMessage));
        	return;
        }else if (currCompamies.size() == 0){
        	errorMessage = 'Current Company not selected. Please select one company. See: Select Company Tab.';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, errorMessage));
        	return;        	
        }else {
        	link = rDML.getAllowedLink(currCompamies[0]);
        	if(link == null){
	         	errorMessage = 'Selected company not supported by Rietumu Bank. See: Select Company Tab.';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, errorMessage));
	        	return;        		
        	}
	        companyName = link.Company__R.name;
	        companyId = link.Company__R.Id;
	        ticket = link.ticket__c;
        }                      
        List<c2g__codaBankAccount__c> bAcc = rDML.getBankAccounts(companyId);
        bAccCurrencyMap = new Map<String, c2g__codaBankAccount__c>();
        List<String> cardAliases = new List<String>();
        String cardAliasesStr = Rietumu_Bridge_Settings__c.getInstance().Card_Aliases__c;
        if (cardAliasesStr != null) cardAliases = cardAliasesStr.split(',');
        for(c2g__codaBankAccount__c ba : bAcc){ 
            Boolean skipAccount = false;
            for(String alias : cardAliases){
                if (ba.name.contains(alias)){
                    skipAccount = true;
                    break;
                }    
            }
            if (skipAccount) continue;
            String curStr = ba.c2g__BankAccountCurrency__r.Name;
            if(curStr == 'RUR') curStr = 'RUB';
            bAccounts.add(new SelectOption(ba.Id, ba.name));
            bAccCurrencyMap.put(curStr, ba);
        } 
        if(bAccounts.size() == 0){
        	errorMessage = 'Do not find Rietumu Bank Accounts for company: ' + companyName;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, errorMessage));
        	return;        	
        }	
        bAccounts.add(new SelectOption('0', 'ALL'));
        bAccountId = '0';
        startDate = Date.today().toStartOfMonth();
        endDate = Date.today();	
        startDateS = Date.today().toStartOfMonth().format();
        endDateS = Date.today().format();
        userAllowed = true;	
        transactionsRequest();
	}
    
    public void moveMonth(Integer i){
        Date d = startDate.date();
        d = d.addMonths(i).toStartOfMonth();
        startDate = d;
        startDateS = d.format();
        Date d2 = Date.newInstance(d.year(), d.month(), Date.daysInMonth(d.year(), d.month()));  
        endDate = d2;
        endDateS = d2.format();
    }
    
    public void nextMonth(){
        moveMonth(1);
        transactionsRequest();
    }
	
    public void prevMonth(){
        moveMonth(-1);
        transactionsRequest();
    }
	
	//Action function
    public void transactionsRequest(){
		transactionsCount = 0;
		transactionList = new List<RietumuTransaction>();
		errorMessage = '';
		String rietumuURL = Rietumu_Bridge_Settings__c.getInstance().Rietumu_URL__c;
		String rietumuProxyURL = Rietumu_Bridge_Settings__c.getInstance().Rietumu_Proxy_URL__c;
		if (bAccountId != '0'){
			curr = rDML.getBankAccountCurrency(bAccountId);
            if(curr == 'RUR') curr = 'RUB';
		}else{
			curr = 'ALL';
		}
        String rietumuId = Rietumu_Bridge_Settings__c.getInstance().Rietumu_Id__c;
        String rPassword = Rietumu_Bridge_Settings__c.getInstance().Password__c;
        if(link.Rietumu_Id__c != null) rietumuId = link.Rietumu_Id__c;
        if(link.Rietumu_Password__c != null) rPassword = link.Rietumu_Password__c;
		HttpRequest req = new HttpRequest();
     	req.setEndpoint(rietumuProxyURL);
    	req.setMethod('POST');
    	//req.setClientCertificateName(SSL_CERTIFICATE); 
	    String reqBody = 'url=' + EncodingUtil.urlEncode(rietumuURL, 'UTF-8') +
	              '&function=Transactions' +
	              '&rid=' + rietumuId +
	              '&password=' + rPassword +
	    	      '&ticket=' + ticket + 
	    	      '&dateFrom=' + startDate.format('yyyy-MM-dd') + 
	    		  '&dateTill=' + endDate.format('yyyy-MM-dd') + 
	    		  '&language=' + lang;
	    if (curr != 'ALL') reqBody = reqBody + '&ccy=' + curr;
	    req.setBody(reqBody);
	    req.setTimeout(120000);
	    Http http = new Http();
	    try{
		    HTTPResponse res = http.send(req);
            //body = res.getBody();
		    if (res.getStatusCode() != 200){
		    	errorMessage = 'Rietumu Bank connection failure, reposnse code: ' + res.getStatusCode() + ' , message: ' + res.getStatus() + '. Try Again!';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, errorMessage));
		    	return;
		    }	
		    parseXMLResponse(res.getBodyDocument());	    	
	    }catch(CalloutException e){
	    	errorMessage = 'Timeout error, try again!'; 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, errorMessage));
	    }	    	    
	}
	   
   
	private static final String RESPONSE_NODE = 'response';
	private static final String CODE_NODE = 'code';
	private static final String ERROR_NODE = 'error';
	private static final String TRANSACTIONS_NODE = 'transactions';
	private static final String TRANSACTION_NODE = 'transaction';
	
	
	public void parseXMLResponse(Dom.Document doc){
		Dom.Xmlnode root = doc.getRootElement();
		String nameSpace = root.getNamespace();
		if (root.getName() != RESPONSE_NODE){
			errorMessage = 'Unclassified error. Rietumu Bank server do not return XML';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, errorMessage));
			return;
		} else {
			Dom.Xmlnode codeNode = doc.getRootElement().getChildElement(CODE_NODE, nameSpace);
	        Dom.Xmlnode errorNode = doc.getRootElement().getChildElement(ERROR_NODE, nameSpace);
			if (codeNode == null){
				errorMessage = 'Do not find ' + CODE_NODE + ' in responce XML';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, errorMessage));
				return;	
			}
			if (codeNode.getText() == '0' ){
				Dom.Xmlnode transactionNodes = doc.getRootElement().getChildElement(TRANSACTIONS_NODE, nameSpace);
				if (transactionNodes.getChildElements().size() > 99){
					errorMessage = 'Too match transactions in response. You can not view more than 99 transactions. Please change date interval';
					ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, errorMessage));
                    return;
				}
				for(Dom.Xmlnode transNode : transactionNodes.getChildElements()){
					RietumuTransaction trans = RietumuTransaction.create(transNode, nameSpace, rDML);
					transactionList.add(trans);										
				}
			} else if (codeNode.getText() == '2'){
				errorMessage = 'No transactions in selected period!';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, errorMessage));
				return;
			} else{
				if (errorNode != null && errorNode.getText() !='') errorMessage = '. Rietumu Server connection failure, message: ' + errorNode.getText();
				errorMessage = 'HTTP Error code: ' + codeNode.getText() + errorMessage + '. Try again!';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, errorMessage));
				return;									
			}
			transactionsCount = transactionList.size();
            prepereTransactions();
		}	
	}
    
    //Set cashentry links for transactions
    private void setCashEntryForTransactions(){
        List<String> trnIDs = new List<String>();
        for(RietumuTransaction rt : transactionList){
            trnIDs.add(rt.uniqueId);
        }
        List<Rietumu_Transaction__c> lt = rDML.getTransactions(trnIDs);
        list<String> cshList = new list<String>(); 
        Map<String, List<RietumuTransaction>> cshMap = new Map<String, List<RietumuTransaction>>(); 
        for(Rietumu_Transaction__c t : lt){
            String uniqueId = t.Name;
            RietumuTransaction rTrn = getTransaction(uniqueId);
            rTrn.matched = false;
            if(rTrn != null) rTrn.cashEntry = t.Cash_Entry__r;
            cshList.add(t.Cash_Entry__c);
            List<RietumuTransaction>  dTrns = cshMap.get(t.Cash_Entry__c);
            if(dTrns == null){
                dTrns = new List<RietumuTransaction>();
            	cshMap.put(t.Cash_Entry__c, dTrns);
            }
            dTrns.add(rTrn);
        } 
        list<c2g__codaCashEntry__c> postedCSHList = [SELECT Id, c2g__Transaction__c FROM c2g__codaCashEntry__c WHERE Id IN: cshList AND c2g__Transaction__c != null];
        List<String> trnIdList = new List<String>();
        Map<String, String> trnMap = new Map<String, String>(); 
        for(c2g__codaCashEntry__c csh : postedCSHList){
            trnIdList.add(csh.c2g__Transaction__c);
            trnMap.put(csh.c2g__Transaction__c, csh.Id);
        }
        List<c2g__codaTransactionLineItem__c> trnLIList = [SELECT Id, c2g__Transaction__c 
                                                           FROM c2g__codaTransactionLineItem__c 
                                                           WHERE c2g__Transaction__c IN: trnIdList 
                                                           AND Aged_analysis_category__c='Matched'];
        for(c2g__codaTransactionLineItem__c trnLI : trnLIList){
            String cshId = trnMap.get(trnLI.c2g__Transaction__c);
            List<RietumuTransaction> rTrns = cshMap.get(cshId);
            if(rTrns == null) continue;
            for(RietumuTransaction rt : rTrns){
            	rt.matched = true;                           
            } 
        }
    }
    
    //set cashEntry, transaction value and parameters string
    public void prepereTransactions(){
    	setCashEntryForTransactions();
        for (Integer i = 0; i < transactionList.size(); i++){
            c2g__codaBankAccount__c bAcc = bAccCurrencyMap.get(transactionList[i].cur);
            if(bAcc != null) transactionList[i].ceCur = bAcc.c2g__BankAccountCurrency__r;
            RietumuTransaction.Value value;
            String params;
			if((i != transactionList.size()-1) && 
                transactionList[i].refno == transactionList[i+1].refno &&
                transactionList[i+1].uniqueId.contains('@@') &&
                transactionList[i].cur == transactionList[i+1].cur){
				value = new RietumuTransaction.Value(transactionList[i].amount, transactionList[i+1].amount, transactionList[i].trndesc);
                transactionList[i].trnValue = value;
                transactionList[i+1].trnValue = value;
                bAcc = bAccCurrencyMap.get(transactionList[i+1].cur);
                if(bAcc != null) transactionList[i+1].ceCur = bAcc.c2g__BankAccountCurrency__r;
                if(transactionList[i].cashEntry == null){
                    params = getParametersStr(transactionList[i], transactionList[i+1]);
                    transactionList[i].parameters = params;
                    transactionList[i+1].parameters = params;                    
                }
                i++;
            }else{
				value = new RietumuTransaction.Value(transactionList[i].amount, 0, transactionList[i].trndesc);
                transactionList[i].trnValue = value;
                if(transactionList[i].cashEntry == null){
					transactionList[i].parameters = getParametersStr(transactionList[i], null);                   
                } 
            }
        }  
    }
    
    private String getParametersStr(RietumuTransaction trn, RietumuTransaction chargeTrn){
        RietumuTransaction.Value val = trn.trnValue;
        String bAccId = 'undefined';
        c2g__codaBankAccount__c bAcc = bAccCurrencyMap.get(trn.cur);
        if(bAcc != null) bAccId = bAcc.Id;
    	String params = 'trnId=' + trn.uniqueId +
                         '&bAccId=' + bAccId +
                         '&companyId=' + companyId +
                         '&companyName=' + EncodingUtil.urlEncode(companyName+'', 'UTF-8') +
                         '&trnDate=' + EncodingUtil.urlEncode(trn.tdate+'', 'UTF-8') +
                         '&trnCur=' + EncodingUtil.urlEncode(trn.cur+'', 'UTF-8') +
                         '&benName=' + EncodingUtil.urlEncode(trn.benname+'', 'UTF-8') +
                         '&cshType=' + EncodingUtil.urlEncode(val.getType()+'', 'UTF-8') +
                         '&trnAmount=' + EncodingUtil.urlEncode(val.amount+'', 'UTF-8') +
                         '&trndesc=' + EncodingUtil.urlEncode(trn.trndesc, 'UTF-8') +
                         '&chargeValue=' + EncodingUtil.urlEncode(val.charge+'', 'UTF-8') +
                         '&details=' + EncodingUtil.urlEncode(trn.details+'', 'UTF-8');
        if(chargeTrn != null) params = params + '&chargeTrnId='+chargeTrn.uniqueId; 
        return String.escapeSingleQuotes(params);
    }
    
    public void updateTransaction(){
        c2g__codaCashEntry__c csh = rDML.getCashEntry(cashEntryId);
        RietumuTransaction trn = getTransaction(updatedTrnId);
        if(trn != null){
            trn.cashEntry = csh;
        }
        trn = getTransaction(updatedChargeTrnId);
        if(trn != null){
            trn.cashEntry = csh;
        }       
    }
    
    //Find transaction in list by Id
    private RietumuTransaction getTransaction(String uniqueId){
        for(RietumuTransaction t : transactionList){
            if(t.uniqueId == uniqueId) return t;
        }
        return null;
    }
	
	//Find selected transaction
    private RietumuTransaction getSelectedTransaction(){
        return getTransaction(selectedTransactionId);
	}
		
	public String getStartDateS(){
            return startDateS;
    }
    
    public void setStartDateS(String d){
            this.startDateS = d;
            startDate = Date.parse(d);
    }
    
    public String getEndDateS(){
            return endDateS;
    }
    
    public void setEndDateS(String d){
            this.endDateS = d;
            endDate = Date.parse(d);
            
    }
	

}