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
    type showTweet = Tweet.showTweet;


    //tweet databse control relation betweet tweets, other database storage data
    public class tweetDB(userDB : UserDB, ){        
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
        * Content map
        * every Content is a tweet
        * @param Contented tweet tid -> Content tweet id set
        */
        private var commentSet = HashMap.HashMap<Nat,  TrieSet.Set<Nat>>(1, Nat.equal, Hash.hash);

        /*
        * Content number map
        * tweet TID -> tweet Content number
        */
        private var contentNumber = HashMap.HashMap<Nat, Nat>(1, Nat.equal, Hash.hash);




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
                owner = uid;
                url = url;
            };
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
            assert(oper_ == tweet.owner);
            deleteTopicTweet(tweet.topic, tid);
            switch(tweetMap.remove(tid), userDB.deleteUserTweet(tweet.owner, tid)){
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
            let oldTweet = switch(getShowTweetById(tid)){
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
        public func getShowTweetById(tid : Nat32) : ?showTweet{
            switch(tweetMap.get(tid)){
                case(null) { null };
                case(?tweet) {
                    ?{
                        tid = tweet.tid;
                        content = tweet.content;
                        topic = tweet.topic;
                        time = tweet.time;
                        user = switch(userDB.getUserProfile(tweet.owner)){
                            case(null){ return null};
                            case(?user) { user };
                        };
                        url = tweet.url;
                    }
                };
            }
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
        * @param follow : user principal
        * @param number : older number
        */
        public func getFollowFiveTweets(follow : Principal, number : Nat32) : [showTweet]{
            var tweets = switch(userDB.getUserAllTweets(follow)){
                case(null) { return []};
                case(?t) { t }; 
            };
            var size : Nat32 = Nat32.fromNat(tweets.size()) - 1;
            var i : Nat32 = 0;
            var result : [showTweet] = [];
            while((number < size - i) and (i <= 5)){
                i += 1;
                //get user old five tweets
                var tempT : showTweet = switch(getShowTweetById(tweets[Nat32.toNat(size - i - number)])){
                    case(null){ return result; };
                    case(?tweet) { tweet };
                };
                result := Array.append(result, [tempT]);
            };
            result
        };
        
        /*
        * get user older five tweets
        * 
        */
        public func getUserOlderFiveTweets(user : Principal, number : Nat32) : ?[Tweet]{
            switch(userDB.getUserAllTweets(user)){
                case(null) { [] };
                case(?tids){
                    var size = Nat32.fromNat(tids.size());
                    if(number >= size){
                        return [];
                    }else{
                        var i : Nat32 = 1;
                        var tempArray : [Tweet] = [];
                        while((number + i < size -1) and (i < 5)){
                            var tempTweet = switch(tweetDB.getShowTweetById(size - 1 - number - i)){
                                case(?tweet){ tweet };
                                case(_) { return null; };
                            };
                            tempArray := Array.append(tempArray, [tempTweet]);
                            i += 1;
                        };
                        tempArray
                    }
                };
            }
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