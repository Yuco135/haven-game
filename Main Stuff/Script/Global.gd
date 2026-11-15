extends Node

var gameStarted = true

var playerWeaponEquip = true
var playerBody: CharacterBody2D
var playerAlive: bool
var playerHitbox: Area2D


var playerDamageZone: Area2D
var playerDamageAmount: int

var enemyDamageAmount: int
var enemyDamageZone = Area2D
