/********************************************************************************
 * CreateQuoteVSSコンポーネントに持たせているクラス
 * 営業プロセスレコードとそれらに関連する情報を一元的に管理させている
 ********************************************************************************/
 
public class CL_OpportunityController{

/********************************************************************************
 * Field(@AuraEnabled)
 ********************************************************************************/

    @AuraEnabled
    public Opportunity opp {get; private set;}
    
    @AuraEnabled
    public String urlToVSS {
        get{ return 
            'https://' + System.Label.AP00_PRM_0001 + '/' + System.Label.AP00_PRM_0002 + '/' + System.Label.AP00_DEF_0008 + 
            '?nextview=' + System.Label.AP00_DEF_0010 + 
            '&System=' + System.Label.AP00_DEF_0011 + 
            '&RUPartyId=' + opp.Owner.DealPartyId__c + 
            '&CustomerPartyId=' + opp.Account.Party_ID__c + 
            '&Brand=' + oppBrand + 
            '&OpportunityId=' + opp.OpportunityIDFormula__c + 
            '&OpportunityName=' + opp.Name + 
            '&TimeOffsetHidden=' + System.Label.AP00_DEF_0012
        ;}
        private set;
    }
    
/********************************************************************************
 * Field
 ********************************************************************************/
 
    private String oppBrand;

/********************************************************************************
 * Constructor
 ********************************************************************************/

    /**
     * 営業プロセスレコードを取得し、ブランド情報を割り出す
     * 
     * @param oppId 本クラスで管理する営業プロセスレコードのSFID
     */
    public CL_OpportunityController(id oppId){
        opp = [
            SELECT o.Id, o.AnkenShonin__c, o.OpportunityIDFormula__c, o.Name, o.Account.Party_ID__c, o.UDShagata__c, u.DealPartyId__c 
            FROM Opportunity o, o.Owner u 
            WHERE id = :oppId
            LIMIT 1
        ];
        
        refreshBrand(opp.UDShagata__c);
    }
    
/********************************************************************************
 * Public Method
 ********************************************************************************/
 
    /**
     * メンバ変数の営業プロセスからブランドを割り出すメソッド
     * 
     * @param udShagata UD車型
     */
    private void refreshBrand(String udShagata){
        if([SELECT MasterLabel FROM VolvoModelList__mdt WHERE MasterLabel = :udShagata].size() >= 1){
            oppBrand = System.Label.AP00_DEF_0014;
        } else {
            oppBrand = System.Label.AP00_DEF_0013;
        }
    }
    
}