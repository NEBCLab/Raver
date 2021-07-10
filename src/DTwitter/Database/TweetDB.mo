import Tweet "../Module/Tweet";
import User "../Module/User";
import Nat32 "mo:base/Nat32";

module{
    type Tweet = Tweet.Tweet;
    type TID = Tweet.TID;
    type Like = Tweet.Like;
    public class TweetDB(){
        /**
        * tweet map : map<tweet TID , Tweet>
        */
        private var tweetMap = HashMap.HashMap<Nat32, Tweet>(1, Hash.equal, Hash.hash);

        /**
        * global tweet id 
        * tid : Nat32
        */
        private var tid : Nat32 = 1;

        /**
        * create tweet and put tweet into tweet map
        * @param uid : user's Principal
        * @param tweet : Tweet 
        * @return ?TID : TID or null
        */
        public func createTweet(
            content : Text,
            topic : Text,
            time : Text,
            owner : Principal){
                var zero = Nat32.fromNat(0);
                var nulArray : [Like]= [];
                var tempArray : [Nat32] = [];
                tweetMap.put({
                    tid = tid;
                    content = content;
                    topic = topic;
                    time = time;
                    owner = owner;
                    comment = {zero; [];};
                    like = {zero; [];};
                });
                tid += 1;
        };

        /**
        * delete tweet from tweet map
        * @param tid : user's Principal
        * @return ?Bool : true -> successful, false : no such tweet
        */
        public func deleteTweet(
            tid : Nat32) : Bool{
                switch(tweetMap.remove(twitterId)){
                    case(?t) { true };
                    case(_){ false };
                }
            }
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
        * create tweet and put tweet into tweet map
        * @param uid : user's Principal
        * @param tweet : Tweet 
        * @return ?TID : TID or null
        */        
        public func findTweetByTopic(topic : Text) : ?[Tweet]{
            var array : [Tweet]= [];
            for((tid,tweet) in tweetMap.entries()){
                if(tweet.topic == topic){
                    Array.append(array, [tweet]);
                }
            };
            array
        };

        /**
        * get tweet by id
        */
        public func getTweetById(tid : Nat32) : ?Tweet{
            tweetMap.get(tid)
        };

        /**
        * create tweet and put tweet into tweet map
        * @param uid : user's Principal
        * @param tweet : Tweet 
        * @return ?TID : TID or null
        
        public func getMyTweets(uid : Principal, userDB : userDB) : ?[Tweet]{
            
        };
        */







    };
};