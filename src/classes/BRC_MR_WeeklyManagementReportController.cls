public with sharing class  BRC_MR_WeeklyManagementReportController extends BRC_MR_ManagementReportsCommon{
    
    public BRC_MR_WeeklyManagementReportController(){
        super();
        reportMode = true;
        initParametersTree();     
    }
    
    public PageReference exportToPdfAction(){
        return new PageReference('/apex/brc_mr_WeeklyReportPrint');
    }   
    
}