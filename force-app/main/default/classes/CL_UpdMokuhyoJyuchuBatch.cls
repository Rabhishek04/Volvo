/********************************************************************************
 * 概要 ： 目標・受注レコード登録、更新バッチ
 ********************************************************************************/
public class CL_UpdMokuhyoJyuchuBatch implements Database.Batchable<sObject>{

/********************************************************************************
 * Field
 ********************************************************************************/
 
    Map<Id, User> userMap;
    final Map<Integer, List<Integer>> TARGET_YEAR_MONTH = new Map<Integer, List<Integer>>();
    final List<String> KUBUN_LIST = new List<String>{'受注','案件','受注予測'};
    final List<String> SHASHU_LIST = new List<String>{'HD','MHD','MD','FH'};
    final List<String> ACCOUNT_TYPE_LIST = new List<String>{'ハンティング', 'アクティブカスタマー'};
    final String TARGET_OPPORTUNITY_TYPE = '新車';

/********************************************************************************
 * Constructor
 ********************************************************************************/

    /**
     * 1月の時だけ処理が変わるため、カバレッジ用に直接実行月を指定できるコンストラクタを作成
     *
     * @param month 実行月
     */
    public CL_UpdMokuhyoJyuchuBatch(Integer month){
        userMap = new Map<Id, User>();
        
        if(month == 1){
            TARGET_YEAR_MONTH.put(Date.today().year()-1, new List<Integer>{12});
        }
        TARGET_YEAR_MONTH.put(Date.today().year(), new List<Integer>{1,2,3,4,5,6,7,8,9,10,11,12});
        TARGET_YEAR_MONTH.put(Date.today().year()+1, new List<Integer>{1,2,3,4,5,6,7,8,9,10,11,12});
        
    }

    /**
     * スケジューラから起動するときはこちらのコンストラクタを起動する
     */
    public CL_UpdMokuhyoJyuchuBatch(){
        this(Date.today().month());
    }

/********************************************************************************
 * Public Method
 ********************************************************************************/

    /**
     * batchableインターフェースのstartメソッド
     */
    public Database.QueryLocator start(Database.BatchableContext bc){
        if(Test.isRunningTest()){
            return Database.getQueryLocator(
                [
                    SELECT Id, VCNId__c
                    FROM User
                    WHERE isActive = true
                        AND profileId = :System.Label.AP00_DEF_0004
                        AND DealPartyId__c != '' 
                    ORDER BY Id DESC
                    LIMIT 1
                ]
            );
        } else {
            return Database.getQueryLocator(
                [
                    SELECT Id, VCNId__c
                    FROM User
                    WHERE isActive = true
                        AND profileId = :System.Label.AP00_DEF_0004
                ]
            );
        }
    }
    
    /**
     * batchableインターフェースのexecuteメソッド
     */
    public void execute(Database.BatchableContext bc, List<User> userList){
    
        // Key:VCNID_kubun_shashu_year/month Value:soqlResult
        Map<String, AggregateResult> rsltMap = new Map<String, AggregateResult>();
        userMap = new Map<Id, User>(userList);
        
        // 目標・受注レコード作成用のデータを集計する
        for(String kubun : KUBUN_LIST){
            for(String shashu : SHASHU_LIST){
                for(String accountType : ACCOUNT_TYPE_LIST){
                    rsltMap.putAll(searchResult(kubun, userList, shashu, accountType));
                }
            }
        }
        
        // 目標・受注レコードを作成し、アップサートする
        upsertMokuhyoJyuchu(rsltMap, userList);
    }
    
    /**
     * batchableインターフェースのfinishメソッド
     */
    public void finish (Database.BatchableContext bc){
        // 何もしない
    }
    

/********************************************************************************
 * Private Method
 ********************************************************************************/
    
    /**
     * SOQLで検索してきた結果をもとに、目標実績レコードを作成する
     *
     * @param rsltMap 目標受注レコード作成用のSOQL検索結果
     * @param userList 目標受注レコード作成対象ユーザ
     */
    private void upsertMokuhyoJyuchu(Map<String, AggregateResult> rsltMap, List<User> userList){
        List<MokuhyoJyuchu__c> recList = new List<MokuhyoJyuchu__c>();
        
        // 目標実績レコードを作成
        for(User usr : userList){
            for(String kubun : KUBUN_LIST){
                for(String shashu : SHASHU_LIST){
                    for(String accountType : ACCOUNT_TYPE_LIST){
                        for(Integer year : TARGET_YEAR_MONTH.keySet()){
                            // 区分「受注」については、来年度の集計を行わない
                            if(KUBUN_LIST[0].equals(kubun) && year == Date.today().year()+1){
                                continue;
                            }
                            
                            for(Integer month : TARGET_YEAR_MONTH.get(year)){
                                String updKey = createUpdateKey(usr.Id, kubun, shashu, accountType, year, month);
                                
                                MokuhyoJyuchu__c rec = new MokuhyoJyuchu__c();
                                rec.UpdateKey__c = updKey;
                                rec.Kubun__c = kubun;
                                rec.Shashu__c = shashu;
                                rec.AccountType__c = accountType;
                                rec.YearMonth__c = year + '/' + IntTo2Str(month);
                                rec.OwnerId = usr.Id;
                                
                                if(rsltMap.containsKey(updKey)){
                                    rec.Daisu__c = (Decimal)rsltMap.get(updKey).get('daisu');
                                } else {
                                    rec.Daisu__c = 0;
                                }
                                
                                recList.add(rec);
                            }
                        }
                    }
                }
            }
        }
        
        upsert recList UpdateKey__c;
    }

    /**
     * 目標実績レコード作成用の情報を取得するメソッド
     * 
     * @return 目標実績レコード作成用のSOQL検索結果（Key値はcreateUpdateKeyメソッドを参照）
     * @param kubun 検索対象の区分
     * @param userList 検索対象のユーザリスト
     * @param targetYear 検索対象の年
     * @param shashu 検索対象の車種
     */
    private Map<String, AggregateResult> searchResult(String kubun, List<User> userList, String shashu, String accountType){
        Map<String, AggregateResult> ret = new Map<String, AggregateResult>();
        
        List<AggregateResult> rsltList = new List<AggregateResult>();
        Set<Integer> trgtYear = TARGET_YEAR_MONTH.keySet();
        
        String query = '';
        
        /* 集計区分ごとの取得クエリ */
        // 受注の集計
        if(KUBUN_LIST[0].equals(kubun)){
            query += 'SELECT SUM(TotalOpportunityQuantity) daisu, CALENDAR_YEAR(CloseDate) year, CALENDAR_MONTH(CloseDate) month, OwnerId sc ';
        // 案件の集計
        } else if(KUBUN_LIST[1].equals(kubun)){
            query += 'SELECT SUM(TotalOpportunityQuantity) daisu, CALENDAR_YEAR(CloseDate) year, CALENDAR_MONTH(CloseDate) month, OwnerId sc ';
        // 受注予測の集計
        } else if(KUBUN_LIST[2].equals(kubun)){
            query += 'SELECT SUM(DaisuYosoku__c) daisu, CALENDAR_YEAR(CloseDate) year, CALENDAR_MONTH(CloseDate) month, OwnerId sc ';
        } else {
            // 何もしない
        }
        
        /* 共通クエリ */
        query += 'FROM Opportunity ';
        query += 'WHERE OwnerId IN :userList ';
        query += 'AND CALENDAR_YEAR(CloseDate) IN :trgtYear ';
        query += 'AND OpportunityType__c = :TARGET_OPPORTUNITY_TYPE ';
        
        /* 集計区分ごとの条件クエリ */
        List<String> stageNameList = new List<String>();
        // 受注の集計
        if(KUBUN_LIST[0].equals(kubun)){
            stageNameList = new List<String>{'受注済み'};
            query += 'AND StageName IN :stageNameList ';
        // 案件の集計
        } else if(KUBUN_LIST[1].equals(kubun)){
            stageNameList = new List<String>{'案件認識','仕様決定済','価格承認済','見積提出済'};
            query += 'AND StageName IN :stageNameList ';
            query += 'AND AnkenShonin__c = TRUE ';
        // 受注予測の集計
        } else if(KUBUN_LIST[2].equals(kubun)){
            // 何もしない
        } else {
            // 何もしない
        }
        
        /* 車両サイズ・UD車型ごとのクエリ */
        List<String> shashuList = new List<String>();
        List<String> udShagataList = new List<String>();
        // HDの場合
        if(SHASHU_LIST[0].equals(shashu)){
            shashuList = new List<String>{'HD','HD(8L)'};
            query += 'AND Shashu__c IN :shashuList ';
            udShagataList = new List<String>{'FH'};
            query += 'AND UDShagata__c NOT IN :udShagataList ';
        // MHDの場合
        } else if(SHASHU_LIST[1].equals(shashu)){
            shashuList = new List<String>{'MHD'};
            query += 'AND Shashu__c IN :shashuList ';
        // MDの場合
        } else if(SHASHU_LIST[2].equals(shashu)){
            shashuList = new List<String>{'MD'};
            query += 'AND Shashu__c IN :shashuList ';
        // FHの場合
        } else if(SHASHU_LIST[3].equals(shashu)){
            udShagataList = new List<String>{'FH'};
            query += 'AND UDShagata__c IN :udShagataList ';
        } else {
            // 何もしない
        }
        
        // ハンティングの場合
        if(ACCOUNT_TYPE_LIST[0].equals(accountType)){
            query += 'AND IsHunting__c = TRUE ';
        // カスタマーの場合
        } else if(ACCOUNT_TYPE_LIST[1].equals(accountType)){
            query += 'AND IsHunting__c = FALSE ';
        }
        
        /* 共通クエリ */
        query += 'GROUP BY OwnerId, CALENDAR_YEAR(CloseDate), CALENDAR_MONTH(CloseDate) ';
        
        // データ取得
        rsltList = Database.query(query);
        
        // 更新キーをキーにして、集計結果を格納
        for(AggregateResult rslt : rsltList){
            String updKey = createUpdateKey((Id)rslt.get('sc'), kubun, shashu, accountType, (Integer)rslt.get('year'), (Integer)rslt.get('month'));
            ret.put(updKey, rslt);
        }
        
        return ret;
    }
    
    /**
     * 数値を0埋めして2桁にする
     * 
     * @return 2桁に変換された文字列型数値
     * @param Integer arg 対象の数値
     */
    private String IntTo2Str(Integer arg){
        return arg != null ? String.valueOf(arg).leftPad(2,'0') : '00';
    }
    
    /**
     * 更新キーを作成する
     * 
     * @return 更新キー
     * @param usrId ユーザID
     * @param kubun 区分
     * @param shashu 車種
     * @param year 対象年
     * @param month 対象月
     */
    private String createUpdateKey(Id usrId, String kubun, String shashu, String accountType, Integer year, Integer month){
        return userMap.get(usrId).VCNId__c + '_' + kubun + '_' + shashu + '_' + accountType + '_' + year + '/' + IntTo2Str(month);
    }
}