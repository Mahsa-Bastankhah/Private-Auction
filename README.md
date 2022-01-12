# Private-Auction
## Introduction
Conventional trading systems necessitate individuals to trust each other or a third party. The most important benefit of Blockchain is eliminating the need for a trusted party. For this reason, trading Dapps have been of great popularity in the past few years. One of the most important applications in financial interactions is an auction. An auction is a way of selling commodities, products, or properties in which the initial price is determined by the seller. Then bidders offer their price for buying the product. The product will be sold to the bidder correspondent with the highest bid. Regarding the privacy of the bids, auctions are categorized as open auctions and sealed-bid auctions.
Open auctions: In this auction, the privacy of the bids is not important. Bidding rules and the strategy to determine the winner are different between ascending open auctions and descending open auctions.
Sealed-bid auction: In this kind of auction the privacy of the bids matters a lot to the bidders. Therefore, bids are hidden until they are opened simultaneously by the auctioneer and the winner will be determined and announced based on the strategy of the auction.
In conventional auctions, the bidders have to trust the auctioneer for announcing the maximum bid. There isn't any way to eliminate the trust of the auctioneer and at the same time preserve the privacy of bids.
## Motivation and challenges
Our objective is to develop a sealed-bid auction Dapp on the Ethereum blockchain. This Dapp should work without trust to the auctioneer or any other third party in determining the winner and at the same time, guarantee the privacy of the bids against all the other bidders or any observer. Implementing sealed-bid auctions on blockchains seems challenging because the privacy of bids has a conflict with the inherent transparency of the Blockchain. tackling this challenge is the main contribution of our work.
## Structure of our Dapp 
The core of our smart contract is consist of several phases that are described below.
### First phase (commitment):
In this phase, bidders encrypt their bid with the auctioneer's public key and commit their encrypted bid to the smart contract. Once the commitment phase has finished no one can commit a new bid. In this phase, all bidders and auctioneer have to deposit some money as a guarantee to follow the protocol honestly. 
### Second phase (revealing):
In this phase, bidders encrypt their bid with the auctioneer's public key send the encrypted bid to the smart contract. In another word, they send the opening values corresponding to the committed bid in the previous phase.
### Third phase (announcement and verification of the winner):
The auctioneer opens the bids and determines and announces the winner; In addition, he must provide a ZK-snark proof to show that the winner has been determined correctly. Note that as we use ZK-snark, no information about any bids except for winner's bid leaks. Smart contract verifies auctioneer's proof, in case of wrong proof or not providing any proof, auctioneer's deposit is burnt and the auction ends. For implementing this phase we have used the Zokrate library which is a ZK-SNARK package implemented for Ethereum blockchain. 
### Forth phase (withdrawal):
At the end of the auction, all the honest participant except for the winner can withdraw their deposit. The winner’s deposit is not refunded and she must fulfil the payment based on her bid.
### Features
It can be inferred from the protocol that the suggested auction provides the following properties:
1. Bids’ Privacy: The submitted bids are visible to nobody during the commitment phase.
2. Posterior privacy: After the revealing phase, bids are not revealed to the public, assuming a semi-honest auctioneer.
3. Bids’ Binding: Bidders cannot deny or change their bids once they have committed.
4. Public Verifiability: As all the transactions including the verifying proofs are saved on Blockchain anyone can check them.
5. Fairness: Rational parties are obligated to follow the proposed protocol to avoid being financially penalized.
6. Non-Interactivity: Since we are using succinct non-interactive Argument of Knowledge protocol bidders and auctioneer don't need to interact with smart contract in order to show the validity of their proofs.
7. Scalability: As we use ZK-snark, proofs are succinct; also verifying the proofs doesn't consume unusual gas, so this auction is scalable across the number of bidders.

At following figure, you see the scheme of participation in a sealed bid auction from the point of view of bidder:
![alt text]("https://ibb.co/pywwMwb")

<img src="https://ibb.co/pywwMwb" />
 
## References:

[Hawk: The Blockchain Model of Cryptography and Privacy-Preserving Smart Contracts](https://user.eng.umd.edu/~cpap/published/hawk.pdf)

[Sealed-Bid Auction on the Ethereum Blockchain](https://user.eng.umd.edu/~cpap/published/hawk.pdf)

