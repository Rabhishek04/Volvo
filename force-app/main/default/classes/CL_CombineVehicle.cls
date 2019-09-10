/********************************************************************************
 * 車両（テンポラリ）レコードの情報を車両レコードにマージするクラス
 * 振る舞いだけを持つstaticクラス
 ********************************************************************************/
public class CL_CombineVehicle{

    /**
     * Assetレコード保存時に、
     * 必要に応じてTemporaryVehicle__cレコードから情報を取得してくるメソッド
     * 
     * @param oldAssetMap 更新前車両レコードマップ
     * @param newAssetList 更新後車両レコードマップ(before insert時にnullになってしまうためリスト取得)
     */
    public static void combineVehicleFromAsset(Map<Id, Asset> oldAssetMap, List<Asset> newAssetList){
        
        // VehicleとマージされるAssetレコードを抽出する
        Map<String, Asset> chassisCodeMap = new Map<String, Asset>();
        
        if(oldAssetMap == null && newAssetList != null){    // insertの時
            for(Asset ass : newAssetList){
                if(String.isNotBlank(ass.ChassisCode__c)){
                    chassisCodeMap.put(ass.ChassisCode__c, ass);
                }
            }
        } else if (oldAssetMap != null && newAssetList != null) {    // updateの時
            for(Asset ass : newAssetList){
                if(oldAssetMap.containsKey(ass.Id)){
                    Asset oldAss = oldAssetMap.get(ass.Id);
                    if(String.isNotBlank(ass.ChassisCode__c) && !ass.ChassisCode__c.equals(oldAss.ChassisCode__c)){
                        chassisCodeMap.put(ass.ChassisCode__c, ass);
                    }
                }
            }
        }
        
        // 被マージ対象のAssetレコードがない場合処理終了
        if(chassisCodeMap.size() == 0){
            return;
        }
        
        // 同一のシャシーを持つTemporaryVehicle__cレコードを取得
        List<TemporaryVehicle__c> tempVehicleList = [
            SELECT Name, AccountPartyId__c, UDTrust__c, VIN__c, BrandNameVDA__c, BrandNameLDS__c, BodyShiyoVDA__c,
                NumberofRegistratio__c, SyaryoKatashikiVDA__c, SyaryoKatashikiLDS__c, HMLSizeCategoryofVehicleVDA__c,
                HMLSizeCategoryofVehicleLDS__c, EngineType__c, MissionType__c, ChassisNumber__c, ChassisSeries__c, ChassisCode__c, 
                OMNoVDA__c, ContractStartDate__c, ContractDuration__c, ExpiryDate__c, Status__c, ContractDescription__c
            FROM TemporaryVehicle__c
            WHERE ChassisCode__c = :chassisCodeMap.keySet()
        ];
        
        // マージ対象のTemporaryVehicle__cレコードがない場合処理終了
        if(tempVehicleList.size() == 0){
            return;
        }
        
        // TemporaryVehicle__cとAssetレコードをマージする
        combineVehicle(chassisCodeMap, tempVehicleList);
    }

    /**
     * TemporaryVehicle__cレコード保存時に、
     * 必要に応じてAssetレコードに自身の車両情報を付け加えて保存するメソッド
     * 
     * @param oldVehicleMap 更新前車両（テンポラリ）レコードマップ
     * @param newVehicleMap 更新後車両（テンポラリ）レコードマップ
     * @param assetMgmt 車両レコードの更新を管理するインスタンス
     */
    public static void combineVehicleFromVehicle(
        Map<ID, TemporaryVehicle__c> oldVehicleMap, 
        Map<ID, TemporaryVehicle__c> newVehicleMap,
        CL_MgmtAsset assetMgmt){
        
        //UDブランド名を取得してSetに格納
        Set<String> setUDBland = new Set<String>();
        for(UDBland__mdt md : [SELECT MasterLabel FROM UDBland__mdt]){
            setUDBland.add(md.MasterLabel);
        }
        
        // AssetにマージされるVehicleレコードを抽出する(自社車両と、他社車両を別々に管理）
        Map<String, TemporaryVehicle__c> chassisCodeMapUD = new Map<String, TemporaryVehicle__c>();
        Map<String, TemporaryVehicle__c> chassisCodeMapNoneUD = new Map<String, TemporaryVehicle__c>();
        
        if(oldVehicleMap == null && newVehicleMap != null){    // insertの時
            for(TemporaryVehicle__c vehicle : newVehicleMap.values()){
                if(String.isNotBlank(vehicle.ChassisCode__c)){
                    if(setUDBland.contains(vehicle.BrandName__c)){    // UDブランドなら
                        chassisCodeMapUD.put(vehicle.ChassisCode__c, vehicle);    
                    } else {    // UDブランドじゃない場合
                        chassisCodeMapNoneUD.put(vehicle.ChassisCode__c, vehicle);
                    }
                }
            }
        } else if (oldVehicleMap != null && newVehicleMap != null){    //updateの時
            for(TemporaryVehicle__c vehicle : newVehicleMap.values()){
                if(oldVehicleMap.containsKey(vehicle.Id)){
                    if(String.isNotBlank(vehicle.ChassisCode__c)){
                        if(changeVehicleInfo(oldVehicleMap.get(vehicle.Id), vehicle)){    // マージする項目が変わっていたら
                            if(setUDBland.contains(vehicle.BrandName__c)){    // UDブランドなら
                                chassisCodeMapUD.put(vehicle.ChassisCode__c, vehicle);    
                            } else {    // UDブランドじゃない場合
                                chassisCodeMapNoneUD.put(vehicle.ChassisCode__c, vehicle);
                            }
                        }
                    }
                }
            }
        }
        
        // マージ対象のAssetレコードを取得する。
        List<Asset> assetList = [
            SELECT ID, ChassisCode__c 
            FROM Asset 
            WHERE ChassisCode__c = :chassisCodeMapUD.keySet() OR ChassisCode__c = :chassisCodeMapNoneUD.keySet()
        ];
        
        // 取得したAssetレコードについてChassiscodeをキーにしたMAPに変換する
        Map<String, Asset> assetMapForUpd = new Map<String, Asset>();
        
        for(Asset ass : assetList){
            assetMapForUpd.put(ass.ChassisCode__c, ass);
        }
        
        // 自社車両はアップデートのみのためマージするだけでいい
        combineVehicle(assetMapForUpd, chassisCodeMapUD.values());
        
        // 他社車両もAssetテーブルにあるものについてまずマージする
        combineVehicle(assetMapForUpd, chassisCodeMapNoneUD.values());
        
        // 他社車両で、Assetテーブルにないものについてはinsertする(combineVehicleメソッドを使うために空のassetMapを作る)
        Map<String, Asset> assetMapForIns = new Map<String, Asset>();
        for(TemporaryVehicle__c vehicle : chassisCodeMapNoneUD.values()){
            if(!assetMapForUpd.containsKey(vehicle.ChassisCode__c)){    // 取得してきたAssetになければinsert用のassetMapにaddする
                assetMapForIns.put(vehicle.ChassisCode__c, new Asset());
            }
        }
        combineVehicle(assetMapForIns, chassisCodeMapNoneUD.values());
        
        // Assetのマネジメントクラスに更新するAssetレコードを渡す
        assetMgmt.setDmlAssetForUpd(assetMapForUpd.values());
        assetMgmt.setDmlAssetForIns(assetMapForIns.values());
    }

    /**
     * TemporaryVehicle__cレコード保存時に、
     * 必要に応じてAssetレコードの車両情報を削除するメソッド
     * 
     * @param oldVehicleMap 更新前車両（テンポラリ）レコードマップ
     * @param newVehicleMap 更新後車両（テンポラリ）レコードマップ
     * @param assetMgmt 車両レコードの更新を管理するインスタンス
     */
    public static void deleteVehicleInfoFromVehicle(
        Map<Id, TemporaryVehicle__c> oldVehicleMap, 
        Map<ID, TemporaryVehicle__c> newVehicleMap,
        CL_MgmtAsset assetMgmt){
        
        // 削除されるTemporaryVehicle__cレコードのChassisCodeを抽出する
        Set<String> cCode = new Set<String>();
        
        if(newVehicleMap == null){    // 一応deleteイベントであることを確認する
            for(TemporaryVehicle__c vehicle : oldVehicleMap.values()){
                if(String.isNotBlank(vehicle.ChassisCode__c)){
                    cCode.add(vehicle.ChassisCode__c);
                }
            }
        }
        
        // 車両情報を削除するAssetレコードを取得する
        List<Asset> assetList = [SELECT ID, InstallDate, Noshayoteibi__c FROM Asset WHERE ChassisCode__c = :cCode];
        
        for(Asset ass : assetList){
            if(ass.InstallDate != null || ass.Noshayoteibi__c != null){    // 納車に関する情報がAssetにある場合は車両情報をブランクにする
                ass.AccountId = null;
                ass.UDTrust__c = null;
                ass.BrandNameVDA__c = null;
                ass.BrandNameLDS__c = null;
                ass.BodyShiyoVDA__c = null;
                ass.SyaryoKatashikiVDA__c = null;
                ass.SyaryoKatashikiLDS__c = null;
                ass.HMLSizeCategoryofVehicleVDA__c = null;
                ass.HMLSizeCategoryofVehicleLDS__c = null;
                ass.EngineType__c = null;
                ass.MissionType__c = null;
                ass.OMNoVDA__c = null;
                ass.ContractStartDate__c = null;
                ass.ContractDuration__c = null;
                ass.ExpiryDate__c = null;
                ass.Status__c = null;
                ass.ContractDescription__c = null;
                
                assetMgmt.setDmlAssetForUpd(ass);
            } else {    // 納車情報を持たないAssetは物理削除する
                System.debug(ass.Id);
                assetMgmt.setDmlAssetForDel(ass.Id);
            }
        }
    }
    
    /**
     * TemporaryVehicle__cとAssetレコードをマージするメソッド
     * 
     * @param assetMap シャシコードをキーにしたAssetレコードマップ
     * @param tempVehicleList マージもとのTemporaryVehicle__cレコードリスト
     */
    private static void combineVehicle(Map<String, Asset> assetMap, List<TemporaryVehicle__c> tempVehicleList){
        
        // TemporaryVehicle__cに紐づくアカウントを取得する
        Set<String> accPartyId = new Set<String>();
        
        for(TemporaryVehicle__c tempVehicle : tempVehicleList){
            if(String.isNotBlank(tempVehicle.AccountPartyId__c)){
                accPartyId.add(tempVehicle.AccountPartyId__c);
            }
        }
        
        List<Account> accList = [SELECT Id, Party_Id__c FROM Account WHERE Party_Id__c = :accPartyId];
        
        // 後続の処理で使いやすいようにパーティIDをキーにしたアカウントID検索用MAPを作成する
        Map<String, Id> accMap = new Map<String, Id>();
        
        for(Account acc : accList){
            accMap.put(acc.Party_Id__c, acc.Id);
        }
        
        // マージ処理を行う
        for(TemporaryVehicle__c tempVehicle : tempVehicleList){
            if(assetMap.containsKey(tempVehicle.ChassisCode__c)){
                Asset ass = assetMap.get(tempVehicle.ChassisCode__c);
                ass.Name = tempVehicle.Name;
                ass.UDTrust__c = tempVehicle.UDTrust__c;
                ass.VIN__c = tempVehicle.VIN__c;
                ass.BrandNameVDA__c = tempVehicle.BrandNameVDA__c;
                ass.BrandNameLDS__c = tempVehicle.BrandNameLDS__c;
                ass.BodyShiyoVDA__c = tempVehicle.BodyShiyoVDA__c;
                ass.NumberofRegistratio__c = tempVehicle.NumberofRegistratio__c;
                ass.SyaryoKatashikiVDA__c = tempVehicle.SyaryoKatashikiVDA__c;
                ass.SyaryoKatashikiLDS__c = tempVehicle.SyaryoKatashikiLDS__c;
                ass.HMLSizeCategoryofVehicleVDA__c = tempVehicle.HMLSizeCategoryofVehicleVDA__c;
                ass.HMLSizeCategoryofVehicleLDS__c = tempVehicle.HMLSizeCategoryofVehicleLDS__c;
                ass.EngineType__c = tempVehicle.EngineType__c;
                ass.MissionType__c = tempVehicle.MissionType__c;
                ass.ChassisNumber__c = tempVehicle.ChassisNumber__c;
                ass.ChassisSeries__c = tempVehicle.ChassisSeries__c;
                ass.ChassisCode__c = tempVehicle.ChassisCode__c;
                ass.OMNoVDA__c = tempVehicle.OMNoVDA__c;
                ass.ContractStartDate__c = tempVehicle.ContractStartDate__c;
                ass.ContractDuration__c = tempVehicle.ContractDuration__c;
                ass.ExpiryDate__c = tempVehicle.ExpiryDate__c;
                ass.Status__c = tempVehicle.Status__c;
                ass.ContractDescription__c = tempVehicle.ContractDescription__c;
                if(accMap.containsKey(tempVehicle.AccountPartyId__c)){
                    ass.AccountId = accMap.get(tempVehicle.AccountPartyId__c);
                }
            }
        }
    }
    
    /**
     * TemporaryVehicle__cのマージ項目が変わっていた場合TRUEを返す
     * 
     * @param oldVehicle 更新前車両（テンポラリ）レコード
     * @param newVehicle 更新後車両（テンポラリ）レコード
     */
    private static Boolean changeVehicleInfo(TemporaryVehicle__c oldVehicle, TemporaryVehicle__c newVehicle){
        return 
            (oldVehicle.Name != newVehicle.Name) || 
            (oldVehicle.UDTrust__c != newVehicle.UDTrust__c) || 
            (oldVehicle.VIN__c  != newVehicle.VIN__c ) || 
            (oldVehicle.BrandNameVDA__c != newVehicle.BrandNameVDA__c) || 
            (oldVehicle.BrandNameLDS__c != newVehicle.BrandNameLDS__c) || 
            (oldVehicle.BodyShiyoVDA__c != newVehicle.BodyShiyoVDA__c) || 
            (oldVehicle.NumberofRegistratio__c != newVehicle.NumberofRegistratio__c) || 
            (oldVehicle.SyaryoKatashikiVDA__c != newVehicle.SyaryoKatashikiVDA__c) || 
            (oldVehicle.SyaryoKatashikiLDS__c != newVehicle.SyaryoKatashikiLDS__c) || 
            (oldVehicle.HMLSizeCategoryofVehicleVDA__c != newVehicle.HMLSizeCategoryofVehicleVDA__c) || 
            (oldVehicle.HMLSizeCategoryofVehicleLDS__c != newVehicle.HMLSizeCategoryofVehicleLDS__c) || 
            (oldVehicle.EngineType__c != newVehicle.EngineType__c) || 
            (oldVehicle.MissionType__c != newVehicle.MissionType__c) || 
            (oldVehicle.ChassisNumber__c != newVehicle.ChassisNumber__c) || 
            (oldVehicle.ChassisSeries__c != newVehicle.ChassisSeries__c) || 
            (oldVehicle.OMNoVDA__c != newVehicle.OMNoVDA__c) || 
            (oldVehicle.ContractStartDate__c != newVehicle.ContractStartDate__c) || 
            (oldVehicle.ContractDuration__c != newVehicle.ContractDuration__c) || 
            (oldVehicle.ExpiryDate__c != newVehicle.ExpiryDate__c) || 
            (oldVehicle.Status__c != newVehicle.Status__c) || 
            (oldVehicle.ContractDescription__c != newVehicle.ContractDescription__c) || 
            (oldVehicle.AccountPartyId__c != newVehicle.AccountPartyId__c);
            
    }
}