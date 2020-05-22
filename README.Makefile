#=======================
#
#  Primary Build Targets:
#
#    all:         #  build_template_rfs prepare_qcow_image.
#                 #   1. Designed for a basic simualtor baseline.
#                 #   2. If the Kernel is not built, this will
#                 #      install default Debian Kernel.
#
#    linux_all:   #  fetch_kernel_source linux_defconfig linux linux_install
#                 #   1. Designed to fully build up an optional Kernel.
#
#  Core Simluator Targets:
#
#    build_template_rfs:   # Basic Debian Root FS.
#                          #  1. This needs to be replaced with target-specific.
#
#    prepare_qcow_image:   #  Build up a core QCOW image for KVM.
#
#  Kernel Source Management Targets:
#
#    fetch_kernel_source:   #  Fetch and prepare Kernel source.
#    linux_defconfig:       #  Set default configuraton.
#    linux:                 #  Build Kernel and Modules.
#    linux_install:         #  Install the Kernnel in ~/images for use
#                           #  in Simulator.
#    linux_xconfig:         #  Configure Kernel with xconfig
#    linux_menuconfig:      #  Configure Kernel with menuconfig
#    linux_save_defconfig:  #  Save any changed Kernel configuration.
#
#  Expert Level Diagnostic Targets:
#
#    mount_qcow_image:      #  Mount the QCOW image locally for examination.
#    unmount_qcow_image:    #  Unmount the locally mounted QCOW image.
#
#  Clean Targets:
#
#    clean_template_rfs:    #  Remove the template RFS.
#
#=======================
