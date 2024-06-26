// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/*
                                                                                          
                              _            _          _                       
             __      __  ___ (_) _ __   __| |  ___   | |__    __ _  ___   ___ 
             \ \ /\ / / / _ \| || '__| / _` | / _ \  | '_ \  / _` |/ __| / _ \
              \ V  V / |  __/| || |   | (_| || (_) | | |_) || (_| |\__ \|  __/
               \_/\_/   \___||_||_|    \__,_| \___/  |_.__/  \__,_||___/ \___|
                                                                 
                                                                                                                                                                                   
                                       .'``````^``'.                                      
                                  ."i)t\\||||||||\\tt|-;`.                                
                               ';{/||||||||||||||||||||||t?^                              
                             ^{t||||||||||||||||||||||||||||fl,,,,,,l!!;'                 
                           `)\||||/|\tft//\\||||||||||||/tf/t/c$$$$$$$$u1){I^`            
                       '^l/$#|||\\//[~-+{+)f\|||||||||\f/}}}/trM$$$$$$$@t~;,'             
               ^!tn*8@$$$$$$z||f\;'.'^`   ..,(||||||\t~`.    .`+@$$$$$$x+".               
           ',I_xuB$$$$$$$$$%|||t. -@$$$W'   .'j|||||/l.   >#8j" |$$&vj/~;`.               
          .'`,i/$$$$$$$$$$$n//|1. :n@$&\.   .,t|\|||||.   ]B$@>'I`.                       
          .````^{$$$$$$$$$$r|||/i` .. .    `-t|||||||||,`''^``i,                          
               """"""";1M$$u|||||\\}++->][/|||\||||||||||\ttt/f"                          
                         'u\||||||||||||||||\||||||||||||||||||]                          
                          {|||||||\|fnvczzz*cvunuxxxnuunnuunnr/t,                         
                          `r||||\/vWM#########################W#*,                        
                           `f||\tnW#####WuvWWMMMMMMMMMWWWWWW####W&                        
                            "j|/\/MM###M[>W##MMMMMMMMMM##########&'                       
                            `n|||||rzW#&`c####################MWzn                        
                            /v|||||||\ru/-8MMMWMMMMMMMWMMM#zvxt|/:                        
                           _rc||||||||||||||||\\\\\\\\\|||||||||j.                        
                         .}f|rf||||||||||||||t|ft||/|/\||||||||f,                         
                       .Ij\|||rf\|||||||||||||\t/\||/\\|||||||ti                          
                    .,[r\|||||||ffjff/||||||||||||||||||||||\/^                           
              .'`"{/j\|||||||||||||||/jffjft||||\/fxtj/\ff(~"                             
          `,ix|:  ."}t\||||||||||||||||||||/tc``````'''..                                 

*/

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


contract Weirdrop {

    // hardcoded address of weirdo, this helps saving gas on weirdrop calls
    address public weirdo = 0x76734B57dFe834F102fB61E1eBF844Adf8DD931e;

    /**
     * @notice Distributes a specified amount of WEIRDO tokens to a list of addresses.
     * @dev This function allows the sender to airdrop a fixed amount of WEIRDO tokens
     *      to multiple recipients in a single transaction, spreading the spirit of weirdness
     *      across the blockchain. The function utilizes `transferFrom` to move the tokens
     *      from the caller's balance to each recipient, ensuring that the caller has 
     *      approved the contract to handle their tokens.
     *      
     *      Embrace your inner weirdo! Each recipient in the array receives the same amount 
     *      of tokens, celebrating the unity and diversity of weirdos everywhere.
     *      
     * @param recipients An array of addresses that will receive the tokens.
     * @param value The amount of WEIRDO tokens each address will receive. The caller must
     *              have enough tokens and must have granted the contract sufficient allowance
     *              to distribute these tokens.
     */
    function weirdrop(address[] calldata recipients, uint256 value) external {

        // pre-calculate and store length to avoid multiple calls
        uint256 length = recipients.length;

        // pre-load the contract with all tokens required for the drop
        // to use transfer instead of transferFrom and save gas
        uint256 totalAmount = length * value;
        require(IERC20(weirdo).transferFrom(msg.sender, address(this), totalAmount), "Preload failed: Check allowance");

        // drop weirdness 
        for (uint256 i = 0; i < length; i++)
            require(IERC20(weirdo).transfer(recipients[i], value));
    }
    
    /**
    * @notice Distributes varying amounts of WEIRDO tokens to a list of addresses.
    * @dev This function allows the sender to airdrop varying amounts of WEIRDO tokens
    *      to multiple recipients in a single transaction. Unlike `weirdrop`, which distributes
    *      a fixed amount to all recipients, this function handles varied amounts per recipient.
    *      This is useful for custom distributions where each recipient may deserve a different
    *      amount of tokens based on specific criteria or contributions.
    *
    *      The function utilizes `transferFrom` directly for each recipient, pulling the specified
    *      amounts from the caller's balance to each recipient's address. The caller must have
    *      approved the contract to handle their tokens and ensure sufficient balance to cover
    *      the total sum of all specified amounts.
    *
    * @param recipients An array of addresses that will receive the tokens.
    * @param amounts An array of token amounts that each address in the recipients array will receive.
    *                There must be an equal number of recipients and amounts, and each index in the
    *                recipients array corresponds to the index in the amounts array.
    */
    function variableWeirdrop(address[] calldata recipients, uint256[] calldata amounts) external {
    uint256 length = recipients.length;
        for (uint256 i = 0; i < length; i++) {
        require(IERC20(weirdo).transferFrom(msg.sender, recipients[i], amounts[i]), "Transfer failed: Check balance and allowance");
        }
    }   
}
