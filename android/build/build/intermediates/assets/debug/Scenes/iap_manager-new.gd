extends Node
 
class_name IAPManagerV2
 
const ANDROID_BILLING_PLUGIN := "AndroidIAPP"
 
signal unlock_new_skin
 
var pirate_player_skin_sku = "new_player_skin"
 
var billing = null
 

func _ready() -> void:
	if Engine.has_singleton(ANDROID_BILLING_PLUGIN):
		billing = Engine.get_singleton(ANDROID_BILLING_PLUGIN)
		Log.write(Log.Type.DEBUG, "Android IAP support is enabled.")
		 
		# Connection information
		billing.startConnection.connect(_on_start_connection)
		billing.connected.connect(_on_connected)
		billing.disconnected.connect(_on_disconnected)
		 
		# Querying product details
		billing.query_product_details.connect(_on_query_product_details)
		billing.query_product_details_error.connect(_on_query_product_details_error)
		 
		billing.startConnection()
	else:
		Log.write(Log.Type.DEBUG, "Android IAP support is not activated.")


func _on_query_product_details(response):
	Log.write(Log.Type.DEBUG, "*** Completed query")
	var product_list = response["product_details_list"]
	#Log.write(Log.Type.DEBUG, ">>> Product List Size: %d" % product_list.size())
	Log.write(Log.Type.DEBUG, ">>> Product List: %s" % str(product_list))
	for i in product_list.size():
		var product = product_list[i]
		Log.write(Log.Type.DEBUG, "Product:")
		Log.write(Log.Type.DEBUG, str(product))


func _on_query_product_details_error(error):
	Log.write(Log.Type.ERROR, "Product query error: %s" % str(error))
 

func _on_start_connection():
	Log.write(Log.Type.DEBUG, "Billing: start connection")
 

func _on_connected():
	Log.write(Log.Type.DEBUG, "Billing successfully connected")
	billing.queryProductDetails([pirate_player_skin_sku], "inapp")


func _on_disconnected():
	Log.write(Log.Type.DEBUG, "Billing disconnected")
 

func purchase_skin():
	unlock_new_skin.emit()
