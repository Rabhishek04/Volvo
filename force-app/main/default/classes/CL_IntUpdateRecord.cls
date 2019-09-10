/********************************************************************************
 * 送信するレコードを更新するクラス
 * trgNumという値でトリガの多重起動防止をしている
 ********************************************************************************/
public class CL_IntUpdateRecord{
    // 起動しているトリガの数
    public static Integer trgNum = 0;

    /**
     * アカウントの全送信フラグをFALSEに更新するメソッド
     *
     * @param recMap 更新対象のレコードマップ
     */
    public static void updateAccount(Map<Id, Account> recMap){
        
        if(recMap == null){
            return;
        }
        
        List<Account> recList = [
            SELECT Id, EmergencyFlg_Add__c, EmergencyFlg_Upd__c, ShokaiSoshin__c
            FROM Account
            WHERE Id IN : recMap.keySet() 
            LIMIT :CL_IntConst.SOQL_LIMIT
        ];
        
        List<Account> recListForUpd = new List<Account>();
            
        for(Account rec : recList){
            if(rec.EmergencyFlg_Add__c == TRUE || rec.EmergencyFlg_Upd__c == TRUE){
                rec.EmergencyFlg_Add__c = FALSE;
                rec.EmergencyFlg_Upd__c = FALSE;
                recListForUpd.add(rec);
            }
        }
        
        update recListForUpd;
    }
    
    /**
     * 見積りの全送信フラグをFALSEに更新するメソッド
     *
     * @param recMap 更新対象のレコードマップ
     */
    public static void updateMitsumori(Map<Id, Mitsumori__c> recMap){
        
        if(recMap == null){
            return;
        }
        
        List<Mitsumori__c> recList = [
            SELECT Id, EmergencyFlg__c
            FROM Mitsumori__c
            WHERE Id IN : recMap.keySet() 
            LIMIT :CL_IntConst.SOQL_LIMIT
        ];
        
        List<Mitsumori__c> recListForUpd = new List<Mitsumori__c>();
        
        for(Mitsumori__c rec : recList){
            if(rec.EmergencyFlg__c == TRUE){
                rec.EmergencyFlg__c = FALSE;
                recListForUpd.add(rec);
            }
        }
        
        update recListForUpd;
    }
    
    /**
     * アカウントの初回送信フラグを更新する
     *
     * @param successMsgLog メッセージ送信に成功したレコードのSFID（Key：メッセージ種別ID）
     */
    public static void updateAccountShokai(Map<String, Set<Id>> successMsgLog){
        if(successMsgLog != null && successMsgLog.containsKey(CL_IntConst.CDB_ADD_MSG_TYPE_ID)){
        
            Set<Id> idSet = successMsgLog.get(CL_IntConst.CDB_ADD_MSG_TYPE_ID);
            
            List<Account> recList = [
                SELECT Id, EmergencyFlg_Add__c 
                FROM Account 
                WHERE Id IN :idSet
                    AND ShokaiSoshin__c = False 
                LIMIT :CL_IntConst.SOQL_LIMIT
            ];
            
            for(Account rec : recList){
                rec.ShokaiSoshin__c = TRUE;
            }
            
            update recList;
        }
    }
}