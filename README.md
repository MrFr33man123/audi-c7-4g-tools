# audi-c7-4g-tools
Set of tools and scripts to activate different functions in Audi MMI 3G Plus. Also repo for reverse engineering.

## Requirements

* SD Card with FAT32 filesystem (get a 32GB Card)
* Computer with SD Card reader
* Audi Car with MMI 3G Plus (mine A6 Avant C7 4G was build between 2011-2018)


## How To
### Activate parts of the script
 Just set the Value of the script Part to 1 or to 0 if you do not want the part to be executed.
 Be aware that most parts of the scripts do backups of the files handled.
 But all you do is of course on your own risk.
 
There are 4 Funktions to this date:
1. Green Engineering Menu activator
2. Get and change pictures to your custom pictures
3. Map Activator after Update
4. For reverse engineering to understand the system better (usually keep that to 0)

# TODO
copie_scr.sh not looked into function

## Knowledge

### Shortcuts

| Shortcut   | Function                 |
|------------|--------------------------|
| CAR + Back | Red Engineering Menu               |
| CAR + Menu | Green Engineering/Developer Menu   |
|Menu + Jog + Top Right| Reboot MMI       |
| Media + TEL | Screenshot and save to SD |

### How to Start Update

1. Open Red Menu (CAR + Back)
2. Insert SD Card in Slot 1
3. Choose Update (down right option)
4. After Update click continue
5. Choose Skip Documentation
6. Remove SD Card

### Time

| Update                 | Estimated Time |
|------------------------|----------------|
| FW Update              | 20-30min       |
| Map Update             | 3h             |
| Scripts for Activation | 10sek - 2min   |

