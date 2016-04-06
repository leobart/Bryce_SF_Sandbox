public class BRC_DL_DealRelation {

    public Deal sellDeal {get; set;}
    public Map<Integer, Deal> buyDeals {get; set;}
    public Integer bdIndex {get; set;}

    public class BalanceSheet{
        public String dealName {get; set;}
        public Decimal quantity {get; set;}
        public Decimal finalPrice {get; set;}
        public Decimal amount {get; set;}
        
        public BalanceSheet(String dealName, Decimal quantity, Decimal finalPrice, Decimal amount){
            this.dealName = dealName;
            this.quantity = quantity;
            this.finalPrice = finalPrice;
            this.amount = amount;
        }
        
        public BalanceSheet(){}
    }
    public Decimal balance {get; set;}
    public List<BalanceSheet> balanceSheet {get; set;}

    public class Deal{
        public BRC_DL_Deal__c deal {get; set;}
        public Map<Integer, AmountLine> amountLines{get; set;} 
        public Integer alIndex;
        public Boolean editFinalPrice {get; set;}
        
        public Deal(BRC_DL_Deal__c deal, Map<Integer, AmountLine> amountLines, Integer alIndex ){
            editFinalPrice = false;
            this.deal = deal;
            this.amountLines = amountLines;
            this.alIndex = alIndex;
        }
        
        public void addLineSinPin(){
            BRC_DL_Deal_Amount_Line__c dal = new BRC_DL_Deal_Amount_Line__c(Date__c = Date.today(), Deal__c = deal.Id);
            if(deal.Type__c == 'Sell'){
            	dal.Type__c='SIN';                
            }else{
                dal.Type__c='PIN';
            }
            amountLines.put(alIndex++, new AmountLine(dal, 'new'));
        }
        
        /*public void addLineScrPcr(){
            BRC_DL_Deal_Amount_Line__c dal = new BRC_DL_Deal_Amount_Line__c(Date__c = Date.today(), Deal__c = deal.Id);
            if(deal.Type__c == 'Sell'){
            	dal.Type__c='SCR';                
            }else{
                dal.Type__c='PCR';
            }
            amountLines.put(alIndex++, new AmountLine(dal, 'new'));
        }*/
        
        public void addLineFinal(){
            if(getFinalExists()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Final Invoice already exists in list'));
                return;
            }
            if(deal.Final_Price__c == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Can not create final invoice. Final price is empty'));
                deal.Final_Price__c.AddError('Set Value');
                return;
            }
            Decimal totalQ = getTotalQuantity();
            Decimal totalA = getTotalAmount();
            Decimal finalA = deal.Final_Price__c * totalQ - totalA;
            BRC_DL_Deal_Amount_Line__c dal = new BRC_DL_Deal_Amount_Line__c(Date__c = Date.today(), Amount__c = finalA, Final__c = true , Deal__c = deal.Id);
            if(finalA > 0){
                if(deal.Type__c == 'Sell'){
                    dal.Type__c='SIN';                
                }else{
                    dal.Type__c='PIN';
                }                
            }else{
                if(deal.Type__c == 'Sell'){
                    dal.Type__c='SCR';                
                }else{
                    dal.Type__c='PCR';
                }               
            }
            amountLines.put(alIndex++, new AmountLine(dal, 'newFinal'));                
        }
        
        public boolean getfinalExists(){
            for(Integer i : amountLines.keySet()){
                AmountLine al = amountLines.get(i);
                if (al.Line.Final__c) return true;
            }
            return false;
        }
        
        public void calcAmount(){
            for(Integer i : amountLines.keySet()){
                AmountLine al = amountLines.get(i);
                if (al.Line.Quontity__c != null && al.type=='new') al.Line.Amount__c = al.Line.Quontity__c * deal.Preliminary_Price__c * deal.Prepayment_Percent__c / 100;
            }            
        }
        
        public Decimal getTotalAmount(){
            Decimal sum = 0;
            for(Integer i : amountLines.keySet()){
                AmountLine al = amountLines.get(i);
                if (al.Line.Amount__c != null) sum = sum + al.Line.Amount__c;
            }
            return sum;
        }
        
        public Decimal getTotalQuantity(){
            Decimal sum = 0;
            for(Integer i : amountLines.keySet()){
                AmountLine al = amountLines.get(i);
                if (al.Line.Quontity__c != null) sum = sum + al.Line.Quontity__c;
            }
            return sum;
        }
        
        public Boolean getSaveEnabled(){
            for(Integer i : amountLines.keySet()){
                AmountLine al = amountLines.get(i);
                if (al.type != 'saved') return true;
            }
            return false;            
        }
        
        public void deleteFinalLine(){
            Integer fLineId = -1;
            for(Integer i : amountLines.keySet()){
                AmountLine al = amountLines.get(i);
                if (al.type=='newFinal'){
                    fLineId = i;
                    break;
                }
            }
            if (fLIneId != -1) amountLines.remove(flineId);
        }  
        
        public void saveDeal(){
            update deal;
            list<BRC_DL_Deal_Amount_Line__c> alForSave = new list<BRC_DL_Deal_Amount_Line__c>();
            for(Integer i : amountLines.keySet()){
                AmountLine al = amountLines.get(i);
                if (al.type.contains('new')) alForSave.add(al.Line);
            } 
            insert alForSave;
        }
    }
    
    public class AmountLine{
        // Types: 'saved'- from DataBase;
        // 'new' - new SIN/PIN/SCR/PCR;
        // 'newFinal' - new final invoice

        public String type {get; set;} 
        public BRC_DL_Deal_Amount_Line__c line {get; set;}
        public Boolean isEdit {get; set;}
        
        public Boolean getFFObjectAssigned(){
            return (line.PIN__c != null || line.SIN__c != null ||  line.SCR__c!= null || line.PCR__c != null) && !isEdit;
        }
        
        public Boolean getShowOutputField(){
            return (line.Type__c=='SIN'&&line.SIN__c!=null || line.Type__c=='SCR'&&line.SCR__c!=null || line.Type__c=='PIN'&&line.PIN__c!=null || line.Type__c=='PCR'&&line.PCR__c!=null) && !isEdit;
        }
        
        public Boolean getShowInputSIN(){
            return (line.Type__c=='SIN' && isEdit);
        }
        
        public Boolean getShowInputSCR(){
            return (line.Type__c =='SCR' && isEdit);
        }
        
        public AmountLine(BRC_DL_Deal_Amount_Line__c line, String type){
            isEdit = false;
            this.type = type;
            this.line = line;
        }
        
        public boolean getEditAmt(){
            return ((line.Type__c=='PCR'||line.Type__c=='SCR')&&type=='new');
        }
        public boolean getEdit(){
            return type != 'saved';
        }
        public boolean getEditQuant(){
            return (line.Type__c=='SIN'||line.Type__c=='PIN')&&type=='new';
        }
    }
    
    public BRC_DL_DealRelation(BRC_DL_Deal__c sellDeal){
        this.sellDeal = initDeal(sellDeal);
        initBuyDeals();
        updateBalanceSheet();
    }
    
    public void reload(){
        this.sellDeal = initDeal(this.sellDeal.deal);
        initBuyDeals(); 
        updateBalanceSheet();
    }
    
    private Deal initDeal(BRC_DL_Deal__c dealC){
        Map<Integer, AmountLine> amountLines = new  Map<Integer, AmountLine>();
        Integer ind = 0;
        List<BRC_DL_Deal_Amount_Line__c> aLinesC = [SELECT  Id,
                                                            Amount__c,
                                                            Deal__c,
                                                            PCR__c,
                                                            SCR__c,
                                                            PIN__c,
                                                            SIN__c,
                                                            Quontity__c,
                                                            Reference_Number__c,
                                                            Type__c,
                                                    		Date__c,
                                                    		Final__c
                                                    FROM BRC_DL_Deal_Amount_Line__c 
                                                    WHERE Deal__c=: dealC.Id];
        for(BRC_DL_Deal_Amount_Line__c al : aLinesC){
            amountLines.put(ind++, new AmountLine(al, 'saved'));
        }
        return new Deal(dealC, amountLines, ind++);        
    }
    
    public void initBuyDeals(){
        buyDeals = new Map<Integer, Deal>();
        bdIndex = 0;
        List<BRC_DL_Deal_Relation__c> dealRList = [SELECT Id, Sell_Deal__c, Buy_Deal__c FROM BRC_DL_Deal_Relation__c WHERE Sell_Deal__c=:sellDeal.deal.Id];
        List<String> buyIds = new List<String>();
        for (BRC_DL_Deal_Relation__c dr : dealRList){
            buyIds.add(dr.Buy_Deal__c);
        }
        
        List<BRC_DL_Deal__c> buyDealsC = [SELECT Id, Name,
                                          		Contract__c, 
                                          		Contract__r.Account.Name,
                                          		Addendum__c, 
                                          		Company__c, 
                                          		Planned_Quantity__c, 
                                          		Preliminary_Price__c, 
                                          		Prepayment_Percent__c,
                                          		Shipment_Month__c,
                                          		Type__c, 
                                          		Final_Price__c
                                          FROM BRC_DL_Deal__c 
                                          WHERE Id IN: buyIds];
        for(BRC_DL_Deal__c buyDealC : buyDealsC){
            buyDeals.put(bdIndex++, initDeal(buyDealC));
        }                
    }
    
    private void updateBalanceSheet(){
        balanceSheet = new list<BalanceSheet>();
        balance = null;
        for(Integer key: buyDeals.keySet()){
            Deal d = buyDeals.get(key);
            BalanceSheet bs = new BalanceSheet();
            bs.dealName = 'Buy From: ' + d.deal.Name;
            bs.quantity = sellDeal.getTotalQuantity();
            bs.finalPrice = d.deal.Final_Price__c;
            if(bs.finalPrice != null){
                bs.amount = -(bs.quantity * bs.finalPrice);
            }
            balanceSheet.add(bs);
        }
        BalanceSheet bs = new BalanceSheet();
        bs.dealName =  'Sell To: ' + sellDeal.deal.Name;
        bs.quantity = sellDeal.getTotalQuantity();
        bs.finalPrice = sellDeal.deal.Final_Price__c;
        if(bs.finalPrice != null){
        	bs.amount = bs.quantity * bs.finalPrice;
        }
        balanceSheet.add(bs);
        balance = 0;
        for(BalanceSheet b : balanceSheet){
            if (b.amount != null) balance = balance + b.amount;
        }
    }
    
    private Deal getSelectedDeal(Integer buyInd){
        if(buyInd == -1){
            return sellDeal;
        }else{
            return buyDeals.get(buyInd);
        }       
    }
    
    public void addVolumeLine(Integer buyInd){
        getSelectedDeal(buyInd).addLineSinPin();
        updateBalanceSheet();
    }
    
    public void calcAmountLines(Integer buyInd){
        Deal dl = getSelectedDeal(buyInd);
        dl.deleteFinalLine();
        dl.calcAmount();
        updateBalanceSheet();
    }
    
    public void addFinalLine(Integer buyInd){
        getSelectedDeal(buyInd).addLineFinal();
        updateBalanceSheet();
    }
    
    public void saveDeal(Integer buyInd){
        getSelectedDeal(buyInd).saveDeal();
        reload();
    }
}