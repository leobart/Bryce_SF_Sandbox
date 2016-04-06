public with sharing class BRC_MR_ItemsTree {
    
	public BRC_MR_Item allParamsRootItem {get; set;}
	public BRC_MR_Item mondayDateRootItem {get; set;}
    public BRC_MR_MRItems mrItems;
    public map<String, BRC_MR_Item> itemsMap; 
    public map<String, BRC_MR_Item> itemsMapForDate; 
    public map<String, BRC_MR_Item> itemsFromFinalTree; 
    private list<BRC_MR_Management_Report_Item_Value__c> values;
    public Date nextMondayDate; 
    public Date currMondayDate; 
    public BRC_MR_SummaryTable summaryTable {get; set;}
    public BRC_CR_RateConverter rateConverter {get; set;}
    public set<String> errorMessages;
    private BRC_MR_ManagementReportsCommon controller;
    
    
    public void init(BRC_MR_ManagementReportsCommon controller){
        this.controller = controller;
        currMondayDate = Date.today().toStartofWeek();
        nextMondayDate = currMondayDate.addDays(7);
        mrItems = new BRC_MR_MRItems();
        itemsMap = new map<String, BRC_MR_Item>();
        allParamsRootItem = new BRC_MR_Item(itemsMap);
        allParamsRootItem.mrItem = mrItems.getRoot();
        itemsMap.put(allParamsRootItem.mrItem.id, allParamsRootItem);
        scanTree(allParamsRootItem);                
    }
    
    public BRC_MR_ItemsTree cloneTree(){
        BRC_MR_ItemsTree cTree = new BRC_MR_ItemsTree();

        cTree.allParamsRootItem = allParamsRootItem;
        cTree.mrItems = mrItems;
        cTree.itemsMap = itemsMap;
        cTree.currMondayDate = currMondayDate;
        cTree.nextMondayDate = nextMondayDate;
        cTree.controller = controller;
        return cTree;
    }
       
    private void scanTree(BRC_MR_Item memoryItem){
        for(BRC_MR_Managment_Report_Item__c mri : mrItems.getChidrenItems(memoryItem.mrItem.Id)){
                BRC_MR_Item childMItem = new BRC_MR_Item(itemsMap);
                childMItem.mrItem = mri;
                memoryItem.childs.add(childMItem); 
                scanTree(childMItem);   
                itemsMap.put(childMItem.mrItem.Id, childMItem);
        }
        memoryItem.childs.sort();
    }
    
    private void findValues(Date mondayDate){
        Date prevMondayDate = mondayDate.addDays(-7);
        Date[] dates = new Date[] {prevMondayDate, mondayDate};
        values = [SELECT Id, Value__c, Managment_Report_Item__c, Auto__c, Active__c, Date__c, currencyISOCode 
										                  FROM BRC_MR_Management_Report_Item_Value__c 
										                  WHERE Managment_Report_Item__c IN: itemsMap.keySet() 
										                  AND Date__c IN: dates ];
        for(String itemId : itemsMap.keySet()){
            BRC_MR_Item item = itemsMap.get(itemId);
            BRC_MR_Management_Report_Item_Value__c value = getValue(itemId, mondayDate);
            if(!item.mrItem.Group__c && value == null && isItemAvailableForThisMonday(mondayDate, item.mrItem) && !controller.reportMode && !item.mrItem.Auto__c && !item.mrItem.Dependent__c){
                value = new BRC_MR_Management_Report_Item_Value__c();
                value.Date__c = mondayDate;
                value.Managment_Report_Item__c = item.mrItem.Id;
                value.Reversed_Item__c = item.mrItem.Reversed_Item__c;
                if(item.mrItem.Long__c){
                    BRC_MR_Management_Report_Item_Value__c prevValue = getValue(itemId, prevMondayDate);
                    if (prevValue != null) value.Value__c = prevValue.Value__c;
                }
                //value.Value__c = 0;
                value.Active__c = item.mrItem.Active__c;
                value.Auto__c = item.mrItem.Auto__c;
                value.currencyISOCode = item.mrItem.currencyISOCode;
            }
            item.value = value;
        }
    }
    
    public void buildTree(Date mondayDate){
        errorMessages = new set<String>();
        // Поиск значений параметров на текущую дату
        findValues(mondayDate);
        mondayDateRootItem = allParamsRootItem.cloneItem();
        // Создание дерева действительных на данную дату параметров
        itemsMapForDate = new map<String, BRC_MR_Item>();
        itemsFromFinalTree = new map<String, BRC_MR_Item>();
        rateConverter = new BRC_CR_RateConverter(mondayDate);
		buildTreeForMondayDate(mondayDateRootItem, allParamsRootItem, mondayDate); 
        summaryTable = new  BRC_MR_SummaryTable(this);        
    }  
    
    private void buildTreeForMondayDate(BRC_MR_Item memoryItem, BRC_MR_Item sourceItem, Date mondayDate){
        Decimal sum = 0;
        for(BRC_MR_Item i : sourceItem.childs){
            BRC_MR_Item j = i.cloneItem();
            buildTreeForMondayDate(j, i, mondayDate);
            if((!j.mrItem.Group__c && isItemVisibleForUser(j.mrItem.Owner__r.User__c) && j.value!= null && j.value.Active__c && isItemAvailableForThisMonday(mondayDate, j.mrItem)) ||
               (!j.mrItem.Group__c && j.value== null && isItemAvailableForThisMonday(mondayDate, j.mrItem) && isItemVisibleForUser(j.mrItem.Owner__r.User__c)) ||
                (j.mrItem.Group__c && j.show )){
                    memoryItem.childs.add(j);
                    memoryItem.show = true;
                    itemsFromFinalTree.put(j.mrItem.Id, j);
                    if(j.value != null && j.value.Value__c != null){
                    	Decimal value = rateConverter.convertValue(j.mrItem.CurrencyIsoCode, memoryItem.mrItem.CurrencyIsoCode, j.value.Value__c);
                        if (value != null){
                            sum = sum + value;
                        }else{
                            errorMessages.add('Нет одного из значений для конвертации валюты из ' + j.mrItem.CurrencyIsoCode + ' в ' + memoryItem.mrItem.CurrencyIsoCode);
                        }                          
                    }
                     
                    if (!j.mrItem.Group__c){
                        j.saveAvailable = (j.value != null && j.value.Id == null);
                        j.editAvailable = (j.value != null && j.value.Id != null);
                    }
                    if(j.saveAvailable) memoryItem.saveAvailable = true;
                    if(j.editAvailable) memoryItem.editAvailable = true;
                    if (!j.mrItem.Group__c) itemsMapForDate.put(j.mrItem.Id, j);
               }
        }
        if(memoryItem.mrItem.Group__c){
        	memoryItem.value = new BRC_MR_Management_Report_Item_Value__c();
        	memoryItem.value.Value__c = sum; 
            memoryItem.value.CurrencyIsoCode = memoryItem.mrItem.CurrencyIsoCode;
        }
    }
    
    private boolean isItemVisibleForUser(String userId){
        return controller.reportMode || controller.viewAllMode || (userId == UserInfo.getUserId());
    }
    
    private boolean isItemAvailableForThisMonday(Date mondayDate, BRC_MR_Managment_Report_Item__c item){
		return mondayDate >= convertDate(item.CreatedDate) && mondayDate <= nextMondayDate;       
    }
       
    private Date convertDate(DateTime dt){
        Date d = dt.date().toStartofWeek();
        return Date.newinstance(d.year(), d.month(), d.day());
    }
    
    private BRC_MR_Management_Report_Item_Value__c getValue(String itemId, Date d){
        for(BRC_MR_Management_Report_Item_Value__c v : values){
            if (v.Managment_Report_Item__c == itemId && d == v.Date__c) return v;
        }
        return null;
    } 
    
    public Decimal getValueForReferenceId(String refId){
        Decimal retValue = 0;
        boolean flag = false;
        for(BRC_MR_Managment_Report_Item__c i : mrItems.getItemsByReferenceId(refId)){
            BRC_MR_Item memoryItem = itemsFromFinalTree.get(i.Id);
            if(memoryItem != null && memoryItem.value != null && memoryItem.value.Value__c != null){
                flag = true;
                retValue = retValue + memoryItem.value.Value__c;
            }
        }
        if(flag) return retValue;
        return null;
    }
    
    
    


}