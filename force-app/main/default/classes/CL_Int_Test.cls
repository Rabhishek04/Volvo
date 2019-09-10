/********************************************************************************
 * カバレッジ用CL_IntAuthorizationテストクラス
 ********************************************************************************/
@isTest
private class CL_Int_Test{

/********************************************************************************
 * Test Method
 ********************************************************************************/

    /**
     * CDB_Add通常系
     */
    static testMethod void testCDBAddStandard(){
        
        // CAユーザを作成
        User usr = CL_TestDataFactory_Test.createUserRecord(CL_IntConst.PROFILE_ID_CA, 1)[0];
        insert usr;
        
        // アカウントデータ作成
        Account acc = CL_TestDataFactory_Test.createAccountRecords(1)[0];
        insert acc;
    
        // テスト事前処理
        preMethod();
        
        // テスト開始
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CL_Int_Test_Mock());
        
        acc.OwnerId = usr.Id;
        update acc;
        
        Test.stopTest();
    }

    /**
     * CDB_Main/Name/Address/Phone/Fax/Website通常系
     */
    static testMethod void testCDBUpdateStandard(){
        
        // CAユーザを作成
        User usr = CL_TestDataFactory_Test.createUserRecord(CL_IntConst.PROFILE_ID_CA, 1)[0];
        insert usr;
        
        // アカウントデータ作成
        Account acc = CL_TestDataFactory_Test.createAccountRecords(1)[0];
        acc.OwnerId = usr.Id;
        acc.ShokaiSoshin__c = TRUE;
        insert acc;
    
        // テスト事前処理
        preMethod();
        
        // テスト開始
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CL_Int_Test_Mock());
        
        acc.Name = 'test02';
        acc.BillingPostalCode = '999-9999';
        acc.BillingCity = '上尾市';
        acc.Phone = '999-9999';
        acc.Fax = '999-9999';
        acc.Website = 'http:localhost';
        update acc;
        
        Test.stopTest();
    }

    /**
     * CDB DealerPartyIDのみ変更
     */
    static testMethod void testCDBUpdateStandard2(){
        
        // CAユーザを作成
        List<User> usrList = CL_TestDataFactory_Test.createUserRecord(CL_IntConst.PROFILE_ID_CA, 2);
        insert usrList;
        
        // アカウントデータ作成
        Account acc = CL_TestDataFactory_Test.createAccountRecords(1)[0];
        acc.OwnerId = usrList[0].Id;
        acc.ShokaiSoshin__c = TRUE;
        insert acc;
    
        // テスト事前処理
        preMethod();
        
        // テスト開始
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CL_Int_Test_Mock());
        
        acc.OwnerId = usrList[1].Id;
        update acc;
        
        Test.stopTest();
    }

    /**
     * CDB全送信
     */
    static testMethod void testCDBAllSend(){
        
        // CAユーザを作成
        User usr = CL_TestDataFactory_Test.createUserRecord(CL_IntConst.PROFILE_ID_CA, 1)[0];
        insert usr;
        
        // アカウントデータ作成
        Account acc = CL_TestDataFactory_Test.createAccountRecords(1)[0];
        acc.OwnerId = usr.Id;
        acc.ShokaiSoshin__c = TRUE;
        insert acc;
    
        // テスト事前処理
        preMethod();
        
        // テスト開始
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CL_Int_Test_Mock());
        
        acc.EmergencyFlg_Add__c = TRUE;
        acc.EmergencyFlg_Upd__c = TRUE;
        update acc;
        
        Test.stopTest();
    }

    /**
     * CDB未送信メッセージ再送
     */
    static testMethod void testCDBReSend(){
        
        // CAユーザを作成
        User usr = CL_TestDataFactory_Test.createUserRecord(CL_IntConst.PROFILE_ID_CA, 1)[0];
        insert usr;
        
        // アカウントデータ作成
        Account acc = CL_TestDataFactory_Test.createAccountRecords(1)[0];
        acc.OwnerId = usr.Id;
        acc.ShokaiSoshin__c = TRUE;
        insert acc;
        
        // メッセージ送信履歴データ作成
        List<String> msgTypeIdList = new List<String>{
            CL_IntConst.CDB_ADD_MSG_TYPE_ID, 
            CL_IntConst.CDB_MAIN_MSG_TYPE_ID, 
            CL_IntConst.CDB_NAME_MSG_TYPE_ID, 
            CL_IntConst.CDB_ADDRESS_MSG_TYPE_ID, 
            CL_IntConst.CDB_PHONE_MSG_TYPE_ID, 
            CL_IntConst.CDB_FAX_MSG_TYPE_ID, 
            CL_IntConst.CDB_WEB_MSG_TYPE_ID
        };
        
        List<SendMsgLog__c>msgLogList = CL_TestDataFactory_Test.createMsgLogRecords(msgTypeIdList, acc);
        insert msgLogList;
    
        // テスト事前処理
        preMethod();
        
        // テスト開始
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CL_Int_Test_Mock());
        
        update acc;
        
        Test.stopTest();
    }

    /**
     * CDB未送信メッセージ再送
     */
    static testMethod void testCDBReSendMulti(){
        
        // CAユーザを作成
        User usr = CL_TestDataFactory_Test.createUserRecord(CL_IntConst.PROFILE_ID_CA, 1)[0];
        insert usr;
        
        // アカウントデータ作成
        List<Account> accList = CL_TestDataFactory_Test.createAccountRecords(2);
        for(Account acc : accList){
            acc.OwnerId = usr.Id;
            acc.ShokaiSoshin__c = TRUE;
        }
        insert accList;
        
        // メッセージ送信履歴データ作成
        List<String> msgTypeIdList = new List<String>{CL_IntConst.CDB_MAIN_MSG_TYPE_ID};
        List<SendMsgLog__c>msgLogList = CL_TestDataFactory_Test.createMsgLogRecords(msgTypeIdList, accList[0]);
        insert msgLogList;
    
        // テスト事前処理
        preMethod();
        
        // テスト開始
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CL_Int_Test_Mock());
        
        update accList;
        
        Test.stopTest();
    }

    /**
     * VSS_Main通常系
     */
    static testMethod void testVSSMainStandard(){
        
        // CAユーザを作成
        User usr = CL_TestDataFactory_Test.createUserRecord(CL_IntConst.PROFILE_ID_CA, 1)[0];
        insert usr;
        
        // アカウントデータ作成
        Account acc = CL_TestDataFactory_Test.createAccountRecords(1)[0];
        acc.OwnerId = usr.Id;
        acc.ShokaiSoshin__c = TRUE;
        insert acc;
        
        // 営業プロセスデータ作成
        Opportunity opp = CL_TestDataFactory_Test.createOpportunityAnkenRecords(acc)[0];
        insert opp;
        
        // 見積りデータ作成
        Mitsumori__c mtmr = CL_TestDataFactory_Test.createMitsumoriRecords(acc)[0];
        insert mtmr;
    
        // テスト事前処理
        preMethod();
        
        // テスト開始
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CL_Int_Test_Mock());
        
        mtmr.Opportunity__c = opp.Id;
        update mtmr;
        
        Test.stopTest();
    }

    /**
     * VSS全送信
     */
    static testMethod void testVSSAllSend(){
        
        // CAユーザを作成
        User usr = CL_TestDataFactory_Test.createUserRecord(CL_IntConst.PROFILE_ID_CA, 1)[0];
        insert usr;
        
        // アカウントデータ作成
        Account acc = CL_TestDataFactory_Test.createAccountRecords(1)[0];
        acc.OwnerId = usr.Id;
        acc.ShokaiSoshin__c = TRUE;
        insert acc;
        
        // 営業プロセス作成
        Opportunity opp = CL_TestDataFactory_Test.createOpportunityAnkenRecords(acc)[0];
        insert opp;
        
        // 見積りデータ作成
        Mitsumori__c mtmr = CL_TestDataFactory_Test.createMitsumoriRecords(acc)[0];
        mtmr.Opportunity__c = opp.Id;
        insert mtmr;
    
        // テスト事前処理
        preMethod();
        
        // テスト開始
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CL_Int_Test_Mock());
        
        mtmr.EmergencyFlg__c = TRUE;
        update mtmr;
        
        Test.stopTest();
    }

    /**
     * VSS未送信メッセージ再送
     */
    static testMethod void testVSSReSend(){
        
        // CAユーザを作成
        User usr = CL_TestDataFactory_Test.createUserRecord(CL_IntConst.PROFILE_ID_CA, 1)[0];
        insert usr;
        
        // アカウントデータ作成
        Account acc = CL_TestDataFactory_Test.createAccountRecords(1)[0];
        acc.OwnerId = usr.Id;
        acc.ShokaiSoshin__c = TRUE;
        insert acc;
        
        // 営業プロセス作成
        Opportunity opp = CL_TestDataFactory_Test.createOpportunityAnkenRecords(acc)[0];
        insert opp;
        
        // 見積りデータ作成
        Mitsumori__c mtmr = CL_TestDataFactory_Test.createMitsumoriRecords(acc)[0];
        mtmr.Opportunity__c = opp.Id;
        insert mtmr;
        
        // メッセージ送信履歴データ作成
        List<String> msgTypeIdList = new List<String>{CL_IntConst.VSS_MAIN_MSG_TYPE_ID};
        List<SendMsgLog__c>msgLogList = CL_TestDataFactory_Test.createMsgLogRecords(msgTypeIdList, mtmr);
        insert msgLogList;
    
        // テスト事前処理
        preMethod();
        
        // テスト開始
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CL_Int_Test_Mock());
        
        update mtmr;
        
        Test.stopTest();
    }
    
    /**
     * メソッド単体テスト
     */
    static testMethod void methodTest(){
        CL_IntCreateMsg msgCreater = new CL_IntCreateMsg_VSSMain(null, null);
        CL_IntUpdateRecord.updateAccount(null);
        CL_IntUpdateRecord.updateMitsumori(null);
        CL_IntSendMsg_Async msgSender = new CL_IntSendMsg_Async(null, 0, 0, new CL_IntMsgLogMgmt());
        
        CL_IntMsgLogMgmt mgmt = new CL_IntMsgLogMgmt();
        mgmt.addMsgLogUpd(new Map<String, Set<Id>>{CL_IntConst.VSS_MAIN_MSG_TYPE_ID => null});
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
        sendMsgFlg.MsgSendTriggerFlgCDB__c = TRUE;
        sendMsgFlg.MsgSendTriggerFlgVSS__c = TRUE;
        sendMsgFlg.RemoveDashForAccountFlg__c = TRUE;
        
        upsert sendMsgFlg;        
    }
}