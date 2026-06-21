extends Resource

class_name ProjectileSpec

## In units/sec for standard projectiles, total distance for hitscan
@export var distance : float = 10

## Controls how many ricochets can occur
@export var max_ricochets : int = 1

## A projectile weapon produces projectiles that travel through space
@export var projectile_scene : PackedScene
