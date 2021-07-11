import UserDB "./Database/UserDB";
import TweetDB "./Database/TweetDB";
import Tweet "./Module/Tweet";
import User "./Module/User";
import Error "mo:base/Error";

actor DTwitter{
    type User = User.User;
    type Tweet = Tweet.Tweet;
    //private var tdb = TweetDB.TweetDB();
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
        // switch(userDB.deleteUser(msg.caller)){
        //     case( true ){ true };
        //     //throw Error.reject()
        //     case( false ){ }
        // }
        userDB.deleteUser(msg.caller)
    };

    public shared(msg) func ifUserExisted() : async Bool{
        userDB.isExist(msg.caller)
    };

    /**
    * @param msg : internet identitiy
    * @param uname : Text new user name
    * @return successful -> true; failed : false
    */
    public shared(msg) func changeUserProfile(uname : Text) : async Bool{
        userDB.changeUserProfile(msg.caller, {
            uid = msg.caller;
            uname = uname;
        })
    };
    
    /**
    * @param msg
    * @return User
    */
    public shared(msg) func getUserProfile() : async User{
        switch(userDB.getUserProfile(msg.caller)){
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
    public shared(msg) func addTweet(topic : Text, content : Text, time : Text) : async Bool{
        tweetDB.createTweet(topic, content, time, msg.caller)
    };

    //is Existed

    /**
    * get user's all tweet id
    * @param msg : msg
    * @return user's all tweet id array : [Nat32]
    */
    public shared(msg) func getUserAllTweets() : async [Nat32]{
        switch(userDB.getUserAllTweets(msg.caller)){
            case ( null ){ [] };
            case (?array) { array };
        }
    };

    /**
    * get tweet by tid
    * @param tid : tweet id
    * @return whrow Error or return tweet
    */
    public query func getTweetById(tid : Nat32) : async Tweet{
        switch(tweetDB.getTweetById(tid)){
            case(null){
                throw Error.reject("no such tweet or worng id")
            };
            case(?t){
                t
            };
        }
    };

    public query func getLastestTweetId() : async Nat32{
        tweetDB.getLastestTweetId()
    };

    public shared(msg) func reTweet(tid : Nat32) : async Bool{
        tweetDB.reTweet(tid, msg.caller);
    };

    public func likeTweet(tid : Nat32) : async Bool{
        tweetDB.likeTweet()
    };

    public func cancelLike(tid : Nat32) : async Bool{
        tweetDB.cancelLike()
    };

    /*
    * if tweet is existed
    * @param tid tweet id
    * @reutrn existed or do not exist
    */
    public query func isExist(tid : Nat32) : async Bool{
        tweetDB.isExist(tid)
    };

    public shared(msg) func deleteTweet(tid : Nat32) : async Bool{
        tweetDB.deleteTweet(msg.caller)
    };

    public shared(msg) func changeTweet(tid : Nat32, topic : Text, content : Text, time : Text) : async Bool{
        let oldTweet = switch(tweetDB.getTweetById(tid)){
            case(null) { return false; };
            case(?t) { t };
        };
        assert(msg.caller == t.owner);
        tweetDB.changeTweet(tid, {
            tid = tid;
            topic = topic;
            content = content;
            time = time;
            owner = msg.caller;
            likeNumber = oldTweet.likeNumber;
            commentNumber = oldTweet.commentNumber;
        })
    };

    public query func getTopicAllTweet(topic : Text) : async [Nat32]{
        switch(findTweetByTopic(topic)){
            case(null){ [] };
            case(?array){ array };
        }
    };

    public shared(msg) func likeTweet(tid) : async Bool{
        tweetDB.likeTweet(tid)
    };

    public shared(msg) func cancelLike(tid) : async Bool{
        tweetDB.cancelLike(tid)
    };
};
