/********************************************************************************
 * カバレッジ用CL_MgmtOpportunityテストクラス
 ********************************************************************************/
@isTest
private class CL_MgmtOpportunity_Test{

/********************************************************************************
 * Test Method
 ********************************************************************************/

    /**
     * 正常系
     */
    static testMethod void testStandard(){
    
        /* update・Delete用にあらかじめ営業プロセスレコードを登録しておく */
        // アカウント作成
        List<Account> acc = CL_TestDataFactory_Test.createAccountRecords(1);
        insert acc;
        
        // 営業プロセスデータ作成
        Opportunity opp = CL_TestDataFactory_Test.createOpportunityAnkenRecords(acc)[0];
        insert opp;
    
        // MgmtOpportunityインスタンスを作成する
        CL_MgmtOpportunity mgmt = new CL_MgmtOpportunity();
        
        // update用の営業プロセスリストを渡す
        opp.TotalOpportunityQuantity = 10;
        mgmt.setDmlOpportunityForUpd(opp);
        opp.TotalOpportunityQuantity = 20;
        mgmt.setDmlOpportunityForUpd(opp);
        
        // DML実行
        mgmt.executeDML();
        
    }
}