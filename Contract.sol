pragma solidity >=0.7.0 <0.9.0;

//Contract deployed at: 0x954D1DdC92EEd03bD45F7d9d32D08111929241FC
/*
Requirements:
1. Creator creates a profile
2. Username must be unique
3. Creator can post different types of posts (text, image, video)
4. Users must be able to react (like, comment)
5. Creator must be able to create a tiered subscription system
6. Users must be able to pay for that
*/

contract Platform {

    uint public numberOfCreators; 
    
    constructor() {
        numberOfCreators = 0;
    }

    modifier onlyOwner (uint id) {
        require(Creators[id].owner == msg.sender, "Only owner can perform this action");
        _;
    }

    struct PostComment {
        address user;
        string text;
    }

    struct CreatorTextPost {
        address postCreator;
        string text;
        uint likes;
        uint comments;
        mapping(uint => PostComment) PostComments;
        mapping(address => uint) Likes;
    }

    struct CreatorMediaPost {
        address postCreator;
        string text;
        string mediaHash;
        uint mediaType; //0 - Image, 1-Video
        mapping(uint => PostComment) PostComments;
        uint likes;
        uint comments;
        mapping(address => uint) Likes;
    }

    struct Creator {
        address owner;
        string profile;
        string metadata; //ipfs hash
        string avatar;
        string banner;
        uint textPosts;
        uint mediaPosts;
        mapping(uint => CreatorTextPost) CreatorTextPosts;
        mapping(uint => CreatorMediaPost) CreatorMediaPosts;
    }

    mapping(string => bool) profileHandles;
    mapping(uint => Creator) Creators;

    function createProfile (string memory _profile, string memory _metadata, string memory _avatar, string memory _banner) public {
        require(profileHandles[_profile] == false, "Profile handle already exists");
        Creators[numberOfCreators].owner = msg.sender;
        Creators[numberOfCreators].profile = _profile;
        Creators[numberOfCreators].metadata = _metadata;
        Creators[numberOfCreators].avatar = _avatar;
        Creators[numberOfCreators].banner = _banner;
        Creators[numberOfCreators].textPosts = 0;
        Creators[numberOfCreators].mediaPosts = 0;
        profileHandles[_profile] = true;
        numberOfCreators++;
    }

    function createTextPost (uint _creatorId, string memory _text) onlyOwner(_creatorId) public {
        uint textPosts = Creators[_creatorId].textPosts;
        Creators[_creatorId].CreatorTextPosts[textPosts].text = _text;
        Creators[_creatorId].CreatorTextPosts[textPosts].postCreator = msg.sender;
        Creators[_creatorId].textPosts++;
    }

    function createMediaPost (uint _creatorId, string memory _text, string memory _cid, uint _type) onlyOwner(_creatorId) public {
        require(_type == 1 || _type == 2, "Post type must be either 1 or 2");
        uint mediaPosts = Creators[_creatorId].mediaPosts;
        Creators[_creatorId].CreatorMediaPosts[mediaPosts].text = _text;
        Creators[_creatorId].CreatorMediaPosts[mediaPosts].mediaHash = _cid;
        Creators[_creatorId].CreatorMediaPosts[mediaPosts].mediaType = _type;
        Creators[_creatorId].CreatorMediaPosts[mediaPosts].postCreator = msg.sender;
        Creators[_creatorId].mediaPosts++;
    }

    function likeTextPost(uint _creatorId, uint _postId) public returns (uint) {
        Creators[_creatorId].CreatorTextPosts[_postId].Likes[msg.sender] = 1;
        Creators[_creatorId].CreatorTextPosts[_postId].likes++;
        return Creators[_creatorId].CreatorTextPosts[_postId].likes;
    }

    function likeMediaPost (uint _creatorId, uint _postId) public returns (uint) {
        Creators[_creatorId].CreatorMediaPosts[_postId].Likes[msg.sender] = 1;
        Creators[_creatorId].CreatorMediaPosts[_postId].likes++;
        return Creators[_creatorId].CreatorMediaPosts[_postId].likes;
    }

    function commentOnPost (uint _creatorId, uint _postId, string memory _text, uint _postType) public {
        require(_postType == 1 || _postType == 2, "Post type must be either 1 or 2");
        if(_postType == 1){
            uint numberOfComments = Creators[_creatorId].CreatorTextPosts[_postId].comments;
            Creators[_creatorId].CreatorTextPosts[_postId].PostComments[numberOfComments].text = _text;
            Creators[_creatorId].CreatorTextPosts[_postId].PostComments[numberOfComments].user = msg.sender;
            Creators[_creatorId].CreatorTextPosts[_postId].comments++;
        }
        else if(_postType == 2) {
            uint numberOfComments = Creators[_creatorId].CreatorMediaPosts[_postId].comments;
            Creators[_creatorId].CreatorMediaPosts[_postId].PostComments[numberOfComments].text = _text;
            Creators[_creatorId].CreatorMediaPosts[_postId].PostComments[numberOfComments].user = msg.sender;
            Creators[_creatorId].CreatorMediaPosts[_postId].comments++;
        }
    }

    function getNumberOfCreators () public view returns (uint)  {
        return numberOfCreators;
    }

    function getNumberOfTextPostsByCreator(uint _creatorId) public view returns (uint) {
        return Creators[_creatorId].textPosts;
    }

    function getNumberOfMediaPostsByCreator(uint _creatorId) public view returns (uint) {
        return Creators[_creatorId].mediaPosts;
    }

    function getNumberOfComments(uint _creatorId, uint _postId, uint _postType) public view returns (uint) {
        require(_postType == 1 || _postType == 2, "Post type must be either 1 or 2");
        uint count;
        if(_postType == 1) {
            count = Creators[_creatorId].CreatorTextPosts[_postId].comments;
        } else if (_postType == 2) {
            count = Creators[_creatorId].CreatorMediaPosts[_postId].comments;
        }
        return count;
    }

    function getProfileInfo (uint _creatorId) public view returns (string memory, string memory, string memory, string memory) {
        string memory _profile = Creators[_creatorId].profile;
        string memory _metadata = Creators[_creatorId].metadata;
        string memory _avatar = Creators[_creatorId].avatar;
        string memory _banner = Creators[_creatorId].banner;
        return (_profile, _metadata, _avatar, _banner);
    }

    function getTextPostInfo(uint _creatorId, uint _postId) public view returns(string memory) {
        return Creators[_creatorId].CreatorTextPosts[_postId].text;
    }

    function getMediaPostInfo(uint _creatorId, uint _postId) public view returns(string memory, string memory) {
        return (Creators[_creatorId].CreatorMediaPosts[_postId].text, Creators[_creatorId].CreatorMediaPosts[_postId].mediaHash);
    }

    function getPostComments(uint _creatorId, uint _postId, uint _postType, uint _commentId) public view returns (address, string memory) {
        require(_postType == 1 || _postType == 2, "Post type must be either 1 or 2");
        address _sender;
        string memory _text;
        if(_postType == 1) {
            _sender = Creators[_creatorId].CreatorTextPosts[_postId].PostComments[_commentId].user;
            _text = Creators[_creatorId].CreatorTextPosts[_postId].PostComments[_commentId].text;
        } else if(_postType == 2) {
            _sender = Creators[_creatorId].CreatorMediaPosts[_postId].PostComments[_commentId].user;
            _text = Creators[_creatorId].CreatorMediaPosts[_postId].PostComments[_commentId].text;
        }
        return (_sender, _text);
    }

}