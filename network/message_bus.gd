## message_bus.gd 
## Define and publish communication events

## Currently autoload network_adaptor listens to some siganls inside message bus.
## it'll be network_adaptor's job to define "communicating up to server" behavior
## in such call backs.

## Global message bus autoload, containing the signals we might want to fire..
## Autoload name to be: MesB
class_name MessageBus
extends Node

## "detected one move from THIS client on position coord"
signal local_move_requested(coord: Vector2i)
