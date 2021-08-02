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
    type ShowTweet = Tweet.showTweet;

    //tweet databse control relation betweet tweets, other database storage data
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

        //comment database
        private var commentDB = CommentDB.commentDB();

        //like databse
        private var likeDB = LikeDB.likeDB();
        
        // tweet content
        private var contentDB = ContentDB.ContentDB();

        public func createTweet(text : Text, time : Text, uid : Principal, url : Text) : Bool{
            let tid = increaseTID();
            let tweet : Tweet = { tid = tid };
            let content = contentDB.make(text, time, url);
            tweetMap.put(tid, tweet);
            contentDB.add(tid, content);
            userDB.addTweet(uid, tid);
            //comment
            //likeDB
            //topicDB.addTopicTweet()
        };


        /**
        * if tweet is existed
        * @param tid : tweet tid
        * @return existed true , not existed false
        */
        public func isTweetExist(tid : Nat) : Bool{
            switch(tweetMap.get(tid)){
                case(null) { false };
                case(()) { true };
            }
        };

        /**
        * delete tweet from tweet map
        * @param tid : user's Principal
        * @return ?Bool : true -> successful, false : no such tweet
        */
        public func deleteTweet(oper_ : Principal, tid : Nat) : Bool{
            switch(userDB.getUidByTid(tid)){
                case null { false };
                case (?uid){
                    if(uid == oper_){
                        tweetMap.delete(tid);
                        userDB.deleteTweet(uid, tid);
                        contentDB.delete(tid);
                        //likeDB.delete(tid);
                        commentDB.delete(tid);
                        //topic
                    }else{
                        false
                    }
                }
            }
        };

        /**
        * change tweet and put tweet into tweet map
        * @param uid : user's Principal
        * @param tweet : Tweet 
        * @return ?TID : TID or null
        */
        public func changeTweet(tid : Nat, text : Text, time : Text, uid : Principal, url : Text) : Bool{
            //change tweet topic
            let oldTweet = switch(getShowTweetById(tid)){
                // ERROR WORNING
                case(null) { return false; };
                case(?t) { t };
            };

            contentDB.replace(tid, contentDB.make())

            
        };


        /**
        * get tweet by id
        */
        public func getShowTweetById(tid : Nat) : ?showTweet{
            if(isTweetExist(tid)){
                let content = switch(contentDB.get(tid)){
                        case null { "" };
                        case (?text) { text };
                };

                ?{
                    tid = tid;
                    content = content.text;
                    time = content.time;
                    user =  switch(userDB.getUidByTid(tid)){
                                case(null) { return null };
                                case (?owner) { owner };
                            };
                    url = content.url;
                    likeNumber = likeDB.likeAmount(tid);
                    commentNumber = commentDB.getNumber(tid);
                }
            }else{
                null
            }
        };

        /**
        * @return the lastest tid
        */
        public func getLastestTweetId() : Nat{
            tid
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


        /*************** inner function **********************************/

        /** TID += 1 and get newest TID **/
        private func increaseTID() : Nat{
            tid := tid + 1;
            getLastestTweetId()
        };



    };
};