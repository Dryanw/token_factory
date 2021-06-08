pragma solidity ^0.8.4;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     * @notice Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract ArtWork is ERC721, Ownable {
    address public _artist;
    string public _name;
    uint public _hashIPFS;

    constructor(uint ipfsHash, string memory artName) ERC721(artName, 'ARTW') public {
        _artist = msg.sender;
        _name = artName;
        _hashIPFS = ipfsHash;
    }

    function setOwner(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
}

contract ArtWorkFactory {
    address factoryOwner;
    mapping (uint => ArtWork) _artworks;
    mapping(address => uint[]) _artistWorks;

    constructor() {
        factoryOwner = msg.sender;
    }

    modifier artExists(uint hashIPFS) {
        address artOwner = _artworks[hashIPFS].owner();
        require(artOwner != address(0));
        _;
    }

    function uploadArtWork(uint hashIPFS, string memory artName) public returns (ArtWork) {
        ArtWork artContract = new ArtWork(hashIPFS, artName);
        _artworks[hashIPFS] = artContract;
        _artistWorks[msg.sender].push(hashIPFS);
        return artContract;
    }

    function getArtWorks(address artist) public view returns(uint[] memory){
        return _artistWorks[artist];
    }

    function getOwner(uint hashIPFS) public view artExists(hashIPFS) returns(address)  {
        return _artworks[hashIPFS].owner();
    }

    function transferArt(uint hashIPFS, address newOwner) public {
        address artOwner = _artworks[hashIPFS].owner();
        require(artOwner != address(0), 'no art with the given IPFS');
        require(artOwner == msg.sender, 'only the owner can transfer the art');
        return _artworks[hashIPFS].transferOwnership(newOwner);
    }

}