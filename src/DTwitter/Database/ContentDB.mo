import Tweet "../Module/Tweet";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Content "../Module/Content";
import HashMap "mo:base/HashMap";

module {

    private type Content = Content.content; 
    
    //content databse control content database 
    public class ContentDB(){
        
        // Content id <-> Content content
        private var contentMap = HashMap.HashMap<Nat, Content>(1, Nat.equal, Hash.hash);

        /*
        * add content
        * @param tid : tweet id
        * @param content : Text content
        * @return success or failed
        */
        public func add(tid : Nat, content : Content) : Bool{
            contentMap.put(tid, content);
            true
        };

        /*
        * add content 
        * @param tid : tweet id
        * @param content : Text content
        * @return true
        */
        public func delete(tid : Nat) : Bool{
            contentMap.delete(tid);
            true
        };

        /*
        * add content 
        * @param tid : tweet id
        * @param content : Text content
        * @return true
        */
        public func replace(tid : Nat, content : Content) : Bool{
            ignore contentMap.replace(tid, content);
            true
        };

        /*
        * add content 
        * @param tid : tweet id : Nat
        * @return null or ?Text
        */
        public func get(tid : Nat) : ?Content{
            switch(contentMap.get(tid)){
                case null { null };
                case (?c){ ?c };
            }
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

        // make content struct
        public func make(text : Text, time : Text, url : Text) : Content{
            {
                text = text;
                time = time;
                url = url;
            }
        };

    };
};