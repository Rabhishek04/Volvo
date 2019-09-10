/********************************************************************************
 * 概要 ： 目標・実績レコード登録、更新バッチのテストクラス
 ********************************************************************************/
@isTest
private class CL_UpdMokuhyoJissekiBatch_Test {

    static testMethod void test1(){
        Test.startTest();
        
        //5秒後に1回だけスケジュール
        Datetime dt = Datetime.now().addSeconds(5);//5秒後
        String startTime = dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        String jobId = System.schedule('CL_UpdMokuhyoJissekiBatch_Test_' + String.valueOf(dt), startTime, new CL_UpdMokuhyoJissekiBatch_Sch());
        
        Test.stopTest();
    }
    
    static testMethod void test2(){
        Test.startTest();
        
        // 実行月を指定してバッチ起動
        Database.executeBatch(new CL_UpdMokuhyoJissekiBatch(1), Integer.valueOf(System.Label.AP01_DEF_0003));
        
        Test.stopTest();
    }
    
    static testMethod void test3(){
        User usr = getCAUser();
        
        List<Asset> vehicleList = CL_TestDataFactory_Test.createAssetRecords(1);
        vehicleList[0].SalesContact__c = usr.Id;
        vehicleList[0].SyaryoKatashiki__c = 'C';
        vehicleList[0].NoshaYoteibi__c = Date.today();
        insert vehicleList;
        
        Test.startTest();
        
        //5秒後に1回だけスケジュール
        Datetime dt = Datetime.now().addSeconds(5);//5秒後
        String startTime = dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        String jobId = System.schedule('CL_UpdMokuhyoJissekiBatch_Test_' + String.valueOf(dt), startTime, new CL_UpdMokuhyoJissekiBatch_Sch());
        
        Test.stopTest();
    }
    
    static User getCAUser(){
        return [
            SELECT Id, VCNId__c
            FROM User
            WHERE isActive = true
                AND profileId = :System.Label.AP00_DEF_0004
            ORDER BY Id DESC
            LIMIT 1
        ];
    }
}