/********************************************************************************
 * メッセージを作成する抽象化クラス
 ********************************************************************************/ 
public abstract class CL_IntCreateMsg {

/********************************************************************************
 * Field
 ********************************************************************************/ 
    public final String endPoint;
    public final String method;
    public final String msgTypeId;
    protected Map<Id,sObject> oldRecMap;
    protected Map<Id,sObject> newRecMap;
    protected Map<Id, String> reqMap;    //HTTPリクエストのボディメッセージを格納
    protected Set<Id> idSet;            //メッセージを送るレコードのIDを格納
    protected Set<Id> errMsgIdSet;    //未送信のメッセージを持つレコードのIDを格納

/********************************************************************************
 * Constructor
 ********************************************************************************/ 
    
    /**
     * メンバ変数の初期化処理
     * 
     * @param argOldRecMap 更新前レコードMAP
     * @param argNewRecMap 更新後レコードMAP
     */
    public CL_IntCreateMsg (Map<Id,sObject> argOldRecMap, Map<Id,sObject> argNewRecMap){
        if(argOldRecMap != null){
            this.oldRecMap = argOldRecMap;
        } else {
            this.oldRecMap = new Map<Id,sObject>();
        }
        if(argNewRecMap != null){
            this.newRecMap = argNewRecMap;
        } else {
            this.newRecMap = new Map<Id,sObject>();
        }
        
        method = CL_IntConst.METHOD;
        reqMap = new Map<Id, String>();
        errMsgIdSet = new Set<Id>();
        idSet = new Set<Id>();
    }
    
/********************************************************************************
 * Public Method
 ********************************************************************************/
 
    /**
     * HTTPリクエストのボディメッセージのゲッター
     *
     * @return HTTPリクエストのボディメッセージ
     */
    public Map<Id, String> getRecMsgMap(){
        return reqMap;
    }
    
/********************************************************************************
 * Protected Method
 ********************************************************************************/
    
    /**
     * メッセージを作成する一連の流れを管理するメソッド
     */
    protected void createMsg(){
        if(!newRecMap.isEmpty()){
            searchErrMsg();
            setIdSet();    // メッセージ送信対象のレコードIDを格納していく
            createBodyMsg();
        }
        else{
            // 何もしない
        }
        return;
    }
    
    /**
     * null値のStringを''にして返す
     * JSONメッセージ作成時に使用
     * 
     * @param str null判定を行いたいStringを設定
     * @return 引数のStringがnullなら''を、それ以外なら引数をそのまま返す
     */
    protected String chgNullToBlank(String str){
        if(String.isEmpty(str)){
            return '';
        } else {
            return str;
        }
    }
    
/********************************************************************************
 * Private Method
 ********************************************************************************/
    
    /**
     * メッセージ送信対象のレコードIDを格納していく
     */
    private void setIdSet(){
         for(sObject newRec : newRecMap.values()){
             
             // そのレコードに未送信メッセージがある場合、メッセージ送信対象とする
             if(errMsgIdSet.contains(newRec.Id)){
                 idSet.add(newRec.Id);
                 continue;
             }
             
             // メッセージ送信判定を、メッセージ種別ごとに判定を行う
             if(chkSndFlg(newRec)){
                 idSet.add(newRec.Id);
             }
         }
    }
    
    /**
     * メッセージ送信判定を、メッセージ種別ごとに判定を行う
     *
     * @param newRec メッセージ送信判定を行う対象のレコード
     * @return Trueならそのレコードはメッセージ送信対象
     */
    private abstract Boolean chkSndFlg(sObject newRec);
    
    /**
     * @description HTTPリクエストのボディメッセージを作成する
     */
    private abstract void createBodyMsg();
    
    /**
     * 更新レコードに、未送信メッセージが存在するか検索を行う
     */
    private void searchErrMsg(){
    
        System.debug('★' + newRecMap.size());
        
        // 複数件更新の時は未送信メッセージ再送処理は行わない
        if(newRecMap.size() != 1){
            return;
        }
        
        List<SendMsgLog__c> msgLogList = null;
        if(msgTypeId == CL_IntConst.VSS_MAIN_MSG_TYPE_ID){
            msgLogList = [
                SELECT Id, MitsumoriId__c 
                FROM SendMsgLog__c 
                WHERE MitsumoriId__c =:newRecMap.keySet() 
                    AND msgTypeId__c = :msgTypeId 
                    AND SuccessCheck__c = FALSE
                LIMIT :CL_IntConst.SOQL_LIMIT
            ];
                
            for(SendMsgLog__c msgLog : msgLogList){
                errMsgIdSet.add(msgLog.MitsumoriId__c);
            }
        } else {
            msgLogList = [
                SELECT Id, AccountId__c 
                FROM SendMsgLog__c 
                WHERE AccountId__c =:newRecMap.keySet() 
                    AND msgTypeId__c = :msgTypeId 
                    AND SuccessCheck__c = FALSE
                LIMIT :CL_IntConst.SOQL_LIMIT
            ];
            
            for(SendMsgLog__c msgLog : msgLogList){
                errMsgIdSet.add(msgLog.AccountId__c);
            }
        }
    }
}