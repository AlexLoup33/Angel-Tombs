extends CharacterBody3D

const SPEED : float = 5.0
const JUMP_VELOCITY : float = 4.5

@onready var Camera = $Camera
@onready var InteractionBox = $Interaction/InteractionBox
@onready var MessageTimer = $Timer
@onready var MessageLabel = $Label3D

var message = false

#Sensibilité de la souris
var mouse_sensitivity : float = 0.06 

#Inventaire du joueur
var inventory = {
	"gemme" : 0,
	"key" : 0
	#Ajouter autre éléments d'inventaire selon le jeu
}

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	InteractionBox.disabled = true

func _physics_process(delta):
	# Gestion de la gravité
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if message :
		if MessageTimer.is_stopped() or MessageTimer.paused:
			MessageTimer.start(3)
			MessageLabel.show()
	else :
		MessageLabel.hide()
	# Gestion du saut
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	#Gestion de la boite de collision pour les interactions avec les autres objets
	if Input.is_action_just_pressed("interact"):
		InteractionBox.disabled = false
	else :
		InteractionBox.disabled = true
	
	#Gestion du mouvement du personnage
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		Camera.rotate_x(-event.relative.y * mouse_sensitivity)
		Camera.rotation.x = clampf(Camera.rotation.x, -deg_to_rad(70), deg_to_rad(70))

#TODO : Fonction qui affiche un message temporaire si le jeu effectue une action imcomplète
func _show_message(msg : String):
	MessageLabel.text = msg
	message = true

func _on_interaction_body_entered(body):
	if body.has_method("interact"):
		body.interact()
		_show_message("J'ai interagit avec " + body.name)
	if body.name == "Door":
		if body.lock == true:
			if inventory["key"] > 0:
				body.unlock()
				inventory["key"] -= 1
			else : 
				_show_message("Je dois trouver une clé !")
		else :
			body.change_state()

func _on_timer_timeout():
	message = false
