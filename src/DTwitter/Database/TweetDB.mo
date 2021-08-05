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

        public func getLastestTweetId() : Nat{
            tid
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
                        likeDB.deleteLikeDB(tid);
                        switch(contentDB.delete(tid), commentDB.deleteTweet(tid)){
                            case(true, true){
                                true
                            };
                            case(_){
                                false
                            };
                        };
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

        public func getFollowLastestTenTweets(uid : Principal, lastTID : Nat) : [Nat]{
            var followArray = userDB.getFollow(uid);
            var tweetArray = Array.init<[Nat]>(followArray.size(), []);
            var count = 0; var result_count = 0;
            var result = Array.init<Nat>(10,0);
            var allSize=0;
            for(x in followArray.vals()){
                tweetArray[count] := switch(userDB.getUserAllTweets(uid)){
                    case null{[]};
                    case(?array){
                        allSize+=array.size();
                        array
                    };
                };
                count+=1;
            };
            var i = 1;
            var hasSel = Array.init<Nat>(followArray.size(),1);
            while(i <= 10 and i <= allSize){
                count := 0;
                var maxn=0;
                var maxn_count=0;
                while(count < followArray.size()){
                    if(tweetArray[count][tweetArray[count].size()-hasSel[count]] > maxn){
                        maxn := tweetArray[count][tweetArray[count].size()-hasSel[count]];
                        maxn_count := count;
                    };
                    count+=1;
                };
                if(maxn <= lastTID){
                    return Array.freeze<Nat>(result);
                };
                hasSel[maxn_count]+=1;
                result[result_count]:=maxn;
                result_count+=1;
                i+=1;
            };
            Array.freeze<Nat>(result)
        };


        public func getUserLastestTenTweets(uid : Principal) : [ShowTweet]{
        // user tweet tid
        var array : [Nat] = switch(userDB.getUserAllTweets(uid)){
            case ( null ){ [] };
            case (?array) { array };
        };
        let tweets : [var ShowTweet] = Array.init<ShowTweet>(10, Tweet.defaultType().defaultShowTweet);
        var i : Nat = 0;
        if(array.size() >= 10){
            while(i < 10){
                switch(getShowTweetById(array[array.size() - i - 1])){
                    case(null) {
                        i += 1;
                    };
                    case(?tweet) { 
                        tweets[i] := tweet;
                        i += 1;
                    };
                };
            };
            Array.freeze<ShowTweet>(tweets)
        }else{
            while(i < array.size()){
                switch(getShowTweetById(array[array.size() - i -1])){
                    case(null) {
                        i += 1;
                    };
                    case(?tweet) { 
                        i += 1;
                        tweets[i] := tweet;
                    };
                };
            };
            Array.freeze<ShowTweet>(tweets)
        }
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