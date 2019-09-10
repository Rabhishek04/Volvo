/********************************************************************************
 * テストクラス用PingFederate認証疑似レスポンスクラス
 ********************************************************************************/
@isTest
public class CL_Int_Test_Mock implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req){
    
        System.debug('★' + req);
        System.debug('★' + req.getEndpoint());
        System.debug('★' + req.getHeader('Authorization'));
    
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        // 認証のコールアウト
        if(req.getEndpoint().contains(CL_IntConst.OAUTH_ENDPOINT)){
            res.setStatusCode(200);
            res.setBody('{"access_token":"abcdefg","refresh_token":"hijklmn","token_type":"Bearer","expires_in":7199}');
            
        // 1回目のコールアウト
        } else if('Bearer nullnullnull'.equals(req.getHeader('Authorization')) || 'Bearer '.equals(req.getHeader('Authorization'))){
            res.setStatusCode(401);
            
        // 2回目のコールアウト
        } else {
            res.setStatusCode(200);
        }
        
        return res;
    }
}