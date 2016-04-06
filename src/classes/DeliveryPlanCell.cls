public with sharing class DeliveryPlanCell {
		
	private Integer rowSpan = 1;
	private Integer colSpan = 1;
	private String value;
	private String loss;
	private String transfer;
    public String delivTransfer {get; set;}
	private String mDate;
	private String movementId;
	private Integer id;
	private String width;
	private String cssClass;
	private String fontCssClass;
	private Boolean checkable = false;
	private Boolean collapsible = false;
	private DPTreeItem treeItem;
	private String balance = '';
    public Integer columnNumber{get; set;}
    public Boolean selected {get; set;}
    public String imageSource {get; set;}
	
	public DeliveryPlanCell(){
		//by default:
		cssClass = DeliveryPlanTable.DATA_CELL_CLASS;
        selected = false;
	}
	
	public Integer getRowSpan(){
		return this.rowSpan;
	}
	
	public void setRowSpan(Integer rowSpan){
		this.rowSpan = rowSpan;
	}
	
	public Integer getColSpan(){
		return colSpan;
	}
	
	public void setColSpan(Integer colSpan){
		this.colSpan = colSpan;
	}
	
	public String getValue(){
		return this.value;
	}
	
	public void setValue(String value){
		this.value = value;
	}
	
	public String getLoss(){
		return this.loss;
	}
	
	public void setLoss(String loss){
		this.loss = loss;
	}
	
	public String getTransfer(){
		return this.transfer;
	}
	
	public void setTransfer(String transfer){
		this.transfer = transfer;
	}
	
	public String getMDate(){
		return this.mDate;
	}
	
	public void setMDate(String mDate){
		this.mDate = mDate;
	}
	
	public void setCssClass(String cssClass){
		this.cssClass = cssClass;
	}
	
	public String getCssClass(){
		return this.cssClass;
	}
	
	public void setMovementId(String movementId){
		this.movementId = movementId;
	}
	
	public String getMovementId(){
		return this.movementId;
	}
	
	public void setCheckable(Boolean checkable){
		this.checkable = checkable;
	}
	
	public Boolean getCheckable(){
		return checkable;
	}
	
	public Boolean getCollapsible(){
		return collapsible;
	}
	
	public void setCollapsible(Boolean collapsible){
		this.collapsible = collapsible;
	}
	
	public void setId(Integer id){
		this.id = id;
	}
	
	public Integer getId(){
		return id;
	}
	
	public void setFontCssClass(String cssClass){
		this.fontCssClass = cssClass;
	}
	
	public void setWidth(String width){
		this.width = width;
	}
	
	public String getFontCssClass(){
		return fontCssClass;
	}
	
	public String getWidth(){
		return width;
	}
	
	public DPTreeItem getTreeItem(){
		return treeItem;
	}
	
	public void setTreeItem(DPTreeItem treeItem){
		this.treeItem = treeItem;
	}
	
	public void setBalance(Double balance){
		if(balance != 0) this.balance = balance.format();
	}
	
	public String getBalance(){
        if(treeItem!= null && treeItem.getMovement() != null) return treeItem.getMovement().Balance__c.format();
		return '';
	}
	
	public Boolean getShowBalance(){
		return treeItem!= null && treeItem.state.opened && treeItem.getMovement() != null && 
		        treeItem.getMovement().Balance__c!= treeItem.getMovement().Quantity__c &&
		        treeItem.getMovement().Balance__c!= 0;
	}
	
	

}