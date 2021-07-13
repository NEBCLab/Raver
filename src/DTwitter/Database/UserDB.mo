import User "../Module/User";
import Tweet "../Module/Tweet";
import HashMap "mo:base/HashMap";
import Array "mo:base/Array";
import Hash "mo:base/Hash";
import Principal "mo:base/Principal";
import List "mo:base/List";


module{
    type User = User.User;
    type Tweet = Tweet.Tweet;

    public class userDB(){
        // uid -> user profile
        private var userDB = HashMap.HashMap<Principal, User>(1, Principal.equal, Principal.hash);
        // uid -> tweets tid
        private var userTweet = HashMap.HashMap<Principal, [Nat32]>(1, Principal.equal, Principal.hash);
        // follower : user uid -> follower uid List
        private var follower = HashMap.HashMap<Principal, List.List<Principal>>(1, Principal.equal, Principal.hash);
        // follow user : user uid -> follow uid List
        private var follow = HashMap.HashMap<Principal, List.List<Principal>>(1, Principal.equal, Principal.hash);        

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


        /**
        * append tweet id to user profile
        * @param uid : user principal
        * @param tid : tweet id
        */
        public func addTweet(uid : Principal, tid : Nat32) : Bool{
            if(isExist(uid)){
                switch(userTweet.get(uid)){
                    case(?tweet){
                        var tweetArray : [Nat32] = Array.append(tweet, [tid]);
                        ignore userTweet.replace(uid, tweetArray);
                    };
                    case(_){
                        userTweet.put(uid, [tid]);
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
        * @return user's tweet -> ?[Nat32]  : null || [Nat32]
        */
        public func getUserAllTweets(uid : Principal) : ?[Nat32]{
            userTweet.get(uid)
        };

        //TODO : tweet [] -> Tree
        public func deleteUserTweet(uid : Principal, tid : Nat32) : Bool{
            var newArray : [Nat32] = []; 
            if(isExist(uid)){
                var tweet : [Nat32] = switch(userTweet.get(uid)){
                    case(null) { [] };
                    case(?array) { array };
                };
                for(v in tweet.vals()){
                    if(v != tid){
                        newArray := Array.append(newArray, [v]);
                    }
                };
                ignore userTweet.replace(uid, newArray);
                true
            }else{
                false
            }
        };

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
                    follower.put(user, ?(follower_user, null));
                    ignore addFollow(user, follower_user);
                };  
                case(?list){
                    var newList = List.push<Principal>(follower_user, list);
                    ignore follower.replace(user, newList);
                    ignore addFollow(user, follower_user);
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
                    follow.put(follower_user, ?(user, null));
                    ignore addFollower(user, follower_user);
                };
                case(?list){
                    var newList = List.push<Principal>(user, list);
                    ignore follow.replace(follower_user, newList);
                    ignore addFollower(user, follower_user);
                };
            };
            true
        };

        /**
        * get user follower
        * @param uid : user principal
        * @return [Principal] or null
        */
        public func getFollower(uid : Principal) : ?[Principal]{
            switch(follower.get(uid)){
                case(null) { null };
                case(?list){
                    ?List.toArray<Principal>(list)
                };
            };
        };

        /**
        * 
        */
        public func getFollow(uid : Principal) : ?[Principal]{
            switch(follow.get(uid)){
                case(null){ null };
                case(?list){
                    ?List.toArray<Principal>(list)
                };
            };
        };


        /**TODO List**/
        /****/
        // public func deleteFollow(user : Principal, followUser : Principal) : Bool{
        //     assert(ifUserExisted(user));
        //     assert(ifUserExisted(followUser));
        //     switch(follow.get(user)){
        //         case(null){ false };
        //         case(?list){
        //             switch(list.find<Principal>(list, )){
        //                 case(null) { false };
        //                 case(?user){
                            
        //                 };
        //             };
        //         };
        //     };
        // };


    };


};