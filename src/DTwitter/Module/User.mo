import Tweet "./Tweet";
//TODO One User One canister
module {
    //user id
    public type UID = Principal;
    // user name
    public type UName = Text;
    
    //to do
    public type Follower = {
        followerNumber : Nat32;
        followerList : [Principal];
    };

    //to do : attention

    //user Profile
    public type User = {
        uid : UID;
        uname : UName;
    };
};