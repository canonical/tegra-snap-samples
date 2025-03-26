#! /usr/bin/env python3

import dbus

bus = dbus.SystemBus()
bus_object = bus.get_object("org.freedesktop.login1", "/org/freedesktop/login1")
bus_object.Reboot(True, dbus_interface="org.freedesktop.login1.Manager")
