import Nat32 "mo:base/Nat32";
import List "mo:base/List";
import Int "mo:base/Int";
import Time "mo:base/Time";
import Text "mo:base/Text";

module{
  public func hash(j : Nat32) : Nat32 {
    hashNat8(
    [j & (255 << 0),
      j & (255 << 8),
      j & (255 << 16),
      j & (255 << 24)
    ]);
  };

  public func hashNat8(key : [Nat32]) : Nat32 {
    var hash : Nat32 = 0;
    for (natOfKey in key.vals()) {
      hash := hash +% natOfKey;
      hash := hash +% hash << 10;
      hash := hash ^ (hash >> 6);
    };
    hash := hash +% hash << 3;
    hash := hash ^ (hash >> 11);
    hash := hash +% hash << 15;
    return hash;
  };


  public func binarySearch(array : [Nat], value : Nat) : Nat{
    var start : Int = 0;
    let size = array.size();
    if(size == 0) { return 0; };
    var end : Int = size - 1;
    var middle : Nat = Int.abs((start + end) / 2);
    
    while(array[middle] != value){
      middle := Int.abs((start + end) / 2);
      if(start > end){
          return size;
      };
      if(array[middle] > value){
        end := middle - 1;
      }else if(array[middle] == value){
          return middle;
      }else{
        start := middle + 1;
      };
    };
    return middle;
  };

    public func binarySearchLess(array : [Nat], value : Nat) : Int{
      if(array.size() == 0) return -2;
      var start : Int = 0;
      let size = array.size();
      if(size == 0) { return 0; };
      var end : Int = size;
      var middle : Nat = Int.abs(end / 2);
      if(array[0] >= value) return -1;
      while(start < end){
        middle := Int.abs((start+end)/2);
        if(array[middle] >= value){
          end := middle;
        }else if(array[middle] < value){
          start := middle+1;
        };
      };
      return start;
    };

    public func isLeapYear(year : Nat) : Bool{
      return( (year%4 == 0 and year%100 != 0) or (year%400 == 0) );
    };

    public func getDaysForYear(year : Nat) : Nat{
      if(isLeapYear(year)) 366
      else 365
    };

    //获取当前时间，返回字符串，格式： yyyy-mm-dd hh:mm:ss 
    public func parseTime(time : Int) : Text{
      var mon_yday = [[0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365],[ 0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366]];
      var seconds = time/1000000000;
      var min = seconds/60;
      var hour = min/60;
      var day = hour/24;
      var curYear = 1970;
      var month = 0;

      //计算年
      var daysCurYear = getDaysForYear(curYear);
      while (day >= daysCurYear){
          day -= daysCurYear;
          curYear+=1;
          daysCurYear := getDaysForYear(curYear);
      };
      //计算月日
      var key = 0;
      if(isLeapYear(curYear)) key := 1;
      var i = 1;
      while(i < 13){
        if (day < mon_yday[key][i]){
              month := i;
              day := day - mon_yday[key][i-1] + 1;
              i:=13;
        };
        i+=1;
      };
      seconds%=60;
      min%=60;
      hour%=24;
      return Int.toText(curYear) #"-" #Int.toText(month) #"-" #Int.toText(day) #" " #Int.toText(hour) #":" #Int.toText(min) #":" #Int.toText(seconds);
    };

};