public with sharing class RietumuTransaction {
	
	public static final String BANK_RIETUMU_ACC_NAME = 'Bank Rietumu';
    
    public class Value{
        
        public Decimal amount {get; set;}
        public Decimal charge {get; set;}
        public String description {get; set;}
        
        public Value(Decimal amount, Decimal charge, String description){
            this.amount = amount;
            this.charge = charge;
            this.description = description;
        }
        
        public Decimal getChargeValue(){
            return getChargeValue(getType());	
        }
        
        public Decimal getChargeValue(String ceType){
            if(charge != null){
                if(amount > 0){
                    return Math.abs(charge);
                }else if(ceType == 'Payment' || ceType == 'Refund'){
                    return -Math.abs(charge);
                }else if(ceType == 'Receipt' || ceType == 'Payment Refund'){
                    return Math.abs(charge);
                }
            }	
            return 0;	
        } 
        
        public String getType(){
            String ceType;
            if (amount > 0){
                ceType = 'Receipt';			
            }else{
                ceType = 'Payment';
            }
            if(description == 'Currency Exchange'){
                if(amount > 0){
                    ceType = 'Payment Refund';				
                }else{
                    ceType = 'Payment';
                }
                            
            }else if (description == 'Charge'){
                ceType = 'Payment';
            }else if (description.contains('fee')){
                ceType = 'Payment';
            }
            return ceType;
        }
    }
	
	public String uniqueId {get; set;}
	public String trnId {get; set;}
	public Date tdate {get; set;}
	public String refno {get; set;}
	public String docno {get; set;}
	public String benname {get; set;}
	public String benacc {get; set;}
	public String benid {get; set;}
	public String benbank {get; set;}
	public String benbankswift {get; set;}
	public String details {get; set;}
	public Decimal amount {get; set;}
	public String cur {get; set;}
	public Decimal saldo {get; set;}
	public String trtype {get; set;}
	public String trntype {get; set;}
	public String trndesc {get; set;}
	public String tcf {get; set;}
    
	public c2g__codaCashEntry__c cashEntry{get; set;}
    public c2g__codaAccountingCurrency__c ceCur{get; set;}
    public boolean matched {get; set;}
    public Value trnValue {get; set;}
    public String parameters {get; set;}
	
	private RietumuDMLInterface rDML;
	
	private RietumuTransaction(){
		
	}
	
	public static RietumuTransaction create(Dom.Xmlnode node, String nameSpace, RietumuDMLInterface rDML){
		RietumuTransaction rt = new RietumuTransaction();
		rt.rDML = rDML;
		Dom.Xmlnode currNode;
        rt.matched = false;
		currNode = node.getChildElement('uniqueID', nameSpace);
		if (currNode != null) rt.uniqueId = currNode.getText();
		currNode = node.getChildElement('trnID', nameSpace);
		if (currNode != null) rt.trnId = currNode.getText();
		currNode = node.getChildElement('date', nameSpace);
		if (currNode != null) rt.tdate = Date.valueOf(currNode.getText());
		currNode = node.getChildElement('refno', nameSpace);
		if (currNode != null) rt.refno = currNode.getText();
		currNode = node.getChildElement('docno', nameSpace);
		if (currNode != null) rt.docno = currNode.getText();
		currNode = node.getChildElement('benname', nameSpace);
		if (currNode != null) rt.benname = currNode.getText();
		if (rt.benname == '') rt.benname = BANK_RIETUMU_ACC_NAME;
		currNode = node.getChildElement('benacc', nameSpace);
		if (currNode != null) rt.benacc = currNode.getText();
		currNode = node.getChildElement('benbank', nameSpace);
		if (currNode != null) rt.benbank = currNode.getText();
		currNode = node.getChildElement('benbankswift', nameSpace);
		if (currNode != null) rt.benbankswift = currNode.getText();
		currNode = node.getChildElement('details', nameSpace);
		if (currNode != null) rt.details = currNode.getText();
		currNode = node.getChildElement('amount', nameSpace);
		if (currNode != null) rt.amount = Decimal.valueOf(currNode.getText());
		currNode = node.getChildElement('currency', nameSpace);
		if (currNode != null) rt.cur = currNode.getText();
		currNode = node.getChildElement('saldo', nameSpace);
		if (currNode != null) rt.saldo = Decimal.valueOf(currNode.getText());
		currNode = node.getChildElement('trtype', nameSpace);
		if (currNode != null) rt.trtype = currNode.getText();
		currNode = node.getChildElement('trntype', nameSpace);
		if (currNode != null) rt.trntype = currNode.getText();
		currNode = node.getChildElement('trndesc', nameSpace);
		if (currNode != null) rt.trndesc = currNode.getText();
		currNode = node.getChildElement('tcf', nameSpace);
		if (currNode != null) rt.tcf = currNode.getText();
		//system.debug('Rietumu transaction: ' + rt);
		return rt;
	}
	
    //depricated for remove
	public void updateCashEntry(){
		List<Rietumu_Transaction__c> trns = rDML.getTransactions(uniqueId); 
		if(trns.size() != 0){
			cashEntry = trns[0].Cash_Entry__r;
		}
		
	}

    public String getCssClass(){
        if(matched){
            return 'matchedCell';
        }else if(cashEntry != null){
            return 'createCECell';
        }
        return 'commonCell';
        //return '';
    }
    
    public String getAllowedUniqeuId(){
        return uniqueId.replace('@@', '__');
    }
}