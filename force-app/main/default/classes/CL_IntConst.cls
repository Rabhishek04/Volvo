/********************************************************************************
 * 定数管理用静的クラス
 ********************************************************************************/
public class CL_IntConst{

/********************************************************************************
 * 全般
 ********************************************************************************/
    
    public static final String PROFILE_ID_CA = System.Label.AP00_DEF_0004;
    public static final Integer SOQL_LIMIT = 1000;

/********************************************************************************
 * コールアウト
 ********************************************************************************/
    public static final String METHOD = 'POST';
    public static final String CDB_SCOPE = System.Label.AP10_DFN_0001;
    public static final String VSS_SCOPE = System.Label.AP10_DFN_0002;
    
    public static final String STATUSCODE_SUCCESS = '200';
    public static final String STATUSCODE_ERROR_AUTH = '401';
    
    public static final Integer CALLOUT_TIMEOUT = 60000;
    
    public static final Integer ASYNC_LIMIT = 50;    //非同期処理の上限回数
    public static final Integer ASYNC_MSG_LIMIT = 8;    //一回の非同期処理あたり、いくつのメッセージ送信するか
    
/********************************************************************************
 * コールアウト - To HMG
 ********************************************************************************/
    public static final String HMG_ENDPOINT = System.Label.AP10_PRM_0001;
    public static final String HMG_ACCEPT = 'application/json';
    public static final String HMG_CONTENT_TYPE = 'application/json;charset=UTF-8';
    public static final String HMG_CLIENT_APP = 'UDCRM_Salesforce';
    
    public static final String HMG_APEX_EXCEPTION_TIMING = 'Sending Message';
     
    public static final String CDB_ADD_MSG_TYPE_ID = 'CDB_Add';
    public static final String CDB_ADD_ENDPOINT = HMG_ENDPOINT + '/' + CDB_SCOPE;
    
    public static final String CDB_MAIN_MSG_TYPE_ID = 'CDB_Main';
    public static final String CDB_MAIN_ENDPOINT = HMG_ENDPOINT + '/' + CDB_SCOPE;
    
    public static final String CDB_NAME_MSG_TYPE_ID = 'CDB_Name';
    public static final String CDB_NAME_ENDPOINT = HMG_ENDPOINT + '/' + CDB_SCOPE;
    
    public static final String CDB_ADDRESS_MSG_TYPE_ID = 'CDB_Address';
    public static final String CDB_ADDRESS_ENDPOINT = HMG_ENDPOINT + '/' + CDB_SCOPE;
    
    public static final String CDB_PHONE_MSG_TYPE_ID = 'CDB_Phone';
    public static final String CDB_PHONE_ENDPOINT = HMG_ENDPOINT + '/' + CDB_SCOPE;
    
    public static final String CDB_FAX_MSG_TYPE_ID = 'CDB_Fax';
    public static final String CDB_FAX_ENDPOINT = HMG_ENDPOINT + '/' + CDB_SCOPE;
    
    public static final String CDB_WEB_MSG_TYPE_ID = 'CDB_Web';
    public static final String CDB_WEB_ENDPOINT = HMG_ENDPOINT + '/' + CDB_SCOPE;
    
    public static final String VSS_MAIN_MSG_TYPE_ID = 'VSS_Main';
    public static final String VSS_MAIN_ENDPOINT = HMG_ENDPOINT + '/' + VSS_SCOPE;
    
/********************************************************************************
 * コールアウト - To PingFederate
 ********************************************************************************/
    
    public static final String OAUTH_ENDPOINT = System.Label.AP10_PRM_0002;
    public static final String OAUTH_CONTENT_TYPE = 'application/x-www-form-urlencoded';
    public static final String OAUTH_CLIENTID = System.Label.AP10_PRM_0003;
    public static final String OAUTH_USERNAME = System.Label.AP10_DFN_0003;
    public static final String OAUTH_VALIDATORID = System.Label.AP10_DFN_0004;
    
    public static final String OAUTH_APEX_EXCEPTION_TIMING = 'Authorization';
    
}