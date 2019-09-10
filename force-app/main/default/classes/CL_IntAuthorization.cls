/********************************************************************************
 * 認可情報を管理するクラス
 * VolvoのPingFederateへのOAuth認証と、
 * Salesforce内でのトークン管理を行っている
 ********************************************************************************/
public class CL_IntAuthorization {

/********************************************************************************
 * Field
 ********************************************************************************/

    private sObject token;
    private String msgTypeId;

/********************************************************************************
 * Constructor
 ********************************************************************************/

    /**
     * カスタム設定から現在の認可情報を取得する
     * 
     * @param argMsgTypeId メッセージ種別ID
     */
    public CL_IntAuthorization(String argMsgTypeId){
        msgTypeId = argMsgTypeId;
        
        if(CL_IntConst.VSS_MAIN_MSG_TYPE_ID.Equals(msgTypeId)){
            token = PingFederateToken_VSS__c.getOrgDefaults();
        } else {
            token = PingFederateToken_CDB__c.getOrgDefaults();
        }
    }

/********************************************************************************
 * Public Method
 ********************************************************************************/

    /**
     * アクセストークン値のゲッター
     * 
     * @return アクセストークン値
     */
    public string getAccessToken(){
        return '' + token.get('AccessToken__c') + token.get('AccessToken2__c') + token.get('AccessToken3__c');
    }

    /**
     * PingFederateへアクセストークンの再取得を行う
     */
    public void authorizationOauth(){
    
        // カスタムメタデータから、クライアントシークレットとパスワードを取得する
        ToPingFederate__mdt ping = [
            SELECT Id, ClientSecret__c, Password__c 
            FROM ToPingFederate__mdt 
            WHERE DeveloperName = 'default' 
            LIMIT 1
        ];
        
        // ユーザ名パスワードフローでOAuth認証を行う
        HttpResponse res = null;
        try{
            res = authorizationPasswordFlow(ping);
        } catch (Exception e) {
            throw e;
        }
        
        // 取得したトークンを、メンバ変数のトークンに格納する
        setToken(res);
    }
    
    /**
     * カスタム設定のトークンをアップデートする
     */
    public void updateToken(){
        if(CL_IntConst.VSS_MAIN_MSG_TYPE_ID.Equals(msgTypeId)){
            if(token != PingFederateToken_VSS__c.getOrgDefaults()){
                upsert token;
            }
        } else {
            if(token != PingFederateToken_CDB__c.getOrgDefaults()){
                upsert token;
            }
        }
    }

/********************************************************************************
 * Private Method
 ********************************************************************************/
    
    /**
     * メンバ変数のトークンを更新する
     * 
     * @param res OAuth認証処理のHTTPレスポンス
     */
    private void setToken(HttpResponse res){
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(res.getbody());
        
        token.put('AccessToken__c',('' + m.get('access_token')).left(255));
        token.put('AccessToken2__c',('' + m.get('access_token')).Mid(255, 255));
        token.put('AccessToken3__c',('' + m.get('access_token')).Mid(510, 255));
        token.put('RefreshToken__c','' + m.get('refresh_token'));
        token.put('TokenType__c','' + m.get('token_type'));
        token.put('ExpiryDateTime__c',System.Now().addSeconds((Integer)m.get('expires_in')));
    }
    
    /**
     * ユーザ名パスワードフローでOAuth認証を行う
     * 
     * @param ping クライアントシークレットとパスワードを保持するカスタムメタデータ
     * @return OAuth認証処理のHTTPレスポンス
     */
    private HttpResponse authorizationPasswordFlow(ToPingFederate__mdt ping){
        HttpRequest req = new HttpRequest();
        
        // req.setTimeout(CL_IntConst.CALLOUT_TIMEOUT);
        req.setTimeout(CL_IntConst.CALLOUT_TIMEOUT);
        req.setMethod(CL_IntConst.METHOD);
        req.setHeader('Content-Type', CL_IntConst.OAUTH_CONTENT_TYPE);
        
        String endPoint = CL_IntConst.OAUTH_ENDPOINT;
        endPoint += '?client_id=' + CL_IntConst.OAUTH_CLIENTID;
        endPoint += '&client_secret=' + ping.ClientSecret__c;
        endPoint += '&grant_type=password';
        endPoint += '&validator_id=' + CL_IntConst.OAUTH_VALIDATORID;
        endPoint += '&username=' + CL_IntConst.OAUTH_USERNAME;
        endPoint += '&password=' + ping.Password__c;
        endPoint += '&scope=';
        
        if(CL_IntConst.VSS_MAIN_MSG_TYPE_ID.Equals(msgTypeId)){
            req.setEndpoint(endPoint + CL_IntConst.VSS_SCOPE);
        } else {
            req.setEndpoint(endPoint + CL_IntConst.CDB_SCOPE);
        }
        
        return new Http().send(req);
    }
}