import HashMap "mo:base/HashMap";

module{

    public class commentDB(){
        /**
        * @param : Nat32 : tid
        * @param : Text : comment
        */
        private var commentMap = HashMap.HashMap<Nat32, [Text]>(1, Hash.hash, Hash.equal);

        public func addComment(tid : Nat32, comment : Text){
            
        };








    };



};