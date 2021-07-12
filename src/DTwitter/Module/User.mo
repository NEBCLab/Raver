import Tweet "./Tweet";
//TODO One User One canister
module {
    //user id
    public type UID = Principal;
    // user name
    public type UName = Text;
    // avatar img url
    public type Avatarimg = Text;
    //user Profile
    public type User = {
        uid : UID;
        uname : UName;
        avatarimg : Avatarimg;
    };
};