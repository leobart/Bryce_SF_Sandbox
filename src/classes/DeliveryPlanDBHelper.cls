public with sharing class DeliveryPlanDBHelper {
    //Type of movements:
    public static final String DELIVERED_TYPE = 'Delivered';
    public static final String DISPATCHED_TYPE = 'Dispatched';
    public static final String DELIVERED_TRANSFER_TYPE = 'Delivered Transfer';
    public static final String DISPATCHED_TRANSFER_TYPE = 'Dispatched Transfer';
    public static final String LOSS_TYPE = 'Loss';
	
	public DeliveryPlanFilter filter;
	
	public DeliveryPlanDBHelper(DeliveryPlanFilter filter){
		this.filter = filter;
		
	}
	
	public Double getAmountForFirstLocation(){
       return getAmountForLocation(filter.route.getFirstLocation().Id, DISPATCHED_TYPE);
    }
    
    public Double getAmountForLocation(Id locationId, String type){
        Double amt = (Double)[SELECT SUM(Quantity__c)summ FROM Movement__c WHERE Delivery_Plan__r.Id =:filter.deliveryPlan.Id AND Location__r.Id =:locationId AND Type__c=:type][0].get('summ'); 
        if (amt == null){
            amt=0;
        }
       return amt;
    }
    
    public Double getLossForLocation(Id locationId, String type){
         Double amt = (Double)[SELECT SUM(Quantity__c)summ FROM Movement__c WHERE Delivery_Plan__r.Id =:filter.deliveryPlan.Id AND Location__r.Id =:locationId AND Type__c=:LOSS_TYPE AND Previous_Movement__r.Type__c=:type][0].get('summ'); 
        if (amt == null){
            amt=0;
        }
       return amt;
    }
	

}