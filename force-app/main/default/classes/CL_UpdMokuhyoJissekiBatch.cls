/********************************************************************************
 * 概要 ： 目標・実績レコード登録、更新バッチ
 ********************************************************************************/
public class CL_UpdMokuhyoJissekiBatch implements Database.Batchable<sObject> {

/********************************************************************************
 * Field
 ********************************************************************************/

    Map<Id, User> userMap;
    
    final List<String> KUBUN_LIST = new List<String>{'実績','受注残','売上予測'};
    final Map<Integer, List<Integer>> TARGET_YEAR_MONTH = new Map<Integer, List<Integer>>();
    final List<String> TARGET_ITEM_LIST = new List<String>{'SHASHU', 'UD_SHAGATA'};
    final Map<String, Map<String, List<String>>> SHASHU_LIST = new Map<String, Map<String, List<String>>>{
        'HD'=>new Map<String, List<String>>{
            'TARGET_ITEM'=>new List<String>{TARGET_ITEM_LIST[0]},
            'TARGET_VALUE'=>new List<String>{'HD','HD(8L)'},
            'OUT_TARGET_ITEM'=>new List<String>{TARGET_ITEM_LIST[1]},
            'OUT_TARGET_VALUE'=>new List<String>{'FH'}
        },
        'MHD'=>new Map<String, List<String>>{
            'TARGET_ITEM'=>new List<String>{TARGET_ITEM_LIST[0]},
            'TARGET_VALUE'=>new List<String>{'MHD'},
            'OUT_TARGET_ITEM'=>new List<String>(),
            'OUT_TARGET_VALUE'=>new List<String>()
        },
        'MD'=>new Map<String, List<String>>{
            'TARGET_ITEM'=>new List<String>{TARGET_ITEM_LIST[0]},
            'TARGET_VALUE'=>new List<String>{'MD'},
            'OUT_TARGET_ITEM'=>new List<String>(),
            'OUT_TARGET_VALUE'=>new List<String>()
        },
        'FH'=>new Map<String, List<String>>{
            'TARGET_ITEM'=>new List<String>{TARGET_ITEM_LIST[1]},
            'TARGET_VALUE'=>new List<String>{'FH'},
            'OUT_TARGET_ITEM'=>new List<String>(),
            'OUT_TARGET_VALUE'=>new List<String>()
        }
    };
    final String TARGET_OPPORTUNITY_TYPE = '新車';
    

/********************************************************************************
 * Constructor
 ********************************************************************************/

    /**
     * 1月の時だけ処理が変わるため、カバレッジ用に直接実行月を指定できるコンストラクタを作成
     *
     * @param month 実行月
     */
    public CL_UpdMokuhyoJissekiBatch(Integer month){
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
    public CL_UpdMokuhyoJissekiBatch(){
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
        
        // 目標・実績レコード作成用のデータを集計する
        for(String kubun : KUBUN_LIST){
            for(String shashu : SHASHU_LIST.keySet()){
                rsltMap.putAll(searchResult(kubun, userList, shashu));
            }
        }
        
        // 目標・実績レコードを作成し、アップサートする
        upsertMokuhyoJisseki(rsltMap, userList);
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
     * @param rsltMap 目標実績レコード作成用のSOQL検索結果
     * @param userList 目標実績レコード作成対象ユーザ
     */
    private void upsertMokuhyoJisseki(Map<String, AggregateResult> rsltMap, List<User> userList){
        List<MokuhyoJisseki__c> recList = new List<MokuhyoJisseki__c>();
        
        // 目標実績レコードを作成
        for(User usr : userList){
            for(String kubun : KUBUN_LIST){
                for(String shashu : SHASHU_LIST.keySet()){
                    for(Integer year : TARGET_YEAR_MONTH.keySet()){
                        // 区分「実績」については、来年度の集計を行わない
                        if(KUBUN_LIST[0].equals(kubun) && year == Date.today().year()+1){
                            continue;
                        }
                        
                        for(Integer month : TARGET_YEAR_MONTH.get(year)){
                            String updKey = createUpdateKey(usr.Id, kubun, shashu, year, month);
                            
                            MokuhyoJisseki__c rec = new MokuhyoJisseki__c();
                            rec.UpdateKey__c = updKey;
                            rec.Kubun__c = kubun;
                            rec.Shashu__c = shashu;
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
    private Map<String, AggregateResult> searchResult(String kubun, List<User> userList, String shashu){
        Map<String, AggregateResult> ret = new Map<String, AggregateResult>();
        
        List<AggregateResult> rsltList = new List<AggregateResult>();
        
        List<String> trgtItm = SHASHU_LIST.get(shashu).get('TARGET_ITEM');
        List<String> trgtVal = SHASHU_LIST.get(shashu).get('TARGET_VALUE');
        List<String> outTrgtItm = SHASHU_LIST.get(shashu).get('OUT_TARGET_ITEM');
        List<String> outTrgtVal = SHASHU_LIST.get(shashu).get('OUT_TARGET_VALUE');
        Set<Integer> trgtYear = TARGET_YEAR_MONTH.keySet();
        
        String query = '';
        
        // 実績の集計
        if(KUBUN_LIST[0].equals(kubun)){
            query += 'SELECT COUNT(id) daisu, CALENDAR_YEAR(InstallDate) year, CALENDAR_MONTH(InstallDate) month, SalesContact__c sc ';
            query += 'FROM Asset ';
            query += 'WHERE SalesContact__c IN :userList ';
            query += 'AND InstallDate != null ';
            query += 'AND CALENDAR_YEAR(InstallDate) IN :trgtYear ';
            
            // 対象の条件指定
            if(TARGET_ITEM_LIST[0].equals(trgtItm[0])){
                query += 'AND HMLSizeCategoryofVehicleFormula__c IN :trgtVal ';
            } else if (TARGET_ITEM_LIST[1].equals(trgtItm[0])){
                query += 'AND SharyoKatashikiLeft2__c IN :trgtVal ';
            } else {
                // 何もしない
            }
            
            // 対象外の条件指定
            if(outTrgtVal.size() != 0){
                if(TARGET_ITEM_LIST[1].equals(outTrgtItm[0])){
                    query += 'AND SharyoKatashikiLeft2__c NOT IN :outTrgtVal ';
                }
            }
            
            query += 'GROUP BY SalesContact__c, CALENDAR_YEAR(InstallDate),  CALENDAR_MONTH(InstallDate) ';
        
        // 受注残の集計
        } else if(KUBUN_LIST[1].equals(kubun)){
            query += 'SELECT COUNT(id) daisu, CALENDAR_YEAR(NoshaYoteibi__c) year, CALENDAR_MONTH(NoshaYoteibi__c) month, SalesContact__c sc ';
            query += 'FROM Asset ';
            query += 'WHERE SalesContact__c IN :userList ';
            query += 'AND InstallDate = null ';
            query += 'AND NoshaYoteibi__c != null ';
            query += 'AND CALENDAR_YEAR(NoshaYoteibi__c) IN :trgtYear ';
            
            if(TARGET_ITEM_LIST[0].equals(trgtItm[0])){
                query += 'AND HMLSizeCategoryofVehicleFormula__c IN :trgtVal ';
            } else if (TARGET_ITEM_LIST[1].equals(trgtItm[0])){
                query += 'AND SharyoKatashikiLeft2__c IN :trgtVal ';
            } else {
                // 何もしない
            }
            
            // 対象外の条件指定
            if(outTrgtVal.size() != 0){
                if(TARGET_ITEM_LIST[1].equals(outTrgtItm[0])){
                    query += 'AND SharyoKatashikiLeft2__c NOT IN :outTrgtVal ';
                }
            }
            
            query += 'GROUP BY SalesContact__c, CALENDAR_YEAR(NoshaYoteibi__c), CALENDAR_MONTH(NoshaYoteibi__c) ';
        
        // 売上予測の集計
        } else if(KUBUN_LIST[2].equals(kubun)){
            query += 'SELECT SUM(DaisuYosoku__c) daisu, CALENDAR_YEAR(DeliveryStartDate__c) year, CALENDAR_MONTH(DeliveryStartDate__c) month, OwnerId sc ';
            query += 'FROM Opportunity ';
            query += 'WHERE OwnerId IN :userList ';
            query += 'AND CALENDAR_YEAR(DeliveryStartDate__c) IN :trgtYear ';
            query += 'AND OpportunityType__c = :TARGET_OPPORTUNITY_TYPE ';
            
            if(TARGET_ITEM_LIST[0].equals(trgtItm[0])){
                query += 'AND Shashu__c IN :trgtVal ';
            } else if (TARGET_ITEM_LIST[1].equals(trgtItm[0])){
                query += 'AND UDShagata__c IN :trgtVal ';
            } else {
                // 何もしない
            }
            
            // 対象外の条件指定
            if(outTrgtVal.size() != 0){
                if(TARGET_ITEM_LIST[1].equals(outTrgtItm[0])){
                    query += 'AND UDShagata__c NOT IN :outTrgtVal ';
                }
            }
            
            query += 'GROUP BY OwnerId, CALENDAR_YEAR(DeliveryStartDate__c), CALENDAR_MONTH(DeliveryStartDate__c) ';
        } else {
            // 何もしない 
        }
        
        // データ取得
        System.debug('★クエリ：' + query);
        rsltList = Database.query(query);
        
        // 更新キーをキーにして、集計結果を格納
        for(AggregateResult rslt : rsltList){
            String updKey = createUpdateKey((Id)rslt.get('sc'), kubun, shashu, (Integer)rslt.get('year'), (Integer)rslt.get('month'));
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
    private String createUpdateKey(Id usrId, String kubun, String shashu, Integer year, Integer month){
        return userMap.get(usrId).VCNId__c + '_' + kubun + '_' + shashu + '_' + year + '/' + IntTo2Str(month);
    }
}