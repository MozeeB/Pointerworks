// ethers_glue.js — thin bridge between Godot (JavaScriptBridge) and ethers.js v6.
//
// Exposes `window.pointerworks`:
//   connect()                         -> async: prompt MetaMask, return {address, chainId}
//   disconnect()                      -> clear cached signer
//   isConnected()                     -> bool
//   getAddress()                      -> string | null
//   completeLevel(levelId, hashHex)   -> async: { txHash } or { error }
//
// Non-destructive — if ethers / MetaMask absent, methods no-op with error.
// Contract address is set via `window.POINTERWORKS_CONTRACT` BEFORE this
// script loads. Consumers may swap the address at runtime (e.g., from a
// query-param) without reloading.

(function () {
	"use strict";

	const ETHERS_CDN =
		"https://cdn.jsdelivr.net/npm/ethers@6/dist/ethers.umd.min.js";

	const ABI = [
		"function completeLevel(uint8 levelId, bytes32 hash) external",
		"function hasCompleted(address player, uint8 levelId) view returns (bool)",
		"function completedBitmap(address player) view returns (uint16)",
		"event LevelCompleted(address indexed player, uint8 indexed levelId, bytes32 hash, uint64 timestamp)",
	];

	const SEPOLIA_CHAIN_ID = 11155111n;

	let _provider = null;
	let _signer = null;
	let _address = null;
	let _contract = null;

	function _loadEthers() {
		return new Promise((resolve, reject) => {
			if (typeof window.ethers !== "undefined") {
				resolve(window.ethers);
				return;
			}
			const s = document.createElement("script");
			s.src = ETHERS_CDN;
			s.async = true;
			s.onload = () => resolve(window.ethers);
			s.onerror = () => reject(new Error("ethers.js failed to load"));
			document.head.appendChild(s);
		});
	}

	async function _ensureContract() {
		if (_contract) return _contract;
		const addr = window.POINTERWORKS_CONTRACT;
		if (!addr || addr === "0x0000000000000000000000000000000000000000") {
			throw new Error("POINTERWORKS_CONTRACT not configured");
		}
		if (!_signer) {
			throw new Error("wallet not connected");
		}
		const ethers = await _loadEthers();
		_contract = new ethers.Contract(addr, ABI, _signer);
		return _contract;
	}

	async function connect() {
		if (typeof window.ethereum === "undefined") {
			return { error: "no_wallet" };
		}
		try {
			const ethers = await _loadEthers();
			_provider = new ethers.BrowserProvider(window.ethereum);
			await _provider.send("eth_requestAccounts", []);
			_signer = await _provider.getSigner();
			_address = await _signer.getAddress();
			const net = await _provider.getNetwork();
			return { address: _address, chainId: Number(net.chainId) };
		} catch (e) {
			return { error: String(e && e.message ? e.message : e) };
		}
	}

	function disconnect() {
		_provider = null;
		_signer = null;
		_address = null;
		_contract = null;
	}

	function isConnected() {
		return _signer !== null && _address !== null;
	}

	function getAddress() {
		return _address;
	}

	async function completeLevel(levelId, hashHex) {
		try {
			const c = await _ensureContract();
			const tx = await c.completeLevel(levelId, hashHex);
			// Fire-and-forget confirm; caller can poll or subscribe.
			tx.wait().catch(() => {});
			return { txHash: tx.hash };
		} catch (e) {
			return { error: String(e && e.message ? e.message : e) };
		}
	}

	window.pointerworks = {
		connect: connect,
		disconnect: disconnect,
		isConnected: isConnected,
		getAddress: getAddress,
		completeLevel: completeLevel,
		SEPOLIA_CHAIN_ID: Number(SEPOLIA_CHAIN_ID),
	};
})();
