public class BRC_DR_DocumentRequestController {
    
    public class DR_LineWrapper implements Comparable{
        public BRC_DR_Line_Item__c drLine {get; set;}
        public List<SelectOption> pickValuesSO {get; set;}
        
        public DR_LineWrapper(BRC_DR_Line_Item__c drLine, String pickListValues){
            pickValuesSO = new List<SelectOption>();
            this.drLine = drLine;
            if(pickListValues == null) return;
            list<String> pickItems = pickListValues.split('\n');
            for(String pickValue : pickItems){
                String val = pickValue.trim();
                pickValuesSO.add(new SelectOption(val, val));
            }
        }
        
        public Integer compareTo(Object compareTo){
            DR_LineWrapper compareToItem = (DR_LineWrapper)compareTo;
            Integer returnValue = 0;
            if (this.drLine.Line_Number__c > compareToItem.drLine.Line_Number__c) {
                returnValue = 1;
            } else if (this.drLine.Line_Number__c < compareToItem.drLine.Line_Number__c) {
                returnValue = -1;
            }       
            return returnValue;       
        }
        
    }
    
    private ApexPages.StandardController controller;
    public BRC_DR_Document_Request__c dr {get; set;}
    public List<DR_LineWrapper> wLines {get; set;}
    public String selectedPatternId {get; set;}
    public List<SelectOption> patternsSO {get; set;}

    public BRC_DR_DocumentRequestController(ApexPages.StandardController controller){
        this.controller = controller;
        patternsSO = new List<SelectOption>();
        List<BRC_DR_Pattern__c> patternsList = [SELECT Id, Name FROM BRC_DR_Pattern__c];
        for(BRC_DR_Pattern__c pattern : patternsList){
        	patternsSO.add(new SelectOption(pattern.Id, pattern.Name));           
        }
        dr = (BRC_DR_Document_Request__c)controller.getRecord();
        if(patternsList.size() > 0) dr.Document_Request_Pattern__c = patternsList[0].Id;
        if(dr.Id != null){
            wLines = new List<DR_LineWrapper>();
            dr = [SELECT Name, Id, Document_Request_Pattern__c, CreatedById, Status__c, Department__c, Due_Date__c, Approved__c, Complete_Date__c, Package__c 
                  FROM BRC_DR_Document_Request__c WHERE Id=:dr.Id];
            list<BRC_DR_Line_Item__c> lines = [SELECT Id, Name, CurrencyIsoCode, 
                                               		  Line_Number__c, Type__c, Pattern_Line__r.Pick_List_Values__c, 
                                               		  Required__c, Text__c, Text_Area__c, Text_Area_Long__c, Date__c, Number__c, Price__c  
                                               FROM BRC_DR_Line_Item__c 
                                               WHERE Document_Request__c=: dr.Id];
            for(BRC_DR_Line_Item__c line:lines){
                wLines.add(new DR_LineWrapper(line, line.Pattern_Line__r.Pick_List_Values__c));
            }
        }else{
            dr.Status__c = 'Init';
            dr.Department__c = 'Geneva';
            prepareRquestLines();
        }
        
    }
    
    public void prepareRquestLines(){
        wLines = new List<DR_LineWrapper>();
        list<BRC_DRP_Line_Item__c> pLines = [SELECT Id, Name, CurrencyIsoCode, Line_Number__c, Type__c, Pick_List_Values__c, Required__c
                                             FROM BRC_DRP_Line_Item__c 
                                             WHERE Document_Request_Pattern__c=: dr.Document_Request_Pattern__c];
        for(BRC_DRP_Line_Item__c pLine : pLines){
            BRC_DR_Line_Item__c line = new BRC_DR_Line_Item__c(CurrencyIsoCode = pLine.CurrencyIsoCode,
                                                               Name = pLine.Name,
                                                               Line_Number__c = pLine.Line_Number__c,
                                                               Pattern_Line__c = pLine.id, 
                                                               Type__c = pLine.Type__c, 
                                                               Required__c = pLine.Required__c);
            wLines.add(new DR_LineWrapper(line, pLine.Pick_List_Values__c));
        }
        wLines.sort();
    }
    
    public PageReference cancelAction(){
        return controller.cancel();
    }
    
    public PageReference saveAction(){
        list<BRC_DR_Line_Item__c> lines = new list<BRC_DR_Line_Item__c>();
        System.Savepoint rollbackPoint = Database.setSavepoint();
        try{
            insert dr;
            for(DR_LineWrapper wline : wLines){
                wLine.drLine.Document_Request__c = dr.Id;
                lines.add(wLine.drLine);
            }
            insert lines;
            String saveNew = system.currentPageReference().getParameters().get('save_new'); 
            String url = system.currentPageReference().getParameters().get('retURL');
            if (saveNew != null || url == null) url = '/'+dr.Id;
            return new PageReference(url);
        }catch(Exception e){
            Database.rollback(rollbackPoint);		             	
            ApexPages.addMessages(e); 
        }
        return null;
    } 
    
    public PageReference updateAction(){
        list<BRC_DR_Line_Item__c> lines = new list<BRC_DR_Line_Item__c>();
        System.Savepoint rollbackPoint = Database.setSavepoint();
        try{
            update dr;
            for(DR_LineWrapper wline : wLines){
                lines.add(wLine.drLine);
            }
            update lines;
            return new PageReference('/'+dr.Id);
        }catch(Exception e){
            ApexPages.addMessages(e);           	
            Database.rollback(rollbackPoint);		    
        }
        return null;
    } 
    
    public PageReference discardAction(){
        dr.Status__c='Discarded';
        update dr;
        return null;
    }
    
}