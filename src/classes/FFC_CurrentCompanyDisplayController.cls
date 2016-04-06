public class FFC_CurrentCompanyDisplayController{
    
    public list<String> companies {get; set;}
    public Boolean noOneSelected {get; set;}
    
    public FFC_CurrentCompanyDisplayController(){
		companies = new list<String>();
        try{
        	companies = c2g.CODAAPICompany_2_0.GetCurrentCompanies(null);            
        }catch(Exception e){}
        noOneSelected = (companies.size() == 0);
    }

}