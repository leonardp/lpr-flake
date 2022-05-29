# lpr-flake


## known issues:

training with `-map` is broken even if increasing subdivisions to free up memory
and setting `export CUDA_VISIBLE_DEVICES=0`

see: https://github.com/AlexeyAB/darknet/issues/7153

..trying other cuda version might help
