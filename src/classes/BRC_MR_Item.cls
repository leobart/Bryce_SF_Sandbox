public class BRC_MR_Item implements Comparable {

    public list<BRC_MR_Item> childs {get; set;}
    public BRC_MR_Managment_Report_Item__c mrItem {get; set;}
    public BRC_MR_Management_Report_Item_Value__c value {get; set;}
    public boolean show {get; set;}
    public boolean saveAvailable {get; set;}
    public boolean editAvailable {get; set;}
    public boolean open {get; set;}
    public map<String, BRC_MR_Item> itemsMap;
        
    public BRC_MR_Item(map<String, BRC_MR_Item> itemsMap){
        this.itemsMap = itemsMap;
        childs = new list<BRC_MR_Item>();   
        show = false;
        open = true;
        saveAvailable = false;
        editAvailable = false;
    }
    
    public BRC_MR_Item cloneItem(){
        BRC_MR_Item item = new BRC_MR_Item(itemsMap);
        item.mrItem = this.mrItem;
        item.value = this.value;
        //item.open = this.open;
        return item;
    }
    
    public Integer compareTo(Object compareTo){
        BRC_MR_Item compareToItem = (BRC_MR_Item)compareTo;
        Integer returnValue = 0;
        if (this.mrItem.Sort_Order__c > compareToItem .mrItem.Sort_Order__c) {
            returnValue = 1;
        } else if (this.mrItem.Sort_Order__c < compareToItem .mrItem.Sort_Order__c) {
            returnValue = -1;
        }       
        return returnValue;       
    }
    
    public boolean getIsEmptyChilds(){
        return childs.size() == 0;
    }
    
    public BRC_MR_Item getSourceItem(){
        BRC_MR_Item i = itemsMap.get(mrItem.Id);
        if(i != null){
        	return i;            
        }
        return this;
        
    }
    
    public boolean getIsOpen(){
        BRC_MR_Item i = itemsMap.get(mrItem.Id);
        if(i != null){
        	return i.open;            
        }
        return false;
    }

}