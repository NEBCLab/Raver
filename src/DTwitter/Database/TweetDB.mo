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
import tools "../Module/tools";
import Int "mo:base/Int";

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
        private var tid : Nat = 0;

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

        /**
        * @param parentTid :         
                0  no parent tweet
                > 0 the type of this tweet is comment, comment is parentTid
                < 0 the type of this tweet is retweet, retweeted tweet tid is parentTid
        */
        public func createTweet(text : Text, time : Text, uid : Principal, url : Text, parentTid : Int) : Nat{
            let tid = increaseTID();
            let tweet : Tweet.Tweet = {
                tid = tid ;
                parentTid = parentTid;
            };
            let content = contentDB.make(text, time, url);
            tweetMap.put(tid, tweet);
            ignore contentDB.add(tid, content);
            if(userDB.addTweet(uid, tid)){
                tid
            }else{
                0
            }
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
                let parentTweet_ : ?Tweet.parentTweet = makeParentTweetByTid(tid);
                ?{
                    tid = tid;
                    content = con_.text;
                    time = con_.time;
                    user =  Option.unwrap<User.User>(userDB.getUserProfile(uid));
                    url = con_.url;
                    likeNumber = likeDB.likeAmount(tid);
                    commentNumber = commentDB.getNumber(tid);
                    parentTweet = parentTweet_;
                }
            }else{
                null
            }
        };


        //获取关注用户及自己的50条post
        public func getFollowOlder50Tweets(uid : Principal, oldTID : Nat) : [ShowTweet]{
            var followArray = userDB.getFollow(uid);
            var tweetArray = Array.init<[Nat]>(followArray.size()+1, []);
            var count = 0; var result_count = 0;
            var allSize=0;
            var actSize=0;
            var pos = Array.init<Int>(followArray.size()+1,1);
            for(x in followArray.vals()){
                tweetArray[count] := switch(userDB.getUserAllTweets(x)){
                    case null{[]};
                    case(?array){
                        allSize+=array.size();
                        array
                    };
                };
                count+=1;
            };
            tweetArray[count] := switch(userDB.getUserAllTweets(uid)){
                case null{[]};
                case(?array){
                    allSize+=array.size();
                    array
                };
            };
            count+=1;
            while(count > 0){
                pos[count-1] := tools.binarySearchLess(tweetArray[count-1], oldTID);
                if(pos[count-1] >= 0){
                    actSize := actSize+1+Int.abs(pos[count-1]);
                };
                count -= 1;
            };
            var array_size = 50;
            if(actSize < 50) array_size := actSize;
            var result = Array.init<ShowTweet>(actSize,Tweet.defaultType().defaultShowTweet);
            var i = 1;
            while(i <= actSize and i <= allSize){
                count := 0;
                var maxn=0;
                var maxn_count=0;
                while(count < followArray.size()+1 and pos[count] >= 0){
                    var t = Int.abs(pos[count]);
                    if(tweetArray[count][t] > maxn){
                        maxn := tweetArray[count][t];
                        maxn_count := count;
                    };
                    count+=1;
                };
                pos[maxn_count]-=1;
                result[result_count]:=Option.unwrap<ShowTweet>(getShowTweetById(maxn));
                result_count+=1;
                i+=1;
            };
            Array.freeze<ShowTweet>(result)
        };

        //获取关注用户及自己的amount条最新post
        public func getFollowLastestAmountTweets(uid : Principal, lastTID : Nat, amount : Nat) : [Nat]{
            var followArray = userDB.getFollow(uid);
            var tweetArray = Array.init<[Nat]>(followArray.size()+1, []);
            var count = 0; var result_count = 0;
            var result = Array.init<Nat>(amount,0);
            var allSize=0;
            for(x in followArray.vals()){
                tweetArray[count] := switch(userDB.getUserAllTweets(x)){
                    case null{[]};
                    case(?array){
                        allSize+=array.size();
                        array
                    };
                };
                count+=1;
            };
            tweetArray[count] := switch(userDB.getUserAllTweets(uid)){
                case null{[]};
                case(?array){
                    allSize+=array.size();
                    array
                };
            };
            var i = 1;
            var hasSel = Array.init<Nat>(followArray.size()+1,1);
            while(i <= amount and i <= allSize){
                count := 0;
                var maxn=0;
                var maxn_count=0;
                while(count < followArray.size()+1){
                    var t : Int = tweetArray[count].size()-hasSel[count];
                    if(t >= 0 and tweetArray[count][tweetArray[count].size()-hasSel[count]] > maxn){
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
        
        public func getUserOlder20Tweets(user : Principal, oldTid : Nat) : [ShowTweet]{
            switch(userDB.getUserAllTweets(user)){
                case(null) { [] };
                case(?tweetId){
                    var size = tweetId.size();
                    var pos : Int = size-1;
                    if(oldTid != 0) pos := tools.binarySearchLess(tweetId, oldTid);
                    if(pos == -2 or pos == -1) return [];
                    var back_size = 20;
                    if(pos+1 < 20) back_size := Int.abs(pos+1);
                    var backArray = Array.init<ShowTweet>(back_size, Tweet.defaultType().defaultShowTweet);
                    var i = 0;
                    var posNat = Int.abs(pos+1);
                    while(posNat > 0 and i < back_size){
                        backArray[i] := Option.unwrap<ShowTweet>(getShowTweetById(tweetId[posNat-1]));
                        posNat -= 1;
                        i += 1;
                    };
                    Array.freeze<ShowTweet>(backArray);
                };
            }
        };

        /********************* COMMENT DATABASE ************************************************/
        //the type of tid and cid is TID, tid : commented tweet, cid : comment tweet
        public func addComment(tid : Nat, cid : Nat) : Bool{
            commentDB.add(tid, cid)
        };

        public func deleteComment(cid : Nat) : Bool{
            var tid = Int.abs(Option.unwrap<Tweet.Tweet>(tweetMap.get(cid)).parentTid);
            if(tid <= 0) {return false;};
            commentDB.delete(tid, cid)
        };

        public func getTweetOlder20Comments(tid : Nat, oldTid : Nat) : [ShowTweet]{
            switch(commentDB.getTweetOlder20Comments(tid)){
                case null { [] };
                case (?tweetId){
                    var size = tweetId.size();
                    var pos : Int = size-1;
                    if(oldTid != 0) pos := tools.binarySearchLess(tweetId, oldTid);
                    if(pos == -2 or pos == -1) return [];
                    var back_size = 20;
                    if(pos+1 < 20) back_size := Int.abs(pos+1);
                    var backArray = Array.init<ShowTweet>(back_size, Tweet.defaultType().defaultShowTweet);
                    var i = 0;
                    var posNat = Int.abs(pos+1);
                    while(posNat > 0 and i < back_size){
                        backArray[i] := Option.unwrap<ShowTweet>(getShowTweetById(tweetId[posNat-1]));
                        posNat -= 1;
                        i += 1;
                    };
                    Array.freeze<ShowTweet>(backArray);
                };
            }
        };

        public func deleteTweetAllComment(tid : Nat) : Bool{
            commentDB.deleteAllComment(tid)
        };

        public func getCommentNumber(tid : Nat) : Nat{
            commentDB.getNumber(tid)
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

        /**
        *   @param tid : tweet id, not parent tweet id
        */
        private func makeParentTweetByTid(tid : Nat) : ?Tweet.parentTweet{
            let tweet = Option.unwrap<Tweet.Tweet>(tweetMap.get(tid));
            var cor = true;
            switch(Tweet.getTweetType(tweet.parentTid)){
                case null { return null; };
                case (?bool){ cor := bool };
            };
            let parT_ = Int.abs(tweet.parentTid);
            let con_ = Option.unwrap<Content.content>(contentDB.get(parT_));
            let uid = Option.unwrap<Principal>(userDB.getUidByTid(parT_));
            ?{
                cor = cor;
                tid = parT_;
                content = con_.text;
                time = con_.time;
                user = Option.unwrap<User.User>(userDB.getUserProfile(uid));
                url = con_.url;
            }
        };


    };
};