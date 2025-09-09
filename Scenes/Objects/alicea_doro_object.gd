#Just a display piece duro for GUI and more.
extends Area2D

@onready var doroSprite = $AnimatedSprite2D

#The Particles System doesn't work at all?
@onready var confusedParticleEmitter = $ConfusedParticles
@onready var heartsParticleEmitter = $HeartsParticles
@onready var eatingParticleEmitter = $EatingParticles
@onready var sleepingParticleEmitter = $SleepingParticles

enum animations { Idle, Angy, ReallyAngy, Happie, Sad, SundayPillow, Eating, EvilLaugh }
@export_enum("Idle", "Angy", "ReallyAngy", "Happie", "Sad", "SundayPillow", "Eating", "EvilLaugh") var animationEnum: int = animations.Idle

enum particle {None, Confused, Eating, Sleeping, Hearts}
@export_enum("None", "Confused", "Eating", "Sleeping", "Hearts") var particlesEnum: int = particle.None : set = setParticles

var particlesReady: int = 0

func _ready() -> void:
	doroSprite.play(str(animations.keys().get(animationEnum)))
	
func _process(_delta: float) -> void:
	if particlesReady == 4:
		setParticles(particle.values().get(particlesEnum))
	
func setAnimation(newAnimation: animations) -> void:
	animationEnum = newAnimation
	doroSprite.set_frame(0)
	doroSprite.play(str(animations.keys().get(animationEnum)))
	
func setParticles(newParticleEnum) -> void:
	if not particlesReady == 4:
		return
	particlesEnum = newParticleEnum
	match particlesEnum:#TODO think of a better way maybe arrays or somthing.
		particle.Confused:
			confusedParticleEmitter.set_emitting(true)
			heartsParticleEmitter.set_emitting(false)
			eatingParticleEmitter.set_emitting(false)
			sleepingParticleEmitter.set_emitting(false)
		particle.Hearts:
			confusedParticleEmitter.set_emitting(false)
			heartsParticleEmitter.set_emitting(true)
			eatingParticleEmitter.set_emitting(false)
			sleepingParticleEmitter.set_emitting(false)
		particle.Confused:
			confusedParticleEmitter.set_emitting(false)
			heartsParticleEmitter.set_emitting(false)
			eatingParticleEmitter.set_emitting(true)
			sleepingParticleEmitter.set_emitting(false)
		particle.Sleeping:
			confusedParticleEmitter.set_emitting(false)
			heartsParticleEmitter.set_emitting(false)
			eatingParticleEmitter.set_emitting(false)
			sleepingParticleEmitter.set_emitting(true)
		particle.None:
			confusedParticleEmitter.set_emitting(false)
			heartsParticleEmitter.set_emitting(false)
			eatingParticleEmitter.set_emitting(false)
			sleepingParticleEmitter.set_emitting(false)


func _on_sleeping_particles_ready() -> void:
	particlesReady += 1

func _on_eating_particles_ready() -> void:
	particlesReady += 1

func _on_hearts_particles_ready() -> void:
	particlesReady += 1

func _on_confused_particles_ready() -> void:
	particlesReady += 1
