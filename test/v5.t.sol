// SPDX-License-Identifier: UNLICENSED
pragma solidity ^ 0.8 .13;

import "forge-std/Test.sol";
import "../src/HazardsCookiesV5.sol";
import "forge-std/Vm.sol";
import "lib/openzeppelin-contracts/contracts/utils/Strings.sol";

contract V5 is Test {
    HazardsCookiesV5 public cookies;
    address payable bob = payable(address(0x1234));
    address payable alice = payable(address(0x5678));
    uint public constant DEAL_AMOUNT = 5 ether;
    uint public constant SMOL_BUY_AMOUNT = 1 ether;
    uint public constant LARGE_BUY_AMOUNT = 2 ether;

    /// @notice setups Game contract for testing
    /// @dev bob is the address of the player buying the cookies
    /// @dev DEAL_AMOUNT is 5 ether
    function setUp()public {
        cookies = new HazardsCookiesV5();
        vm.deal(bob, DEAL_AMOUNT);
        vm.deal(alice, DEAL_AMOUNT);
    }

    /// @notice Tests the buyCookieOfWealth function
    /// @dev Cookie of Wealth is NFT #5 and should be owned by bob
    function testBuyCookieOfWealth()public { // Bob buys Cookie of Wealth
        vm.startPrank(address(bob));
        cookies.buyCookieOfWealth {
            value : SMOL_BUY_AMOUNT
        }();
        emit log_string("NFT Owners: ");
        vm.stopPrank();

        // Bob should own Cookie of Wealth
        assertEq(cookies.lookupOwner(5), bob);

        // Log NFT owners after bob buys Cookie of Wealth
        for (uint256 i = 1; i <= 5; i ++) {
            address owner = cookies.lookupOwner(i);
            emit log_named_address(Strings.toString(i), owner);
        }
    }

    /// @notice Tests the buyCookieOfWealth function with alice buying from bob
    function testBuyCookieOfWealthFromPass()public { 
        /// @notice Tests the passcase of alice buying from bob
        /// @dev Cookie of Wealth is NFT #5 and should be owned by alice
        /// @dev Bob should have his ether returned back in this pass case   

        // Bob buys Cookie of Wealth to setup test    
        vm.startPrank(address(bob));
        cookies.buyCookieOfWealth {
            value : SMOL_BUY_AMOUNT
        }();
        emit log_named_uint("Contract Before: ", address(this).balance);
        emit log_string("NFT Owners: ");
        vm.stopPrank();

        // Bob should own Cookie of Wealth
        assertEq(cookies.lookupOwner(5), bob);

        // Log NFT owners after bob buys Cookie of Wealth
        for (uint256 i = 1; i <= 5; i ++) {
            address owner = cookies.lookupOwner(i);
            emit log_named_address(Strings.toString(i), owner);
        }

        // Alice buys Cookie of Wealth from Bob
        vm.startPrank(address(alice));
        cookies.buyCookieOfWealth {
            value : LARGE_BUY_AMOUNT
        }();
        emit log_string("NFT Owners: ");
        vm.stopPrank();

        // Alice should own Cookie of Wealth
        assertEq(cookies.lookupOwner(5), alice);

        // Log NFT owners after alice buys Cookie of Wealth
        for (uint256 i = 1; i <= 5; i ++) {
            address owner = cookies.lookupOwner(i);
            emit log_named_address(Strings.toString(i), owner);
        }

        // log contracts balance
        emit log_named_uint("Contract Balance After: ", address(this).balance);

        // log bob's balance
        emit log_named_uint("Bob's Balance: ", bob.balance);

        // Bob should have his ether returned back
        assertEq(bob.balance, DEAL_AMOUNT);


        /// @notice Tests the failcase of alice buying from bob
        /// @dev Cookie of Wealth is NFT #5 and should be owned by bob
        /// @dev Bob tries to buys Cookie of Wealth, fails, and should not own Cookie of Wealth
        /// @dev Alice should not have her ether returned back
        /// @dev Alice should own Cookie of Wealth
        assertEq(cookies.lookupOwner(5), alice);

        // Bob tries to buy Cookie of Wealth from Bob
        // Anticipated revert because bob does not have enough ether
        vm.startPrank(address(bob));
        vm.expectRevert("Not enough funds");
        cookies.buyCookieOfWealth {
            value : SMOL_BUY_AMOUNT
        }();
        vm.stopPrank();

        // Alice should still own Cookie of Wealth
        assertEq(cookies.lookupOwner(5), alice);

        // Log NFT owners after Bob tries to buy Cookie of Wealth
        emit log_string("NFT Owners: ");
        for (uint256 i = 1; i <= 5; i ++) {
            address owner = cookies.lookupOwner(i);
            emit log_named_address(Strings.toString(i), owner);
        }

        // Alice should not have her ether returned back
        assertEq(alice.balance, DEAL_AMOUNT - LARGE_BUY_AMOUNT);
    }

    /// @notice Tests the takeCookieOfWar function
    function testTakeCookieOfWar()public { 
        /// @notice Tests the pass case of the takeCookieOfWar function
        /// @dev Cookie of War is NFT #4 and should be owned by after takeCookieOfWar is called
        /// @dev Starts prank on bob and rolls the vm to an even block number
        vm.startPrank(address(bob));
        vm.roll(69420);
        emit log_named_uint("Block Number: ", block.number);

        // Bob buys Cookie of War on even block number
        cookies.takeCookieOfWar();
        vm.stopPrank();

        // Bob should own Cookie of War
        assertEq(cookies.lookupOwner(4), bob);

        // Log NFT owners after Bob takes Cookie of War
        emit log_string("NFT Owners: ");
        for (uint256 i = 1; i <= 5; i ++) {
            address owner = cookies.lookupOwner(i);
            emit log_named_address(Strings.toString(i), owner);
        }

        /// @notice Tests the fail case of the takeCookieOfWar function
        /// @dev Cookie of War is NFT #4 and should be owned by the bob deployer after Alice calls it
        /// @dev Starts prank on Alice and rolls the vm to an odd block number
        vm.startPrank(address(alice));
        vm.roll(69421);
        emit log_named_uint("Block Number: ", block.number);

        // Alice tries to buy Cookie of War on odd block number
        // Anticipated revert because the block number is odd
        vm.expectRevert("Not an even block");
        cookies.takeCookieOfWar();
        vm.stopPrank();

        // Bob should still own the Cookie of War
        assertEq(cookies.lookupOwner(4), address(bob));

        // Log NFT owners after Alice tries to take Cookie of War
        emit log_string("NFT Owners: ");
        for (uint256 i = 1; i <= 5; i ++) {
            address owner = cookies.lookupOwner(i);
            emit log_named_address(Strings.toString(i), owner);
        }
    }

    /// @notice Tests the takeCookieOfTime function
    function testTakeCookieOfTime()public {
        /// @notice Tests the passing case
        /// @dev Starts prank on bob and rolls the vm to a block timestamp 1 week greater
        /// @dev Logs the block timestamp before and after the warp
        /// @dev Cookie of Time is NFT #3 and should be owned by bob after it is called
        vm.startPrank(address(bob));
        emit log_named_uint("Block Timestamp: ", block.timestamp);
        vm.warp(block.timestamp + 604800);
        emit log_named_uint("After Roll Block Timestamp: ", block.timestamp);

        // Bob buys Cookie of Time on a block timestamp 1 week greater
        cookies.takeCookieOfTime();
        vm.stopPrank();

        // Bob should own Cookie of Time
        assertEq(cookies.lookupOwner(3), bob);

        // Log NFT owners after Bob takes Cookie of Time
        emit log_string("NFT Owners: ");
        for (uint256 i = 1; i <= 5; i ++) {
            address owner = cookies.lookupOwner(i);
            emit log_named_address(Strings.toString(i), owner);
        }

        /// @notice Tests the failing case of takeCookieOfTime
        /// @dev Starts prank on alice and rolls the vm to a block timestamp slightly less then 1 week
        /// @dev Logs the block timestamp before and after the warp
        vm.startPrank(address(alice));
        emit log_named_uint("Block Timestamp: ", block.timestamp);
        vm.warp(block.timestamp + 604798);
        emit log_named_uint("After Roll Block Timestamp: ", block.timestamp);

        // Alice tries to buy Cookie of Time on a block timestamp slightly less than 1 week
        // Anticipated revert because the block timestamp is less than 1 week
        vm.expectRevert("Not a week");
        cookies.takeCookieOfTime();
        vm.stopPrank();

        // Bob should still own Cookie of Time
        assertEq(cookies.lookupOwner(3), address(bob));

        // Log NFT owners after Bob tries to take Cookie of Time
        emit log_string("NFT Owners: ");
        for (uint256 i = 1; i <= 5; i ++) {
            address owner = cookies.lookupOwner(i);
            emit log_named_address(Strings.toString(i), owner);
        }
    }


    /// @notice Tests the takeCookieOfWisdom function
    function testTakeCookieOfWisdom()public { // Starts prank on bob and logs the hashed input number and the hashed previous number
        /// @notice Tests the passing case of takeCookieOfWisdom
        /// @dev Cookie of Wisdom is NFT #2 and should be owned by bob after it is called
        /// @dev assumes that the hashed input number is greater than the hashed previous number
        vm.startPrank(address(bob));
        uint testNumber1 = 1;
        emit log_named_uint("Test Number: ", uint256(keccak256(abi.encodePacked(testNumber1))));
        emit log_named_uint("Last Number: ", uint256(keccak256(abi.encodePacked(cookies.lastNumber))));

        // Bob buys Cookie of Wisdom on a hashed input number greater than the hashed previous number
        cookies.takeCookieOfWisdom(testNumber1);
        vm.stopPrank();

        // Bob should own Cookie of Wisdom
        assertEq(cookies.lookupOwner(2), bob);

        // Log NFT owners after Bob takes Cookie of Wisdom
        emit log_string("NFT Owners: ");
        for (uint256 i = 1; i <= 5; i ++) {
            address owner = cookies.lookupOwner(i);
            emit log_named_address(Strings.toString(i), owner);
        }

        /// @notice Tests the failing case of takeCookieOfWisdom
        /// @dev Cookie of Wisdom is NFT #2 and should be owned by bob after it is called
        /// @dev assumes that the hashed input number is less than the hashed previous number 
        /// @dev when alice tries to claim it
        vm.startPrank(address(alice));
        uint testNumber2 = 0;
        emit log_named_uint("Test Number: ", uint256(keccak256(abi.encodePacked(testNumber2))));
        emit log_named_uint("Last Number: ", uint256(keccak256(abi.encodePacked(cookies.lastNumber))));

        // Alice tries to buy Cookie of Wisdom on a hashed input number less than the hashed previous number
        // Anticipated revert because the hashed input number is less than the hashed previous number
        vm.expectRevert("Not greater than previous");
        cookies.takeCookieOfWisdom(testNumber2);
        vm.stopPrank();

        // Bob should still own the Cookie of Wisdom
        assertEq(cookies.lookupOwner(2), address(bob));

        // Log NFT owners after Alice tries to take Cookie of Wisdom
        emit log_string("NFT Owners: ");
        for (uint256 i = 1; i <= 5; i ++) {
            address owner = cookies.lookupOwner(i);
            emit log_named_address(Strings.toString(i), owner);
        }
    }


    /// @notice Tests the takeCookieOfPower function
    function testTakeCookieOfPower()public {
        /// @notice Tests the pass case of the takeCookieOfPower function
        /// @dev Cookie of Power is NFT #1 and should be owned by bob after it is called
        /// @dev assumes that the block number ends in 420
        /// @dev Starts prank on bob and rolls the vm to a block number ending in 420
        /// @dev Logs the block number after the warp
        vm.startPrank(address(bob));
        vm.roll(69420);
        emit log_named_uint("Block Number: ", block.number);

        // Bob buys Cookie of Power on a block number ending in 420
        cookies.takeCookieOfPower();
        vm.stopPrank();

        // Bob should own Cookie of Power
        assertEq(cookies.lookupOwner(1), bob);

        // Log NFT owners after Bob takes Cookie of Power
        emit log_string("NFT Owners: ");
        for (uint256 i = 1; i <= 5; i ++) {
            address owner = cookies.lookupOwner(i);
            emit log_named_address(Strings.toString(i), owner);
        }

        /// @notice Tests the fail case of the takeCookieOfPower function
        /// @dev Cookie of Power is NFT #1 and should be owned by bob after it is called
        /// @dev assumes that the block number does not end in 420 when alice tries to buy it
        vm.startPrank(address(alice));
        vm.roll(69421);
        emit log_named_uint("Block Number: ", block.number);

        // Alice tries to buy Cookie of Power on a block number not ending in 420
        // Anticipated revert because the block number does not end in 420
        vm.expectRevert("Not a 420 block");
        cookies.takeCookieOfPower();
        vm.stopPrank();

        // Bob should still own Cookie of Power
        assertEq(cookies.lookupOwner(1), address(bob));

        // Log NFT owners after Alice tries to take Cookie of Power
        emit log_string("NFT Owners: ");
        for (uint256 i = 1; i <= 5; i ++) {
            address owner = cookies.lookupOwner(i);
            emit log_named_address(Strings.toString(i), owner);
        }
    }

    /// @notice Tests the takeCookieOfH4X0R function
    /// @dev Tests both the pass and fail cases
    /// @dev assumes that the block number is 69420
    function testTakeCookieOfH4X0R()public {
        /// @notice Tests the Passing Case
        // Starts prank on bob and rolls the vm to a block number of 69420
        // Logs the block number after the warp
        vm.startPrank(address(bob));
        vm.roll(69420);
        emit log_named_uint("Block Number: ", block.number);
        cookies.takeCookieOfPower();
        vm.roll(69421);
        cookies.takeCookieOfH4X0R();
        vm.stopPrank();

        // Bob should own Cookie of H4X0R
        assertEq(cookies.lookupOwner(1337), bob);

        // Log NFT owners after Bob takes Cookie of H4X0R
        emit log_string("NFT Owners: ");
        for (uint256 i = 1; i <= 6; i ++) {
            if (i == 6) {
                address owner = cookies.lookupOwner(1337);
                emit log_named_address(Strings.toString(1337), owner);
            } else {
                address owner = cookies.lookupOwner(i);
                emit log_named_address(Strings.toString(i), owner);
            }
        }
  
        /// @notice Starts prank on alice to test failing case
        // Logs the block number after the warp
        vm.startPrank(address(alice));
        emit log_named_uint("Block Number: ", block.number);

        // Alice tries to buy Cookie of H4X0R
        // Anticipated revert because Bob does not own any of the other cookies
        vm.expectRevert("Must own one of the other cookies");
        cookies.takeCookieOfH4X0R();

        // Bob should own Cookie of H4X0R
        assertEq(cookies.lookupOwner(1337), address(bob));
        vm.stopPrank();

        // Log NFT owners after Alice tries to take Cookie of H4X0R
        emit log_string("NFT Owners: ");
        for (uint256 i = 1; i <= 6; i ++) {
            if (i == 6) {
                emit log_named_address(Strings.toString(1337), address(bob));
            } else {
                address owner = cookies.lookupOwner(i);
                emit log_named_address(Strings.toString(i), owner);
            }
        }
    }
}
