extends Node
 
class_name IAPManagerV2
 
const ANDROID_BILLING_PLUGIN = "AndroidIAPP"
const IOS_BILLING_PLUGIN = "InAppStore"
 
signal unlock_new_skin

var google_payment = null
var pirate_player_skin_sku = "new_player_skin"
 

var apple_payment = null
var apple_pirate_player_skin_sku = "new_player_skin"



func _ready() -> void:
	if Engine.has_singleton(ANDROID_BILLING_PLUGIN):
		Log.write(Log.Type.DEBUG, "Android IAP support is enabled.")
		android_iap()
	else:
		Log.write(Log.Type.DEBUG, "Android IAP support is not available.")
	
	if Engine.has_singleton(IOS_BILLING_PLUGIN):
		Log.write(Log.Type.DEBUG, "iOS IAP support is enabled.")
		ios_iap()
	else:
		Log.write(Log.Type.DEBUG, "iOS IAP support is not available.")


func android_iap():
	google_payment = Engine.get_singleton(ANDROID_BILLING_PLUGIN)

	 
	# Connection information
	google_payment.startConnection.connect(_on_google_start_connection)
	google_payment.connected.connect(_on_google_connected)
	google_payment.disconnected.connect(_on_google_disconnected)
	 
	# Querying product details
	google_payment.query_product_details.connect(_on_google_query_product_details)
	google_payment.query_product_details_error.connect(_on_google_query_product_details_error)
	 
	google_payment.startConnection()


func ios_iap():
	# https://docs.godotengine.org/en/stable/tutorials/platform/ios/plugins_for_ios.html
	apple_payment = Engine.get_singleton(IOS_BILLING_PLUGIN)
	
	var result = apple_payment.request_product_info({"product_ids": [apple_pirate_player_skin_sku]})
	if result == OK:
		Log.write(Log.Type.DEBUG, "Apple IAP started product info request.")
		poll_apple_events()
	else:
		Log.write(Log.Type.ERROR, "Apple IAP failed to request product info.")


func poll_apple_events():
	Log.write(Log.Type.DEBUG, "Creating IAP Timer")
	var timer = Timer.new()
	timer.wait_time = 1
	add_child(timer)
	timer.timeout.connect(apple_check_events)
	timer.start()
	

func apple_check_events():
	Log.write(Log.Type.DEBUG, "Polling Apple")
	while apple_payment.get_pending_event_count() > 0:
		var event = apple_payment.pop_pending_event()
		if event.result == "ok":
			match event.type:
				"restore":
					Log.write(Log.Type.DEBUG, "Apple IAP restore event: %s" % event)
				"purchase":
					Log.write(Log.Type.DEBUG, "Apple IAP purchase event: %s" % event)
				"product_info":
					Log.write(Log.Type.DEBUG, "Apple IAP product info event: %s" % event)
		else:
			Log.write(Log.Type.ERROR, "Apple IAP event: %s" % event)
















func _on_google_query_product_details(response):
	Log.write(Log.Type.DEBUG, "*** Completed query")
	var product_list = response["product_details_list"]
	Log.write(Log.Type.DEBUG, ">>> Product List: %s" % str(product_list))
	for i in product_list.size():
		var product = product_list[i]
		Log.write(Log.Type.DEBUG, "Product:")
		Log.write(Log.Type.DEBUG, str(product))


func _on_google_query_product_details_error(error):
	Log.write(Log.Type.ERROR, "Product query error: %s" % str(error))
 

func _on_google_start_connection():
	Log.write(Log.Type.DEBUG, "Billing: start connection")
 

func _on_google_connected():
	Log.write(Log.Type.DEBUG, "Billing successfully connected")
	google_payment.queryProductDetails([pirate_player_skin_sku], "inapp")


func _on_google_disconnected():
	Log.write(Log.Type.DEBUG, "Billing disconnected")
 

func purchase_skin():
	unlock_new_skin.emit()
