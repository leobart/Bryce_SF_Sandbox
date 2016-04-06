public with sharing class DPTreeItem {
		
	private Movement__c movement;
	private DPTreeItem parent;
	private List<DPTreeItem> childs = new List<DPTreeItem>();
	private List<Double> amounts = new List<Double>();
	private List<Double> losses = new List<Double>();
	private List<Double> transfers = new List<Double>();
    public List<Double> delivTransfers {get; set;}
	private Integer rowSpan = 0;
	private Integer id;
	//private Boolean selected = false;
	private Double balance = 0;
    public boolean disable {get; set;}	// indicate that item on the left from sort column
	public DPCState state {get; set;}
    public String value {get; set;}  // if movement == null uses this field for output value;
    public Boolean isRoot;
    public Integer level {get; set;}
    public Boolean isTransfer {get; set;} // indicate tрфе this item branch for transfered movement from another plan
	
	
    public DPTreeItem(){
        disable = false;
        isRoot = false;
        isTransfer = false;
        delivTransfers = new List<Double>();
    }
    
	public void setParent(DPTreeItem parent){
		this.parent = parent;
		
	}
	
	public DPTreeItem getParent(){
		return this.parent;
	}
	
	public void addChild(DPTreeItem child){
		this.childs.add(child);
	}
	
	public void setMovement(Movement__c movement){
		this.movement = movement;
	}
	
	public Movement__c getMovement(){
		return movement;
	}
	
	public List<DPTreeItem> getChilds(){
		return childs;
	}
    
    public void setChilds(List<DPTreeItem> childsList){
        childs = childsList;
    }
	
	public List<Double> getAmounts(){
		return amounts;
	}
	
	public void setAmounts(List<Double> amounts){
		this.amounts = amounts;
	}
	
	public List<Double> getLosses(){
		return losses;
	}
	
	public void setLosses(List<Double> losses){
		this.losses = losses;
	}
	
	public List<Double> getTransfers(){
		return transfers;
	}
	
	public void setTransfers(List<Double> transfers){
		this.transfers = transfers;
	}
	
	public void setRowSpan(Integer r){
		this.rowSpan = r;
	}
	
	public Integer getRowSpan(){
		return this.rowSpan;
	}
	
	public Integer getId(){
		return id;
	}
	
	public void setId(Integer id){
		this.id = id;
	}
	
	//public Boolean getSelected(){
	//	return selected;
	//}
	
	//public void setSelected(Boolean isSelected){
	//	this.selected = isSelected;
	//}
	
	public void setBalance(Double balance){
		this.balance = balance;
	}
	
	public Double getBalance(){
		return balance;
	}
	
	

}