/********************************************************************************
 * 概要 ： 目標・実績レコード登録、更新バッチのテストクラス
 ********************************************************************************/
@isTest
private class CL_UpdMokuhyoJyuchuBatch_Test {

    static testMethod void test1(){
        Test.startTest();
        
        //5秒後に1回だけスケジュール
        Datetime dt = Datetime.now().addSeconds(5);//5秒後
        String startTime = dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        String jobId = System.schedule('CL_UpdMokuhyoJyuchuBatch_Test_' + String.valueOf(dt), startTime, new CL_UpdMokuhyoJyuchuBatch_Sch());
        
        Test.stopTest();
    }
    
    static testMethod void test2(){
        Test.startTest();
        
        // 実行月を指定してバッチ起動
        Database.executeBatch(new CL_UpdMokuhyoJyuchuBatch(1), Integer.valueOf(System.Label.AP01_DEF_0003));
        
        Test.stopTest();
    }
    
    static testMethod void test3(){
        
        // User取得
        User usr = getCAUser();
    
        // アカウント作成
        List<Account> acc = CL_TestDataFactory_Test.createAccountRecords(1);
        acc[0].OwnerId = usr.Id;
        insert acc;
        
        // 営業プロセスデータ作成
        Opportunity opp = CL_TestDataFactory_Test.createOpportunityAnkenRecords(acc)[0];
        opp.OwnerId = usr.Id;
        opp.AnkenShonin__c = TRUE;
        opp.DeliveryStartDate__c = Date.today();
        opp.CloseDate = Date.today();
        opp.OpportunityType__c = '新車';
        opp.Shashu__c = 'HD';
        opp.TotalOpportunityQuantity = 10;
        insert opp;
        
        Test.startTest();
        
        //5秒後に1回だけスケジュール
        Datetime dt = Datetime.now().addSeconds(5);//5秒後
        String startTime = dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        String jobId = System.schedule('CL_UpdMokuhyoJyuchuBatch_Test_' + String.valueOf(dt), startTime, new CL_UpdMokuhyoJyuchuBatch_Sch());
        
        Test.stopTest();
    }
    
    static User getCAUser(){
        return [
            SELECT Id, VCNId__c
            FROM User
            WHERE isActive = true
                AND profileId = :System.Label.AP00_DEF_0004
                AND DealPartyId__c != '' 
            ORDER BY Id DESC
            LIMIT 1
        ];
    }
}