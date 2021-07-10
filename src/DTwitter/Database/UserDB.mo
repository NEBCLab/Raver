import User "../Module/User";
import Tweet "../Module/Tweet";
import HashMap "mo:base/HashMap";
import Array "mo:base/Array";
import Hash "mo:base/Hash";


module{
    type User = User.User;
    type Tweet = Tweet.Tweet;

    public class userDB(){
        // uid -> user profile
        private var userDB = HashMap.HashMap<Principal, User>(1, Principal.hash, Principal.equal);
        // uid -> tweets tid
        private var userTweet = HashMap.HashMap<Principal, [Nat32]>(1, Principal.hash, Principal.equal)

        /**
        * @param user : User
        */
        public func addUser(user : User) : bool{
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
        * @return bool -> successful : true; failed : false 
        */
        public func deleteUser(uid : Principal) : bool{
            if(isExist(uid)){
                //operator is owner
                assert(uid == switch(getUserProfile(uid)){
                    case(null){
                        ()
                    };
                    case(?user){
                        user.uid
                    };
                })
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
        public func changeUserProfile(uid : Principal, user : User) : bool{
            if(isExist(uid)){
                assert(uid == switch(getUserProfile(user.uid)){
                    case(null){
                        ()
                    };
                    case(?user){
                        user.uid
                    };
                })
                ignore userDB.replace(uid, user);
                true
            }else{
                false
            }
        };

        /**
        * @param uid : user's principal
        * @return ?User : if user existt
        */
        public func getUserProfile(uid : Principal) : ?User{
            switch(userDB.get(uid)){
                case (?user){ user };
                case(_) { null };
            }
        };

        /**private function : is user is existed**/
        private func isExist(uid : Principal) : bool{
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
        public func addTweet(uid : Principal, tid : Nat32) : bool{
            if(isExist(uid)){
                switch(userTweet.get(uid)){
                    case(?tweet){
                        tweet := Array.append(tweet, [tid]);
                        userTweet.replace(uid, tweet);
                    };
                    case(_){
                        userTweet.put(uid, [tid]);
                    }
                }
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
        public func deleteUserTweet(uid : Principal, tid : Nat32) : bool{
            var newArray : [Nat32] = []; 
            if(isExist(uid)){
                var tweet = switch(userTweet.get(uid)){
                    case(null) { [] };
                    case(?array) { array };
                };
                for((k,v) in tweet){
                    if(v != tid){
                        Array.append(newArray, v);
                    }
                };
                ignore userTweet.replace(uid, newArray);
                true
            }else{
                false
            }
        };


        /**TODO List**/

        /**add follower**/






    };


};