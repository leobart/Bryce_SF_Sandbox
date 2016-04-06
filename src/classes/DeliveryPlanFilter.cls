public with sharing class DeliveryPlanFilter {
		
	//Type of movements:
    public static final String DELIVERED_TYPE = 'Delivered';
    public static final String DISPATCHED_TYPE = 'Dispatched';
    public static final String DELIVERED_TRANSFER_TYPE = 'Delivered Transfer';
    public static final String DISPATCHED_TRANSFER_TYPE = 'Dispatched Transfer';
    public static final String LOSS_TYPE = 'Loss';
    
    //Sort order types:
    public static final String DATE_ASC_SORT = 'Date__c ASC';
    public static final String DATE_DESC_SORT = 'Date__c DESC';
    public static final String VOLUME_ASC_SORT = 'Quantity__c ASC';
    public static final String VOLUME_DESC_SORT = 'Quantity__c DESC';
    public static final List<SelectOption> sortOrderListStatic = new List<SelectOption>();
    static {
    	sortOrderListStatic.add(new Selectoption(DATE_ASC_SORT, 'Date Ascending'));
    	sortOrderListStatic.add(new Selectoption(DATE_DESC_SORT, 'Date Descending'));
    	sortOrderListStatic.add(new Selectoption(VOLUME_ASC_SORT, 'Volume Ascending'));
    	sortOrderListStatic.add(new Selectoption(VOLUME_DESC_SORT, 'Volume Descending'));    	
    }
    
    //Delivery document types:
    public static final String DD_BUY_TYPE = 'Buy';
    public static final String DD_SELL_TYPE = 'Sell';
    
    
    //Filter properties
    public Boolean lossDisable {get; set;}
    public Boolean dispTransferDisable {get; set;}
    public Boolean movementCBox {get; set;}
    public Boolean completelyMovedCBox {get; set;}
    public Boolean delivTransferCBox {get; set;}
    
    public List<DeliveryDocument> buyDocumentsList {get; set;}
    public List<String> selectedBuyDocuments {get; set;}
    public Boolean selectAllBuyDocuments {get; set;}
    
    public List<DeliveryDocument> sellDocumentsList {get; set;}
    public List<String> selectedSellDocuments {get; set;}
    public Boolean selectAllSellDocuments {get; set;}
        
    public List<SelectOption> sortOrderList {get; set;}
	public String sortOrder {get; set;}
 	public Delivery_Plan__c deliveryPlan {get; set;}
	public Route route {get; set;}
    
    public List<SelectOption> deliveryPlans {get; set;}
    public String deliveryPlanId {get; set;}
    
    private String startDateS;
    private String EndDateS;
    public Date startDate;
    public Date endDate;
   	
	
	public DeliveryPlanFilter(){
		deliveryPlans = new List<SelectOption>();
		List<Delivery_Plan__c> dps = [SELECT id, Name, Cargo__r.Name, Cargo__r.Id FROM Delivery_Plan__c];
        for(Delivery_Plan__c dp : dps){           
            deliveryPlans.add(new SelectOption(dp.Id, getDPName(dp)));
        }
        deliveryPlanId = dps[0].Id;
        selectAllBuyDocuments = true;
        selectAllSellDocuments = true;
        updateDeliveryDocumentsList();		
		lossDisable = true;
        dispTransferDisable = true;
        movementCBox = true;
        completelyMovedCBox = true;
        delivTransferCBox = true;
		
		startDateS = Date.today().format();
        endDateS = Date.today().format();
        startDate = Date.today();
        endDate = Date.today();		
		
		sortOrder = DATE_ASC_SORT;
		sortOrderList = sortOrderListStatic;
		updateFilter();
	}
    
    private String getDPName(Delivery_Plan__c dp){
        return dp.Name + ' (' + dp.Cargo__r.Name + ')';
    }
	
	public DeliveryPlanFilter copy(){
		DeliveryPlanFilter cloneFilter = new DeliveryPlanFilter();
		cloneFilter.route = this.route;
		cloneFilter.deliveryPlan = this.deliveryPlan;
		cloneFilter.deliveryPlanId = this.deliveryPlanId;	
		cloneFilter.selectedBuyDocuments = getSelectedBuyIds();
        cloneFilter.selectedSellDocuments = getSelectedSellIDs();
		cloneFilter.buyDocumentsList = this.buyDocumentsList.clone();
		cloneFilter.sellDocumentsList = this.sellDocumentsList.clone();
		cloneFilter.sortOrder = this.sortOrder;
		cloneFilter.startDate = this.startDate;
		cloneFilter.endDate = this.endDate;	
        cloneFilter.completelyMovedCBox = this.completelyMovedCBox;
        cloneFilter.delivTransferCBox = this.delivTransferCBox;
        cloneFilter.movementCBox = this.movementCBox;
		return cloneFilter;
	}
	
	public void updateFilter(){
		deliveryPlan = [SELECT Name, Id, Route__r.id, Cargo__r.Name, Cargo__r.Id FROM Delivery_Plan__c WHERE id=:deliveryPlanId];
		route = new Route(deliveryPlan.Route__r.Id);
						
	}
	
	public Double getAmountForFirstLocation(){
       return getAmountForLocation(route.getFirstLocation().Id, DISPATCHED_TYPE);
    }
    
    public Double getAmountForLocation(Id locationId, String type){
        Double amt = (Double)[SELECT SUM(Quantity__c)summ FROM Movement__c WHERE Delivery_Plan__r.Id =:deliveryPlanId AND Location__r.Id =:locationId AND Type__c=:type][0].get('summ'); 
        if (amt == null){
            amt=0;
        }
       return amt;
    }
    
    public Double getLossForLocation(Id locationId, String type){
         Double amt = (Double)[SELECT SUM(Quantity__c)summ FROM Movement__c WHERE Delivery_Plan__r.Id =:deliveryPlanId AND Location__r.Id =:locationId AND Type__c=:LOSS_TYPE AND Previous_Movement__r.Type__c=:type][0].get('summ'); 
        if (amt == null){
            amt=0;
        }
       return amt;
    }
    
    //TODO not used, for REMOVE
    public List<Movement__c> getRootMovements(){
    	Id firstLocationId = route.getFirstLocation().Id;
    	return Database.query('SELECT Id, Quantity__c, Date__c, Type__c, Location__r.Id, Location__r.Name, Buy_Document__r.id, Delivery_Plan__r.id ' +
    	                      'FROM Movement__c ' +
    	                      'WHERE Delivery_Plan__r.id =:deliveryPlanId AND ' +
    	                             'Location__r.Id = :firstLocationId AND ' +
    	                             'Date__c >= :startDate AND Date__c <= :endDate AND '+ 
    	                             'Buy_Document__r.Id IN :selectedBuyDocuments ' + 
    	                             'ORDER BY ' + sortOrder);
    }
    
    //TODO not used, for REMOVE
    public List<Movement__c> getChildMovements(Movement__c movement){
    	Id movementId = movement.Id;
    	return Database.query('SELECT Id, Quantity__c, Date__c, Type__c, Location__r.Id, Location__r.Name, Buy_Document__r.id, Delivery_Plan__r.id ' +
    	                      'FROM Movement__c '  +
    	                      'WHERE Delivery_Plan__r.id =:deliveryPlanId AND ' +
    	                             'Previous_Movement__r.Id = :movementId AND '  +
    	                             'Buy_Document__r.Id IN :selectedBuyDocuments ' + 
    	                             'ORDER BY ' + sortOrder);
    }
    
    public Set<Movement__c> getMovements(){
        return new Set<Movement__c>([SELECT Id, Quantity__c, Date__c, Type__c, Balance__c, Location__r.Id, Location__r.Name, Buy_Document__r.id, Sell_Document__r.id, Delivery_Plan__r.id, Previous_Movement__c, Moved__c
                FROM Movement__c 
                WHERE Delivery_Plan__r.id =:deliveryPlanId 
                	AND Buy_Document__c IN :selectedBuyDocuments 
                	AND (Sell_Document__c = null OR Sell_Document__c IN: selectedSellDocuments)
                	AND Date__c >= :startDate AND Date__c <= :endDate]);
    }
    
    public Set<Movement__c> getMovements(List<String> mIds){
        return new Set<Movement__c>([SELECT Id, Quantity__c, Date__c, Type__c, Balance__c, Location__r.Id, Location__r.Name, Buy_Document__r.id, Sell_Document__r.id, Delivery_Plan__r.id, Previous_Movement__c, Moved__c
                FROM Movement__c 
                WHERE Id IN: mIds]);
    }
        
    public Set<Movement__c> getMovementsForParent(List<String> mIds){
        return new Set<Movement__c>([SELECT Id, Quantity__c, Date__c, Type__c, Balance__c, Location__r.Id, Location__r.Name, Buy_Document__r.id, Sell_Document__r.id, Delivery_Plan__r.id, Previous_Movement__c, Moved__c
                FROM Movement__c 
                WHERE Previous_Movement__r.Id IN: mIds]);
    }
    
    public void updateDeliveryDocumentsList(){
        selectAllBuyDocuments = true;
        selectAllSellDocuments = true;
    	buyDocumentsList = new List<DeliveryDocument>();
    	List<Delivery_Document__c> dds = [SELECT Name, Planned_month__c, Contract__r.name, Addendum__r.name FROM Delivery_Document__c WHERE Delivery_Plan__r.Id=:deliveryPlanId AND Type__c=:DD_BUY_TYPE];
    	for(Delivery_Document__c dd : dds){
    		buyDocumentsList.add(new DeliveryDocument(dd.Id, dd.Name, dd.Contract__r.Name, dd.Addendum__r.Name, dd.Planned_month__c));
    	} 
        sellDocumentsList = new List<DeliveryDocument>();
    	dds = [SELECT Name, Contract__r.name, Planned_month__c, Addendum__r.name FROM Delivery_Document__c WHERE Delivery_Plan__r.Id=:deliveryPlanId AND Type__c=:DD_SELL_TYPE];
    	for(Delivery_Document__c dd : dds){
    		sellDocumentsList.add(new DeliveryDocument(dd.Id, dd.Name, dd.Contract__r.Name, dd.Addendum__r.Name, dd.Planned_month__c));
    	}
    	updateFilter();
    }
           
    public List<SelectOption> getSelectedBuyDocsSO(){
    	List<SelectOption> buyDocs = new List<SelectOption>();
    	for(DeliveryDocument dd : buyDocumentsList){
    		if (dd.selected) buyDocs.add(new SelectOption(dd.Id, dd.getStrValue())); 
    	}
    	return buyDocs;   	
    }
    
    public List<SelectOption> getTransferBuyDocsSO(String deliveryPlanId){
        List<Delivery_Document__c> dds = [SELECT Name, Contract__r.name, Planned_month__c, Addendum__r.name 
                                              FROM Delivery_Document__c 
                                              WHERE Delivery_Plan__r.Id=:deliveryPlanId  AND Type__c=:DD_BUY_TYPE];
    	List<SelectOption> docsSO = new List<SelectOption>();
        for(Delivery_Document__c dd : dds){
            DeliveryDocument dDoc = new DeliveryDocument(dd.Id, dd.Name, dd.Contract__r.Name, dd.Addendum__r.Name, dd.Planned_month__c);
            docsSO.add(new SelectOption(dDoc.Id, dDoc.getStrValue())); 
        }
        return docsSO;       
    }
    
    public List<SelectOption> getSelectedSellDocsSO(){
    	List<SelectOption> sellDocs = new List<SelectOption>();
    	for(DeliveryDocument dd : sellDocumentsList){
    		if (dd.selected) sellDocs.add(new SelectOption(dd.Id, dd.getStrValue())); 
    	}
    	return sellDocs;   	
    }
    
    public List<SelectOption> getSelectedSellDocsSOWithNone(){
    	List<SelectOption> sellDocs = new List<SelectOption>();
        sellDocs.add(new SelectOption('none', 'none'));
    	for(SelectOption so : getSelectedSellDocsSO()){
    		sellDocs.add(so);	 
    	}
    	return sellDocs;   	
    }
    
    public List<SelectOption> getTransferSellDocsSOWithNone(String deliveryPlanId){
        List<Delivery_Document__c> dds = [SELECT Name, Contract__r.name, Planned_month__c, Addendum__r.name 
                                              FROM Delivery_Document__c 
                                              WHERE Delivery_Plan__r.Id=:deliveryPlanId  AND Type__c=:DD_SELL_TYPE];
    	List<SelectOption> docsSO = new List<SelectOption>();
        docsSO.add(new SelectOption('none', 'none'));
        for(Delivery_Document__c dd : dds){
            DeliveryDocument dDoc = new DeliveryDocument(dd.Id, dd.Name, dd.Contract__r.Name, dd.Addendum__r.Name, dd.Planned_month__c);
            docsSO.add(new SelectOption(dDoc.Id, dDoc.getStrValue())); 
        }
        return docsSO;       
    }
    
    public List<SelectOption> getDeliveryPlansForTransfer(String locationId){
        system.debug('DP: ' + deliveryPlan);
        Delivery_Plan__c[] dps = [SELECT ID, Name, Cargo__r.Name 
                                   FROM Delivery_Plan__c 
                                   WHERE Route__c IN (SELECT Route__c FROM Locations_List__c WHERE Location__c=:locationId)
                                  		AND Id !=: deliveryPlanId
                                        AND Cargo__c =: deliveryPlan.Cargo__r.Id];
        SelectOption[] dpListSO = new List<SelectOption>();
        for(Delivery_Plan__c dp : dps){
            dpListSO.add(new SelectOption(dp.Id, getDPName(dp)));
        }
        return dpListSO;
    }
    
    /*public List<SelectOption> getSellDocsSO(){
    	List<SelectOption> sellDocs = new List<SelectOption>();
    	List<Delivery_Document__c> dds = [SELECT Name, Planned_month__c, Contract__r.name, Addendum__r.name FROM Delivery_Document__c WHERE Delivery_Plan__r.Id=:deliveryPlanId AND Type__c=:DD_SELL_TYPE];
    	for(Delivery_Document__c dd : dds){
    		DeliveryDocument sd = new DeliveryDocument(dd.Id, dd.Name, dd.Contract__r.Name, dd.Addendum__r.Name, dd.Planned_month__c);
    		sellDocs.add(new SelectOption(sd.Id, sd.getStrValue())); 
    	}
    	return sellDocs;   	
    }*/
    
    private List<String> getSelectedBuyIds(){
    	List<String> ddIds = new List<String>();
    	for(DeliveryDocument dd : buyDocumentsList){
    		if(dd.selected){
    			ddIds.add(dd.Id);
    		}    		
    	} 
    	return ddIds;  	
    }
    
    private List<String> getSelectedSellIds(){
    	List<String> ddIds = new List<String>();
    	for(DeliveryDocument dd : sellDocumentsList){
    		if(dd.selected){
    			ddIds.add(dd.Id);
    		}    		
    	} 
    	return ddIds;  	
    }
    
    public static String getResourceURL(String resourceName){

            // Fetching the resource
            List<StaticResource> resourceList= [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = :resourceName];

            // Checking if the result is returned or not
            if(resourceList.size() == 1){

               // Getting namespace
               String namespace = resourceList[0].NamespacePrefix;
               // Resource URL
               return '/resource/' + resourceList[0].SystemModStamp.getTime() + '/' + (namespace != null && namespace != '' ? namespace + '__' : '') + resourceName; 
            }
            else return '';
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
    
    public void selectAllBuyDocuments(){
        for(DeliveryDocument dd : buyDocumentsList){
            dd.selected = selectAllBuyDocuments;
        }
    }
    
    public void selectAllSellDocuments(){
        for(DeliveryDocument dd : sellDocumentsList){
            dd.selected = selectAllSellDocuments;
        }
    }
    
    public Integer getBuyDocumentsListSize(){
        return buyDocumentsList.size();
    }
    
    public Integer getSellDocumentsListSize(){
        return buyDocumentsList.size();
    }
    
    
	

}