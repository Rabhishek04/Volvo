/********************************************************************************
 * カバレッジ用CL_CombineVehicleテストクラス
 ********************************************************************************/
@isTest
private class CL_CombineVehicle_Test{

/********************************************************************************
 * Test Method
 ********************************************************************************/

    /**
     * Assetで先にChassisCode__cが入るパターン
     */
    static testMethod void testAssetInitiated(){
    
        // テスト開始前の共通処理
        preMethod();
        
        // 車両データ作成
        Asset ass = CL_TestDataFactory_Test.createAssetRecords(1)[0];
        ass.ChassisCode__c = 'TEST000001';
        insert ass;
        
        // 車両（テンポラリ）データ作成
        TemporaryVehicle__c vehicle = CL_TestDataFactory_Test.createVehicleRecords(1);
        vehicle.ChassisCode__c = 'TEST000001';
        insert vehicle;
    }
    
    /**
     * Vehicleで先にChassisCode__cが入るパターン
     * その後、Vehicleレコードが更新される
     * その後、Vehicleレコードが削除される
     */
    static testMethod void testVehicleInitiated(){
    
        // テスト開始前の共通処理
        preMethod();
    
        // アカウント作成
        Account acc = CL_TestDataFactory_Test.createAccountRecords(1)[0];
        acc.Party_Id__c = '0000000000';
        insert acc;
        
        // 車両データ作成
        Asset ass = CL_TestDataFactory_Test.createAssetRecords(1)[0];
        ass.NoshaYoteibi__c = Date.today();
        insert ass;
        
        // 車両（テンポラリ）データ作成
        TemporaryVehicle__c vehicle = CL_TestDataFactory_Test.createVehicleRecords(1);
        insert vehicle;
        
        // 車両データアップデート
        ass.ChassisCode__c = vehicle.ChassisCode__c;
        ass.InstallDate = Date.today();
        update ass;
        
        // 車両（テンポラリ）データ更新
        vehicle.AccountPartyId__c = '0000000001';
        update vehicle;
        
        // 車両（テンポラリ）データ削除
        delete vehicle;
    }
    
    /**
     * NoneUD車についてVehicleを作成するパターン
     * その後、Vehicleレコードが更新される
     * その後、Vehicleレコードが削除される
     */
    static testMethod void testNoneUDVehicle(){
    
        // テスト開始前の共通処理
        preMethod();
    
        // アカウント作成
        Account acc = CL_TestDataFactory_Test.createAccountRecords(1)[0];
        acc.Party_Id__c = '0000000000';
        insert acc;
        
        // 車両（テンポラリ）データ作成
        TemporaryVehicle__c vehicle = CL_TestDataFactory_Test.createVehicleRecords(1);
        vehicle.BrandNameVDA__c = 'Fuso';
        vehicle.BrandNameLDS__c = 'Fuso';
        insert vehicle;
        
        // 車両（テンポラリ）データ更新
        vehicle.AccountPartyId__c = '0000000001';
        update vehicle;
        
        // 車両（テンポラリ）データ削除
        delete vehicle;
    }
    
/********************************************************************************
 * None Test Method
 ********************************************************************************/

    /**
     * テスト開始前の共通処理
     */
    static void preMethod(){
    
        // カスタム設定作成        
        ApexTrgFuncEnable__c sendMsgFlg = ApexTrgFuncEnable__c.getOrgDefaults();
        sendMsgFlg.CombineVehicleAsset__c = TRUE;
        sendMsgFlg.CombineVehicleTempVehicle__c = TRUE;
        
        upsert sendMsgFlg;        
    }
}