extends Node
 
class_name IAPManager
 
const ANDROID_BILLING_PLUGIN = "AndroidIAPP"
const IOS_BILLING_PLUGIN = "InAppStore"
 
signal unlock_new_skin

var google_payment = null
var pirate_player_skin_sku = "new_player_skin"

var apple_payment = null
var apple_pirate_player_skin_sku = "pirate_player_skin"


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
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


func purchase_skin():
	if google_payment:
		make_google_purchase(pirate_player_skin_sku)
	elif apple_payment:
		make_apple_purchase(apple_pirate_player_skin_sku)
	else:
		# no IAP - so FREE purchase
		unlock_new_skin.emit()


###################################################
### Apple IAP code

func ios_iap():
	# https://docs.godotengine.org/en/stable/tutorials/platform/ios/plugins_for_ios.html
	apple_payment = Engine.get_singleton(IOS_BILLING_PLUGIN)
	apple_payment.set_auto_finish_transaction(true)
	GameManager.onRestorePurchases.connect(onRestoreApplePurchases)
	
	var result = apple_payment.request_product_info({"product_ids": [apple_pirate_player_skin_sku]})
	if result == OK:
		Log.write(Log.Type.DEBUG, "Apple IAP started product info request.")
		start_polling_apple_events()
	else:
		Log.write(Log.Type.ERROR, "Apple IAP failed to request product info.")


func onRestoreApplePurchases():
	if not apple_payment:
		return
	
	var result = apple_payment.restore_purchases()
	if result == OK:
		Log.write(Log.Type.DEBUG, "Apple IAP restore purchases requested")
	else:
		Log.write(Log.Type.ERROR, "Apple IAP restore purchases failed: %s" % result)


func start_polling_apple_events():
	var timer = find_child("timer")
	#Log.write(Log.Type.DEBUG, "Creating IAP Timer")
	if timer:
		Log.write(Log.Type.DEBUG, "Timer already running. Resetting.")
		stop_polling_apple_events()

	timer = Timer.new()
	timer.wait_time = 1
	add_child(timer)
	timer.timeout.connect(apple_check_events)
	timer.start()


func stop_polling_apple_events():
	var timer = find_child("timer")
	#Log.write(Log.Type.DEBUG, "Creating IAP Timer")
	if timer:
		Log.write(Log.Type.DEBUG, "Timer running. Stopping.")
		timer.queue_free()


func apple_check_events():
	#Log.write(Log.Type.DEBUG, "Polling Apple")
	while apple_payment.get_pending_event_count() > 0:
		var event = apple_payment.pop_pending_event()
		if event.result == "ok":
			match event.type:
				"restore":
					if event.product_id == apple_pirate_player_skin_sku:
						unlock_new_skin.emit()
						Log.write(Log.Type.DEBUG, "Apple IAP restore event: %s [%s]" % [event.product_id, event.transaction_id])
					else:
						Log.write(Log.Type.ERROR, "Apple IAP UNKNOWN purchase restored: %s" % event)
				"purchase":
					if event.product_id == apple_pirate_player_skin_sku:
						Log.write(Log.Type.DEBUG, "Apple IAP purchase successful: %s" % event.product_id)
						unlock_new_skin.emit()
					else:
						Log.write(Log.Type.ERROR, "Apple IAP UNKNOWN purchase: %s" % event)
				"product_info":
					Log.write(Log.Type.DEBUG, "Apple IAP product info event: %s" % event)
					onRestoreApplePurchases()
		elif event.result == "completed":
			Log.write(Log.Type.DEBUG, "Apple IAP restore purchases completed")
		else:
			Log.write(Log.Type.ERROR, "Uncaught Apple IAP event: %s" % event)


func make_apple_purchase(product_id):
	var result = apple_payment.purchase({"product_id" : product_id})
	if result == OK:
		Log.write(Log.Type.DEBUG, "Apple product purchase result is OK. Making purchase...")
		# finish transaction in event loop
	else:
		Log.write(Log.Type.ERROR, "Apple product purchase failed.")


###################################################
### Android/Google Play code

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
	GameManager.onRestorePurchases.connect(onRestoreGooglePurchases)


func onRestoreGooglePurchases():
	google_payment.queryPurchases("inapp")
	Log.write(Log.Type.DEBUG, "Google IAP restore purchases requested")
	pass


func _on_google_query_product_details(response):
	Log.write(Log.Type.DEBUG, "*** Completed query")
	var product_list = response["product_details_list"]
	Log.write(Log.Type.DEBUG, ">>> Product List: %s" % str(product_list))
	for i in product_list.size():
		var product = product_list[i]
		Log.write(Log.Type.DEBUG, "Product:")
		Log.write(Log.Type.DEBUG, str(product))


func make_google_purchase(product_id):
		var response = google_payment.purchase(product_id)
		if response.status != OK:
			Log.write(Log.Type.ERROR, "Google Payment purchase failed.")
		else:
			unlock_new_skin.emit()


func _on_google_query_product_details_error(error):
	Log.write(Log.Type.ERROR, "Product query error: %s" % str(error))
 

func _on_google_start_connection():
	Log.write(Log.Type.DEBUG, "Billing: start connection")
 

func _on_google_connected():
	Log.write(Log.Type.DEBUG, "Billing successfully connected")
	google_payment.queryProductDetails([pirate_player_skin_sku], "inapp")


func _on_google_disconnected():
	Log.write(Log.Type.DEBUG, "Billing disconnected")
 
