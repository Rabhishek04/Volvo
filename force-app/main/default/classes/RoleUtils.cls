public class RoleUtils {
	//Returns all the Regions from the role hierarchy the user has access to.
	//The method will return null, if the logged in user belongs to a Sales department    
    @auraEnabled
    public static Map<Id, UserRole> GetRegions(Id userId){
        User usr = [Select Id, Name, UserRoleId From User Where Id = :userId];
        UserRole rol = [Select Id, Name, DeveloperName, ParentRoleId From UserRole Where Id =: usr.UserRoleId];
        Map<Id,UserRole> subordinate_roles = null;
        if(string.isEmpty(rol.ParentRoleId)){
            subordinate_roles = new Map<Id,UserRole>([
                    SELECT Id, Name, DeveloperName, ParentRoleId
                    FROM UserRole
                    WHERE ParentRoleId =: rol.Id
                ]);
        }
        if(rol.DeveloperName.contains('Region')){
            subordinate_roles = new Map<Id,UserRole>();
            subordinate_roles.put(rol.Id, rol);
        }
        return subordinate_roles;
    }
    
    //Returns all the sales managers in a given region. The method returns null if the input role is not of type
    //region
    @auraEnabled
    public static Map<Id, User> GetSalesManagers(Id roleId){
        UserRole rol = [Select Id, Name, DeveloperName, ParentRoleId From UserRole Where Id =: roleId];
        System.debug(rol.DeveloperName.contains('Region'));
        System.debug(rol.DeveloperName);
        if(!rol.DeveloperName.contains('Region')){
            return null;
        }
        Map<Id,UserRole> salesManagerRole =
                new Map<Id,UserRole>([
                    SELECT Id, Name, DeveloperName, ParentRoleId
                    FROM UserRole
                    WHERE ParentRoleId =: roleId
                ]);
        Map<Id, User> salesManagers = 
            new Map<Id,User>([Select Id, Name, UserRoleId From User Where UserRoleId IN :salesManagerRole.keySet()]);
            System.debug('salesManagers '+salesManagers);
    	return salesManagers;
    }
    
    //Returns all the users in the sales department for a given Sales Manager. The method returns null if the input role is not of type
    //SalesManager
    @auraEnabled
    public static Map<Id,User> GetSalesDepartment(Id userId) {
        User usr = [Select Id, Name, UserRoleId From User Where Id = :userId];
        UserRole rol = [Select Id, Name, DeveloperName, ParentRoleId From UserRole Where Id =: usr.UserRoleId];
        Map<Id, User> salesDepartment = null;
        System.debug(rol.DeveloperName.contains('SalesManager'));
        System.debug(rol.ParentRoleId);
        if(!string.isEmpty(rol.ParentRoleId) && rol.DeveloperName.contains('SalesManager')){
            Map<Id,UserRole> salesManagerRole = new Map<Id,UserRole>([
                    SELECT Id, Name, DeveloperName, ParentRoleId
                    FROM UserRole
                    WHERE ParentRoleId =: rol.Id
                ]);
            salesDepartment = 
            new Map<Id,User>([Select Id, Name, UserRoleId From User Where UserRoleId IN :salesManagerRole.keySet()]);
        }
        return salesDepartment;
    }
    
    //Returns all the subordinate users. recordId can be role or userid
    public static Set<ID> GetSubordinateUsers(Id recordId, boolean isRole) {
  	
    	// get requested user's role
    	 Id roleId;
        if(! isRole){
            roleId = [select UserRoleId from User where Id = :recordId].UserRoleId;
        }else{
            roleId = recordId;
        }
    
        // get all of the roles underneath the user
        Set<Id> allSubRoleIds = getAllSubRoleIds(new Set<ID>{roleId});
        // get all of the ids for the users in those roles
        Map<Id,User> users = new Map<Id, User>([Select Id, Name From User where 
          UserRoleId IN :allSubRoleIds]);
        // return the ids as a set so you can do what you want with them
        return users.keySet();
  	
  	}
	
      public static Set<ID> GetAllSubRoleIds(Set<ID> roleIds) {
        
        Set<ID> currentRoleIds = new Set<ID>();
        
        // get all of the roles underneath the passed roles
        for(UserRole userRole :[select Id from UserRole where ParentRoleId 
          IN :roleIds AND ParentRoleID != null])
        currentRoleIds.add(userRole.Id);
        
        // go fetch some more rolls!
        if(currentRoleIds.size() > 0)
          currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
    
        return currentRoleIds;
        
      }

}