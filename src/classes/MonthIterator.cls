public class MonthIterator{
    
    public static list<String> MONTH_ALIASES = new list<String>{'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 
        										'Июнь', 'Июль', 'Август', 'Сентябрь', 'Октябрь', 
        										'Ноябрь', 'Декабрь'}; 
    
    public static List<SelectOption> YEARS_LIST {get; set;}
    public Static list<SelectOption> MONTHS_LIST {get; set;}
    public Static List<SelectOption> MONTH_NUMBER {get; set;}
    
    static{
        YEARS_LIST = new List<SelectOption>();
        MONTHS_LIST = new List<SelectOption>();
        for(Integer i=2010; i<=2030; i++){
            YEARS_LIST.add(new SelectOption(i+'',i+''));            
        } 
        for(Integer i=1; i<=12; i++){
            String mNum = i + '';
            if(i<10) mNum = '0' + mNum;
            MONTHS_LIST.add(new SelectOption(mNum, MONTH_ALIASES[i-1])); 
			MONTH_NUMBER.add(new SelectOption(mNum, mNum));            
        }        
    }
    
    public String monthStr {get; set;}
    public String intervalStr {get; set;}
    public String yearStr {get; set;}
    
    public Date startDate {get; set;}
    public Date endDate {get; set;}
    
    public MonthIterator(){
        Date d = System.today();
        startDate = d.toStartOfMonth();
        endDate =Date.newInstance(d.year(), d.month(), Date.daysInMonth(d.year(), d.month()));  
        monthStr = d.month() + '';
        yearStr = d.year() + '';
        intervalStr = '1';
    }
    
    public void moveLeft(){
        Integer month = Integer.valueOf(monthStr);
        Integer year = Integer.valueOf(yearStr);
        Integer interval = Integer.valueOf(intervalStr);
        Date d = Date.newInstance(year, month, 1);
        d.addMonths(-interval);
    }
    
    

}