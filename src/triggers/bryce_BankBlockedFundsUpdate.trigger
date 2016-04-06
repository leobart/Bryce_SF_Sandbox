trigger bryce_BankBlockedFundsUpdate on c2g__codaBankAccount__c (after insert, after update, after delete) {
      if ((trigger.isInsert)||(trigger.isDelete)||(trigger.isUpdate)){
           List<Bank__c> BList=[SELECT Id, Funds_Blocked__c FROM Bank__c];
           for(Bank__c bit: BList){
               AggregateResult[] sm=[SELECT SUM(Funds_Blocked__c)summa FROM c2g__codaBankAccount__c WHERE Bank__c=:bit.Id];
               bit.Funds_Blocked__c = (Decimal)sm[0].get('summa');
               update bit;
           }
      }               
}