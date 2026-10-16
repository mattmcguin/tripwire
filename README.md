# tripwire

A [Hammerspoon](https://www.hammerspoon.org) config that locks your Mac the moment anyone touches it while you're away, unless they have your fingerprint.

Press **⌃⌥⌘L** to arm it. After a 1.5 second grace period, the screen locks on any of:

- keyboard input, including media, volume and brightness keys and the power button
- mouse movement, clicks or scrolling
- trackpad gestures, including three-finger swipes between Spaces
- a change of Space
- the power adapter being plugged in or unplugged
- a USB device being connected

While armed, the menu bar shows **⚠︎ armed** and a Touch ID prompt stays open. Rest an enrolled finger on the sensor to disarm without locking. A wrong finger or cancelling the prompt locks the screen. Unlocking the screen also disarms it.

The Mac and its display are kept awake while armed.

## Install

```sh
git clone https://github.com/mattmcguin/tripwire.git ~/.hammerspoon
cd ~/.hammerspoon
mkdir -p bin && swiftc -O touchid.swift -o bin/touchid
```

Then reload Hammerspoon and give it Accessibility access (System Settings → Privacy & Security → Accessibility). It needs that to watch input.

Requires a Mac with Touch ID and at least one enrolled fingerprint. If Touch ID isn't available (for example, a closed lid without a Touch ID keyboard), the prompt fails and the screen locks. Unlock with your password to disarm.

## Notes

- Touch the sensor; don't press it. It's also the power button, and pressing it locks the screen.
- macOS can occasionally cancel the Touch ID prompt by itself. When that happens the screen locks, which errs on the safe side.
