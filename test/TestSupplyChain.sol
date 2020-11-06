pragma solidity ^0.6.12;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SupplyChain.sol";

contract TestSupplyChain {

    // Test for failing conditions in this contracts:
    // https://truffleframework.com/tutorials/testing-for-throws-in-solidity-tests
    SupplyChain scinstance = SupplyChain(DeployedAddresses.SupplyChain());
    address supplyChain = DeployedAddresses.SupplyChain();
    
    
    // buyItem
    // test for failure if user does not send enough funds
    function testForFailBuy() public{
        // scinstance.addItem("foo", 200);
        // scinstance.addItem("bar", 200);
        supplyChain.call(abi.encodeWithSignature("addItem(string,uint256)", "foo",100));
 
        (bool r,) = supplyChain.call{value: 1 ether}(abi.encodeWithSignature("buyItem(uint256)", 0)); 
        
        Assert.isFalse(r, "Should be false because is should throw!");

    }
    // test for purchasing an item that is not for Sale
    function testForFailNotSale() public{

        (bool r, ) = supplyChain.call{value: 300}(abi.encodeWithSignature("buyItem(uint256)", 0)); 

        Assert.isFalse(r, "Should be false because is should throw!");

    }
    // shipItem

    // test for calls that are made by not the seller
    function testForFailNotSeller() public{
        ThrowProxy throwproxy = new ThrowProxy(supplyChain); 
        
        SupplyChain(address(throwproxy)).shipItem(0);

        (bool r, ) = throwproxy.execute(); 
        // (bool r, bytes memory returnData) = supplyChain.call{value: 100}(abi.encodeWithSignature("shipItem(uint256)", 0)); 

        Assert.isFalse(r, "Should be false because is should throw!");

    }
    // test for trying to ship an item that is not marked Sold
    function testForFailNotSMarkedSold() public{
        
        (bool r, bytes memory returnData) = supplyChain.call(abi.encodeWithSignature("shipItem(uint256)", 0)); 

        Assert.isFalse(r, "Should be false because is should throw!");

    }

    // receiveItem

    // test calling the function from an address that is not the buyer
    function testForFailNotBuyer() public{
        ThrowProxy throwproxy = new ThrowProxy(supplyChain); 
        
        SupplyChain(address(throwproxy)).receiveItem(0);

        (bool r, ) = throwproxy.execute(); 

        Assert.isFalse(r, "Should be false because is should throw!");

    }
    // test calling the function on an item not marked Shipped
    function testForFailNotSMarkedShipped() public{
        
        (bool r, bytes memory returnData) = supplyChain.call(abi.encodeWithSignature("receiveItem(uint256)", 0)); 

        Assert.isFalse(r, "Should be false because is should throw!");

    }

    receive() external payable{

    }

}

// Proxy contract for testing throws
contract ThrowProxy {
  address public target;
  bytes data;

  constructor(address _target) public{
    target = _target;
  }

  //prime the data using the fallback function.
  fallback() external{
    data = msg.data;
  }

  function execute() public returns (bool, bytes memory){
    return target.call(data);
  }
}
