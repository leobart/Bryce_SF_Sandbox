// Class with rules for preparing several Rietumu Transactions in one Cashe Entry
public with sharing class RietumuRules {
	
	public class RietumuRuleException extends Exception {}
	
	private RietumuTransaction amountTrn;
	private RietumuTransaction chargeTrn;
	private List<RietumuTransaction> trnList;
	
	public RietumuRules(RietumuTransaction trn, List<RietumuTransaction> trnList){
		this.trnList = trnList;
		if(trn.uniqueId.contains('@@')){
			this.chargeTrn = trn;
			for (Integer i = 1; i < trnList.size(); i++){
				if(trnList[i].uniqueId == trn.uniqueId && i>0 && trnList[i-1].refno == trn.refno){
					this.amountTrn = trnList[i-1];
                    break;
				}
			}	  
			if (this.amountTrn == null){
			 	//throw new RietumuRuleException('Can not find pair transaction for charge transaction!');					
				amountTrn = trn;
				chargeTrn = null;
			}
		} else {
			this.amountTrn = trn;	
			for (Integer i = 0; i < trnList.size()-1; i++){
				if(trnList[i].uniqueId == trn.uniqueId && trnList[i+1].refno == trn.refno && trnList[i+1].uniqueId.contains('@@')){
					this.chargeTrn = trnList[i+1];
                    break;
				}
			}			
		}
		system.debug('Rules transactions: ' + amountTrn.uniqueId + ' charge: ' + chargeTrn);
	} 
	
	public Decimal getChargeValue(){
		return getChargeValue(getType());	
	}
	
	public Decimal getChargeValue(String ceType){
		if(chargeTrn != null){
			if(amountTrn.amount > 0){
				return Math.abs(chargeTrn.amount);
			}else if(ceType == 'Payment' || ceType == 'Refund'){
				return -Math.abs(chargeTrn.amount);
			}else if(ceType == 'Receipt' || ceType == 'Payment Refund'){
				return Math.abs(chargeTrn.amount);
			}
		}	
		return 0;	
	} 
	
	public RietumuTransaction getTransaction(){
		return amountTrn;	
	}
	
	public RietumuTransaction getChargeTransaction(){
		return chargeTrn;	
	}
	
	public String getType(){
		String ceType;
		if (amountTrn.amount > 0){
			ceType = 'Receipt';			
		}else{
			ceType = 'Payment';
		}
		if(amountTrn.trndesc == 'Currency Exchange'){
			if(amountTrn.amount > 0){
				ceType = 'Payment Refund';				
			}else{
				ceType = 'Payment';
			}
						
		}else if (amountTrn.trndesc == 'Charge'){
			ceType = 'Payment';
		}else if (amountTrn.trndesc.contains('fee')){
			ceType = 'Payment';
		}
		return ceType;
	}
	
	public void updateCashEntry(){
		amountTrn.updateCashEntry();
		if (chargeTrn != null) chargeTrn.updateCashEntry();
	}

}