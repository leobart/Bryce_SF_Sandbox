public class DPDistributionController{
    
    public List<DPVolumeDistribution> dpDocDistributions {get; set;}
    public Delivery_Plan__c deliveryPlan {get; set;}
    public static List<SelectOption> docTypeSL {get; set;}
    public String groupType {get; set;}
    public List<SelectOption> documentSL {get; set;}
    
    public String currentDocId {get; set;}
    
    static{
        docTypeSL = new List<SelectOption>();
        docTypeSL.add(new SelectOption('Sell','Sell'));
        docTypeSL.add(new SelectOption('Buy','Buy'));
    }   
    
    public DPDistributionController(){
        groupType = 'Sell';
        dpDocDistributions = new List<DPVolumeDistribution>();
        String dpId = ApexPages.currentPage().getParameters().get('dpId');
        deliveryPlan = [SELECT Id, Name FROM Delivery_Plan__c WHERE Id=:dpId];
        updateDistributionsList();
    }
    
    public void updateDistributionsList(){
        dpDocDistributions = new List<DPVolumeDistribution>();
        List<Delivery_Document__c> deliveryDocuments = [SELECT Id, Name, Planned_volume__c FROM Delivery_Document__c WHERE Type__c=: groupType AND Delivery_Plan__r.Id=:deliveryPlan.Id];
        
        for(Delivery_Document__c deliveryDocument : deliveryDocuments){
            system.debug('DP Doc: ' + deliveryDocument);
            DPVolumeDistribution dpvd = new DPVolumeDistribution();
            dpvd.distributionDoc = deliveryDocument;
            String docId = deliveryDocument.id;
            String dbSelect;
            if(groupType == 'Sell'){
                dbSelect = 'SELECT Id, Buy_Document__r.Id, Buy_Document__r.Name, Volume__c FROM Volume_Distribution__c WHERE Sell_Document__r.Id=:docId';
                updateDocSL([SELECT Id, Name FROM Delivery_Document__c WHERE Type__c='Buy' AND Delivery_Plan__r.Id=:deliveryPlan.Id]);
            }else{
                dbSelect = 'SELECT Id, Sell_Document__r.Id, Sell_Document__r.Name, Volume__c FROM Volume_Distribution__c WHERE Buy_Document__r.Id=:docId';
                updateDocSL([SELECT Id, Name FROM Delivery_Document__c WHERE Type__c='Sell' AND Delivery_Plan__r.Id=:deliveryPlan.Id]);
            }
            List<Volume_Distribution__c> l = Database.query(dbselect);
            for(Volume_Distribution__c vd : l){
                dpvd.dRows.add(new DPVolumeDistribution.DistributionRow(false, vd));
            }
            dpDocDistributions.add(dpvd);
        }
    }
    
    
    private void updateDocSL(List<Delivery_Document__c> ddl){
        documentSL = new List<SelectOption>();
        for(Delivery_Document__c d : ddl){
        	documentSL.add(new SelectOption(d.Id, d.Name));
        }
    }
    
    public void addDistributionRow(){
        DPVolumeDistribution dpvd = findDistribution();
        DPVolumeDistribution.DistributionRow row;
        if(groupType == 'Sell'){
        	row = new DPVolumeDistribution.DistributionRow(true, new Volume_Distribution__c(Volume__c=0, Sell_Document__c=dpvd.distributionDoc.Id));     
        }else{
        	row = new DPVolumeDistribution.DistributionRow(true, new Volume_Distribution__c(Volume__c=0, Buy_Document__c=dpvd.distributionDoc.Id));                 
        }
        
        if (documentSL.size() > 0){
        	row.documentId = documentSL[0].getValue();
        }
        
        dpvd.dRows.add(row);       
    } 
    
    public Integer getDistributionsListSize(){
        return dpDocDistributions.size();
    }
    
    private DPVolumeDistribution findDistribution(){
        for(DPVolumeDistribution dpvd : dpDocDistributions){
            if(dpvd.distributionDoc.Id == currentDocId) return dpvd;
        }
        return null;
    }

}