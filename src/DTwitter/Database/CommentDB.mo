import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Array "mo:base/Array";

module{
    
    // control relation betweet tweets
    public class commentDB(){
        
        //realtion table : tid - (cid, comment_hash)
        private var relation = HashMap.HashMap<Nat, HashMap.HashMap<Nat, ()>>(1, Nat.equal, Hash.hash);

        /****/
        public func add(tid : Nat, cid : Nat) : Bool{
            switch(relation.get(tid)){
                case null {
                    var map = HashMap.HashMap<Nat, ()>(1, Nat.equal, Hash.hash);
                    map.put(cid, ());
                    relation.put(tid, map);
                    true
                };
                case (?map) {
                    map.put(cid, ());
                    relation.put(tid, map);
                    true
                };
            }
        };

        /****/
        public func delete(tid : Nat, cid : Nat) : Bool{
            switch(relation.get(tid)){
                case null { false };
                case (?map) {
                    map.delete(cid);
                    relation.put(tid, map);
                    true
                };
            }
        };

        /****/
        public func getTweetAllComments(tid : Nat) : ?[Nat]{
            switch(relation.get(tid)){
                case null { null };
                case (?map) {
                    var i = 0;
                    var array = Array.init<Nat>(map.size(), 1);
                    for((k, _) in map.entries()){
                        array[i] := k;    
                    };
                    ?Array.freeze<Nat>(array)
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
                case (?map) { map.size() };
            }
        };

        /****/
        public func deleteTweet(tid : Nat) : Bool{
            relation.delete(tid);
            true
        };
    

    };





};