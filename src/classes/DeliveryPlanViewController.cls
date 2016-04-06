public with sharing class DeliveryPlanViewController {
        
    public Boolean showFilter {get; set;}
    public Boolean showTable {get; set;}
           
    public DeliveryPlanFilter filter {get; set;}
    public DeliveryPlanTable dpTable {get; set;}   
    public MovementManager movementManager {get; set;}   
    public DPTree dpTree {get; set;}
           
    public Integer selectColNumber {get; set;}
    public Boolean selectColValue {get; set;}
    
    public DeliveryPlanViewController(){
        showFilter = true;
        showTable = false;
        filter = new DeliveryPlanFilter();
        dpTree = new DPTree();
        dpTable = new DeliveryPlanTable(dpTree);
        movementManager = new MovementManager(dpTree);
    }
                    
    // Action function
    public void buildTableWithNewFilter(){
        showTable = true;
        dpTable.buildAllTable(filter.copy());
    }
    
    // Action function
    public void buildTableWithCurrFilter(){
        dpTable.buildAllTable();
    }
    
    // Action function
    public void buildTableWithoutReloadTree(){
        dpTable.buildTableWithoutReloadTree();
    }
    
    // Action function
    public void filterSwitch(){
        showFilter = !showFilter;       
    } 
    
    // Action function
    public void uncollapseAllCells(){
        for(DPTreeItem treeItem : dpTree.treeItems){
                treeItem.state.opened = true;
        }
        dpTable.buildTableWithoutReloadTree();
    } 
    
    // Action function
    public void createInvoice(){
        //TODO
    }
    
    // Action function
    public Pagereference createMovementsPage(){
        movementManager.createMovementItems();
        return new PageReference('/apex/createMovementsPage');
    }  
        
    // Action function (create movements button in createMovementsPage)   
    public PageReference createMovements(){
        if (movementManager.createMovements()){
            buildTableWithCurrFilter();
            return commonPage();        
        }
        return new PageReference('/apex/createMovementsPage');
    }
    
    // Action function
    public PageReference bulkMovementsCreationPage(){
        movementManager.bulkMovementCreationDataInit();
        return new PageReference('/apex/bulkMovementCreatePage');
    }
           
    // Action function
    public void removeMovementFromList(){
        movementManager.removeMovementFromList();
    }
    
    // Action function
    public void addSubMovement(){
        movementManager.addSubMovement();
    }
    
    // Action function
    public void delSubMovement(){
        movementManager.delSubMovement(); 
    }
    
    //Action function
    public void calculateFinallyBalance(){
        movementManager.calculateFinallyBalance(); 
    }    
      
    // Action function
    public void lossChanged(){
        movementManager.lossChanged();
    }
    
    // Action function
    public void transferChanged(){
        movementManager.transferChanged();
    }
    
    //Action function
    public void deleteMovements(){
        movementManager.deleteMovements();
        buildTableWithCurrFilter();
    }
    
    //Action function
    public void unselectAll(){
        dpTree.unselectAll();
    }
          
    //Action function
    public void updateDeliveryDocumentsList(){
        filter.updateDeliveryDocumentsList();
    }
    
    //Action function
    public void selectAllBuyDocuments(){
        filter.selectAllBuyDocuments();
    }
    
    //Action function
    public void selectAllSellDocuments(){
        filter.selectAllSellDocuments();
    }
    
    //Action function
    public void unselectAllBuyDocuments(){
        filter.selectAllBuyDocuments = false;
    }
    
    //Action function
    public void unselectAllSellDocuments(){
        filter.selectAllSellDocuments = false;
    }
    public PageReference commonPage(){
        //buildTableWithCurrFilter();
        return new PageReference('/apex/deliveryPlanPage');
    }
    
    //Action function
    public void selectAllColumn(){
        dpTree.selectAllMovementsInLevel(selectColNumber, selectColValue);        
    }
    
    //Action function
    public PageReference assignMDocPage(){
        movementManager.initMDoc();
        return new PageReference('/apex/assignMovementDocumentPage');
    }
    
    //Action function
    public PageReference assignDocForMovements(){
        if (movementManager.assignDocumentForMovements()){
           return commonPage(); 
        } else{
           return new PageReference('/apex/assignMovementDocumentPage'); 
        }

    }
    
    //Acgion function
    public void expandInColumn(){
        dpTree.expandInLevel(true, selectColNumber);
        buildTableWithoutReloadTree();
    }
    
    //Acgion function
    public void collapseInColumn(){
        dpTree.expandInLevel(false, selectColNumber);
        buildTableWithoutReloadTree();
    }
    
    //Action for add columnParseData in BulkMovementCreateData
    public void addColumnParseData(){
        movementManager.bmcd.addParseParam();
    }

    //Action for BulkMovementCreateData
    public void deleteParseColumn(){
        movementManager.bmcd.deleteParseColumn();
    }
    
    //Action for BulkMovementCreateData
    public void removeDublicatesFromParseParams(){
        movementManager.bmcd.removeDublicatesFromParseParams();
    }
    
    //Action for BulkMovementCreateData
    public PageReference bulkCreateAction(){
        if(!movementManager.bmcd.parseMovementsAndDocsForBulkCreation()){
            return bulkMovementCreatePage();
        }
        return new PageReference('/apex/bulkMovementCreateParsePage');
    }
    
    public PageReference bulkMovementCreatePage(){
        return new PageReference('/apex/bulkMovementCreatePage');
    }
    
    public PageReference bulkMovementCreateAction(){
        if (movementManager.BulkMovementCreateAction()){
            buildTableWithCurrFilter();
            return commonPage();
        }
        return new PageReference('/apex/bulkMovementCreateParsePage');
    }
    
    public void moveQuantityCalculation(){
        movementManager.calculateMCDForQuantityValue();
    }
    
	//Just for update old data
    //For remove:
    public void setMovementState(){
        List<Movement__c> movements = [SELECT Id, Location__c, State__c, Delivery_PLan__c, Type__c FROM Movement__c];
        List<Delivery_Plan__c> dPlans = [SELECT Id, Route__c FROM Delivery_Plan__c];
        List<Locations_List__c> locationsList = [SELECT Id, Location__c, Route__c, Sequence_Number__c FROM Locations_List__c];
        for(Movement__c movement : movements){
            //search route
            String routeId = null;
            for(Delivery_Plan__c dp : dPlans){
                if(dp.Id == movement.Delivery_Plan__c){
                    routeId = dp.Route__c;
                    break;
                } 
            }
            if (routeId == null) continue;
            Decimal maxNum = 1;
            String firstLocationId = null;
            String lastLocationId = null;
            //determine first/last locations for this route
            for(Locations_List__c locList : locationsList){
                if(locList.Route__c == routeId){
                    if(locList.Sequence_Number__c == 1){
                        firstLocationId = locList.Location__c;
                    }else if(locList.Sequence_Number__c > maxNum){
                        lastLocationId = locList.Location__c;
                        maxNum = locList.Sequence_Number__c;
                    }
                }               
            }
            if(movement.Location__c == firstLocationId){
                movement.State__c = 'First';
            }else if (movement.Location__c == lastLocationId && movement.Type__c == 'Dispatched'){
                movement.State__c = 'Last';
            }else{
                movement.State__c = 'Intermediate';
            }
        }
        update movements;
    }
    
    //For remove:
    /*public void fillMovedField(){
        Movement__c[] updateMs = new List<Movement__c>();
        Movement__c[] ms = [SELECT Id, Previous_Movement__r.Id, Previous_Movement__r.Moved__c , Moved__c FROM Movement__c WHERE Previous_Movement__c != null AND Previous_Movement__r.Moved__c =null];
        for(Movement__c m : ms){
            Movement__c parentM = m.Previous_Movement__r;
            AggregateResult[] ars = [SELECT SUM(Quantity__c) totalMoved FROM Movement__c WHERE Previous_Movement__c =: m.Previous_Movement__c];
             Decimal moved = 0;
             if(ars.size()>0){
                 moved = (Decimal)ars[0].get('totalMoved');               
             }
             if(parentM.Moved__c != moved){
                 parentM.Moved__c = moved;
                 //update parentM;
                 updateMs.add(parentM);
             }
        }  
        update updateMs;
    }*/
               
}