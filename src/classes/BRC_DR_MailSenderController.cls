public class BRC_DR_MailSenderController {
    
    public String name {get; set;}
    public String url {get; set;}
    public String description {get; set;}
    public String selectedUserId {get; set;}
    public list<SelectOption> usersSO {get; set;}
    public String testStr {get; set;}
    private Map<String, User> mailsMap {get; set;}
    
    public BRC_DR_MailSenderController(){
        usersSO = new list<SelectOption>();
        mailsMap = new Map<String, User>();
        List<User> usersList = [SELECT Id, Name, Email FROM User WHERe IsActive = true];
        for(User u : usersList){
            usersSO.add(new SelectOption(u.Id, u.Name));
            mailsMap.put(u.Id, u);
        }
        if(usersList.size()>0){
            selectedUserId = usersList[0].Id;
        }
    }
    
    public PageReference sendMailAction(){
        sendMail(prepareMailBody());
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Письмо отправлено пользователю: ' + getUser().Name + ' на почту: ' + getUser().email));
        return new PageReference('/apex/brc_dr_MailSenderResultPage');
    }
    
    public String getMail(){
        return getUser().email;
    }
    
    public User getUser(){
        return mailsMap.get(selectedUserId);
    }
    
    public PageReference comebackAction(){
        return new PageReference('/apex/brc_dr_MailSenderPage');
    }
    
    private void sendMail(String errorsBody){
    	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    	List<String> sendTo = new List<String>();
    	sendTo.add(getMail());
    	mail.setToAddresses(sendTo);
   		mail.setReplyTo(UserInfo.getUserEmail());
    	mail.setSenderDisplayName(UserInfo.getFirstName() + ' ' + UserInfo.getLastName());
		mail.setSubject('Send the link');
    	mail.setHtmlBody(errorsBody);
    	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });         
    }
    
    private String prepareMailBody(){
        return '<html><body><p>' + description + '</p><br/><a href="' + url + '">' + name + '</a></body></html>';
    }
}