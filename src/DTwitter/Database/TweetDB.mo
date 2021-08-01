import Tweet "../Module/Tweet";
import User "../Module/User";
import Nat "mo:base/Nat";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Array "mo:base/Array";
import tools "../Module/tools";
import Text "mo:base/Text";
import UserDB "./UserDB";
import Nat8 "mo:base/Nat8";
import LikeDB "./LikeDB";
import Option "mo:base/Option"

module{
    type Tweet = Tweet.Tweet;
    type TID = Tweet.TID;
    type UserDB = UserDB.userDB;
    type showTweet = Tweet.showTweet;

    public class tweetDB(userDB : UserDB){        
        /**
        * global tweet id 
        * tid : Nat
        */
        private var tid : Nat = 1;

        /**
        * tweet map : map<tweet TID , Tweet>
        */
        private var tweetMap = HashMap.HashMap<Nat, Tweet>(1, Nat.equal, Hash.hash);

        /**
        * topic
        */
        private var topicTweet = HashMap.HashMap<Text, [Nat]>(1, Text.equal, Text.hash);

        /**
        * comment map
        */
        private var commentMap = HashMap.HashMap<Nat, Nat8>(1, Nat.equal, Hash.hash);

        private var likeDB = LikeDB.likeDB();

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
        public func isTweetExist(tid : Nat) : Bool{
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
        public func deleteTweet(oper_ : Principal, tid : Nat) : Bool{
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
        public func changeTweet(tid : Nat, newTweet : Tweet) : Bool{
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
        public func findTweetByTopic(topic : Text) : ?[Nat]{
            topicTweet.get(topic)
        };

        /**
        * get tweet by id
        */
        public func getShowTweetById(tid : Nat) : ?showTweet{
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
        public func getLastestTweetId() : Nat{
            tid
        };

        /**
        * reTweet a tweet
        * @param tid : Nat -> retweet tweet id
        * @param 
        * @return
        * TODO : to save memory storage, retweet only need change the user
        */
        public func reTweet(tid : Nat, user : Principal) : Bool{
            userDB.addTweet(user, tid)
        };

    

        /**
        * @param follow : user principal
        * @param number : older number
        */
        public func getFollowFiveTweets(follow : Principal, number : Nat) : [showTweet]{
            var tweets = switch(userDB.getUserAllTweets(follow)){
                case(null) { return []};
                case(?t) { t }; 
            };
            var size : Nat = tweets.size() - 1;
            var i : Nat = 0;
            var result : [showTweet] = [];
            while((number < size - i) and (i <= 5)){
                i += 1;
                //get user old five tweets
                var tempT : showTweet = switch(getShowTweetById(tweets[size - i - number])){
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
        public func getUserOlderFiveTweets(user : Principal, number : Nat) : ?[Tweet]{
            switch(userDB.getUserAllTweets(user)){
                case(null) { null };
                case(?tids){
                    var size = tids.size();
                    if(number >= size){
                        return null;
                    }else{
                        var i : Nat = 1;
                        var tempArray : [Tweet] = [];
                        while((number + i < size -1) and (i < 5)){
                            var tempTweet = switch(tweetDB.getShowTweetById(size - 1 - number - i)){
                                case(?tweet){ tweet };
                                case(_) { return null; };
                            };
                            tempArray := Array.append(tempArray, [tempTweet]);
                            i += 1;
                        };
                        Option.make<[Tweet]>(tempArray)
                    }
                };
            }
        };

        //TODO

        /**comment**/
        //public func getTweetComment() : {};

        //TODO change tweet topic
        //should change tweet storage data structure

        /**
        * @param topic : tweet topic
        * @param tid : tweet tid
        */
        private func addTopicTweet(topic : Text, tid : Nat){
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
        private func deleteTopicTweet(topic : Text, tid : Nat){
            var tempArray : [Nat] = [];
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
        private func changeTweetTopic(tid : Nat, newTopic : Text){
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
        };

        /**
        *The following part is like moudle-------------------like-------------------------
        **/
        public func likeAmount(tid : Nat) : Nat{
            likeDB.likeAmount(tid)
        };

        public func likeTweet(tid : Nat, uid : Principal) : Bool{
            likeDB.likeTweet(tid, uid)
        };

        public func cancelLike(tid : Nat, uid : Principal) : Bool{
            likeDB.cancelLike(tid, uid)
        };

        public func getTweetLikeUsers(tid : Nat) : ?[Principal]{
            likeDB.getTweetLikeUsers(tid)
        };

        public func isTweetLiked(tid : Nat, uid : Principal) : Bool{
            likeDB.isTweetLiked(tid, uid)
        };
    };
};