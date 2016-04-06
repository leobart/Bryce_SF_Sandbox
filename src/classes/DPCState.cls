public with sharing class DPCState {
	
	public Boolean opened {get; set;}
    public Boolean selected {get; set;}
	
	public DPCState(){
		opened = true;
        selected = false;
	}

}