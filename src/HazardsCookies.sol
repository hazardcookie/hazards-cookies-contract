// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8 .13;

import "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "lib/openzeppelin-contracts/contracts/utils/Base64.sol";

/// @title Hazard's Cookies 
/// @author @hazardcookie
/// @notice This NFT contract has 5 cookies, each claimable with different conditions
/// @dev This version of the contract has a multi-call function to return all owners and metadata
contract HazardsCookiesV4 is ERC721 {
    uint256 public constant COOKIE_OF_POWER = 1;
    uint256 public constant COOKIE_OF_WISDOM = 2;
    uint256 public constant COOKIE_OF_TIME = 3;
    uint256 public constant COOKIE_OF_WAR = 4;
    uint256 public constant COOKIE_OF_WEALTH = 5;
    uint256 internal constant COOKIE_OF_H4X0R = 1337;

    uint256 public lastPrice;
    uint256 public lastTime;
    uint256 public lastNumber;

    // colors for the cookies F5D6FD
    string[5] internal colors = [
        "#ff8dc0",
        "#cc96f0",
        "#A581FA",
        "#899EF8",
        "#98E7FF"
    ];

    // names of the cookies
    string[5] internal names = [
        "Power",
        "Wisdom",
        "War",
        "Time",
        "Wealth"
    ];

    constructor()ERC721("Hazards Cookies", "COOKIES") {
        _mint(msg.sender, COOKIE_OF_POWER);
        _mint(msg.sender, COOKIE_OF_WISDOM);
        _mint(msg.sender, COOKIE_OF_WAR);
        _mint(msg.sender, COOKIE_OF_TIME);
        _mint(msg.sender, COOKIE_OF_WEALTH);
        _mint(msg.sender, COOKIE_OF_H4X0R);
    }

    /// @notice returns the owner of a token
    /// @param tokenId the id of the token
    /// @return address of the owner
    function lookupOwner(uint256 tokenId)public view returns(address) {
        return ownerOf(tokenId);
    }

    /// @notice Buys the Cookie of Wealth
    /// @dev requires that the msg.value is greater than or equal to the lastPrice
    /// @dev if true, it transfers the Cookie of wealth to the msg.sender
    /// @dev then it  returns the previous owner's funds & sets the lastPrice to the msg.value
    function buyCookieOfWealth()public payable {
        require(msg.value > lastPrice, "Not enough funds");
        address payable previousOwner = payable(ownerOf(COOKIE_OF_WEALTH));
        uint256 refund = lastPrice;
        lastPrice = msg.value;
        _transfer(ownerOf(COOKIE_OF_WEALTH), payable(msg.sender), COOKIE_OF_WEALTH);
        previousOwner.send(refund);
    }

    /// @notice Takes the Cookie of War
    /// @dev requires that the block number is even
    /// @dev if true, it transfers the Cookie of war to the msg.sender
    function takeCookieOfWar()public {
        require(block.number % 2 == 0, "Not an even block");
        _transfer(ownerOf(COOKIE_OF_WAR), payable(msg.sender), COOKIE_OF_WAR);
    }

    /// @notice Takes the Cookie of Time
    /// @dev requires that the the caller has waited a week since the last claim
    /// @dev if true, it transfers the Cookie of time to the msg.sender
    function takeCookieOfTime()public {
        require(block.timestamp - lastTime >= 604800, "Not a week");
        lastTime = block.timestamp;
        _transfer(ownerOf(COOKIE_OF_TIME), payable(msg.sender), COOKIE_OF_TIME);
    }

    /// @notice Takes the Cookie of Wisdom
    /// @param number a number that is hashed and compared to the lastNumber
    /// @dev requires that the caller has provided a number that
    /// @dev when hashed is greater than the hashed lastNumber.
    /// @dev if true: it transfers the Cookie of wisdom to the msg.sender
    function takeCookieOfWisdom(uint256 number)public {
        require(uint256(keccak256(abi.encode(number))) > uint256(keccak256(abi.encode(lastNumber))), "Not greater than previous");
        _transfer(ownerOf(COOKIE_OF_WISDOM), payable(msg.sender), COOKIE_OF_WISDOM);
    }

    /// @notice Takes the Cookie of Power
    /// @dev requires that the block number ends in 420
    /// @dev if true, it transfers the Cookie of power to the msg.sender
    function takeCookieOfPower()public {
        uint8 lastDigit = uint8(block.number % 10);
        uint8 secondToLastDigit = uint8((block.number / 10) % 10);
        uint8 thirdToLastDigit = uint8((block.number / 100) % 10);
        require(lastDigit == 0 && secondToLastDigit == 2 && thirdToLastDigit == 4, "Not a 420 block");
        _transfer(ownerOf(COOKIE_OF_POWER), payable(msg.sender), COOKIE_OF_POWER);
    }

    /// @notice 1337 H4X0R
    function takeCookieOfH4X0R()public {
        require(ownerOf(COOKIE_OF_POWER) == msg.sender || ownerOf(COOKIE_OF_WISDOM) == msg.sender || ownerOf(COOKIE_OF_WAR) == msg.sender || ownerOf(COOKIE_OF_TIME) == msg.sender || ownerOf(COOKIE_OF_WEALTH) == msg.sender, "Must own one of the other cookies");
        _transfer(ownerOf(COOKIE_OF_H4X0R), payable(msg.sender), COOKIE_OF_H4X0R);
    }

    /// @notice gets the svg of a cookie and applies the color
    /// @param tokenId id of the token
    /// @return string svg of the Cookie
    function getSVG(uint256 tokenId)private view returns(string memory) {
        string memory svg;
        svg = string.concat('<svg fill="', colors[tokenId - 1],'" width="100px" height="100px" version="1.1" viewBox="0 0 700 700" xmlns="http://www.w3.org/2000/svg"><g><path d="m350 560c-75.949 0-147.02-29.727-200.15-83.766-52.711-53.598-81.059-124.44-79.824-199.48 0.09375-5.5078 2.1484-10.828 5.7852-14.98 3.125-3.5703 7.4414-6.3477 12.039-7.5117 20.648-5.2031 38.102-19.133 47.949-38.219 5.4375-10.547 17.922-15.328 29.027-11.129 51.52 19.555 100.61-19.762 100.61-69.301l-0.44141-4.1523-0.51172-3.8984c-0.69922-6.4414 1.3281-12.879 5.5781-17.781 4.2461-4.875 10.336-7.793 16.824-8.0273 33.438-1.1445 62.137-24.547 69.789-56.91 5.9023-24.941 31.57-40.32 57.262-34.418 127.21 29.586 216.07 141.03 216.07 271.02 0 153.6-125.6 278.55-280 278.55zm-233.03-266.42c2.8945 56.422 26.039 109.18 66.148 149.94 44.285 45.035 103.55 69.812 166.88 69.812 128.66 0 233.33-104.02 233.33-231.89 0-108.17-74.012-200.92-179.97-225.56l-1.5625 0.30469c-10.406 44.566-46.012 78.914-90.09 89.133-4.9688 62.254-57.191 111.35-120.66 111.35-8.0039 0-16.055-0.86328-24.102-2.5664-12.879 17.383-30.148 31.012-49.98 39.48z"/><path d="m443.33 198.33c0 19.332-15.668 35-35 35-19.328 0-35-15.668-35-35 0-19.328 15.672-35 35-35 19.332 0 35 15.672 35 35"/><path d="m280 338.33c0 19.332-15.672 35-35 35s-35-15.668-35-35c0-19.328 15.672-35 35-35s35 15.672 35 35"/><path d="m466.67 385c0 19.328-15.672 35-35 35-19.332 0-35-15.672-35-35s15.668-35 35-35c19.328 0 35 15.672 35 35"/><path d="m373.33 280c0 12.887-10.445 23.332-23.332 23.332s-23.332-10.445-23.332-23.332 10.445-23.332 23.332-23.332 23.332 10.445 23.332 23.332"/><path d="m326.67 420c0 12.887-10.449 23.332-23.336 23.332s-23.332-10.445-23.332-23.332 10.445-23.332 23.332-23.332 23.336 10.445 23.336 23.332"/><path d="m303.33 23.332c0 12.887-10.445 23.336-23.332 23.336s-23.332-10.449-23.332-23.336 10.445-23.332 23.332-23.332 23.332 10.445 23.332 23.332"/><path d="m210 128.33c0 19.332-15.672 35-35 35s-35-15.668-35-35c0-19.328 15.672-35 35-35s35 15.672 35 35"/><path d="m513.33 280c0 12.887-10.445 23.332-23.332 23.332s-23.332-10.445-23.332-23.332 10.445-23.332 23.332-23.332 23.332 10.445 23.332 23.332"/></g></svg>');
        return svg;
    }

    /// @notice return metadata of the Cookie
    /// @param tokenId the id of the token
    /// @return string encoded metadata of the Cookie
    function tokenURI(uint256 tokenId)
    public view override(ERC721) returns(string memory) {
        string memory json = Base64.encode(
            bytes(string(
                abi.encodePacked(
                    '{"name": "', names[tokenId - 1],'", "description": "Hazards Cookies, Yumm!", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(getSVG(tokenId))), '"}'
                )
            ))
        );
        return string(abi.encodePacked('data:application/json;base64,', json));
    }

    /// @notice returns the tokenURIs of all the cookies
    /// @return string[] tokenURIs of the cookies
    function getCookieURIs() public view returns(string[] memory) {
        string[] memory tokenURIs = new string[](5);
        for (uint256 i = 0; i < 5; i++) {
            tokenURIs[i] = tokenURI(i + 1);
        }
        return tokenURIs;
    }

    /// @notice returns the owners of all the cookies
    /// @return address[] owners of the cookies
    function getCookieOwners() public view returns(address[] memory) {
        address[] memory owners = new address[](5);
        for (uint256 i = 0; i < 5; i++) {
            owners[i] = ownerOf(i + 1);
        }
        return owners;
    }

    /// @notice returns the results of getCookieURIs and getCookieOwners
    /// @return string[] tokenURIs of the cookies
    /// @return address[] owners of the cookies
    function getCookieURIsAndOwners() public view returns(string[] memory, address[] memory) {
        return (getCookieURIs(), getCookieOwners());
    }
}
