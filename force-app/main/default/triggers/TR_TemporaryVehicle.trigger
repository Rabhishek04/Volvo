trigger TR_TemporaryVehicle on TemporaryVehicle__c (after insert, after update, after delete) {

    if(Trigger.isAfter){
        if(Trigger.isInsert || Trigger.isUpdate){
        
            CL_MgmtAsset mgmtAsset = new CL_MgmtAsset();
        
            // Assetレコードにある同一車両に車両情報をマージする
            if(ApexTrgFuncEnable__c.getOrgDefaults().CombineVehicleTempVehicle__c){
                CL_CombineVehicle.combineVehicleFromVehicle(Trigger.oldMap, Trigger.newMap, mgmtAsset);
            }
            
            mgmtAsset.executeDML();
        }
        
        if(Trigger.isDelete){
        
            CL_MgmtAsset mgmtAsset = new CL_MgmtAsset();
            
            // Assetレコードにある同一車両の車両情報を削除する
            if(ApexTrgFuncEnable__c.getOrgDefaults().CombineVehicleTempVehicle__c){
                CL_CombineVehicle.deleteVehicleInfoFromVehicle(Trigger.oldMap, Trigger.newMap, mgmtAsset);
            }
            
            mgmtAsset.executeDML();
        }
    }
}