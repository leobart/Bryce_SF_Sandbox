public class BRC_MR_ItemsTreeController {
    
    public BRC_MR_ItemsTree tree {get; set;}
    public String itemId {get; set;}
    
    public void invertOpenItemAction(){
        BRC_MR_Item item =  tree.itemsMap.get(itemId);
        if(item != null){
            item.open = !item.open;
        }
    }
}