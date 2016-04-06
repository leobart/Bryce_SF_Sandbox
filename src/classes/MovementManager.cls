public with sharing class MovementManager {
	
	public List<MovementCreateData> movementCreateItems {get; set;}
    public String currentMcdId {get; set;}
    public Integer currentMccId {get; set;}

    public Movement_Document__c mDocument {get; set;}
    public Movement_Document_For_Movement__c mdfm {get; set;}
    public String assignDocType {get; set;}
    public Set<String> selectedMovements {get; set;}
    
    public BulkMovementCreateData bmcd {get; set;}
    
    public Decimal moveQuantity{get; set;}
    public Boolean moveQuantityAvailable {get; set;}
    public Boolean moveQuantitySelected {get; set;}
    
    public Boolean assignDocumentAvailable {get; set;}
    
    private DPTree dpTree;
    
    public MovementManager(DPTree dpTree){
    	this.dpTree = dpTree;
    } 
    
    public void createMovementItems(){
        moveQuantity = 0;
    	//Create movements selection list for display on '/apex/createMovementsPage'
    	movementCreateItems = new List<MovementCreateData>();
        //Update movements
        String[] selMovementIds = new List<String>();
    	for(DPTreeItem treeItem : dpTree.treeItems){
    		If (treeItem.state.selected){
                selMovementIds.add(treeItem.getMovement().Id);
    		}
    	}
        Set<Movement__c> updatedMovements = dpTree.getFilter().getMovements(selMovementIds);
    	for(DPTreeItem treeItem : dpTree.treeItems){
    		If (treeItem.state.selected){
    			// Creation data for selected treeItem
                for(Movement__c m : updatedMovements) {
                    if (treeItem.getMovement().id == m.Id){
                        treeItem.setMovement(m);
                        break;
                    }
                }
    			movementCreateItems.add(new MovementCreateData(treeItem, dpTree.getFilter()));  
    		}
    	}
    	if (movementCreateItems.size() == 0){
    		movementCreateItems.add(new MovementCreateData(dpTree.getFilter())); 
            moveQuantityAvailable = false;
        }else{
            MovementCreateData prevMcd = movementCreateItems[0];
            moveQuantityAvailable = true;
            for(MovementCreateData mcd: movementCreateItems){
                moveQuantityAvailable = prevMcd.locationA == mcd.locationA && 
                                        prevMcd.locationB == mcd.locationB && 
                                        prevMcd.typeA == mcd.typeA && 
                                        prevMcd.typeB == mcd.typeB && 
                                        moveQuantityAvailable;                    
            }
            moveQuantityAvailable = moveQuantityAvailable && prevMcd.typeB == DeliveryPlanFilter.DISPATCHED_TYPE;
        }
        updateMoveQuantity();
    }
    
    public void calculateMCDForQuantityValue(){
        if(!moveQuantityAvailable) return;
        Decimal sumQ = 0;
        Boolean isComplete = false;
        List<MovementCreateData> newMCI = new List<MovementCreateData>();
        for(MovementCreateData mcd : movementCreateItems){
            newMCI.add(mcd);
            mcd.init();
            sumQ = mcd.treeItem.getMovement().Quantity__c + sumQ;
            if(sumQ > moveQuantity){
                //split value
                Decimal splitQ = mcd.treeItem.getMovement().Quantity__c - (sumQ - moveQuantity);
                mcd.movementsCreateCells[0].movement.Quantity__c = splitQ;
                mcd.calculateFinallyBalance(); 
                break;
            }                       
        }        
        if (sumQ < moveQuantity) moveQuantity = sumQ;
        movementCreateItems = newMCI;
    }
    
    public void updateMoveQuantity(){
        moveQuantity = 0;
        for(MovementCreateData mcd : movementCreateItems){
            for(MovementCreateCell mcc : mcd.movementsCreateCells){
                moveQuantity = moveQuantity + mcc.movement.Quantity__c;
            }
        }
    }
    
    public void bulkMovementCreationDataInit(){
        bmcd = new BulkMovementCreateData(dpTree.getFilter());
    }
    
    public boolean BulkMovementCreateAction(){
        List<Movement__c> movementsForCreate = new List<Movement__c>();
        List<Movement_Document__c> movDocsForCreate = new List<Movement_Document__c>();
        List<Movement_Document_For_Movement__c> movementToMovDocRelations = new List<Movement_Document_For_Movement__c>();
        //Create movements and docs
        for(BulkMovementCreateData.LineImportData lid : bmcd.importLines){
            movementsForCreate.add(lid.movement);
            for(Movement_Document__c mDoc : lid.documents){
	            movDocsForCreate.add(mDoc);
            }
        }
        System.Savepoint dbSavePoint = Database.setSavepoint();
        try{
            insert movementsForCreate;
            insert movDocsForCreate;
            //Create movements and docs
            for(BulkMovementCreateData.LineImportData lid : bmcd.importLines){
                for(Movement_Document__c mDoc : lid.documents){
                    movementToMovDocRelations.add(new Movement_Document_For_Movement__c(Movement__c = lid.movement.Id, Movement_Document__c = mDoc.Id));
                }
            } 
            insert movementToMovDocRelations;
        }catch(Exception e){
		    Database.rollback(dbSavePoint);
            ApexPages.addMessages(e);
            return false;           
        }
        return true;
    }

    public Boolean createMovements(){
    	checkForErrors();
        List<Movement__c> movementsForCreate = new List<Movement__c>(); 
        List<Movement__c> transferMovementsForCreate = new List<Movement__c>(); 
    	for(MovementCreateData mcd : movementCreateItems){
    		if(mcd.errorMessage != '') continue;
    		for(MovementCreateCell mcc : mcd.movementsCreateCells){
                if (mcc.loss){
                    mcc.movement.Type__c = DeliveryPlanFilter.LOSS_TYPE;    				
                }else if (mcd.transferAvailable && mcc.transfer){
                    mcc.movement.Type__c = DeliveryPlanFilter.DISPATCHED_TRANSFER_TYPE;    				
                    Movement__c transferMovement = new Movement__c(Date__c = mcc.movement.Date__c, 
                                                                  Quantity__c = mcc.movement.Quantity__c, 
                                                                  Location__c = mcc.movement.Location__c,
                                                                  Delivery_Plan__c = mcc.transferDPId,
                                                                  Buy_Document__c = mcc.buyDocumentId, Type__c = DeliveryPlanFilter.DELIVERED_TRANSFER_TYPE,
                                                                  Moved__c = 0, State__c='Intermediate');
                    if(mcc.sellDocumentId != 'none') transferMovement.Sell_Document__c = mcc.sellDocumentId;
                    transferMovementsForCreate.add(transferMovement);                        
                }else if (mcd.firstLocationMCD){
                    mcc.movement.Buy_Document__c = mcc.buyDocumentId;
                    if(mcc.sellDocumentId != 'none') mcc.movement.Sell_Document__c = mcc.sellDocumentId;
                }else if (mcd.lastLocationMCD){
                    if (mcc.sellDocumentId == '' || mcc.sellDocumentId == null){
                        mcd.errorMessage = 'Undefined sell document!';
                        continue;
                    }
                    mcc.movement.Sell_Document__c = mcc.sellDocumentId;
                }
                movementsForCreate.add(mcc.movement);
    		}
    	}
        System.Savepoint insertPoint = Database.setSavepoint();
        try{
            insert transferMovementsForCreate;
            insert movementsForCreate;
        }catch (Exception e){
            ApexPages.addMessages(e);
          	// Rollback database if error 
           	Database.rollback(insertPoint);
        }            
        List<MovementCreateData> mcds = new List<MovementCreateData>();
    	for(MovementCreateData mcd : movementCreateItems){
    		if(mcd.errorMessage != ''){
    			mcds.add(mcd);
    		}    		
    	}
    	movementCreateItems = mcds;
    	if (movementCreateItems.size() == 0){	    	
	    	return true;
    		
    	} 
    	return false;
    }
    
    public void removeMovementFromList(){
    	List<MovementCreateData> mcds = new List<MovementCreateData>();
    	for(MovementCreateData mcd : movementCreateItems){
    		if(!mcd.remove){
    			mcds.add(mcd);
    		}    		
    	}
    	movementCreateItems = mcds;
    }
    
     public void addSubMovement(){
      	MovementCreateData mcd = getCurrentMCD();
    	if (mcd != null){
    		mcd.addSubMovement();		
    	}
    }
 
     public void delSubMovement(){
     	MovementCreateData mcd = getCurrentMCD();
    	if (mcd != null){
    		mcd.delSubMovement();
    	}  
    }
 
     public void calculateFinallyBalance(){
        updateMoveQuantity(); 
    	MovementCreateData mcd = getCurrentMCD();
    	if (mcd !=null){
    		mcd.calculateFinallyBalance();    		
    	} 
    }    
 
     public void lossChanged(){
    	MovementCreateCell mcc = getCurrentMCC();
    	if(mcc.loss){
    		mcc.transferDisabled = true;
    	}else{
    		mcc.transferDisabled = false;
    	}   	
    }
    
    public void transferChanged(){
     	MovementCreateCell mcc = getCurrentMCC();
        if(mcc.dpListForTransfer.size()>0){
            mcc.buyDocumentList = dpTree.getFilter().getTransferBuyDocsSO(mcc.transferDPId);
            mcc.sellDocumentList = dpTree.getFilter().getTransferSellDocsSOWithNone(mcc.transferDPId);
        }

    }

    public void deleteMovements(){
        List<Movement__c> movementsForDelete = new List<Movement__c>();
    	for(DPTreeItem treeItem : dpTree.treeItems){
    		If (treeItem.state.selected){
                movementsForDelete.add(treeItem.getMovement());
    		}
    	}
        try{
        	delete movementsForDelete;            
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, String.valueOf(e)));
        }
    }
    
    public void initMDoc(){
        mdfm = new Movement_Document_For_Movement__c();
        mDocument = new Movement_Document__c();
        selectedMovements = dpTree.getSelectetMovementIDs();
        if(selectedMovements.size() == 0){
            assignDocType = 'none';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'No selected movements for assign!'));
        }else{
            assignDocType = 'select';
        }        
    }
    
    public boolean assignDocumentForMovements(){
        System.Savepoint dbSavePoint = Database.setSavepoint();
        try{
            List<Movement_Document_For_Movement__c> insertList = new List<Movement_Document_For_Movement__c>();
            String movementDocId;
            if (assignDocType == 'new'){
                insert mDocument;
                movementDocId = mDocument.Id;            
            } else{
                movementDocId = mdfm.Movement_Document__c;
            }
            for(String mId : selectedMovements){
                insertList.add(new Movement_Document_For_Movement__c(Movement__c = mId, Movement_Document__c = movementDocId));           
            }
            insert insertList;
        }catch(Exception e){
		    Database.rollback(dbSavePoint);
            ApexPages.addMessages(e);
            //assignDocType = 'none';
            return false;
        }
        return true;
     }
    
    
       
    private void checkForErrors(){
    	for (MovementCreateData mcd : movementCreateItems){
    		mcd.calculateFinallyBalance(); 
    		mcd.checkDates();   		    		
    	}
    }
    
    private MovementCreateData getCurrentMCD(){
    	for(MovementCreateData mcd : movementCreateItems){
    		if (mcd.getId() == currentMcdId) return mcd;
    	}
    	system.debug('Can not find current MCD with id: ' + currentMcdId);
    	return null;
    }
    
    private MovementCreateCell getCurrentMCC(){
    	MovementCreateData mcd = getCurrentMCD();
    	for(MovementCreateCell mcc : mcd.movementsCreateCells){
    		if (mcc.id == currentMccId) return mcc;
    	}
    	system.debug('Can not find current MCC with id: ' + currentMccId);
    	return null;
    }
    
	

}