// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";

contract NFTContract is ERC1155, Ownable {
  
  address manager;

  string _uri;

  event Mint(address indexed minter, uint256 tokenId);

  constructor(address _mananger) ERC1155("ipfs://QmUyJVMuN7ozozwJvswz33GBqoPBA1VeMAsvnkyV8fgNk7/{id}.json") {
    manager = _mananger;
    _uri = "ipfs://QmUyJVMuN7ozozwJvswz33GBqoPBA1VeMAsvnkyV8fgNk7/";
  }

  function uri(uint256 _tokenId) override public view returns (string memory) {
    return string(
      abi.encodePacked(
          "ipfs://QmUyJVMuN7ozozwJvswz33GBqoPBA1VeMAsvnkyV8fgNk7/",
          Strings.toString(_tokenId),
          ".json"
      )
    );
  }

  function setURI(string memory _uri) public onlyManager {
    _setURI(_uri);
  }

  function mint(address mintTo, uint256 tokenId) public {
    require(msg.sender != mintTo);
    _mint(mintTo, tokenId, 1, "");
    emit Mint(mintTo, tokenId);
  }

  function _beforeTokenTransfer(
    address operator,
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) pure override internal {
    require(from == address(0) || to == address(0), "This a Soulbound token. It cannot be transferred. It can only be burned by the token owner.");
  }

  function burn(uint256 tokenId, uint256 amount) external {
      require(balanceOf(msg.sender, tokenId) >= amount, "not enough tokens to burn");
      _burn(msg.sender, tokenId, amount);
  }

  function _burn(address sender, uint256 tokenId, uint256 amount) internal override (ERC1155) {
      super._burn(sender, tokenId, amount);
  }

  modifier onlyManager() {
        _checkManager();
        _;
    }

  function _checkManager() internal view virtual {
    require(manager == msg.sender, "Ownable: caller is not the owner");
  }
}