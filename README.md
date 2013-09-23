# Hug
===
A Love2D wrapper for CoronaSDK.
Built for Love 0.8.0


### Main framework differences
CoronaSDK renders everything automatically, which Löve2D does not. To solve this
all objects created are put into the hug.graphics[] table, which is rendered via
the hug.drawGroup() function.


### Coding stucture
Unofficial functions should go in the `hug[ ]` table.
When unofficial properties are needed names start with underscore `obj._property`.


### Bugs
* Inserting an object into another group will cause duplicates (unless you manually remove it first).
* Changing or setting a new parent after creation will cause duplicate renders.
* Animation speed acting strange, can't seems to find the cause.


### To do
* More physics support: circleShape
* Try to make physics act more similar
* More EventListener functions
* Add Transition.to() support
* More alignment support
* Add text support

