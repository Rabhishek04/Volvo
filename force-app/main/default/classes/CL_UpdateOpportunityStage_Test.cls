@isTest
private class CL_UpdateOpportunityStage_Test{

    private static final String PROFILE_ID_CA = System.Label.AP00_DEF_0004;

    /**
     * 正常系
     */
    static testMethod void normalTest01(){
    
        // 初期設定
        preMethod();
        
        // CAユーザを作成
        User usr = CL_TestDataFactory_Test.createUserRecord(PROFILE_ID_CA, 1)[0];
        insert usr;
        
        // アカウントデータ作成
        Account acc = CL_TestDataFactory_Test.createAccountRecords(1)[0];
        acc.OwnerId = usr.Id;
        acc.ShokaiSoshin__c = TRUE;
        insert acc;
        
        // 営業プロセスデータ作成
        Opportunity opp = CL_TestDataFactory_Test.createOpportunityAnkenRecords(acc)[0];
        insert opp;
        
        // テスト開始
        Test.startTest();
        
        // 見積りデータ作成
        Mitsumori__c mtmr = CL_TestDataFactory_Test.createMitsumoriRecords(acc)[0];
        mtmr.Opportunity__c = opp.Id;
        mtmr.Status__c = [SELECT MitsumoriStatus__c FROM StatusStageAllocation__mdt][0].MitsumoriStatus__c;
        insert mtmr;
        
        Test.stopTest();
    }

    /**
     * 異常系：更新した見積レコードがない
     */
    static testMethod void abnormalTest01(){
        // 初期設定
        preMethod();
        
        // テスト実行
        CL_UpdateOpportunityStage.updOppStg(null);
    }

/********************************************************************************
 * None Test Method
 ********************************************************************************/

    /**
     * テスト開始前の共通処理
     */
    static void preMethod(){
    
        // カスタム設定作成        
        ApexTrgFuncEnable__c apexFlg = ApexTrgFuncEnable__c.getOrgDefaults();
        apexFlg.SalesStageAutoUpdateFlg__c = TRUE;
        apexFlg.QuoteLinkFlgUpdateFlg__c = TRUE;
        
        upsert apexFlg;        
    }
}