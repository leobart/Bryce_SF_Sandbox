@isTest (SeeAllData=true)
public class BRC_HB_ReaderTest {
    
    private static String companyId;
    private static c2g__codaAccountingCurrency__c curr;
    private static c2g__codaGeneralLedgerAccount__c gla = [SELECT Id From c2g__codaGeneralLedgerAccount__c WHERE Name='1-1001 BNPP bank account'];
    static{
        String companyName = c2g.CODAAPICompany_2_0.GetCurrentCompanies(null)[0];
        companyId = [SELECT Id FROM c2g__codaCompany__c WHere Name=: companyName][0].Id;
        curr = [SELECT Id FROM c2g__codaAccountingCurrency__c where c2g__OwnerCompany__c=: companyId and Name='USD'];
        
    }

    static testmethod void test1(){
        
        c2g__codaBankAccount__c bacc = new c2g__codaBankAccount__c(c2g__BankName__c='Hellenic', 
                                                                   c2g__AccountName__c='CompHellenicUSD', 
                                                                   c2g__AccountNumber__c='340-07-709296-02', 
                                                                   c2g__ReportingCode__c='zzzxxxcccvvvss',
                                                                   c2g__BankAccountCurrency__c = curr.Id,
                                                                   c2g__GeneralLedgerAccount__c = gla.Id, 
                                                                   c2g__BankChargesGLA__c = gla.Id, 
                                                                   c2g__InterestPaidGLA__c = gla.Id,
                                                                   c2g__InterestReceivedGLA__c = gla.Id);
        insert bacc;
        test.startTest(); 
        StaticResource sr = [Select Body From StaticResource Where Name = 'Test_BRC_HB_Data' LIMIT 1];
        BRC_HB_ReaderController controller = new BRC_HB_ReaderController();
        controller.viewStatementPageAction();
        controller.fileBody = sr.Body;
        controller.viewStatementPageAction();
        BRC_HB_TransactionLine tline = controller.statement.transactions[0];
        for(BRC_HB_TransactionLine tl : controller.statement.transactions){
            system.debug('TLINE: ' + tl);
        }
        tline.getFormatBalance();
        tline.getFormatCharge();
        tline.getformatDate();
        tline.getFormatValue();
        tline.getCssClass();
        tline.getMatched();
        tline.getParameters();
        tline.getType();
        controller.updateSCHForTransactionsAction();
        controller.downloadDocPageAction();
        
        sr = [Select Body From StaticResource Where Name = 'brc_mr_plus_icon' LIMIT 1];
        controller.fileBody = sr.Body;
        controller.viewStatementPageAction();
        
        sr = [Select Body From StaticResource Where Name = 'Test_BRC_HB_Data2' LIMIT 1];
        controller.fileBody = sr.Body;
        controller.viewStatementPageAction();
        
    }
}