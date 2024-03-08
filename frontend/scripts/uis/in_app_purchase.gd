extends HBoxContainer

enum ConnectionState {
	DISCONNECTED, # not yet connected to billing service or was already closed
	CONNECTING, # currently in process of connecting to billing service
	CONNECTED, # currently connected to billing service
	CLOSED, # already closed and shouldn't be used again
}
enum PurchaseState {
	UNSPECIFIED,
	PURCHASED,
	PENDING,
}

var isAndroid = false
var isIOS = false

var payment
var dictionary = {}

var in_app_store

const TOKEN_VALUE = [{"cost": 1, "tokens": 100000}, {"cost": 10, "tokens": 1200000}]

func _ready():
	if Engine.has_singleton("GodotGooglePlayBilling"):
		isAndroid = true
		payment = Engine.get_singleton("GodotGooglePlayBilling")

		payment.billing_resume.connect(_on_billing_resume) # No params
		payment.connected.connect(_on_connected) # No params
		#payment.disconnected.connect(_on_disconnected) # No params
		#payment.connect_error.connect(_on_connect_error) # Response ID (int), Debug message (string)
		payment.purchases_updated.connect(_on_purchases_updated) # Purchases (dictionary[])
		payment.purchase_error.connect(_on_purchase_error) # Response ID (int), Debug message (string)
		payment.product_details_query_completed.connect(_on_product_details_query_completed) # Products (dictionary[])
		payment.product_details_query_error.connect(_on_product_details_query_error) # Response ID (int), Debug message (string), Queried SKUs (string[])
		payment.purchase_consumed.connect(_on_purchase_consumed) # Purchase token (string)
		payment.purchase_consumption_error.connect(_on_purchase_consumption_error) # Response ID (int), Debug message (string), Purchase token (string)
		payment.query_purchases_response.connect(_on_query_purchases_response) # Purchases (dictionary[])

		payment.startConnection()
	else:
		print("Android IAP support is not enabled. Make sure you have enabled 'Gradle Build' and the GodotGooglePlayBilling plugin in your Android export settings! IAP will not work.")

	if Engine.has_singleton("InAppStore"):
		isIOS = true
		in_app_store = Engine.get_singleton("InAppStore")
		in_app_store.set_auto_finish_transaction(true)
	else:
		print("iOS IAP plugin is not available on this platform.")
		
	

func _on_connected():
	payment.querySkuDetails(["my_iap_item"], "inapp") # "subs" for subscriptions

func _on_billing_resume():
	if payment.getConnectionState() == ConnectionState.CONNECTED:
		_query_purchases()

func _on_product_details_query_completed(product_details):
	for available_product in product_details:
		print(available_product)

func _on_product_details_query_error(response_id, error_message, products_queried):
	print("on_product_details_query_error id:", response_id, " message: ",
			error_message, " products: ", products_queried)

func _query_purchases():
	payment.queryPurchases("inapp") # Or "subs" for subscriptions
	
func _on_query_purchases_response(query_result):
	if query_result.status == OK:
		for purchase in query_result.purchases:
			_process_purchase(purchase)
	else:
		print("queryPurchases failed, response code: ",
				query_result.response_code,
				" debug message: ", query_result.debug_message)
				
func _process_purchase(purchase):
	dictionary.put("order_id", purchase.getOrderId());
	dictionary.put("package_name", purchase.getPackageName());
	dictionary.put("purchase_state", purchase.getPurchaseState());
	dictionary.put("purchase_time", purchase.getPurchaseTime());
	dictionary.put("purchase_token", purchase.getPurchaseToken());
	dictionary.put("quantity", purchase.getQuantity());
	dictionary.put("signature", purchase.getSignature());
	#// PBL V4 replaced getSku with getSkus to support multi-sku purchases,
	#// use the first entry for "sku" and generate an array for "skus"
	#ArrayList<String> skus = purchase.getSkus();
	#dictionary.put("sku", skus.get(0)); # Not available in plugin
	#String[] skusArray = skus.toArray(new String[0]);
	#dictionary.put("products", productsArray);
	dictionary.put("is_acknowledged", purchase.isAcknowledged());
	dictionary.put("is_auto_renewing", purchase.isAutoRenewing());
	
	if "my_consumable_iap_item" in purchase.products and purchase.purchase_state == PurchaseState.PURCHASED:
		 #Add code to store payment so we can reconcile the purchase token
		 #in the completion callback against the original purchase
		payment.consumePurchase(purchase.purchase_token)

func _on_purchase(item):
	payment.purchase(item)

func _on_purchases_updated(purchases):
	for purchase in purchases:
		_process_purchase(purchase)

func _on_purchase_error(response_id, error_message):
	print("purchase_error id:", response_id, " message: ", error_message)

func _on_purchase_consumed(purchase_token):
	_handle_purchase_token(purchase_token, true)

func _on_purchase_consumption_error(response_id, error_message, purchase_token):
	print("_on_purchase_consumption_error id:", response_id,
			" message: ", error_message)
	_handle_purchase_token(purchase_token, false)

# Find the sku associated with the purchase token and award the
# product if successful
func _handle_purchase_token(purchase_token, purchase_successful):
	# check/award logic, remove purchase from tracking list
	pass

# IOS 
func on_purchase_pressed():
	var result = in_app_store.purchase({ "product_id": "my_product" })
	if result == OK:
		pass

# put this on a 1 second timer or something
func check_events():
	while in_app_store.get_pending_event_count() > 0:
		var event = in_app_store.pop_pending_event()
		if event.type == "purchase":
			if event.result == "ok":
				event.product_id
