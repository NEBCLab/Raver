import Tweet "../Module/Tweet";
import User "../Module/User";
import Nat32 "mo:base/Nat32";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Array "mo:base/Array";
import tools "../Module/tools";
import Text "mo:base/Text";
import UserDB "./UserDB";

module{
    type Tweet = Tweet.Tweet;
    type TID = Tweet.TID;
    type Like = Tweet.Like;
    type UserDB = UserDB.userDB;

    public class tweetDB(userDB : UserDB){        
        /**
        * global tweet id 
        * tid : Nat32
        */
        private var tid : Nat32 = 1;

        /**
        * tweet map : map<tweet TID , Tweet>
        */
        private var tweetMap = HashMap.HashMap<Nat32, Tweet>(1, Hash.equal, tools.hash);

        /**
        * topic
        */
        private var topicTweet = HashMap.HashMap<Text, [Nat32]>(1, Text.equal, Text.hash);

        /**
        * 
        */
        private var tweetLike = HashMap.HashMap<Nat32, List<Nat32>>();


        /**
        * put tweet into tweet map and topic tweet, user tweet map
        * @param uid : user's Principal
        * @param tweet : Tweet 
        * @return ?TID : TID or null
        */
        public func createTweet(tweet : Tweet) : Bool{
            tweetMap.put(tid, tweet);
            addTopicTweet(tweet.topic, tid);
            ignore userDB.addTweet(tweet.owner, tid);
            tid += 1;
            true
        };

        /**
        * if tweet is existed
        * @param tid : tweet tid
        * @return existed true , not existed false
        */
        public func isExist(tid : Nat32) : Bool{
            switch(tweetMap.get(tid)){
                case(null) { false };
                case(?t) { true };
            }
        };

        /**
        * delete tweet from tweet map
        * @param tid : user's Principal
        * @return ?Bool : true -> successful, false : no such tweet
        */
        public func deleteTweet(tid : Nat32) : Bool{
            let tweet = switch(tweetMap.get(tid)){
                case (null) { () };
                case (?t) { t };
            };
            switch(tweetMap.remove(tid), topicTweet.deleteTopicTweet(tweet.topic, tid), userDB.deleteUserTweet(tweet.owner, tid)){
                case(?t, true, true) { true };
                case(_){ false };
            };
        };

        /**
        * change tweet and put tweet into tweet map
        * @param uid : user's Principal
        * @param tweet : Tweet 
        * @return ?TID : TID or null
        */
        public func changeTweet(tid : Nat32, newTweet : Tweet) : Bool{
            switch(tweetMap.replace(tid, newTweet)){
                case(?tweet){
                    true
                };
                case (_){
                    false
                };
            }
        };

        /**
        * find same topic tweet id
        * @param uid : user's Principal
        * @param tweet : Tweet 
        * @return ?TID : TID or null
        */
        public func findTweetByTopic(topic : Text) : ?[Nat32]{
            topicTweet.get(topic)
        };

        /**
        * get tweet by id
        */
        public func getTweetById(tid : Nat32) : ?Tweet{
            tweetMap.get(tid)
        };

        /**
        * @return the lastest tid
        */
        public func getLastestTweetId() : Nat32{
            tid
        };

        /**
        * reTweet a tweet
        */
        public func reTweet(tid : Nat32, user : Principal) : Bool{
            var t : Tweet = switch(getTweetById(tid)){
                case( null ){ return false; };
                case( ?t ){ t };
            };
            ignore createTweet();
            true
        };


        /**
        * add tweet like number
        * @param tid : 
        * @param 
        */
        public func likeTweet(tid : Nat32) : Bool{
            switch(tweetMap.get(tid)){
                case( null ){ false };
                case( ?t) { t.likeNumber += 1; ignore tweetMap.replace(tid, t); true};
            }
        };

        public func cancelLike(tid : Nat32, uid : Principal) : Bool{

        };

        public func getTweetLikeUsers() : ?[Nat32]{

        };

        /**comment**/
        //public func getTweetComment() : {};

        //TODO change tweet topic
        //should change tweet storage data structure

        /**
        * @param topic : tweet topic
        * @param tid : tweet tid
        */
        private func addTopicTweet(topic : Text, tid : Nat32){
            switch(topicTweet.get(topic)){
                case(null){ topicTweet.put(topic, [tid]) };
                case(?array){
                    array = Array.append(array, [tid]);
                    ignore topicTweet.replace(array);
                };
            }
        };

        private func deleteTopic(topic : Text){
            ignore topicTweet.delete(topic);
        };

        /****/
        private func deleteTopicTweet(topic : Text, tid : Nat32){
            var tempArray : [Nat32] = [];
            switch(topicTweet.get(topic)){
                case(null) { () };
                case(?array) {
                    for(v in array.vals()){
                        if(v != tid){
                            tempArray = Array.append(tempArray, [v]);
                        };
                    };
                    ignore topicTweet.replace(topic, tempArray);
                };
            };
        };

    };
};