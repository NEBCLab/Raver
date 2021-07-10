import Tweet "../Module/Tweet";
import User "../Module/User";

module{
    type Tweet = Tweet.Tweet;
    type TID = Tweet.TID;
    type Like = Tweet.Like;
    public class TweetDB(){
        /**
        * tweet map : map<tweet TID , Tweet>
        */
        private var tweetMap = HashMap.HashMap<Nat32, Tweet>(1, Hash.hash, Hash.equal);

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
                tweetMap.put({
                    tid = tid;
                    content = content;
                    topic = topic;
                    time = time;
                    owner = owner;
                    comment = {0, [""]};
                    like = {0, [owner]};
                });
                tid += 1;
        };

        /**
        * delete tweet from tweet map
        * @param tid : user's Principal
        * @return ?bool : true -> successful, false : no such tweet
        */
        public func deleteTweet(
            tid : Nat32) : bool{
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
        public func changeTweet(tid : Nat32, newTweet : Tweet) : bool{
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
        
        public func getMyTweetList(uid : Principal, userDB : userDB) : ?[Tweet]{
            
        };
        */
    };
};