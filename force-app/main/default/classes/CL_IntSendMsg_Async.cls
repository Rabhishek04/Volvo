/********************************************************************************
 * メッセージを送信するクラス
 * QueueableはSF標準のインターフェース
 ********************************************************************************/
public class CL_IntSendMsg_Async implements Queueable, Database.AllowsCallouts{

/********************************************************************************
 * Field
 ********************************************************************************/

    private CL_IntAuthorization auth;    // 認証情報を管理するクラス
    private Map<Integer, Map<String, String>> sndMsgMap;    // 送信するメッセージを管理するクラス
    private Integer startNum;    // 送信するメッセージのボディ部
    private Integer sndAmount;    // 送信するメッセージの対象レコードのSFID
    private CL_IntMsgLogMgmt msgLogger;  // メッセージ送信履歴オブジェクトへの保存処理を管理する

/********************************************************************************
 * Constructor
 ********************************************************************************/

    /**
     * 初期化処理
     *
     * @param argSndMsgMap 送信するメッセージ
     * @param argStartNum 何番目のメッセージから送信するか
     * @param argSndAmount 何個メッセージを送信するか
     * @param argMsgLoger メッセージ送信履歴オブジェクトへの保存処理を管理する
     */
    public CL_IntSendMsg_Async(Map<Integer, Map<String, String>> argSndMsgMap, Integer argStartNum, Integer argSndAmount, CL_IntMsgLogMgmt argMsgLogger){
        if(argSndMsgMap == null){
            this.sndMsgMap = new Map<Integer, Map<String, String>>();
        } else {
            this.sndMsgMap = argSndMsgMap;
        }
        this.startNum = argStartNum;
        this.sndAmount = argSndAmount;
        this.msgLogger = argMsgLogger;
    }

/********************************************************************************
 * Public Method
 ********************************************************************************/

    /**
     * @override
     * 非同期処理として行われるメソッド
     * 
     * @param context ジョブIDを含む非同期処理情報
     */
    public void execute(QueueableContext context){
        
        // アクセストークンを取得
        if(sndMsgMap.containsKey(startNum)){
            auth = new CL_IntAuthorization(sndMsgMap.get(startNum).get('msgTypeId'));
        } else {
            return;
        }
        
        // 送信に成功したメッセージを記録する
        Map<String, Set<Id>> successMsgLog = new Map<String, Set<Id>>();
        
        // メッセージを一つ一つ送信する
        for(Integer i = 0; i < sndAmount; i++){
            
            // 送信するメッセージがなくなったら、ループを抜け出す
            if(!sndMsgMap.containsKey(startNum + i)){
                 break;
            }
            Map<String, String> msg = sndMsgMap.get(startNum + i);
            
            // メッセージ送信
            HttpResponse res = sendMsg(msg);
            
            // ステータスコードで認証エラーが返ってきた場合再認証して、再度メッセージ送信をする
            if(res != null && CL_IntConst.STATUSCODE_ERROR_AUTH.equals(res.getStatusCode().format())){
            
                // HTTPレスポンスをリセットしておく
                res = new HttpResponse();
                try{
                    auth.authorizationOauth();
                    res = sendMsg(msg);
                } catch (Exception e){
                    msgLogger.addMsgLogUpd(msg.get('id'), msg.get('msgTypeId'), e, CL_IntConst.OAUTH_APEX_EXCEPTION_TIMING);
                }
            }
            
            // メッセージ送信履歴オブジェクトの更新用レコードリストを追加
            msgLogger.addMsgLogUpd(msg.get('id'), msg.get('msgTypeId'), res);
            
            // 送信に成功したメッセージを記録する
            if(res != null && CL_IntConst.STATUSCODE_SUCCESS.equals(res.getStatusCode().format())){
                if(!successMsgLog.containsKey(msg.get('msgTypeId'))){
                    successMsgLog.put(msg.get('msgTypeId'), new Set<Id>());
                }
                successMsgLog.get(msg.get('msgTypeId')).add(msg.get('id'));
            }
        }
        
        // メッセージ送信履歴オブジェクトの更新用レコードリストを追加
        msgLogger.addMsgLogUpd(successMsgLog);
        
        //　メッセージ送信履歴オブジェクトのレコードをアップデートする
        msgLogger.updateMsgLog();
        
        // メッセージ送信に成功しているアカウントの初回送信フラグをTRUEにする
        CL_IntUpdateRecord.updateAccountShokai(successMsgLog);
        
        // カスタム設定に保持している認証情報を更新
        auth.updateToken();
    }

/********************************************************************************
 * Private Method
 ********************************************************************************/
    
    /**
     * メッセージを送信する
     *
     * @return HTTPレスポンス
     */
    private HttpResponse sendMsg(Map<String, String> msg){
        
        HttpResponse ret = new HttpResponse();
        HttpRequest req = new HttpRequest();
        
        req.setTimeout(CL_IntConst.CALLOUT_TIMEOUT);
        req.setEndpoint(msg.get('endPoint'));
        req.setMethod(msg.get('method'));
        req.setHeader('Accept', CL_IntConst.HMG_ACCEPT);
        req.setHeader('Content-Type', CL_IntConst.HMG_CONTENT_TYPE);
        req.setHeader('Authorization', 'Bearer ' + auth.getAccessToken());
        req.setHeader('clientApp', CL_IntConst.HMG_CLIENT_APP);
        req.setBody(msg.get('msg'));
        
        try{
            ret = new Http().send(req);
        } catch (Exception e){
            msgLogger.addMsgLogUpd(msg.get('id'), msg.get('msgTypeId'), e, CL_IntConst.HMG_APEX_EXCEPTION_TIMING);
        }
        
        return ret;
    }
}