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
    public type Comment = Text;
    //tweet like
    public type Like = {
        like_number : Nat32;
        like_List : [Principal];
    };

    public type Tweet = {
        tid : TID;
        content : Content;
        topic : Topic;
        time : Time;
        owner : Owner;
        comment : Comment;
        like : Like;
    };

    public type TweetMap = HashMap.HashMap<Nat32, Tweet>;



};