extends Node

static var DEFAULT_CLOUD_SAVES_FILE_NAME: String = "saves_ids"

signal user_authentificated_checked
signal cloud_to_local_synchronized(new_save_id : int)
#key: save 'unique_name'
#value: save 'cloud_id'
var cloud_saves_ids = {}
var is_user_authentificated : bool = false:
	set(value):
		is_user_authentificated = value
		user_authentificated_checked.emit()
var is_first_login_ever : bool:
	set(value):
		is_first_login_ever = value

		

func _init():
	_connect_signals()
	SignInClient.is_authenticated()



func _connect_signals():
	SignInClient.user_authenticated.connect(_get_online_status)
	SnapshotsClient.game_loaded.connect(_on_game_loaded)
	SnapshotsClient.game_saved.connect(_on_game_saved)
	SnapshotsClient.snapshots_loaded.connect(_on_snapshots_loaded)
	
	
func _get_online_status(is_authenticated: bool):
	#first time and online
	is_user_authentificated = is_authenticated
	print("user authentificate status: "+str(is_authenticated))
	
	
func load_saves_from_cloud():
	SnapshotsClient.load_snapshots(true)

	
func _on_snapshots_loaded(snapshots: Array[SnapshotsClient.SnapshotMetadata]):
	for snapshot in snapshots:
		cloud_saves_ids[snapshot.unique_name] = snapshot.snapshot_id
	if Configurator.is_sync_already_choosen == true:
		return
	Configurator.is_sync_already_choosen = true
	if snapshots.size()==0:
		print("First login ever")
		return
	print("Not first login ever")
	sync_all_from_cloud_to_local(snapshots)
	

func _on_game_saved(is_saved: bool, save_data_name: String, save_data_description: String):
	if not is_saved:
		printerr("file saves_ids not initialized")
	print("file saves_ids initialized successfully")	


func sync_all_from_cloud_to_local(snapshots: Array[SnapshotsClient.SnapshotMetadata]):
	SaveManager.delete_all_local_saves()
	for snapshot in snapshots:
		SnapshotsClient.load_game(snapshot.unique_name)
		

func _on_game_loaded(snapshot: SnapshotsClient.Snapshot):
	var string_content = snapshot.content.get_string_from_utf8()
	SaveManager.create_save_from_str(int(snapshot.metadata.unique_name),
		string_content)
	if(SaveManager.ALL_SAVES.size()==1):
		#Choose first existing save
		var save :SavedGame = SaveManager.ALL_SAVES[int(snapshot.metadata.unique_name)]
		Configurator.current_save_id = save.get_id()
		cloud_to_local_synchronized.emit()


func sync_all_from_local_to_cloud():
	var saves:Array[String] = []
	for int_local_save_id in SaveManager.ALL_SAVES.keys():
		var str_local_save_id : String =str(int_local_save_id)
		saves.append(str_local_save_id)
		SnapshotsClient.save_game(str_local_save_id, str_local_save_id,
		SaveManager.get_str_from_save(int_local_save_id).to_utf8_buffer(), 0, 0)

	

		
	

