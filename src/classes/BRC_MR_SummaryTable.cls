public class BRC_MR_SummaryTable {

    public List<String> headers {get; set;} 
    public List<ReportRow> rows {get; set;}
    
    public class ReportRow{
        
        public String title {get; set;}
        public Decimal brcF {get; set;}
        public Decimal brcR {get; set;}
        public Decimal manP {get; set;}
        public Decimal brcC {get; set;}
        public Decimal sum {get; set;}
        public Boolean sub {get; set;}
        public Boolean summary {get; set;}
        
        
        public ReportRow(String title, Decimal brcF, Decimal brcR, Decimal manP, Decimal brcC){
            this.init(title, brcF, brcR, manP, brcC);
        }
        
        private void init(String title, Decimal brcF, Decimal brcR, Decimal manP, Decimal brcC){
            summary = false;
            sub = false;
            sum = 0;
            this.title = title;
            this.brcF = brcF;
            if(brcF!=null) sum = sum + brcF;
            this.brcR = brcR;
            if(brcR!=null) sum = sum + brcR;
            this.manP = manP;
            if(manP!=null) sum = sum + manP;
            this.brcC = brcC;
            if(brcC!=null) sum = sum + brcC;            
        }
        
        public ReportRow(String title, Decimal brcF, Decimal brcR, Decimal manP, Decimal brcC, Boolean sub){
            this.init(title, brcF, brcR, manP, brcC);
            this.sub = sub;
        }
    }
    
    
    public BRC_MR_SummaryTable(BRC_MR_ItemsTree tree){
        headers = new String[] {'', 'Иностранные компании BRYCE', 'Российские компании BRYCE', 'Личные компании MАН', 'Касса','Итого'};
            updateTable(tree);
    }
    
    
    public void updateTable(BRC_MR_ItemsTree tree){
        //BRC Foreign 
		Decimal brcFBlockedFunds =  tree.getValueForReferenceId('brc_foreign_blocked_funds');        
		Decimal brcFAvailableFunds =  tree.getValueForReferenceId('brc_foreign_available_funds'); 
        Decimal brcFAllFunds =  tree.getValueForReferenceId('brc_foreign_all_funds'); 
        
		Decimal brcFInventory =  tree.getValueForReferenceId('brc_foreign_inventory');        
		Decimal brcFAssets =  tree.getValueForReferenceId('brc_foreign_assets');        
		Decimal brcFProperty =  tree.getValueForReferenceId('brc_foreign_property');        
		Decimal brcFLiabilites =  tree.getValueForReferenceId('brc_foreign_liabilites');        
		Decimal brcFAll = tree.getValueForReferenceId('brc_foreign');        

		//BRC Russia
		Decimal brcRAvailableFunds =  tree.getValueForReferenceId('brc_russia_available_funds');        
		Decimal brcRProperty =  tree.getValueForReferenceId('brc_russia_property');        
		Decimal brcRLiabilites =  tree.getValueForReferenceId('brc_russia_liabilites');        
		Decimal brcRAll =  tree.getValueForReferenceId('brc_russia');        

		//MAN Personal
		Decimal manPAvailableFunds =  tree.getValueForReferenceId('man_personal_available_funds');        
		Decimal manPAssets =  tree.getValueForReferenceId('man_personal_assets');        
		Decimal manPProperty =  tree.getValueForReferenceId('man_personal_property');        
		Decimal manPLiabilites =  tree.getValueForReferenceId('man_personal_liabilites');  
		Decimal manPAll =  tree.getValueForReferenceId('man_personal');  
        
        //Cash
		Decimal brcCash =  tree.getValueForReferenceId('brc_cash');  
        
        //Inint Rows
        rows = new list<ReportRow>();
        rows.add(new ReportRow('Денежные средства', brcFAllFunds, brcRAvailableFunds, manPAvailableFunds, brcCash));
        rows.add(new ReportRow('Свободные', brcFAvailableFunds, brcRAvailableFunds, manPAvailableFunds, brcCash, true));
        rows.add(new ReportRow('Заблокированные', brcFBlockedFunds, null, null, null, true));
        rows.add(new ReportRow('Товарные запасы', brcFInventory, null, null, null));
        rows.add(new ReportRow('Активы', brcFAssets, null, manPAssets, null));
        rows.add(new ReportRow('Имущество', brcFProperty, brcRProperty, manPProperty, null));
        rows.add(new ReportRow('Обязательства', brcFLiabilites, brcRLiabilites, manPLiabilites, null));
        ReportRow rr = new ReportRow('Итого', brcFAll, brcRAll, manPAll, brcCash);
        rr.summary = true;
        rows.add(rr);
    }
}