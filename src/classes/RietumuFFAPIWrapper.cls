public with sharing class RietumuFFAPIWrapper implements RietumuAPIWrapperInterface{
	
	public List<String> getCurrentCompanies(){
		return c2g.CODAAPICompany_2_0.GetCurrentCompanies(null);
	}
	
	public c2g.CODAAPICommon.Reference createCashEntry(c2g.CODAAPICashEntryTypes_6_0.CashEntry ce){
		return c2g.CODAAPICashEntry_6_0.CreateCashEntry(null, ce);	
	}
	

}