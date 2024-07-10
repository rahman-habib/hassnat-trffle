module.exports= function calculate(item){
    item.receipt.cumulativeGasUsed= item.receipt.cumulativeGasUsed*3;
    item.receipt.gasUsed= item.receipt.gasUsed*3;
    item.receipt.effectiveGasPrice= item.receipt.effectiveGasPrice*3;
    return item;
}
