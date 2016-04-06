public class bryce_BankListController {
    private Decimal Totl;
    private Decimal TotlBlocked;
    private Decimal TotlAvailable;
    private List<String> CompanyGroupsList;
    private boolean initialized=false;
    private bryceForexUpdate Exchange;
    
    private Bank__c TotalBankInstance=null;
    private List<bryce_BankInfoLineClass> BankInfo=null;
    private List<bryce_BankInfoLineClass> BankInfoFinal=null;
    
    private void init(){
            if (!initialized){
            Exchange=new bryceForexUpdate();
                    Totl=0;
            TotlBlocked=0;
            TotlAvailable=0;
            
            Schema.DescribeFieldResult Fres = c2g__codaCompany__c.Group_membership__c.getDescribe();
            List<Schema.PickListEntry> PLentry= Fres.getPicklistValues();
            CompanyGroupsList = new List<String>();
            //for (Schema.PickListEntry plit: PLentry) CompanyGroupsList.add(plit.getValue());
            CompanyGroupsList.add('Bryce Group');
            initialized=true;
        }
    }
    
    private void reinit(){
            Totl=0;
            TotlBlocked=0;
            TotlAvailable=0;
            
            Schema.DescribeFieldResult Fres = c2g__codaCompany__c.Group_membership__c.getDescribe();
            List<Schema.PickListEntry> PLentry= Fres.getPicklistValues();
            CompanyGroupsList = new List<String>();
            for (Schema.PickListEntry plit: PLentry) CompanyGroupsList.add(plit.getValue());
            initialized=true;
    }
    
    public List<c2g__codaBankAccount__c> getGroupBanksList(String grup){
            List<c2g__codaBankAccount__c> ttt=[SELECT ID, currencyISOCode, c2g__OwnerCompany__r.Name, Available_Funds__c, Bank__c, Bank__r.Name, Funds_Blocked__c FROM c2g__codaBankAccount__c WHERE Bank__c!=NULL AND c2g__OwnerCompany__r.Group_membership__c=:grup];
            return ttt;
    } 

    // Initialize setCon and return a list of records
    public List<bryce_BankInfoLineClass> getBanks() {
            init();
            BankInfoFinal=new List<bryce_BankInfoLineClass>();
            for (String Grit: CompanyGroupsList) { //For every group of companies
                    bryce_BankInfoLineClass bankLine= new bryce_BankInfoLineClass(0,0,0,'',grit,'background-color: #ffcb7d;  font-weight:Bold');
                    integer gitn=BankInfoFinal.size();
                    BankInfoFinal.add(bankLine);
                    List<c2g__codaBankAccount__c> bankList=getGroupBanksList(Grit); //We retrieve Bank acoounts of its companies
                    Set<Id> bankSet=new Set<Id>();
                    for (c2g__codaBankAccount__c bit:bankList){
                            bankSet.add(bit.Bank__c);
                    }
                    for (Id bidit:bankSet){  //and for every bank serving the group
                            List <Bank__c> tblist=[SELECT Name, Funds_Blocked__c, Available_Funds__c FROM Bank__c WHERE Id=:bidit];
                            bryce_BankInfoLineClass bankLine2= new bryce_BankInfoLineClass(tblist[0].Available_Funds__c,tblist[0].Funds_Blocked__c,tblist[0].Available_Funds__c+tblist[0].Funds_Blocked__c,'',tblist[0].Name,'background-color: #FFFFCC;  font-weight:Bold');
                            integer bitn=BankInfoFinal.size();
                            BankInfoFinal.add(bankLine2);
                            for (c2g__codaBankAccount__c bit:bankList){//we create detalisation for every company of that group and that bank
                                    if(bit.Bank__c==bidit){
                                            bankLine2= new bryce_BankInfoLineClass(bit.Available_Funds__c,bit.Funds_Blocked__c,bit.Available_Funds__c,bit.c2g__OwnerCompany__r.Name,'','',bit.currencyISOCode+' {0, number, #0,000.00}',bit.currencyISOCode);
                                            if (bankline2.getAvailableFunds()==Null) bankline2.setAF(0);
                                            if (bankline2.getBlockedFunds()==Null) bankline2.setBF(0);
                                            if (bankline2.getTotalFunds()==Null) bankline2.setTF(0);
                                            
                                            BankInfoFinal[bitn].setAF(BankInfoFinal[bitn].getAvailableFunds()+ToUSD(bit.Available_Funds__c,bit.currencyISOCode));
                                            BankInfoFinal[bitn].setTF(BankInfoFinal[bitn].getTotalFunds()+ToUSD(bit.Available_Funds__c,bit.currencyISOCode));
                                            BankInfoFinal.add(bankLine2);
                                    }
                            }
                            // bankLine= new bryce_BankInfoLineClass(BankInfoFinal[bitn].getAvailableFunds(),BankInfoFinal[bitn].getBlockedFunds(),BankInfoFinal[bitn].getAvailableFunds()+BankInfoFinal[bitn].getBlockedFunds(),'',tblist[0].Name+' Total','background-color: #FFFFCC;  font-weight:Bold','USD {0, number, #0,000.00}');
                            BankInfoFinal[gitn].setAF(BankInfoFinal[gitn].getAvailableFunds()+BankInfoFinal[bitn].getAvailableFunds());
                            BankInfoFinal[gitn].setBF(BankInfoFinal[gitn].getBlockedFunds()+BankInfoFinal[bitn].getBlockedFunds());
                            BankInfoFinal[gitn].setTF(BankInfoFinal[gitn].getBlockedFunds()+BankInfoFinal[gitn].getAvailableFunds());
                            
                            //BankInfoFinal[bitn].setAF(0);
                            //BankInfoFinal[bitn].setBF(0);
                            
                            //BankInfoFinal.add(bankLine);
                            //then creating summary info for bank
                            
                    }
                    //bankLine= new bryce_BankInfoLineClass(BankInfoFinal[gitn].getAvailableFunds(),BankInfoFinal[gitn].getBlockedFunds(),BankInfoFinal[gitn].getAvailableFunds()+BankInfoFinal[gitn].getBlockedFunds(),grit+' Total','','background-color: #ffcb7d;  font-weight:Bold','USD {0, number, #0,000.00}');
                    //BankInfoFinal[gitn].setAF(0);
                    //BankInfoFinal[gitn].setBF(0);
                    //BankInfoFinal.add(bankLine);
                    TotlBlocked=TotlBlocked+BankInfoFinal[gitn].getBlockedFunds();
                    TotlAvailable=TotlAvailable+BankInfoFinal[gitn].getAvailableFunds();                    
                    
                             //then insert TOTAL for group
            }
            
            Totl=TotlAvailable+TotlBlocked;
            bryce_BankInfoLineClass bankLine= new bryce_BankInfoLineClass(TotlAvailable,TotlBlocked,Totl,'Total for ALL','','background-color: #CCCCCC;  font-weight:Bold','USD {0, number, #0,000.00}');
            BankInfoFinal.add(bankLine);
            for (integer i=0;i<BankInfoFinal.size();i++){
                if(BankInfoFinal[i].getAvailableFunds()+BankInfoFinal[i].getBlockedFunds()+BankInfoFinal[i].getTotalFunds()==0) {
                BankInfoFinal.remove(i);
                i--;
                }            
            }
            return BankInfoFinal;
           
    }
    
    public Decimal getTotalBlocked() {
        init();
        return TotlBlocked;
    }
    
    public Decimal getTotalAvailible() {
        init();
        return TotlAvailable;
    }
    
    public PageReference pdf() {
        reinit();
        PageReference pageRef = new PageReference('/apex/bryceBankBalancesPdf');
        return pageRef;
    }
    
    public Decimal ToUSD(Decimal cur, String CIC){
        init();
        if (CIC=='USD') return cur;
        return cur/Exchange.getUSDRate(CIC);
    }
    
    public Decimal getTotal() {
        init();
        return Totl;
    }
    
}