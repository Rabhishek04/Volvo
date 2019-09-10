/********************************************************************************
 * カバレッジ用CL_MgmtAssetテストクラス
 ********************************************************************************/
@isTest
private class CL_MgmtAsset_Test{

/********************************************************************************
 * Test Method
 ********************************************************************************/

    /**
     * 正常系
     */
    static testMethod void testStandard(){
    
        // update・Delete用にあらかじめ車両データを登録しておく
        List<Asset> assetList = CL_TestDataFactory_Test.createAssetRecords(1);
        insert assetList;
    
        // MgmtAssetインスタンスを作成する
        CL_MgmtAsset mgmt = new CL_MgmtAsset();
        
        // insert用の車両リストを渡す
        mgmt.setDmlAssetForIns(CL_TestDataFactory_Test.createAssetRecords(1));
        
        // update用の車両リストを渡す
        assetList[0].InstallDate = Date.today();
        mgmt.setDmlAssetForUpd(assetList);
        assetList[0].NoshaYoteibi__c = Date.today();
        mgmt.setDmlAssetForUpd(assetList);
        
        // delete用の車両のIDを渡す
        List<Id> assetId = new List<Id>();
        for(Asset ass : assetList){
            assetId.add(ass.Id);
        }
        mgmt.setDmlAssetForDel(assetId);
        
        // DML実行
        mgmt.executeDML();
        
    }
}