module {

    public type content = {
        text : Text;
        time : Text;
        url : Text;
    };

    public class defaultType(){
        public let defaultContent : content = {
            text = "default";
            time = "default";
            url = "default";
        };
    };

};