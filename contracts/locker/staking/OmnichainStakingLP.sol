// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.20;

// ███████╗███████╗██████╗  ██████╗
// ╚══███╔╝██╔════╝██╔══██╗██╔═══██╗
//   ███╔╝ █████╗  ██████╔╝██║   ██║
//  ███╔╝  ██╔══╝  ██╔══██╗██║   ██║
// ███████╗███████╗██║  ██║╚██████╔╝
// ╚══════╝╚══════╝╚═╝  ╚═╝ ╚═════╝

// Website: https://zerolend.xyz
// Discord: https://discord.gg/zerolend
// Twitter: https://twitter.com/zerolendxyz

import {ILPOracle} from "../../interfaces/ILPOracle.sol";
import {IPythAggregatorV3} from "../../interfaces/IPythAggregatorV3.sol";
import {OmnichainStakingBase} from "./OmnichainStakingBase.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";

contract OmnichainStakingLP is OmnichainStakingBase {
    using SafeCast for int256;

    ILPOracle public oracleLP;
    IPythAggregatorV3 public oracleZERO;

    function init(
        address _locker,
        address _zeroToken,
        address _poolVoter,
        uint256 _rewardsDuration,
        address _lpOracle,
        address _zeroPythAggregator,
        address _owner,
        address _distributor
    ) external reinitializer(10) {
        super.__OmnichainStakingBase_init(
            "ZERO LP Voting Power", "ZEROvp-LP", _locker, _zeroToken, _poolVoter, _rewardsDuration, _distributor
        );

        oracleLP = ILPOracle(_lpOracle);
        oracleZERO = IPythAggregatorV3(_zeroPythAggregator);

        _transferOwnership(_owner);
    }

    receive() external payable {
        // accept eth in the contract
    }

    /**
     * Calculate voting power based on how much the LP token is worth in ZERO terms
     * @param amount The LP token amount
     */
    function _getTokenPower(uint256 amount) internal view override returns (uint256 power) {
        uint256 lpPrice = oracleLP.getPrice();
        uint256 zeroPrice = oracleZERO.latestAnswer().toUint256();
        require(zeroPrice > 0 && lpPrice > 0, "!price");
        power = ((lpPrice * amount) / zeroPrice);
    }
}
