public class DDVolumeDistributionController{
    
    public Delivery_Document__C document {get; set;}
    public DPVolumeDistribution dpvd {get; set;}
    public List<SelectOption> documentSL {get; set;}
    public integer delRowId {get; set;}
    public Integer selectedRowId {get; set;}
    public Boolean changed {get; set;}
    
    public DDVolumeDistributionController(){
        String ddId = ApexPages.currentPage().getParameters().get('ddId');
        document = [SELECT Id, Type__c,Name, Planned_volume__c, Planned_Month__c, Delivery_Plan__r.Id, Contract__r.Account.Name, Contract__r.Name, Addendum__r.Name 
                    FROM Delivery_Document__c WHERE Id=:ddId];
        updateDistributionsList();
    }     
    
    public DDVolumeDistributionController(ApexPages.StandardController controller){
        document = (Delivery_Document__c)controller.getRecord();
        document = [SELECT Id, Type__c, Name, Planned_volume__c, Planned_Month__c, Delivery_Plan__r.Id, Contract__r.Account.Name, Contract__r.Name, Addendum__r.Name 
                    FROM Delivery_Document__c WHERE Id=:document.Id];
        updateDistributionsList();
    }     
    
    public void updateDistributionsList(){        
        dpvd = new DPVolumeDistribution();
        dpvd.distributionDoc = document;
        String docId = document.id;
        String dbSelect;
        List<Volume_Distribution__c> vds;
        List<String> distributedDocIDs = new List<String>();
        if(document.Type__c == 'Sell'){
            vds = [SELECT Id, Buy_Document__r.Id, Buy_Document__r.Name , Sell_Document__r.Id, Sell_Document__r.Name, Volume__c 
                   FROM Volume_Distribution__c 
                   WHERE Sell_Document__r.Id=:docId];
            for(Volume_Distribution__c vd : vds){
                distributedDocIDs.add(vd.Buy_Document__r.Id);
                dpvd.addRow(new DPVolumeDistribution.DistributionRow('Sell', vd));
            }            
            updateDocSL([SELECT Id, Name FROM Delivery_Document__c 
                         WHERE Type__c='Buy' 
                         	AND Delivery_Plan__r.Id=:document.Delivery_Plan__r.Id AND Id NOT IN:distributedDocIDs]);        	
        }else{
            vds = [SELECT Id, Buy_Document__r.Id, Buy_Document__r.Name , Sell_Document__r.Id, Sell_Document__r.Name, Volume__c 
                   FROM Volume_Distribution__c 
                   WHERE Buy_Document__r.Id=:docId];
            for(Volume_Distribution__c vd : vds){
                distributedDocIDs.add(vd.Sell_Document__r.Id);
                dpvd.addRow(new DPVolumeDistribution.DistributionRow('Buy', vd));
            }            
            updateDocSL([SELECT Id, Name FROM Delivery_Document__c 
                         WHERE Type__c='Sell' 
                         	AND Delivery_Plan__r.Id=:document.Delivery_Plan__r.Id AND Id NOT IN:distributedDocIDs]);
        }		         
        if(documentSL.size() == 0){
            if(vds.size() == 0) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Can not make distribution for this document. Can not find opposite documents'));
            dpvd.allDocInUse = true;
        }else{
            dpvd.allDocInUse = false;
        }
        changed = false;
        if(document.Planned_volume__c <= dpvd.getSummary()) dpvd.allDocInUse = true;
    }
    
    
    private void updateDocSL(List<Delivery_Document__c> ddl){
        documentSL = new List<SelectOption>();
        for(Delivery_Document__c d : ddl){
        	documentSL.add(new SelectOption(d.Id, DPVolumeDistribution.getDDFullName(d.Id)));
        }
    }
    
    private List<SelectOption> getUnusedDocumentSL(){
        List<String> usedDocs = new List<String>();
        for(DPVolumeDistribution.DistributionRow r : dpvd.dRows){
            if (r.status == 'new') usedDocs.add(r.getDocumentId());
        }
        List<SelectOption> unusedDocsSOList = new List<SelectOption>();
        for(SelectOption so : documentSL){
            Boolean unused = true;
            for(String id : usedDocs){
                if(so.getValue() == id){
                    unused = false;
                    break;
                }
            }
            if (unused) unusedDocsSOList.add(so);
        } 
        if (unusedDocsSOList.size()<=1) dpvd.allDocInUse = true;
        return unusedDocsSOList;
    } 
    
    public void addDistributionRow(){
        changed = true;
        //Fix distribution document for pre added rows
        for(DPVolumeDistribution.DistributionRow r : dpvd.dRows){
            r.showDocList = false;
        }
        DPVolumeDistribution.DistributionRow row = 
            new DPVolumeDistribution.DistributionRow(document.Type__c, document.Id, document.Delivery_Plan__r.Id, getUnusedDocumentSL());
        dpvd.addRow(row);       
    } 
    
    public void delDistributionRow(){
        changed = true;
    	dpvd.deleteRow(delRowId); 
    }
    
    public void saveChanges(){
        System.Savepoint rollbackPoint = Database.setSavepoint();
        try{
            for(DPVolumeDistribution.DistributionRow row : dpvd.dRows){
                system.debug('DISTRIBUTION: ' + row.distribution);
                if(row.status == 'new'){
                    insert row.distribution;
                }else if (row.status == 'delete'){
                    delete row.distribution;
                }else if (row.status == 'edit'){
                    update row.distribution;
                }
            }
        }catch(Exception e){
            Database.rollback(rollbackPoint);
            ApexPages.addMessages(e);
            return;
        }
        updateDistributionsList();
    }
    
    public void editRow(){
        changed = true;
    	dpvd.editRow(selectedRowId);
    }
            
}