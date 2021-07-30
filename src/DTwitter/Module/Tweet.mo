import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
//import User "./User";

module {
    //type User = User.User;
    private type User = {
        uid : Principal;
        uname : Text;
        avatarimg : Text;
    };
    //Tweet ID
    public type TID = Nat32;
    //Tweet content
    public type Content = Text;
    //Tweet topic
    public type Topic = Text;
    //tweet time
    public type Time = Text;
    //tweet owner
    public type Owner = Principal;

    //后续全部改成外键， tweet内容全部用数据库存着
    public type Tweet = {
        tid : Nat32;
        content : Text;
        topic : Text;
        time : Text;
        // change to principal
        owner : Principal;
        url : Text; //图床
        //just beginning, should be changed
        //todo
        //visiable
    };

    public type showTweet = {
        tid : Nat32;
        content : Text;
        topic : Text;
        time : Text;
        user : User;
        url : Text;
    };


};