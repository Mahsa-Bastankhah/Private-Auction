
# Private-Auction
## Introduction
An auction is a way of selling commodities, products, or properties in which the initial price is determined by the seller. Then bidders offer their price for buying the product. The product will be sold to the bidder correspondent with the highest bid. Regarding the privacy of the bids, auctions are categorized as open auctions and sealed-bid auctions.

#### Open auctions: 
In this auction, the privacy of the bids is not important. All the bidders announce their bid publicly and the winner is determined based on the auction rules.

#### Sealed-bid auction: 
In sealed-bid auctions, the bids are private data that should remain unknown to the other bidders even after the auction finishes. Therefore, the bidders send their bids to the auctioneer in sealed envelopes. Then the auctioneer opens all of them simultaneously and determines and announces the winner.
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
Our proposed scheme has the following security and privacy guarantees:
1. Bids’ Privacy: The submitted bids are visible to nobody during the commitment phase.
2. Posterior privacy: After the revealing phase, bids are not revealed to the public, assuming a semi-honest auctioneer.
3. Bids’ Binding: Bidders cannot deny or change their bids once they have committed.
4. Public Verifiability: As all the transactions including the verifying proofs are saved on Blockchain anyone can check them.
5. Fairness: Rational parties are obligated to follow the proposed protocol to avoid being financially penalized.
6. Non-Interactivity: Since we are using succinct non-interactive Argument of Knowledge protocol bidders and auctioneer don't need to interact with smart contract in order to show the validity of their proofs.
7. Scalability: As we use ZK-snark, proofs are succinct; also verifying the proofs doesn't consume unusual gas, so this auction is scalable across the number of bidders.
 
## References:

[Hawk: The Blockchain Model of Cryptography and Privacy-Preserving Smart Contracts](https://user.eng.umd.edu/~cpap/published/hawk.pdf)

[Sealed-Bid Auction on the Ethereum Blockchain](https://eprint.iacr.org/2018/704.pdf)


