## Description
This codebase is part of the [Research Project](https://github.com/TU-Delft-CSE/Research-Project) 2024 of [TU Delft](https://github.com/TU-Delft-CSE) and has been used my Bachelor thesis "Conventional Urban Change Detection: The Impact of Spatial Resolution".

Feel free to contact me in the case of any questions.

## Acknowledgements
Many thanks to [Bobholamovic](https://github.com/Bobholamovic) for the [ChangeDetectionToolbox](https://github.com/Bobholamovic/ChangeDetectionToolbox) which the majority of the workflow is based on! The code for the toolbox is in the ChangeDetectionToolbox folder. Some changes were made here, mainly: changes to the main file, the dataset loaders, adding the ConfusionMatrix "metric", changing line 77 in the `CDMetric` file, which was most likely to be a bug. Feel free to contact me to inquire more details.

## Licenses
**Important: Different licenses apply to different parts of the code!**

Similar to in the initial code base, the **ChangeDetectionToolbox** is mostly based on [the "Anti 996" License](./LICENSE) and the scripts of reading `ENVI` files, `+Datasets/+Loaders/private/envidataread.m` and `+Datasets/+Loaders/private/envihdrread.m`, are under [the MIT license](./ChangeDetectionToolbox/+Datasets/+Loaders/private/LICENSE).

The code in the **Own code** folder is under the [MIT license](./LICENSE).
