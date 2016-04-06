public class BRC_RTM_EnterpriseLink {
    
    public class ConnectionException extends Exception{
    }
    
    public static list<RietumuTransaction> getTransactions(String rietumuURL, String proxyURL, DateTime startDate, DateTime endDate, String ticket, String rietumuId, String password, String curr, String lang){
		HttpRequest req = new HttpRequest();
     	req.setEndpoint(proxyURL);
    	req.setMethod('POST');
	    String reqBody = 'url=' + EncodingUtil.urlEncode(rietumuURL, 'UTF-8') +
	              '&function=Transactions' +
	              '&rid=' + rietumuId +
	              '&password=' + password +
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
		    if (res.getStatusCode() == 200){
		    	return parseXML(res.getBodyDocument());	    	
		    }
            throw new ConnectionException('Rietumu Bank connection failure, reposnse code: ' + res.getStatusCode() + ' , message: ' + res.getStatus() + '. Try Again!');
	    }catch(CalloutException e){
            throw new ConnectionException(e.getMessage() + ' Timeout error, try again!');
	    }
        return new list<RietumuTransaction>();                                               
          
    }
    
	private static final String RESPONSE_NODE = 'response';
	private static final String CODE_NODE = 'code';
	private static final String ERROR_NODE = 'error';
	private static final String TRANSACTIONS_NODE = 'transactions';
	private static final String TRANSACTION_NODE = 'transaction';
	
	
	private static list<RietumuTransaction> parseXML(Dom.Document doc){
        List<RietumuTransaction> transactionList = new List<RietumuTransaction>();
		Dom.Xmlnode root = doc.getRootElement();
		String nameSpace = root.getNamespace();
		if (root.getName() != RESPONSE_NODE){
            throw new ConnectionException('Unclassified error. Rietumu Bank server do not return XML');
		} else {
			Dom.Xmlnode codeNode = doc.getRootElement().getChildElement(CODE_NODE, nameSpace);
	        Dom.Xmlnode errorNode = doc.getRootElement().getChildElement(ERROR_NODE, nameSpace);
			if (codeNode == null){
                throw new ConnectionException('Do not find ' + CODE_NODE + ' in responce XML');
			}
			if (codeNode.getText() == '0' ){
				Dom.Xmlnode transactionNodes = doc.getRootElement().getChildElement(TRANSACTIONS_NODE, nameSpace);
				for(Dom.Xmlnode transNode : transactionNodes.getChildElements()){
					RietumuTransaction trans = RietumuTransaction.create(transNode, nameSpace, null);
					transactionList.add(trans);										
				}
			} else if (codeNode.getText() == '2'){
				//infoMessage = 'No transactions in selected period!';
			} else{
                if (errorNode != null && errorNode.getText() !=''){
                    throw new ConnectionException('Rietumu Server connection failure, message: ' + errorNode.getText());
                }else{
                     throw new ConnectionException('HTTP Error code: ' + codeNode.getText() + '. Rietumu Server connection failure, message: ' + errorNode.getText() + '. Try again!');
                } 
			}
		}
        return transactionList;
	}
    

}