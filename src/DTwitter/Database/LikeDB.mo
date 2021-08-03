import Tweet "../Module/Tweet";
import User "../Module/User";
import Nat "mo:base/Nat";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Array "mo:base/Array";
import Text "mo:base/Text";
import UserDB "./UserDB";
import Nat8 "mo:base/Nat8";
import TrieSet "mo:base/TrieSet";
import Principal "mo:base/Principal";
import Option "mo:base/Option";

module{
    type Tweet = Tweet.Tweet;
    type TID = Tweet.TID;
    type UserDB = UserDB.userDB;
    type showTweet = Tweet.showTweet;

    public class likeDB(){
        /**
        * like map
        */
        private var likeMap = HashMap.HashMap<Nat, TrieSet.Set<Principal> >(1, Nat.equal, Hash.hash);

        /**
        * get tweet's like amount
        * @param tid : Nat
        * @return tweet's like amount -> Nat
        */
        public func likeAmount (tid : Nat) : Nat{ 
            switch(likeMap.get(tid)){
                case null{
                    0
                };
                case (?set){
                    TrieSet.size(set)
                };
            };
        } ;
        /**
        * add like to tweet
        * @param tid : Nat
        * @param uid : Principal
        * @return
        */
        public func likeTweet(tid : Nat, uid : Principal) : Bool{ 
            switch(likeMap.get(tid)){
                case null{
                    var tempSet=TrieSet.empty<Principal>();
                    tempSet := TrieSet.put<Principal>(tempSet,uid,Principal.hash(uid),Principal.equal);
                    likeMap.put(tid, tempSet);
                };
                case (?set){
                    if(TrieSet.mem<Principal>(set, uid, Principal.hash(uid), Principal.equal)==true) return false; //如果赞过返回false
                    var newSet = TrieSet.put<Principal>(set,uid,Principal.hash(uid),Principal.equal);
                    ignore likeMap.replace(tid, newSet);
                };
            };
            true
        };

        /**
        * user cancel like
        * @param tid : Nat
        * @param uid : Principal
        * @return
        */

        public func cancelLike(tid : Nat, uid : Principal) : Bool{
            switch(likeMap.get(tid)){
                case null{
                    return false;
                };
                case (?set){
                    if(TrieSet.mem<Principal>(set, uid, Principal.hash(uid), Principal.equal)==false) return false; //如果没赞过返回false
                    var newSet = TrieSet.delete<Principal>(set,uid,Principal.hash(uid),Principal.equal);
                    ignore likeMap.replace(tid, newSet);
                };
            };
            true
        };

        /**
        * Get Tweet Like Users Array
        * @param tid : Nat
        * @return
        */

        public func getTweetLikeUsers(tid : Nat) : ?[Principal]{
            switch(likeMap.get(tid)){
                case null{
                    null
                };
                case (?set){
                    Option.make<[Principal]>(TrieSet.toArray<Principal>(set))
                };
            };
        };

        /**
        * is this tweet be liked by user
        * @param tid : Nat
        * @param uid : Principal
        * @return
        */

        public func isTweetLiked(tid : Nat, uid : Principal) : Bool{
            switch(likeMap.get(tid)){
                case null{
                    false
                };
                case (?set){
                    TrieSet.mem<Principal>(set, uid, Principal.hash(uid), Principal.equal)
                };
            };
        };

        
        /**
        * delete a tweet's LikeDB
        * @param tid : Nat
        * @param uid : Principal
        * @return
        */

        public func deleteLikeDB(tid : Nat){
            likeMap.delete(tid)
        };
    };
};