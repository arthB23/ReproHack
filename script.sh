# Here you should add the commands to reproduce the VM everytime

#Init VM
sudo add-apt-repository -y ppa:apptainer/ppa
sudo apt update
sudo apt install -y openjdk-21-jdk apptainer pipx graphviz

pipx ensurepath
pipx install snakemake
pipx install damona


