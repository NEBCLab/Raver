import Nat32 "mo:base/Nat32";
import List "mo:base/List";

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

  //get elemnt E's preElement
  public func getPreElement<T>(list : List<T>, ele_ : T) : List<T>{
    switch(list){
      case null { null };
      case (?(tEle, nl)){
        switch(nl){
          case null { null };
          case (?(nE, nnl)){
            if(nE == ele_){
              list
            }else{
              getPreElement(nl, ele_)
            }
          };
        }
      }
    }
  };

  //delete element ele_ from list l
  public func deleteListElement<T>(l : List.List<T>, ele_ : T) : List.List<T>{
    var preElement = getPreElement<Nat>(l, ele_);
    switch(preElement){
      case null { null };
      case (?(tE, nl)){
        switch(nl){
          case null { null };
          case (?(nE, nnl)){
            ?(tE, nnl)
          }
        }
      }
    }
  };


  //get elemnt E's preElement 
  //get push element
  public func getPreElement(list : List.List<Nat>, ele_ : Nat) : List.List<Nat>{
    switch(list){
      case null { null };
      case (?(tEle, nl)){
        switch(nl){
          case null { null };
          case (?(nE, nnl)){
            if(nE == ele_){
              list
            }else{
              getPreElement(nl, ele_)
            }
          };
        }
      }
    }
  };

  public func deleteListElement(l : List.List<Nat>, ele_ : Nat) : List.List<Nat>{
    var preElement = getPreElement(l, ele_);
    switch(preElement){
      case null { null };
      case (?(tE, nl)){
        switch(nl){
          case null { null };
          case (?(nE, nnl)){
            ?(tE, nnl)
          }
        }
      }
    }
  };


};