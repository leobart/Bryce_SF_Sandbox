public with sharing class DPTree {
    
    private DeliveryPlanFilter filter;
    public MovementBuffer buffer{get; set;} 
    private DPTreeItem rootItem;
    private Map<Id, DPCState> treeItemStates = new Map<Id, DPCState>();
    public Set<DPTreeItem> treeItems = new Set<DPTreeItem>();
    
    public DPTree(){
        buffer = new MovementBuffer();         
    }
    
    public DPTreeItem getRoot(){
        return rootItem;
    }
    
    public void setFilter(DeliveryPlanFilter filter){
        this.filter = filter;
        buffer.setFilter(filter);
    }
    
    public DeliveryPlanFilter getFilter(){
        return filter;
    }
    
    public Decimal getselectedSum(){
        Decimal sum = 0;
        for(DPTreeItem treeItem : treeItems){
            if(treeItem.state.selected) sum = sum + treeItem.getMovement().Quantity__c;            
        }
        return sum;
    }
    
    public Set<String> getSelectetMovementIDs(){
        Set<String> selItems = new Set<String>();
        for(DPTreeItem treeItem : treeItems){
            If (treeItem.state.selected){
                selItems.add(treeItem.getMovement().Id);
            }
        }
        return selItems;
    }
    
    public void reloadTree(){
        buffer.updateBuffer();
        rootItem = new DPTreeItem();
        rootItem.value = 'Values';
        rootItem.level = -1;
        rootItem.isRoot = true;
        scanTree(null, rootItem);
        buildPrevItemsForTree();
        buildTransferTreeItems();
        filterTree();
        treeItems.clear();
        calcTree(rootItem);
        resetSelectionBeforeSelectedColumn();
    }
    
    public void filterTreeAndCalc(){
    }
    
    public void selectAllMovementsInLevel(Integer level, Boolean isSelected){
        for(DPTreeItem item : treeItems){
            if(item.level == level && item.getMovement() != null) item.state.selected = isSelected;
        }
    }
    
    public void unselectAll(){
        for(DPTreeItem item : treeItems){
            if(item.getMovement() != null) item.state.selected = false;
        }
    }
    
    public void expandInLevel(Boolean isOpened, Integer level){
        for(DPTreeItem item : treeItems){
            if(item.level == level) item.state.opened = isOpened;
        }
    }
    
    private void resetSelectionBeforeSelectedColumn(){
        for(Integer i = 0; i < buffer.columnNumber; i++){
            selectAllMovementsInLevel(i, false);
        }            
    }
    
    
    //Create heararchy tree of movements in memory:
    private void scanTree(Movement__c movement, DPTreeItem treeItem){
        List<Movement__c> childMovements;
        if (movement == null){
            childMovements = buffer.getColumnMovements();
        } else{
            childMovements = buffer.getChildMovements(movement.Id);
        } 
        for(Movement__c childMovement : childMovements){
            DPTreeItem childItem = new DPTreeItem();
            childItem.setMovement(childMovement);
            treeItem.addChild(childItem);
            childItem.setParent(treeItem);
            scanTree(childMovement, childItem);
        }
        //Remember state of treeItem in memory (collapsed or opened):
        DPCState state = new DPCState();
        if (movement == null){
            //for root item:
            if (treeItemStates.get(filter.deliveryPlan.id) != null){
                treeItem.state = treeItemStates.get(filter.deliveryPlan.id);            
            } else{
                treeItem.state = state; 
                treeItemStates.put(filter.deliveryPlan.id, state);                          
            }
        } else{
            //for other items
            if (treeItemStates.get(movement.id) != null){
                treeItem.state = treeItemStates.get(movement.id);                           
            }else{
                treeItem.state = state; 
                treeItemStates.put(movement.id, state); 
            }
        }
        if (treeItem.getChilds().size() <=1) treeItem.state.opened = true;
        if (movement!=null && (movement.Type__c == DeliveryPlanFilter.LOSS_TYPE || movement.Type__c == DeliveryPlanFilter.DISPATCHED_TRANSFER_TYPE)){
            treeItem.state.opened = true;           
        }
    }
      
    //Calculate item parameters for whole tree:
    private void calcTree(DPTreeItem treeItem){
        treeItems.add(treeItem);
        Movement__c movement = treeItem.getMovement();
        List<DPTreeItem> childItems = treeItem.getChilds();
        List<Double> amtResultList = new List<Double>();
        List<Double> lossResultList = new List<Double>();
        List<Double> transferResultList = new List<Double>();
        List<Double> delivTransferResultList = new List<Double>();
        treeItem.setAmounts(new List<Double>());
        treeItem.setLosses(new List<Double>());
        treeItem.setTransfers(new List<Double>());
        treeItem.delivTransfers = new List<Double>();
        Double subTotal = 0;
        Double lossSubTotal = 0;
        Double transferSubTototal = 0;
        Double delivTransferSubTotal = 0;
        for(DPTreeItem childItem : childItems){
            childItem.level = treeItem.level + 1;
            calcTree(childItem);
            sumLists(amtResultList, childItem.getAmounts());
            sumLists(lossResultList, childItem.getLosses());
            sumLists(transferResultList, childItem.getTransfers());
            sumLists(delivTransferResultList, childItem.delivTransfers);
            Movement__c childMovement = childItem.getMovement();
            if (childMovement != null){
                if(childMovement.Type__c == DeliveryPlanFilter.LOSS_TYPE){
                    lossSubTotal = lossSubTotal + childMovement.Quantity__c;
                }else if(childMovement.Type__c == DeliveryPlanFilter.DISPATCHED_TRANSFER_TYPE){
                    transferSubTototal = transferSubTototal + childMovement.Quantity__c;
                }else if(childMovement.Type__c == DeliveryPlanFilter.DELIVERED_TRANSFER_TYPE){
                    delivTransferSubTotal = delivTransferSubTotal + childMovement.Quantity__c;
                }else{
                    subTotal = subTotal + childMovement.Quantity__c;
                }
            }
            treeItem.setRowSpan(treeItem.getRowSpan() + childItem.getRowSpan());
        }
        Double balance = 0;
        if (movement != null){
                balance = movement.Quantity__c - (subTotal + transferSubTototal + lossSubTotal);                
        }
        treeItem.setBalance(balance);
        if (treeItem.getRowSpan() == 0) treeItem.setRowSpan(1); 
        if (movement != null && childItems.size() == 0 && !(filter.route.isLast(movement.Location__r.Id) && movement.Type__c == DeliveryPlanFilter.DISPATCHED_TYPE)){
            // fill ziro if movement don't have childs and not dispatched in last location
            for (Integer i=1;i<=getIterationCount(treeItem); i++){
                treeItem.getAmounts().add(0);
                treeItem.getLosses().add(0);
                treeItem.getTransfers().add(0);
                treeItem.delivTransfers.add(0);
            }
        }else if (childItems.size() != 0) {
            // fill summary values of next locations
            treeItem.getAmounts().add(subTotal);
            treeItem.getLosses().add(lossSubTotal);
            treeItem.getTransfers().add(transferSubTototal);
            treeItem.delivTransfers.add(delivTransferSubTotal);
            for(Integer i = 0; i < amtResultList.size(); i++){
                treeItem.getAmounts().add(amtResultList[i]);            
                treeItem.getLosses().add(lossResultList[i]);            
                treeItem.getTransfers().add(transferResultList[i]);
                treeItem.delivTransfers.add(delivTransferResultList[i]);
            }               
        }
    }
      
    private void sumLists(List<Double> sourceList, List<Double> addList){
        if (sourceList.size() == 0){
            for (Double amt : addList){
                    sourceList.add(amt);                            
            }
            return;
        }
        //system.debug('Summ lists: ' + sourceList.size() + '/' + addList.size());
        //system.debug('source list: ' + sourceList);
        //system.debug('add list: ' + addList);
        for(Integer i=0; i<sourceList.size(); i++){
                sourceList[i] = sourceList[i] + addList[i];
        }
    }
    
    private Integer getIterationCount(DPTreeItem treeItem){
        Movement__c m = treeItem.getMovement();
        Integer colCount = filter.route.getColumnCount();
        Integer colNum = 0;
        If(m.Type__c == DeliveryPlanFilter.DELIVERED_TYPE || m.Type__c == DeliveryPlanFilter.DELIVERED_TRANSFER_TYPE){
            colNum = filter.route.getOddColumnNumber(m.Location__c);
        }else if(m.Type__c == DeliveryPlanFilter.DISPATCHED_TYPE || m.Type__c == DeliveryPlanFilter.DISPATCHED_TRANSFER_TYPE){
            colNum = filter.route.getEvenColumnNumber(m.Location__c);
        }else if(m.Type__c == DeliveryPlanFilter.LOSS_TYPE && treeItem.getParent() != null){
            if(treeItem.getParent().getMovement().Type__c == DeliveryPlanFilter.DELIVERED_TYPE || treeItem.getParent().getMovement().Type__c == DeliveryPlanFilter.DELIVERED_TRANSFER_TYPE){
               colNum = filter.route.getEvenColumnNumber(m.Location__c); 
            }else{
               colNum = filter.route.getOddColumnNumber(m.Location__c); 
            }
        }

        return colCount-colNum - 1;
    }
    
    private Boolean isCompletelyMoved(DPTreeItem treeItem, Movement__c movement){
        Boolean result;      
        if (movement == null){
            //empty item not change result
            result = true;
        } else{
            Boolean isMovementDispInLastLocation = filter.route.isLast(movement.Location__c) && movement.Type__c == DeliveryPlanFilter.DISPATCHED_TYPE;
            Boolean isLoss = movement.Type__c == DeliveryPlanFilter.LOSS_TYPE;
            Boolean isZiroBalance = movement.Balance__c == 0;
            if(isMovementDispInLastLocation || isLoss || isZiroBalance){
                result = true;
            } else {
                result = false;
            }
        }
        if(treeItem != null && movement == null){
            for(DPTreeItem childItem : treeItem.getChilds()){
                result = result && isCompletelyMoved(childItem, childItem.getMovement());               
            }
        }else if( movement != null){
            for(Movement__c m : buffer.getChildMovements(movement.Id)){
                result = result && isCompletelyMoved(null, m);               
            }
            
        }
        return result;
    }
    
    private void filterTree(){
        List<DPTreeItem> items = new List<DPTreeItem>();
        for(DPTreeItem childItem : rootItem.getChilds()){
            Boolean isCompletelyMoved = isCompletelyMoved(childItem, childItem.getMovement());
            Boolean isDeliveryTransfer = childItem.isTransfer;
            Boolean isMovement = !isCompletelyMoved && !isDeliveryTransfer;
            if((filter.completelyMovedCBox && isCompletelyMoved) || (filter.movementCBox && isMovement) || (filter.delivTransferCBox && isDeliveryTransfer)){
                items.add(childItem);
            }
        }
        rootItem.setChilds(items);        
    }
    
    //rebuild tree if sort column number > 0 (add items before sorted column)
    private void buildPrevItemsForTree(){
        //rebuild tree, add elements if sortColumn != 0
        if(buffer.columnNumber != 0){
            List<DPTreeItem> rootChilds = new List<DPTreeItem>();
            for(DPTreeItem dpti : rootItem.getChilds()){ 
                if (buffer.columnNumber == 0) break;
                DPTreeItem item = buildPrevTreeItems(dpti, buffer.columnNumber, false);
                item.setParent(rootItem);
                rootChilds.add(item);
            }  
            rootItem.setChilds(rootChilds);
        }       
    }
    
    private DPTreeItem buildPrevTreeItems(DPTreeItem treeItem, Integer colNum, boolean transfer){
        DPTreeItem prevItem = treeItem;
        DPTreeItem item = treeItem;
        for(integer i=0; i < colNum; i++){
            item = new DPTreeItem();
            if (prevItem.getMovement() != null) item.setMovement(buffer.getMovement(prevItem.getMovement().Previous_Movement__c));
            item.addChild(prevItem);
            prevItem.setParent(item);
            prevItem = item; 
            item.disable = true;
            item.isTransfer = transfer;
            if(treeItem.getMovement() != null && treeItem.getMovement().Type__c == DeliveryPlanFilter.DELIVERED_TRANSFER_TYPE){
                item.isTransfer = true;
            }
            //set state, this item must be allways be opened
            DPCState state = new DPCState();
            state.opened = true;
            item.state = state;
            item.value = '';
        }
        return item;
    }
    
    //build branches for transfered movements
    private void buildTransferTreeItems(){
        Movement__c[] tMovements = buffer.getTransferedMovements();   
        system.debug('TMOVEMENTS: ' + tMovements);
        for(Movement__c m : tMovements){
            DPTreeItem item = new DPTreeItem();
            item.setMovement(m);
            item.isTransfer = true;
            scanTree(m, item);
            Integer mColNumber = filter.route.getOddColumnNumber(m.Location__c);
            DPTreeItem rItem = buildPrevTreeItems(item, mColNumber, true);
            system.debug('RITEM: ' + rItem);
            rItem.setParent(rootItem);
            rootItem.getChilds().add(rItem);
        }
    }

}