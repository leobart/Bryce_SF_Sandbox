public with sharing class DeliveryDocument {
	public String name {get; set;}
	public String id {get; set;}
	public String contract {get; set;}
	public String addendum {get; set;}
	public Boolean selected {get; set;}
    public String period {get; set;}

	public DeliveryDocument(String id, String name, String contract, String addendum, String period){
		selected = true;
		this.name = name;
		this.id = id;
		this.contract = contract;
		this.addendum = addendum;
        this.period = period;
	}
	
	public String getStrValue(){
		String s = '';
		if (addendum != null) s = ' / ' + addendum; 
		return name + ' / ' + contract + s;
	}
}