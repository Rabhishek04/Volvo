trigger TR_Asset on Asset (before insert, before update, after insert, after update, after delete) {
    if(Trigger.isBefore){
        if(ApexTrgFuncEnable__c.getOrgDefaults().CombineVehicleAsset__c){
            CL_CombineVehicle.combineVehicleFromAsset(Trigger.oldMap, Trigger.new);
        }
    }
    
    if(Trigger.isAfter){
        if(ApexTrgFuncEnable__c.getOrgDefaults().CPDDSetToOpportunity__c){
            CL_MgmtOpportunity mgmt = new CL_MgmtOpportunity();
            
            CL_CPDDSetToOpportunity.setCPDDToOpp(Trigger.oldMap, Trigger.newMap, mgmt);
         
            mgmt.executeDML();
        }
    }
}