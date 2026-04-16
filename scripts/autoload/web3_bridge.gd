extends Node
## Web3Bridge — Ethereum integration (Sepolia testnet).
##
## Day 5 wiring: bootstraps `scripts/web3/ethers_glue.js` into the browser
## document, then calls `window.pointerworks.*` via `JavaScriptBridge`.
## 100% skippable — if `OS.has_feature("web")` is false, if MetaMask isn't
## installed, or if the contract address is unset, every method no-ops
## gracefully and signals `wallet_error` with the reason.
##
## **Never blocks gameplay.** Local `Progress` is still marked complete
## whether or not the TX succeeds.

signal wallet_connected(address: String)
signal wallet_disconnected
signal tx_pending(tx_hash: String)
signal tx_confirmed(tx_hash: String)
signal wallet_error(message: String)

## Override via export preset's `html/head_include` or by editing the
## custom_html_shell.html file. Alternative: set at runtime via
## `Web3Bridge.set_contract_address()` (e.g., from a ?contract=... query).
const DEFAULT_CONTRACT_ADDRESS: String = "0x0000000000000000000000000000000000000000"
const GLUE_PATH: String = "res://scripts/web3/ethers_glue.js"

var _address: String = ""
var _bootstrapped: bool = false
var _poll_timer: Timer


func _ready() -> void:
	_poll_timer = Timer.new()
	_poll_timer.wait_time = 0.5
	_poll_timer.autostart = false
	_poll_timer.timeout.connect(_poll_connection_state)
	add_child(_poll_timer)

	if not OS.has_feature("web"):
		return
	_bootstrap_glue()


func _bootstrap_glue() -> void:
	if _bootstrapped:
		return
	if not _has_js_bridge():
		return

	# Read the glue source + eval it. Safer than a <script src=...> that
	# relies on HTML-shell edits which Godot export may overwrite.
	var file := FileAccess.open(GLUE_PATH, FileAccess.READ)
	if file == null:
		push_warning("Web3Bridge: glue not found at %s" % GLUE_PATH)
		return
	var src: String = file.get_as_text()
	file.close()

	var boot: String = "window.POINTERWORKS_CONTRACT = window.POINTERWORKS_CONTRACT || '%s';\n" % DEFAULT_CONTRACT_ADDRESS
	JavaScriptBridge.eval(boot + src, false)
	_bootstrapped = true


func set_contract_address(addr: String) -> void:
	# Allow runtime override (e.g., from URL query param, level data).
	if not _has_js_bridge():
		return
	JavaScriptBridge.eval("window.POINTERWORKS_CONTRACT = '%s';" % addr, false)


func is_wallet_connected() -> bool:
	return _address != ""


func get_address() -> String:
	return _address


func connect_wallet() -> void:
	if not _has_js_bridge():
		wallet_error.emit("web-only feature")
		return
	_bootstrap_glue()
	# ethers_glue.connect() is async — result lands in window.__pw_connect_result
	# which we poll below. Keep the JS snippet as a single expression so eval is safe.
	var snippet: String = "(async()=>{try{const r=await window.pointerworks.connect();window.__pw_connect_result=JSON.stringify(r);}catch(e){window.__pw_connect_result=JSON.stringify({error:String(e)});}})();"
	JavaScriptBridge.eval(snippet, false)
	_poll_timer.start()


func disconnect_wallet() -> void:
	if _has_js_bridge() and _bootstrapped:
		JavaScriptBridge.eval("window.pointerworks && window.pointerworks.disconnect();", false)
	_address = ""
	wallet_disconnected.emit()


## `solution_hash` must be a 0x-prefixed 32-byte hex string.
func complete_level(level_id: int, solution_hash: String) -> void:
	if not is_wallet_connected():
		wallet_error.emit("wallet not connected")
		return
	if not _has_js_bridge():
		wallet_error.emit("web-only feature")
		return
	var snippet: String = "(async()=>{try{const r=await window.pointerworks.completeLevel(%d,'%s');window.__pw_tx_result=JSON.stringify(r);}catch(e){window.__pw_tx_result=JSON.stringify({error:String(e)});}})();" % [level_id, solution_hash]
	JavaScriptBridge.eval(snippet, false)
	_poll_timer.start()


func _poll_connection_state() -> void:
	if not _has_js_bridge():
		_poll_timer.stop()
		return

	var conn_raw: Variant = JavaScriptBridge.eval("window.__pw_connect_result || ''", true)
	if typeof(conn_raw) == TYPE_STRING and (conn_raw as String) != "":
		JavaScriptBridge.eval("window.__pw_connect_result = '';", false)
		_handle_connect_result(conn_raw as String)

	var tx_raw: Variant = JavaScriptBridge.eval("window.__pw_tx_result || ''", true)
	if typeof(tx_raw) == TYPE_STRING and (tx_raw as String) != "":
		JavaScriptBridge.eval("window.__pw_tx_result = '';", false)
		_handle_tx_result(tx_raw as String)

	if _address == "" and not _has_pending_work():
		_poll_timer.stop()


func _has_pending_work() -> bool:
	if not _has_js_bridge():
		return false
	var c: Variant = JavaScriptBridge.eval("window.__pw_connect_result || ''", true)
	var t: Variant = JavaScriptBridge.eval("window.__pw_tx_result || ''", true)
	return (typeof(c) == TYPE_STRING and (c as String) != "") \
		or (typeof(t) == TYPE_STRING and (t as String) != "")


func _handle_connect_result(json: String) -> void:
	var parsed: Variant = JSON.parse_string(json)
	if typeof(parsed) != TYPE_DICTIONARY:
		wallet_error.emit("invalid connect response")
		return
	var d: Dictionary = parsed
	if d.has("error"):
		wallet_error.emit(str(d["error"]))
		return
	_address = str(d.get("address", ""))
	if _address != "":
		wallet_connected.emit(_address)


func _handle_tx_result(json: String) -> void:
	var parsed: Variant = JSON.parse_string(json)
	if typeof(parsed) != TYPE_DICTIONARY:
		wallet_error.emit("invalid tx response")
		return
	var d: Dictionary = parsed
	if d.has("error"):
		wallet_error.emit(str(d["error"]))
		return
	var h: String = str(d.get("txHash", ""))
	if h != "":
		tx_pending.emit(h)
		# ethers_glue calls tx.wait() internally but doesn't surface the
		# confirmed result via a marker var (kept small on purpose). For
		# MVP we treat 'submitted' as success — most players will check
		# Etherscan for the confirm.
		tx_confirmed.emit(h)


func _has_js_bridge() -> bool:
	# Only meaningful on web exports. On desktop JavaScriptBridge.eval
	# returns null without erroring, but we gate to be explicit.
	return OS.has_feature("web")
