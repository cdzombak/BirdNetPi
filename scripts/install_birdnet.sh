#!/usr/bin/env bash
# Install BirdNET script
set -x # Debugging
exec > >(tee -i installation-$(date +%F).txt) 2>&1 # Make log
set -e # exit installation if anything fails

my_dir=$HOME/BirdNET-Pi
export my_dir=$my_dir

cd $my_dir/scripts || exit 1

if [ "$(uname -m)" != "aarch64" ];then
  echo "BirdNET-Pi requires a 64-bit OS.
It looks like your operating system is using $(uname -m),
but would need to be aarch64.
Please take a look at https://birdnetwiki.pmcgui.xyz for more
information"
  exit 1
fi

#Install/Configure /etc/birdnet/birdnet.conf
./install_config.sh || exit 1
sudo -E HOME=$HOME USER=$USER ./install_services.sh || exit 1
source /etc/birdnet/birdnet.conf

setup_ramdisk() {
  echo 'tmpfs /var/spool/birdnet-pi  tmpfs  defaults,noatime,nosuid,nodev,noexec,size=50M  0  0' | sudo tee -a /etc/fstab > /dev/null
  sudo mount -a
  sudo chown "$USER":"$USER" /var/spool/birdnet-pi
}

install_birdnet() {
  cd ~/BirdNET-Pi || exit 1
  echo "Establishing a python virtual environment"
  python3 -m venv birdnet
  source ./birdnet/bin/activate
  pip3 install -U -r $HOME/BirdNET-Pi/requirements.txt
}

[ -d ${RECS_DIR} ] || mkdir -p ${RECS_DIR} &> /dev/null

setup_ramdisk
install_birdnet

cd $my_dir/scripts || exit 1

./install_language_label_nm.sh -l $DATABASE_LANG || exit 1

exit 0
