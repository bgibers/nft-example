pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

import { Base64 } from "./libraries/Base64.sol";

contract MyNFT is ERC721URIStorage {
  using Counters for Counters.Counter;
  using Strings for uint256;

  Counters.Counter private _tokenIds;

  // This is our SVG code. All we need to change is the word that's displayed. Everything else stays the same.
  // So, we make a baseSvg variable here that all our NFTs can use.
  string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' font-size='20' dy='0' class='base' dominant-baseline='middle' text-anchor='middle'>";

  string[] adjectives = ["very analytical", "experienced", "a fast learner", "capable of anything", "always eager to learn more", "wanting to make an impact"];
  string[] experiences = ["typescript", "solidity", "git", "dotnet", "sql", "angular", "cloud computing", "data engineering"];

  // We need to pass the name of our NFTs token and it's symbol.
  constructor() ERC721 ("BrendanNFT", "AboutMe") {
    console.log("This is my NFT contract. Woah!");
  }

  function mintNFT() public {
     // Get the current tokenId, this starts at 0.
    uint256 newItemId = _tokenIds.current();

    uint256 rando = random(string(
                    abi.encodePacked(
                        block.difficulty,
                        block.timestamp
                    )
                ));

    string memory nftText;
    string memory verbage;

    // if its an even number we'll create an adjective else an experience
    if (rando % 2 == 0 || experiences.length <= 0) {
      nftText = pickRandomAdjective(newItemId);
      verbage = "who is \n";
    } else {
      nftText = pickRandomExperience(newItemId);
      verbage = "who knows \n";
    }
    // Create the nft
    string memory finalSvg = string(abi.encodePacked(baseSvg, "<tspan x='50%'>An engineer</tspan>", "<tspan x='50%' dy='1.2em'>", verbage, 
    "</tspan>", "<tspan x='50%' dy='1.2em'>", nftText, "</tspan></text></svg>"));

    string memory json = Base64.encode(
      bytes(
            string(
                abi.encodePacked(
                    '{"name": "Brendan #',
                    // We set the title of our NFT as the generated word.
                    newItemId.toString(),
                    '", "description": "Some info about me", "image": "data:image/svg+xml;base64,',
                    // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                    Base64.encode(bytes(finalSvg)),
                    '"}'
                )
            )
        )
    );

    // console.log(json);
    // Just like before, we prepend data:application/json;base64, to our data.
    string memory finalTokenUri = string(
        abi.encodePacked("data:application/json;base64,", json)
    );

    console.log(
      string(
          abi.encodePacked(
              "https://nftpreview.0xdev.codes/?code=",
              finalTokenUri
          )
      )
    );

    _safeMint(msg.sender, newItemId);
    _setTokenURI(newItemId, finalTokenUri);    
    _tokenIds.increment();
    console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);
  }

  function pickRandomAdjective(uint256 tokenId) private returns (string memory) {
    uint256 rand = random(string(abi.encodePacked(Strings.toString(tokenId))));
    rand = rand % adjectives.length;

    console.log(rand);
    string memory adjective = adjectives[rand];
    removeAdj(rand);
    return adjective;
  }

  function pickRandomExperience(uint256 tokenId) private returns (string memory) {
    uint256 rand = random(string(abi.encodePacked(Strings.toString(tokenId))));
    rand = rand % experiences.length;

    console.log(rand);
    string memory experience = experiences[rand];
    removeExpr(rand);
    return experience;
  }

  function random(string memory input) internal pure returns (uint256) {
      return uint256(keccak256(abi.encodePacked(input)));
  }

  function removeAdj(uint index) private {
        // Move the last element into the place to delete
        adjectives[index] = adjectives[adjectives.length - 1];
        // Remove the last element
        adjectives.pop();
  }

  function removeExpr(uint index) private {
        // Move the last element into the place to delete
        experiences[index] = experiences[experiences.length - 1];
        // Remove the last element
        experiences.pop();
  }
}