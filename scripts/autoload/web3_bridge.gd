extends Node
## Web3Bridge — stub for Ethereum integration (wired up Day 5).
##
## On Day 5 this is replaced with JavaScriptBridge calls into
## `scripts/web3/ethers_glue.js` to talk to MetaMask + the
## PointerworksAchievements contract on Sepolia. Until then, every
## public function returns a safe default and all gameplay works
## without the bridge.

signal wallet_connected(address: String)
signal wallet_disconnected
signal tx_pending(tx_hash: String)
signal tx_confirmed(tx_hash: String)
signal wallet_error(message: String)

var _address: String = ""


func is_connected() -> bool:
	return _address != ""


func get_address() -> String:
	return _address


func connect_wallet() -> void:
	# Day 5: invoke window.pointerworks.connect() via JavaScriptBridge.
	push_warning("Web3Bridge.connect_wallet called before Day 5 wiring — no-op.")


func disconnect_wallet() -> void:
	_address = ""
	wallet_disconnected.emit()


func complete_level(_level_id: int, _solution_hash: String) -> void:
	# Day 5: invoke window.pointerworks.completeLevel(id, hash).
	push_warning("Web3Bridge.complete_level called before Day 5 wiring — no-op.")
