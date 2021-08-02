import HashMap "mo:base/HashMap";


module{

    // control relation betweet tweets
    public class commentDB(){
        
        private var relation = HashMap.HashMap<Nat, HashMap<Nat, ()>>(1, Nat.equal, Hash.hash);

        /****/
        public func addComment(tid : Nat, cid : Nat) : Bool{
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
        public func deleteComment(tid : Nat, cid : Nat) : Bool{
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
                    for(k, _) in map.entries(){
                        array[i] = k;    
                    };
                    array
                };
            };
        };

        /**delte tweet comment relation**/
        public func deleteAllComment(tid : Nat) : Bool{
            relation.delete(tid);
            true
        };

        //get tweet number
        public func getNumber(tid : Nat) : Nat{
            switch(relation.get(tid)){
                case null { 0 };
                case (?map) { map.size() };
            }
        };

        //retweet todo





    };





};