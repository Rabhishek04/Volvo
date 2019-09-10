/********************************************************************************
 * メッセージ送信履歴オブジェクトにレコードを保存するクラス
 ********************************************************************************/
public class CL_IntMsgLogMgmt{

/********************************************************************************
 * Field
 ********************************************************************************/
 
    private Map<String, SendMsgLog__c> msgLogIns;    // insert用のメッセージ送信履歴レコード
    private Map<Id, SendMsgLog__c> msgLogUpd;   //update用のメッセージ送信履歴レコード

/********************************************************************************
 * Constructor
 ********************************************************************************/

    /**
     * 初期化処理
     */
    public CL_IntMsgLogMgmt(){
        msgLogIns = new Map<String, SendMsgLog__c>();
        msgLogUpd = new Map<Id, SendMsgLog__c>();
    }

/********************************************************************************
 * Public Method
 ********************************************************************************/

    /**
     * 引数に応じて、msgLogInsにレコードを追加する
     *
     * @param msgBody コールアウト時に送信したメッセージのボディ部
     * @param msgTypeId コールアウト時に送信したメッセージのメッセージ種別ID
     * @param successFlg そのコールアウトを成功とみなす場合、TRUEを設定する
     * @param id 送信したレコードのSFID
     */
    public void addMsgLogIns(String msgBody, String msgTypeId, Id id){
        SendMsgLog__c msgLog = new SendMsgLog__c();
            msgLog.msg__c = msgBody;
            msgLog.MsgTypeId__c = msgTypeId;
            msgLog.SuccessCheck__c = false;
            if(CL_IntConst.VSS_MAIN_MSG_TYPE_ID.equals(msgTypeId)){
                msgLog.MitsumoriId__c = id;
            } else {
                msgLog.AccountId__c = id;
            }
        
        msgLogIns.put(id + msgTypeId, msgLog);
    }
    
    /**
     * msgLogInsをSFに保存する
     */
    public void insertMsgLog(){
        System.debug('★' + msgLogIns);
        if(msgLogIns != null){
            if(!msgLogIns.isEmpty()){
                insert msgLogIns.values();
            }
        }
    }
    
    /**
     * 引数に応じて、msgLogUpdにレコードを追加する
     *
     * @param id 更新対象のレコードID
     * @param msgTypeId メッセージ種別ID
     * @param statusCode ステータスコード
     * @param bodyMsg レスポンスのボディ部
     */
    public void addMsgLogUpd(Id id, String msgTypeId, HttpResponse res){
        // レスポンス情報がないときは何もしない
        if(res.getStatusCode() == 0){
            return;
        }
        
        // メッセージ送信履歴の更新
        if(msgLogIns.containsKey(id + msgTypeId)){
            SendMsgLog__c msgLog = msgLogIns.get(id + msgTypeId);
            msgLog.StatusCode__c = res.getStatusCode().format();
            msgLog.SuccessCheck__c = CL_IntConst.STATUSCODE_SUCCESS.equals(res.getStatusCode().format());
            msgLog.SendMsgTime__c = System.Now();
            msgLog.ResponseMsg__c = res.getBody();
            msgLogUpd.put(msgLog.Id, msgLog);
        }
    }
    
    /**
     * 引数に応じて、msgLogUpdにレコードを追加する(例外発生時用)
     *
     * @param id 更新対象のレコードID
     * @param msgTypeId メッセージ種別ID
     * @param e 例外
     * @param timing 例外が発生したタイミングを表すString
     */
    public void addMsgLogUpd(Id id, String msgTypeId, Exception e, String timing){
        if(msgLogIns.containsKey(id + msgTypeId)){
            SendMsgLog__c msgLog = msgLogIns.get(id + msgTypeId);
            msgLog.APEXExceptionTiming__c = timing;
            msgLog.APEXExceptionType__c = e.getTypeName();
            msgLog.APEXExceptionDescription__c = e.getMessage().left(255);
            msgLogUpd.put(msgLog.Id, msgLog);
        }
    }
    
    /**
     * 引数に応じて、msgLogUpdにレコードを追加する
     *
     * @param successMsgLog メッセージ送信に成功したレコードの、メッセージ種別IDとレコードID
     */
    public void addMsgLogUpd(Map<String, Set<Id>> successMsgLog){
        
        // メッセージ種別IDごとにSOQL処理を行う
        for(String msgTypeId : successMsgLog.keySet()){
            List<SendMsgLog__c> msgLogList;
            if(msgTypeId == CL_IntConst.VSS_MAIN_MSG_TYPE_ID){
                msgLogList = [
                    SELECT Id 
                    FROM SendMsgLog__c 
                    WHERE Id NOT IN :msgLogUpd.keySet() 
                        AND msgTypeId__c = :msgTypeId 
                        AND MitsumoriId__c IN :successMsgLog.get(msgTypeId) 
                        AND SuccessCheck__c = FALSE
                    LIMIT :CL_IntConst.SOQL_LIMIT
                ];
            } else {
                msgLogList = [
                    SELECT Id 
                    FROM SendMsgLog__c 
                    WHERE Id NOT IN :msgLogUpd.keySet() 
                        AND msgTypeId__c = :msgTypeId 
                        AND AccountId__c IN :successMsgLog.get(msgTypeId) 
                        AND SuccessCheck__c = FALSE
                    LIMIT :CL_IntConst.SOQL_LIMIT
                ];
            }
            
            for(SendMsgLog__c msgLog : msgLogList){
                msgLog.SuccessCheck__c = TRUE;
            }
            msgLogUpd.putAll(msgLogList);
        }
    }
    
    /**
     * msgLogUpdをSFに保存する
     */
    public void updateMsgLog(){
        update msgLogUpd.values();
    }
}