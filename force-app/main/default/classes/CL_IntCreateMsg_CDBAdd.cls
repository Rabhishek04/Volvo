/********************************************************************************
 * CDBAddメッセージを作成するクラス
 ********************************************************************************/
public class CL_IntCreateMsg_CDBAdd extends CL_IntCreateMsg {
    
/********************************************************************************
 * Constructor
 ********************************************************************************/
 
    /**
     * 初期化処理
     * 
     * @param argOldRecMap 更新前レコードMAP
     * @param argNewRecMap 更新後レコードMAP
     */
    public CL_IntCreateMsg_CDBAdd(Map<Id,sObject> argOldRecMap, Map<Id,sObject> argNewRecMap){
        super(argOldRecMap, argNewRecMap);
        endPoint = CL_IntConst.CDB_ADD_ENDPOINT;
        msgTypeId = CL_IntConst.CDB_ADD_MSG_TYPE_ID;
        this.createMsg();
    }
    
/********************************************************************************
 * Private Method
 ********************************************************************************/
     
    /**
     * @override
     */
    private Boolean chkSndFlg(sObject newRec){
    
        // 複数件同時更新の場合は、全送信処理を行わない
        if((Boolean)newRec.get('EmergencyFlg_Add__c') && newRecMap.size() == 1){
            return true;
        }
        
        if(newRec.get('ShokaiSoshin__c') == False && (Boolean)newRec.get('OwnerAssign__c')){
            return true;
        }
        return false;
    }
     
    /**
     * @override
     */
    private void createBodyMsg(){
        for(Id id : idSet){
            sObject rec = newRecMap.get(id);
            JSONGenerator json = JSON.createGenerator(false);
            
            json.writeStartObject();
            json.writeStringField('MessageName', msgTypeId);
            json.writeStringField('Action', 'add');
            json.writeStringField('AccountId', chgNullToBlank(rec.Id));
            json.writeStringField('PartyId', chgNullToBlank((String)rec.get('Party_Id__c')));
            json.writeStringField('DealerPartyId', chgNullToBlank((String)rec.get('OwnerDealerPartyID__c')));
            json.writeStringField('AccountName', chgNullToBlank((String)rec.get('Name')));
            json.writeStringField('BillingStreet', chgNullToBlank((String)rec.get('BillingStreet')));
            json.writeStringField('BillingPostalCode', chgNullToBlank((String)rec.get('BillingPostalCode')));
            json.writeStringField('BillingCountryCode', chgNullToBlank((String)rec.get('BillingCountryCode')));
            json.writeStringField('BillingState', chgNullToBlank((String)rec.get('BillingState')));
            json.writeStringField('BillingCity', chgNullToBlank((String)rec.get('BillingCity')));
            json.writeStringField('Phone', chgNullToBlank((String)rec.get('Phone')));
            json.writeStringField('Fax', chgNullToBlank((String)rec.get('Fax')));
            json.writeStringField('Website', chgNullToBlank((String)rec.get('Website')));
            json.writeEndObject();
            
            reqMap.put(rec.Id ,json.getAsString());
        }
    }
}