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

module{
    type Tweet = Tweet.Tweet;
    type TID = Tweet.TID;
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
        * like map
        */
        private var likeMap = HashMap.HashMap<Nat32, Nat8>(1, Hash.equal, tools.hash);

        /**
        * comment map
        */
        private var commentMap = HashMap.HashMap<Nat32, Nat8>(1, Hash.equal, tools.hash);


        /**
        * put tweet into tweet map and topic tweet, user tweet map
        * @param uid : user's Principal
        * @param tweet : Tweet 
        * @return ?TID : TID or null
        */
        public func createTweet(topic : Text, content : Text, time : Text, uid : Principal, url : Text) : Bool{
            let tweet : Tweet = {
                tid = tid;
                content = content;
                topic = topic;
                time = time;
                user = switch(userDB.getUserProfile(uid)){
                    case(null){ return false; };
                    case(?user){
                        user
                    };
                };
                url = url;
            };
            tweetMap.put(tid, tweet);
            addTopicTweet(tweet.topic, tid);
            ignore userDB.addTweet(tweet.user.uid, tid);
            tid += 1;
            true
        };

        /**
        * if tweet is existed
        * @param tid : tweet tid
        * @return existed true , not existed false
        */
        public func isTweetExist(tid : Nat32) : Bool{
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
        public func deleteTweet(oper_ : Principal, tid : Nat32) : Bool{
            let tweet = switch(tweetMap.get(tid)){
                case (null) { return false };
                case (?t) { t };
            };
            assert(oper_ == tweet.user.uid);
            deleteTopicTweet(tweet.topic, tid);
            switch(tweetMap.remove(tid), userDB.deleteUserTweet(tweet.user.uid, tid)){
                case(?t, true) { true };
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
            //change tweet topic
            let oldTweet = switch(getTweetById(tid)){
                case(null) { return false; };
                case(?t) { t };
            };
            if(newTweet.topic != oldTweet.topic){
                changeTweetTopic(tid, newTweet.topic);
            };
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
        * @param tid : Nat32 -> retweet tweet id
        * @param 
        * @return
        * TODO : to save memory storage, retweet only need change the user
        */
        public func reTweet(tid : Nat32, user : Principal) : Bool{
            userDB.addTweet(user, tid)
        };

        /**
        * add tweet like number
        * @param tid : 
        * @param 
        */
        public func likeTweet(tid : Nat32) : Bool{
            if(isTweetExist(tid)){
                switch(likeMap.get(tid)){
                    case(null){
                        likeMap.put(tid, 1);
                    };
                    case(?number){
                        ignore likeMap.replace(tid, number+1);
                    };
                };
                true
            }else{
                false
            }
        };

        //TODO 
        // + uid : Principal
        public func cancelLike(tid : Nat32) : Bool{
            if(isTweetExist(tid)){
                switch(likeMap.get(tid)){
                    case(null){
                        likeMap.put(tid, 1);
                    };
                    case(?number){
                        ignore likeMap.replace(tid, number-1);
                    };
                };
                true
            }else{
                false
            }
        };

        /**
        * @param follow : user principal
        * @param number : older number
        */
        public func getFollowFiveTweets(follow : Principal, number : Nat32) : [Tweet]{
            var tweets = switch(userDB.getUserAllTweets(follow)){
                case(null) { return []};
                case(?t) { t }; 
            };
            var size : Nat32 = Nat32.fromNat(tweets.size()) - 1;
            var i : Nat32 = 0;
            var result : [Tweet] = [];
            while((number < size - i) and (i <= 5)){
                i += 1;
                var tempT : Tweet = switch(getTweetById(tweets[Nat32.toNat(size - i - number)])){
                    case(null){ return result; };
                    case(?tweet) { tweet };
                };
                result := Array.append(result, [tempT]);
            };
            result
        };

        
        
        
        
        
        
        //TODO
        // public func getTweetLikeUsers() : ?[Nat32]{

        // };

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

        private func deleteTopic(topic : Text){
            topicTweet.delete(topic);
        };

        /****/
        private func deleteTopicTweet(topic : Text, tid : Nat32){
            var tempArray : [Nat32] = [];
            switch(topicTweet.get(topic)){
                case(null) { () };
                case(?array) {
                    for(v in array.vals()){
                        if(v != tid){
                            tempArray := Array.append(tempArray, [v]);
                        };
                    };
                    ignore topicTweet.replace(topic, tempArray);
                };
            };
        };

        /****/
        private func ifTopicExist(topic : Text) : Bool{
            for((k,_) in topicTweet.entries()){
                if( k == topic){
                    return true;
                }
            };
            false
        };

        /****/
        private func changeTweetTopic(tid : Nat32, newTopic : Text){
            if(ifTopicExist(newTopic)){
                addTopicTweet(newTopic, tid);
                let oldTopic = switch(tweetMap.get(tid)){
                    case(null){""};
                    case(?t){t.topic};                    
                };
                deleteTopicTweet(oldTopic, tid);
            }else{
                addTopicTweet(newTopic, tid);
            }
        }
        


    };
};