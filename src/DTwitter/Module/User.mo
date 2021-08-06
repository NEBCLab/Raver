import Principal "mo:base/Principal";
import Text "mo:base/Text";

//TODO One User One canister
module {
    //user id
    public type UID = Principal;
    // nick name
    public type NickName = Text;
    // username
    public type UserName = Text;
    // avatar img url
    public type Avatarimg = Text;

    public type User = {
        uid : UID;
        nickname : NickName;
        username : UserName;
        avatarimg : Avatarimg;
    };

    //private let defaultPrincipal : Principal.Principal = Principal.fromText("default");
    public class defaultType(){
        private let defaultPrincipal : Principal = Principal.fromText("r7inp-6aaaa-aaaaa-aaabq-cai");
        public let defaultUser : User = {
            uid = defaultPrincipal;
            nickname = "default";
            username = "unset";
            avatarimg = "default";
        };
    };
};