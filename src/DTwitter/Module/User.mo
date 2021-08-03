import Principal "mo:base/Principal";
import Text "mo:base/Text";

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

    //private let defaultPrincipal : Principal.Principal = Principal.fromText("default");
    public class defaultType(){
        private let defaultPrincipal : Principal = Principal.fromText("default");
        public let defaultUser : User = {
            uid = defaultPrincipal;
            uname = "default";
            avatarimg = "default";
        };
    };


};