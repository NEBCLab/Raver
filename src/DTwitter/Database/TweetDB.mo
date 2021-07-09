import Tweet "../Module/Tweet";

module{
    public class TweetDB(){
        public func createTweet(user : Principal, tweet : Tweet) : ?Tweet.TID {

        };

        public func deleteTweet(user : Principal, twitterId : Int8) : ?bool {

        };

        public  func changeTweet(user : Principal, twitterId : Nat32) : ?bool{

        };

        public func findTweetByTopic(topic : Text) : ?[Tweet.Tweet]{

        };







    };
};