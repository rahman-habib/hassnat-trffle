pragma solidity ^0.5.0;

contract PerformanceCheck {
  // Events
  event BuildingAdded(string indexed BI);
  event CaseCreated(uint256 caseCount,
    address  Owner,
    address  Contractor,
    address FM,
    string BuildingId,
    bytes32[] TsetIDs,
    bytes32[] TIDs,
    bytes32[] RHuIDs,
    bytes32[] AQuIDs,
    uint256 time);

  event diffcalculated(uint256 diff);

// initial variables
  address payable public contractOwner;
  uint256 public caseCount = 0;
  uint256 public measurmentCount = 0;
  uint256 public EmeasurmentCount = 0;
  //uint256 public compareCount = 0;
  //uint256 public diffCount = 0;
  uint256 public TxCount = 0;
  //uint256 public diff = 0;
  //uint256 public  size0 = 0;
  uint256 public amountCO = 0;
  uint256 public amountFM = 0;
  uint256 public xtime = 0;
  uint256 public FMFCount = 0;
  uint256 public COFCount = 0;
  uint256 public AllfineCount = 0;
  uint256 public FMFaults = 0;
  uint256 public COFaults = 0;
  uint256 public NoFault = 0;
  uint256 public state = 0;
  uint256 public stime = 0;
  bool public b = false;

  address payable public _toCo;
  address payable public _toFM;
  mapping (address => uint256) private balances;

//the buildings which should be observed are saved in this struct
  struct CaseItem {
    uint256 CaseNumber;
    address Owner;
    address payable Contractor;
    address payable FM;
    string BuildingId;
    bytes32[] TsetIDs;
    bytes32[] TIDs;
    bytes32[] RHuIDs;
    bytes32[] AQuIDs;
    uint256 time;
    uint256 Erate;
  }

  mapping(uint256 => CaseItem) public cases;

  address public useraddress;
  mapping(address => bool) Users;



//measured value of different buildings are here
  struct TempVals {
    uint256 measurmentnumber;
    bytes32 devids;
    uint256[] measures;
    string buid;
  }

  mapping(uint256 => TempVals) public values;

  struct EVals {
    uint256 measurmentnumber;
    uint256 measures;
    string buid;
    uint256 time;
  }

  mapping(uint256 => EVals) public Evalues;

  // the faults of the facility manager
  struct FMFs {
    uint256 FMFnumber;
    bytes32 devid;
    uint256 time;
    string buid;
  }
  mapping(uint256 => FMFs) public FMF;



  //the faults of the contractor
  struct COFs {
    uint256 COFnumber;
    bytes32 devid;
    uint256 time;
    string buid;
    }
  mapping(uint256 => COFs) public COF;

  //no ones fault
  struct Allfines {
    uint256 Allfinenumber;
    bytes32 devid;
    uint256 time;
    string buid;
  }
  mapping(uint256 => Allfines) public Allfine;

  struct TxEx {
    uint256 Txnumber;
    string buid;
    address from;
    address toCo;
    uint256 amCO;
    address toFM;
    uint256 amFM;
    uint256 time;
  }
  mapping(uint256 => TxEx) public Txs;

  

  modifier onlyOwner() {
        require((msg.sender == contractOwner || contractOwner == msg.sender), "caller is not the contract owner");
            _;
    }

  constructor()  public{
        contractOwner = msg.sender;
        //emit contractownerdefined(msg.sender);
    }

  //contract owner adds building owner as a user
  function boAdd(address boAddress) public onlyOwner {
        require((boAddress != address(0) && !Users[boAddress]), "The Building owner address is not correct or is already in the list");
        Users[boAddress] = true;
    }

  function isWhitelisted(address passAddress) public view returns (bool) {
        return Users[passAddress];
    }

  //adding a building and its information to the list to get checked
  function addCase(address account1, address payable account2, address payable account3, 
                  string memory BI, bytes32[] memory TsetIDs, bytes32[] memory TIDs, 
                  bytes32[] memory RHuIDs, bytes32[] memory AQuIDs, uint256 depoam, uint256 Erate) public {
    require (isWhitelisted(account1),"building owner is not a user");
    require (depoam == 11,"not enoug depo");
    caseCount ++;
    uint256 time = block.timestamp;
    cases[caseCount] = CaseItem(caseCount, account1, account2, account3, BI, TsetIDs, TIDs, RHuIDs, AQuIDs, time, Erate);
    emit CaseCreated(caseCount, account1, account2, account3, BI, TsetIDs, TIDs, RHuIDs, AQuIDs, time);
  }

  //adding depo into contract account to be transfered later to the contractor and facility manager
  function addDepo() public payable {
    require (msg.value == 11 ether,"not enoug depo");
    //ContractAdd.transfer(msg.value);
    //Receive(msg.value);
  }

  //adding depo to contract owner account for gas fee of the sensor measurements
  // function addDepo2() public payable {
  //   require (msg.value == 20 ether,"not enoug depo");
  //   contractOwner.transfer(20 ether);
  // }

  function getarray(uint256 _select) public view returns (bytes32[] memory devids) {
    return cases[_select].TsetIDs;
  }

  function chekRHuid (uint256 _select, bytes32 _id) public view returns (bool  a) {
    a = false;
    for (uint256 i = 0; i<(cases[_select].RHuIDs.length); i++){
      if (cases[_select].RHuIDs[i] == _id)
      {
        a = true;
      }
    }
    return a;
  }
  function chekTid (uint256 _select, bytes32 _id) public view returns (bool  a) {
    a = false;
    for (uint256 i = 0; i<(cases[_select].TIDs.length); i++){
      if (cases[_select].TIDs[i] == _id)
      {
        a = true;
      }
    }
    return a;
  }
  function chekAQuid (uint256 _select, bytes32 _id) public view returns (bool  a) {
    a = false;
    for (uint256 i = 0; i<(cases[_select].AQuIDs.length); i++){
      if (cases[_select].AQuIDs[i] == _id)
      {
        a = true;
      }
    }
    return a;
  }

// adding measurement of sesnors and comparing them to the accepted range
 function addValue (bytes32 devid, uint256[] memory measures, string memory buid ) public {
    measurmentCount ++;
    values[measurmentCount] = TempVals (measurmentCount, devid, measures, buid);
    uint256 time = block.timestamp;

    //here we check diffrent measures
      if ( measures[0]>220)
      {
        if(measures[1]>=200)
        {
          FMFCount ++;
          FMF[FMFCount] = FMFs(FMFCount, devid, time, buid);
        }
        else if(measures[1]<200 && measures[1]!=0)
        {
          COFCount ++;
          COF[COFCount] = COFs(COFCount, devid, time, buid);
        }
        else{
          AllfineCount ++;
          Allfine[AllfineCount] = Allfines(AllfineCount, devid, time, buid);
        }
      }
      else if ( measures[0]<200 && measures[0]!=0)
      {
        if(((measures[1]>=180) || measures[1] == 10000 || measures[1] == 0 ) && ((measures[2]>=200 && measures[2]<=600) || measures[2]==10000 || measures[2]==0 ) && (measures[3] <= 1000 || measures[3] == 10000 || measures[3] == 0))
        {
          AllfineCount ++;
          Allfine[AllfineCount] = Allfines(AllfineCount, devid, time, buid);
        }
        else
        {
          FMFCount ++;
          FMF[FMFCount] = FMFs(FMFCount, devid, time, buid);
        }
       
      }
      else if ( measures[0]<=220 && measures[0]>=200)
      {
        if ((measures[1]<180))
        {
          COFCount ++;
          COF[FMFCount] = COFs(COFCount, devid, time, buid);
        }
        else if(((measures[1]>=180) || measures[1] == 10000 || measures[1] == 0 ) && ((measures[2] >= 200 && measures[2]<= 600) || measures[2] == 10000 || measures[2] == 0 ) && (measures[3]<= 1000 || measures[3] == 10000 || measures[3] == 0))
        {
          AllfineCount ++;
          Allfine[AllfineCount] = Allfines(AllfineCount, devid, time, buid);
        }
        else
        {
          FMFCount ++;
          FMF[FMFCount] = FMFs(FMFCount, devid, time, buid);
        }
      }
      else{
        AllfineCount ++;
        Allfine[AllfineCount] = Allfines(AllfineCount, devid, time, buid);
      }
  }
  function addEValue ( uint256 measures, string memory buid ) public {
    EmeasurmentCount ++;
    uint256 time = block.timestamp;
    Evalues[measurmentCount] = EVals (EmeasurmentCount, measures, buid, time);
  }
  function statusQuoFM (string memory _buid, uint256 checkstart, uint256 checkend) public {
    FMFaults = 0;
    for (uint256 i = 1; i<(FMFCount+1); i++)
    {
      if (keccak256(abi.encodePacked((FMF[i].buid))) == keccak256(abi.encodePacked((_buid))) &&
      FMF[i].time <= checkend && FMF[i].time >= checkstart)
      {
        FMFaults ++;
      }
    }
  }
   function statusQuoCO (string memory _buid, uint256 checkstart, uint256 checkend) public {
    COFaults = 0;

    for (uint256 i = 1; i<(COFCount+1); i++)
    {
      if (keccak256(abi.encodePacked((COF[i].buid))) == keccak256(abi.encodePacked((_buid))) &&
      COF[i].time <= checkend && COF[i].time >= checkstart)
      {
        COFaults ++;
      }
    }
  }
   function statusQuoAll (string memory _buid, uint256 checkstart, uint256 checkend) public {
    NoFault = 0;
    for (uint256 i = 1; i<(AllfineCount+1); i++)
    {
      if (keccak256(abi.encodePacked((Allfine[i].buid))) == keccak256(abi.encodePacked((_buid))) &&
      Allfine[i].time <= checkend && Allfine[i].time >= checkstart)
      {
        NoFault ++;
      }
    }
  }



  function makeTx (string memory _buid, address payable COreceiver, address payable FMreceiver) public {
    require (isWhitelisted(msg.sender),"msg sender is not a user");
    b = false;
    uint256 Cid = 0;
    uint256 Erate = 0;
    for (uint256 i=1; i<(caseCount+1); i++)
    {
      if ( keccak256(abi.encodePacked(( cases[uint256(i)].BuildingId))) == keccak256(abi.encodePacked((_buid))) &&
      cases[uint256(i)].Contractor == COreceiver && cases[uint256(i)].FM == FMreceiver)
      {
        Cid = i;
        _toCo = cases[uint256(i)].Contractor;
        _toFM = cases[uint256(i)].FM;
        Erate = cases[uint256(i)].Erate;
        xtime = cases[uint256(i)].time;
        stime = xtime;
        b = true;
        state = 1;
      }
    }
    require (b == true, "Wrong building Id");
    state = 2;
    uint256 time = block.timestamp;

    
    state = 3;
    for (uint256 i = 1; i<(TxCount+1); i++)
    {
      if ( keccak256(abi.encodePacked(( Txs[uint256(i)].buid))) == keccak256(abi.encodePacked((_buid))) && Txs[uint256(i)].time > xtime)
      {
        xtime = Txs[uint256(i)].time;

      }

    }
    require ((time-xtime)>=432000, "You should wait at least four minute after your previous transaction");
    uint256 totdiff1 = 0;
    uint256 Esum = 0;
    uint256 EsumCount = 0;
    uint256 totdiff2 = 0;
    uint256 totdiff3 = 0;
    uint256 maxamount = 0;
    //uint256 maxamount = (80*(duedate-xtime)/63072000)*1000000000000000000;
    uint256 sixmonthamount = (5)*1000000000000000000;
    if ((time - stime) <= 6*432000){
      state = 4;
      if ((time-xtime) >= 432000 && (time-xtime) < 2*432000)
      {
      maxamount = sixmonthamount * 1;
      time = xtime + 432000;
      }
      else if ((time-xtime) >= 2*432000 && (time-xtime) < 3*432000 )
      {
      maxamount = sixmonthamount * 2;
      time = xtime + 2*432000;
      }
      else if ((time-xtime) >= 3*432000 && (time-xtime) < 4*432000 )
      {
      maxamount = sixmonthamount * 3;
      time = xtime + 3*432000;
      }
      else if ((time-xtime) >= 4*432000 && (time-xtime) < 5*432000 )
      {
      maxamount = sixmonthamount * 4;
      time = xtime + 4*432000;
      }
      else if ((time-xtime) >= 5*432000 && (time-xtime) < 6*432000)
      {
      maxamount = sixmonthamount * 5;
      time = xtime + 5*432000;
      }
      else {
      maxamount = 0;
      state = 5;
      }
    }
    else  {
      state = 6;
      if (xtime == stime){
        maxamount = sixmonthamount * 6;
      }
      else if ((xtime-stime) == 432000){
        maxamount = sixmonthamount * 5;
      }
      else if ((xtime-stime) == 2*432000){
        maxamount = sixmonthamount * 4;
      }
      else if ((xtime-stime) == 3*432000){
        maxamount = sixmonthamount * 3;
      }
      else if ((xtime-stime) == 4*432000){
        maxamount = sixmonthamount * 2;
      }
      else if ((xtime-stime) == 5*432000){
        maxamount = sixmonthamount * 1;
      }
      else{
        maxamount = 0;
        state = 7;
      }

      time = stime+6*432000;
      //cases.remove(Cid);
      for (uint256 i = Cid; i<(caseCount); i++)
      {
        cases[i+1].CaseNumber = i;
        cases[i] = cases[i+1];
      }
      caseCount = caseCount-1;
    }
    for (uint256 i = 1; i<(EmeasurmentCount+1); i++)
    {
      // if ( FMF[uint256(i)].caseid == caseNo && FMF[uint256(i)].time > (xtime-1) && FMF[uint256(i)].time < (time+1))
      if ( keccak256(abi.encodePacked(( Evalues[uint256(i)].buid))) == keccak256(abi.encodePacked((_buid))) && Evalues[uint256(i)].time < time &&
      Evalues[uint256(i)].time >= xtime )
      {
        EsumCount ++;
        Esum += Evalues[uint256(i)].measures;
      }
    }
    for (uint256 i = 1; i<(COFCount+1); i++)
    {
      // if ( FMF[uint256(i)].caseid == caseNo && FMF[uint256(i)].time > (xtime-1) && FMF[uint256(i)].time < (time+1))
      if ( keccak256(abi.encodePacked(( COF[uint256(i)].buid))) == keccak256(abi.encodePacked((_buid))) && COF[uint256(i)].time < time &&
      COF[uint256(i)].time >= xtime )
      {
        totdiff1 ++;
      }
    }

    for (uint256 i = 1; i<(FMFCount+1); i++)
    {
      // if ( FMF[uint256(i)].caseid == caseNo && FMF[uint256(i)].time > (xtime-1) && FMF[uint256(i)].time < (time+1))
      if ( keccak256(abi.encodePacked(( FMF[uint256(i)].buid))) == keccak256(abi.encodePacked((_buid))) &&
      FMF[uint256(i)].time < time && FMF[uint256(i)].time >= xtime )
      {
        totdiff2 ++;
      }
    }
    for (uint256 i = 1; i<(AllfineCount+1); i++)
    {
      // if ( FMF[uint256(i)].caseid == caseNo && FMF[uint256(i)].time > (xtime-1) && FMF[uint256(i)].time < (time+1))
      if ( keccak256(abi.encodePacked(( Allfine[uint256(i)].buid))) == keccak256(abi.encodePacked((_buid))) &&
      Allfine[uint256(i)].time < time && Allfine[uint256(i)].time >= xtime )
      {
        totdiff3 ++;
      }
    }


    if (EsumCount>0){
      if ((Esum*100/(EsumCount*Erate))>150){
       if (((totdiff1+totdiff2+totdiff3)/3)<totdiff2 ){
        totdiff1 += 0;
      }
      else if (((totdiff1+totdiff2+totdiff3)/3)>totdiff2 && ((totdiff1+totdiff2+totdiff3)/5)<totdiff2 ){
        totdiff1 += 200;
      }
      else if (((totdiff1+totdiff2+totdiff3)/5)>=totdiff2 && ((totdiff1+totdiff2+totdiff3)/7)<totdiff2 ){
        totdiff1 += 350;
      }
      else {
        totdiff1 += 500;
      }
    }

    else if ((Esum*100/(EsumCount*Erate))<=150 && (Esum*100/(EsumCount*Erate))>110){
      if (((totdiff1+totdiff2+totdiff3)/3)<totdiff2 ){
        totdiff1 += 0;
      }
      else if (((totdiff1+totdiff2+totdiff3)/3)>totdiff2 && ((totdiff1+totdiff2+totdiff3)/5)<totdiff2 ){
        totdiff1 += 100;
      }
      else if (((totdiff1+totdiff2+totdiff3)/5)>=totdiff2 && ((totdiff1+totdiff2+totdiff3)/7)<totdiff2 ){
        totdiff1 += 200;
      }
      else if ((maxamount/sixmonthamount*50)>=totdiff2){
        totdiff1 += 300;

      }
        
      
    }
    else 
    totdiff1 += 0;
    }
 


    amountCO = maxamount-(totdiff1*1000000000000000000/100);
    amountFM = maxamount-(totdiff2*1000000000000000000/100);
    //amount = 2*1000000000000000000;


    TxCount ++;
    Txs[TxCount] = TxEx (TxCount, _buid, contractOwner, _toCo, amountCO, _toFM, amountFM, time);

    _toCo.transfer(amountCO);
    _toFM.transfer(amountFM);
    //emit CaseCreated(caseCount, account1, account2, BI, DeIDs);

  }
 }
