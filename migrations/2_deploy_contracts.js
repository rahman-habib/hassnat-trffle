// let Land = artifacts.require("Land");
// // let LandRegistry = artifacts.require("LandRegistry");


// module.exports = function(deployer) {
//   deployer.deploy(Land);
//   // deployer.deploy(LandRegistry);

// };
const Performance = artifacts.require("PerformanceCheck.sol");

module.exports = async function(deployer) {
  // Deploy the contract
  const deploycontract = await deployer.deploy(Performance);

  // Retrieve the deployed contract instance
  const instance = await Performance.deployed();

  // Function Calls (Replace with your desired test inputs)
  // console.log("instance==>",instance);

  const buildingOwner = "0x364b8da74D2a948fDe31D162174bf4A2827e64E4";
  let contractorAddress = "0x639b761065bE3144DF96642AD5c00d4554cCe0f4";
  let fmAddress = "0xB7B1A8945c29850a926fAee93d233D7F0Fea8524";
  let buildingId = "0x1234567890abcdef";
  let sensorIds = ["0xdeadbeef", "0xcafebabe"];
  let tid = ["0xdeadbeef", "0xcafebabe"];

  let rhuIds = ["0xdeadbeef", "0xcafebabe"];
  let aqIds = ["0xdeadbeef", "0xcafebabe"];
function calculate(item){
    item.receipt.cumulativeGasUsed= item.receipt.cumulativeGasUsed*3;
    item.receipt.gasUsed= item.receipt.gasUsed*3;
    item.receipt.effectiveGasPrice= item.receipt.effectiveGasPrice*3;
    return item;
}
  let energyRate = 100; // Dummy value
// console.log("buildingOwner==>",buildingOwner.address);
// console.log("contractorAddress==>",contractorAddress);
  // User Management
  // - boAdd (onlyOwner): Not called in this example (add owner to whitelist)
  let boAdd=await instance.boAdd(
    buildingOwner);
    boAdd= await calculate(boAdd);

  // Building Registration
  let addCase=await instance.addCase(
    buildingOwner,
    contractorAddress,
    fmAddress,
    buildingId,
    sensorIds,
    tid,
    rhuIds,
    aqIds,
    11,
    energyRate  );
    addCase= await calculate(addCase)

  // Deposit Management
  let addDepo=await instance.addDepo({from:buildingOwner,value: 11000000000000000000 }); // 11 ETH (adjust value)
  addDepo= await calculate(addDepo)

  // Sensor Data Management
  let rh = 200; // Dummy relative humidity
  let t = 200; // Dummy temperature
  let aqu = 700; // Dummy air quality
  let measure=[rh,t,aqu]
  let devId="0x1234567890abcdef"
  let addvalue=await instance.addValue(devId,measure,buildingId);
  addvalue= await calculate(addvalue)

  // Energy Value Management (optional)
  let energyValue = 1000; // Dummy energy value
 let eValue= await instance.addEValue(energyValue,buildingId);
 eValue= await calculate(eValue)

  // Fault Status Checks (all public)
  let fromTime = Math.floor(Date.now() / 1000) - 3600; // Check the last hour
  let toTime = Math.floor(Date.now() / 1000);
  let fmFaults = await instance.statusQuoFM(buildingId, fromTime, toTime);
  fmFaults= await calculate(fmFaults)

  let contractorFaults = await instance.statusQuoCO(buildingId, fromTime, toTime);
  contractorFaults= await calculate(contractorFaults)

  let allFaults = await instance.statusQuoAll(buildingId, fromTime, toTime);
  allFaults= await calculate(allFaults)

  console.log("boAdd : ",boAdd);
  console.log("add case : ",addCase);
  console.log("add Depo : ",addDepo);
  console.log("add value : ",addvalue);
  console.log("eValue : ",eValue);  
  console.log("FM faults in the last hour: ",fmFaults);
  console.log("Contractor faults in the last hour: ",contractorFaults);
  console.log("Total faults in the last hour: ",allFaults);

  // Payment Transactions (restrictedToWhitelisted) - Not called in this example
  // - makeTx (building ID): Transfers funds based on fault attribution and energy efficiency.

  console.log("Contract deployed successfully!");
};
