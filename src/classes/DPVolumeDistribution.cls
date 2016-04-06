//Class contain distributions for some document(buy/sell)
public class DPVolumeDistribution{
    
    public class DistributionRow{
        public String docType;
        public String documentId;
        public Volume_Distribution__c distribution {get; set;}
        public Boolean edit {get; set;}
        public integer id {get; set;}
        // status can be: view, edit, delete, new
        public String status {get; set;}
		public List<SelectOption> documentSL {get; set;}
        public Boolean showDocList {get; set;} 
        public Decimal availableVolume;
        public Decimal availableVolumeForEdit;
        public String description {get; set;}
        
        //Constructor for distribution row from database
        public DistributionRow(Boolean docType, Volume_Distribution__c vd){}
        public DistributionRow(String docType, Volume_Distribution__c vd){
            this.docType = docType;
            distribution = vd;
            this.status = 'view';
            this.showDocList = false;
            if(docType == 'Sell'){                
                documentId = distribution.Buy_Document__c;
            } else {
                documentId = distribution.Sell_Document__c;
            } 
            availableVolume = calcAvailableVolume();
            description = DPVolumeDistribution.getDDFullName(documentId);
            //Used this value for show max available value for volume in distribution row
            availableVolumeForEdit = availableVolume + distribution.Volume__c;
        }
        
        
        //Constructor for new distribution row in memory
        public DistributionRow(String docType, String firstDocId, String deliveryPlanId, List<SelectOption> documentSL){
            this.docType = docType;
            this.showDocList = true;
            distribution = new Volume_Distribution__c();            
            if(docType == 'Sell'){                
                distribution.Sell_Document__c = firstDocId;
            } else {
                distribution.Buy_Document__c = firstDocId;
            } 
            distribution.Delivery_Plan__c = deliveryPlanId;
            this.documentSL = documentSL;
            if (documentSL.size() == 1) showDocList = false;
            setDocumentId(documentSL[0].getValue());
            this.edit = false;           
            this.status = 'new';
            availableVolumeForEdit = availableVolume;

        }
        
        private Decimal calcAvailableVolume(){
            List<Delivery_Document__c> l = [SELECT Planned_Volume__c FROM Delivery_Document__c WHERE Id=:documentId];
            Decimal plannedVolume = 0;
            if (l.size()>0 && l[0].Planned_Volume__c !=null){
                plannedVolume = l[0].Planned_Volume__c;
            }             
            List<AggregateResult> rl;
            Decimal usedVolume = 0;
            if(docType=='Sell'){
                rl = [SELECT Sum(Volume__c) usedVolume FROM Volume_Distribution__c WHERE Buy_Document__r.Id=:documentId GROUP BY Buy_Document__r.Id];    
            }else{
                rl = [SELECT Sum(Volume__c) usedVolume FROM Volume_Distribution__c WHERE Sell_Document__r.Id=:documentId GROUP BY Sell_Document__r.Id];                
            }
            if (rl.size()>0) usedVolume = (Decimal)rl[0].get('usedVolume');
            return plannedVolume - usedVolume;
        }
        
        
        public void setDocumentId(String docId){
            this.documentId = docId;
            if(docType == 'Sell'){
                distribution.Buy_Document__r = [SELECT Id, Name FROM Delivery_Document__c WHERE Id=:documentId][0];
                distribution.Buy_Document__c = distribution.Buy_Document__r.Id;
            } else {
                distribution.Sell_Document__r = [SELECT Id, Name FROM Delivery_Document__c WHERE Id=:documentId][0];
                distribution.Sell_Document__c = distribution.Sell_Document__r.Id;
            } 
            availableVolume = calcAvailableVolume();
            distribution.Volume__c = 0;
           description = DPVolumeDistribution.getDDFullName(documentId);
        }
        
        public String getDocumentId(){
            return documentId;
        }
        
        public Decimal getAvailableVolume(){
            if(status=='edit') return availableVolumeForEdit;
            return availableVolume;
        }
        

    }
    
    public Delivery_Document__c distributionDoc {get; set;}
    public List<DistributionRow> dRows {get; set;} 
    private Integer idNumber;
    public Boolean allDocInUse {get; set;}
    
    public DPVolumeDistribution(){
        idNumber = 0;
        dRows = new List<DistributionRow>();
    }
    
    public void addRow(DistributionRow r){
        idNumber++;
        r.id = idNumber;
        dRows.add(r);
    }
    
    public void deleteRow(Integer idNumber){
        List<DistributionRow> l = new List<DistributionRow>();
        for(DistributionRow r : dRows){
            If(r.id == idNumber && r.distribution.Id ==null){
                allDocInUse = false;
            	continue;
            }else if (r.id == idNumber && r.distribution.Id !=null){
                r.status = 'delete';
            }
            l.add(r);
        }
        dRows = l;
    }
    
    public void editRow(Integer idNumber){
        for(DistributionRow r : dRows){
            If(r.id == idNumber ){
            	r.status = 'edit';
            }
        }
    }
    
    public Decimal getSummary(){
    	Decimal s = 0;
        for(DistributionRow r : dRows){
            if(r.status != 'delete') s = s + r.distribution.Volume__c;
        }
        return s;
    }
    
    public static String getDDFullName(String documentId){
        Delivery_Document__c dd = [SELECT Name, Contract__r.Name, Addendum__r.Name, Contract__r.Account.Name, Planned_Month__c FROM Delivery_Document__C WHERE id=:documentId];
        system.debug('DD: ' + dd);
        String addendum = '';
        if(dd.Addendum__r.Name != null) addendum = ' / ' + dd.Addendum__r.Name;
        String res = dd.Contract__r.Name + addendum + ' / ' + dd.Contract__r.Account.Name + ' / ' + dd.Planned_month__c ;
        return res;
    }

}