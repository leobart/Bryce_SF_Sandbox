//This class used in MovementsTrigger, created for decrease DML queries
public class MovementsHelper{
    
    private List<Movement__c> movements;
    private List<Movement__c> oldMovements;
    private List<Movement__c> parentMovements;
    private List<String> movementIDs;
    private List<String> parentMovementIDs;
    private List<AggregateResult> totalMovedFromParents;
    private List<AggregateResult> totalMovedFromMovements;
    private Map<string, Movement__c> movementsForUpdate;
    private List<AggregateResult> childrenMinDates;
    
    private List<Movement__c> childrenMovements;
    
    public MovementsHelper(List<Movement__c> movements){
        this.movements = movements;
        oldMovements = null;
        movementIDs = new List<String>();
        parentMovementIDs = new List<String>();
        movementsForUpdate = new Map<string, Movement__c>();
        for(Movement__c m : movements){
            movementIDs.add(m.Id);
            parentMovementIDs.add(m.Previous_Movement__c);
        }
    }
    
    public MovementsHelper(List<Movement__c> movements, List<Movement__c> oldMovements){
        this(movements);
        this.oldMovements = oldMovements;
    }
    
    private void initParentMovements(){
        if(parentMovements == null)
         parentMovements = [SELECT Id, Moved__c, Quantity__c, Date__c FROM Movement__c WHERE Id IN :parentMovementIDs];       
    }
    
    private void initChildrenMovements(){
        if(childrenMovements == null)
        	childrenMovements = [SELECT Id FROM Movement__c WHERE Previous_Movement__c IN :movementIDs];	
    }
    
    private void initTotalMovedFromParents(){
        if(totalMovedFromParents == null)
        totalMovedFromParents = [SELECT Previous_Movement__c mId, SUM(Quantity__c) totalMoved 
                                FROM Movement__c 
                                WHERE Previous_Movement__c  IN :parentMovementIDs 
                                GROUP BY Previous_Movement__c];        
    }
    
    private void initTotalMovedFromMovements(){
        if(totalMovedFromMovements == null)
        	totalMovedFromMovements = [SELECT Previous_Movement__c mId, SUM(Quantity__c) totalMoved 
                                FROM Movement__c 
                                WHERE Previous_Movement__c  IN :movementIDs 
                                GROUP BY Previous_Movement__c];        
    }
        
    private void initChildrenMinDates(){
        if(childrenMinDates == null)
        	childrenMinDates = [SELECT Previous_Movement__c mId, MIN(Date__c) minDate 
                                FROM Movement__c 
                                WHERE Previous_Movement__c  IN :movementIDs 
                                GROUP BY Previous_Movement__c];        
    }
        
    //----------------------------------------------------------------------
    
    private Movement__c getParentMovement(Movement__c movement){
        for(Movement__c pm : parentMovements){
            if(pm.id == movement.Previous_Movement__c) return pm;
        }
        return null;
    }
    
    private Decimal getMovedFromParentM(String parentId){
        for(AggregateResult ar : totalMovedFromParents){
            Decimal moved = (Decimal)ar.get('totalMoved');
            String mId = (String)ar.get('mId');
            if(mId == parentId) return moved;
        }
        return 0;
    }
    
    private Decimal getMovedFromMovement(String movementId){
        for(AggregateResult ar : totalMovedFromMovements){
            Decimal moved = (Decimal)ar.get('totalMoved');
            String mId = (String)ar.get('mId');
            if(mId == movementId) return moved;
        }
        return 0;
    }
    
    private Date getChildrenMinDate(String movementId){
        for(AggregateResult ar : childrenMinDates){
            date minDate = (Date)ar.get('minDate');
            String mId = (String)ar.get('mId');
            if(mId == movementId) return minDate;
        }
        return null;
    }
    
    //------------------------------------------------------------------------------------------------    
    //Update field Movement__r.Moved__c in dependecy Movements
    public void updateMovedValues(){
        initParentMovements();
        initTotalMovedFromParents();
        for(Movement__c m : movements){
            Movement__c parentM = getParentMovement(m);
            if(parentM != null){
                Decimal totalMoved = getMovedFromParentM(parentM.Id);
                if(parentM.Moved__c != totalMoved){
                    parentM.Moved__c = totalMoved;
                    movementsForUpdate.put(parentM.Id, parentM);
                }
            }
        } 
        update movementsForUpdate.values();
    }
    
    //------------------------------------------------------------------------------------------------    
    //Check Quantity field before inserting or updating
    public void checkQuantityValues(){
        initParentMovements();
        initTotalMovedFromParents();
        initTotalMovedFromMovements();
        for(Integer i = 0; i < movements.size(); i++){
            Movement__c movement = movements[i];
            //Quantity can not be <=0:
            if (movement.Quantity__c <= 0) movement.Quantity__c.addError('Quantity can not be <= 0');
            Movement__c parentM = getParentMovement(movement);
            if (parentM != null){
                // if updated movement has parent then check summ of childs for this parent with new movement value, this summ can not be > than parent quantity
                Decimal amount = getMovedFromParentM(parentM.Id);
                //For inserting oldQuantity = 0
                Decimal oldQuantity = 0;
                if(oldMovements!=null){
                    oldQuantity = oldMovements[i].Quantity__c;
                } 
                Decimal maxVal =parentM.Quantity__c - (amount - oldQuantity);
                if(maxVal <= 0 ) {
                    movement.Quantity__c.addError('Can not create new movement, available quantity = 0, may be movement already created from another place');
                } else if(movement.Quantity__c > maxVal) movement.Quantity__c.addError('Quantity can not be greater then: ' + maxVal);            
            } 
            if(oldMovements!=null){
                // check summ for childs, movement quantity can not be less then summ of child quantities
                Decimal minVal = getMovedFromMovement(movement.Id);              
                if(movement.Quantity__c < minVal) movement.Quantity__c.addError('Quantity can not be less than: ' + minVal);
            }          
        }
    }
    
    //------------------------------------------------------------------------------------------------    
    public void checkDateValues(){
        initParentMovements();
		initChildrenMinDates();
        for(Movement__c movement : movements){
        	Movement__c parentM = getParentMovement(movement);
            if(parentM != null && movement.Date__c < parentM.Date__c) movement.Date__c.addError('Date can not be earlier than ' + parentM.Date__c.format());
            if(oldMovements!=null){
               //check this only if movments updated, inserted movements dont have children!
               Date childrenMinDate = getChildrenMinDate(movement.Id);
            	if(childrenMinDate!= null && movement.Date__c > childrenMinDate ) movement.Date__c.addError('Date can not be later then ' + childrenMinDate.format() ); 
            }
        }
    }
    
    //------------------------------------------------------------------------------------------------    
    //Delete dependecy Movements
    public void deleteChildren(){
		initChildrenMovements();	       
        try{
        	delete childrenMovements;             
        }catch(Exception e){
            //do nothimg
        }
    }
        
}