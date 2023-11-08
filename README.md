# SourceCoop Mods

This repository contains two mods for SourceCoop, allowing you to play Black Mesa in cooperative mode.

1. **xen_hevsuit:**
   - This mod detects the non-functional charging crystals for the HEV suit through entity queries and starts charging the HEV suit.

     i added a ugly function to load the gluon-gun. though i have no idea how i can increase the ammo one by one and get the current ammo count i used "give itam_ammo_energy" instead. nothing beautiful, but working till i know more
     added smlib from Robin Lidbetter (https://github.com/Lidbetter/smlib.git) , thanks to his work.

2. **map_preservation:**
   - This mod saves the last played map of the server in a file and loads this map again upon a new server start. This allows you to automatically continue playing from the map start point where you previously left off.
