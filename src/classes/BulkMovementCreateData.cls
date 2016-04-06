public class BulkMovementCreateData{

    public List<SelectOption> buyDocuments {get; set;}
    public String buyDocId {get; set;}
	public List<SelectOption> sellDocuments {get; set;}
    public String sellDocId {get; set;}
    
    public static final List<SelectOption> columnTypeSOStatic = new List<SelectOption>();
    public static final String MOVEMENT_VOLUME = 'Movement Volume';
    public static final String MOVEMENT_DATE = 'Movement Date';
    public static final String MOVEMENT_DOC = 'Movement Doc';
    public static final List<String> parseTypesStatic = new List<String> {MOVEMENT_VOLUME, MOVEMENT_DATE, MOVEMENT_DOC};
    static {
    	columnTypeSOStatic.add(new Selectoption(MOVEMENT_VOLUME, MOVEMENT_VOLUME));
    	columnTypeSOStatic.add(new Selectoption(MOVEMENT_DATE, MOVEMENT_DATE));
    	columnTypeSOStatic.add(new Selectoption(MOVEMENT_DOC, MOVEMENT_DOC));
    }
    
    public static final List<SelectOption> movementDocTypeSOStatic = new List<SelectOption>();
    // variables here depends on Movement_Document__c.Type field
    public static final String MD_TYPE_BL = 'BL';
    public static final String MD_TYPE_RWB = 'RWB';
    public static final String MD_TYPE_TN_ACT = 'TN Act';
    public static final String MD_TYPE_TN_TELEGRAMM = 'TN Telegram';
    public static final List<String> deliveryDocTypesStatic = new List<String> {MD_TYPE_TN_ACT, MD_TYPE_TN_TELEGRAMM, MD_TYPE_BL, MD_TYPE_RWB};
    static {
    	movementDocTypeSOStatic.add(new Selectoption(MD_TYPE_TN_ACT, MD_TYPE_TN_ACT));
    	movementDocTypeSOStatic.add(new Selectoption(MD_TYPE_TN_TELEGRAMM, MD_TYPE_TN_TELEGRAMM));
    	movementDocTypeSOStatic.add(new Selectoption(MD_TYPE_BL, MD_TYPE_BL));
    	movementDocTypeSOStatic.add(new Selectoption(MD_TYPE_RWB, MD_TYPE_RWB));
    }
    
    public List<SelectOption> columnTypeSO {get; set;}
    public List<SelectOption> movementDocTypeSO {get; set;}
    
    public Integer deleteParseParamNumber {get; set;}
    
    public class ColumnParseData{
        public String colType {get; set;}
        public String addType {get; set;}
        public boolean isDocCol {get; set;}
        public ColumnParseData(String colType, String addType){
            this.colType = colType;
            this.addType = addType;
            this.isDocCol = true;
        }
        public ColumnParseData(String colType){
            this.colType = colType;
            this.isDocCol = false;
        }
        
        public String getHeader(){
            if(this.addType == null){
                return this.colType;
            }
            return this.colType + ' (' + this.addType + ')';
        }
    }
    
    public class LineImportData{
        public Movement__c movement;
        public list<Movement_Document__c> documents; 
        
        public LineImportData(Decimal volume, Date vDate, List<List<String>> documents, String buyDocId, String sellDocId, DeliveryPlanFilter filter){
            movement = new Movement__c(Date__c = vDate, 
                                       Quantity__c = volume, 
                                       Buy_Document__C = buyDocId, 
                                       Delivery_Plan__c = filter.deliveryPlanId,
                                       Location__c = filter.route.getFirstLocation().Id, 
                                       Type__c = DeliveryPlanFilter.DISPATCHED_TYPE, 
                                       Moved__c = 0,
                                       State__c='First'); 
            if(sellDocId!='none') movement.Sell_Document__c=sellDocId;
            this.documents = new list<Movement_Document__c>();
            for(List<String> docParam : documents){
                this.documents.add(new Movement_Document__c(Type__c=docParam[0], Document_ID__c=docParam[1]));
            }
        }
    }
        
    public List<LineImportData> importLines;
    public List<List<String>> parsedTable {get; set;}
    
    public List<ColumnParseData> parseParams {get; set;}    
    public String inputData {get; set;}
    private DeliveryPlanFilter filter;
    
    public BulkMovementCreateData(DeliveryPlanFilter filter){
        this.filter = filter;
		this.buyDocuments = filter.getSelectedBuyDocsSO();
		this.sellDocuments = filter.getSelectedSellDocsSOWithNone(); 
        columnTypeSO = columnTypeSOStatic;
        movementDocTypeSO = movementDocTypeSOStatic;
        parseParams = new List<ColumnParseData>();
        parseParams.add(new ColumnParseData(MOVEMENT_VOLUME));
        parseParams.add(new ColumnParseData(MOVEMENT_DATE));
    }
        
    public void deleteParseColumn(){
        List<ColumnParseData> pParams = new List<ColumnParseData>(); 
        Integer i=0;
        for(ColumnParseData cpd : parseParams){
            if(i != deleteParseParamNumber){
                pParams.add(cpd);
            }
            i++;
        }
        parseParams = pParams;
    }
    
    public void addParseParam(){
        ColumnParseData newParseData = null;
        String parseTypeForAdd = null;
        for(String parseType : parseTypesStatic){
            boolean isNotFound = true;
            for(ColumnParseData cpd : parseParams){
                isNotFound = (cpd.colType != parseType)&&isNotFound;
            }
            if(isNotFound ) {
                parseTypeForAdd = parseType;
                break;
            }
        }
        if(parseTypeForAdd == null) parseTypeForAdd = MOVEMENT_DOC;
        String docTypeForAdd = null;
        if(parseTypeForAdd == MOVEMENT_DOC){
            for(String dType : deliveryDocTypesStatic){
                boolean isNotFound = true;
                for(ColumnParseData cpd : parseParams){
                    isNotFound = (cpd.addType != dType) && isNotFound;
                }
                if (isNotFound) {
                    docTypeForAdd = dType;
                    break;
                }
            }
            if(docTypeForAdd != null) newParseData = new ColumnParseData(parseTypeForAdd, docTypeForAdd);
        }else{
            newParseData = new ColumnParseData(parseTypeForAdd);
        }
        If (newParseData != null) parseParams.add(newParseData);       
    }
    
    public void removeDublicatesFromParseParams(){
        List<ColumnParseData> resultParseParams = new List<ColumnParseData>();
        for(ColumnParseData cpd : parseParams){
            if(cpd.colType == MOVEMENT_DOC){
                cpd.isDocCol = true;
                if (cpd.addType == null) cpd.addType = deliveryDocTypesStatic[0];
            }else{
                cpd.isDocCol = false;
                cpd.addType = null;
            } 
            Boolean isDublicate = false;
            for(ColumnParseData rcpd : resultParseParams){
                if(rcpd.colType == cpd.colType && rcpd.addType == cpd.addType){
                    isDublicate = true;
                    break;
                }
            }
            if(!isDublicate){
                resultParseParams.add(cpd);
            }
        }
        parseParams = resultParseParams;
    }
    
    public boolean parseMovementsAndDocsForBulkCreation(){
        importLines = new List<LineImportData>();
        parsedTable = new List<List<String>>();
        if(inputData.length() == 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'No Data for import. Copy data into text area'));
            return false;
        }
        String[] lines = inputData.split('\r\n');
        Integer i = 0;
        for(String line : lines){
        	system.debug('LINE: ' + line);
            String[] fields = line.split('\\s+');
            if(parseParams.size() != fields.size()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Not consistency data. Count of parse parameters: ' + parseParams.size()
                                                           + '. Count of columns: ' + fields.size() +'. Line number: ' + i));
                return false;
            }            
            Decimal volume;
            Date vDate;
            List<List<String>> deliveryDocs = new List<List<String>>();
            List<String> parsedTableLine = new List<String>();
            for(Integer j=0; j<parseParams.size(); j++){
                String fieldType = parseParams[j].colType;
                String fieldValue;
                if(fieldType == MOVEMENT_VOLUME){
                    try{
	                    volume = Decimal.valueOf(fields[j].replace(',','.'));  
                        fieldValue = volume.format();
                    }catch(Exception e){
                        ApexPages.addMessages(e);
                        return false;
                    }
                } else if (fieldType == MOVEMENT_DATE){
                    try{
                        vDate = getDate(fields[j]);
                        fieldValue = vDate.format();
                    }catch(Exception e){
                        ApexPages.addMessages(e);
                        return false;
                    }                    
                } else {
                    List<String> deliveryDoc = new List<String> {parseParams[j].addType, fields[j]};
				    fieldValue = fields[j];                      
                    deliveryDocs.add(deliveryDoc);    
                }
                parsedTableLine.add(fieldValue);
            }
            if(volume == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Volume not defined!'));
                return false;
            }
            if(vDate == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Date not defined!'));
                return false;
            }
			i++;
            parsedTable.add(parsedTableLine);
            importLines.add(new LineImportData(volume, vDate, deliveryDocs, buyDocId, sellDocId, filter));
        }
        return true;
    }
        
    //no one way to convert date in different locale, so write method for converting date string in format dd.mm.yyyy to Date
    private Date getDate(String strDate){
        system.debug('DATE STR: ' + strDate);
        List<String> dateParts = strDate.split('\\.');
        system.debug('DATE: ' + dateParts);
        if(dateParts.size() != 3){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Problem with date format: ' + strDate));
            return null;
        }
        Integer d = Integer.valueOf(dateParts[0]);
		Integer m = Integer.valueOf(dateParts[1]);
		Integer y = Integer.valueOf(dateParts[2]);
		return Date.newInstance(y,m,d);       
    }

    
    public boolean getIsMaxParams(){
        return parseParams.size() == parseTypesStatic.size() - 1 + deliveryDocTypesStatic.size(); 
    }

}