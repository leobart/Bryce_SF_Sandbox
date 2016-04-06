public class BRC_CR_CurrencyFieldComponentController {

    public Decimal sourceValue  {get; set;}
    public String currencyId {get; set;}
    
    public String getFormattedValue(){
        if (sourceValue == null) return '';
        Integer sign = 1;
        if(sourceValue < 0) sign = -1;
        Decimal d = sourceValue.setScale(2) + (sign * 0.001);
        String s = d.format();
        String retValue = s.substring(0,s.length()-1);
        if(currencyId == 'USD'){
            retValue = '$ ' + retValue;
        } else if(currencyId == 'EUR'){
            retValue = '€ ' + retValue;            
        } else if(currencyId == 'GBP'){
            retValue = '£ ' + retValue;            
        } else if(currencyId == 'CHF'){
            retValue = '₣ ' + retValue;            
        } else if(currencyId == 'RUR'){
            retValue = retValue + ' руб.';            
        } else if(currencyId == 'BYR'){
            retValue = 'Br ' + retValue;            
        }
        return retValue;
    }
    
}