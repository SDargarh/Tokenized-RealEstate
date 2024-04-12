//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IERC721 {
    function transferFrom(address _from, address _to, uint256 _id) external;
}

contract Escrow {
    address public nftAddress;
    address payable public seller;
    address public lender;
    address public inspector;

    mapping (uint256 => bool) public isListed;
    mapping(uint256 => uint256) public purchasePrice;
    mapping(uint256 => uint256) public escrowAmount;
    mapping(uint256 => address) public buyer;
    
    constructor(
        address _nftAddress,
        address payable _seller,
        address _inspector,
        address _lender
    ) {
        nftAddress = _nftAddress;
        seller = _seller;
        inspector = _inspector;
        lender = _lender;
    }

    modifier onlySeller() {
        require(msg.sender == seller, "unauthorised");
        _;
    }

    function list(uint256 _nftID, uint256 _purchasePrice, uint256 _escrowAmount) public payable onlySeller {

        // transfer NFT from seller to this contract
        IERC721(nftAddress).transferFrom(seller, address(this), _nftID);
        isListed[_nftID] = true;
        purchasePrice[_nftID] = _purchasePrice;
        escrowAmount[_nftID] = _escrowAmount;
        
    }

    function depositEarnest(uint256 _nftID) public payable {
        require(msg.value >= escrowAmount[_nftID]);
        buyer[_nftID] = msg.sender;
    }

    receive() external payable{}

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
