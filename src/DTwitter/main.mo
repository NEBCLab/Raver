import UserDB "./Database/UserDB";
import TweetDB "./Database/TweetDB";
import Tweet "./Module/Tweet";
import User "./Module/User";
import Error "mo:base/Error";

actor DTwitter{
    type User = User.User;
//    type Tweet = Tweet.Tweet;
    //private var tdb = TweetDB.TweetDB();
    private var userDB = UserDB.userDB();

    /**
    * add user
    * @param msg : Internet Identity
    * @pararm uname ; user name 
    * @return successful -> true; failed : false
    */
    public shared(msg) func addUser(uname : Text) : async Bool{
        userDB.addUser({
            uid = msg.caller;
            uname = uname;
        })
    };

    /**
    * delete user
    * @param msg : Internet Identity
    * @return successful -> true; failed : false
    */
    public shared(msg) func deleteUser() : async Bool{
        // switch(userDB.deleteUser(msg.caller)){
        //     case( true ){ true };
        //     //throw Error.reject()
        //     case( false ){ }
        // }
        userDB.deleteUser(msg.caller)
    };

    /**
    * @param msg : internet identitiy
    * @param uname : Text new user name
    * @return successful -> true; failed : false
    */
    public shared(msg) func changeUserProfile(uname : Text) : async Bool{
        userDB.changeUserProfile(msg.caller, {
            uid = msg.caller;
            uname = uname;
        })
    };
    
    /**
    * @param msg
    * @return User
    */
    public shared(msg) func getUserProfile() : async User{
        switch(userDB.getUserProfile(msg.caller)){
            case(?user){ user };
            case(_){ throw Error.reject("No such user") };
        }
    };

    // /**TODO**/
    // public shared(msg) func addTweet() : async Bool{
    //     //TODO
    //     var tid : Nat32 = 0;
    //     userDB.addTweet(msg.caller, tid);
    //     true
    // }; 

    // /**TODO**/
    // public shared(msg) func getUserAllTweets() : async [Tweet]{
    //     []
    // };

    /**
    *{
                    tid = tid;
                    content = content;
                    topic = topic;
                    time = time;
                    owner = owner;
                    comment = {
                        commentNumber = Nat32.fromNat(0); 
                        commentList = [];
                    };
                    like = {
                        likeNumber = Nat32.fromNat(0); 
                        likeList = [];
                    };
                }
                                var nulArray : [Like]= [];
                var tempArray : [Nat32] = [];
    */





};
