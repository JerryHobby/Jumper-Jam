extends Node

var google_payments = null
signal unlock_new_skin

func purchase_skin():
	unlock_new_skin.emit()

# https://docs.godotengine.org/en/stable/tutorials/platform/android/android_in_app_purchases.html
# https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html#exporting-for-google-play-store

var new_skin_sku = "new_player_skin"


func _ready():
	if Engine.has_singleton("GodotGooglePlayBilling"):
		google_payments = Engine.get_singleton("GodotGooglePlayBilling")
		
		google_payments.connected.connect(_on_connected)
		google_payments.disconnected.connect(_on_disconnected)
		google_payments.connect_error.connect(_on_connect_error)
		google_payments.sku_details_query_completed.connect(_on_sku_details_query_completed)
		google_payments.sku_details_query_error.connect(_sku_details_query_error)
		
		
		google_payments.startConnection()
		Log.write(Log.Type.DEBUG, "Loaded Google Payments")
	else:
		Log.write(Log.Type.DEBUG, "Google Payments disabled")


func _on_connected():
	Log.write(Log.Type.DEBUG, ">>> Google Payments connected")
	google_payments.querySkuDetails([new_skin_sku], "inapp")


func _on_disconnected():
	Log.write(Log.Type.DEBUG, "<<< Google Payments disconnected")


func _on_connect_error(response_id, error_msg):
	Log.write(Log.Type.ERROR, "*** Google Payments error %d: %s" % [response_id, error_msg])


func _on_sku_details_query_completed(skus:Array):
	Log.write(Log.Type.DEBUG, ">>> Google Payments SKU Query Completed")
	Log.write(Log.Type.DEBUG, ">>> SKUs found: %d" % skus.size())
	for sku in skus:
		Log.write(Log.Type.DEBUG, ">>> sku: %s" % sku)


func _sku_details_query_error(response_id:int, response_message:String, skus):
	for sku in skus:
		Log.write(Log.Type.ERROR, ">>> Google Payments SKU Query: [%s] error: %d: %s " \
		% [sku, response_id, response_message])
