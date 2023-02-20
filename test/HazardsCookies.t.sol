// SPDX-License-Identifier: UNLICENSED
pragma solidity ^ 0.8 .13;

import "forge-std/Test.sol";
import "../src/HazardsCookies.sol";
import "forge-std/Vm.sol";
import "lib/openzeppelin-contracts/contracts/utils/Strings.sol";

contract CookiesTest is Test {
    HazardsCookiesV4 public cookies;
    address payable bob = payable(address(0x1234));
    address payable alice = payable(address(0x5678));
    uint public constant DEAL_AMOUNT = 5 ether;
    uint public constant SMOL_BUY_AMOUNT = 1 ether;
    uint public constant LARGE_BUY_AMOUNT = 2 ether;

    /// @notice setups Game contract for testing
    /// @dev bob is the address of the player buying the cookies
    /// @dev DEAL_AMOUNT is 5 ether
    function setUp()public {
        cookies = new HazardsCookiesV4();
        vm.deal(bob, DEAL_AMOUNT);
        vm.deal(alice, DEAL_AMOUNT);
    }

    /// @notice tests the getCookieURIsAndOwners function
    function testGetCookieURIsAndOwners()public {
        string[] memory uris;
        address[] memory owners;
        (uris, owners) = cookies.getCookieURIsAndOwners();
        for (uint256 i = 0; i < 5; i ++) {
            emit log_named_string(Strings.toString(i), uris[i]);
            emit log_named_address(Strings.toString(i), owners[i]);
        }
    }

    /// @notice test the getCookieURIs function
    function testGetCookieURIs()public {
        string[] memory uris;
        uris = cookies.getCookieURIs();
        for (uint256 i = 0; i < 5; i ++) {
            emit log_named_string(Strings.toString(i), uris[i]);
        }
    }

    /// @notice tests getCookieOwners()
    function testGetCookieOwners()public {
        address[] memory owners;
        owners = cookies.getCookieOwners();
        for (uint256 i = 0; i < 5; i ++) {
            emit log_named_address(Strings.toString(i), owners[i]);
        }
    }

    /// @notice Tests contract address
    function testContractAddress()public {
        emit log_named_address("Contract Address: ", address(cookies));
    }

    /// @notice Tests contract owner
    function testContractOwner()public {
        emit log_named_address("Contract Owner: ", address(this));
    }

    /// @notice Tests the tokenURI function
    function testTokenURI()public {
        emit log_named_string("Token URI: ", cookies.tokenURI(1));
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
    /// @dev Cookie of Wealth is NFT #5 and should be owned by alice
    /// @dev Bob should have his ether returned back
    function testBuyCookieOfWealthFromPass()public { // Bob buys Cookie of Wealth
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
    }

    /// @notice Tests the buyCookieOfWealth function with alice buying from bob
    /// @dev Cookie of Wealth is NFT #5 and should be owned by bob
    /// @dev Bob should not have his ether returned back
    /// @dev TODO: Test to make sure funds wern't returned to bob
    function testBuyCookieOfWealthFromFail()public { // Bob buys Cookie of Wealth
        vm.startPrank(address(bob));
        cookies.buyCookieOfWealth {
            value : SMOL_BUY_AMOUNT
        }();
        vm.stopPrank();

        // Bob should own Cookie of Wealth
        assertEq(cookies.lookupOwner(5), bob);

        // Log NFT owners after Bob buys Cookie of Wealth
        emit log_string("NFT Owners: ");
        for (uint256 i = 1; i <= 5; i ++) {
            address owner = cookies.lookupOwner(i);
            emit log_named_address(Strings.toString(i), owner);
        }

        // Alice tries to buy Cookie of Wealth from Bob
        // Anticipated revert because alice does not have enough ether
        vm.startPrank(address(alice));
        vm.expectRevert("Not enough funds");
        cookies.buyCookieOfWealth {
            value : SMOL_BUY_AMOUNT
        }();
        vm.stopPrank();

        // Bob should still own Cookie of Wealth
        assertEq(cookies.lookupOwner(5), bob);

        // Log NFT owners after Alice tries to buy Cookie of Wealth
        emit log_string("NFT Owners: ");
        for (uint256 i = 1; i <= 5; i ++) {
            address owner = cookies.lookupOwner(i);
            emit log_named_address(Strings.toString(i), owner);
        }

        // Bob should not have his ether returned back
        assertEq(bob.balance, DEAL_AMOUNT - SMOL_BUY_AMOUNT);
    }

    /// @notice Tests the takeCookieOfWar function
    /// @dev Cookie of War is NFT #4 and should be owned by after takeCookieOfWar is called
    /// @dev assumes that the block number is even
    function testTakeCookieOfWarPass()public { // Starts prank on bob and rolls the vm to an even block number
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
    }

    /// @notice Tests the takeCookieOfWar function
    /// @dev Cookie of War is NFT #4 and should be owned by the contract deployer after it is called
    /// @dev assumes that the block number is odd
    function testTakeCookieOfWarFail()public { // Starts prank on bob and rolls the vm to an odd block number
        vm.startPrank(address(bob));
        vm.roll(69421);
        emit log_named_uint("Block Number: ", block.number);

        // Bob tries to buy Cookie of War on odd block number
        // Anticipated revert because the block number is odd
        vm.expectRevert("Not an even block");
        cookies.takeCookieOfWar();
        vm.stopPrank();

        // Contract deployer should still own Cookie of War
        assertEq(cookies.lookupOwner(4), address(this));

        // Log NFT owners after Bob tries to take Cookie of War
        emit log_string("NFT Owners: ");
        for (uint256 i = 1; i <= 5; i ++) {
            address owner = cookies.lookupOwner(i);
            emit log_named_address(Strings.toString(i), owner);
        }
    }

    /// @notice Tests the takeCookieOfTime function with a block timestamp that is 1 week greater
    /// @dev Cookie of Time is NFT #3 and should be owned by bob after it is called
    /// @dev assumes that the block timestamp is greater than the previous block timestamp by 1 week
    function testTakeCookieOfTimePass()public {
        // Starts prank on bob and rolls the vm to a block timestamp 1 week greater
        // Logs the block timestamp before and after the warp
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
    }

    /// @notice Tests the takeCookieOfTime function with a block timestamp that is 1 week less
    /// @dev Cookie of Time is NFT #3 and should be owned by the contract deployer after it is called
    /// @dev assumes that the block timestamp is less than the previous block timestamp by 1 week
    function testTakeCookieOfTimeFail()public {
        // Starts prank on bob and rolls the vm to a block timestamp slightly less then 1 week
        // Logs the block timestamp before and after the warp
        vm.startPrank(address(bob));
        emit log_named_uint("Block Timestamp: ", block.timestamp);
        vm.warp(block.timestamp + 604798);
        emit log_named_uint("After Roll Block Timestamp: ", block.timestamp);

        // Bob tries to buy Cookie of Time on a block timestamp slightly less than 1 week
        // Anticipated revert because the block timestamp is less than 1 week
        vm.expectRevert("Not a week");
        cookies.takeCookieOfTime();
        vm.stopPrank();


        assertEq(cookies.lookupOwner(3), address(this));

        // Log NFT owners after Bob tries to take Cookie of Time
        emit log_string("NFT Owners: ");
        for (uint256 i = 1; i <= 5; i ++) {
            address owner = cookies.lookupOwner(i);
            emit log_named_address(Strings.toString(i), owner);
        }
    }


    /// @notice Tests the takeCookieOfWisdom function
    /// @dev Cookie of Wisdom is NFT #2 and should be owned by bob after it is called
    /// @dev assumes that the hashed input number is greater than the hashed previous number
    function testTakeCookieOfWisdomPass()public { // Starts prank on bob and logs the hashed input number and the hashed previous number
        vm.startPrank(address(bob));
        uint testNumber = 1;
        emit log_named_uint("Test Number: ", uint256(keccak256(abi.encodePacked(testNumber))));
        emit log_named_uint("Last Number: ", uint256(keccak256(abi.encodePacked(cookies.lastNumber))));

        // Bob buys Cookie of Wisdom on a hashed input number greater than the hashed previous number
        cookies.takeCookieOfWisdom(testNumber);
        vm.stopPrank();

        // Bob should own Cookie of Wisdom
        assertEq(cookies.lookupOwner(2), bob);

        // Log NFT owners after Bob takes Cookie of Wisdom
        emit log_string("NFT Owners: ");
        for (uint256 i = 1; i <= 5; i ++) {
            address owner = cookies.lookupOwner(i);
            emit log_named_address(Strings.toString(i), owner);
        }
    }

    /// @notice Tests the takeCookieOfWisdom function
    /// @dev Cookie of Wisdom is NFT #2 and should be owned by the contract deployer after it is called
    /// @dev assumes that the hashed input number is less than the hashed previous number
    function testTakeCookieOfWisdomFail()public { // Starts prank on bob and logs the hashed input number and the hashed previous number
        vm.startPrank(address(bob));
        uint testNumber = 0;
        emit log_named_uint("Test Number: ", uint256(keccak256(abi.encodePacked(testNumber))));
        emit log_named_uint("Last Number: ", uint256(keccak256(abi.encodePacked(cookies.lastNumber))));

        // Bob tries to buy Cookie of Wisdom on a hashed input number less than the hashed previous number
        // Anticipated revert because the hashed input number is less than the hashed previous number
        vm.expectRevert("Not greater than previous");
        cookies.takeCookieOfWisdom(testNumber);
        vm.stopPrank();

        // Contract deployer should own Cookie of Wisdom
        assertEq(cookies.lookupOwner(2), address(this));

        // Log NFT owners after Bob tries to take Cookie of Wisdom
        emit log_string("NFT Owners: ");
        for (uint256 i = 1; i <= 5; i ++) {
            address owner = cookies.lookupOwner(i);
            emit log_named_address(Strings.toString(i), owner);
        }
    }


    /// @notice Tests the takeCookieOfPower function
    /// @dev Cookie of Power is NFT #1 and should be owned by bob after it is called
    /// @dev assumes that the block number ends in 420
    function testTakeCookieOfPowerPass()public {
        // Starts prank on bob and rolls the vm to a block number ending in 420
        // Logs the block number after the warp
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
    }

    /// @notice Tests the takeCookieOfPower function
    /// @dev Cookie of Power is NFT #1 and should be owned by the contract deployer after it is called
    /// @dev assumes that the block number does not end in 420
    function testTakeCookieOfPowerFail()public {
        // Starts prank on bob and rolls the vm to a block number not ending in 420
        // Logs the block number after the warp
        vm.startPrank(address(bob));
        vm.roll(69421);
        emit log_named_uint("Block Number: ", block.number);

        // Bob tries to buy Cookie of Power on a block number not ending in 420
        // Anticipated revert because the block number does not end in 420
        vm.expectRevert("Not a 420 block");
        cookies.takeCookieOfPower();
        vm.stopPrank();

        // Contract deployer should own Cookie of Power
        assertEq(cookies.lookupOwner(1), address(this));

        // Contract deployer should own Cookie of Power
        emit log_string("NFT Owners: ");
        for (uint256 i = 1; i <= 5; i ++) {
            address owner = cookies.lookupOwner(i);
            emit log_named_address(Strings.toString(i), owner);
        }
    }

    /// @notice Tests the takeCookieOfH4X0R function
    /// @dev Cookie of H4X0R is NFT #1337 and should be owned by bob after it is called
    /// @dev assumes that the block number is 69420
    function testTakeCookieOfH4X0RPass()public {
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
    }

    /// @notice Tests the takeCookieOfH4X0R function
    /// @dev Cookie of H4X0R is NFT #1337 and should be owned by the contract deployer after it is called
    /// @dev assumes that the block number is not 69420
    function testTakeCookieOfH4X0RFail()public {
        // Starts prank on bob and rolls the vm to a block number not of 69420
        // Logs the block number after the warp
        vm.startPrank(address(bob));
        emit log_named_uint("Block Number: ", block.number);

        // Bob tries to buy Cookie of H4X0R
        // Anticipated revert because Bob does not own any of the other cookies
        vm.expectRevert("Must own one of the other cookies");
        cookies.takeCookieOfH4X0R();
        vm.stopPrank();

        // Contract deployer should own Cookie of H4X0R
        assertEq(cookies.lookupOwner(1337), address(this));

        // Log NFT owners after Bob tries to take Cookie of H4X0R
        emit log_string("NFT Owners: ");
        for (uint256 i = 1; i <= 6; i ++) {
            if (i == 6) {
                emit log_named_address(Strings.toString(1337), address(this));
            } else {
                address owner = cookies.lookupOwner(i);
                emit log_named_address(Strings.toString(i), owner);
            }
        }
    }
}
