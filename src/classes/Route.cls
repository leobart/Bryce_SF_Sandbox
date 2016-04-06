public with sharing class Route{
	
	private List<Location__c> locations;
	
	public Route(Id routeId){
        init(routeId);
	}
    
    public Route(String dpId){
        String routeId = [SELECT Route__c FROM Delivery_Plan__c WHERE Id=:dpId][0].Route__c;
        init(routeId);
    }
    
    private void init(String routeId){
		locations = new List<Location__c>();
		List<Locations_List__c> locationsList = [Select Location__r.Name, Location__r.Id From Locations_List__c where Route__r.id=:routeId order by Sequence_Number__c];
		for(Locations_List__c item : locationsList){
			locations.add(item.Location__r);						
		}		        
    }
	
	public Integer locationsCount(){
		return locations.size();
	}
	
	public List<Location__c> getLocations(){
		return locations;
	}
	
    public List<String> getLocationNamesWithoutFirst(){
        List<String> locationNames = new List<String>();
        Boolean isFirst = true;
        for(Location__c location : locations){
            if (isFirst){
                isFirst = false;
                continue;
            }
            locationNames.add(location.Name);
        }
        return locationNames;
    }
        
    public Location__c getFirstLocation(){
        return locations.get(0);
    }
    
    public Boolean isFirst(Id locationId){
    	Location__c location = getFirstLocation();
    	if(location != null){
    		return location.Id == locationId;
    	}
    	return false;
    }
    
    public Location__c getLastLocation(){
        return locations.get(locations.size()-1);
    }
    
    public Boolean isLast(Id locationId){
    	Location__c location = getLastLocation();
    	if(location != null){
    		return location.Id == locationId;
    	}
    	return false;
    }
    
    public Integer getLocationNumber(Id locationId){
        Integer num = 0;
        for(Location__c location: locations){
            num++;
            if(location.Id == locationId){
                    return num;
            }
        }
        return 0;
    }
    
    public Location__c getNextLocation(Id locationId){
    	Iterator<Location__c> locationsIterator = locations.iterator();
    	for(;locationsIterator.hasNext();){
    		if (locationsIterator.next().Id == locationId && locationsIterator.hasNext()) return locationsIterator.next();
    	}
    	return null;
    }
        
    public String getLocationIdByColumnNumber(Integer colNumber){
        if(colNumber == 0){
            return getFirstLocation().Id;
        }else{
            Integer i;
            if(colNumber/2*2 == colNumber) {
                i=colNumber/2;
            }else{
                i=(colNumber+1)/2;
            }
            return locations[i].Id;
        }
    }
    
    public Integer getLocationNum(Integer colNumber){
        if(colNumber/2*2 == colNumber){
            return colNumber/2;
        }else{
            return(colNumber+1)/2;
        }
    }
    
    public boolean isMovementInColumn(Movement__c movement, Integer columnNumber){
        String movementType = DeliveryPlanFilter.DISPATCHED_TYPE;
        if(columnNumber>0){
            if (columnNumber/2*2 == columnNumber){
                movementType = DeliveryPlanFilter.DISPATCHED_TYPE;
            }else{
                movementType = DeliveryPlanFilter.DELIVERED_TYPE;
            }
        }
        String locationId = getLocationIdByColumnNumber(columnNumber);
        return movement.Type__c == movementType && movement.Location__c == locationId;

    }
    
    public Integer getOddColumnNumber(String locationId){
        Integer locationNum = getLocationNumber(locationId);
        if (locationNum > 1){
            return (locationNum - 2) * 2 + 1;
        }
        return 0;
    } 
    
    public Integer getEvenColumnNumber(String locationId){
        Integer locationNum = getLocationNumber(locationId);
        if (locationNum > 1){
            return (locationNum - 2) * 2 + 2;
        }
        return 0;
    }
    
    public Integer getColumnCount(){
        return getLocations().size() * 2 -1;
    }
    
	
	

}