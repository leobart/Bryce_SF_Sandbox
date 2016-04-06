@isTest(SeeAllData=true)
private class Invoice_Balances_Test{
    @isTest static void test1 (){
     	InvoiceBalancesController c = new InvoiceBalancesController();
        c.selectedCompany = 'Bryce Company Holding Inc.';
       	c.userName = 'Ruslan Cashaev';
  		c.total = 0;
        c.companies = new List <SelectOption>();
        SelectOption option = new SelectOption('Bryce Company Holding Inc','Bryce Company Holding Inc');
        c.companies.add(option);
        Test.startTest();
        List<SelectOption> comps = c.getCompanies();
        System.assert(comps.size()>0);
        Map<String,List<c2g__codaTransaction__c>> tba = c.getTransactionsByAccount();
        System.assert(tba.size()>0);
        Map<String,Decimal> totalsba = c.getTotalsByAccount();
        System.assert(totalsba.size()>0);
        c.up();
       	System.assert(c.getTotal()!='');
        ApexPages.currentPage().getParameters().put('invoiceInternalNumber','SIN001228');
        System.assert(c.openInvoice()!=null);
        Test.stopTest();
     }
}