public class FFC_CurrencyRatesController {
    
    public FFC_CurrencyRatesManager crManager {get; set;}
    
    public void recalculateRates(){
        crManager.recalculateRates();
    }
    
    public Boolean getShowRatesComponent(){
        return crManager!= null && crManager.ratesMap.size() > 0;
    }

}