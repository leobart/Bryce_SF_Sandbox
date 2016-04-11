// Helenic Bank Statement Transaction Line
// Author Leonid Bartenev barteneff@gmail.com, lbartenev@bryce.ch
public class BRC_HB_TransactionLine {
    
    public String bankAccountNumber {get; set;}
    public Date trnDate {get; set;}
    public String trnId {get; set;}
    public String uniqueId {get; set;}
    public Decimal value {get; set;}
    public Decimal charge {get; set;}
    public Decimal debit {get; set;}
    public Decimal credit {get; set;}
    public Decimal balance {get; set;}
    public String datesInterval {get; set;}
    public String currencyCode {get; set;}
    public String contractorName {get; set;}
    public c2g__codaCashEntry__c cashEntry {get; set;}
    public c2g__codaBankAccount__c bankAccount{get; set;}
    
    public BRC_HB_TransactionLine(String data){
        String[] params = data.split('\t');
        //system.debug('PARAMS: ' + params);
        bankAccountNumber = params[0].trim();
        datesInterval = params[1].trim();
        currencyCode = params[2].trim();
        trnId = params[4].trim().replace('/','_');
        uniqueId = bankAccountNumber + '__' + trnId;
        contractorName = params[5].trim();
        debit = parseDeciaml(params[6].trim());
        credit = parseDeciaml(params[7].trim());
        if(credit == 0){
            value = -debit;
        }else{
            value = credit;
        }
        trnDate = parseDate(params[8].trim());
        balance = parseDeciaml(params[9].trim());
        
    }
    
    private Decimal parseDeciaml(String strValue){
        String leftSide, rightSide;
        leftSide = strValue.left(23);
        rightSide = strValue.right(2);
        Decimal result = Decimal.valueOf(leftSide);
        Decimal decimalPart = Decimal.valueOf(rightSide);
        decimalPart = decimalPart/100;
        result.setScale(2);
        result = result + decimalPart;
        return result;
    }
    
    private Date parseDate(String strValue){
        String[] dParams = strValue.split('/');
        return Date.newInstance(Integer.valueOf(dParams[2]), Integer.valueOf(dParams[1]), Integer.valueOf(dParams[0]));       
    }
    
    public String getformatDate(){
        return trnDate.format();
    }
    
    public String getFormatValue(){
        return value.format();
    }
    
    public String getFormatCharge(){
        return charge.format();
    }
    
    public String getFormatBalance(){
        return balance.format();
    }
    
    public String getCssClass(){
        if(getMatched()){
            return 'matchedCell';
        }else if(cashEntry != null){
            return 'createCECell';
        }
        return 'commonCell';
    }
    
    public Boolean getMatched(){
        return cashEntry != null && cashEntry.c2g__Transaction__c != null && cashEntry.c2g__Transaction__r.c2g__AccountOutstandingTotal__c == 0;
    }
    
    public String getType(){
        String ceType;
        if (value > 0){
            ceType = 'Receipt';			
        }else{
            ceType = 'Payment';
        }
        return ceType;
    }
    
    public String getParameters(){
        Decimal chargeValue = 0;
        if(charge != null) chargeValue = charge;
    	String params = 'trnId=' + uniqueId +
                         '&bAccId=' + bankAccount.Id +
                         '&companyId=' + bankAccount.c2g__OwnerCompany__r.Id +
                         '&companyName=' + EncodingUtil.urlEncode(bankAccount.c2g__OwnerCompany__r.Name+'', 'UTF-8') +
                         '&trnDate=' + EncodingUtil.urlEncode(trnDate + '', 'UTF-8') +
                         '&trnCur=' + EncodingUtil.urlEncode(currencyCode + '', 'UTF-8') +
                         '&benName=' + EncodingUtil.urlEncode(contractorName + '', 'UTF-8') +
                         '&cshType=' + EncodingUtil.urlEncode(getType() + '', 'UTF-8') +
                         '&trnAmount=' + EncodingUtil.urlEncode(value + '', 'UTF-8') +
                         '&trndesc=' + EncodingUtil.urlEncode('', 'UTF-8') +
                         '&chargeValue=' + EncodingUtil.urlEncode(chargeValue + '', 'UTF-8') +
                         '&details=' + EncodingUtil.urlEncode('', 'UTF-8');
        return String.escapeSingleQuotes(params);        
    }
    
    

}