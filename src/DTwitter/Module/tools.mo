import Nat32 "mo:base/Nat32";

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

};