public with sharing virtual class BRC_MR_ManagementReportsCommon {

    public BRC_MR_ItemsTree tree {get; set;}
    public BRC_MR_Management_Report_Item_Value__c dayOfWeek {get; set;}
    public boolean editMode {get; set;}
    public boolean viewAllMode {get; set;}
    public boolean reportMode {get; set;}
        
    private map<String, BRC_MR_ItemsTree> treeForDateMap;
    
    public BRC_MR_ManagementReportsCommon(){
        editMode = false;
        viewAllMode = false;
        reportMode = false;
        dayOfWeek = new BRC_MR_Management_Report_Item_Value__c();
        dayOfWeek.Date__c = Date.today().toStartofWeek();
        treeForDateMap = new map<String, BRC_MR_ItemsTree>();
        tree = new BRC_MR_ItemsTree();
        tree.init(this);
    }
    
    public boolean getIsSuperUser(){
		Map<String, BRC_MR_Super_Users_Settings__c> superUserSettings = BRC_MR_Super_Users_Settings__c.getAll();
		for(String key : superUserSettings.keyset()){
            BRC_MR_Super_Users_Settings__c sUserSetting = superUserSettings.get(key);
            if(sUserSetting.Edit_All_User_Id__c == UserInfo.getUserId()) return true;
        } 
        return false;
 	}
    
    protected void initParametersTree(){
        getTree();        
    }
    private void getTree(){
        BRC_MR_ItemsTree t = treeForDateMap.get(dayOfWeek.Date__c.format());
        if (t != null) {
            tree = t;
            showErrors();
            return;
        }
        buildTree();
    }
    
    private void buildTree(){
        // буфферизация приводит к переполнению, поэтому ее не используем
        /*BRC_MR_ItemsTree t = tree.clone();
        t.buildTree(dayOfWeek.Date__c);
        treeForDateMap.put(dayOfWeek.Date__c.format(), t);
        tree = t;*/
        tree.buildTree(dayOfWeek.Date__c);
        showErrors();
    }
    
    private void showErrors(){
        for(String errorMessage : tree.errorMessages){
           ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, errorMessage));
        }
    }
        
    public String getDayOfWeekFormated(){
        return dayOfWeek.Date__c.format();
    }
    
    public void prevWeekAction(){
        dayOfWeek.Date__c = dayOfWeek.Date__c.toStartofWeek();
        dayOfWeek.Date__c = dayOfWeek.Date__c.addDays(-7);
        getTree();
        editMode = false;
    }
    
    public void nextWeekAction(){
        dayOfWeek.Date__c = dayOfWeek.Date__c.toStartofWeek();
        dayOfWeek.Date__c = dayOfWeek.Date__c.addDays(7);        
        getTree();
        editMode = false;
    }
    
    public void dateChangeAction(){
        dayOfWeek.Date__c = dayOfWeek.Date__c.toStartofWeek();
        getTree();
        editMode = false;
   }
    
    public void saveAction(){
        list<BRC_MR_Management_Report_Item_Value__c> updateList = new list<BRC_MR_Management_Report_Item_Value__c>();
        list<BRC_MR_Management_Report_Item_Value__c> createList = new list<BRC_MR_Management_Report_Item_Value__c>(); 
        
        for(String id : tree.itemsMapForDate.keySet()){
            BRC_MR_Item i = tree.itemsMapForDate.get(id);
            if(i.value == null) continue;
            if(i.value.Id == null && i.value.Value__c !=null && !i.value.Auto__c && i.value.Active__c){
            	createList.add(i.value);    
            } else if (i.value.Id != null && i.value.Value__c !=null && !i.value.Auto__c && i.value.Active__c){
                updateList.add(i.value);
            }
        }
        System.Savepoint savePoint = Database.setSavepoint();
        try{
            insert createList;
            if (editMode) {
                update updateList;
            }
        }catch (Exception e){
		    Database.rollback(savePoint);
		    ApexPages.addMessages(e);            
        }
		buildTree();
        editMode = false;
    }
    
    public void editAction(){
        editMode = true;
    }
    
    public void cancelAction(){
        editMode = false;
    }
    
    public void viewAllAction(){
        buildTree();
    }
    
}