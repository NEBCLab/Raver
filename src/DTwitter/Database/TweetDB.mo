import Nat "mo:base/Nat";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Array "mo:base/Array";
import Text "mo:base/Text";
import Nat8 "mo:base/Nat8";
import Option "mo:base/Option";

import Tweet "../Module/Tweet";
import User "../Module/User";
import Content "../Module/Content";

import UserDB "./UserDB";
import LikeDB "./LikeDB";
import CommentDB "./CommentDB";
import ContentDB "./ContentDB";

module{
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
        private var tweetMap = HashMap.HashMap<Nat, Tweet.Tweet>(1, Nat.equal, Hash.hash);

        //comment database
        private var commentDB = CommentDB.commentDB();

        //like databse
        private var likeDB = LikeDB.likeDB();
        
        // tweet content
        private var contentDB = ContentDB.ContentDB();

        public func createTweet(text : Text, time : Text, uid : Principal, url : Text) : Bool{
            let tid = increaseTID();
            let tweet : Tweet.Tweet = { tid = tid };
            let content = contentDB.make(text, time, url);
            tweetMap.put(tid, tweet);
            ignore contentDB.add(tid, content);
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
                case(_) { true };
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
                        switch(userDB.deleteTweet(uid, tid), contentDB.delete(tid), commentDB.deleteTweet(tid)){
                            case(true, true, true){
                                true
                            };
                            case(_){
                                false
                            };
                        };
                        //likeDB.delete(tid);
                        
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
                case(null) { Tweet.defaultType().defaultTweet };
                case(?t) { t };
            };
            if (contentDB.replace(tid, contentDB.make(text, time, url))){
                true
            }else{
                false
            }
        };


        /**
        * get tweet by id
        */
        public func getShowTweetById(tid : Nat) : ?ShowTweet{
            if(isTweetExist(tid)){
                let con_ = Option.unwrap<Content.content>(contentDB.get(tid));
                let uid = Option.unwrap<Principal>(userDB.getUidByTid(tid));

                ?{
                    tid = tid;
                    content = con_.text;
                    time = con_.time;
                    user =  Option.unwrap<User.User>(userDB.getUserProfile(uid));
                    url = con_.url;
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
        
        /*
        * get user older five tweets
        * 
        */
        public func getUserOlderFiveTweets(user : Principal, number : Nat) : ?[var ShowTweet]{
            switch(userDB.getUserAllTweets(user)){
                case(null) { null };
                case(?tids){
                    var size : Nat = tids.size();
                    if(number >= size){
                        return null;
                    }else{
                        var i : Nat = 1;
                        var tempArray = Array.init<ShowTweet>(size, Tweet.defaultType().defaultShowTweet);
                        while((number + i < size -1) and (i < 5)){
                            var tempTweet : ShowTweet = switch(getShowTweetById(size - 1 - number - i)){
                                case(?tweet){ tweet };
                                case(_) { Tweet.defaultType().defaultShowTweet };
                            };
                            tempArray[i-1] := tempTweet;
                            i += 1;
                        };
                        ?tempArray
                    }
                };
            }
        };

        
        
        /**
        *The following part is comment moudle-------------------comment-------------------------
        **/     





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