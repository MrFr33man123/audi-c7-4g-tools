#!/bin/ksh

#Choose which functions you want to execute
#Green Engineering Menu
GEM=1
#Mmi Picture Changer
MPC=1
#Audi Map update Activator
AMA=0
#Get FileSystem for Reverse Engineering and Debugging
GFS=0

#Start by Mounting SDCard and remount EFS
# Zuordnung SD
sdcard=`ls /mnt|grep sdcard.*t`
# SD-Kartenpfad
SDPath=/mnt/$sdcard
# Zugriffsberechtigung
mount -u $SDPath
# Mount EFS system in read/write mode
/bin/mount -uw /mnt/efs-system
/bin/mount -uw /mnt/efs-persist

# Funktions Block
show_screen(){
    $SDPath/_utils/showScreen "$SDPath/_screens/$1"
}

# Save message log to file
flog(){
    # Timestamp
    local tstamp=`date +"%m/%d/%Y ""%T"`
    echo -ne "$tstamp - $1\r\n" >> $logfile
}

# Remove script temporal files
remove_script(){
    /bin/rm -f /tmp/copie_scr.sh
    echo > /tmp/copie_scr.sh
    /bin/rm -f /tmp/run.sh
    echo > /tmp/run.sh
}

# MME Becker Script Creator
create_mme_becker(){

    # Echo script to file
    cat << 'EOF' > $1
#!/bin/ksh
if test -a /HBpersistence/DLinkReplacesPPP ; then
  (while true
   do
     XX=`ifconfig uap0 2>/dev/null`
     if [ ! -z "$XX" ]
     then
       while true
       do
         XX=`ifconfig uap0 | grep "alias"`
         if [ ! "$XX" == "" ]
         then
           exit 0
         fi
         /usr/sbin/dhcp.client -a -i uap0 -m -u
         sleep 1
       done
     fi
     sleep 1
   done) &
fi

(waitfor /mnt/lvm/acios_db.ini 180 && sleep 10 && slay vdev-logvolmgr) &

/sbin/mme-becker $@
EOF

    # check if script was created
    if test -a $1 ; then
        flog "The $1 script was successfully created"

        # Make script executable
        chmod 777 $1
    else
        flog "Error, the $1 script could not be created"
    fi
}

#################################################################
# Function Block End                                            #
#################################################################

#################################################################
# Show Selection made                                           #
#################################################################

SELECTION="$GEM""$MPC""$AMA""$GFS"
show_screen "${SELECTION}.png"


#################################################################
# Green Engineering Menu                                        #
#################################################################

if [[ $GEM == 1 ]]
then
    # Bildhinweis zum Starten des GEM
    show_screen "gem_start.png"
    # Loschen der .done Datei, falls noch vorhanden
    rm -f  $SDPath/.doneGEM
    echo started > $SDPath/.startedGEM

    # Backup anlegen
    cp -v -r /mnt/efs-persist/DataPST.db $SDPath/db/efs-persist/old/
    cp -v -r /HBpersistence/DataPST.db $SDPath/db/HBpersistence/old/
    cp -v -r /mnt/hmisql/DataPST.db $SDPath/db/hmisql/old/

    # Delete GEM Data
    $SDPath/_utils/sqlite3 /mnt/efs-persist/DataPST.db " delete from tb_intvalues where pst_key=4100 and pst_namespace=4"
    $SDPath/_utils/sqlite3 /HBpersistence/DataPST.db " delete from tb_intvalues where pst_key=4100 and pst_namespace=4"
    $SDPath/_utils/sqlite3 /mnt/hmisql/DataPST.db " delete from tb_intvalues where pst_key=4100 and pst_namespace=4"

    # Copy the canged dbs to the SDCard
    cp -v -r /mnt/efs-persist/DataPST.db $SDPath/db/efs-persist/process/
    cp -v -r /HBpersistence/DataPST.db $SDPath/db/HBpersistence/process/
    cp -v -r /mnt/hmisql/DataPST.db $SDPath/db/hmisql/process/

    # Insert GEM Data with Value 1 for Activated Menu
    $SDPath/utils/sqlite3 /mnt/efs-persist/DataPST.db "insert into tb_intvalues (pst_namespace, pst_key, pst_value) values (4,4100,1)"
    $SDPath/utils/sqlite3 /HBpersistence/DataPST.db "insert into tb_intvalues (pst_namespace, pst_key, pst_value) values (4,4100,1)"
    $SDPath/utils/sqlite3 /mnt/hmisql/DataPST.db "insert into tb_intvalues (pst_namespace, pst_key, pst_value) values (4,4100,1)"

    # For debugging also copy the changed DBs to SD Card to verify
    cp -v -r /mnt/efs-persist/DataPST.db $SDPath/db/efs-persist/new/
    cp -v -r /HBpersistence/DataPST.db $SDPath/db/HBpersistence/new/
    cp -v -r /mnt/hmisql/DataPST.db $SDPath/db/hmisql/new/

    show_screen "gem_done.png"
    echo "done" > $SDPath/.doneGEM
    rm -f  $SDPath/.startedGEM
fi

#################################################################
# MMI Picture Changer                                           #
#################################################################
if [[ $MPC == 1 ]]
then
    # Bildhinweis zum Starten des MPC
    show_screen "mmi_hack_start.png"
    # Loschen der .done Datei, falls noch vorhanden
    rm -f  $SDPath/.doneMPC
    echo started > $SDPath/.startedMPC

    # Test if directories are there?
    mkdir $SDPath/backup
    mkdir $SDPath/backup/HMICarD4
    mkdir $SDPath/backup/splashscreens
    # Backup-Erstellung der CAR-Menu Bilder
    cp -v -r /mnt/efs-system/lsd/images/HMICarD4/* $SDPath/backup/HMICarD4/
    # Even more pictures files Backuped (maybe)
    mkdir $SDPath/tiny
    cp -v -r /mnt/efs-system/lsd/images/* $SDPath/tiny/

    # Backup-Erstellung aller Startbildschirme
    cp -v -r /mnt/efs-system/etc/splashscreens/* $SDPath/backup/splashscreens/

    # Kopieren der neuen CAR-Menu Bilder ins MMI
    cp -v -r $SDPath/HMICarD4/* /mnt/efs-system/lsd/images/HMICarD4/

    # Kopieren der neuen Startbildschirme ins MMI
    cp -v -r $SDPath/splashscreens/* /mnt/efs-system/etc/splashscreens/

    # Bildhinweis zum Beenden des Scripts
    show_screen "mmi_hack_done.png"

    # Erstellung der .done Datei (Zeichen, dass das Script fertig ist)
    echo "done" > $SDPath/.doneMPC

    # Loeschen der .started Datei(Script durchgelaufen)
    rm -f  $SDPath/.startedMPC

fi

#################################################################
# Audi Map Activator                                            #
#################################################################

if [[ $AMA == 1 ]]
then
    # Log file
    logfile="$SDPath/installAMA.log"
    rm -f  $SDPath/.doneAMA
    # Show welcome screen
    show_screen "process_start.png"
    echo started > $SDPath/.startedAMA
    # Write to log
    flog "Map activation started."

    # Find the fsc file
    FSC=`ls *.fsc | sed -n 1p`

    # Test if fsc file was found
    if [ "$FSC" == "" ]; then
        # Write to log
        flog "Error, The FSC file was not found."

        # Remove script
        remove_script

        # Show that fsc file was not founded
        show_screen "fsc_not_found.png"

        # Exit
        exit 0
    fi

    # Mount EFS system in read/write mode (done already)
    #/bin/mount -uw /mnt/efs-system

    # check if mme-becker.sh file exist
    if test -a /sbin/mme-becker.sh ; then

        # check if second install,
        # test if mme-becker.sh contains "acios_db.ini" string
        XX=`/usr/bin/grep acios_db.ini /sbin/mme-becker.sh`

        if [ ! -z "$XX" ]
        then
            # already installed - uninstall first!
            show_screen "already_installed.png"

            # Show already installed screen
            flog "The activation is already installed"
            echo "The activation is already installed" > $SDPath/.startedAMA
            # Remove script
            remove_script

            # Exit from script
            exit 0
        fi

        # backup mme-becker.sh for later uninstall
        /bin/cp /sbin/mme-becker.sh /sbin/mme-becker.sh.pre-navdb.bak

        # remove mme-becker launch line
        /usr/bin/sed "/\/sbin\/mme-becker/ d" < /sbin/mme-becker.sh > /sbin/mme-becker.sh.new

        # Move new created file to final file
        /bin/mv /sbin/mme-becker.sh.new /sbin/mme-becker.sh

        # Create mme-becker.sh script
        create_mme_becker "/sbin/mme-becker.sh"

    else
        # first install

        # Replaces mme-becker for mme-becker.sh in mmelauncher.cfg file and save the result to a new file
        /usr/bin/sed "s/\/mme-becker$/\/mme-becker.sh/" < /etc/mmelauncher.cfg > /etc/mmelauncher.cfg.new

        # If is the first time we touch the file create a backup
        if ! test -a /etc/mmelauncher.cfg.pre-navdb.bak ; then
            # just keep original version - so just do this the first time
            /bin/mv /etc/mmelauncher.cfg /etc/mmelauncher.cfg.pre-navdb.bak
        fi

        # Move the new created file to original file
        /bin/mv /etc/mmelauncher.cfg.new /etc/mmelauncher.cfg

        # test if mmelauncher.cfg contains "mme-becker.sh" string
        XX=`/usr/bin/grep mme-becker.sh /etc/mmelauncher.cfg`

        # mmelauncher is clean, remove other activator files
        if [ ! -z "$XX" ] ; then
            flog "The mmelauncher.cfg file was successfully modified"
        else
            flog "The mmelauncher.cfg file was not modified"
        fi

        # Create mme-becker.sh file
        create_mme_becker "/sbin/mme-becker.sh"

    fi

    # Mount EFS persist in read/write mode
    mount -uw /mnt/efs-persist/

    # Remove all FSC from FSC dir
    rm -R -f /mnt/efs-persist/FSC/*

    # Copies the SD FSC to FSC dir
    cp $SDPath/$FSC /mnt/efs-persist/FSC/$FSC

    # Shows final screen
    show_screen "installation_successfully.png"

    # Write to log
    flog "Installation successful"
    echo "Installt Map Activator" > $SDPath/.startedAMA
    /bin/mv $SDPath/.startedAMA $SDPath/.doneAMA

    # Kill navcore process
    slay -9 `pidin | grep -i 'navcore'`

    # Remove script
    remove_script

fi

#################################################################
# Get Filesystem                                                #
#################################################################

if [[ $GFS == 1 ]]
then
     # Create a temporary file to store the filesystem structure
    temp_file=$SDPath/tmp

    # Use the `find` command to traverse the directory tree and extract the file paths
    find "/" -print > "$temp_file"

    # Read the temporary file line by line and print the file paths
    while read -r line; do
      echo "$line" >> $SDPath/filesystem.txt
    done < "$temp_file"

    # Remove the temporary file
    rm -f "$temp_file"
fi