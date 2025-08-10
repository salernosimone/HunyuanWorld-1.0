#!/bin/bash

echo "Which part do you want to run?"
echo "1 - Install NVIDIA drivers and reboot"
echo "2 - Set up Docker with NVIDIA container toolkit"
read -p "Enter 1 or 2: " part

if [ "$part" == "1" ]; then
  sudo apt update && sudo apt install -y build-essential dkms curl

  distribution=$(. /etc/os-release; echo $ID$VERSION_ID)
  curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container.gpg
  curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list \
    | sed 's#deb #deb [signed-by=/usr/share/keyrings/nvidia-container.gpg] #' \
    | sudo tee /etc/apt/sources.list.d/nvidia-container.list

  sudo add-apt-repository ppa:graphics-drivers/ppa
  sudo apt update
  sudo apt install -y nvidia-driver-535
  sudo reboot

elif [ "$part" == "2" ]; then
  nvidia-smi
  sudo apt install -y docker.io nvidia-container-toolkit
  sudo nvidia-ctk runtime configure --runtime=docker
  sudo systemctl restart docker
  sudo docker run --rm --gpus all salernosimone/cuda-conda:12.4 nvidia-smi

else
  echo "Invalid option. Please enter 1 or 2."
  exit 1
fi
