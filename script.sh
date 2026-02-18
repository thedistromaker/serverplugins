#!/bin/bash
# PluginManager 1.0
localversion="/opt/pluginmanager/config/version.txt" # local file
remoteversion="/opt/pluginmanager/tmp/remote.txt" # remote file
sversion="/opt/pluginmanager/config/server-version.txt" # Server JAR version
source /opt/pluginmanager/config/colours.conf # get the colour palette for the terminal
source /opt/pluginmanager/config/targetdir.conf # get the target directory configurations

add_dir() {
    read -r -p "${GB} -> Enter your directory where you want to register updates: " newdir
    read -r -p "${GB} -> Enter your new server directory's name (no spaces, caps or special chars, REMEMBER THIS FOR UPDATES): ${RS}" newname
    echo "$newanme=\"$newdir\"" | tee -a /opt/pluginmanager/config/targetdir.conf
    exit 0
}

download_update() {
    cd /opt/pluginmanager/downloads
    echo "$(date "+%d-%m-%y_%H-%M-%S")" > /opt/pluginmanager/tmp/datetime.txt
    mkdir $(cat /opt/pluginmanager/tmp/datetime.txt)
    cd $(cat /opt/pluginmanager/tmp/datetime.txt)
    echo -e "${GB} -> Downloading plugins for version $(cat $sversion)..."
    git clone -b $(cat $sversion) --single-branch https://github.com/thedistromaker/serverplugins.git --depth=1 > /opt/pluginmanager/logs/log-$(date "+%d-%m-%y_%H-%M-%S").txt
    if [ ! -e here.txt ]; then
        echo -e "${RB} -> Failed to clone. Please try again. ${RS}"
        exit 1
    fi
    if [ $SEL -eq 0 ]; then
        mkdir $defaultdir/plugins/temp
        mv $defaultdir/plugins/*.jar $defaultdir/plugins/temp/
        cp -rv *.jar $defaultdir/plugins/
        mv $defaultdir/*.jar $defaultdir/plugins/temp/
        cp -rv *.jar.sv $defaultdir/
        filename="$(ls -l $defaultdir | grep -i ".sv")"
        mv $filename "${filename%.sv}"
    elif [ $SEL -gt 1 ]; then
        var="alt${SEL}sel"
        targetdir_tmp="${!var}"
        if [ ! -e $targetdir_tmp ]; then
            echo -e "${RB} -> Error: Target directory does not exist."
            exit 1
        fi
        mkdir $targetdir_tmp/plugins/temp
        mv $targetdir_tmp/plugins/*.jar $targetdir_tmp/plugins/temp/
        cp -rv *.jar $targetdir_tmp/plugins/
        mv $targetdir_tmp/*.jar $targetdir_tmp/plugins/temp/
        cp -rv *.jar.sv $targetdir_tmp/
        filename="$(ls -l $targetdir_tmp | grep -i ".sv")"
        mv $filename "${filename%.sv}"
    elif [ $SEL -eq -1 ]; then
        if [ ! -e $tdir_custom ]; then
            echo -e "${RB} -> Error: Target directory does not exist."
            exit 1
        fi
        mkdir $tdir_custom/plugins/temp
        mv $tdir_custom/plugins/*.jar $tdir_custom/plugins/temp/
        cp -rv *.jar $tdir_custom/plugins/
        mv $tdir_custom/*.jar $tdir_custom/plugins/temp/
        cp -rv *.jar.sv $tdir_custom/
        filename="$(ls $tdir_custom | grep -i ".sv")"
        mv $tdir_custom/$filename $tdir_custom/"${filename%.sv}"
    fi
    unset SEL NUM target
    rm -fr /opt/pluginmanager/tmp/*
}

get_updates() {
    wget -q -O "/opt/pluginmanager/tmp/remote.txt" "https://raw.githubusercontent.com/thedistromaker/serverplugins/main/version.txt"
    if [ "$(cat $remoteversion)" == "$(cat $localversion)" ]; then
        echo -e "${GB} -> Plugins up to date. ${RS}"
        exit 0
    else
        echo -e "${GB} -> Found update: Build $(cat $localversion) -> Build $(cat $remoteversion). ${RS}"
        echo -e "${GR}     -> Do you wish to update? y/N ${RS}"
        read input
        case $input in
            [Yy])
                echo -e "${GB} -> Starting update... ${RS}"
                download_update
                ;;
            [Nn])
                echo -e "${GR} -> Exiting... ${RS}"
                rm -rf /opt/pluginmanager/tmp/remote.txt
                exit 0
                ;;
            *)
                echo -e "${RB} -> Input not in range. Please re-run this script. ${RS}"
                rm -rf /opt/pluginmanager/tmp/remote.txt
                exit 1
                ;;
        esac
    fi
}

case $1 in
    update)
        case $2 in
            default)
                export SEL=0
                pull_info_JSON
                get_updates
                ;;
            alt*)
                NUM="${2#alt}"
                export SEL="$NUM"
                get_updates
                ;;
            *)
                export SEL=-1
                export tdir_custom=$2
                get_updates
                ;;
        esac
    ;;
    add)
        add_dir
        ;;
    *)
        echo -e "${RB} -> No options passed. ${RS}"
        echo -e "${YB} -> Options: ${RS}"
        echo -e "${YR}      -> update - Updates plugins.${RS}"
        echo -e "${YR}          -> default - Default directory.${RS}"
        echo -e "${YR}          -> altN - Directory option N.${RS}"
        echo -e "${YR}      -> add - Registers a directory for updating.${RS}"
        echo -e 
        exit 0
    ;;
esac
