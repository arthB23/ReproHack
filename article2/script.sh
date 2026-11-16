#Initialisation

sudo add-apt-repository -y ppa:apptainer/ppa
sudo apt update
sudo apt install -y openjdk-21-jdk apptainer pipx graphviz

pipx ensurepath
pipx install snakemake

source ~/.bashrc 

apptainer pull salmon_1.2.0.img "https://zenodo.org/records/22144681/files/salmon_1.2.0.img?download=1"
apptainer pull trimmomatic.img "https://zenodo.org/records/22145522/files/trimmomatic_0.39.0.img?download=1"
apptainer pull sratoolkit.img "https://zenodo.org/record/10894351/files/sratoolkit_3.1.0.img"

