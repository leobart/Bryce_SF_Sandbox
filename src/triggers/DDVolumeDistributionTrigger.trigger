trigger DDVolumeDistributionTrigger on Volume_Distribution__c (before insert,  before update, before delete){
    if(Trigger.isInsert || Trigger.isUpdate){
    	Volume_Distribution__c vd = Trigger.new[0];
        system.debug('VD: ' + vd);
    	Decimal buyDocPlannedVolume = [SELECT Planned_Volume__c FROM Delivery_Document__c WHERE Id=:vd.Buy_Document__c][0].Planned_Volume__c;
        Decimal sellDocPlannedVolume = [SELECT Planned_Volume__c FROM Delivery_Document__c WHERE Id=:vd.Sell_Document__c][0].Planned_Volume__c;
        List<AggregateResult> ar = [SELECT SUM(Volume__c) usedVolume FROM Volume_Distribution__c WHERE Buy_Document__r.Id=:vd.Buy_Document__c GROUP BY Buy_Document__r.Id];
        Decimal usedVolumeOfBuyDoc = 0;
        if(ar.size() > 0) usedVolumeOfBuyDoc = (Decimal)ar[0].get('usedVolume');
         
        ar = [SELECT SUM(Volume__c) usedVolume FROM Volume_Distribution__c WHERE Sell_Document__r.Id=:vd.Sell_Document__c GROUP BY Sell_Document__r.Id];
        Decimal usedVolumeOfSellDoc = 0;
        if(ar.size() > 0) usedVolumeOfSellDoc =  (Decimal)ar[0].get('usedVolume');
        Decimal availableBuyVolume;
        Decimal availableSellVolume;       
        if (Trigger.isInsert){
            availableBuyVolume = buyDocPlannedVolume - usedVolumeOfBuyDoc;
            availableSellVolume = sellDocPlannedVolume - usedVolumeOfSellDoc;           
        }else{
            Volume_Distribution__c vdOld = Trigger.old[0];
            availableBuyVolume = buyDocPlannedVolume - usedVolumeOfBuyDoc + vdOld.Volume__c;
            availableSellVolume = sellDocPlannedVolume - usedVolumeOfSellDoc  + vdOld.Volume__c; 
        }
        if (availableBuyVolume <= availableSellVolume){
            If(vd.Volume__c > availableBuyVolume) 
                vd.Volume__c.addError('Exceeded the value of the planned volume for Buy Document. Max Value: ' + availableBuyVolume);           
        }else{
            If(vd.Volume__c > availableSellVolume) 
                vd.Volume__c.addError('Exceeded the value of the planned volume for Sell Document. Max Value: ' + availableSellVolume);                       
        }
    
    }
    If(Trigger.isDelete || Trigger.isUpdate){
        Volume_Distribution__c vd = Trigger.old[0];
        List<AggregateResult> ar = [SELECT SUM(Quantity__c) shipped FROM Movement__c 
                                    WHERE State__c='Last' 
                                    AND Buy_Document__c=:vd.Buy_Document__c 
                                    AND Sell_Document__c=:vd.Sell_Document__c];
        Decimal alreadyShipped = 0;
        if(ar.size() > 0) alreadyShipped =  (Decimal)ar[0].get('shipped');
        if(Trigger.isDelete){
        	if(alreadyShipped>0) vd.addError('Impossible to remove. There is already a shipment under this agreement for volume: ' + alreadyShipped);        
        }else{
            Volume_Distribution__c vdNew = Trigger.new[0];
            if (vdNew.Volume__c < alreadyShipped) vdNew.addError('Impossible to update. There is already a shipment under this agreement for volume: ' + alreadyShipped); 
        }
    }
}