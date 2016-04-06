trigger BRC_DL_DealTrigger on BRC_DL_Deal__c (before insert) {
    List<BRC_DL_Deal__c> newDeals = Trigger.new;
    for(BRC_DL_Deal__c deal : newDeals){
        list<BRC_DL_Deal__c> dList = [SELECT ID FROM BRC_DL_Deal__c WHERE Contract__c=:deal.Contract__c];
        if (dList.size() > 0){
            dList = [SELECT ID FROM BRC_DL_Deal__c WHERE Addendum__c=:deal.Addendum__c];
            if(dList.size() != 0){
                deal.Contract__c.addError('Deal for this contract or addendum already exists');
                deal.Addendum__c.addError('Deal for this contract or addendum already exists');
            }
        }
        
    }
}