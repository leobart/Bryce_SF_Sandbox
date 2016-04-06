@isTest
public class BRC_MR_Test {
    
    static testmethod void test1(){
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('ratesXML');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'text/xml');
        Test.setMock(HttpCalloutMock.class, mock);

        BRC_CR_RateUpdate.process(Date.today().toStartOfWeek());
        BRC_CR_RateUpdate.process(Date.today().toStartOfWeek());
        BRC_MR_Management_Report_Item_Owner__c io = new BRC_MR_Management_Report_Item_Owner__c(User__c = UserInfo.getUserId());
        insert io;
        
        BRC_MR_Managment_Report_Item__c root = new BRC_MR_Managment_Report_Item__c(Title__c = 'Root', 
                                                                                   Group__c = true, 
                                                                                   Auto__c = false, 
                                                                                   Active__c = true, 
                                                                                   Sort_Order__c = 1, 
                                                                                   Owner__c = io.Id);
        insert root;
        List<BRC_MR_Managment_Report_Item__c> items = new List<BRC_MR_Managment_Report_Item__c>();
        BRC_MR_Managment_Report_Item__c brcF = new BRC_MR_Managment_Report_Item__c(Title__c = 'Иностранные компании БРАЙС', 
                                                                                   Group__c = true, 
                                                                                   Auto__c = false, 
                                                                                   Active__c = true, 
                                                                                   Sort_Order__c = 0, 
                                                                                   Owner__c = io.Id,
                                                                                   Parent_Item__c = root.Id, 
                                                                                   Reference_Id__c = 'brc_foreign');
        items.add(brcF);
        BRC_MR_Managment_Report_Item__c brcR = new BRC_MR_Managment_Report_Item__c(Title__c = 'Российские компании БРАЙС', 
                                                                                   Group__c = true, 
                                                                                   Auto__c = false, 
                                                                                   Active__c = true, 
                                                                                   Sort_Order__c = 1, 
                                                                                   Owner__c = io.Id,
                                                                                   Parent_Item__c = root.Id,
                                                                                   Reference_Id__c = 'brc_russia');
         items.add(brcR);

        BRC_MR_Managment_Report_Item__c manP = new BRC_MR_Managment_Report_Item__c(Title__c = 'Личные компании', 
                                                                                   Group__c = true, 
                                                                                   Auto__c = false, 
                                                                                   Active__c = true, 
                                                                                   Sort_Order__c = 2, 
                                                                                   Owner__c = io.Id,
                                                                                   Parent_Item__c = root.Id,
                                                                                   Reference_Id__c = 'man_personal');
        items.add(manP);
        insert items;
        
        BRC_MR_Managment_Report_Item__c brcFunds = new BRC_MR_Managment_Report_Item__c(Title__c = 'Funds', 
                                                                                   Group__c = false, 
                                                                                   Auto__c = false, 
                                                                                   Active__c = true, 
                                                                                   Sort_Order__c = 0, 
                                                                                   Owner__c = io.Id,
                                                                                   Parent_Item__c = brcF.Id,
                                                                                   Reference_Id__c = 'brc_foreign');
        insert brcFunds;
 

        BRC_MR_Managment_Report_Item__c revToItem = new BRC_MR_Managment_Report_Item__c(Title__c = 'ReversTo', 
                                                                                   Group__c = false, 
                                                                                   Auto__c = false, 
                                                                                   Active__c = true, 
                                                                                   Sort_Order__c = 1, 
                                                                                   Owner__c = io.Id,
                                                                                   Parent_Item__c = brcF.Id,
                                                                                   Dependent__c = true);
        insert revToItem; 
        
        BRC_MR_Managment_Report_Item__c revFromItem = new BRC_MR_Managment_Report_Item__c(Title__c = 'ReversFrom', 
                                                                                   Group__c = false, 
                                                                                   Auto__c = false, 
                                                                                   Active__c = true, 
                                                                                   Sort_Order__c = 1, 
                                                                                   Owner__c = io.Id,
                                                                                   Parent_Item__c = brcF.Id,
                                                                                   Dependent__c = false, 
                                                                                   Reversed_Item__c = revToItem.Id);
        insert revFromItem; 




        BRC_MR_Managment_Report_Item__c autoItem = new BRC_MR_Managment_Report_Item__c(Title__c = 'Rietumu', 
                                                                                   Group__c = false, 
                                                                                   Auto__c = true, 
                                                                                   Active__c = true, 
                                                                                   Sort_Order__c = 1, 
                                                                                   Owner__c = io.Id,
                                                                                   Parent_Item__c = brcF.Id,
                                                                                   Apex_Class__c = 'BRC_MR_RietumuELSaldoCalculator',
                                                                                   Parameters__c = 'a2UL0000000D4S6/USD');
        
        BRC_MR_MRWeeklyUpdateController wuController = new BRC_MR_MRWeeklyUpdateController();
        wuController.getDayOfWeekFormated();
        wuController.prevWeekAction();
        wuController.nextWeekAction();
        wuController.dateChangeAction();
        wuController.editAction();
        wuController.cancelAction();
        BRC_MR_ItemsTreeController treeController = new BRC_MR_ItemsTreeController();
        treeController.tree = wuController.tree;
        treeController.itemId = wuController.tree.mondayDateRootItem.mrItem.id;
        treeController.invertOpenItemAction();
        BRC_MR_NotifyUsersAndCalcAutoFields sc = new BRC_MR_NotifyUsersAndCalcAutoFields();
        sc.process();
        BRC_MR_ItemsTree t = wuController.tree;
        t.mondayDateRootItem.childs.get(0).childs.get(0).value.Value__c = 100;
        t.mondayDateRootItem.childs.get(0).childs.get(2).value.Value__c = 200;
        wuController.saveAction();
        BRC_MR_WeeklyManagementReportController wmrController = new BRC_MR_WeeklyManagementReportController();
        wmrController.exportToPdfAction(); 
                
    }
        
    static testmethod void test2(){       
        BRC_MR_Management_Report_Item_Owner__c io = new BRC_MR_Management_Report_Item_Owner__c(User__c = UserInfo.getUserId());
        insert io;
        
        BRC_MR_Managment_Report_Item__c root = new BRC_MR_Managment_Report_Item__c(Title__c = 'Root', 
                                                                                   Group__c = true, 
                                                                                   Auto__c = false, 
                                                                                   Active__c = true, 
                                                                                   Sort_Order__c = 1, 
                                                                                   Owner__c = io.Id);
        insert root;
        List<BRC_MR_Managment_Report_Item__c> items = new List<BRC_MR_Managment_Report_Item__c>();
        BRC_MR_Managment_Report_Item__c brcF = new BRC_MR_Managment_Report_Item__c(Title__c = 'Иностранные компании БРАЙС', 
                                                                                   Group__c = true, 
                                                                                   Auto__c = false, 
                                                                                   Active__c = true, 
                                                                                   Sort_Order__c = 0, 
                                                                                   Owner__c = io.Id,
                                                                                   Parent_Item__c = root.Id, 
                                                                                   Reference_Id__c = 'brc_foreign');
        items.add(brcF);
        
        c2g__codaCompany__c company = new c2g__codaCompany__c(Name='xxx');
        insert company;
        Rietumu_EL__c el = new Rietumu_EL__c(Ticket__c='qqqqqqqqqq', Company__c = company.Id);
        insert el;
        BRC_MR_Managment_Report_Item__c autoItem = new BRC_MR_Managment_Report_Item__c(Title__c = 'Rietumu', 
                                                                                   Group__c = false, 
                                                                                   Auto__c = true, 
                                                                                   Active__c = true, 
                                                                                   Sort_Order__c = 1, 
                                                                                   Owner__c = io.Id,
                                                                                   Parent_Item__c = brcF.Id,
                                                                                   Apex_Class__c = 'BRC_MR_MockCalculator',
                                                                                   Parameters__c = el.Id + '/USD');
        insert autoItem;         
        
        Test.startTest();

        BRC_MR_UpdateAutoItems sc = new BRC_MR_UpdateAutoItems();
        sc.execute(null);
        
        autoItem.Apex_Class__c = 'xxxx';
        update autoItem;
        sc.execute(null);
    }
    
    static testmethod void test3(){
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('RietumuTestXML');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'text/xml');
        Test.setMock(HttpCalloutMock.class, mock);
        BRC_MR_RietumuELSaldoCalculator calc = new BRC_MR_RietumuELSaldoCalculator();
        calc.getValue('test/USD', null);
        calc.getValue('test/USD', 0.9);
    }
    
    static testmethod void test4(){       
        BRC_MR_Management_Report_Item_Owner__c io = new BRC_MR_Management_Report_Item_Owner__c(User__c = UserInfo.getUserId());
        insert io;
        
        BRC_MR_Managment_Report_Item__c root = new BRC_MR_Managment_Report_Item__c(Title__c = 'Root', 
                                                                                   Group__c = true, 
                                                                                   Auto__c = false, 
                                                                                   Active__c = true, 
                                                                                   Sort_Order__c = 1, 
                                                                                   Owner__c = io.Id);
        insert root;
        List<BRC_MR_Managment_Report_Item__c> items = new List<BRC_MR_Managment_Report_Item__c>();
        BRC_MR_Managment_Report_Item__c brcF = new BRC_MR_Managment_Report_Item__c(Title__c = 'Иностранные компании БРАЙС', 
                                                                                   Group__c = true, 
                                                                                   Auto__c = false, 
                                                                                   Active__c = true, 
                                                                                   Sort_Order__c = 0, 
                                                                                   Owner__c = io.Id,
                                                                                   Parent_Item__c = root.Id, 
                                                                                   Reference_Id__c = 'brc_foreign');
        items.add(brcF);
        
        c2g__codaCompany__c company = new c2g__codaCompany__c(Name='xxx');
        insert company;
        Rietumu_EL__c el = new Rietumu_EL__c(Ticket__c='qqqqqqqqqq', Company__c = company.Id);
        insert el;
        BRC_MR_Managment_Report_Item__c inactiveItem = new BRC_MR_Managment_Report_Item__c(Title__c = 'Rietumu', 
                                                                                   Group__c = false, 
                                                                                   Auto__c = false, 
                                                                                   Active__c = false, 
                                                                                   Sort_Order__c = 1, 
                                                                                   Owner__c = io.Id,
                                                                                   Parent_Item__c = brcF.Id
                                                                                   );
        insert inactiveItem; 
        
        
        
        Test.startTest();

        BRC_MR_UpdateInactiveItemValues sc = new BRC_MR_UpdateInactiveItemValues();
		sc.execute(null);
    }
        
}