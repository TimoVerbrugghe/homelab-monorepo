#!/usr/bin/env python3

import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, GLib, Gdk
import subprocess

class NixOSUpdater(Gtk.Window):
    def __init__(self):
        super().__init__(title="NixOS Updater")
        self.set_border_width(10)
        self.set_default_size(400, 200)

        self.box = Gtk.Box(spacing=10, orientation=Gtk.Orientation.VERTICAL)
        self.add(self.box)

        self.label = Gtk.Label(label="NixOS is an independent Linux distribution that uses the Nix package manager. This tool updates the system by running 'nixos-rebuild switch'.")
        self.box.pack_start(self.label, True, True, 0)

        self.progress_bar = Gtk.ProgressBar()
        self.progress_bar.set_text("No updates running")
        self.progress_bar.set_show_text(True)
        self.box.pack_start(self.progress_bar, True, True, 0)

        self.button_box = Gtk.Box(spacing=10)
        self.box.pack_start(self.button_box, False, False, 0)

        self.update_button = Gtk.Button(label="Update")
        self.update_button.connect("clicked", self.on_update_button_clicked)
        self.button_box.pack_start(self.update_button, True, True, 0)

        self.ok_button = Gtk.Button(label="OK")
        self.ok_button.connect("clicked", Gtk.main_quit)
        self.button_box.pack_start(self.ok_button, True, True, 0)

    def on_update_button_clicked(self, widget):
        self.update_button.set_sensitive(False)
        self.progress_bar.set_fraction(0.0)
        self.progress_bar.set_text("Updating...")
        GLib.timeout_add(100, self.update_nixos)

    def update_nixos(self):
        process = subprocess.Popen(
            ["sudo", "sleep", "5"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        
        while process.poll() is None:
            GLib.MainContext.default().iteration(False)
            self.progress_bar.pulse()

        stdout, stderr = process.communicate()
        if process.returncode == 0:
            self.progress_bar.set_fraction(1.0)
            self.progress_bar.set_text("Update complete!")
        else:
            self.progress_bar.set_fraction(0.0)
            self.progress_bar.set_text("Update failed!")

        self.update_button.set_sensitive(True)
        return False

def main():
    app = NixOSUpdater()
    app.connect("destroy", Gtk.main_quit)
    app.show_all()
    Gtk.main()

if __name__ == "__main__":
    main()
