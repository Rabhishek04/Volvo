/********************************************************************************
 * テストクラス用テストデータ作成クラス
 ********************************************************************************/
@isTest
public class CL_TestDataFactory_Test {

    /**
     * ユーザリストを作成し、リストを返すメソッド
     * 
     * @return 作成したユーザリスト
     * @param profileIdArg 作成したいプロファイルID
     * @param numOfUser 作成するレコード数
     */
    public static List<User> createUserRecord(String profileIdArg, Integer numOfUser){
        List<User> ret = new List<User>();
        
        for(integer i = 0 ; i < numOfUser ; i++){
            ret.add(
                new User(
                    UserName = 'newCRM_testClass_createdUser_'+ String.valueOf(i) +'@volvo.com',
                    Email = 'newCRM_testClass_createdUser_'+ String.valueOf(i) +'@volvo.com',
                    LastName = 'Test',
                    Alias = 'Test',
                    TimeZoneSidKey = 'Asia/Tokyo',
                    LocaleSidKey = 'ja_JP',
                    EmailEncodingKey = 'ISO-2022-JP',
                    LanguageLocaleKey = 'ja',
                    ProfileId = profileIdArg,
                    VCNId__c = 'TEST'+ String.valueOf(i),
                    DealPartyId__c = 'TESTD'+ String.valueOf(i)
                )
            );
        }
        
        return ret;
    }

    /**
     * アカウントリストを作成し、リストを返すメソッド
     * 
     * @return 作成したアカウントリスト
     * @param numOfRecord 作成するレコード数
     */
    public static List<Account> createAccountRecords(Integer numOfRecord){
        List<Account> ret = new List<Account>();
        
        for(integer i = 0;i < numOfRecord ; i++){
            ret.add(
                new Account(
                    Name = 'テストアカウント' + String.valueOf(i), 
                    KanshinGoto__c = '事業の継承',
                    Party_Id__c = '' + i
                )
            );
        }

        return ret;
    }

    /**
     * 営業プロセスリストを作成し、リストを返すメソッド
     * 
     * @return 作成した営業プロセスリスト
     * @param accList 紐づけるアカウントリスト
     */
    public static List<Opportunity> createOpportunityAnkenRecords(List<Account> accList){
        List<Opportunity> ret = new List<Opportunity>();
        
        for(Account acc : accList){
            Opportunity opp = new Opportunity();
            
            opp.Name = 'オポチュニティ';
            opp.CloseDate = System.today().addDays(1);
            opp.AccountId = acc.Id;
            opp.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'RPT_StartAnken' AND SobjectType = 'Opportunity' LIMIT 1].Id;
            opp.StageName = '案件認識';
            
            ret.add(opp);
        }

        return ret;
    }

    /**
     * 営業プロセスリストを作成し、リストを返すメソッド
     * 
     * @return 作成した営業プロセスリスト
     * @param acc 紐づけるアカウント
     */
    public static List<Opportunity> createOpportunityAnkenRecords(Account acc){
        List<Account> accList = new List<Account>();
        accList.add(acc);
        
        return createOpportunityAnkenRecords(accList);
    }

    /**
     * 見積りリストを作成し、リストを返すメソッド
     * 
     * @return 作成した見積りリスト
     * @param acc 紐づけるアカウントリスト
     */
    public static List<Mitsumori__c> createMitsumoriRecords(List<Account> accList){
        List<Mitsumori__c> ret = new List<Mitsumori__c>();
        
        Integer i = 0;
        for(Account acc : accList){
            Mitsumori__c mtmr = new Mitsumori__c();
            mtmr.Account__c = acc.Id;
            mtmr.VSS_QUOTE_ID__c = '' + i;
            mtmr.VSS_DEAL_ID__c = '' + i;
            
            ret.add(mtmr);
            
            i++;
        }
        
        return ret;
    }

    /**
     * 見積りリストを作成し、リストを返すメソッド
     * 
     * @return 作成した見積りリスト
     * @param acc 紐づけるアカウント
     */
    public static List<Mitsumori__c> createMitsumoriRecords(Account acc){
        List<Account> accList = new List<Account>();
        accList.add(acc);
        
        return createMitsumoriRecords(accList);
    }

    /**
     * 車両リストを作成し、リストを返すメソッド
     * 
     * @return 作成した車両リスト
     * @param numOfRecord 作成するレコード数
     */
    public static List<Asset> createAssetRecords(Integer numOfRecord){
        List<Asset> ret = new List<Asset>();
        
        for(integer i = 0;i < numOfRecord ; i++){
            ret.add(
                new Asset(
                    Name = 'テスト車両' + String.valueOf(i)
                )
            );
        }

        return ret;
    }

    /**
     * 車両（テンポラリ）を作成して、そのレコードを返すメソッド
     * 
     * @return 作成した車両（テンポラリ）レコード
     * @param num 作成するレコードの番号（ChassisCode__cの後ろなどにつく）
     */
    public static TemporaryVehicle__c createVehicleRecords(Integer num){
        TemporaryVehicle__c ret = new TemporaryVehicle__c();
        
        ret.ChassisCode__c = 'Chss' + ('000000' + num).right(6);
        ret.Name = ('00000000' + num).right(8);
        ret.AccountPartyId__c = '0000000000';
        ret.UDTrust__c = '10';
        ret.VIN__c = ret.Name;
        ret.BrandNameVDA__c = [SELECT MasterLabel FROM UDBland__mdt][0].MasterLabel;
        ret.BrandNameLDS__c = ret.BrandNameVDA__c;
        ret.BodyShiyoVDA__c = '42';
        ret.NumberofRegistratio__c = 'ABCDEFGHIJ';
        ret.SyaryoKatashikiVDA__c = 'UE11 42T';
        ret.SyaryoKatashikiLDS__c = 'UE11 42T';
        ret.HMLSizeCategoryofVehicleVDA__c = 'UD-HD';
        ret.HMLSizeCategoryofVehicleLDS__c = 'UD-HD';
        ret.EngineType__c = 'GH13';
        ret.MissionType__c = '1609A';
        ret.ChassisNumber__c = ret.ChassisCode__c.left(4);
        ret.ChassisSeries__c = ret.ChassisCode__c.right(6);
        ret.OMNoVDA__c = ret.Name;
        ret.ContractStartDate__c = Date.today();
        ret.ContractDuration__c = 1;
        ret.ExpiryDate__c = Date.today();
        ret.Status__c = 1;
        ret.ContractDescription__c = 'TEST';
        
        return ret;
    }

    /**
     * メッセージ送信履歴リストを作成し、リストを返すメソッド
     * 
     * @return 作成したメッセージ送信履歴リスト
     * @param msgTypeIdList 作成するメッセージのメッセージ種別IDリスト
     * @param objList 紐づける対象のオブジェクトリスト
     */
    public static List<SendMsgLog__c> createMsgLogRecords(List<String> msgTypeIdList, List<sObject> objList){
        List<SendMsgLog__c> ret = new List<SendMsgLog__c>();
        
        for(sObject obj : objList){
            for(String msgTypeId : msgTypeIdList){
                SendMsgLog__c msgLog = new SendMsgLog__c();
                
                msgLog.MsgTypeId__c = msgTypeId;
                msgLog.SuccessCheck__c = FALSE;
                msgLog.msg__c = '送信メッセージ';
                
                if(obj.getSObjectType().getDescribe().getName() == 'Account'){
                    msgLog.AccountId__c = obj.Id;
                } else if(obj.getSObjectType().getDescribe().getName() == 'Mitsumori__c') {
                    msgLog.MitsumoriId__c = obj.Id;
                } else {
                }
                
                ret.add(msgLog);
            }
        }

        return ret;
    }

    /**
     * メッセージ送信履歴リストを作成し、リストを返すメソッド(紐付先のオブジェクトがリストでない場合)
     * 
     * @return 作成したメッセージ送信履歴リスト
     * @param msgTypeIdList 作成するメッセージのメッセージ種別IDリスト
     * @param objList 紐づける対象のオブジェクト
     */
    public static List<SendMsgLog__c> createMsgLogRecords(List<String> msgTypeIdList, sObject obj){
        List<sObject> objList = new List<sObject>();
        objList.add(obj);
        
        return createMsgLogRecords(msgTypeIdList, objList);
    }
}