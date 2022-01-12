## Private-Auction
#Introduction
Conventional trading systems necessitate individuals to trust each other or a third party. The most important benefit of Blockchain is eliminating the need for a trusted party. For this reason, trading Dapps have been of great popularity in the past few years. One of the most important applications in financial interactions is auction. An auction is a way of selling commodities, products, or properties in which the initial price is determined by the seller. Then bidders offer their price for buying the product. The product will be sold to the bidder correspondent with the highest bid. Procurement auction is a type of auction in which the traditional roles of buyer and seller are reversed. Thus, there is one buyer and many potential sellers. And sellers compete to underbid each other. Auctions are classified based on different criteria like: ascending/descending bid, all pay / one pay, first price / second price, multiunit/single-unit. Regarding the privacy of the bids, auctions are categorized as open auctions and sealed-bid auctions.
Open auctions: In this kind of auction the privacy of the bids is not important. Bidding rules and the strategy to determine the winner are different between ascending open auctions and descending open auctions.
Sealed-bid auction: In this kind of auction the privacy of the bids matters a lot to the bidders. Therefore, bids are hidden until they are opened simultaneously by the auctioneer and the winner will be determined and announced based on the strategy of the auction.
Sealed bid auctions are held in general to sell or buy crucial and expensive products and services. Governments conduct sealed bid Procurement auctions between provider companies to buy services or commodities; Hence attendees at these types of auctions are mostly rival companies that care a lot about the confidentiality of their bids.


#Incentive 
Our objective is to develop a Dapp based on the Ethereum blockchain that supports a wide spectrum of auctions while using Blockchain technology obviates the necessity of third party existence such that all the features of Blockchain like transparency, anonymity, distribution, consensus on protocol and … are reflected in it.
Challenges
According to open auction definition, it seems that it is trivial to implement them on a Turing-complete language Blockchain like Ethereum; as others have done this before. But implementing sealed-bid auctions seems challenging. In available central sealed-bid auction websites, for preserving the confidentiality of bids, bidders don’t have any choice other than to trust the auctioneer with determining the winner. It’s obvious that in this case, the auctioneer can collude with some of bidders or sellers and change the result of the auction in favor of some of them.
We are going to use Blockchain instead of the centralized auctioneer to solve the trust problem, but the privacy of bids conflicts the inherent transparency of the Blockchain. Solving this confliction is the most challenging part of designing the Dapp above.
Structure of our Dapp 
Open auction:
The distributed back-end of our proposed structure is basically a smart contract that will be deployed on the Zilliqa Blockchain whenever a new auction is initiated. Every auction type has a specific smart contract. Properties of auction like its type, end time, minimum increment value, the maximum number of bidders and … are set by the seller.
 In fact, the user doesn’t need to send a smart contract or transaction to Blockchain herself; she just interacts with a user interface, and our website sends transactions to the Blockchain on behalf of her. It doesn’t mean that the user has to trust us with her private data; user can send public data (that are supposed to be saved on the Blockchain) through our website instead of sending data directly to Blockchain. Any user that doesn’t trust us can check the correctness of every auction on Blockchain.
Sealed bid auction:
A summary of a sealed-bid auction protocol is presented below; for an in-depth description see Hawk.
Bidding for a sealed bid or open auction through the website doesn’t differ from the user's point of view. But there is a basic difference between smart contracts associated with each of these prototypes.
 We have employed ZK-snark to solve the problem mentioned in the challenges section. The acronym ZK-SNARK stands for “Zero-Knowledge Succinct Non-Interactive Argument of Knowledge,” and refers to a proof construction where one can prove possession of certain information, e.g. a secret key, without revealing that information, and without any interaction between the prover and verifier. The following procedure is undergoing to preserve bid’s confidentiality. (In the following whenever we mention “bidder” in fact we mean website on behalf of the bidder.)
First phase (commitment): In this phase, bidders calculate the hash of their bid concatenated with a random value and send this hash (H) to the smart contract. Once the commitment duration has finished no one can commit a new bid. In this phase all bidders and auctioneer have to deposit some money as a guarantee to follow the protocol honestly. 
Second phase (revealing): Note that every bidder and auctioneer can mutually share a key via Diffie-Hellman secret sharing without any interaction. Each bidder encrypts her bid using this shared key and sends the cipher (C) text to the smart contract.
But how can we make sure that all the bidders have submitted consistent values in commitment and reveal phase? In other word, the opening value of their commitment is equal to the plaintext that matches their ciphertext.
For the purpose of preventing such a potential malicious behavior, each bidder is obligated to generate a proof using ZK-snark that shows:
1)    She knows a secret value that its associated ciphertext is equal to C and its hash value is H. 
2)    She has encrypted the bid using a valid shared key.
Note that no secret information like bidder’s bid or private key can be extracted from the proof. It is actually the power of ZK-snark!
The smart contract judges the correctness of the proofs and if any bidder has sent an invalid proof or hasn't sent any ciphertext, smart contract labels her as a violator and distracts her commitment and ciphertext from further steps besides blocking her deposit.
Third phase (announcement and verification of the winner): As explained before, each user shares a Diffie-Helman key with the auctioneer in phase 2 and encrypts her bid and random value using this key. The auctioneer mutually can calculate the key shared between him and any bidder and use this key to decrypt bidder's ciphertext. Auctioneer must compare bids and determine and announce the winner; In addition, he must provide a ZK-snark proof as an evidence of determining winner correctly. Note that as we use ZK-snark, no information about any bids except for winners' bid leaks out. Smart contract verifies auctioneer's proof, in case of wrong proof or not providing any proof, auctioneer's deposit is blocked and the auction ends. 
Forth phase (withdrawal): At the end of the auction, any honest participant except the winner can withdraw her deposit. The winner’s deposit is not refunded and she must fulfill the payment of the highest bid (or another value based on the auction type). As mentioned before, the deposit of fraudulent participants are blocked and refunded to all honest participants at the end of the auction. This encourages people not to act maliciously.
It can be inferred from the protocol that the suggested auction provides the following properties:
1.Bids’ Privacy. The submitted bids are visible to nobody during the commitment phase.
2. Posterior privacy. After the revealing phase, bids are not revealed to the public, assuming a semi-honest auctioneer.
3. Bids’ Binding. Bidders cannot deny or change their bids once they have committed.
4. Public Verifiability. As all the transactions including the verifying proofs are saved on Blockchain anyone can check them.
5. Fairness. Rational parties are obligated to follow the proposed protocol to avoid being financially penalized.
6. Non-Interactivity. Since we are using succinct non-interactive Argument of Knowledge protocol bidders and auctioneer don't need to interact with smart contract in order to show the validity of their proofs.
7. Scalability. As we use ZK-snark, proofs are succinct; also verifying the proofs doesn't consume unusual gas, so this auction is scalable across the number of bidders.
Bidders and auctioneer in phase 2 and phase 3 create ZK-snark proofs, respectively. We will design an easy to use application that generates proofs from user's private data locally; As a result, users don't require to send their private data to a server for generating proof and their privacy is protected.
At following figure, you see the scheme of participation in a sealed bid auction from the point of view of bidder:
 
References:
Hawk: The Blockchain Model of Cryptography and Privacy-Preserving Smart Contracts

Verifiable Sealed-Bid Auction on the Ethereum Blockchain

