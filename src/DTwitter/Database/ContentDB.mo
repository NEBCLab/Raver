import Tweet "../Module/Tweet";
import Nat "mo:base/Nat";
import Hash "mo：base/Hash";


module {

    //content databse control content database 
    public class ContentDB(){
        
        // Content id <-> Content content
        private var contentMap = HashMap.HashMap<Nat, Text>(1, Nat.equal, Hash.hash);

        /*
        * add content 
        * @param tid : tweet id
        * @param content : Text content
        * @return success or failed
        */
        public func addContent(tid : Nat, content : Text) : Bool{
            contentMap.put(tid, content);
            true
        };

        /*
        * add content 
        * @param tid : tweet id
        * @param content : Text content
        * @return true
        */
        public func deleteContent(tid : Nat) : Bool{
            contentMap.delete(tid)
            true
        };

        /*
        * add content 
        * @param tid : tweet id
        * @param content : Text content
        * @return true
        */
        public func replaceContent(tid : Nat, content : Text) : Bool{
            ignore contentMap.replace(tid, content);
            true
        };

        /*
        * add content 
        * @param tid : tweet id : Nat
        * @return null or ?Text
        */
        public func getContent(tid : Nat) : ?Text{
            contentMap.get(tid)
        };


        /*
        * add content 
        * @param tid : tweet id : Nat
        * @return exist ? true : false
        */
        public func isContentExist(tid : Nat) : Bool{
            switch(contentMap.get(tid)){
                case null { false };
                case (?c) { true };
            }
        };

    };
};