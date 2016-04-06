@isTest
public class BRC_CR_CurrencyFieldComponentTest {
    
    static testmethod void test1(){
        BRC_CR_CurrencyFieldComponentController c = new BRC_CR_CurrencyFieldComponentController();
        c.currencyId='';
        c.sourceValue = null;
        c.getFormattedValue();
        c.currencyId='USD';
        c.sourceValue = 10000.01;
        c.getFormattedValue();
        c.currencyId='GBP';
        c.sourceValue = 10000.01;
        c.getFormattedValue();
        c.currencyId='RUR';
        c.sourceValue = 10000.01;
        c.getFormattedValue();
        c.currencyId='CHF';
        c.sourceValue = 10000.01;
        c.getFormattedValue();
        c.currencyId='EUR';
        c.sourceValue = 10000.01;
        c.getFormattedValue();
        c.currencyId='BYR';
        c.sourceValue = 10000.01;
        c.getFormattedValue();
    }

}