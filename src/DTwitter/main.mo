import UserDB "./Database/UserDB";
import TweetDB "./Database/TweetDB";
import Tweet "./Module/Tweet";
import User "./Module/User";
import Error "mo:base/Error";
import Array "mo:base/Array";
import Nat "mo:base/Nat";

actor DTwitter{
    type User = User.User;
    type ShowTweet = Tweet.showTweet;
    private var userDB = UserDB.userDB();
    private var tweetDB = TweetDB.tweetDB(userDB);

    /**
    * add user
    * @param msg : Internet Identity
    * @pararm uname ; user name 
    * @return successful -> true; failed : false
    */
    public shared(msg) func addUser(uname : Text, avatarimg: Text) : async Bool{
        userDB.addUser({
            uid = msg.caller;
            uname = uname;
            avatarimg = avatarimg;
        })
    };

    /**
    * delete user
    * @param msg : Internet Identity
    * @return successful -> true; failed : false
    */
    public shared(msg) func deleteUser() : async Bool{
        userDB.deleteUser(msg.caller)
    };

    public query func ifUserExisted(uid : Principal) : async Bool{
        userDB.isExist(uid)
    };

    /**
    * @param msg : internet identitiy
    * @param uname : Text new user name
    * @return successful -> true; failed : false
    */
    public shared(msg) func changeUserProfile(uname : Text, avatarimg : Text) : async Bool{
        userDB.changeUserProfile(msg.caller, {
            uid = msg.caller;
            uname = uname;
            avatarimg = avatarimg;
        })
    };
    
    /**
    * @param msg
    * @return User
    */
    public query func getUserProfile(uid : Principal) : async User{
        switch(userDB.getUserProfile(uid)){
            case(?user){ user };
            case(_){ throw Error.reject("No such user") };
        }
    };

    /**
    * create a tweet 
    * @param topic : Text -> tweet topic
    * @param content : Text -> tweet content
    * @param time : Text -> send tweet time
    * @return bool : if add tweet successfully
    */
    public shared(msg) func addTweet(topic : Text, content : Text, time : Text, url : Text) : async Bool{
        tweetDB.createTweet(topic, content, time, msg.caller, url)
    };

    /**
    * get user's all tweet id
    * @param msg : msg
    * @return user's all tweet id array : [Nat]
    */
    public query func getUserAllTweets(uid : Principal) : async [Nat]{
        switch(userDB.getUserAllTweets(uid)){
            case ( null ){ [] };
            case (?array) { array };
        }
    };

    
    /*
    * get user newest 10 tweets (<= 10)
    */
    public query func getUserLastestTenTweets(uid : Principal) : async [ShowTweet]{
        // user tweet tid
        var array = switch(userDB.getUserAllTweets(uid)){
            case ( null ){ [] };
            case (?array) { array };
        };
        let tweets : [var ShowTweet] = Array.init<ShowTweet>(10, Tweet.defaultType().defaultTweet);
        var i : Nat = 0;
        if(array.size() >= 10){
            while(i < 10){
                switch(tweetDB.getShowTweetById(array[array.size() - i - 1])){
                    case(null) {
                        i += 1;
                    };
                    case(?tweet) { 
                        tweets[i] := tweet;
                        i += 1;
                    };
                };
            };
            tweets
        }else{
            while(i < array.size()){
                switch(tweetDB.getShowTweetById(array[array.size() - i -1])){
                    case(null) {
                        i += 1;
                    };
                    case(?tweet) { 
                        i += 1;
                        tweets[i] := tweet;
                    };
                };
            };
            tweets
        }
    };


    /**
    * @param number : Nat -> [Tweet] size <= 5
    */
    public query func getUserOlderFiveTweets(number : Nat) : async [ShowTweet]{
        switch(userDB.getUserAllTweets(msg.caller)){
            case(null) { [] };
            case(?tids){
                var size = tids.size();
                if(number >= size){
                    return [];
                }else{
                    var i : Nat = 0;
                    var tempArray = Array.init<ShowTweet>(5, Tweet.defaultType().defaultTweet);
                    while((number + i <= size -1) and (i < 5)){
                        tempArray[i] := switch(tweetDB.getShowTweetById(size - 1 - number -1 - i)){
                            case(?tweet){ tweet };
                            case(_) { throw Error.reject("no tweet") };
                        };
                        i += 1;
                    };
                    tempArray
                }
            };
        };
    };

    /****/
    public shared(msg) func getFollowFiveTweets(follow : Principal, number : Nat) : async [ShowTweet]{
        assert(userDB.isExist(follow));
        tweetDB.getFollowFiveTweets(follow, number)
    };


    /**
    * get tweet by tid
    * @param tid : tweet id
    * @return whrow Error or return tweet
    */
    public query func getTweetById(tid : Nat) : async ShowTweet{
        switch(tweetDB.getShowTweetById(tid)){
            case(null){
                throw Error.reject("no such tweet or worng id")
            };
            case(?t){
                t
            };
        }
    };

    public query func getLastestTweetId() : async Nat{
        tweetDB.getLastestTweetId()
    };

    public shared(msg) func reTweet(tid : Nat) : async Bool{
        tweetDB.reTweet(tid, msg.caller);
    };

    /*
    * if tweet is existed
    * @param tid tweet id
    * @reutrn existed or do not exist
    */
    public query func isExist(tid : Nat) : async Bool{
        tweetDB.isTweetExist(tid)
    };

    public shared(msg) func deleteTweet(tid : Nat) : async Bool{
        tweetDB.deleteTweet(msg.caller, tid)
    };

    public shared(msg) func changeTweet(tid : Nat, topic : Text, content : Text, time : Text, url : Text) : async Bool{ 
        switch(tweetDB.getShowTweetById(tid)){
            case(null) { return false; };
            case(?t) {
                assert(t.user.uid == msg.caller);
            };
        };
        tweetDB.changeTweet(tid, ShowTweet {
            tid = tid;
            topic = topic;
            content = content;
            time = time;
            owner = msg.caller;
            url = url;
        })
    };

    public query func getTopicAllTweet(topic : Text) : async [Nat]{
        switch(tweetDB.findTweetByTopic(topic)){
            case(null){ [] };
            case(?array){ array };
        }
    };


    /**
    * get user attention user
    * @param msg
    * @param uid : user principal
    * @return [Principal] user followed by user  
    */
    public shared(msg) func getFollow(uid : Principal) : async [Principal]{
        switch(userDB.getFollow(msg.caller)){
            case(null){ throw Error.reject("no such user") };
            case(?array) { array };
        };
    };

    /**
    * get user follower
    * @param msg
    * @param uid : user principal
    * @return [Principal] user followed by user  
    */
    public shared(msg) func getFollower(uid : Principal) : async [Principal]{
        switch(userDB.getFollower(msg.caller)){
            case(null){ throw Error.reject("no such user") };
            case(?array) { array };
        };
    };


    /** TODO**/
    // public shared(msg) func deleteFollow() ： async Bool{};


    /**
    *The following part is like moudle-------------------like-------------------------
    **/
    public query func likeAmount(tid : Nat) : async Nat{
        tweetDB.likeAmount(tid)
    };

    public shared(msg) func likeTweet(tid : Nat, uid : Principal) : async Bool{
        tweetDB.likeTweet(tid, msg.caller)
    };

    public shared(msg) func cancelLike(tid : Nat, uid : Principal) : async Bool{
        tweetDB.cancelLike(tid, msg.caller)
    };

    public query  func getTweetLikeUsers(tid : Nat) : async [Principal]{
        switch(tweetDB.getTweetLikeUsers(tid)){
            case(null){ throw Error.reject("no one has liked this tweet") };
            case(?array) { array };
        }
    };

    public query func isTweetLiked(tid : Nat, uid : Principal) : async Bool{
        tweetDB.isTweetLiked(tid, uid)
    };

};
