extends Node
@onready var parent = get_parent()
@onready var shieldNode = parent.get_node("shieldContainer")
var shieldScene = preload("res://scenes/shield.tscn")
@export var health : int = 0
@export var particle : PackedScene
var level : int = 1
var toNextLevel : int = 3
var levelPts : int = 0
var shieldCount = 0
var shield = []
var r1 = 40
var r2 = 70
var r3 = 100
var r4 = 130
var s1 = 2
var s2 = 2
var s3 = 2
var s4 = 2
var pickedAugments = []
var totalAugmentNum = 2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func loseHp():
	var aParticle = particle.instantiate()
	aParticle.position.x = get_parent().position.x
	aParticle.position.y = get_parent().position.y
	aParticle.emitting = true
	aParticle.modulate = Color(1, 1, 1)
	get_tree().current_scene.add_child(aParticle)
	if shieldCount <= 0:
		return  # No shields to remove.
	health -= 1
	shieldCount -= 1
	$loseShell.play()
	var removed_shield = shield.pop_back()  # This removes and returns the last element.
	shieldNode.remove_child(removed_shield)

func add_shield():
	var newShield = shieldScene.instantiate()
	if shieldCount == 0:
		newShield.angle = 0
		newShield.radius = r1
		newShield.speed = s1
	elif shieldCount < 2:
		newShield.angle = shieldNode.get_child(shieldCount-1).angle +PI
		newShield.radius = r1
		newShield.speed = s1
	elif shieldCount < 10:
		newShield.angle = shieldNode.get_child(shieldCount-1).angle +2*PI/8
		newShield.radius = r2
		newShield.speed = s2
	elif shieldCount < 18:
		newShield.angle = shieldNode.get_child(shieldCount-1).angle +2*PI/8
		newShield.radius = r3
		newShield.speed = s3
	elif shieldCount < 36:
		newShield.angle = shieldNode.get_child(shieldCount-1).angle +2*PI/18
		newShield.radius = r4
		newShield.speed = s4
	else:
		return
	
	shield.append(newShield)
	shieldNode.add_child(shield[shieldCount])
	shieldCount+=1
var rng = RandomNumberGenerator.new()
func augment():
	var player = get_parent()
	var augmentNum = rng.randi_range(1,2)
	augmentNum =3
	if augmentNum == 1:
		if pickedAugments.has(augmentNum):
			augmentNum= (augmentNum+ 1)%totalAugmentNum
		if augmentNum == 1:
			player.augment1 = true
			$"../CanvasLayer/Label2".visible = true
			pickedAugments.append(1)
	if augmentNum == 2:
		if pickedAugments.has(augmentNum):
			augmentNum= (augmentNum+ 1)%totalAugmentNum
		if augmentNum == 2:
			player.get_parent().get_node("Line2D").queue_free()
			player.augment2 = true
			$"../CanvasLayer/Label".visible = true
			pickedAugments.append(2)
	if augmentNum == 3:
		if pickedAugments.has(augmentNum):
			augmentNum= (augmentNum+ 1)%totalAugmentNum
		if augmentNum == 3:
			player.get_parent().spawn_lasers()
			$"../CanvasLayer/Label3".visible = true
			pickedAugments.append(3)
func levelUp():
	level += 1
	health += 1
	toNextLevel = round(toNextLevel * 1.5)
	levelPts = 0
	add_shield()
	if level%3==0:
		augment()
		
func takeDMG():
	if health == 0:
		$dead.play()
		get_parent().visible = false
		await get_tree().create_timer(0.4).timeout
		queue_free()
	loseHp()
func pickUp():
	if levelPts == toNextLevel:
		levelUp()
		$"level up".play()
	else:
		levelPts += 1
		$collect.play()
		
func _exit_tree() -> void:
	# This code will run before the node is removed.
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	# You can trigger additional logic here.

func _on_pickup_area_area_entered(area: Area2D) -> void:
	pickUp()
	var h = area.get_parent()
	var aParticle = particle.instantiate()
	aParticle.position.x = h.position.x
	aParticle.position.y = h.position.y
	aParticle.emitting = true
	get_tree().current_scene.add_child(aParticle)
	h.queue_free()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	takeDMG()
