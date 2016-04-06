public class LogisticReportsController{
    
    public static list<String> MONTH_ALIASES = new list<String>{'January', 'February', 'March', 'April', 'May', 
        										'June', 'July', 'August', 'September', 'October', 
        										'November', 'December'}; 
    
    public static List<SelectOption> YEARS_LIST {get; set;}
    public Static list<SelectOption> MONTHS_LIST {get; set;}
    
    static{
        YEARS_LIST = new List<SelectOption>();
        MONTHS_LIST = new List<SelectOption>();
        for(Integer i=2010; i<=2030; i++){
            YEARS_LIST.add(new SelectOption(i+'',i+''));            
        } 
        for(Integer i=1; i<=12; i++){
            String mNum = i + '';
            if(i<10) mNum = '0' + mNum;
            MONTHS_LIST.add(new SelectOption(mNum, MONTH_ALIASES[i-1]));             
        }        
    }
    
    private final static String ALL_STR = '%';
    
    public static String REPORT_CELL_STRING_TYPE='String';
    public static String REPORT_CELL_DECIMAL_TYPE='Decimal';
    public static String REPORT_CELL_LINK_TYPE='Link';
    
    private static final String LAST_STATE = 'Last';
    
    public class ReportCell{
        public Object value {get; private set;}
        public Object Id {get; set;}
        public Boolean isSummary {get; private set;}
        public String type {get; private set;}
        
        public ReportCell(Object value, String type, Boolean isSummary){
            this(value, type);
            this.isSummary = isSummary;
        }
        
        public ReportCell(Object value, String type){
            this.value = value;
            this.type = type;
            this.isSummary = false;
        }
        
        public ReportCell copy(){
            ReportCell rc = new ReportCell(this.value, this.type, this.isSummary);
            rc.Id = Id;
            return rc;
        }
    }
    
    public ReportCell createlinkCell(Object value, Object Id){
        ReportCell rc = new ReportCell(value, REPORT_CELL_LINK_TYPE);
        rc.Id = Id;
        return rc;
    }
    
    public Integer selectedReport {get; set;}
    public List<List<ReportCell>> reportTable{get; set;}
    public List<String> reportTableHeaders {get; set;}
    public List<SelectOption> deliveryPlansSO {get; private set;}
    public String selectedDeliveryPlan {get; set;}
    public String selectedYear {get; set;}
    public String selectedMonth {get; set;}
    public List<SelectOption> yearsSO {get; private set;}
    public List<SelectOption> monthsSO {get; private set;}
    
    private String dpSelector;
    private String sellMonthAndYearSelector;
    private String buyMonthAndYearSelector;
    private String monthAndYear;
    
    public LogisticReportsController(){
        selectedReport = 0;
        clearReport();
    	deliveryPlansSO = new List<SelectOption>();
        selectedDeliveryPlan = ALL_STR;
        SelectOption allSO = new SelectOption(ALL_STR, 'All');
        deliveryPlansSO.add(allSO); 
    	for(Delivery_Plan__c dp : [SELECT Id, Name FROM Delivery_Plan__c]){
    		deliveryPlansSO.add(new SelectOption(dp.Id, dp.Name)); 
    	}
        monthsSO = new List<SelectOption>();
        monthsSO.add(allSO);
        for(SelectOption mSO : MONTHS_LIST){
            monthsSO.add(mSO);
        }
        yearsSO = new List<SelectOption>();
        yearsSO.add(allSO);
        for(SelectOption ySO : YEARS_LIST){
            yearsSO.add(ySO);
        }
        
    }
    
    public void clearReport(){
        reportTable = new List<List<ReportCell>>();
        reportTableHeaders = new List<String>();
    }
    
    public void runReport(){
        if(selectedReport == 0){
            shipmentByCintractMonthReport();            
        }else if (selectedReport == 1){
            summaryByShipment();
        }else if (selectedReport == 2){
            sellaryPlanFromSeller();
        }else if (selectedReport == 3){
            sellaryPlanFromBuyer();
        }        
    }
    
    private Boolean prepareParameters(){
        dpSelector = '';
        sellMonthAndYearSelector  = '';
        buyMonthAndYearSelector = '';
        if(selectedDeliveryPlan != ALL_STR) dpSelector = ' AND Delivery_Plan__c=:selectedDeliveryPlan ';
        monthAndYear = selectedMonth + '/' + selectedYear;
        sellMonthAndYearSelector = ' AND Sell_Document__r.Planned_Month__c LIKE :monthAndYear  ';
        buyMonthAndYearSelector = ' AND Buy_Document__r.Planned_Month__c LIKE :monthAndYear  ';
        return true;
    }
    
    //Отгрузки по месяцу договора
    public void shipmentByCintractMonthReport(){
        clearReport();
        if(!prepareParameters())return;
        reportTableHeaders = new List<String>{'Month of contract','Shipment date','Delivery Plan', 'Seller', 'Buyer', 'Amount'};
        List<AggregateResult> arList = Database.query('SELECT ' + 
                                           ' Sell_Document__r.Planned_Month__c pMonth,' +
                                           ' CALENDAR_MONTH(Date__c) shipmentMonth,' + 
                                           ' CALENDAR_YEAR(Date__c) shipmentYear,' + 
                                           ' Max(Delivery_Plan__r.Name) dpName, Delivery_Plan__c dpId, MAX(Delivery_Plan__r.Cargo__r.Name) cargoName,' +
                                           ' MAX(buy_document__r.Contract__r.Account.Name) baName, MAX(buy_document__r.Name) bdName, MAX(buy_document__r.Contract__r.Name) bcName, ' +
                                           ' buy_document__c buyDocId,' +
                                           ' Max(sell_document__r.Contract__r.Account.Name) saName, MAX(sell_document__r.Name) sdName, MAX(sell_document__r.Contract__r.Name) scName, ' +
                                           ' sell_document__c sellDocId,' +
                                           ' SUM(Quantity__c) amount ' + 
                                        ' FROM Movement__c ' + 
                                        ' WHERE State__c=:LAST_STATE ' + dpSelector + sellMonthAndYearSelector +
                                        ' GROUP BY ' +
                                           ' Sell_Document__r.Planned_Month__c,' +
                                           ' CALENDAR_MONTH(Date__c),' +
                                           ' CALENDAR_YEAR(Date__c),' +
                                           ' Delivery_Plan__c,' +
                                           ' buy_document__c,' +
                                           ' sell_document__c'
										);
        if(arList.size() == 0) return;       
        for(AggregateResult ar : arList){
            List<ReportCell> rcRow = new List<ReportCell>();
            rcRow.add(new ReportCell(ar.get('pMonth'), REPORT_CELL_STRING_TYPE));
            rcRow.add(new ReportCell(ar.get('shipmentMonth')+' / '+ar.get('shipmentYear'), REPORT_CELL_STRING_TYPE));
            rcRow.add(createlinkCell(ar.get('dpName') + ' / ' + ar.get('cargoName'), ar.get('dpId')));
            rcRow.add(createLinkCell(ar.get('bdName') + ' / ' +  ar.get('bcName') + ' / ' + ar.get('baName'), ar.get('buyDocId')));
            rcRow.add(createLinkCell(ar.get('sdName') + ' / ' +  ar.get('scName') + ' / ' + ar.get('saName'), ar.get('sellDocId')));
            rcRow.add(new ReportCell(ar.get('amount'), REPORT_CELL_DECIMAL_TYPE));
            reportTable.add(rcRow);
        }
        rollupReportTable(1, new Integer[]{5}, null);        
    }
    
    //Сводная по отгрузкам
    public void summaryByShipment(){
        clearReport();
        if(!prepareParameters())return;
        reportTableHeaders = new List<String>{'Buyer', 'Delivery Plan', 'Planned Month', 'Planned Volume', 'Shipment Date', 'Seller', 'Shipment Amount', 'Balance'};
        List<AggregateResult> arList = Database.query(' SELECT ' + 
                                                           ' Max(sell_document__r.Contract__r.Account.Name) saName, MAX(sell_document__r.Name) sdName, MAX(sell_document__r.Contract__r.Name) scName, ' +
                                                           ' sell_document__c sellDocId,' +
                                                           ' Sell_Document__r.Planned_Month__c pMonth, ' +
                                                           ' Max(Sell_Document__r.Planned_Volume__c) pVolume, ' +
                                                           ' CALENDAR_MONTH(Date__c) shipmentMonth, ' + 
                                                           ' CALENDAR_YEAR(Date__c) shipmentYear, ' + 
                                          				   ' MAX(buy_document__r.Contract__r.Account.Name) baName, MAX(buy_document__r.Name) bdName, MAX(buy_document__r.Contract__r.Name) bcName, ' +
                                                           ' buy_document__c buyDocId,' +
                                                           ' Max(Delivery_Plan__r.Name) dpName, Delivery_Plan__c dpId, MAX(Delivery_Plan__r.Cargo__r.Name) cargoName,' +
                                                           ' SUM(Quantity__c) amount ' +                                                        
                                                        ' FROM Movement__c  ' +
                                                        ' WHERE State__c=:LAST_STATE ' + dpSelector + sellMonthAndYearSelector +
                                                        ' GROUP BY ' + 
                                                           ' Sell_document__c, ' +
                                                           ' Sell_Document__r.Planned_Month__c, ' +
                                                           ' CALENDAR_MONTH(Date__c), ' + 
                                                           ' CALENDAR_YEAR(Date__c), ' + 
                                                           ' buy_document__c,' +
                                                           ' Delivery_Plan__c'
														);
        if(arList.size() == 0) return;       
        for(AggregateResult ar : arList){
            List<ReportCell> rcRow = new List<ReportCell>();
            rcRow.add(createLinkCell(ar.get('sdName') + ' / ' +  ar.get('scName') + ' / ' + ar.get('saName'), ar.get('sellDocId')));
            rcRow.add(createlinkCell(ar.get('dpName') + ' / ' + ar.get('cargoName'), ar.get('dpId')));
            rcRow.add(new ReportCell(ar.get('pMonth'), REPORT_CELL_STRING_TYPE));
            rcRow.add(new ReportCell(ar.get('pVolume'), REPORT_CELL_DECIMAL_TYPE));
            rcRow.add(new ReportCell(ar.get('shipmentMonth')+'/'+ar.get('shipmentYear'), REPORT_CELL_STRING_TYPE));
            rcRow.add(createLinkCell(ar.get('bdName') + ' / ' +  ar.get('bcName') + ' / ' + ar.get('baName'), ar.get('buyDocId')));
            rcRow.add(new ReportCell(ar.get('amount'), REPORT_CELL_DECIMAL_TYPE));
            rcRow.add(new ReportCell('', REPORT_CELL_DECIMAL_TYPE));
            reportTable.add(rcRow);
        }
        rollupReportTable(1, new Integer[]{6}, new SummaryByShipmentBalanceCalc());        
    }
    
    public class SummaryByShipmentBalanceCalc implements ReportCellCalculator{
        public void calculate(List<ReportCell> reportRow, List<ReportCell> summaryRow){
            summaryRow[7].value = (Decimal)reportRow[3].value - (Decimal)summaryRow[6].value;
        }
    }
    
    //План продаж от продавца 
    public void sellaryPlanFromSeller(){
        clearReport();
        if(!prepareParameters())return;
        reportTableHeaders = new List<String>{'Seller', 'Contract Month', 'Contract Volume', 'Unit Price', 'Buy Price', 'Shipped',  
            								  'Delivery Plan', 
                                              'Buyer', 'Contract Month', 'Contract Volume', 'Distributed Volume' , 'Unit Price', 'Sell Price', 
                                              'Shipped', 'Shipped Price', 'Planned Profit', 'Shipped Profit'};
        List<AggregateResult> arList = Database.query(' SELECT ' + 
                                                           ' Buy_Document__c bDoc, ' +
                                                           ' MAX(Buy_Document__r.Name) bDocName, ' +
                                                           ' MAX(Buy_document__r.Contract__r.Account.Name) baName, ' +                                                     
                                                           ' Buy_Document__r.Planned_Month__c pbMonth, ' +
                                                           ' MAX(Buy_Document__r.Planned_Volume__c) pbVolume, ' +
                                                           ' MAX(Buy_Document__r.Unit_Price__c) pbPrice, ' +
                                                           ' Delivery_Plan__c dpId, ' +
                                                           ' MAX(Delivery_Plan__r.Name) dpName, ' +
                                                           ' MAX(Delivery_Plan__r.Cargo__r.Name) cargo, ' +
                                                           ' Sell_Document__c sDoc, ' +
                                                           ' Max(Sell_Document__r.Name) sDocName, ' +
                                                           ' MAX(Sell_document__r.Contract__r.Account.Name) saName, ' +                                                     
                                                           ' MAX(Sell_Document__r.Planned_Volume__c) psVolume, ' +
                                                           ' MAX(Sell_Document__r.Unit_Price__c) psPrice, ' +
                                                           ' Sell_Document__r.Planned_Month__c psMonth, ' +
                                                           ' SUM(Volume__c) distribution ' +
                                                        ' FROM Volume_Distribution__c ' +
                                                        ' WHERE Buy_Document__c != null '  + dpSelector + buyMonthAndYearSelector +
                                                        ' GROUP BY ' +
                                                           ' Buy_Document__c, ' +
                                                           ' Buy_Document__r.Planned_Month__c, ' +
                                                           ' Delivery_Plan__c, ' +
                                                           ' Sell_Document__c, ' +
                                                           ' Sell_Document__r.Planned_Month__c '                                                       
														);
        Set<String> buyDocIds = new Set<String>();
        Set<String> sellDocIds = new Set<String>();        
        for(AggregateResult ar : arList){
            buyDocIds.add((String)ar.get('bDoc'));
            sellDocIds.add((String)ar.get('sDoc'));
        }
        List<AggregateResult> sellDocShippedAr = [SELECT Sell_document__c docId, SUM(Quantity__c) shipped 
                                                FROM Movement__c 
                                                WHERE  State__c='Last' AND Sell_Document__c IN :sellDocIds 
                                                GROUP BY Sell_document__c]; 
        List<AggregateResult> buyDocShippedAr = [SELECT Buy_document__c docId, SUM(Quantity__c) shipped 
                                                FROM Movement__c 
                                                WHERE  State__c='First' AND Buy_Document__c IN :buyDocIds 
                                                GROUP BY Buy_Document__c]; 
        
        Map<String,Decimal> bDocShipped = new Map<String,Decimal>();
        Map<String,Decimal> sDocShipped = new Map<String,Decimal>();
        for(AggregateResult ar: sellDocShippedAr) sDocShipped.put((String)ar.get('docId'), (Decimal)ar.get('shipped'));
        for(AggregateResult ar: buyDocShippedAr) bDocShipped.put((String)ar.get('docId'), (Decimal)ar.get('shipped'));
        if(arList.size() == 0) return;       
        for(AggregateResult ar : arList){
            List<ReportCell> rcRow = new List<ReportCell>();
            rcRow.add(createLinkCell(ar.get('baName')+ ' (' +ar.get('bDocName') + ')', ar.get('bDoc')));
            rcRow.add(new ReportCell(ar.get('pbMonth'), REPORT_CELL_STRING_TYPE));
            rcRow.add(new ReportCell(ar.get('pbVolume'), REPORT_CELL_DECIMAL_TYPE));
            rcRow.add(new ReportCell(ar.get('pbPrice'), REPORT_CELL_DECIMAL_TYPE));            
            rcRow.add(new ReportCell((Decimal)ar.get('pbVolume')*(Decimal)ar.get('pbPrice'), REPORT_CELL_DECIMAL_TYPE));
            Decimal shipped = (Decimal)bDocShipped.get((String)ar.get('bDoc'));
            if (shipped == null) shipped = 0;
            rcRow.add(new ReportCell(shipped, REPORT_CELL_DECIMAL_TYPE));            
            
            rcRow.add(createlinkCell(ar.get('dpName') + ' / ' + ar.get('cargo'), ar.get('dpId')));
            
            rcRow.add(createLinkCell(ar.get('saName')+ ' (' + ar.get('sDocName') + ')', ar.get('sDoc'))); 
            rcRow.add(new ReportCell(ar.get('psMonth'), REPORT_CELL_STRING_TYPE));
            rcRow.add(new ReportCell(ar.get('psVolume'), REPORT_CELL_DECIMAL_TYPE));
            rcRow.add(new ReportCell(ar.get('distribution'), REPORT_CELL_DECIMAL_TYPE));
            rcRow.add(new ReportCell(ar.get('psPrice'), REPORT_CELL_STRING_TYPE));
            rcRow.add(new ReportCell((Decimal)ar.get('distribution')*(Decimal)ar.get('psPrice'), REPORT_CELL_DECIMAL_TYPE));
            shipped = (Decimal)sDocShipped.get((String)ar.get('sDoc'));
            if (shipped == null) shipped = 0;
            rcRow.add(new ReportCell(shipped, REPORT_CELL_DECIMAL_TYPE));            
            rcRow.add(new ReportCell(shipped*(Decimal)ar.get('psPrice'), REPORT_CELL_DECIMAL_TYPE));            
            rcRow.add(new ReportCell('', REPORT_CELL_DECIMAL_TYPE));
            rcRow.add(new ReportCell('', REPORT_CELL_DECIMAL_TYPE));

            
            reportTable.add(rcRow);
        }
        rollupReportTable(1, new Integer[]{9,10,12,13,14}, new SellaryPlanFromSellerCalc());        
    }
    
    public class SellaryPlanFromSellerCalc implements ReportCellCalculator{
        public void calculate(List<ReportCell> reportRow, List<ReportCell> summaryRow){
            //Planned profit (#12 - summ sell price, #4 - summ buy price)
            summaryRow[15].value = (Decimal)summaryRow[12].value - (Decimal)reportRow[4].value;
            summaryRow[15].type = REPORT_CELL_DECIMAL_TYPE;
            //Shipped profit (#14 - shipped sell price sum, #3 - unit buy price, #13 - shipped amount )
            summaryRow[16].value = (Decimal)summaryRow[14].value - (Decimal)reportRow[3].value * (Decimal)summaryRow[13].value ;
            summaryRow[16].type = REPORT_CELL_DECIMAL_TYPE;
        }
    }
    
    
    //План продаж от покупателя 
    public void SellaryPlanFromBuyer(){
        clearReport();
        if(!prepareParameters())return;
        reportTableHeaders = new List<String>{'Buyer', 'Contract Month', 'Contract Volume', 'Unit Price', 'Sell Price',  
            								  'Delivery Plan', 
                                              'Seller', 'Contract Month', 'Distributed Volume' , 'Unit Price', 'Buy Price', 
                                              'Shipped', 'Shipped Buy Price', 'Planned Profit', 'Shipped Profit'};
        List<AggregateResult> arList = Database.query(' SELECT ' + 
                                                           ' Sell_Document__c sDoc, ' +
                                                           ' MAX(Sell_Document__r.Name) sDocName, ' +
                                                           ' MAX(Sell_document__r.Contract__r.Account.Name) saName, ' +                                                     
                                                           ' Sell_Document__r.Planned_Month__c psMonth, ' +
                                                           ' MAX(Sell_Document__r.Planned_Volume__c) psVolume, ' +
                                                           ' MAX(Sell_Document__r.Unit_Price__c) psPrice, ' +
                                                           ' Delivery_Plan__c dpId, ' +
                                                           ' MAX(Delivery_Plan__r.Name) dpName, ' +
                                                           ' MAX(Delivery_Plan__r.Cargo__r.Name) cargo, ' +
                                                           ' Buy_Document__c bDoc, ' +
                                                           ' Max(Buy_Document__r.Name) bDocName, ' +
                                                           ' MAX(Buy_document__r.Contract__r.Account.Name) baName, ' +                                                     
                                                           ' MAX(Buy_Document__r.Planned_Volume__c) pbVolume, ' +
                                                           ' MAX(Buy_Document__r.Unit_Price__c) pbPrice, ' +
                                                           ' Buy_Document__r.Planned_Month__c pbMonth, ' +
                                                           ' SUM(Volume__c) distribution ' +
                                                        ' FROM Volume_Distribution__c ' +
                                                        ' WHERE Buy_Document__c != null '  + dpSelector + sellMonthAndYearSelector +
                                                        ' GROUP BY ' +
                                                           ' Sell_Document__c, ' +
                                                           ' Sell_Document__r.Planned_Month__c, ' +
                                                           ' Delivery_Plan__c, ' +
                                                           ' Buy_Document__c, ' +
                                                           ' Buy_Document__r.Planned_Month__c '                                                       
														);
        Set<String> sellDocIds = new Set<String>();        
        for(AggregateResult ar : arList){
            sellDocIds.add((String)ar.get('sDoc'));
        }
        List<AggregateResult> sellDocShippedAr = [SELECT Sell_Document__c sDocId, Buy_Document__c bDocId, SUM(Quantity__c) shipped 
                                                FROM Movement__c 
                                                WHERE  State__c='Last' AND Sell_Document__c IN :sellDocIds 
                                                GROUP BY Sell_Document__c, Buy_Document__c]; 
        
        Map<String,Decimal> sDocShipped = new Map<String,Decimal>();
        for(AggregateResult ar: sellDocShippedAr) sDocShipped.put((String)ar.get('sDocId') + (String)ar.get('bDocId'), (Decimal)ar.get('shipped'));
        if(arList.size() == 0) return;       
        for(AggregateResult ar : arList){
            List<ReportCell> rcRow = new List<ReportCell>();
            rcRow.add(createLinkCell(ar.get('saName')+ ' (' + ar.get('sDocName') + ')', ar.get('sDoc'))); 
            rcRow.add(new ReportCell(ar.get('psMonth'), REPORT_CELL_STRING_TYPE));
            rcRow.add(new ReportCell(ar.get('psVolume'), REPORT_CELL_DECIMAL_TYPE));
            rcRow.add(new ReportCell(ar.get('psPrice'), REPORT_CELL_STRING_TYPE));
            rcRow.add(new ReportCell((Decimal)ar.get('psVolume')*(Decimal)ar.get('psPrice'), REPORT_CELL_DECIMAL_TYPE));

            rcRow.add(createlinkCell(ar.get('dpName') + ' / ' + ar.get('cargo'), ar.get('dpId')));

            rcRow.add(createLinkCell(ar.get('baName')+ ' (' +ar.get('bDocName') + ')', ar.get('bDoc')));
            rcRow.add(new ReportCell(ar.get('pbMonth'), REPORT_CELL_STRING_TYPE));
            rcRow.add(new ReportCell(ar.get('distribution'), REPORT_CELL_DECIMAL_TYPE));
            rcRow.add(new ReportCell(ar.get('pbPrice'), REPORT_CELL_DECIMAL_TYPE));            
            rcRow.add(new ReportCell((Decimal)ar.get('distribution')*(Decimal)ar.get('pbPrice'), REPORT_CELL_DECIMAL_TYPE));
            Decimal shipped = (Decimal)sDocShipped.get((String)ar.get('sDoc') + (String)ar.get('bDoc'));
            if (shipped == null) shipped = 0;
            rcRow.add(new ReportCell(shipped, REPORT_CELL_DECIMAL_TYPE));            
            rcRow.add(new ReportCell(shipped*(Decimal)ar.get('pbPrice'), REPORT_CELL_DECIMAL_TYPE));            
            
            rcRow.add(new ReportCell('', REPORT_CELL_DECIMAL_TYPE));
            rcRow.add(new ReportCell('', REPORT_CELL_DECIMAL_TYPE));
            
            reportTable.add(rcRow);
        }
        rollupReportTable(1, new Integer[]{8,10,11,12}, new  SellaryPlanFromBuyerCalc());        
    }
    
    public class SellaryPlanFromBuyerCalc implements ReportCellCalculator{
        public void calculate(List<ReportCell> reportRow, List<ReportCell> summaryRow){
            //Planned profit (#4 - summ sell price, #10 - summ buy price )
            summaryRow[13].value = (Decimal)reportRow[4].value - (Decimal)summaryRow[10].value;
            summaryRow[13].type = REPORT_CELL_DECIMAL_TYPE;
            //Shipped profit (#3 - sell unit price, #11 - shipped summ, #12 - summ buy price for shipped volume )
            summaryRow[14].value = (Decimal)reportRow[3].value *(Decimal)summaryRow[11].value - (Decimal)summaryRow[12].value ;
            summaryRow[14].type = REPORT_CELL_DECIMAL_TYPE;           
        }
    }
    
    //------------------------------------------------------------------------------------------------
    //Interface for calculate special values in summary rows of report
    public Interface ReportCellCalculator{
        void calculate(List<ReportCell> reportRow, List<ReportCell> summaryRow);
    }
    
    //------------------------------------------------------------------------------------------------   
    //Culculate summery for group fields
    private void rollupReportTable(Integer rollupFieldsCount, List<Integer> summaryColNums, ReportCellCalculator calculator){
        List<Map<Integer,Decimal>> subTotals = new List<Map<Integer,Decimal>>();
        for(Integer j = 0; j < rollupFieldsCount; j++){
            Map<Integer, Decimal> colNumsForLevel = new Map<Integer, Decimal>();
            for(Integer k = 0; k < summaryColNums.size(); k++) colNumsForLevel.put(summaryColNums[k], 0);  
            subTotals.add(colNumsForLevel);
        } 
            
        List<List<ReportCell>> resList = new List<List<ReportCell>>();
        List<List<ReportCell>> summaryRows;
        List<ReportCell> rowForAdd = reportTable[0]; 
        for(Integer i = 0; i < reportTable.size(); i++){
            List<ReportCell> nextRowForAdd = new List<ReportCell>();
            resList.add(rowForAdd);
            Boolean isLastRow = (i == reportTable.size()-1); 
            List<ReportCell> currRow = reportTable[i];
            List<ReportCell> nextRow;
            if(!isLastRow) nextRow = reportTable[i+1];
            Boolean stillEqual = true;
            summaryRows = new List<List<ReportCell>>();
            for(Integer j = 0; j < currRow.size(); j++){
                stillEqual = !isLastRow && stillEqual && (currRow[j].value == nextRow[j].value && currRow[j].Id == nextRow[j].Id);
                ReportCell rc;
                if(!isLastRow) rc = nextRow[j].copy();
                if(j < rollupFieldsCount){
                    for(integer k : subTotals.get(j).keySet()){
                        Decimal sum = subTotals.get(j).get(k) + (Decimal)currRow[k].value;
                    	subTotals.get(j).put(k, sum);                      
                    }
                }
                if (stillEqual){
                	rc.value = '';
                }else{
                    if(j < rollupFieldsCount){
                        List<ReportCell> summaryRow = new List<ReportCell>();                        
                        for(Integer k = 0; k < currRow.size(); k++){
                            if(k < j){
                                summaryRow.add(new ReportCell('', 'String'));
                            }else if (k == j){
                                summaryRow.add(new ReportCell(currRow[j].value + ' Summary', REPORT_CELL_STRING_TYPE, true));                               
                            }else if (subTotals.get(j).keySet().contains(k)){
                            	summaryRow.add(new ReportCell(subTotals.get(j).get(k), REPORT_CELL_DECIMAL_TYPE, true));                                                                                                      
                            }else{
                                summaryRow.add(new ReportCell('', 'String', true));                                                               
                            }
                        }
                        if(calculator != null) calculator.calculate(currRow, summaryRow);
                        summaryRows.add(summaryRow); 
                        for(integer k : subTotals.get(j).keySet()){
                            subTotals.get(j).put(k, 0);                      
                        }
                    }
                }
                nextRowForAdd.add(rc);
            }
            rowForAdd = nextRowForAdd;
            //add summary
            for(Integer j = summaryRows.size()-1; j>=0; j--){
                resList.add(summaryRows[j]);
            }                               
        } 
        reportTable = resList;       
    }
        
    public Boolean getIsEmptyTable(){
        return reportTable.size() == 0;
    }
    
    public PageReference excel(){
        return new PageReference('/apex/LogisticReportsExcelPage');
    }
    
    public PageReference pdf(){
        return new PageReference('/apex/LogisticReportsPdfPage');       
    }

}