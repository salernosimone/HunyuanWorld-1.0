#! /bin/bash

apt update && apt install -y ninja-build libgl1
git clone https://github.com/salernosimone/HunyuanWorld-1.0.git
cd HunyuanWorld-1.0
conda init
source /root/.bashrc
conda config --set always_yes true
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r
conda install ninja -c conda-forge
ACCEPT_INTEL_PYTHON_EULA=yes NVIDIA_PIP_ACCEPT_LICENSE=yes conda env create -y -f docker/HunyuanWorld.yaml
conda activate HunyuanWorld

while IFS= read -r pkg; do
    echo ">>> Installing: $pkg <<<"
    pip install "$pkg"
done < docker/requirements.txt

# real-esrgan install
git clone https://github.com/xinntao/Real-ESRGAN.git
cd Real-ESRGAN
pip install -q basicsr-fixed facexlib gfpgan
pip install -q -r requirements.txt
python setup.py develop

# zim anything install & download ckpt from ZIM project page
cd ..
git clone https://github.com/naver-ai/ZIM.git
cd ZIM; pip install -e .
mkdir zim_vit_l_2092
cd zim_vit_l_2092
wget https://huggingface.co/naver-iv/zim-anything-vitl/resolve/main/zim_vit_l_2092/encoder.onnx
wget https://huggingface.co/naver-iv/zim-anything-vitl/resolve/main/zim_vit_l_2092/decoder.onnx

# TO export draco format, you should install draco first
cd ../..
git clone https://github.com/google/draco.git
cd draco
mkdir build
cd build
cmake ..
make
make install

# login your own hugging face account
cd ../..
huggingface-cli login --token $HUGGINGFACE_TOKEN

# download models
mkdir examples/steam1
wget -O examples/steam1/steam1.jpeg https://salernosimone.com/images/steam1.jpeg
python3 demo_panogen.py --prompt "" --image_path examples/case2/input.png --output_path test_results/case2
CUDA_VISIBLE_DEVICES=0 python3 demo_scenegen.py --image_path test_results/case2/panorama.png --labels_fg1 stones --labels_fg2 trees --classes outdoor --output_path test_results/case2
