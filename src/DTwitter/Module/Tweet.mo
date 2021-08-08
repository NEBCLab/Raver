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

    //外键， tweet内容全部用数据库存着
    //存储的tweet 当前版本要将字段全部转换为相应数据库的主键
    public type Tweet = {
        tid : Nat;
        
        // parentTid = 0  no parent tweet
        // parentTid < 0 the type of this tweet is comment, comment is parentTid
        // parentTid > 0 the type of this tweet is  retweet
        parentTid : Int;
        //visiable : todo
    };

    public type parentTweet = {
        // cor : comment or retweet : 0 -> comment, retweet : 1
        cor : Nat;
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

};