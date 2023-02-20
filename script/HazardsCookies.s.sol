// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import { HazardsCookiesV4 } from "src/HazardsCookies.sol";

contract CookiesScript is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();
        new HazardsCookiesV4();
    }
}
