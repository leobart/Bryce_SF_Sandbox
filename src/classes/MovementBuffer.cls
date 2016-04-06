//Class for decrease SOQL 
public class MovementBuffer{
 
    
    public class MovementWrapper implements Comparable{
        public Movement__c movement;
        public Boolean ascending;
        
        public MovementWrapper(Movement__c movement, Boolean ascending){
            this.movement = movement;
            this.ascending = ascending;
        }
        
        public Integer compareTo(Object compareTo) {
            Integer retValue = 0;
            MovementWrapper mw = (MovementWrapper)compareTo;
            if(this.movement.Date__c < mw.movement.Date__c){
               retValue = 1; 
            }else if(this.movement.Date__c > mw.movement.Date__c){
                retValue = -1;
            }else if(this.movement.Quantity__c < mw.movement.Quantity__c){
                retValue = 1;
            }else if(this.movement.Quantity__c > mw.movement.Quantity__c){
                retValue = -1;
            }
            if(!ascending) retValue = retValue*(-1);
            return retValue;
        }
    }
       
    private DeliveryPlanFilter filter;
    public Set<Movement__c> movements {get; set;}
    public boolean sortAscending {get; set;}
    public Integer columnNumber {get; set;}
    private Integer recursionLevel;
    
    public MovementBuffer(){
    	sortAscending = true;
        columnNumber = 0;
    }
    
    public void updateBuffer(){
        system.debug('UPDATE MOVEMENT BUFFER!');
        movements = filter.getMovements();
        recursionLevel=0;
        checkDataIntegrity();
    }
        
    private void checkDataIntegrity(){
        recursionLevel++;
        List<String> parentMovementsIds = new List<String>();
        List<String> movementsForParentIds = new List<String>();
        for(Movement__c m : movements){
            if(m.Previous_Movement__c !=null){
                Movement__c parentM = getMovement(m.Previous_Movement__c);
                if(parentM == null) parentMovementsIds.add(m.Previous_Movement__c);                
            }
            Double sum = 0; 
            Double moved = 0;
            if (m.Moved__c !=null) moved = m.Moved__c;
        	List<Movement__c> cMovements = getChildMovementsNoSort(m.Id);
            for(Movement__c childM : cMovements){
                sum = sum + childM.Quantity__c;
            }
            system.debug('Childs SUM: ' + sum + '   Parent Moved:' + m.Moved__c + '   Parent ID: ' + m.Id);
            if (moved != sum) movementsForParentIds.add(m.Id);
        }
        
        /*system.debug('PARENT_IDS: ' + parentMovementsIds.size());
        for(String s : parentMovementsIds) system.debug('--- ' + s);
        
        system.debug('CHILD_IDS: ' + movementsForParentIds.size());
        for(String s : movementsForParentIds) system.debug('--- ' + s);*/
        
        movements.addAll(filter.getMovements(parentMovementsIds));
        movements.addAll(filter.getMovementsForParent(movementsForParentIds));
        
        if (parentMovementsIds.size() == 0 && movementsForParentIds.size() == 0 || recursionLevel >= filter.route.getColumnCount()) return;
        checkDataIntegrity();
    }
    
    public void setFilter(DeliveryPlanFilter filter){
        this.filter = filter;      
    	sortAscending = true;
        columnNumber = 0;
		//updateBuffer();
    }
    
    public List<Movement__c> getChildMovements(String movementId){
        List<MovementWrapper> mwList = new List<MovementWrapper>();
        List<Movement__c> children = new List<Movement__c>();
        for(Movement__c m:movements){
            if( m.Previous_Movement__c == movementId) mwList.add(new MovementWrapper(m, sortAscending));
        }
        mwList.sort();
        for (MovementWrapper mw : mwList) children.add(mw.movement);
        return children;
    }
    
    public List<Movement__c> getChildMovementsNoSort(String movementId){
        List<Movement__c> children = new List<Movement__c>();
        for(Movement__c mov : movements){
            if( mov.Previous_Movement__c == movementId) children.add(mov);
        }
        return children;      
    }
    
    public Movement__c getMovement(String movementId){
        for(Movement__c mov : movements){
            if( mov.Id == movementId) return mov;
        }
    	return null;
    }
    
    public List<Movement__c> getTransferedMovements(){
        List<Movement__c> retMovements = new List<Movement__c>();
        for(Movement__c m : movements){
            if(m.Type__c == DeliveryPlanFilter.DELIVERED_TRANSFER_TYPE){
                if (filter.route.getOddColumnNumber(m.Location__c) > columnNumber) retMovements.add(m);              
            }
        }
        return retMovements;
    }
    
    
    
    public List<Movement__c> getColumnMovements(){
        Set<String> movementTypes = new Set<String>();
        Set<String> lossParentTypes = new Set<String>() ;
        if(columnNumber>0){
            if (columnNumber/2*2 == columnNumber){
                movementTypes.add(DeliveryPlanFilter.DISPATCHED_TYPE);
                movementTypes.add(DeliveryPlanFilter.DISPATCHED_TRANSFER_TYPE);
                lossParentTypes.add(DeliveryPlanFilter.DELIVERED_TYPE);
                lossParentTypes.add(DeliveryPlanFilter.DELIVERED_TRANSFER_TYPE);
            }else{
                movementTypes.add(DeliveryPlanFilter.DELIVERED_TYPE);
                movementTypes.add(DeliveryPlanFilter.DELIVERED_TRANSFER_TYPE);
                lossParentTypes.add(DeliveryPlanFilter.DISPATCHED_TYPE);
            }
        }else{
            movementTypes.add(DeliveryPlanFilter.DISPATCHED_TYPE);
        }
        String locationId = filter.route.getLocationIdByColumnNumber(columnNumber);
        List<Movement__c> columnMovements = new List<Movement__c>();
        List<MovementWrapper> mwList = new List<MovementWrapper>();
        for(Movement__c m:movements){
            if( m.Location__c == locationId && movementTypes.contains(m.Type__c)) mwList.add(new MovementWrapper(m, sortAscending));
        	//prepare loss movements
            if( m.Location__c == locationId && m.Type__c == DeliveryPlanFilter.LOSS_TYPE){
                if(m.Previous_Movement__c != null && lossParentTypes.contains(getMovement(m.Previous_Movement__c).Type__c)){
                    mwList.add(new MovementWrapper(m, sortAscending));
                }
            } 
            //if(m.Location__c == locationId && m.Type__c == DeliveryPlanFilter.DELIVERED_TRANSFER_TYPE && filter.delivTransferCBox && filter.route.getOddColumnNumber(m.Location__c ) == columnNumber){
            //     mwList.add(new MovementWrapper(m, sortAscending));
            //}
        }
        mwList.sort();
        for (MovementWrapper mw : mwList) columnMovements.add(mw.movement);
        return columnMovements;
    }

}