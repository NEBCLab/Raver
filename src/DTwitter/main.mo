import UserDB "./Database/UserDB";
import TweetDB "./Database/TweetDB";
import Tweet "./Module/Tweet";
import User "./Module/User";
import Error "mo:base/Error";
import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Option "mo:base/Option";
import Int "mo:base/Int";

actor DTwitter{
    type User = User.User;
    type ShowTweet = Tweet.showTweet;
    type ShowUser = User.showUser;
    private var userDB = UserDB.userDB();
    private var tweetDB = TweetDB.tweetDB(userDB);

    /**
    * add user
    * @param msg : Internet Identity
    * @pararm uname ; user name 
    * @return successful -> true; failed : false
    */
    public shared(msg) func addUser(username : Text,nickname : Text, avatarimg: Text) : async Bool{
        userDB.addUser({
            uid = msg.caller;
            nickname =nickname;
            username = username;
            avatarimg = avatarimg;
        })
    };
    

    /**
    * delete user
    * @param msg : Internet Identity
    * @return successful -> true; failed : false
    */
    public shared(msg) func deleteUser() : async Bool{
        var tweetArray = Option.get<[Nat]>(userDB.getUserAllTweets(msg.caller), []);
        var status = true;
        for(x in tweetArray.vals()){
            if(tweetDB.deleteTweet(msg.caller, x) == false) status := false;
            userDB.deleteTweetUser(x);
        };
        if(userDB.deleteUser(msg.caller) == false) status := false;
        return status;
    };

    public query func isUserExist(uid : Principal) : async Bool{
        userDB.isUserExist(uid)
    };

    public query func isUserNameUsed(userName : Text) : async Bool{
        userDB.isUserNameUsed(userName)
    };

    /**
    * @param msg : internet identitiy
    * @param uname : Text new user name
    * @return successful -> true; failed : false
    */
    public shared(msg) func changeUserProfile(nickname : Text, username : Text, avatarimg : Text) : async Bool{
        userDB.changeUserProfile(msg.caller, {
            uid = msg.caller;
            nickname = nickname;
            username = username;
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
            case(_){ throw Error.reject("no such user") };
        }
    };

    public query func getShowUserProfileByPrincipal(uid : Principal) : async ShowUser{
        switch(userDB.getShowUserProfile(uid)){
            case(?showuser){ showuser };
            case(_){ throw Error.reject("no such user") };
        }
    };

    public query func getShowUserProfileByUserName(userName : Text) : async ShowUser{
        var uid = switch(userDB.getPrincipalByUserName(userName)){
            case null{throw Error.reject("can't find this username")};
            case(?principal){principal};
        };
        switch(userDB.getShowUserProfile(uid)){
            case(?showuser){ showuser };
            case(_){ throw Error.reject("no such user") };
        }
    };
    /**
    * create a tweet 
    * @param topic : Text -> tweet topic
    * @param content : Text -> tweet content
    * @param time : Text -> send tweet time
    * @return bool : if add tweet successfully
    */
    //todo : topic
    public shared(msg) func addTweet(content : Text, time : Text, url : Text, parentTid : Int) : async Bool{
        if(tweetDB.createTweet(content, time, msg.caller, url, parentTid) != 0){
            true
        }else{
            false
        }
    };

    public shared(msg) func reTweet(content : Text, time : Text, url : Text, parentTid : Int) : async Bool{
        if(tweetDB.createTweet(content, time, msg.caller, url, parentTid) != 0){
            true
        }else{
            false
        }
    };

    /**
    * get user's all tweet id
    * @param msg : msg
    * @return user's all tweet id array : [Nat]
    */
    public query func getUserAllTid(uid : Principal) : async [Nat]{
        switch(userDB.getUserAllTweets(uid)){
            case ( null ){ [] };
            case (?array) { array };
        }
    };

    //get user's all show tweet
    public query func getUserAllTweets(uid : Principal) : async [ShowTweet]{
        switch(userDB.getUserAllTweets(uid)){
            case null { throw Error.reject("no tweets has been found") };
            case (?array){
                var tempArray = Array.init<ShowTweet>(array.size(), Tweet.defaultType().defaultShowTweet);
                var i = 0;
                for(k in array.vals()){
                    tempArray[i] := Option.unwrap<ShowTweet>(tweetDB.getShowTweetById(k));
                    i := i + 1;
                };
                Array.freeze<ShowTweet>(tempArray)
            };
        }
    };

    
    /*
    * get user newest 10 tweets (<= 10)
    */
    public shared(msg) func getUserLastestTenTweets() : async [ShowTweet]{
        tweetDB.getUserLastestTenTweets(msg.caller)
    };

    //获取关注用户及自己的最新20条post
    public query func getFollowLastest20Tweets(uid : Principal, lastTid : Nat) : async [ShowTweet]{
        var TidArray = tweetDB.getFollowLastest20Tweets(uid, lastTid);
        var tempArray = Array.init<ShowTweet>(TidArray.size(), Tweet.defaultType().defaultShowTweet);
        var i = 0;
        for(k in TidArray.vals()){
            tempArray[i] := Option.unwrap<ShowTweet>(tweetDB.getShowTweetById(k));
            i := i + 1;
        };
        Array.freeze<ShowTweet>(tempArray)
    };

    //获取关注用户及自己的最新amount条post
    public query func getFollowLastestAmountTweets(uid : Principal, lastTid : Nat, amount : Nat) : async [ShowTweet]{
        var TidArray = tweetDB.getFollowLastestAmountTweets(uid, lastTid, amount);
        var tempArray = Array.init<ShowTweet>(TidArray.size(), Tweet.defaultType().defaultShowTweet);
        var i = 0;
        for(k in TidArray.vals()){
            tempArray[i] := Option.unwrap<ShowTweet>(tweetDB.getShowTweetById(k));
            i := i + 1;
        };
        Array.freeze<ShowTweet>(tempArray)
    };

    /**
    * @param number : Nat -> [Tweet] size <= 5
    */
    public query func getUserOlder20Tweets(tid : Nat, uid : Principal) : async [ShowTweet]{
        switch(tweetDB.getUserOlder20Tweets(uid, tid)){
            case(null) { [] };
            case(?tweets){ tweets };
        }
    };


    /**
    * get tweet by Tid
    * @param Tid : tweet id
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

    public query func getLastestTweeTid() : async Nat{
        tweetDB.getLastestTweetId()
    };

    /*
    * if tweet is existed
    * @param Tid tweet id
    * @reutrn existed or do not exist
    */
    public query func isExist(tid : Nat) : async Bool{
        tweetDB.isTweetExist(tid)
    };

    public shared(msg) func deleteTweet(tid : Nat) : async Bool{
        tweetDB.deleteTweet(msg.caller, tid)
    };

    public shared(msg) func changeTweet(tid : Nat, content : Text, time : Text, url : Text) : async Bool{ 
        switch(tweetDB.getShowTweetById(tid)){
            case(null) { return false; };
            case(?t) {
                assert(t.user.uid == msg.caller);
            };
        };
        tweetDB.changeTweet(tid, content, time, msg.caller, url)
    };


    /**
    *The following part is follow moudle-------------------follow-------------------------
    **/

    /**
    * get user attention user
    * @param msg
    * @param uid : user principal
    * @return [Principal] user followed by user  
    */
    public query func getFollow(uid : Principal) : async [ShowUser]{
        var followArray = userDB.getFollow(uid);
        var userArray = Array.init<ShowUser>(followArray.size(), User.defaultType().defaultShowUser);
        var count = 0;
        while(count < followArray.size()){
            userArray[count] := switch(userDB.getShowUserProfile(followArray[count])){
                case null{User.defaultType().defaultShowUser};
                case(?showuser){showuser};
            };
        };
        Array.freeze<ShowUser>(userArray)
    };


    public query func getFollowAmount(uid : Principal) : async Nat{
        var followArray = userDB.getFollow(uid);
        followArray.size()
    };


    /**
    * get user follower
    * @param msg
    * @param uid : user principal
    * @return [Principal] user followed by user  
    */
    public query func getFollower(uid : Principal) : async [ShowUser]{
        var followerArray = userDB.getFollower(uid);
        var userArray = Array.init<ShowUser>(followerArray.size(), User.defaultType().defaultShowUser);
        var count = 0;
        while(count < followerArray.size()){
            userArray[count] := switch(userDB.getShowUserProfile(followerArray[count])){
                case null{User.defaultType().defaultShowUser};
                case(?showuser){showuser};
            };
        };
        Array.freeze<ShowUser>(userArray)
    };


    public query func getFollowerAmount(uid : Principal) : async Nat{
        var followerArray = userDB.getFollower(uid);
        followerArray.size()
    };


    public query func isTwoUserFollowEachOther(user_A : Principal, user_B : Principal) : async Bool{
        var result = userDB.isAFollowedByB(user_A, user_B);
        if(result == 0 or result ==10) return false;
        if(result == 6) throw Error.reject("A does not exist");
        if(result == 7) throw Error.reject("B does not exist");
        if(result == 1){
            var result_reverse = userDB.isAFollowedByB(user_B, user_A);
            if(result_reverse == 0) return false;
            if(result_reverse == 10 or result_reverse == 6  or result_reverse == 7) throw Error.reject("Unknown Error");
            if(result_reverse == 1) return true;
        };
        false
    };

    public query func isAFollowedByB(user_A : Principal, user_B : Principal) : async Bool{
        var result = userDB.isAFollowedByB(user_A, user_B);
        if(result == 0 or result ==10) return false;
        if(result == 6) throw Error.reject("A does not exist");
        if(result == 7) throw Error.reject("B does not exist");
        if(result == 1) return true;
        false;
    };

    public shared(msg) func addFollow(follow : Principal): async Bool{
        var stepOne = userDB.addFollow(follow, msg.caller);
        var stepTwo = userDB.addFollower(follow, msg.caller);
        if(stepOne and stepTwo) true
        else false
    };

    public shared(msg) func cancelFollow(follow : Principal): async Bool{
        var stepOne = userDB.cancelFollow(follow, msg.caller);
        var stepTwo = userDB.cancelFollower(follow, msg.caller);
        if(stepOne == 1 and stepTwo == 1) true
        else false
    };

    /**                Cooment                                 **/
    public shared(msg) func addComment(text : Text, time : Text, url : Text, parentTid : Int) : async Bool{
        let cid = tweetDB.createTweet(text, time, msg.caller, url, parentTid);
        tweetDB.addComment(Int.abs(parentTid), cid);
    };

    public shared(msg) func deleteComment(cid : Nat) : async Bool{
        ignore tweetDB.deleteTweet(msg.caller, cid);
        ignore tweetDB.deleteComment(cid);
        true
    };

    public query func getTweetAllComments(tid : Nat) : async [ShowTweet]{
        switch(tweetDB.getTweetAllComments(tid)){
            case null { [] };
            case (?tweets){ tweets };
        }
    };

    public query func getTweetCommentNumber(tid : Nat) : async Nat{
        tweetDB.getCommentNumber(tid)
    };

    public shared(msg) func deleteTweetAllComment(tid : Nat) : async Bool{
        if(msg.caller == Option.unwrap<Principal>(userDB.getUidByTid(tid))){
            tweetDB.deleteTweetAllComment(tid)
        }else{
            throw Error.reject("you have no right");
        }
    };


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

    /**
    *The following part is like moudle-------------------bio-------------------------
    **/
    public query func getBio(uid : Principal) : async Text{
        userDB.getBio(uid)
    };
    public shared(msg) func putBio(bioText : Text){
        userDB.putBio(msg.caller, bioText)
    }
};
