import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import User "./User";

module {
    //Tweet ID
    public type TID = Nat;
    //Tweet content
    public type Content = Text;
    //Tweet topic
    public type Topic = Text;
    //tweet time
    public type Time = Text;
    //tweet owner
    public type Owner = Principal;
    
    //Todo : visiable
    public type Tweet = {
        tid : Nat;
        // parentTid = 0  no parent tweet
        // parentTid > 0 the type of this tweet is comment, comment is parentTid
        // parentTid < 0 the type of this tweet is  retweet
        parentTid : Int;
    };

    public type parentTweet = {
        // cor : true -> comment; false -> retweet
        cor : Bool;
        tid : Nat;
        content : Text;
        time : Text;
        user : User.User;
        url : Text;
    };

    /*
    * 返回给用户的Tweet， 只作为返回值，不作为存储值
    * tweet module : back to user 
    */
    public type showTweet = {
        tid : Nat;
        content : Text;
        //topic : Text;
        time : Text;
        user : User.User;
        url : Text;
        likeNumber : Nat;
        commentNumber : Nat;
        parentTweet : ?parentTweet;
    };

    public class defaultType() {
        public let defaultTweet : Tweet = {
            tid = 0;
            parentTid = 0;
        };

        public let defaultShowTweet : showTweet = {
            tid = 0;
            content = "default";
            time = "0:0:0";
            user = User.defaultType().defaultUser;
            url = "default";
            likeNumber = 0;
            commentNumber = 0;
            parentTweet = null;
        };
    };

    // get tweet type from parentTid
    // parentTid = 0  no parent tweet, return null
    // parentTid > 0 the type of this tweet is comment, return true
    // parentTid < 0 the type of this tweet is  retweet, return false
    public func getTweetType(parentTid : Int) : ?Bool{
        if(parentTid < 0){ ?false }
        else if(parentTid == 0) { null }
        else{ ?true }
    };



};