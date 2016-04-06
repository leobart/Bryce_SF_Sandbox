public with sharing class DeliveryPlanTable {
	
	//CSS classes for styling cells of table:
    public static final String HEADER_CLASS = 'dhCell';
    public static final String HEADER_COLUMN_CLASS = 'dhColumnCell';
    public static final String FULL_CELL_CLASS = 'dFullCell';
    public static final String FULL_CELL_FONT_CLASS = 'dCompletelyMovedFont';
    public static final String FOOTER_CLASS = 'dFooter';
    public static final String LOSS_CLASS = 'dLoss';
    public static final String LOSS_FONT_CLASS = 'dLossFont';
    public static final String DELIVERED_TRANSFER_CLASS = 'dDelivTransfer';
    public static final String DELIVERED_TRANSFER_FONT_CLASS = 'dDelivTransferFont';
    public static final String DISPATCHED_TRANSFER_CLASS = 'dDispTransfer';
    public static final String DISPATCHED_TRANSFER_FONT_CLASS = 'dTransferFont';
    public static final String DATA_CELL_CLASS = 'dCell';
    public static final String LOCATION_CELL_CLASS = 'dLocation';
    public static final String LOCATION_FONT_CLASS = 'dLocationFont';
    public static final String TOTALLY_HEADER_CLASS = 'dTHeader';
    public static final String TOTALLY_HEADER_FONT_CLASS = 'dTHeaderFont';
    public static final String DISABLE_FONT_CLASS = 'dDisableFont';
    public static final String DISABLE_CLASS = 'dDisable';
    
    //Table lables
    public static final String PLACE_LABEL = 'Place';
    public static final String BETWEEN_LABEL = 'Between';
    public static final String DIRECTION_LABEL = 'Direction';
    public static final String DISPATCHED_LABEL = 'Dispatched';
    public static final String DELIVERED_LABEL = 'Delivered';
    public static final String SUMMARY_LABEL = 'Summary';
    public static final String LOSS_LABEL = 'Loss';
    public static final String DELIVERED_TRANSFER_LABEL = 'Delivered transfer';
    public static final String DISPATCHED_TRANSFER_LABEL = 'Dispatched transfer';
    public static final String BALANCE_LABEL = 'Balance';
    public static final String TOTALLY_FOR_PLAN_LABEL = 'Totally for delivery plan';
    
    //Image sources
    public static final String IMG_BIG_RIGHT_ARROW = DeliveryPlanFilter.getResourceURL('big_right_arrow');
    public static final String IMG_UP_RIGHT_ARROW = DeliveryPlanFilter.getResourceURL('up_right_arrow');
    public static final String IMG_DOWN_RIGHT_ARROW = DeliveryPlanFilter.getResourceURL('down_right_arrow');
    
    //Table column size 
    public static final Double FIRST_COLUMN_WIDTH_FACTOR = 0.7;
    public static final Double BETWEEN_COLUMN_WIDTH_FACTOR = 0.5;
	
	
	public List<List<DeliveryPlanCell>> headerCells {get; set;}
    public List<List<DeliveryPlanCell>> bodyCells {get; set;}
    public List<List<DeliveryPlanCell>> footerCells {get; set;}
    public String name {get; set;}
    
    private DPTree dpTree;

	public DeliveryPlanTable(){
	}
    
    public void setColumnNumber(Integer colNumber){
        dpTree.buffer.columnNumber = colNumber;
    }
    
    public void setSortOrder(Boolean ascending){
        dpTree.buffer.sortAscending = ascending;
    }

    public DeliveryPlanTable(DPTree dpTree){
    	this.dpTree = dpTree;
    	headerCells = new List<List<DeliveryPlanCell>>();
    	bodyCells = new List<List<DeliveryPlanCell>>();
    	footerCells = new List<List<DeliveryPlanCell>>();
    }
    
    public DeliveryPlanFilter getFilter(){
    	return dpTree.getFilter();
    }
    
    public Route getRoute(){
    	return getFilter().route;    	
    }
    
    public void buildAllTable(DeliveryPlanFilter filter){
    	name = filter.deliveryPlan.Name + ' (' + filter.deliveryPlan.Cargo__r.Name + ')';
    	dpTree.setFilter(filter);
    	buildAllTable();
    }
    
    //Build table with reloaded tree
    public void buildAllTable(){
    	dpTree.reloadTree();
        buildTableWithoutReloadTree();
    }
    
    //Build table without reloading of tree
    public void buildTableWithoutReloadTree(){
    	updateBodyCells(dpTree.getRoot());
    	buildHeader();
    	buildFooter();
    }
    	
	// Create header cells of table
    public void buildHeader(){
        headerCells = new List<List<DeliveryPlanCell>>();
        //Calculate columns width
        //First column width factor:
        Double k1 = FIRST_COLUMN_WIDTH_FACTOR;
        //'Between' column width factor:
        Double k2 = BETWEEN_COLUMN_WIDTH_FACTOR;
        Integer a = getRoute().locationsCount() * 2 - 1;
        Integer b = getRoute().locationsCount() - 1;
        Double d1 = 100 / (k1 + a + k2 * b);
        Double d2 = k2 * d1;
        Long width1 = d1.round();
        Long width2 = d2.round();
        Long width3 = 100 - a * width1 - b * width2;
        //First row
        List<DeliveryPlanCell> row = new List<DeliveryPlanCell>();
        DeliveryPlanCell cell = new DeliveryPlanCell();
        cell.setValue(PLACE_LABEL);
        cell.setCssClass(HEADER_COLUMN_CLASS);
        row.add(cell);
        cell = new DeliveryPlanCell();
        cell.setValue(getRoute().getFirstLocation().Name);
        cell.setCssClass(LOCATION_CELL_CLASS);
        cell.setFontCssClass(LOCATION_FONT_CLASS);
        row.add(cell);
        for(String locationName : getRoute().getLocationNamesWithoutFirst()){
            cell = new DeliveryPlanCell();
            //cell.setValue(BETWEEN_LABEL);
            cell.imageSource = IMG_BIG_RIGHT_ARROW; 
            cell.setCssClass(HEADER_CLASS);
            cell.setWidth(width2 + '%');
            cell.setRowSpan(2 + dpTree.getRoot().getRowSpan());
            row.add(cell);
            cell = new DeliveryPlanCell();
            cell.setValue(locationName);
            cell.setCssClass(LOCATION_CELL_CLASS);
            cell.setFontCssClass(LOCATION_FONT_CLASS);
            cell.setColSpan(2);
            row.add(cell);                                  
        }  
        headerCells.add(row);
        //Second row
        row = new List<DeliveryPlanCell>();
        cell = new DeliveryPlanCell();
        cell.setValue(DIRECTION_LABEL);
        cell.setCssClass(HEADER_COLUMN_CLASS);
        cell.setWidth(width3 + '%');
        row.add(cell);  
        cell = new DeliveryPlanCell();
        cell.setValue(DISPATCHED_LABEL);
        cell.imageSource = IMG_UP_RIGHT_ARROW;
        cell.setCssClass(HEADER_CLASS);
        cell.setWidth(width1 + '%');
        Integer i = 0;
        cell.columnNumber = i;
        cell.selected = false;
        cell.setCheckable(true);
        row.add(cell); 
        for(String locationName : getRoute().getLocationNamesWithoutFirst()){
            i++;
            cell = new DeliveryPlanCell();
            cell.setValue(DELIVERED_LABEL);
            cell.imageSource = IMG_DOWN_RIGHT_ARROW;
            cell.setCssClass(HEADER_CLASS);
            cell.setWidth(width1 + '%');
            cell.columnNumber = i;
            cell.selected = false;
        	cell.setCheckable(true);
            row.add(cell);
            i++;
            cell = new DeliveryPlanCell();
            cell.setValue(DISPATCHED_LABEL);
            cell.imageSource = IMG_UP_RIGHT_ARROW;
            cell.setCssClass(HEADER_CLASS);
            cell.setWidth(width1 + '%');
            cell.columnNumber = i;
            cell.selected = false;
        	cell.setCheckable(true);
            row.add(cell); 
        }
        headerCells.add(row);
    }
	
    //Create footer cells of table
    public void buildFooter(){
        footerCells = new List<List<DeliveryPlanCell>>();
        totalForFilter();
        //totalForDP();
        
    }
    
    private void totalForFilter(){
    	if(dpTree.getRoot().getChilds().size()==0) return;
        List<DeliveryPlanCell> summaryRow = new List<DeliveryPlanCell>();
        List<DeliveryPlanCell> lossRow = new List<DeliveryPlanCell>();
        List<DeliveryPlanCell> deliverdTransferRow = new List<DeliveryPlanCell>();
        List<DeliveryPlanCell> dispatchedTransferRow = new List<DeliveryPlanCell>();
        List<DeliveryPlanCell> balanceRow = new List<DeliveryPlanCell>();
        //Init first column cells for all rows:
        DeliveryPlanCell cell = new DeliveryPlanCell();
        cell.setValue(SUMMARY_LABEL);
        cell.setCssClass(HEADER_COLUMN_CLASS);
        summaryRow.add(cell);
        cell = new DeliveryPlanCell();
        cell.setValue(LOSS_LABEL);
        cell.setCssClass(HEADER_COLUMN_CLASS);
        lossRow.add(cell);
        cell = new DeliveryPlanCell();
        cell.setValue(DELIVERED_TRANSFER_LABEL);
        cell.setCssClass(HEADER_COLUMN_CLASS);
        deliverdTransferRow.add(cell);
        cell = new DeliveryPlanCell();
        cell.setValue(DISPATCHED_TRANSFER_LABEL);
        cell.setCssClass(HEADER_COLUMN_CLASS);
        dispatchedTransferRow.add(cell);
        cell = new DeliveryPlanCell();
        cell.setValue(BALANCE_LABEL);
        cell.setCssClass(HEADER_COLUMN_CLASS);
        balanceRow.add(cell);
        //Create column for first location:
        Double prevDispValume = dpTree.getRoot().getAmounts()[0];
        cell = new DeliveryPlanCell();
        cell.setValue(prevDispValume.format());
        cell.setCssClass(FOOTER_CLASS);
        summaryRow.add(cell);
        cell = new DeliveryPlanCell();
        cell.setValue('-');
        cell.setCssClass(FOOTER_CLASS);
        lossRow.add(cell);
        deliverdTransferRow.add(cell);
        dispatchedTransferRow.add(cell);
        balanceRow.add(cell);
        //Create columns for each locaion without first
        Boolean isFirst = true;
        Integer j = dpTree.buffer.columnNumber; 
        Integer k = j;
        if(j/2*2 == j && j != 0) j = j-1;
        for(Integer i = 1; i < dpTree.getRoot().getAmounts().size(); i+=2){
            Double deliveredVolume = dpTree.getRoot().getAmounts()[i];
            Double dispatchedVolume = dpTree.getRoot().getAmounts()[i+1];
            Double lossDelivered = dpTree.getRoot().getLosses()[i+1];
            Double lossDispatched = dpTree.getRoot().getLosses()[i];
            Double deliveredTransfer = dpTree.getRoot().delivTransfers[i];
            Double dispatchedTransfer = dpTree.getRoot().getTransfers()[i+1];
            
            Double balanceInLocation = deliveredVolume - dispatchedVolume + deliveredTransfer - dispatchedTransfer - lossDelivered;
            Double balanceBetween = prevDispValume - deliveredVolume - lossDispatched;
            prevDispValume = dispatchedVolume;
            
            //Summary row cells:
            //cell = new DeliveryPlanCell();
            //cell.setValue('-'); // Between value
            //cell.setCssClass(HEADER_CLASS);
            //summaryRow.add(cell);
            //cell = new DeliveryPlanCell();
            //cell.setValue(deliveredVolume.format());
            //cell.setCssClass(FOOTER_CLASS);
            //summaryRow.add(cell);
            //cell = new DeliveryPlanCell();
            //cell.setValue(dispatchedVolume.format());
            //cell.setCssClass(FOOTER_CLASS);
            //summaryRow.add(cell);
            
            //Loss row cells:
            //cell = new DeliveryPlanCell();
            //cell.setValue(lossDispatched.format());
            //cell.setCssClass(HEADER_CLASS);
            //lossRow.add(cell);
            //cell = new DeliveryPlanCell();
            //cell.setValue(lossDelivered.format());
            //cell.setColSpan(2);
            //cell.setCssClass(FOOTER_CLASS);
            //lossRow.add(cell);
                
            //Delivered Transfer row cells:
            /*cell = new DeliveryPlanCell();
            cell.setValue('-');
            cell.setCssClass(HEADER_CLASS);
            deliverdTransferRow.add(cell);
            cell = new DeliveryPlanCell();
            cell.setValue(deliveredTransfer.format());
            cell.setColSpan(2);
            cell.setCssClass(FOOTER_CLASS);
            deliverdTransferRow.add(cell);*/
            
            //Dispatched Transfer row cells:
            /*cell = new DeliveryPlanCell();
            cell.setValue('-');
            cell.setCssClass(HEADER_CLASS);
            dispatchedTransferRow.add(cell);
            cell = new DeliveryPlanCell();
            cell.setValue(dispatchedTransfer.format());
            cell.setColSpan(2);
            cell.setCssClass(FOOTER_CLASS);
            dispatchedTransferRow.add(cell);*/
            
            //Balance row cells:
            
            if(i < j){
                cell = new DeliveryPlanCell();
                cell.setValue('');
                cell.setCssClass(HEADER_CLASS);
                balanceRow.add(cell);
            	cell = new DeliveryPlanCell();
            	cell.setValue('');
            	cell.setColSpan(2);
            	cell.setCssClass(FOOTER_CLASS);
                balanceRow.add(cell);
            }else if(i == j){
                cell = new DeliveryPlanCell();
                cell.setValue('');
                cell.setCssClass(HEADER_CLASS);
                balanceRow.add(cell);
                if(k/2*2!=k || k==0){
                    cell = new DeliveryPlanCell();
                    cell.setValue(balanceInLocation.format());
                    cell.setColSpan(2);
                    cell.setCssClass(FOOTER_CLASS);
                    balanceRow.add(cell);          
                }else{
                    cell = new DeliveryPlanCell();
                    cell.setValue('');
                    cell.setColSpan(2);
                    cell.setCssClass(FOOTER_CLASS);
                    balanceRow.add(cell);          
                }
            }else{
                cell = new DeliveryPlanCell();
                cell.setValue(balanceBetween.format());
                cell.setCssClass(HEADER_CLASS);
                balanceRow.add(cell);
                cell = new DeliveryPlanCell();
                cell.setValue(balanceInLocation.format());
                cell.setColSpan(2);
                cell.setCssClass(FOOTER_CLASS);
                balanceRow.add(cell);          
            }
        }
        //footerCells.add(summaryRow);
        //footerCells.add(lossRow);
        //footerCells.add(deliverdTransferRow);
        //footerCells.add(dispatchedTransferRow);
        footerCells.add(balanceRow);
    	
    }
    
    private void totalForDP(){
    	List<DeliveryPlanCell> totalLRow = new List<DeliveryPlanCell>();
        List<DeliveryPlanCell> summaryRow = new List<DeliveryPlanCell>();
        List<DeliveryPlanCell> lossRow = new List<DeliveryPlanCell>();
        List<DeliveryPlanCell> deliverdTransferRow = new List<DeliveryPlanCell>();
        List<DeliveryPlanCell> dispatchedTransferRow = new List<DeliveryPlanCell>();
        List<DeliveryPlanCell> balanceRow = new List<DeliveryPlanCell>();
        //Init first column cells for all rows:
        DeliveryPlanCell cell = new DeliveryPlanCell();
        cell.setValue(SUMMARY_LABEL);
        cell.setCssClass(HEADER_COLUMN_CLASS);
        summaryRow.add(cell);
        cell = new DeliveryPlanCell();
        cell.setValue(LOSS_LABEL);
        cell.setCssClass(HEADER_COLUMN_CLASS);
        lossRow.add(cell);
        cell = new DeliveryPlanCell();
        cell.setValue(DELIVERED_TRANSFER_LABEL);
        cell.setCssClass(HEADER_COLUMN_CLASS);
        deliverdTransferRow.add(cell);
        cell = new DeliveryPlanCell();
        cell.setValue(DISPATCHED_TRANSFER_LABEL);
        cell.setCssClass(HEADER_COLUMN_CLASS);
        dispatchedTransferRow.add(cell);
        cell = new DeliveryPlanCell();
        cell.setValue(BALANCE_LABEL);
        cell.setCssClass(HEADER_COLUMN_CLASS);
        balanceRow.add(cell);
        //Create column for first location:
        Double prevDispValume = getFilter().getAmountForFirstLocation();
        cell = new DeliveryPlanCell();
        cell.setValue(prevDispValume.format());
        cell.setCssClass(FOOTER_CLASS);
        summaryRow.add(cell);
        cell = new DeliveryPlanCell();
        cell.setValue('-');
        cell.setCssClass(FOOTER_CLASS);
        lossRow.add(cell);
        deliverdTransferRow.add(cell);
        dispatchedTransferRow.add(cell);
        balanceRow.add(cell);
        //Create columns for each locaion without first
        Boolean isFirst = true;
        for(Location__c location : getRoute().getLocations()){
            if (isFirst){
                isFirst = false;
                continue;
            }
            Double deliveredVolume = getFilter().getAmountForLocation(location.Id, DeliveryPlanFilter.DELIVERED_TYPE);
            Double dispatchedVolume = getFilter().getAmountForLocation(location.Id, DeliveryPlanFilter.DISPATCHED_TYPE);
            Double lossDelivered = getFilter().getLossForLocation(location.Id, DeliveryPlanFilter.DELIVERED_TYPE);
            Double lossDispatched = getFilter().getLossForLocation(location.Id, DeliveryPlanFilter.DISPATCHED_TYPE);
            Double deliveredTransfer = getFilter().getAmountForLocation(location.Id, DeliveryPlanFilter.DELIVERED_TRANSFER_TYPE);
            Double dispatchedTransfer = getFilter().getAmountForLocation(location.Id, DeliveryPlanFilter.DISPATCHED_TRANSFER_TYPE);
            
            Double balanceInLocation = deliveredVolume - dispatchedVolume + deliveredTransfer - dispatchedTransfer - lossDelivered;
            Double balanceBetween = prevDispValume - deliveredVolume - lossDispatched;
            prevDispValume = dispatchedVolume;
            
            //Summary row cells:
            cell = new DeliveryPlanCell();
            cell.setValue('-'); // Between value
            cell.setCssClass(FOOTER_CLASS);
            summaryRow.add(cell);
            cell = new DeliveryPlanCell();
            cell.setValue(deliveredVolume.format());
            cell.setCssClass(FOOTER_CLASS);
            summaryRow.add(cell);
            cell = new DeliveryPlanCell();
            cell.setValue(dispatchedVolume.format());
            cell.setCssClass(FOOTER_CLASS);
            summaryRow.add(cell);
            
            //Loss row cells:
            cell = new DeliveryPlanCell();
            cell.setValue(lossDispatched.format());
            cell.setCssClass(FOOTER_CLASS);
            lossRow.add(cell);
            cell = new DeliveryPlanCell();
            cell.setValue(lossDelivered.format());
            cell.setColSpan(2);
            cell.setCssClass(FOOTER_CLASS);
            lossRow.add(cell);
                
            //Delivered Transfer row cells:
            cell = new DeliveryPlanCell();
            cell.setValue('-');
            cell.setCssClass(FOOTER_CLASS);
            deliverdTransferRow.add(cell);
            cell = new DeliveryPlanCell();
            cell.setValue(deliveredTransfer.format());
            cell.setColSpan(2);
            cell.setCssClass(FOOTER_CLASS);
            deliverdTransferRow.add(cell);
            
            //Dispatched Transfer row cells:
            cell = new DeliveryPlanCell();
            cell.setValue('-');
            cell.setCssClass(FOOTER_CLASS);
            dispatchedTransferRow.add(cell);
            cell = new DeliveryPlanCell();
            cell.setValue(dispatchedTransfer.format());
            cell.setColSpan(2);
            cell.setCssClass(FOOTER_CLASS);
            dispatchedTransferRow.add(cell);
            
            //Balance row cells:
            cell = new DeliveryPlanCell();
            cell.setValue(balanceBetween.format());
            cell.setCssClass(FOOTER_CLASS);
            balanceRow.add(cell);
            cell = new DeliveryPlanCell();
            cell.setValue(balanceInLocation.format());
            cell.setColSpan(2);
            cell.setCssClass(FOOTER_CLASS);
            balanceRow.add(cell);          
        }
        cell = new DeliveryPlanCell();
        cell.setColSpan(getRoute().locationsCount() * 2 -1 + getRoute().locationsCount());
        cell.setValue(TOTALLY_FOR_PLAN_LABEL);
        cell.setCssClass(TOTALLY_HEADER_CLASS);
        cell.setFontCssClass(TOTALLY_HEADER_FONT_CLASS);
        totalLRow.add(cell);
        footerCells.add(totalLRow);
        footerCells.add(summaryRow);
        footerCells.add(lossRow);
        footerCells.add(deliverdTransferRow);
        footerCells.add(dispatchedTransferRow);
        footerCells.add(balanceRow);    	
    }
    
    public void updateBodyCells(DPTreeItem root){
        bodyCells = new List<List<DeliveryPlanCell>>();
        List<DeliveryPlanCell> row = new List<DeliveryPlanCell>();
        buildBodyCellsFromTree(bodyCells, row, root);
        //insertColumns(bodyCells, root);       
    }
    

    //Crete data cells from hierarchy of Movements (recursive method)
    private void buildBodyCellsFromTree(List<List<DeliveryPlanCell>> tableValues, List<DeliveryPlanCell> row, DPTreeItem tree){
        DeliveryPlanCell cell, cell2;
        cell = new DeliveryPlanCell();
        cell.setRowSpan(1);
        cell.setCollapsible(true);
        cell.setId(tree.getId());
        cell.setTreeItem(tree);
        cell.setBalance(tree.getBalance());
        if (tree.getMovement() != null){
            cell.setValue(tree.getMovement().Quantity__c.format());
            cell.setMDate(tree.getMovement().Date__c.format());
            cell.setCssClass(DATA_CELL_CLASS);
            cell.setMovementId(tree.getMovement().Id);
            cell.setCheckable(true); 
            
            if(tree.getMovement().Type__c == DeliveryPlanFilter.LOSS_TYPE){
                cell.setCssClass(LOSS_CLASS);
                cell.setCollapsible(false);
                cell.setCheckable(true);
                cell.setFontCssClass(LOSS_FONT_CLASS);
            }else if (tree.getMovement().Type__c == DeliveryPlanFilter.DELIVERED_TYPE || tree.getMovement().Type__c == DeliveryPlanFilter.DISPATCHED_TYPE){
                cell.setCheckable(true);
            }else if (tree.getMovement().Type__c == DeliveryPlanFilter.DISPATCHED_TRANSFER_TYPE){
                cell.setCssClass(DISPATCHED_TRANSFER_CLASS);
                cell.setFontCssClass(DISPATCHED_TRANSFER_FONT_CLASS);
                cell.setCheckable(true); 
            }else if (tree.getMovement().Type__c == DeliveryPlanFilter.DELIVERED_TRANSFER_TYPE){
                cell.setCssClass(DELIVERED_TRANSFER_CLASS);
                cell.setFontCssClass(DELIVERED_TRANSFER_FONT_CLASS);
                cell.setCheckable(true);                 
            }
            if (tree.getMovement().Balance__c == 0 || (tree.getMovement().Type__c == DeliveryPlanFilter.DISPATCHED_TYPE && getRoute().isLast(tree.getMovement().Location__r.Id))){
                cell.setCssClass(FULL_CELL_CLASS);
                cell.setFontCssClass(FULL_CELL_FONT_CLASS);
            }
            if(tree.disable){
                cell.setCheckable(false);
                cell.setCssClass(DISABLE_CLASS);
                cell.setFontCssClass(DISABLE_FONT_CLASS);
            }
        } else {
            cell.setCheckable(false); 
            cell.setValue(tree.value);
            //Root cell
            if(tree.isRoot){
                cell.setCssClass(HEADER_COLUMN_CLASS);                                
            }else{
                cell.setCssClass(DISABLE_CLASS);
                cell.setFontCssClass(DISABLE_FONT_CLASS);
            }
        }
        if(tree.getChilds().size() <= 1) cell.setCollapsible(false);
        row.add(cell); 
        //if cell not opened then use aggregated values
        if(!tree.state.opened){
            tree.setRowSpan(1);
            for (Integer i = 0; i < tree.getAmounts().size(); i++){
                cell2 = new DeliveryPlanCell();
                cell2.setRowSpan(1);
                String v = '';
                String l = '';
                String t = '';
                String dt = '';
                if (tree.getAmounts()[i] != 0) v = tree.getAmounts()[i].format();
                if (tree.getLosses()[i] != 0) l = tree.getLosses()[i].format();
                if (tree.getTransfers()[i] != 0) t = tree.getTransfers()[i].format();
                if (tree.delivTransfers[i] != 0) dt = tree.delivTransfers[i].format();
                //Hide aggregated values if cell column < sorted column
                if(tree.level+i+1 < dpTree.buffer.columnNumber && tree.isRoot){
                    cell2.setValue('');
                    cell2.setLoss('');
                    cell2.setTransfer('');
                    cell2.setCssClass(DISABLE_CLASS);
                }else{
                    cell2.setValue(v);
                    cell2.setLoss(l);
                    cell2.setTransfer(t);
                    cell2.delivTransfer = dt;
                    cell2.setCssClass(DATA_CELL_CLASS);
                }                
                cell2.setCollapsible(false);
                cell2.setCheckable(false); 
                row.add(cell2);                         
            }
            tableValues.add(row);
            system.debug('Data table row size: ' + row.size());
            row = new List<DeliveryPlanCell>();                               
        }else{
            //if cell opened scan hierarchy
            if (tree.getChilds().size() == 0){
                //Use agregated ziro fol fill cells
                for (Double amt : tree.getAmounts()){
                    cell2 = new DeliveryPlanCell();
                    cell2.setRowSpan(1);
                    cell2.setValue('');
                    cell2.setCollapsible(false);
                    if(tree.getMovement().Type__c == DeliveryPlanFilter.LOSS_TYPE){
                        cell2.setCssClass(LOSS_CLASS);
                    }else if(tree.getMovement().Type__c == DeliveryPlanFilter.DISPATCHED_TRANSFER_TYPE){
                        cell2.setCssClass(DISPATCHED_TRANSFER_CLASS);                                   
                    }
                    row.add(cell2);
                }
                tableValues.add(row);
                row = new List<DeliveryPlanCell>();               
                    
            }
            tree.setRowSpan(0);
            String q='null';
            if(tree.getMovement() != null) q = tree.getMovement().Quantity__c + '';
            for(DPTreeItem treeItem : tree.getChilds()){
                //Recurrency enter:
                buildBodyCellsFromTree(tableValues, row, treeItem);
                if (treeItem.state.opened){
                        tree.setRowSpan(tree.getRowSpan() + treeItem.getRowSpan()); 
                } else {
                        tree.setRowSpan(tree.getRowSpan() + 1); 
                }                       
                row = new List<DeliveryPlanCell>(); 
                if (tree.getMovement() != null && tree.getMovement().Type__c == DeliveryPlanFilter.DISPATCHED_TYPE && getRoute().isLast(tree.getMovement().Location__r.Id)){
                            tableValues.add(row);
                            row = new List<DeliveryPlanCell>();           
                        
                }
            } 
            if (tree.getRowSpan() == 0) tree.setRowSpan(1);  
            cell.setRowSpan(tree.getRowSpan());             
        }       
    }
    
    //Insert "between" columns:
    // not used for remove
    private void insertColumns(List<List<DeliveryPlanCell>> tableValues, DPTreeItem tree){
        DeliveryPlanCell cell;
        if(tableValues.size() == 0) return;
        if(tableValues.get(0).size() == 1){
            for(Integer i = 0; i < getRoute().locationsCount() * 2 - 1; i++){
                cell = new DeliveryPlanCell();
                cell.setCssClass(DATA_CELL_CLASS);
                tableValues.get(0).add(cell);
            }
                
        }
        List<DeliveryPlanCell> firstRow = new List<DeliveryPlanCell>(); 
        firstRow.add(tableValues[0].get(0));
        firstRow.add(tableValues[0].get(1));
        for(Integer i=2; i<tableValues[0].size(); i+=2 ){
            cell = new DeliveryPlanCell();
            cell.setRowSpan(tree.getRowSpan());
            cell.setValue('');
            cell.imageSource = IMG_BIG_RIGHT_ARROW;
            cell.setCollapsible(false);
            cell.setCssClass(DATA_CELL_CLASS);
            firstRow.add(cell);
            firstRow.add(tableValues[0].get(i));
            firstRow.add(tableValues[0].get(i+1));
        }
        tableValues[0] = firstRow;
        //For debug:
        /*for (List<DeliveryPlanCell> row : tableValues){
            String s = '';
            for(DeliveryPlanCell dpc : row){
                    s = s + ' ' + dpc.getValue()+'/'+dpc.getRowSpan(); 
            }
            system.debug('Result row: ' + s);
        } */      
    }
    
    //Not used for remove:
    public void selectColumn(Integer columnNumber, Boolean selected){
        //system.debug('COL NUMBER: ' + columnNumber + ' val: ' + selected);
        for(List<DeliveryPlanCell> row : bodyCells){
            for(DeliveryPlanCell cell : row){
                if(cell.getTreeItem()!= null && 
                   cell.getTreeItem().getMovement()!= null && 
                   dpTree.getFilter().route.isMovementInColumn(cell.getTreeItem().getMovement(), columnNumber)){
                	cell.getTreeItem().state.selected = selected;
                }
            }
        }
    }


}