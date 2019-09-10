/********************************************************************************
 * カバレッジ用CL_CPDDSetToOpportunityテストクラス
 ********************************************************************************/
@isTest
private class CL_CPDDSetToOpportunity_Test{

/********************************************************************************
 * Test Method
 ********************************************************************************/

    /**
     * 通常系(insert,update,deleteを通して行う)
     */
    static testMethod void testStandard(){
    
        // テスト開始前の共通処理
        preMethod();    
    
        // CAユーザを作成
        User usr = CL_TestDataFactory_Test.createUserRecord(System.Label.AP00_DEF_0004, 1)[0];
        insert usr;
    
        // アカウント作成
        List<Account> acc = CL_TestDataFactory_Test.createAccountRecords(1);
        for(Account a : acc){
            a.OwnerId = usr.Id;
        }
        insert acc;
        
        // 営業プロセスデータ作成
        Opportunity opp = CL_TestDataFactory_Test.createOpportunityAnkenRecords(acc)[0];
        opp.AccountId = acc[0].Id;
        opp.OwnerId = usr.Id;
        insert opp;
        
        // 見積りデータ作成
        Mitsumori__c mtmr = CL_TestDataFactory_Test.createMitsumoriRecords(acc)[0];
        mtmr.Opportunity__c = opp.Id;
        insert mtmr;
        
        //車両データ作成
        List<Asset> assetList = CL_TestDataFactory_Test.createAssetRecords(1);
        for(Asset ass : assetList){
            ass.Noshayoteibi__c = Date.today();
            ass.MitsumoriId__c = mtmr.Id;
        }
        insert assetList;
           
        //車両データ更新
        for (Asset a : assetList) {
               a.InstallDate = Date.today() + 1;
        } 
        update assetList;
            
        // 車両データ削除
        delete assetList;
         

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
        sendMsgFlg.CPDDSetToOpportunity__c = TRUE;
        
        upsert sendMsgFlg;        
    }
}