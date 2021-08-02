import Tweet "../Module/Tweet";
import User "../Module/User";
import Nat32 "mo:base/Nat32";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Array "mo:base/Array";
import tools "../Module/tools";
import Text "mo:base/Text";
import UserDB "./UserDB";
import Nat8 "mo:base/Nat8";
import List "mo:base/List";
import Hash "mo：base/Hash";
import TrieSet "mo:base/TrieSet";


module {

    //content databse control content database 
    public class ContentDB(){
        
        // Content id <-> Content content
        private var contentMap = HashMap.HashMap<Nat, Text>(1, Nat.equal, Hash.hash);
        // Content 在 coment DB ， tweet在tweet db封装

        public func addContent(tid : Nat, ) : Bool{
            
        };

        public func deleteContent() : Bool{

        };

        public func replaceContent() : Bool{

        };

        public func getContent() : ?[Text]{
            
        };

        /* 
        * increase CID
        * @return CID
        */
        private func increaseCID() : Nat{
            CID := CID + 1;
        };

        /*
        * @param tid : tweet id
        * @return Content number at present
        */
        private func increaseContentNumber(tid : Nat32) : Nat{
            switch(ContentNumber.get(tid)){
                case(null) { false };
                case(?number) { ContentNumber.put(tid, number + 1); true };
            }
        };

        /*
        * @param 
        * 
        */
        private func decreaseContentNumber(tid : Nat32){
            switch(ContentNumber.get(tid)){
                case(null) { false };
                case(?number) { ContentNumber.put(tid, number - 1); true };
            }
        };

        // get Content exist ? true : false
        public func ContentIsExist(tid : Nat32, user : Principal) : Bool{
            switch(ContentMap.get(tid)){
                case null { false };
                case (?map){
                    switch(map.get(user)){
                        case null { false };
                        case (?c) { true };
                    }
                };
            }
        };

    };
};