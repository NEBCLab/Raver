import User "../Module/User";
import Tweet "../Module/Tweet";
import HashMap "mo:base/HashMap";
import Array "mo:base/Array";
import Hash "mo:base/Hash";
import Principal "mo:base/Principal";
import List "mo:base/List";
import Nat "mo:base/Nat";
import Option "mo:base/Option";
import Text "mo:base/Text";
import TrieSet "mo:base/TrieSet";

module{
    type User = User.User;
    type Tweet = Tweet.Tweet;
    type ShowUser = User.showUser;

    public class userDB(){
        // uid -> user profile
        private var userDB = HashMap.HashMap<Principal, User>(1, Principal.equal, Principal.hash);
        // uid -> tweets tid
        private var userTweet = HashMap.HashMap<Principal, TrieSet.Set<Nat>>(1, Principal.equal, Principal.hash);
        // follower : user uid -> follower uid List
        private var follower = HashMap.HashMap<Principal, TrieSet.Set<Principal>>(1, Principal.equal, Principal.hash);
        // follow user : user uid -> follow uid List
        private var follow = HashMap.HashMap<Principal, TrieSet.Set<Principal>>(1, Principal.equal, Principal.hash);        
        // get user principal by tweet id
        private var tweet_user = HashMap.HashMap<Nat, Principal>(1, Nat.equal, Hash.hash);
        // get user principal by username
        private var userName2Uid = HashMap.HashMap<Text, Principal>(1, Text.equal, Text.hash);

        private var bioMap = HashMap.HashMap<Principal,Text>(1, Principal.equal, Principal.hash);



//*******************************  User *******************************************
        /**
        * @param user : User
        */
        public func addUser(user : User) : Bool{
            if(isUserExist(user.uid) or isUserNameUsed(user.username)){
                false
            }else{
                userDB.put(user.uid, user);
                userName2Uid.put(user.username, user.uid);
                true
            }
        };

        /**
        * delete user from user database
        * @param uid -> owner : Princiapl
        * @return Bool -> successful : true; failed : false
        */
        public func deleteUser(uid : Principal) : Bool{
            if(isUserExist(uid)){
                //operator is owner
                var operator_ = switch(getUserProfile(uid)){
                    case(?user){
                        user.uid
                    };
                    case(null) {
                        return false;
                    };
                };
                assert(uid == operator_);
                userDB.delete(uid);
                userTweet.delete(uid);
                deleteFollowMap(uid);
                bioMap.delete(uid);
                switch(getUserNameByPrincipal(uid)){
                    case null{
                    };
                    case(?text){
                        userName2Uid.delete(text);
                    };
                };
                true
            }else{
                false
            }
        };

        /**
        * for security , operator must give uid , database should not use User.uid change
        * as changer's uid
        */
        public func changeUserProfile(uid : Principal, user : User) : Bool{
            if(isUserExist(uid)){
                var user_uid = switch(getUserProfile(user.uid)){
                    case(?user){
                        user.uid
                    };
                    case(_){
                        return false;
                    };
                };
                assert(uid == user_uid);
                var name_uid = switch(userName2Uid.get(user.username)){
                    case null{
                        ignore userDB.replace(uid, user);
                        ignore userName2Uid.replace(user.username, uid);
                        return true;
                    };
                    case(?principal){
                        principal;
                    };
                };
                if(isUserNameUsed(user.username) and name_uid!=uid ){return false;};
                ignore userDB.replace(uid, user);
                ignore userName2Uid.replace(user.username, uid);
                true
            }else{
                false
            }
        };

        /**
        * @param uid : user's principal
        * @return ?User : if user existd
        */
        public func getUserProfile(uid : Principal) : ?User{
            switch(userDB.get(uid)){
                case (?user){ ?user };
                case(_) { null };
            }
        };

        public func getShowUserProfile(uid : Principal) : ?ShowUser{
            switch(userDB.get(uid)){
                case (?user){ 
                     ?{
                        uid = user.uid;
                        nickname = user.nickname;
                        username = user.username;
                        avatarimg = user.avatarimg;
                        bio = getBio(user.uid);
                     }
                };
                case(_) { null };
            }
        };

        /**private function : is user is existed**/
        public func isUserExist(uid : Principal) : Bool{
            switch(userDB.get(uid)){
                case(?user){ true };
                case(_){ false };
            }
        };

/****************************  Tweet *********************************************************/

        /**
        * append tweet id to user profile
        * @param uid : user principal
        * @param tid : tweet id
        */
        public func addTweet(uid : Principal, tid : Nat) : Bool{
            if(isUserExist(uid)){
                switch(userTweet.get(uid)){
                    case(?set){
                        var newSet = TrieSet.put<Nat>(set,tid,Hash.hash(tid),Nat.equal);
                        userTweet.put(uid, newSet);
                        putTweetUser(tid, uid);
                    };
                    case(_){
                        var tempSet = TrieSet.empty<Nat>();
                        tempSet := TrieSet.put<Nat>(tempSet,tid,Hash.hash(tid),Nat.equal);
                        userTweet.put(uid, tempSet);
                        putTweetUser(tid, uid);
                    }
                };
                true
            }else{
                false
            }
        };

        /**
        * get user's all tweet id
        * @param uid : user's principal
        * @return user's tweet -> ?[Nat]  : null || [Nat]
        */
        public func getUserAllTweets(uid : Principal) : ?[Nat]{
            switch(userTweet.get(uid)){
                case null{ null };
                case(?set){
                    var array = TrieSet.toArray<Nat>(set);
                    Option.make<[Nat]>(Array.sort<Nat>(array, Nat.compare))
                };
            };
        };

        

        /** tweet_user database **/
        private func putTweetUser(tid : Nat, uid : Principal){
            tweet_user.put(tid, uid);
        };

        /** tweet_user database **/
        public func deleteTweetUser(uid : Principal, tid : Nat){
            switch(userTweet.get(uid)){
                case null{};
                case(?set){
                    var newSet = TrieSet.delete<Nat>(set,tid,Hash.hash(tid),Nat.equal);
                    ignore userTweet.replace(uid, newSet);
                };
            };
            tweet_user.delete(tid);
        };

        // get tweet's user principal(uid)
        public func getUidByTid(tid : Nat) : ?Principal{
            tweet_user.get(tid)
        };


        //**********************follow part****************************/

        /**
        * add follower
        * @param user : followed user principal
        * @param follower : follower user Principal 
        */
        public func addFollower(user : Principal, follower_user : Principal) : Bool{
            assert(isUserExist(user));
            assert(isUserExist(follower_user));
            switch(follower.get(user)){
                case(null){ 
                    var tempSet=TrieSet.empty<Principal>();
                    tempSet := TrieSet.put<Principal>(tempSet,follower_user,Principal.hash(follower_user),Principal.equal);
                    follower.put(user, tempSet);
                };  
                case(?set){
                    var newSet = TrieSet.put<Principal>(set, follower_user, Principal.hash(follower_user),Principal.equal);
                    ignore follower.replace(user, newSet);
                };
            };
            true
        };

        /**
        * attention people
        */
        public func addFollow(user : Principal, follower_user : Principal) : Bool{
            assert(isUserExist(user));
            assert(isUserExist(follower_user));
            switch(follow.get(follower_user)){
                case(null){ 
                    var tempSet=TrieSet.empty<Principal>();
                    tempSet := TrieSet.put<Principal>(tempSet,user,Principal.hash(user),Principal.equal);
                    follow.put(follower_user, tempSet);
                };  
                case(?set){
                    var newSet = TrieSet.put<Principal>(set, user, Principal.hash(user),Principal.equal);
                    ignore follow.replace(follower_user, newSet);
                };
            };
            true
        };

        public func cancelFollow(user : Principal, follower_user : Principal) : Nat{
            var check = isAFollowedByB(user, follower_user);
            if(check == 1){
                switch(follow.get(follower_user)){
                    case(null){
                        return 10;
                    };
                    case(?set){
                        var newSet = TrieSet.delete<Principal>(set, user, Principal.hash(user), Principal.equal);
                        ignore follow.replace(follower_user, newSet);
                        return 1;
                    };
                };
            }else{
                return check;
            };
        };

        public func cancelFollower(user : Principal, follower_user : Principal) : Nat{
            var check = isAFollowedByB(user, follower_user);
            if(check == 1){
                switch(follower.get(user)){
                    case(null){
                        return 10;
                    };
                    case(?set){
                        var newSet = TrieSet.delete<Principal>(set, follower_user, Principal.hash(follower_user), Principal.equal);
                        ignore follower.replace(user, newSet);
                        return 1;
                    };
                };
            }else{
                return check;
            };
        };


        public func getFollow(user : Principal) : [Principal]{
            if(isUserExist(user)){
                switch(follow.get(user)){
                    case null {
                        []
                    };
                    case(?set){
                        TrieSet.toArray<Principal>(set)
                    };
                };
            }else{
                []
            };      
        };

        public func getFollower(user : Principal) : [Principal]{
            if(isUserExist(user)){
                switch(follower.get(user)){
                    case null {
                        []
                    };
                    case(?set){
                        TrieSet.toArray<Principal>(set)
                    };
                };
            }else{
                []
            };
        };

        public func isAFollowedByB(user_A : Principal, user_B : Principal) : Nat{
            if(isUserExist(user_A)){
                if(isUserExist(user_B)){
                    switch(follower.get(user_A)){
                        case null {
                            return 10; //No one follows A
                        };
                        case(?set){
                            if(TrieSet.mem<Principal>(set, user_B, Principal.hash(user_B),Principal.equal)) return 1;
                            return 0; //false
                        };
                    };
                }else{
                    return 7; //B does not exist
                };
            }else{
                return 6; //A does not exist
            };
        };

        private func deleteFollowMap(user : Principal) {
            follower.delete(user);
            follow.delete(user);
        };
        
        //**********************username part****************************/
        public func isUserNameUsed(userName : Text) : Bool{
            switch(userName2Uid.get(userName)){
                case null{
                    false
                };
                case(?principal){
                    true
                }
            };
        };

        public func getPrincipalByUserName(userName : Text) : ?Principal{
            switch(userName2Uid.get(userName)){
                case null{
                    null
                };
                case(?principal){
                    Option.make<Principal>(principal)
                };
            };
        };

        public func getUserNameByPrincipal(uid : Principal) : ?Text{
            switch(userDB.get(uid)){
                case null{
                    null
                };
                case(?user){
                    Option.make<Text>(user.username)
                };
            };
        };
        //---------------------bio----------------------
        public func putBio(uid : Principal, bioText : Text) {
            if(isUserExist(uid))
            bioMap.put(uid, bioText);
        };

        public func getBio(uid : Principal) : Text{
            switch(bioMap.get(uid)){
                case null{
                    "这个人很懒，什么都没有留下~"
                };
                case(?text){
                    text
                };
            };
        };

    };
};