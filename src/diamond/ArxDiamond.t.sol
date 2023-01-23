// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import { IOwnableInternal } from "@solidstate/contracts/access/ownable/IOwnableInternal.sol";
import { IERC173Internal } from "@solidstate/contracts/interfaces/IERC173Internal.sol";
import { IDiamondWritableInternal } from "@solidstate/contracts/proxy/diamond/writable/IDiamondWritableInternal.sol";
import { IERC721 } from "@solidstate/contracts/interfaces/IERC721.sol";
import { IArxDiamond, IDiamondFallback, IDiamondWritable, IDiamondReadable, IERC165, ISafeOwnable, IOwnable, IERC173 } from "./IArxDiamond.sol";
import { ArxERC721Mock } from "../mock/ArxERC721Mock.sol";
import { ArxDiamondMock } from "../mock/ArxDiamondMock.sol";
import { TestUtils } from "@test/TestUtils.sol";

contract ArxDiamondTest is Test, TestUtils, IERC173Internal, IDiamondWritableInternal {
    address public immutable owner = address(1);

    ArxDiamondMock public mock;
    IArxDiamond public diamond;
    IERC173 public ownable;
    ArxERC721Mock public erc721;
    ArxERC721Mock public erc721_2;

    function setUp() public {
        mock = new ArxDiamondMock(owner);
        diamond = IArxDiamond(payable(mock));
        ownable = IERC173(address(mock));
        erc721 = new ArxERC721Mock("test", "TEST", "");
        erc721_2 = new ArxERC721Mock("test", "TEST", "");
    }

    //::DiamondBase::#fallback()


    //::DiamondReadable::#facets()
    function testFacetFacetsLength() public {
        emit log("DiamondReadable::#facets()");
        IArxDiamond.Facet[] memory facets = diamond.facets();
        assertEq(facets.length, 1);
    }

    //::DiamondReadable::#facets()
    function testFacetSelectors() public {
        emit log("DiamondReadable::#facets()");
        IArxDiamond.Facet[] memory facets = diamond.facets();
        _facetFunctionSelectors(facets[0].selectors);
    }

     //::DiamondReadable::#facetAddresses()
    function testFacetAddresses() public {
        emit log("DiamondReadable::#facetAddresses()");
        address[] memory addresses = diamond.facetAddresses();
        assertEq(addresses.length, 1);
        assertEq(addresses[0], address(diamond));
    }

    //::DiamondReadable::#facetAddress(bytes4)
    function testFacetAddres() public {
        emit log("DiamondReadable::#facetAddress(bytes4)");
        bytes4[] memory selectors = diamond.facetFunctionSelectors(address(diamond));
        for (uint i=0; i< selectors.length; i++) {
            assertEq(diamond.facetAddress(selectors[i]), address(diamond));
        }
    }

    //::DiamondReadable::#facetFunctionSelectors(address)
    function testFacetFunctionSelectors() public {
        emit log("DiamondReadable::#facetFunctionSelectorsaddress()");
        bytes4[] memory selectors = diamond.facetFunctionSelectors(address(diamond));
        _facetFunctionSelectors(selectors);
        
    }

    //::DiamondWritable::#diamondCut((address,enum,bytes4[])[],address,bytes)
    // ADD
    function testDiamondCut() public {
        emit log("DiamondWritable::#diamondCut((address,enum,bytes4[])[],address,bytes)");
        bytes4[] memory selectors = new bytes4[](9);
        uint256 selectorIndex;

        selectors[selectorIndex++] = IERC721.balanceOf.selector;
        selectors[selectorIndex++] = IERC721.ownerOf.selector;
        selectors[selectorIndex++] = IERC721.transferFrom.selector;
        selectors[selectorIndex++] = IERC721.approve.selector;
        selectors[selectorIndex++] = IERC721.getApproved.selector;
        selectors[selectorIndex++] = IERC721.setApprovalForAll.selector;
        selectors[selectorIndex++] = IERC721.isApprovedForAll.selector;
        selectors[selectorIndex++] = erc721.mint.selector;
        selectors[selectorIndex++] = erc721.burn.selector;
        FacetCut[] memory facetCuts = new FacetCut[](1);

        facetCuts[0] = FacetCut({
            target: address(erc721),
            action: FacetCutAction.ADD,
            selectors: selectors
        });
        vm.prank(owner);
        diamond.diamondCut(facetCuts, ZERO, "");     
        vm.stopPrank();
        IArxDiamond.Facet[] memory facets = diamond.facets();
        assertEq(facets.length, 2);
        assertEq(facets[1].selectors.length, 9);
        assertEq(facets[1].target, address(erc721));
    }

    //::DiamondWritable::#diamondCut((address,enum,bytes4[])[],address,bytes)
    // ADD
    // Ownable__NotOwner
    function testExpertRevertDiamondCutNonOwner() public {
        emit log("DiamondWritable::#diamondCut((address,enum,bytes4[])[],address,bytes), Ownable__NotOwner");
        bytes4[] memory selectors = new bytes4[](1);

        selectors[0] = IERC721.balanceOf.selector;
        FacetCut[] memory facetCuts = new FacetCut[](1);

        facetCuts[0] = FacetCut({
            target: address(2),
            action: FacetCutAction.ADD,
            selectors: selectors
        });
        vm.expectRevert(IOwnableInternal.Ownable__NotOwner.selector);
        diamond.diamondCut(facetCuts, ZERO, "");     
    }

    //::DiamondWritable::#diamondCut((address,enum,bytes4[])[],address,bytes)
    // REPLACE
    // using FacetCutAction REPLACE
    function testDiamondCutReplaceSelector() public {
        emit log("DiamondWritable::#diamondCut((address,enum,bytes4[])[],address,bytes), Ownable__NotOwner");
        bytes4[] memory selectors = new bytes4[](2);

        selectors[0] = IERC721.balanceOf.selector;
        FacetCut[] memory facetCuts = new FacetCut[](1);

        facetCuts[0] = FacetCut({
            target: address(erc721),
            action: FacetCutAction.ADD,
            selectors: selectors
        });
        vm.prank(owner);
        diamond.diamondCut(facetCuts, ZERO, ""); 
        selectors[0] = IERC721.balanceOf.selector;
        facetCuts[0] = FacetCut({
            target: address(erc721_2),
            action: FacetCutAction.REPLACE,
            selectors: selectors
        });
        vm.prank(owner);
        diamond.diamondCut(facetCuts, ZERO, ""); 
        vm.stopPrank();
    }

    //::DiamondWritable::#diamondCut((address,enum,bytes4[])[],address,bytes)
    // ADD
    // DiamondWritable__TargetHasNoCode
    function testExpectRevertDiamondCutTargetNoCode() public {
        emit log("DiamondWritable::#diamondCut((address,enum,bytes4[])[],address,bytes), DiamondWritable__TargetHasNoCodeDiamondWritable__TargetHasNoCode");
        bytes4[] memory selectors = new bytes4[](1);
        uint256 selectorIndex;

        selectors[selectorIndex++] = IERC721.balanceOf.selector;
        FacetCut[] memory facetCuts = new FacetCut[](1);

        facetCuts[0] = FacetCut({
            target: ZERO,
            action: FacetCutAction.ADD,
            selectors: selectors
        });
        vm.prank(owner);
        vm.expectRevert(IDiamondWritableInternal.DiamondWritable__TargetHasNoCode.selector);
        diamond.diamondCut(facetCuts, ZERO, "");     
        vm.stopPrank();
    }

    //::DiamondWritable::#diamondCut((address,enum,bytes4[])[],address,bytes)
    // REPLACE
    // DiamondWritable__SelectorNotFound
    function testExpectRevertDiamondCutReplaceSelectorSelectorNotFound() public {
        emit log("DiamondWritable::#diamondCut((address,enum,bytes4[])[],address,bytes), DiamondWritable__SelectorNotFound");
        bytes4[] memory selectors = new bytes4[](2);

        selectors[0] = IERC721.balanceOf.selector;
        FacetCut[] memory facetCuts = new FacetCut[](1);

        facetCuts[0] = FacetCut({
            target: address(erc721),
            action: FacetCutAction.ADD,
            selectors: selectors
        });
        vm.prank(owner);
        diamond.diamondCut(facetCuts, ZERO, ""); 
        selectors[0] = IERC721.ownerOf.selector;
        facetCuts[0] = FacetCut({
            target: address(erc721_2),
            action: FacetCutAction.REPLACE,
            selectors: selectors
        });
        vm.prank(owner);
        vm.expectRevert(IDiamondWritableInternal.DiamondWritable__SelectorNotFound.selector);
        diamond.diamondCut(facetCuts, ZERO, ""); 
        vm.stopPrank();
    }

    //::DiamondWritable::#diamondCut((address,enum,bytes4[])[],address,bytes)
    // REPLACE
    // DiamondWritable__SelectorNotFound
    function testExpectRevertDiamondCutSelectorNotFound() public {
        emit log("DiamondWritable::#diamondCut((address,enum,bytes4[])[],address,bytes), DiamondWritable__SelectorNotFound");
        bytes4[] memory selectors = new bytes4[](2);

        selectors[0] = IERC721.balanceOf.selector;
        FacetCut[] memory facetCuts = new FacetCut[](1);

        facetCuts[0] = FacetCut({
            target: address(mock),
            action: FacetCutAction.REPLACE,
            selectors: selectors
        });
        vm.prank(owner);
        vm.expectRevert(IDiamondWritableInternal.DiamondWritable__SelectorNotFound.selector);
        diamond.diamondCut(facetCuts, ZERO, ""); 
        vm.stopPrank();
    }

    //::DiamondWritable::#diamondCut((address,enum,bytes4[])[],address,bytes)
    // REPLACE
    // DiamondWritable__SelectorIsImmutable
    function testExpectRevertDiamondCutSelectorIsImmutable() public {
        emit log("DiamondWritable::#diamondCut((address,enum,bytes4[])[],address,bytes), DiamondWritable__SelectorIsImmutable");
        bytes4[] memory selectors = new bytes4[](2);

        selectors[0] = IERC721.balanceOf.selector;
        FacetCut[] memory facetCuts = new FacetCut[](1);

        facetCuts[0] = FacetCut({
            target: address(mock),
            action: FacetCutAction.ADD,
            selectors: selectors
        });
        vm.prank(owner);
        
        diamond.diamondCut(facetCuts, ZERO, ""); 

        facetCuts[0] = FacetCut({
            target: address(mock),
            action: FacetCutAction.REPLACE,
            selectors: selectors
        });
        vm.prank(owner);
        vm.expectRevert(IDiamondWritableInternal.DiamondWritable__SelectorIsImmutable.selector);
        diamond.diamondCut(facetCuts, ZERO, ""); 
        vm.stopPrank();
    }

    //::DiamondWritable::#diamondCut((address,enum,bytes4[])[],address,bytes)
    // REMOVE
    function testDiamondCutRemove() public {
        emit log("DiamondWritable::#diamondCut((address,enum,bytes4[])[],address,bytes)");
        bytes4[] memory selectors = new bytes4[](1);
        uint256 selectorIndex;

        selectors[selectorIndex++] = IERC721.balanceOf.selector;
        FacetCut[] memory facetCuts = new FacetCut[](1);

        facetCuts[0] = FacetCut({
            target: address(erc721),
            action: FacetCutAction.ADD,
            selectors: selectors
        });
        vm.prank(owner);
        diamond.diamondCut(facetCuts, ZERO, "");

        facetCuts[0] = FacetCut({
            target: address(0),
            action: FacetCutAction.REMOVE,
            selectors: selectors
        });
        vm.prank(owner);
        diamond.diamondCut(facetCuts, ZERO, "");   
        vm.stopPrank();
        IArxDiamond.Facet[] memory facets = diamond.facets();
        assertEq(facets.length, 1);
    }

     //::DiamondWritable::#diamondCut((address,enum,bytes4[])[],address,bytes)
    // REMOVE
    // DiamondWritable__RemoveTargetNotZeroAddress
    function testExpectRevertDiamondCutRemove() public {
        emit log("DiamondWritable::#diamondCut((address,enum,bytes4[])[],address,bytes), DiamondWritable__RemoveTargetNotZeroAddress");
        bytes4[] memory selectors = new bytes4[](1);
        uint256 selectorIndex;

        selectors[selectorIndex++] = IERC721.balanceOf.selector;
        FacetCut[] memory facetCuts = new FacetCut[](1);

        facetCuts[0] = FacetCut({
            target: address(erc721),
            action: FacetCutAction.ADD,
            selectors: selectors
        });
        vm.prank(owner);
        diamond.diamondCut(facetCuts, ZERO, "");

        facetCuts[0] = FacetCut({
            target: address(erc721),
            action: FacetCutAction.REMOVE,
            selectors: selectors
        });
        vm.prank(owner);
        vm.expectRevert(IDiamondWritableInternal.DiamondWritable__RemoveTargetNotZeroAddress.selector);
        diamond.diamondCut(facetCuts, ZERO, "");   
        vm.stopPrank();
    }

    //::ERC165::#supportsInterface(bytes4)
    function testSupportsInterface() public {
        emit log("ERC165::#supportsInterface(bytes4)");
        assertEq(diamond.supportsInterface(0x01ffc9a7), true);
    }

    //::ERC165::#supportsInterface(bytes4)
    // function testReturnFalseUnknownInterface(bytes4 interfaceByte) public {
    //     emit log("ERC165::#supportsInterface(bytes4)");
    //     bytes4[] memory selectors = diamond.facetFunctionSelectors(address(diamond));
    //     vm.assume(interfaceByte != 0x01ffc9a7);
    //     for (uint i=0; i< selectors.length; i++) {
    //         assertEq(diamond.facetAddress(selectors[i]), address(diamond));
    //         vm.assume(interfaceByte != selectors[i]);
    //     }
    //     assertEq(diamond.supportsInterface(interfaceByte), false);
    // }

     // ArxDiamond transfer ethers
    function testAcceptEtherViaTransfer(uint112 amount) public {
        vm.assume(amount > 0);
        vm.deal(owner, amount);
        vm.prank(owner);
        payable(diamond).transfer(amount);
        assertEq(address(diamond).balance, amount);
    }

    // ArxDiamond send ethers
    function testAcceptEtherViaSend(uint112 amount) public {
        vm.assume(amount > 0);
        vm.deal(owner, amount);
        vm.prank(owner);
        assert(payable(diamond).send(amount));
        assertEq(address(diamond).balance, amount);
    }

    // ArxDiamond sending ethers with call
    function testAcceptEtherViaCall(uint112 amount) public {
        vm.assume(amount > 0);
        vm.deal(owner, amount);
        vm.prank(owner);
        (bool sent, ) = payable(diamond).call{value: amount}("");
        assert(sent);
        assertEq(address(diamond).balance, amount);
    }

    //::ArxDiamond::#_getImplementation()
    function testInternalGetImplementation() public {
        emit log("::ArxDiamond::#_getImplementation()");
        assertEq(mock.__getImplementation(), diamond.getFallbackAddress());
    }

    // ArxDiamond __transferOwnership
    function testInternalTransferOwnership(address newOwner) public {
        mock.__transferOwnership(newOwner);
        assertEq(diamond.nomineeOwner(), newOwner);
    }

    //::ArxDiamond::Ownable::#owner()
    function testOwner() public {
        //emit log("::Ownable::#owner()");
        assertEq(ownable.owner(), owner);
    }

    //::ArxDiamond::SafeOwnable.#nomineeOwner()
    function testNomineeOwner() public {
        emit log("SafeOwnable::#nomineeOwner()");
        assertEq(diamond.nomineeOwner(), ZERO);
    }

    //::ArxDiamond::SafeOwnable::#transferOwnership(address)
    function testTransferOwnership(address newOwner) public {
        emit log("SafeOwnable::#transferOwnership(address), does not set new owner");
        vm.prank(owner);
        diamond.transferOwnership(newOwner);
        vm.stopPrank();
        assertEq(diamond.nomineeOwner(), newOwner);
        assertEq(ownable.owner(), owner);
    }

    //::ArxDiamond::SafeOwnable::#transferOwnership(address)
    // sender is not owner
    function testExpectRevertTransferOwnershipNotOwner(address newOwner) public {
        emit log("SafeOwnable::#transferOwnership(address), sender is not owner");
        address alice = address(2);
        vm.prank(alice);
        vm.expectRevert(IOwnableInternal.Ownable__NotOwner.selector);
        diamond.transferOwnership(newOwner);
        vm.stopPrank();
    
    }

    //::ArxDiamond::SafeOwnable::#acceptOwnership
    function testAcceptOwnership(address newOwner) public {
        emit log("SafeOwnable::#acceptOwnership()");
        vm.prank(owner);
        diamond.transferOwnership(newOwner);
        vm.stopPrank();
        assertEq(diamond.nomineeOwner(), newOwner);
        vm.prank(newOwner);
        diamond.acceptOwnership();
        vm.stopPrank();
        assertEq(ownable.owner(), newOwner);
    }

    //::ArxDiamond::SafeOwnable::#acceptOwnership
    // emit OwnershipTransferred()
    function testExpectEmitAcceptOwnership(address newOwner) public {
        emit log("SafeOwnable::#acceptOwnership(), emit OwnershipTransferred()");
        vm.prank(owner);
        diamond.transferOwnership(newOwner);
        vm.stopPrank();
        assertEq(diamond.nomineeOwner(), newOwner);
        vm.prank(newOwner);
        vm.expectEmit(true, true, false, false);
        diamond.acceptOwnership();
        emit OwnershipTransferred(owner, newOwner);
        vm.stopPrank();
        assertEq(ownable.owner(), newOwner);
    }

    function _facetFunctionSelectors(bytes4[] memory selectors) internal {
        assertEq(selectors.length, 12);

        // registered DiamondFallback
        assertEq(selectors[0], IDiamondFallback
            .getFallbackAddress
            .selector);

        assertEq(selectors[1], IDiamondFallback
            .setFallbackAddress
            .selector);

        // registered DiamondWritable
        assertEq(selectors[2], IDiamondWritable
            .diamondCut
            .selector);

        // registered DiamondReadable
        assertEq(selectors[3], IDiamondReadable.facets.selector);
        assertEq(selectors[4], IDiamondReadable
            .facetFunctionSelectors
            .selector);
        assertEq(selectors[5], IDiamondReadable.facetAddresses.selector);
        assertEq(selectors[6], IDiamondReadable.facetAddress.selector);

        // registered ERC165
        assertEq(selectors[7], IERC165.supportsInterface.selector);

        // registered SafeOwnable
        assertEq(selectors[8], IERC173.owner.selector);
        assertEq(selectors[9], ISafeOwnable.nomineeOwner.selector);
        assertEq(selectors[10], IERC173.transferOwnership.selector);
        assertEq(selectors[11], ISafeOwnable.acceptOwnership.selector);
    }
}
