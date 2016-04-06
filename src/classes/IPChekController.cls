public class IPChekController{
    
    private String url = 'http://5.79.75.194:8517/RietumuProxy/testip';
    public String serverResponse {get; set;}
    public List<String> l {get; set;}
    
    public IPChekController(){
        l = new list<String>();
        serverResponse = 'none';
        HttpRequest req = new HttpRequest();
     	req.setEndpoint(url);
    	req.setMethod('GET');
	    Http http = new Http();
	    try{
		    HTTPResponse res = http.send(req);
		    if (res.getStatusCode() != 200){
		    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Server return error: ' + res.getStatusCode()));
		    	return;
		    }		    
		    serverResponse = res.getBody();    	
	    }catch(CalloutException e){
            ApexPages.addMessages(e);
	    }	    	    
    }
    
}