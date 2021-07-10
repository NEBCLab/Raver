import HashMap "mo:base/Hashmap";
import Hash "mo:base/Hash";

module {
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
    //tweet comment
    public type Comment = {
        commentNumber : Nat32;
        commentList : [Text];
    };
    //tweet like
    public type Like = {
        likeNumber : Nat32;
        likeList : [Principal];
    };

    public type Tweet = {
        tid : Nat32;
        content : Text;
        topic : Text;
        time : Text;
        owner : Principal;
        comment : Comment;
        like : Like;
        //todo
        //visiable
    };


};