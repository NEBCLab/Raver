import Tweet "../Module/Tweet";
import Nat "mo:base/Nat";
import Hash "mo：base/Hash";


module {

    public class TopicDB(){
        
        // topic id <-> topic topic
        private var topicMap = HashMap.HashMap<Nat, Text>(1, Nat.equal, Hash.hash);

        /*
        * add topic 
        * @param tid : tweet id
        * @param topic : Text topic
        * @return success or failed
        */
        public func add(tid : Nat, topic : Text) : Bool{
            topicMap.put(tid, topic);
            true
        };

        /*
        * add topic 
        * @param tid : tweet id
        * @param topic : Text topic
        * @return true
        */
        public func delete(tid : Nat) : Bool{
            topicMap.delete(tid)
            true
        };

        /*
        * add topic 
        * @param tid : tweet id
        * @param topic : Text topic
        * @return true
        */
        public func replace(tid : Nat, topic : Text) : Bool{
            ignore topicMap.replace(tid, topic);
            true
        };

        /*
        * add topic 
        * @param tid : tweet id : Nat
        * @return null or ?Text
        */
        public func get(tid : Nat) : ?Text{
            topicMap.get(tid)
        };


        /*
        * add topic 
        * @param tid : tweet id : Nat
        * @return exist ? true : false
        */
        public func isExist(tid : Nat) : Bool{
            switch(topicMap.get(tid)){
                case null { false };
                case (?c) { true };
            }
        };

        /**
        * @param topic : tweet topic
        * @param tid : tweet tid
        */
        private func topicAddTweet(topic : Text, tid : Nat){
            switch(topicTweet.get(topic)){
                case(null){ topicTweet.put(topic, [tid]) };
                case(?array){
                    var newArray = Array.append(array, [tid]);
                    ignore topicTweet.replace(topic, newArray);
                };
            }
        };

        public func getAllTopic() : [Text] {
            var array : [Text] = [];
            for((k,_) in topicTweet.entries()){
                array := Array.append(array, [k]);
            };
            array
        };

    };
};