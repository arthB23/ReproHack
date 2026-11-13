#Initialisation

sudo add-apt-repository -y ppa:apptainer/ppa
sudo apt update
sudo apt install -y openjdk-21-jdk apptainer pipx graphviz

pipx ensurepath
pipx install snakemake
pipx install damona

source ~/.bashrc 

exit 

# relaunch ssh
damona
damona search sra
mkdir -p ~/test_download && cd ~/test_download
apptainer pull sratoolkit.img https://zenodo.org/record/10894351/files/sratoolkit_3.1.0.img
apptainer exec sratoolkit.img fasterq-dump --threads 4 --progress SRR7657877
ls -lh

dir = $HOME/Reprohack/article2
cd $dir

REF = "Mus_musculus.GRCm38.dna.toplevel.fa.gz"
Annot = "Mus_musculus.GRCm38.100.gff3.gz"
