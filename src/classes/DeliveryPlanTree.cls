public with sharing class DeliveryPlanTree {
	
	private Movement__c movement;
	private DeliveryPlanTree parent;
	private List<DeliveryPlanTree> childs = new List<DeliveryPlanTree>();
	private List<Double> amounts = new List<Double>();
	private List<Double> losses = new List<Double>();
	private List<Double> transfers = new List<Double>();
	private Integer rowSpan = 0;
	private Integer id;
	private Boolean selected = false;
	private Double balance = 0;
	
	public DPCState state {get; set;}
	
	
	public void setParent(DeliveryPlanTree parent){
		this.parent = parent;
		
	}
	
	public DeliveryPlanTree getParent(){
		return this.parent;
	}
	
	public void addChild(DeliveryPlanTree child){
		this.childs.add(child);
	}
	
	public void setMovement(Movement__c movement){
		this.movement = movement;
	}
	
	public Movement__c getMovement(){
		return movement;
	}
	
	public List<DeliveryPlanTree> getChilds(){
		return childs;
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
	
	public Boolean getSelected(){
		return selected;
	}
	
	public void setSelected(Boolean isSelected){
		this.selected = isSelected;
	}
	
	public void setBalance(Double balance){
		this.balance = balance;
	}
	
	public Double getBalance(){
		return balance;
	}
	
}