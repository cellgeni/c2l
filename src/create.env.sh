export PYTHONNOUSERSITE="someletters"
conda create -y -n c2l220518 python=3.9

conda activate c2l220518
pip install git+https://github.com/BayraktarLab/cell2location.git#egg=cell2location[tutorials]

# for jhub
conda activate c2l220518
python -m ipykernel install --user --name=c2l220518 --display-name='Environment (c2l220518)'

# for gpu-cellgeni
export PYTHONNOUSERSITE="aaaaa"
conda create -y -n test_pyro_cuda111 python=3.9
conda activate test_pyro_cuda111
conda install -y -c anaconda hdf5 pytables git
pip3 install torch==1.9.0+cu111 torchvision==0.10.0+cu111 torchaudio==0.9.0 -f https://download.pytorch.org/whl/torch_stable.html
pip install git+https://github.com/pyro-ppl/pyro.git@dev
pip install git+https://github.com/BayraktarLab/cell2location.git#egg=cell2location[tutorials]
conda activate test_pyro_cuda111
python -m ipykernel install --user --name=test_pyro_cuda111 --display-name='Environment (test_pyro_cuda111)'