public class DatesHelper {
    
    public static list<String> MONTH_ALIASES = new list<String>{'January', 'February', 'March', 'April', 'May', 
        										'June', 'July', 'August', 'September', 'October', 
        										'November', 'December'}; 
    public static list<String> MONTH_NUMBERS = new list<String>{'01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'}; 
    
    public static List<SelectOption> YEARS_LIST {get; set;}
    public Static list<SelectOption> MONTHS_LIST {get; set;}
    public Static list<SelectOption> MONTHS_ALL_LIST {get; set;}
    
    static{
        YEARS_LIST = new List<SelectOption>();
        MONTHS_LIST = new List<SelectOption>();
        MONTHS_ALL_LIST = new List<SelectOption>();
        MONTHS_ALL_LIST.add(new SelectOption('0', 'ALL'));
        for(Integer i=2010; i<=2030; i++){
            YEARS_LIST.add(new SelectOption(i+'',i+''));            
        } 
        for(Integer i=1; i<=12; i++){
            String mNum = i + '';
            if(i<10) mNum = '0' + mNum;
            MONTHS_LIST.add(new SelectOption(mNum, MONTH_ALIASES[i-1]));             
            MONTHS_ALL_LIST.add(new SelectOption(mNum, MONTH_ALIASES[i-1]));             
        }        
    }
    
    public static String getMonthStr(Integer monthNum, String separator, Integer year){
        Integer index = monthNum;
        if(monthNum < 1 || monthNum > 12){
            index = Date.today().Month();
        }
        return MONTH_NUMBERS[index-1] + separator + year;
    }
    
    public static Integer getMonthFromMonthYearStr(String monthYear){
        String m = monthYear.substring(0, 1);
        return Integer.valueOf(m);
    }

    public static Integer getYearFromMonthYearStr(String monthYear){
        String y = monthYear.substring(3, 6);
        return Integer.valueOf(y);
    }

}