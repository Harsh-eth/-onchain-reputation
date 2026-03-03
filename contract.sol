// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OnChainReputation {

    struct UserData {
        uint points;
        bool active;
    }

    enum tier {Beginer, Intermediate, Advance }
    tier achieved;
    tier constant defaultChoice = tier.Beginer;

    mapping(address=>UserData) user;
    mapping(address=>bool) registered;

    address public owner;
    address[] totalUsers;
    
    bool public paused;
    bool private locked;

    event Registered(address indexed user);
    event PointsEarned(address indexed user, uint points);
    event PointsDecreased(address  indexed user, uint points);
    event Activated(address  indexed user);
    event Deactivated(address  indexed user);
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can call this");
        _;
    }

    modifier whenNotPaused() {
        require(paused == false, "contract is paused");
        _;
    }

    modifier nonReentrant() {
        require(!locked, "reentrant");
        locked = true;
        _;
        locked = false;
    }

    constructor() {
        owner = msg.sender;
    }

    function ownerAddPoints(address usr, uint points) public onlyOwner {
        require(registered[usr], "user is not registered");
        user[usr].points += points;
        emit PointsEarned(usr, points);
    }

    function ownerDeletePoints(address usr, uint points) public onlyOwner {
        require(registered[usr], "user is not registered");
        if(points >= user[usr].points){
            user[usr].points = 0;
        } else {
            user[usr].points -= points;
        }
        emit PointsDecreased(usr, points);
    }

    function ownerDeactivate(address usr) public onlyOwner {
        require(registered[usr], "user is not registered");
        user[usr].active = false;
        emit Deactivated(usr);
    }

    function pause() public onlyOwner {
        paused = true;
    }
    
    function unPause() public onlyOwner {
        paused = false;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "invalid address");
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function register() public whenNotPaused nonReentrant {
        require(registered[msg.sender] == false, "you can register only once");
        UserData storage u = user[msg.sender];
        u.points = 0;
        u.active = true;
        registered[msg.sender] = true;
        totalUsers.push(msg.sender);
        emit Registered(msg.sender);
    }

    function earnPoints() public whenNotPaused nonReentrant {
        UserData storage u = user[msg.sender];
        require(registered[msg.sender] == true && u.active == true, "you can earn points only if you are registered and active");
        u.points += 1;
        emit PointsEarned(msg.sender, 1);
    }

    function decreasePoints() public whenNotPaused nonReentrant {
        UserData storage u = user[msg.sender];
        require(registered[msg.sender] == true && u.active == true, "you can decrease points only if you are registered and active");
        if(u.points > 0) {
            u.points -= 1;
            emit PointsDecreased(msg.sender, 1);
        }
    }

    function activate() public whenNotPaused nonReentrant {
        require(registered[msg.sender], "user is not registered");
        user[msg.sender].active = true;
        emit Activated(msg.sender);
    }

    function deActivate() public whenNotPaused nonReentrant {
        require(registered[msg.sender], "user is not registered");
        user[msg.sender].active = false;
        emit Deactivated(msg.sender);
    }

    function getUser(address usr) public view returns(uint points, bool active, bool isregistered, tier myTier) {
        return (user[usr].points, user[usr].active, registered[usr], getUserTierOf(usr));
    }

    function getMyPoints() public view returns(uint) {
        return user[msg.sender].points;
    }

    function getUserTier() public view returns(tier){
        uint pts = user[msg.sender].points;
        if(pts <= 10) {
            return tier.Beginer;
        }else if(pts > 10 && pts <= 25) {
            return tier.Intermediate;
        }else {
            return tier.Advance;
        }
    }

    function getUserTierOf(address usr) public view returns(tier) {
        uint pts = user[usr].points;

        if(pts <= 10){
            return tier.Beginer;
        }else if(pts > 10 && pts <= 25){
            return tier.Intermediate;
        }else{
            return tier.Advance;
        }
    }

    function getTotalUser() public view returns(uint) {
        return totalUsers.length;
    }

    function getUserAtIndex(uint index) public view returns(address) {
        require(index < totalUsers.length,"index is out of the range");
        return totalUsers[index];
    }

    function getAllUsers() public view returns(address[] memory) {
        return totalUsers;
    }

    function isUserRegistered(address usr) public view returns(bool) {
        return registered[usr];
    }

    function isUserActive(address usr) public view returns(bool) {
        return user[usr].active;
    }

    function getActiveUserCount() public view returns(uint count) {
        for(uint i=0;i < totalUsers.length ; i++) {
            if(isUserActive(totalUsers[i])) {
                count++;
            }
        }
    }



}
