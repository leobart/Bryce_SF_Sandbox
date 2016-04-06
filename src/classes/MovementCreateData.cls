public with sharing class MovementCreateData {
	public static final String NONE_DP = 'none';
	
	public DPTreeItem treeItem {get; set;}
	public List<MovementCreateCell> movementsCreateCells {get; set;}
	
	public String locationA {get; set;} 
	public String LocationB {get; set;}
	public String typeA {get; set;}
	public String typeB {get; set;}
	public Boolean remove {get; set;}
	public Double finalBalance {get; set;}
	public String errorMessage {get; set;}
	public String unavailableMessage {get; set;}
	public String warningMessage {get; set;}
	public List<SelectOption> dpListForTransfer {get; set;}
	public Boolean transferAvailable {get; set;}
	public Boolean firstLocationMCD {get; set;}
	public Boolean lastLocationMCD {get; set;}
	public List<SelectOption> buyDocuments {get; set;}
	public List<SelectOption> sellDocuments {get; set;}
    public String imageSourceA {get; set;}
    public String imageSourceB {get; set;}
	public Id locationBId;
	public Integer lastMccId = 0;
	private Integer nextId  = 0;
	private DeliveryPlanFilter filter;
	private String id;
    private Route route;

	
	public MovementCreateData(){
		
	}
	
	//TODO REMOVE THIS!!!
	public MovementCreateData(DeliveryPlanTree treeItem, Route route){	
	}
	
	public MovementCreateData(DPTreeItem treeItem, DeliveryPlanFilter filter){
		this.filter = filter;
		this.route = filter.route;
		this.treeItem = treeItem;
        init();
	}
    
    public void init(){
		firstLocationMCD = false;
		lastLocationMCD = false;
		unavailableMessage = '';
		errorMessage = '';
		movementsCreateCells = new List<MovementCreateCell>();
		remove = false;
		finalBalance = 0;
		if (treeItem != null){
	     	locationA = treeItem.getMovement().Location__r.Name;
			typeA = treeItem.getMovement().Type__c;
			if (route.isLast(treeItem.getMovement().Location__r.Id) && treeItem.getMovement().Type__c == DeliveryPlanFilter.DISPATCHED_TYPE){
				unavailableMessage = 'Movement dispatched in last location! Movement will be discarded';
			} else if (treeItem.getMovement().Balance__c == 0){
 				unavailableMessage = 'Balance = 0! Movement will be discarded';   				
			} else if (typeA == DeliveryPlanFilter.LOSS_TYPE){
				unavailableMessage = 'Cannot create movements for loss! Movement will be discarded';	    									
			} else if (typeA == DeliveryPlanFilter.DISPATCHED_TRANSFER_TYPE){
				unavailableMessage = 'Cannot create movements for Dispatched transfer type! Movement will be discarded';	    									
			}  else{
				// Set location B:
     			if (typeA == DeliveryPlanFilter.DELIVERED_TYPE || typeA == DeliveryPlanFilter.DELIVERED_TRANSFER_TYPE){
    				LocationB = locationA;
    				locationBId = treeItem.getMovement().Location__r.Id;
    				typeB = DeliveryPlanFilter.DISPATCHED_TYPE;
    			} else if (typeA == DeliveryPlanFilter.DISPATCHED_TYPE){
    				Location__c nextLocation = route.getNextLocation(treeItem.getMovement().Location__r.Id);
    				if (nextLocation == null){
    					errorMessage = 'Can not get next location after ' + locationA;
    				}
    				LocationB = nextLocation.Name;
    				locationBId = nextLocation.Id;
    				typeB = DeliveryPlanFilter.DELIVERED_TYPE;
    			}  	    		
    			MovementCreateCell mcc = new MovementCreateCell();
    			mcc.addEnable = true;
    			mcc.delEnable = false;
    			mcc.id = getNextId();
                transferAvailable = false;
                dpListForTransfer = new List<SelectOption>();
                if(typeB == DeliveryPlanFilter.DISPATCHED_TYPE && !route.isLast(treeItem.getMovement().Location__r.Id)){
                    transferAvailable = true;
                    dpListForTransfer = filter.getDeliveryPlansForTransfer(treeItem.getMovement().Location__r.Id);
                    mcc.dpListForTransfer = dpListForTransfer;
                    if(dpListForTransfer.size()>0){
                        mcc.buyDocumentList = filter.getTransferBuyDocsSO(dpListForTransfer[0].getValue());
                        mcc.sellDocumentList = filter.getTransferSellDocsSOWithNone(dpListForTransfer[0].getValue());
                    }
                }		
    			mcc.dpListForTransfer = dpListForTransfer;
				if (typeA == DeliveryPlanFilter.DELIVERED_TYPE && route.isLast(treeItem.getMovement().Location__r.Id)){
					lastLocationMCD = true;	
					mcc.sellDocumentList = filter.getSelectedSellDocsSO();
                    if(treeItem.getMovement().Sell_Document__c != null) mcc.sellDocumentId = treeItem.getMovement().Sell_Document__c;
					//transferAvailable = false;   									
		     	}
	    		movementsCreateCells.add(mcc);		    				    		  			
    			mcc.movement = prepareChildMovement();
 		        setImageSources();
			}
		}
    }
    
	//Constructor for root movements
	public MovementCreateData(DeliveryPlanFilter filter){
		movementsCreateCells = new List<MovementCreateCell>();
		this.filter = filter;
		warningMessage = '';
    	errorMessage = '';	
    	transferAvailable = false;
		lastLocationMCD = false;
		firstLocationMCD = true;
		locationB = filter.route.getFirstLocation().Name;
		locationBId = filter.route.getFirstLocation().Id;
		typeB = DeliveryPlanFilter.DISPATCHED_TYPE;
		finalBalance = 1;
		this.buyDocuments = filter.getSelectedBuyDocsSO();
		this.sellDocuments = filter.getSelectedSellDocsSOWithNone();
		MovementCreateCell mcc = new MovementCreateCell();
		mcc.buyDocumentList = buyDocuments;	
        mcc.sellDocumentList = sellDocuments;
		mcc.addEnable = true;
		mcc.delEnable = false;
		mcc.id = getNextId();
		mcc.movement = prepareFirstMovement();
		movementsCreateCells.add(mcc);	
        imageSourceB = DeliveryPlanFilter.getResourceURL('up_right_arrow');
	}
	
    private void setImageSources(){
        if(locationA == locationB){
            imageSourceA = DeliveryPlanFilter.getResourceURL('down_right_arrow');
            imageSourceB = DeliveryPlanFilter.getResourceURL('up_right_arrow');
        }else{
            imageSourceA = DeliveryPlanFilter.getResourceURL('up_right_arrow');
            imageSourceB = DeliveryPlanFilter.getResourceURL('down_right_arrow');
        }
    }
	
	private Movement__c prepareChildMovement(){
    	Movement__c child = new Movement__c();
	    child.Quantity__c = treeItem.getBalance();
	    child.Date__c = treeItem.getMovement().Date__c;
	    child.Previous_Movement__c = treeItem.getMovement().Id;
	    child.Buy_Document__c = treeItem.getMovement().Buy_Document__c;
	    child.Sell_Document__c = treeItem.getMovement().Sell_Document__c;        
	    child.Delivery_Plan__c = treeItem.getMovement().Delivery_Plan__r.Id;
	    child.Location__c = locationBId;
	    child.Type__c = typeB;
        child.Moved__c = 0;
        if(lastLocationMCD){
            child.State__c = 'Last';
        }else {
            child.State__c = 'Intermediate';
        }
    	return child;
    }
	
	private Movement__c prepareFirstMovement(){
    	Movement__c child = new Movement__c();
	    child.Quantity__c = 1;
	    child.Date__c = Date.today();
	    child.Delivery_Plan__c = filter.deliveryPlanId;
	    child.Location__c = locationBId;
	    child.Type__c = typeB;
        child.Moved__c = 0;
        child.State__c = 'First';
    	return child;
    }	
	
	public Integer getNextId(){
		Integer id = nextId;
		nextId++;
		return id;
	}  
	
    public void addSubMovement(){
    	if (firstLocationMCD){
			for(MovementCreateCell mcc : movementsCreateCells){
				mcc.addEnable = false;
				mcc.delEnable = true;	
			}
			MovementCreateCell mcc = new MovementCreateCell();
			mcc.addEnable = true;
			mcc.delEnable = true;
			mcc.movement = prepareFirstMovement();
			mcc.id = getNextId();
			mcc.buyDocumentList = buyDocuments;
            mcc.sellDocumentList = sellDocuments;
			movementsCreateCells.add(mcc);
			warningMessage = '';
    	}else{
			Double summ = 0; 
			for(MovementCreateCell mcc : movementsCreateCells){
				summ = mcc.movement.Quantity__c + summ;
			}
			if(treeItem.getBalance() - summ > 0){
				for(MovementCreateCell mcc : movementsCreateCells){
					mcc.addEnable = false;
					mcc.delEnable = true;	
				}
				MovementCreateCell mcc = new MovementCreateCell();
				mcc.addEnable = true;
				mcc.delEnable = true;
				mcc.movement = prepareChildMovement();
				mcc.movement.Quantity__c = treeItem.getBalance() - summ;				
				mcc.id = getNextId();
				mcc.dpListForTransfer = dpListForTransfer;
                if(lastLocationMCD) mcc.sellDocumentList = filter.getSelectedBuyDocsSO(); 
				movementsCreateCells.add(mcc);
				warningMessage = '';
				finalBalance = 0;
			}else if (treeItem.getBalance() - summ == 0){
				warningMessage = 'Can not add more movements, change quantity values';				
			}    		
    	}
    }
    
    public void delSubMovement(){
   		List<MovementCreateCell> mccs = new List<MovementCreateCell>();
		for(MovementCreateCell mcc : movementsCreateCells){
			if (!mcc.remove){
				mccs.add(mcc);
				mcc.addEnable = false;
				mcc.delEnable = true;
			}
		}
		movementsCreateCells = mccs; 
		if (movementsCreateCells.size() > 0){
			Integer i = movementsCreateCells.size()-1;
			movementsCreateCells[i].addEnable = true;	
			//can not delete last one							
			if (movementsCreateCells.size() == 1) movementsCreateCells[0].delEnable = false;							
		}	
    	warningMessage = '';
    	errorMessage = '';		
   		calculateFinallyBalance();	  	
    }
    
    public void calculateFinallyBalance(){
    	if (firstLocationMCD) return;
    	warningMessage = '';
 		Double summ = 0; 
		for(MovementCreateCell mcc : movementsCreateCells){
			summ = mcc.movement.Quantity__c + summ;
		}
    	finalBalance = treeItem.getBalance() - summ;
    	if (finalBalance < 0) errorMessage = 'Finall balance cannot be < 0! Change quantity values';
    	else errorMessage = '';
    }
    
    public void checkDates(){
    	if (firstLocationMCD) return;
		for(MovementCreateCell mcc : movementsCreateCells){
			if ( mcc.movement.Date__c  < treeItem.getMovement().Date__c){
				errorMessage = 'Date cannot be later than ' + treeItem.getMovement().Date__c.format() + '. Correct dates';
				return;
			}
		}    	
    }     
	
	public String getFinalBalanceStr(){
		return finalBalance.format();
	}
	
	public String getId(){
		if (firstLocationMCD){
			return 'RootMCD';
		}
		return treeItem.getMovement().Id;
	}
	  	
	
}