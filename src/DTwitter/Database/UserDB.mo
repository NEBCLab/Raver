import User "../Module/User";
import Tweet "../Module/Tweet";
import HashMap "mo:base/HashMap";
import Array "mo:base/Array";
import Hash "mo:base/Hash";
import Principal "mo:base/Principal";
import List "mo:base/List";
import Nat "mo:base/Nat";
import Option "mo:base/Option";
import TrieSet "mo:base/TrieSet"

module{
    type User = User.User;
    type Tweet = Tweet.Tweet;

    public class userDB(){
        // uid -> user profile
        private var userDB = HashMap.HashMap<Principal, User>(1, Principal.equal, Principal.hash);
        // uid -> tweets tid
        private var userTweet = HashMap.HashMap<Principal, [Nat]>(1, Principal.equal, Principal.hash);
        // follower : user uid -> follower uid List
        private var follower = HashMap.HashMap<Principal, TrieSet.Set<Principal>>(1, Principal.equal, Principal.hash);
        // follow user : user uid -> follow uid List
        private var follow = HashMap.HashMap<Principal, TrieSet.Set<Principal>>(1, Principal.equal, Principal.hash);        
        // get user principal by tweet id
        private var tweet_user = HashMap.HashMap<Nat, Principal>(1, Nat.equal, Hash.hash);


//*******************************  User *******************************************
        /**
        * @param user : User
        */
        public func addUser(user : User) : Bool{
            if(isExist(user.uid)){
                false
            }else{
                userDB.put(user.uid, user);
                true
            }
        };

        /**
        * delete user from user database
        * @param uid -> owner : Princiapl
        * @return Bool -> successful : true; failed : false 
        */
        public func deleteUser(uid : Principal) : Bool{
            if(isExist(uid)){
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
            if(isExist(uid)){
                var user_uid = switch(getUserProfile(user.uid)){
                    case(?user){
                        user.uid
                    };
                    case(_){
                        return false;
                    };
                };
                assert(uid == user_uid);
                ignore userDB.replace(uid, user);
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

        /**private function : is user is existed**/
        public func isExist(uid : Principal) : Bool{
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
            if(isExist(uid)){
                switch(userTweet.get(uid)){
                    case(?tweet){
                        var tweetArray : [Nat] = Array.append(tweet, [tid]);
                        ignore userTweet.replace(uid, tweetArray);
                        putTweetUser(tid, uid);
                    };
                    case(_){
                        userTweet.put(uid, [tid]);
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
            userTweet.get(uid)
        };

        //TODO : tweet [] -> Tree
        public func deleteTweet(uid : Principal, tid : Nat) : Bool{
            var newArray : [Nat] = []; 
            if(isExist(uid)){
                var tweet : [Nat] = switch(userTweet.get(uid)){
                    case(null) { [] };
                    case(?array) { array };
                };
                for(v in tweet.vals()){
                    if(v != tid){
                        newArray := Array.append(newArray, [v]);
                    }
                };
                ignore userTweet.replace(uid, newArray);
                deleteTweetUser(tid);
                true
            }else{
                false
            }
        };

        /** tweet_user database **/
        private func putTweetUser(tid : Nat, uid : Principal){
            tweet_user.put(tid, uid);
        };

        /** tweet_user database **/
        private func deleteTweetUser(tid : Nat){
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
            assert(isExist(user));
            assert(isExist(follower_user));
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
            assert(isExist(user));
            assert(isExist(follower_user));
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


        public func getFollow(user : Principal) : ?[Principal]{
            if(isExist(user)){
                switch(follow.get(user)){
                    case null {
                        Option.make<[Principal]>([])
                    };
                    case(?set){
                        Option.make<[Principal]>(TrieSet.toArray<Principal>(set))
                    };
                };
            }else{
                null
            };      
        };

        public func getFollower(user : Principal) : ?[Principal]{
            if(isExist(user)){
                switch(follower.get(user)){
                    case null {
                        Option.make<[Principal]>([])
                    };
                    case(?set){
                        Option.make<[Principal]>(TrieSet.toArray<Principal>(set))
                    };
                };
            }else{
                null
            };
        };

        public func isAFollowedByB(user_A : Principal, user_B : Principal) : Nat{
            if(isExist(user_A)){
                if(isExist(user_B)){
                    switch(follower.get(user_A)){
                        case null {
                            return 10; //Unknown Error
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
        }

    };
};