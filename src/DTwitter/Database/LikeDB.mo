import Tweet "../Module/Tweet";
import User "../Module/User";
import Nat32 "mo:base/Nat32";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Array "mo:base/Array";
import tools "../Module/tools";
import Text "mo:base/Text";
import UserDB "./UserDB";
import TweetDB "./TweetDB";
import Nat8 "mo:base/Nat8";

moudle{
    type Tweet = Tweet.Tweet;
    type TID = Tweet.TID;
    type UserDB = UserDB.userDB;
    type TweetDB = TweetDB.tweetDB;
    type showTweet = Tweet.showTweet;

    public class likeDB(tweetDB : TweetDB){
        /**
        * like map
        */
        private var likeMap = HashMap.HashMap<Nat32, Nat8>(1, Hash.equal, tools.hash);

        /**
        * add tweet like number
        * @param tid : 
        * @param 
        */
        public func likeTweet(tid : Nat32) : Bool{
            if(isTweetExist(tid)){
                switch(likeMap.get(tid)){
                    case(null){
                        likeMap.put(
                            tid, 1);
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


    };
};