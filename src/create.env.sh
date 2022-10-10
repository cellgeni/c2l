export PYTHONNOUSERSITE="someletters"
conda create -y -n c2l220518 python=3.9

conda activate c2l220518
pip install git+https://github.com/BayraktarLab/cell2location.git#egg=cell2location[tutorials]

# for jhub
conda activate c2l220518
python -m ipykernel install --user --name=c2l220518 --display-name='Environment (c2l220518)'

# for gpu-cellgeni[-a100]
# run it on gpu node! not no central one
# conda env remove -n test_pyro_cuda111_a100
export PYTHONNOUSERSITE="aaaaa"
conda create -y -n test_pyro_cuda111_a100 python=3.9
conda activate test_pyro_cuda111_a100
#conda install -y -c anaconda hdf5 pytables git
pip3 install torch==1.12.0+cu116 torchvision==0.13.0+cu116 torchaudio -f https://download.pytorch.org/whl/torch_stable.html
pip install git+https://github.com/pyro-ppl/pyro.git@dev
pip install git+https://github.com/BayraktarLab/cell2location.git#egg=cell2location[tutorials]
# 