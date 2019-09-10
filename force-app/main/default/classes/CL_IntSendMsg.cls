/********************************************************************************
 * メッセージ送信の一連の流れを管理する静的クラス
 ********************************************************************************/
public class CL_IntSendMsg{

    /**
     * メッセージ送信の一連の流れ
     *
     * @param msgList 作成したメッセージのインスタンス
     */
    public static void sendMsg(List<CL_IntCreateMsg> msgList){
        
        // nullチェック
        if(msgList == null || msgList.size() == 0){return;}
        
        // メッセージ送信履歴オブジェクト管理クラスをインスタンス化
        CL_IntMsgLogMgmt msgLogger = new CL_IntMsgLogMgmt();
        
        // メッセージを送信しやすい形に整形する
        Integer i = 0;
        Map<Integer, Map<String, String>> sndMsgMap = new Map<Integer, Map<String, String>>();
        for(CL_IntCreateMsg msg : msgList){
            for(Id id : msg.getRecMsgMap().keySet()){
                Map<String, String> m = new Map<String, String>();
                m.put('msg', msg.getRecMsgMap().get(id));
                m.put('id', id);
                m.put('msgTypeId', msg.msgTypeId);
                m.put('endPoint', msg.endPoint);
                m.put('method', msg.method);
                sndMsgMap.put(i,m);
                i++;
                
                // メッセージ送信履歴オブジェクトに保存するレコードを作成する
                msgLogger.addMsgLogIns(msg.getRecMsgMap().get(id), msg.msgTypeId, id);
            }
        }
        
        // 送信するメッセージをメッセージ送信履歴オブジェクトに保存する
        msgLogger.insertMsgLog();
        
        // メッセージの数に応じて、メッセージ送信処理をApexジョブに追加する
        for(Integer j = 0; j < CL_IntConst.ASYNC_LIMIT; j++){
            if(sndMsgMap.size() <= (CL_IntConst.ASYNC_MSG_LIMIT * j)){break;}
            ID jobID = System.enqueueJob(new CL_IntSendMsg_Async(sndMsgMap, CL_IntConst.ASYNC_MSG_LIMIT * j, CL_IntConst.ASYNC_MSG_LIMIT, msgLogger));
        }
    }
}