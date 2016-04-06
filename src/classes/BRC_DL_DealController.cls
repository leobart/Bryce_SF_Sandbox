public class BRC_DL_DealController {
    public BRC_DL_Deal__c filterFields {get; set;}
    public List<SelectOption> companyListSO {get; set;}
    public String selectedCompany {get; set;}
    public List<SelectOption> yearsSO {get; private set;}
    public List<SelectOption> monthsSO {get; private set;}
    public Integer selectedYear {get; set;}
    public Integer selectedMonth {get; set;}
    
    public BRC_DL_Deal__c sellDeal {get; set;}
    public Map<integer, BuyDealWrapper> buyDeals {get; set;}
    public integer buyDealNumber {get; set;}
    public integer selectedBuyDealNumber {get; set;}
    
    public Map<Integer, BRC_DL_DealRelation> dealsRelationMap {get; set;} 
    public Integer selectedBuyInd {get; set;} 
    public Integer selectedSellInd {get; set;} 
    
    private integer currentMonth;
   
    
    public class BuyDealWrapper{
        public boolean useExisting {get; set;}
        public BRC_DL_Deal_Relation__c dealR {get; set;}
        public BRC_DL_Deal__c buyDeal {get; set;}
        
        public BuyDealWrapper(boolean useExisting, BRC_DL_Deal__c buyDeal){
            this.useExisting = useExisting;
            this.buyDeal = buyDeal;
        }
    }
        
    public BRC_DL_DealController(){
        dealsRelationMap = new Map<Integer, BRC_DL_DealRelation>();
        currentMonth = Date.today().Month();
        filterFields = new BRC_DL_Deal__c();
        filterFields.Type__c = 'Sell';
        List<String> companyList = c2g.CODAAPICompany_2_0.GetCurrentCompanies(null);
        List<c2g__codaCompany__c> companies = [SELECT Id, Name FROM c2g__codaCompany__c WHERE Name in: companyList];
        selectedCompany = companies[0].Id;
        companyChangedAction();
        companyListSO = new List<SelectOption>();
        for(c2g__codaCompany__c c : companies){
            SelectOption so = new SelectOption(c.Id, c.Name);
            companyListSO.add(so);
        }         
        yearsSO = DatesHelper.YEARS_LIST.clone();
        selectedYear = Date.today().year();
        monthsSO = DatesHelper.MONTHS_ALL_LIST.clone();
        selectedMonth = 0;
    }
    
    public integer getBuyDealSize(){
        return buyDeals.size();
    }
    
    public void companyChangedAction(){
        filterFields.Company__c = selectedCompany;
    }
    
    public PageReference createDealAction(){
        integer month = currentMonth;
        if(selectedMonth > 0) month = selectedMonth;
        sellDeal = new BRC_DL_Deal__c();
        sellDeal.Prepayment_Percent__c = 80;
        sellDeal.Shipment_Month__c = DatesHelper.getMonthStr(selectedMonth, '/', selectedYear);
        sellDeal.Type__c = 'Sell';
        sellDeal.Company__c = filterFields.Company__c;
        sellDeal.Contract__c = filterFields.Contract__c;
        sellDeal.Addendum__c = filterFields.Addendum__c;
        buyDealNumber = 0;
        buyDeals = new Map<integer, BuyDealWrapper>();        
        buyDeals.put(buyDealNumber, new BuyDealWrapper(false, createBuyDeal()));
        return new PageReference('/apex/brc_dl_CreateDealPage');
    }
    
    private BRC_DL_Deal__c createBuyDeal(){
        integer month = currentMonth;
        if(selectedMonth > 0) month = selectedMonth;
        BRC_DL_Deal__c buyDeal = new BRC_DL_Deal__c();
        buyDeal.Prepayment_Percent__c = 100;
        buyDeal.Shipment_Month__c = DatesHelper.getMonthStr(selectedMonth, '/', selectedYear);
        buyDeal.Type__c = 'Buy';
        buyDeal.Company__c = filterFields.Company__c;
        return buyDeal;
    }
    
    public void addBuyDealAction(){
        buyDealNumber++;
		buyDeals.put(buyDealNumber, new BuyDealWrapper(false, createBuyDeal()));                
    }
    
    public void deleteBuyDealAction(){
        system.debug('SELECTED DEAL NUM: ' + selectedBuyDealNumber);
       buyDeals.remove(selectedBuyDealNumber); 
    }
    
    public PageReference combackToDealPage(){
        return new PageReference('/apex/brc_dl_DealPage');
    }
    
    public PageReference createDealsAction(){
        System.Savepoint dbSavePoint = Database.setSavepoint();
        try{
            insert sellDeal;
            for (Integer key : buyDeals.keySet()){
                BuyDealWrapper bdw = buyDeals.get(key);
                if(bdw.useExisting){
                    bdw.dealR.Sell_Deal__c = sellDeal.Id;
                    insert bdw.dealR;
                }else{
                    insert bdw.buyDeal;
                    BRC_DL_Deal_Relation__c dr = new BRC_DL_Deal_Relation__c();
                    dr.Sell_Deal__c = sellDeal.Id;
                    dr.Buy_Deal__c = bdw.buyDeal.Id;
                    insert dr;
                }
            }
            filterFields.Contract__c = sellDeal.Contract__c;
            filterFields.Addendum__c = sellDeal.Addendum__c;
            selectedMonth = DatesHelper.getMonthFromMonthYearStr(sellDeal.Shipment_Month__c);
            selectedYear = DatesHelper.getMonthFromMonthYearStr(sellDeal.Shipment_Month__c);
            return combackToDealPage();
        } catch (Exception e){
		    // Rollback database if error 
		    Database.rollback(dbSavePoint);
		    //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
            return null;
        }
    }
    
    public void findDealAction(){
        dealsRelationMap = new Map<Integer, BRC_DL_DealRelation>();
        List<BRC_DL_Deal__c> sDeals = [SELECT Id, Name, 
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
                                       WHERE Type__c='Sell' 
                                       	AND Contract__c=:filterFields.Contract__c 
                                       	AND Addendum__c=:filterFields.Addendum__c];
        if(sDeals.size() > 1){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Уточните условия поиска'));
            return;
        } else if(sDeals.size() == 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Ни одной сделки не найдено'));   
            return;
        }
        BRC_DL_Deal__c sellDeal = sDeals[0];
        dealsRelationMap.put(0, new BRC_DL_DealRelation(sellDeal));       
    }
    
    public void addLineAction(){
        dealsRelationMap.get(selectedSellInd).addVolumeLine(selectedBuyInd);
    }
    
    public void calcAmountLinesAction(){
        dealsRelationMap.get(selectedSellInd).calcAmountLines(selectedBuyInd);        
    }
    
    public void addFinalLineAction(){
        dealsRelationMap.get(selectedSellInd).addFinalLine(selectedBuyInd);        
    }
    
    public void saveDealAction(){
        System.Savepoint dbSavePoint = Database.setSavepoint();
        try{
            dealsRelationMap.get(selectedSellInd).saveDeal(selectedBuyInd);
        } catch (Exception e){
		    // Rollback database if error 
		    Database.rollback(dbSavePoint);
        }
        
    }
    
}