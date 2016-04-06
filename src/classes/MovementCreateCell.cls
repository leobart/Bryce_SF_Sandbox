public with sharing class MovementCreateCell {
	public Movement__c movement {get; set;}
	public Boolean addEnable {get; set;}
	public Boolean delEnable {get; set;}
	public Boolean remove {get; set;}
	public Boolean loss {get; set;}
	public Boolean lossDisabled {get; set;}
    public Boolean transfer {get; set;}
	public Boolean transferDisabled {get; set;}
	public List<SelectOption> dpListForTransfer {get; set;}
	public String transferDPId {get; set;}
	public List<SelectOption> buyDocumentList {get; set;}
	public String buyDocumentId {get; set;}
	public List<SelectOption> sellDocumentList {get; set;}
	public String sellDocumentId {get; set;}
	public Integer id {get; set;}
	
	public MovementCreateCell(){
		remove = false;
		loss = false;
        transfer = false;
		lossDisabled = false;
		transferDisabled = false;
		transferDPId = MovementCreateData.NONE_DP;
	}
		
	
}