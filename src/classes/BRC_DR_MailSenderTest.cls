@isTest
public class BRC_DR_MailSenderTest {
    
    static testmethod void test1(){
        BRC_DR_MailSenderController controller = new BRC_DR_MailSenderController();
        User u = [SELECT Id, Name FROM User WHERE Name='Leonid Bartenev'];
        controller.selectedUserId = u.Id;
        controller.sendMailAction();
    } 

}