public class BRC_HB_ReaderController {
    
    public string errorMessage {get; set;}
        
    public Blob fileBody {get; set;}
    public BRC_HB_Statement statement {get; set;}
    public c2g__codaCashEntry__c cashEntry {get; set;} //For BankAccount InputField
    
    
        
    public PageReference downloadDocPageAction(){
        errorMessage = null;
        return new PageReference('/apex/brc_hb_downloadStatement');
    }
    
    public PageReference viewStatementPageAction(){
        errorMessage = null;
        if(fileBody == null){
	    	errorMessage = 'Вы не выбрали файл с выпиской. Нажмите кнопку "Выберите файл". А только затем "Загрузить выписку"';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, errorMessage));
            return null;
        }
        try{
            statement = new BRC_HB_Statement(fileBody.toString());
        	fileBody = null;          
            if(statement.bankAccount == null){
                errorMessage = 'Не найден BankAccount (' + statement.bankAccountNumber + ') в FinancialForce для текущей компании. Возможно у вас выбрана неверная компания. Выберите соответствующую компанию.';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, errorMessage));  
                return null;
            }else{
                cashEntry = new c2g__codaCashEntry__c();
                cashEntry.c2g__BankAccount__c = statement.bankAccount.Id;
                List<String> currCompamies = c2g.CODAAPICompany_2_0.GetCurrentCompanies(null);
                if(currCompamies.size() > 1) {
                    errorMessage = 'Данный модуль не поддерживает работу в режиме "Мulti-company mode". Пожалуйста выберете только одну компанию на зкаладе "Select Company"';
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, errorMessage));
                    return null;
                }else if (currCompamies.size() == 0){
                    errorMessage = 'Не выбрана ни одна компания. Пожалуйста выберите компанию на закладке "Select Company"';
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, errorMessage));
                    return null;
                }else {
                    if(currCompamies[0] != statement.bankAccount.c2g__OwnerCompany__r.Name){
                        errorMessage = 'Выбранная компания не соответствует компании из выписки Hellenic Bank, выберите компанию: "' + statement.bankAccount.c2g__OwnerCompany__r.Name + '"';
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, errorMessage));
                        return null;
                    }
                } 
            }
        }catch (Exception e){
        	errorMessage = 'Файл не поддерживается или поврежден';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, errorMessage)); 
            return null;
        }      
        return new PageReference('/apex/brc_hb_statementReader');
    }
    
    public void updateSCHForTransactionsAction(){
        statement.loadCashEntriesForTrn();
    }
        

}