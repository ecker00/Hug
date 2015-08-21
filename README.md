# Hug

A CoronaSDK to Löve2D wrapper.
Built with Love 0.8.0 and CoronaSDK 2013.1202
https://www.youtube.com/watch?v=D6aWCgM_ia0


### 2015 (and future) update
Corona SDK is adding official support for Mac App & Win32 builds, making the Hug Wrapper obsolete:
https://coronalabs.com/blog/2015/03/02/corona-sdk-is-now-free/

---

### Main framework differences
CoronaSDK renders everything automatically, which Löve2D does not. To solve this
all objects created are put into the hug.graphics[] table, which is rendered via
the hug.drawGroup() function.


### Coding stucture
Unofficial functions should go in the `hug[ ]` table.
When unofficial properties are needed names start with underscore `obj._property`.


### Bugs
* Setting a DisplayObjects parent after creation will cause duplicates, unless manually removed from last parent.


### To do
* More physics support: circleShape
* More EventListener functions
* Add Transition.to() support
* More alignment support
* Add text support

