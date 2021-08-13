import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Array "mo:base/Array";
import TrieSet "mo:base/TrieSet";
import Option "mo:base/Option";

module{
    
    // control relation betweet tweets
    public class commentDB(){
        
        //realtion table : tid - (cid, comment_hash)
        private var relation = HashMap.HashMap<Nat, TrieSet.Set<Nat>>(1, Nat.equal, Hash.hash);

        /****/
        public func add(tid : Nat, cid : Nat) : Bool{
            switch(relation.get(tid)){
                case null {
                    var tempSet = TrieSet.empty<Nat>();
                    tempSet := TrieSet.put<Nat>(tempSet,cid,Hash.hash(cid),Nat.equal);
                    relation.put(tid, tempSet);
                    true
                };
                case (?set) {
                    var newSet = TrieSet.put<Nat>(set,cid,Hash.hash(cid),Nat.equal);
                    relation.put(tid, newSet);
                    true
                };
            }
        };

        /****/
        public func delete(tid : Nat, cid : Nat) : Bool{
            switch(relation.get(tid)){
                case null { false };
                case (?set) {
                    var newSet = TrieSet.delete<Nat>(set,cid,Hash.hash(cid),Nat.equal);
                    relation.put(tid, newSet);
                    true
                };
            }
        };

        /****/
        public func getTweetOlder20Comments(tid : Nat) : ?[Nat]{
            switch(relation.get(tid)){
                case null { null };
                case (?set) {
                    var array = TrieSet.toArray<Nat>(set);
                    Option.make<[Nat]>(Array.sort<Nat>(array, Nat.compare))
                };
            };
        };

        /**delte tweet comment relation**/
        public func deleteAllComment(tid : Nat) : Bool{
            relation.delete(tid);
            true
        };

        //get comment number
        public func getNumber(tid : Nat) : Nat{
            switch(relation.get(tid)){
                case null { 0 };
                case (?set) { TrieSet.size(set) };
            }
        };

        /****/
        public func deleteTweet(tid : Nat) : Bool{
            relation.delete(tid);
            true
        };
    

    };





};