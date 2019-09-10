/********************************************************************************
 * Assetを管理するクラス。
 * トリガなどで多量のメソッドを実装したときに、
 * DMLの回数が増えないようDML更新はこのクラスに任せる。
 ********************************************************************************/
public class CL_MgmtAsset {

/********************************************************************************
 * Field
 ********************************************************************************/

    private List<Asset> dmlAssetForIns;
    private Map<Id,Asset> dmlAssetForUpd;
    private Set<Id> dmlAssetForDel;
    
/********************************************************************************
 * Constructor
 ********************************************************************************/

    /**
     * コンストラクタ
     */
    public CL_MgmtAsset(){
        refreshMemberDMLParam();
    }
    
/********************************************************************************
 * Public Method
 ********************************************************************************/

    /**
     * メンバ変数[dmlAsserForIns]のセッター
     * 
     * @param argAsset メンバ変数[dmlAssetForIns]にセットしたいAssetレコード
     */
    public void setDmlAssetForIns(Asset argAsset){
        if(argAsset != null){
            dmlAssetForIns.add(argAsset);
        }
    }
    
    /**
     * メンバ変数[dmlAsserForIns]のセッター
     * 
     * @param argAssetList メンバ変数[dmlAssetForIns]にセットしたいAssetレコード
     */
    public void setDmlAssetForIns(List<Asset> argAssetList){
        for(Asset ass : argAssetList){
            setDmlAssetForIns(ass);
        }
    }

    /**
     * メンバ変数[dmlAsserForUpd]のセッター
     * 
     * レコードタイプを指定していないargAssetを引数に渡しても、
     * dmlAssetForUpdでレコードタイプが指定されてしまうためレコードタイプの更新処理時には要注意。
     * 
     * @param argAsset メンバ変数[dmlAssetForUpd]にセットしたいAssetレコード
     */
    public void setDmlAssetForUpd(Asset argAsset){
        Asset ass;
        
        if(dmlAssetForUpd.containsKey(argAsset.id)){
            ass = dmlAssetForUpd.get(argAsset.id);
        } else {
            ass = new Asset();
        }
        
        for(String itemName : argAsset.getPopulatedFieldsAsMap().keySet()){
            ass.put(itemName, argAsset.getPopulatedFieldsAsMap().get(itemName));
        }
        
        dmlAssetForUpd.put(ass.Id, ass);
    }

    /**
     * メンバ変数[dmlAsserForUpd]のセッター
     * 
     * レコードタイプを指定していないargAssetを引数に渡しても、
     * dmlAssetForUpdでレコードタイプが指定されてしまうためレコードタイプの更新処理時には要注意。
     * 
     * @param argAssetList メンバ変数[dmlAssetForUpd]にセットしたいAssetレコード
     */
    public void setDmlAssetForUpd(List<Asset> argAssetList){
        for(Asset ass : argAssetList){
            setDmlAssetForUpd(ass);
        }
    }

    /**
     * メンバ変数[dmlAsserForDel]のセッター
     * 
     * @param argAssetId メンバ変数[dmlAssetForDel]にセットしたいAssetレコードのSFID
     */
    public void setDmlAssetForDel(Id argAssetId){
        if(argAssetId != null){
            dmlAssetForDel.add(argAssetId);
        }
    }

    /**
     * メンバ変数[dmlAsserForDel]のセッター
     * 
     * @param argAssetIdList メンバ変数[dmlAssetForDel]にセットしたいAssetレコードのSFID
     */
    public void setDmlAssetForDel(List<Id> argAssetIdList){
        for(Id assetId : argAssetIdList){
            setDmlAssetForDel(assetId);
        }
    }

    /**
     * DML処理を実行する。
     */
    public void executeDML(){
        
        // insert処理
        if(dmlAssetForIns.size() >= 1){
            Database.insert(dmlAssetForIns, false);
        }
        
        // update処理
        if(dmlAssetForUpd.size() >= 1){
            Database.update(dmlAssetForUpd.values(), false);
        }
        
        // delete処理
        if(dmlAssetForDel.size() >= 1){
            Database.delete(new List<Id>(dmlAssetForDel), false);
        }
        
        // DML処理用メンバ変数の初期化
        refreshMemberDMLParam();
    }
    
    
    
/********************************************************************************
 * Private Method
 ********************************************************************************/

    /**
     * DML処理用メンバ変数を初期化する。
     */
    private void refreshMemberDMLParam(){
        dmlAssetForIns = new List<Asset>();
        dmlAssetForUpd = new Map<Id,Asset>();
        dmlAssetForDel = new Set<Id>();
    }

}