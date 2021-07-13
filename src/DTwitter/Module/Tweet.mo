import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import User "./User";

module {
    type User = User.User;
    //Tweet ID
    public type TID = Nat32;
    //URL 
    //public type URL = Text;
    //Tweet content
    public type Content = Text;
    //Tweet topic
    public type Topic = Text;
    //tweet time
    public type Time = Text;
    //tweet owner
    public type Owner = Principal;

    public type Tweet = {
        tid : Nat32;
        content : Text;
        topic : Text;
        time : Text;
        user : User;
        url : Text;
        //just beginning, should be changed
        //todo
        //visiable
    };


};